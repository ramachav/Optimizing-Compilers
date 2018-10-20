%{
  #include <stdio.h>
  #include <string>
  #include <stdlib.h>
  #include <iostream>
  #include <list>
  #include <sstream>
  #include "../src/asm_maker.h"
  using namespace std;
  
  extern int yylex();
  extern int yylineno;
  extern char *yytext;
  extern symbol_table_tree * stem;
  extern string current_leaf_scope;
  extern string current_branch_scope;
  extern list_data threeAC_list;
  extern list_data inter_list;
  extern list_instr tiny_list;
  extern list_instr inter_tiny_list;
  extern list_data rw_id_list;
  extern list_data assign_expr_list;
  extern int block_count;
  string leaf_type = "INT";
  int label_number = 1;
  int current_register_index = 1;
  
  void yyerror( const char *s) {
        //print_symbol_table_tree(stem);
       	printf("Not Accepted\n");
  	//printf("Error line %d token %s\n", yylineno, yytext);
  }

%}

%union{
  int leaf_int_value;
  float leaf_float_value;
  char * leaf_string_value;
  list_data * leaf_list;
  threeAC_node * ast_node;
}

%type <leaf_string_value> id id_list str var_type
%type <leaf_list> read_stmt write_stmt assign_expr assign_stmt else_part if_stmt for_stmt while_stmt stmt
%type <leaf_list> return_stmt base_stmt init_stmt incr_stmt cond stmt_list loop_stmt control_stmt call_expr
%type <leaf_list> expr expr_prefix factor factor_prefix expr_list expr_list_tail
%type <ast_node> addop mulop compop
%type <leaf_list> postfix_expr primary


%token <leaf_string_value> PROGRAM
%token <leaf_string_value> _BEGIN
%token <leaf_string_value> _END
%token <leaf_string_value> FUNCTION
%token <leaf_string_value> READ
%token <leaf_string_value> WRITE
%token <leaf_string_value> IF
%token <leaf_string_value> ELSE
%token <leaf_string_value> ENDIF
%token <leaf_string_value> WHILE
%token <leaf_string_value> ENDWHILE
%token <leaf_string_value> RETURN
%token <leaf_string_value> INT
%token <leaf_string_value> VOID
%token <leaf_string_value> STRING
%token <leaf_string_value> FLOAT
%token <leaf_string_value> TRUE
%token <leaf_string_value> FALSE
%token <leaf_string_value> FOR
%token <leaf_string_value> ENDFOR
%token <leaf_string_value> CONTINUE
%token <leaf_string_value> BREAK
%token <leaf_string_value> IDENTIFIER
%token <leaf_string_value> INTLITERAL
%token <leaf_string_value> FLOATLITERAL
%token <leaf_string_value> STRINGLITERAL
%token <leaf_string_value> ASSIGNOPERATOR
%token <leaf_string_value> ADDOPERATOR
%token <leaf_string_value> MINUSOPERATOR
%token <leaf_string_value> MULTIPLYOPERATOR
%token <leaf_string_value> DIVIDEOPERATOR
%token <leaf_string_value> EQUALS_TO
%token <leaf_string_value> NOT_EQUALS_TO
%token <leaf_string_value> LESS_THAN
%token <leaf_string_value> GREATER_THAN
%token <leaf_string_value> LESS_THAN_EQUAL
%token <leaf_string_value> GREATER_THAN_EQUAL
%token <leaf_string_value> SEMICOLON
%token <leaf_string_value> COMMA
%token <leaf_string_value> OPENPARENTHESIS
%token <leaf_string_value> CLOSEPARENTHESIS

%%

/* Program */
program:		PROGRAM id _BEGIN pgm_body _END {
			clean_3ac_list(threeAC_list);
			print_threeAC_code(threeAC_list);
			create_tiny_code(threeAC_list);
			clean_tiny_list(tiny_list);
			print_tiny_code(tiny_list);
			}; 
id:	   		IDENTIFIER;
pgm_body:		decl func_declarations;
decl:	   		string_decl decl | var_decl decl |;

/* Global String Declaration */
string_decl: 	 	STRING id ASSIGNOPERATOR str SEMICOLON { leaf_type = "STRING"; create_leaf($2, leaf_type, $4, 0, 0); };
str:			STRINGLITERAL;

/* Variable Declaration */
var_decl:      		var_type id_list SEMICOLON;
var_type:       	FLOAT { leaf_type = "FLOAT"; } | INT { leaf_type = "INT"; };
any_type:       	var_type | VOID; 
id_list:		id { create_leaf($1, leaf_type, "_", 0, 0); } id_tail;
id_tail:        	COMMA id { create_leaf($2, leaf_type, "_", 0, 0); } id_tail |;

/* Function Paramater List */
param_decl_list:        param_decl param_decl_tail |;
param_decl:	        var_type id { create_leaf($2, $1, "_", 0, 0); };
param_decl_tail:        COMMA param_decl param_decl_tail |;

/* Function Declarations */
func_declarations:      func_decl func_declarations |;
func_decl:	        FUNCTION any_type id { start_block_scope($3); } OPENPARENTHESIS param_decl_list CLOSEPARENTHESIS _BEGIN func_body _END { end_block_scope(); };
func_body:	        decl stmt_list {
			list_data * stmt_list_list = $2;
			threeAC_list.splice(threeAC_list.end(), *stmt_list_list);
			}; 

/* Statement List */
stmt_list:		stmt stmt_list {
			list_data * stmt_list_ptr = $1;
			list_data * stmt_list_list = $2;
			if(stmt_list_list != NULL && stmt_list_ptr != NULL)
				stmt_list_ptr->splice(stmt_list_ptr->end(), *stmt_list_list);
			$$ = stmt_list_ptr;
			} | { $$ = NULL; };
stmt:			base_stmt { $$ = $1; } | if_stmt { $$ = $1; } | loop_stmt { $$ = $1; };
base_stmt:		assign_stmt { $$ = $1; } | read_stmt { $$ = $1; } | write_stmt { $$ = $1; } | control_stmt { $$ = $1; };

/* Basic Statements */
assign_stmt:       	assign_expr SEMICOLON { $$ = $1; };
assign_expr:        	id ASSIGNOPERATOR expr {
			list_data * expr_list = $3;
			threeAC_node * temp_expr = expr_list->back();
			threeAC_node * fresh_node = new threeAC_node;

			fresh_node->Rt = "_";
			fresh_node->reg_dest = $1;
			fresh_node->op_value = ":=";
			fresh_node->op_type = temp_expr->op_type;
			//if(temp_expr->op_value == "+" || temp_expr->op_value == "-" || temp_expr->op_value == "*" || temp_expr->op_value == "/")
			if(expr_list->size() == 1 && temp_expr->op_value != "+" && temp_expr->op_value != "-" && temp_expr->op_value != "*" && temp_expr->op_value != "/") {
				threeAC_node * addon = new threeAC_node;
				addon->op_type = temp_expr->op_type;
				addon->op_value = (addon->op_type == "INT")? "STOREI" : "STOREF";
				addon->Rs = temp_expr->op_value;
				addon->Rt = "_";
				set_register_Rd(addon);
				fresh_node->Rs = addon->reg_dest;
				expr_list->pop_back();
				expr_list->push_back(addon);
				expr_list->push_back(fresh_node);
			}
			else {
				fresh_node->Rs = temp_expr->reg_dest;
				expr_list->push_back(fresh_node);
			}
			symbol_table_tree * temp_search = new symbol_table_tree;
			temp_search = check_leaf($1, "GLOBAL");
			if(temp_search != NULL)
				format_node(expr_list, temp_search->leaf_type);
			$$ = expr_list;
			};
read_stmt:          	read OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON {
			leaf_type = "Read_Write";
			list_data * read_stmt_list = new list_data;
			if(!rw_id_list.empty()) {
				list_data::iterator index;
				for(index = rw_id_list.begin(); index != rw_id_list.end(); index++) {
				threeAC_node * fresh_node = new threeAC_node;
				fresh_node->reg_dest = "_";
				fresh_node->Rt = "_";
				fresh_node->Rs = (*index)->Rs;
				if((*index)->op_value == "read_write_int")
					fresh_node->op_value = "sys readi";
				else if((*index)->op_value == "read_write_float")
				     	fresh_node->op_value = "sys readr";
				read_stmt_list->push_back(fresh_node);
				}
				rw_id_list.clear();
			}
			$$ = read_stmt_list;
			};
read:			READ { leaf_type = "Read_Write"; };
write_stmt:         	write OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON {
			leaf_type = "Read_Write";
			list_data * write_stmt_list = new list_data;
			if(!rw_id_list.empty()) {
				list_data::iterator index;
				for(index = rw_id_list.begin(); index != rw_id_list.end(); index++) {
				threeAC_node * fresh_node = new threeAC_node;
				fresh_node->reg_dest = "_";
				fresh_node->Rt = "_";
				fresh_node->Rs = (*index)->Rs;
				if((*index)->op_value == "read_write_int")
					fresh_node->op_value = "sys writei";
				else if((*index)->op_value == "read_write_float")
				     	fresh_node->op_value = "sys writer";
				else if((*index)->op_value == "read_write_string")
				        fresh_node->op_value = "sys writes";
				write_stmt_list->push_back(fresh_node);
				}
				rw_id_list.clear();
			}
			$$ = write_stmt_list;
			};
write:			WRITE { leaf_type = "Read_Write"; };
return_stmt:        	RETURN expr SEMICOLON { $$ = $2; };

/* Expressions */
expr:			expr_prefix factor {
			if($1 == NULL)
			      $$ = $2;
			else if($1 != NULL) {
			     list_data * expr_prefix_list = $1;
			     list_data * factor_list = $2;
			     threeAC_node * temp_factor = factor_list->back();
			     threeAC_node * temp_expr = expr_prefix_list->back();
			     //if(temp_factor->op_value == "+" || temp_factor->op_value == "-" || temp_factor->op_value == "*" || temp_factor->op_value == "/")
			     if(factor_list->size() == 1) {
			     		threeAC_node * fresh_node = new threeAC_node;
					fresh_node->op_type = temp_factor->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node);
					fresh_node->Rs = temp_factor->op_value;
					fresh_node->Rt = "_";
			      		temp_expr->right_child_op_value = fresh_node->reg_dest;
					temp_expr->right_child_op_type = temp_factor->op_type;
			      		temp_expr->Rs = temp_expr->left_child_op_value;
			      		temp_expr->Rt = temp_expr->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_expr->Rs;
					duplicate->Rt = temp_expr->Rt;
					duplicate->reg_dest = temp_expr->reg_dest;
					duplicate->op_type = temp_expr->op_type;
					duplicate->op_value = temp_expr->op_value;
					duplicate->left_child_op_value = temp_expr->left_child_op_value;
					duplicate->left_child_op_type = temp_expr->left_child_op_type;
					duplicate->right_child_op_value = temp_expr->right_child_op_value;
					duplicate->right_child_op_type = temp_expr->right_child_op_type;

					expr_prefix_list->pop_back();
					expr_prefix_list->push_back(fresh_node);
					expr_prefix_list->push_back(duplicate);
			      }
			      else {
					temp_expr->right_child_op_value = temp_factor->reg_dest;
			      		temp_expr->right_child_op_type = temp_factor->op_type;
			      		temp_expr->Rs = temp_expr->left_child_op_value;
			      		temp_expr->Rt = temp_expr->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_expr->Rs;
					duplicate->Rt = temp_expr->Rt;
					duplicate->reg_dest = temp_expr->reg_dest;
					duplicate->op_type = temp_expr->op_type;
					duplicate->op_value = temp_expr->op_value;
					duplicate->left_child_op_value = temp_expr->left_child_op_value;
					duplicate->left_child_op_type = temp_expr->left_child_op_type;
					duplicate->right_child_op_value = temp_expr->right_child_op_value;
					duplicate->right_child_op_type = temp_expr->right_child_op_type;

					expr_prefix_list->pop_back();
					expr_prefix_list->splice(expr_prefix_list->end(), *factor_list);
					expr_prefix_list->push_back(duplicate);
			      }
			      format_node(expr_prefix_list, temp_expr->op_type);
			      $$ = expr_prefix_list;
			}
			};
expr_prefix:       	expr_prefix factor addop {
			if($1 == NULL) {
			      list_data * factor_list = $2;
			      threeAC_node * temp_factor = factor_list->back();
			      threeAC_node * temp_addop = $3;
			      //if(!(temp_factor->op_value == "+" || temp_factor->op_value == "-" || temp_factor->op_value == "*" || temp_factor->op_value == "/"))
			      if(factor_list->size() == 1) {
			      		temp_addop->left_child_op_value = temp_factor->op_value;
					temp_addop->left_child_op_type = temp_factor->op_type;
					if(temp_factor->op_type == "INT")
			      			temp_addop->op_type = "INT";
			      		else if(temp_factor->op_type == "FLOAT")
			      	   	     	temp_addop->op_type = "FLOAT";
					factor_list->pop_back();
					factor_list->push_back(temp_addop);
			      }
			      else {
					temp_addop->left_child_op_value = temp_factor->reg_dest; 
			      		temp_addop->left_child_op_type = temp_factor->op_type;
			 	        if(temp_factor->op_type == "INT")
			      			temp_addop->op_type = "INT";
			                else if(temp_factor->op_type == "FLOAT")
			      	   	        temp_addop->op_type = "FLOAT";
					factor_list->push_back(temp_addop);
			      }
			      $$ = factor_list;
			}
			else if($1 != NULL) {
			      list_data * expr_prefix_list = $1;
			      list_data * factor_list = $2;
			      threeAC_node * temp_factor = factor_list->back();
			      threeAC_node * temp_expr = expr_prefix_list->back();
			      threeAC_node * temp_addop = $3;
			      //if(temp_factor->op_value == "+" || temp_factor->op_value == "-" || temp_factor->op_value == "*" || temp_factor->op_value == "/")
			      if(factor_list->size() == 1) {
			                threeAC_node * fresh_node = new threeAC_node;
					fresh_node->op_type = temp_factor->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node);
					fresh_node->Rs = temp_factor->op_value;
					fresh_node->Rt = "_";
			      		temp_expr->right_child_op_value = fresh_node->reg_dest;
					temp_expr->right_child_op_type = temp_factor->op_type;
					temp_expr->Rs = temp_expr->left_child_op_value;
					temp_expr->Rt = temp_expr->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_expr->Rs;
					duplicate->Rt = temp_expr->Rt;
					duplicate->reg_dest = temp_expr->reg_dest;
					duplicate->op_type = temp_expr->op_type;
					duplicate->op_value = temp_expr->op_value;
					duplicate->left_child_op_value = temp_expr->left_child_op_value;
					duplicate->left_child_op_type = temp_expr->left_child_op_type;
					duplicate->right_child_op_value = temp_expr->right_child_op_value;
					duplicate->right_child_op_type = temp_expr->right_child_op_type;

					expr_prefix_list->pop_back();
					expr_prefix_list->push_back(fresh_node);
					expr_prefix_list->push_back(duplicate);
					temp_addop->left_child_op_value = duplicate->reg_dest;
					temp_addop->left_child_op_type = duplicate->op_type;
					if(temp_factor->op_type == "INT")
			      			temp_addop->op_type = "INT";
			      		else if(temp_factor->op_type == "FLOAT")
			      	   	     	temp_addop->op_type = "FLOAT";
					expr_prefix_list->push_back(temp_addop);
			      }
			      else {
					temp_expr->right_child_op_value = temp_factor->reg_dest;
			      		temp_expr->right_child_op_type = temp_factor->op_type;
			      		temp_expr->Rs = temp_expr->left_child_op_value;
			      		temp_expr->Rt = temp_expr->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_expr->Rs;
					duplicate->Rt = temp_expr->Rt;
					duplicate->reg_dest = temp_expr->reg_dest;
					duplicate->op_type = temp_expr->op_type;
					duplicate->op_value = temp_expr->op_value;
					duplicate->left_child_op_value = temp_expr->left_child_op_value;
					duplicate->left_child_op_type = temp_expr->left_child_op_type;
					duplicate->right_child_op_value = temp_expr->right_child_op_value;
					duplicate->right_child_op_type = temp_expr->right_child_op_type;

					expr_prefix_list->pop_back();
					expr_prefix_list->splice(expr_prefix_list->end(), *factor_list);
					expr_prefix_list->push_back(duplicate);
					temp_addop->left_child_op_value = duplicate->reg_dest;
					temp_addop->left_child_op_type = duplicate->op_type;
					if(temp_factor->op_type == "INT")
			      			temp_addop->op_type = "INT";
			      		else if(temp_factor->op_type == "FLOAT")
			      	   	     	temp_addop->op_type = "FLOAT";
					expr_prefix_list->push_back(temp_addop);
			      }
			      $$ = expr_prefix_list;
			}			      
			} | { $$ = NULL; };
factor:            	factor_prefix postfix_expr {
			if($1 == NULL) 
			      $$ = $2;
			else if($1 != NULL) {
			      list_data * factor_prefix_list = $1;
			      list_data * postfix_expr_list = $2;
			      threeAC_node * temp_factor = factor_prefix_list->back();
			      threeAC_node * temp_post = postfix_expr_list->back();
			      if(postfix_expr_list->size() == 1) {
			      		threeAC_node * fresh_node = new threeAC_node;
					fresh_node->op_type = temp_post->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node);
					fresh_node->Rs = temp_post->op_value;
					fresh_node->Rt = "_";
			      		temp_factor->right_child_op_value = fresh_node->reg_dest;
					temp_factor->right_child_op_type = temp_post->op_type;
					temp_factor->Rs = temp_factor->left_child_op_value;
					temp_factor->Rt = temp_factor->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_factor->Rs;
					duplicate->Rt = temp_factor->Rt;
					duplicate->reg_dest = temp_factor->reg_dest;
					duplicate->op_type = temp_factor->op_type;
					duplicate->op_value = temp_factor->op_value;
					duplicate->left_child_op_value = temp_factor->left_child_op_value;
					duplicate->left_child_op_type = temp_factor->left_child_op_type;
					duplicate->right_child_op_value = temp_factor->right_child_op_value;
					duplicate->right_child_op_type = temp_factor->right_child_op_type;

					factor_prefix_list->pop_back();
					factor_prefix_list->push_back(fresh_node);
					factor_prefix_list->push_back(duplicate);
			      }
			      else {
					temp_factor->right_child_op_value = temp_post->reg_dest;
			      		temp_factor->right_child_op_type = temp_post->op_type;
			      		temp_factor->Rs = temp_factor->left_child_op_value;
			      		temp_factor->Rt = temp_factor->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_factor->Rs;
					duplicate->Rt = temp_factor->Rt;
					duplicate->reg_dest = temp_factor->reg_dest;
					duplicate->op_type = temp_factor->op_type;
					duplicate->op_value = temp_factor->op_value;
					duplicate->left_child_op_value = temp_factor->left_child_op_value;
					duplicate->left_child_op_type = temp_factor->left_child_op_type;
					duplicate->right_child_op_value = temp_factor->right_child_op_value;
					duplicate->right_child_op_type = temp_factor->right_child_op_type;

					factor_prefix_list->pop_back();
					factor_prefix_list->splice(factor_prefix_list->end(), *postfix_expr_list);
					factor_prefix_list->push_back(duplicate);
			      }
			      $$ = factor_prefix_list;
			}
			};
factor_prefix:     	factor_prefix postfix_expr mulop {
			if($1 == NULL) {
			      list_data * postfix_expr_list = $2;
			      threeAC_node * temp_post = postfix_expr_list->back();
			      threeAC_node * temp_mulop = $3;
			      threeAC_node * fresh_node = new threeAC_node;
			      if(postfix_expr_list->size() == 1) {
			      		fresh_node->op_type = temp_post->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node);
					fresh_node->Rs = temp_post->op_value;
					fresh_node->Rt = "_";
			      		temp_mulop->left_child_op_value = fresh_node->reg_dest;
			      }
			      else
					temp_mulop->left_child_op_value = temp_post->reg_dest;
			      temp_mulop->left_child_op_type = temp_post->op_type;
			      if(temp_post->op_type == "INT")
			      		temp_mulop->op_type = "INT";
			      else if(temp_post->op_type == "FLOAT")
			      	   	temp_mulop->op_type = "FLOAT";
			      if(postfix_expr_list->size() == 1) {
			      		postfix_expr_list->pop_back();
					postfix_expr_list->push_back(fresh_node);
			      }
			      postfix_expr_list->push_back(temp_mulop);
			      $$ = postfix_expr_list;
			}
			else if($1 != NULL) {
			      list_data * factor_prefix_list = $1;
			      list_data * postfix_expr_list = $2;
			      threeAC_node * temp_post = postfix_expr_list->back();
			      threeAC_node * temp_factor = factor_prefix_list->back();
			      threeAC_node * temp_mulop = $3;
			      if(postfix_expr_list->size() == 1) {
			      		threeAC_node * fresh_node = new threeAC_node;
			      		fresh_node->op_type = temp_post->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node);
					fresh_node->Rs = temp_post->op_value;
					fresh_node->Rt = "_";
			      		temp_factor->right_child_op_value = fresh_node->reg_dest;
			      		temp_factor->right_child_op_type = temp_post->op_type;
			      		temp_factor->Rs = temp_factor->left_child_op_value;
			      		temp_factor->Rt = temp_factor->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_factor->Rs;
					duplicate->Rt = temp_factor->Rt;
					duplicate->reg_dest = temp_factor->reg_dest;
					duplicate->op_type = temp_factor->op_type;
					duplicate->op_value = temp_factor->op_value;
					duplicate->left_child_op_value = temp_factor->left_child_op_value;
					duplicate->left_child_op_type = temp_factor->left_child_op_type;
					duplicate->right_child_op_value = temp_factor->right_child_op_value;
					duplicate->right_child_op_type = temp_factor->right_child_op_type;

					factor_prefix_list->pop_back();
					factor_prefix_list->push_back(fresh_node);
					factor_prefix_list->push_back(duplicate);
					temp_mulop->left_child_op_value = duplicate->reg_dest;
					temp_mulop->left_child_op_type = duplicate->op_type;
					if(temp_post->op_type == "INT")
			      			temp_mulop->op_type = "INT";
			      		else if(temp_post->op_type == "FLOAT")
			      	   	     	temp_mulop->op_type = "FLOAT";
					factor_prefix_list->push_back(temp_mulop);
			      }
			      else {
					temp_factor->right_child_op_value = temp_post->reg_dest;
					temp_factor->right_child_op_type = temp_post->op_type;
					temp_factor->Rs = temp_factor->left_child_op_value;
					temp_factor->Rt = temp_factor->right_child_op_value;

					threeAC_node * duplicate = new threeAC_node;
					duplicate->Rs = temp_factor->Rs;
					duplicate->Rt = temp_factor->Rt;
					duplicate->reg_dest = temp_factor->reg_dest;
					duplicate->op_type = temp_factor->op_type;
					duplicate->op_value = temp_factor->op_value;
					duplicate->left_child_op_value = temp_factor->left_child_op_value;
					duplicate->left_child_op_type = temp_factor->left_child_op_type;
					duplicate->right_child_op_value = temp_factor->right_child_op_value;
					duplicate->right_child_op_type = temp_factor->right_child_op_type;

					factor_prefix_list->pop_back();
					factor_prefix_list->splice(factor_prefix_list->end(), *postfix_expr_list);
					factor_prefix_list->push_back(duplicate);
					temp_mulop->left_child_op_value = duplicate->reg_dest;
					temp_mulop->left_child_op_type = duplicate->op_type;
					if(temp_post->op_type == "INT")
			      			temp_mulop->op_type = "INT";
			      		else if(temp_post->op_type == "FLOAT")
			      	   	     	temp_mulop->op_type = "FLOAT";
					factor_prefix_list->push_back(temp_mulop);
			      }
			      $$ = factor_prefix_list;
			}
			} | { $$ = NULL; };
postfix_expr:      	primary { $$ = $1; } | call_expr;
call_expr:         	id OPENPARENTHESIS expr_list CLOSEPARENTHESIS { $$ = $3; };
expr_list:         	expr expr_list_tail {
			list_data * expr_list_list = $1;
			list_data * expr_list_tail_list = $2;
			if(expr_list_tail_list != NULL)
				expr_list_list->splice(expr_list_list->end(), *expr_list_tail_list);
			$$ = expr_list_list;
			} | { $$ = NULL; };
expr_list_tail:    	COMMA expr expr_list_tail {
			list_data * expr_list_list = $2;
			list_data * expr_list_tail_list = $3;
			if(expr_list_tail_list != NULL)
				expr_list_list->splice(expr_list_list->end(), *expr_list_tail_list);
			$$ = expr_list_list;
			} | { $$ = NULL; };
primary:           	OPENPARENTHESIS expr CLOSEPARENTHESIS { $$ = $2; } | id {
			threeAC_node * fresh_node = new threeAC_node;
			list_data * primary_list = new list_data;
			int temp_block_count = block_count;
			string temp_leaf_scope;
			fresh_node->op_value = $1;
			symbol_table_tree * temp_search = new symbol_table_tree;
			
			/*while(temp_block_count > 0) {
				stringstream temp_string;
   				string int2string;
    				temp_string << temp_block_count;
    				int2string = temp_string.str();
    				temp_leaf_scope = "BLOCK " + int2string;
				temp_search = check_leaf($1, temp_leaf_scope);
				if(temp_search != NULL)
				     fresh_node->op_type = temp_search->leaf_type;
				temp_block_count--;
			}
			if(temp_search == NULL) {
				temp_search = check_leaf($1, "main");
				if(temp_search != NULL)
				     fresh_node->op_type = temp_search->leaf_type;
				else {*/
				     temp_search = check_leaf($1, "GLOBAL");
				     if(temp_search != NULL)
				     	  fresh_node->op_type = temp_search->leaf_type;
			//	}
			//}
			primary_list->push_back(fresh_node);
			$$ = primary_list;
			} | INTLITERAL {
			threeAC_node * fresh_node = new threeAC_node;
			list_data * primary_list = new list_data;
			fresh_node->op_value = $1;
			fresh_node->op_type = "INT";
			primary_list->push_back(fresh_node);
			$$ = primary_list;
			} | FLOATLITERAL {
			threeAC_node * fresh_node = new threeAC_node;
			list_data * primary_list = new list_data;
			fresh_node->op_value = $1;
			fresh_node->op_type = "FLOAT";
			primary_list->push_back(fresh_node);
			$$ = primary_list;
			};
addop:             	ADDOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "ADD";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node);
			$$ = fresh_node;
			} | MINUSOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "SUB";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node);
			$$ = fresh_node;
			};
mulop:             	MULTIPLYOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "MUL";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node);
			$$ = fresh_node;
			} | DIVIDEOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "DIV";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node);
			$$ = fresh_node;
			};

/* Complex Statements and Condition */ 
if_stmt:                if_stmt_start OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list else_part if_stmt_end {
				list_data * if_stmt_list = new list_data;
				list_data * cond_list = $3;
				list_data * stmt_list_list = $6;
				list_data * else_part_list = $7;
				threeAC_node * temp_cond = cond_list->back();
				threeAC_node * fresh_node1 = new threeAC_node;
				threeAC_node * fresh_node2 = new threeAC_node;
				threeAC_node * fresh_node3 = new threeAC_node;
				fresh_node1->op_value = "jmp";
				fresh_node1->Rs = "_";
				fresh_node1->Rt = "_";
				set_dest_label(fresh_node1);
				if_stmt_list->splice(if_stmt_list->end(), *cond_list);
				if_stmt_list->splice(if_stmt_list->end(), *stmt_list_list);
				if_stmt_list->push_back(fresh_node1);

				fresh_node2->op_value = "label";
				fresh_node2->Rs = "_";
				fresh_node2->Rt = "_";
				fresh_node2->reg_dest = temp_cond->reg_dest;
				if_stmt_list->push_back(fresh_node2);
				if(else_part_list != NULL)
					if_stmt_list->splice(if_stmt_list->end(), *else_part_list);
				
				fresh_node3->op_value = "label";
				fresh_node3->Rs = "_";
				fresh_node3->Rt = "_";
				fresh_node3->reg_dest = fresh_node1->reg_dest;
				if_stmt_list->push_back(fresh_node3);
				$$ = if_stmt_list;
			};
if_stmt_start:		IF { start_block_scope("BLOCK"); };
if_stmt_end:		ENDIF { end_block_scope(); };
else_part:         	else_part_start decl stmt_list { end_block_scope(); $$ = $3; } | { $$ = NULL; };
else_part_start:	ELSE { start_block_scope("BLOCK"); };

cond:              	expr compop expr {
			list_data * expr_list1 = $1;
			threeAC_node * temp_compop = $2;
			list_data * expr_list2 = $3;
			threeAC_node * temp_expr1 = expr_list1->back();
			threeAC_node * temp_expr2 = expr_list2->back();
			if(expr_list1->size() == 1) {
				temp_compop->left_child_op_value = temp_expr1->op_value;
				temp_compop->left_child_op_type = temp_expr1->op_type;
				expr_list1->pop_back();
				if(expr_list2->size() == 1) {
					threeAC_node * fresh_node = new threeAC_node;
					fresh_node->Rs = temp_expr2->op_value;
					fresh_node->Rt = "_";
					fresh_node->op_type = temp_expr1->op_type;
					set_register_Rd(fresh_node);
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					expr_list1->push_back(fresh_node);

					temp_compop->right_child_op_value = fresh_node->reg_dest;
					temp_compop->right_child_op_type = fresh_node->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = fresh_node->op_type;
					set_dest_label(temp_compop);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
				else {
					temp_compop->right_child_op_value = temp_expr2->reg_dest;
					temp_compop->right_child_op_type = temp_expr2->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = temp_expr2->op_type;
					set_dest_label(temp_compop);
					expr_list1->splice(expr_list1->end(), *expr_list2);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
			}
			else {
				temp_compop->left_child_op_value = temp_expr1->reg_dest;
				temp_compop->left_child_op_type = temp_expr1->op_type;
				if(expr_list2->size() == 1) {
					threeAC_node * fresh_node = new threeAC_node;
					fresh_node->Rs = temp_expr2->op_value;
					fresh_node->Rt = "_";
					fresh_node->op_type = temp_expr1->op_type;
					set_register_Rd(fresh_node);
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					expr_list1->push_back(fresh_node);

					temp_compop->right_child_op_value = fresh_node->reg_dest;
					temp_compop->right_child_op_type = fresh_node->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = fresh_node->op_type;
					set_dest_label(temp_compop);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
				else {
					temp_compop->right_child_op_value = temp_expr2->reg_dest;
					temp_compop->right_child_op_type = temp_expr2->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = temp_expr2->op_type;
					set_dest_label(temp_compop);
					expr_list1->splice(expr_list1->end(), *expr_list2);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
			}
			print_inter_list(*expr_list1, "Condition statement list");
			$$ = expr_list1;
			} | TRUE { $$ = NULL; } | FALSE {
			list_data * cond_list = new list_data;
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_value = "jmp";
			fresh_node->Rs = "_";
			fresh_node->Rt = "_";
			set_dest_label(fresh_node);
			cond_list->push_back(fresh_node);
			$$ = cond_list;
			};
compop:            	EQUALS_TO {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "EQ";
			fresh_node->op_value = "=";
			$$ = fresh_node;
			} | NOT_EQUALS_TO {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "NE";
			fresh_node->op_value = "!=";
			$$ = fresh_node;
			} | LESS_THAN {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "LT";
			fresh_node->op_value = "<";
			$$ = fresh_node;
			} | GREATER_THAN {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "GT";
			fresh_node->op_value = ">";
			$$ = fresh_node;
			} | LESS_THAN_EQUAL {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "LE";
			fresh_node->op_value = "<=";
			$$ = fresh_node;
			} | GREATER_THAN_EQUAL{
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "GE";
			fresh_node->op_value = ">=";
			$$ = fresh_node;
			};
while_stmt:        	while_stmt_start OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list while_stmt_end {
			list_data * while_stmt_list = new list_data;
			list_data * cond_list = $3;
			list_data * stmt_list_list = $6;
			threeAC_node * temp_cond = cond_list->back();
			threeAC_node * fresh_node1 = new threeAC_node;
			threeAC_node * fresh_node2 = new threeAC_node;
			threeAC_node * fresh_node3 = new threeAC_node;
			fresh_node1->op_value = "label";
			fresh_node1->Rs = "_";
			fresh_node1->Rt = "_";
			set_dest_label(fresh_node1);
			while_stmt_list->push_back(fresh_node1);
			while_stmt_list->splice(while_stmt_list->end(), *cond_list);
			while_stmt_list->splice(while_stmt_list->end(), *stmt_list_list);

			fresh_node3->reg_dest = fresh_node1->reg_dest;
			fresh_node3->Rs = "_";
			fresh_node3->Rt = "_";
			fresh_node3->op_value = "jmp";
			while_stmt_list->push_back(fresh_node3);

			fresh_node2->op_value = "label";
			fresh_node2->Rs = "_";
			fresh_node2->Rt = "_";
			fresh_node2->reg_dest = temp_cond->reg_dest;
			while_stmt_list->push_back(fresh_node2);
			$$ = while_stmt_list;
			};
while_stmt_start:	WHILE { start_block_scope("BLOCK"); };
while_stmt_end:		ENDWHILE { end_block_scope(); };
/*ECE573 ONLY*/
control_stmt:		return_stmt { $$ = $1; } | CONTINUE SEMICOLON {
			$$ = NULL; //To be fixed later on
			} | BREAK SEMICOLON {
			$$ = NULL; //To be fixed later on
			};
loop_stmt:         	while_stmt { $$ = $1; } | for_stmt { $$ = $1; };
init_stmt:         	assign_expr { $$ = $1; } | { $$ = NULL; };
incr_stmt:      	assign_expr { $$ = $1; } | { $$ = NULL; };
for_stmt:          	for_stmt_start OPENPARENTHESIS init_stmt SEMICOLON cond SEMICOLON incr_stmt CLOSEPARENTHESIS decl stmt_list for_stmt_end {
			list_data * for_stmt_list = new list_data;
			list_data * init_stmt_list = $3;
			list_data * cond_list = $5;
			list_data * incr_stmt_list = $7;
			list_data * stmt_list_list = $10;
			threeAC_node * temp_cond = cond_list->back();
			threeAC_node * fresh_node1 = new threeAC_node;
			threeAC_node * fresh_node2 = new threeAC_node;
			
			for_stmt_list->splice(for_stmt_list->end(), *init_stmt_list);
			fresh_node1->op_value = "label";
			fresh_node1->Rs = "_";
			fresh_node1->Rt = "_";
			set_dest_label(fresh_node1);
			for_stmt_list->push_back(fresh_node1);
			for_stmt_list->splice(for_stmt_list->end(), *cond_list);
			for_stmt_list->splice(for_stmt_list->end(), *stmt_list_list);
			for_stmt_list->splice(for_stmt_list->end(), *incr_stmt_list);

			fresh_node1->op_value = "jmp";
			for_stmt_list->push_back(fresh_node1);

			fresh_node2->op_value = "label";
			fresh_node2->Rs = "_";
			fresh_node2->Rt = "_";
			fresh_node2->reg_dest = temp_cond->reg_dest;
			for_stmt_list->push_back(fresh_node2);
			$$ = for_stmt_list;
			};
for_stmt_start:		FOR { start_block_scope("BLOCK"); };
for_stmt_end:		ENDFOR { end_block_scope(); };

%%

