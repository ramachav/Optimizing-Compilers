%{
  #include <stdio.h>
  #include <string>
  #include <stdlib.h>
  #include <iostream>
  #include <list>
  #include <set>
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
  extern reg_file register_file[4];
  string leaf_type = "INT";
  string current_function_scope = "GLOBAL";
  int function_slot_counter = 0;
  int function_param_counter = 0;
  int label_number = 1;
  int current_register_index = 0;
  int current_statement_number = 0;
  
  void yyerror( const char *s) {
        print_symbol_table_tree(stem);
       	printf("Not Accepted\n");
  	printf("Error line %d token %s\n", yylineno, yytext);
  }

%}

%union{
  int leaf_int_value;
  float leaf_float_value;
  char * leaf_string_value;
  list_data * leaf_list;
  threeAC_node * ast_node;
  list_data_list * leaf_list_list;
}

%type <leaf_string_value> id id_list str var_type
%type <leaf_list> read_stmt write_stmt assign_expr assign_stmt else_part if_stmt for_stmt while_stmt stmt
%type <leaf_list> return_stmt base_stmt init_stmt incr_stmt cond stmt_list loop_stmt control_stmt call_expr
%type <leaf_list> expr expr_prefix factor factor_prefix
%type <leaf_list_list> expr_list expr_list_tail
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
			print_symbol_table_tree(stem);
			clean_3ac_list(threeAC_list);
			print_threeAC_code(threeAC_list);
			create_tiny_code(threeAC_list);
			clean_tiny_list(tiny_list);
			print_tiny_code(tiny_list);
			dalloc_symbol_table_tree();
			};
id:	   		IDENTIFIER;
pgm_body:		decl func_declarations;
decl:	   		string_decl decl | var_decl decl |;

/* Global String Declaration */
string_decl: 	 	STRING id ASSIGNOPERATOR str SEMICOLON { leaf_type = "STRING"; create_leaf($2, leaf_type, $4, 0, 0, 0); };
str:			STRINGLITERAL;

/* Variable Declaration */
var_decl:      		var_type id_list SEMICOLON;
var_type:       	FLOAT { leaf_type = "FLOAT"; } | INT { leaf_type = "INT"; };
any_type:       	var_type | VOID { leaf_type = "_"; }; 
id_list:		id { create_leaf($1, leaf_type, "_", 0, 0, 0); } id_tail;
id_tail:        	COMMA id { create_leaf($2, leaf_type, "_", 0, 0, 0); } id_tail |;

/* Function Paramater List */
param_decl_list:        param_decl param_decl_tail |;
param_decl:	        var_type id { create_leaf($2, $1, "_", 0, 0, 1); };
param_decl_tail:        COMMA param_decl param_decl_tail |;

/* Function Declarations */
func_declarations:      func_decl func_declarations |;
func_decl:	        FUNCTION any_type id {			
			current_function_scope = $3;
			function_param_counter = 1;
			threeAC_node * fresh_node0 = new threeAC_node;
			fresh_node0->op_value = "label";
			fresh_node0->Rs = "_";
			fresh_node0->Rt = "_";
			fresh_node0->reg_dest = "FUNC_" + current_function_scope;
			threeAC_list.push_back(fresh_node0);
			start_block_scope($3, leaf_type);
			} OPENPARENTHESIS param_decl_list CLOSEPARENTHESIS _BEGIN func_body _END { end_block_scope(); };
	
func_body:	        decl stmt_list {
			list_data * stmt_list_list = $2;
			threeAC_node * fresh_node1 = new threeAC_node;
			threeAC_node * temp_threeAC_list = threeAC_list.back();
			fresh_node1->op_value = "link";
			fresh_node1->Rs = "_";
			fresh_node1->Rt = "_";
			stringstream temp_string;
			temp_string << count_function_params_or_locals(current_function_scope, 0);
			fresh_node1->reg_dest = temp_string.str();
			fresh_node1->predecessor0 = threeAC_list.back();
			if(stmt_list_list != NULL)
				fresh_node1->successor0 = stmt_list_list->front();
			temp_threeAC_list->successor0 = fresh_node1;
			if(stmt_list_list != NULL) {
				threeAC_node * temp_stmt_list_back = stmt_list_list->back();
				if(temp_stmt_list_back->op_value != "ret") {
					threeAC_node * unlink_instr = new threeAC_node;
					unlink_instr->op_value = "unlnk";
					unlink_instr->Rs = "_";
					unlink_instr->Rt = "_";
					unlink_instr->reg_dest = "_";
					stmt_list_list->push_back(unlink_instr);
			
					threeAC_node * return_instr = new threeAC_node;
					return_instr->op_value = "ret";
					return_instr->Rs = "_";
					return_instr->Rt = "_";
					return_instr->reg_dest = "_";
					stmt_list_list->push_back(return_instr);
				}
				stmt_list_list->push_front(fresh_node1);
				set_up_predecessor_and_successor(stmt_list_list);
				set_up_gen_and_kill(stmt_list_list);
				set_up_reach_gen_and_kill(stmt_list_list);
				set_up_in_and_out(stmt_list_list);
				set_up_reach_in_and_out(stmt_list_list);
				set_up_invariance_and_code_motion(stmt_list_list);
				register_reallocate(stmt_list_list);
				format_params_and_locals(stmt_list_list, current_function_scope);
				threeAC_list.splice(threeAC_list.end(), *stmt_list_list);
			}
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
base_stmt:		assign_stmt {
			current_statement_number++;
			list_data * assign_stmt_list = $1;
			list_data::iterator index = assign_stmt_list->begin();
			while(index != assign_stmt_list->end()) {
				(*index)->statement_number = current_statement_number;
				index++;
			}
			$$ = assign_stmt_list;
			} | read_stmt {
			current_statement_number++;
			list_data * read_stmt_list = $1;
			list_data::iterator index = read_stmt_list->begin();
			while(index != read_stmt_list->end()) {
				(*index)->statement_number = current_statement_number;
				index++;
			}
			$$ = read_stmt_list;
			} | write_stmt { $$ = $1; } | control_stmt { $$ = $1; };

/* Basic Statements */
assign_stmt:       	assign_expr SEMICOLON { $$ = $1; };
assign_expr:        	id ASSIGNOPERATOR expr {
			list_data * expr_list = $3;
			string variable_name = $1;
			threeAC_node * temp_expr = expr_list->back();
			threeAC_node * fresh_node = new threeAC_node;
			symbol_table_tree * temp_search = new symbol_table_tree;
			temp_search = check_leaf(variable_name, current_function_scope);
			
			fresh_node->Rt = "_";
			fresh_node->reg_dest = $1;
			fresh_node->op_value = ":=";
			fresh_node->op_type = (temp_expr->op_type == "_")? ( (temp_search != NULL)? temp_search->leaf_type : "_") : temp_expr->op_type;
			
			if(expr_list->size() == 1 && temp_expr->op_value != "+" && temp_expr->op_value != "-" && temp_expr->op_value != "*" && temp_expr->op_value != "/") {
				threeAC_node * addon = new threeAC_node;
				addon->op_type = temp_expr->op_type;
				addon->op_value = (addon->op_type == "INT")? "STOREI" : "STOREF";
				addon->Rs = temp_expr->op_value;
				addon->Rt = "_";
				set_register_Rd(addon, "$T", current_register_index);
				fresh_node->Rs = addon->reg_dest;
				expr_list->pop_back();
				expr_list->push_back(addon);
				expr_list->push_back(fresh_node);
			}
			else {
				fresh_node->Rs = temp_expr->reg_dest;
				expr_list->push_back(fresh_node);
			}
			
			format_node(expr_list, fresh_node->op_type);
			//format_params_and_locals(expr_list, current_function_scope);

			$$ = expr_list;
			};
read_stmt:          	READ { leaf_type = "Read_Write"; } OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON {
			leaf_type = "Read_Write";
			list_data * read_stmt_list = new list_data;
			if(!rw_id_list.empty()) {
				list_data::iterator index;
				for(index = rw_id_list.begin(); index != rw_id_list.end(); index++) {
				threeAC_node * fresh_node = new threeAC_node;
				fresh_node->Rs = "_";
				fresh_node->Rt = "_";
				fresh_node->reg_dest = (*index)->Rs;
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
write_stmt:         	WRITE { leaf_type = "Read_Write"; } OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON {
			leaf_type = "Read_Write";
			list_data * write_stmt_list = new list_data;
			if(!rw_id_list.empty()) {
				list_data::iterator index;
				for(index = rw_id_list.begin(); index != rw_id_list.end(); index++) {
				threeAC_node * fresh_node = new threeAC_node;
				fresh_node->Rs = "_";
				fresh_node->Rt = "_";
				fresh_node->reg_dest = (*index)->Rs;
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
return_stmt:        	RETURN expr SEMICOLON {
			list_data * return_stmt_list = $2;
			threeAC_node * temp_return = return_stmt_list->back();
			threeAC_node * fresh_node = new threeAC_node;
			int return_slot = 6 + count_function_params_or_locals(current_function_scope, 1);
			if(current_function_scope == "main")
				return_slot = 5 + count_function_params_or_locals(current_function_scope, 1);
			stringstream temp_string;
			string int2string;
			temp_string << return_slot;
			int2string = temp_string.str();
			if(temp_return->op_type != "INT" && temp_return->op_type != "FLOAT") {
				symbol_table_tree * search_tree = new symbol_table_tree;
				list_data::iterator index;
				string func_name = "_";
				int jsr_count = 0;
				for(index = return_stmt_list->begin(); index != return_stmt_list->end(); index++) {
					if((*index)->op_value == "jsr") {
						jsr_count++;
						size_t pos = (*index)->reg_dest.find("_");
						pos++;
						func_name = (*index)->reg_dest.substr(pos);
					}
				}
				if(func_name != "_")
					search_tree = check_leaf(func_name, current_function_scope);
				if(search_tree != NULL)
					temp_return->op_type = search_tree->leaf_type;
				if(jsr_count > 1) {
					for(index = return_stmt_list->begin(); index != return_stmt_list->end(); index++) {
						if((*index)->op_value == "jsr") {
							while((*index)->reg_dest[0] != '$' && (*index)->reg_dest[1] != 'T')
								index++;
							string reg_dest_holder = (*index)->reg_dest;
							(*index)->reg_dest = "$T105";
							register_file[2].register_number = (*index)->reg_dest;
							register_file[2].dirty = 1;
							list_data::iterator m = return_stmt_list->begin();
							while(m != return_stmt_list->end()) {
								if((*m)->Rs == reg_dest_holder)
									(*m)->Rs = "$T105";
								if((*m)->Rt == reg_dest_holder)
									(*m)->Rt = "$T105";
								if((*m)->reg_dest == reg_dest_holder)
									(*m)->reg_dest = "$T105";
								m++;
							}
							break;
						}
					}
				}
			}
			fresh_node->op_type = temp_return->op_type;
			fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
			fresh_node->reg_dest = "$" + int2string;
			fresh_node->Rt = "_";
			if(return_stmt_list->size() == 1) {
				threeAC_node * addon = new threeAC_node;
				addon->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
				addon->op_type = fresh_node->op_type;
				addon->Rs = temp_return->op_value;
				addon->Rt = "_";
				set_register_Rd(addon, "$T", current_register_index);
				fresh_node->Rs = addon->reg_dest;
				return_stmt_list->pop_back();
				return_stmt_list->push_back(addon);
				return_stmt_list->push_back(fresh_node);
			}
			else {
				fresh_node->Rs = temp_return->reg_dest;
				return_stmt_list->push_back(fresh_node);
			}
			threeAC_node * unlink_instr = new threeAC_node;
			unlink_instr->op_value = "unlnk";
			unlink_instr->Rs = "_";
			unlink_instr->Rt = "_";
			unlink_instr->reg_dest = "_";
			return_stmt_list->push_back(unlink_instr);
			
			threeAC_node * return_instr = new threeAC_node;
			return_instr->op_value = "ret";
			return_instr->Rs = "_";
			return_instr->Rt = "_";
			return_instr->reg_dest = "_";
			return_stmt_list->push_back(return_instr);

			format_node(return_stmt_list, temp_return->op_type);
			
			$$ = return_stmt_list;
			};

/* Expressions */
expr:			expr_prefix factor {
			if($1 == NULL)
			      $$ = $2;
			else if($1 != NULL) {
			     list_data * expr_prefix_list = $1;
			     list_data * factor_list = $2;
			     threeAC_node * temp_factor = factor_list->back();
			     threeAC_node * temp_expr = expr_prefix_list->back();
			     if(factor_list->size() == 1) {
			     		threeAC_node * fresh_node = new threeAC_node;
					fresh_node->op_type = temp_factor->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node, "$T", current_register_index);
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
			      if(factor_list->size() == 1) {
			                threeAC_node * fresh_node = new threeAC_node;
					fresh_node->op_type = temp_factor->op_type;
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					set_register_Rd(fresh_node, "$T", current_register_index);
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
					set_register_Rd(fresh_node, "$T", current_register_index);
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
					set_register_Rd(fresh_node, "$T", current_register_index);
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
					set_register_Rd(fresh_node, "$T", current_register_index);
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
postfix_expr:      	primary { $$ = $1; } | call_expr { $$ = $1; };
call_expr:         	id OPENPARENTHESIS expr_list CLOSEPARENTHESIS {
			list_data * call_expr_list = new list_data;
			list_data_list * expr_list_list = $3;
			list_data * temp_expr_list = new list_data;

			int parameter_count = count_function_params_or_locals($1, 1);
			string function_name = $1;
			list_data_list::iterator index;

			if(expr_list_list != NULL) {
				for(index = expr_list_list->begin(); index != expr_list_list->end(); index++) {
					temp_expr_list = (*index);
					if(temp_expr_list != NULL) {
						if(temp_expr_list->size() > 1)
							call_expr_list->insert(call_expr_list->end(), temp_expr_list->begin(), temp_expr_list->end());
					}
				}
			}

			threeAC_node * fresh_node_return = new threeAC_node;
			fresh_node_return->op_value = "push";
			fresh_node_return->Rs = "_";
			fresh_node_return->Rt = "_";
			fresh_node_return->reg_dest = "_";
			call_expr_list->push_back(fresh_node_return);
			
			threeAC_node * fresh_node0 = new threeAC_node;
			fresh_node0->op_value = "push";
			fresh_node0->Rs = "_";
			fresh_node0->Rt = "_";
			fresh_node0->reg_dest = "r0";
			call_expr_list->push_back(fresh_node0);

			threeAC_node * fresh_node1 = new threeAC_node;
			fresh_node1->op_value = "push";
			fresh_node1->Rs = "_";
			fresh_node1->Rt = "_";
			fresh_node1->reg_dest = "r1";
			call_expr_list->push_back(fresh_node1);
			
			threeAC_node * fresh_node2 = new threeAC_node;
			fresh_node2->op_value = "push";
			fresh_node2->Rs = "_";
			fresh_node2->Rt = "_";
			fresh_node2->reg_dest = "r2";
			call_expr_list->push_back(fresh_node2);
			
			threeAC_node * fresh_node3 = new threeAC_node;
			fresh_node3->op_value = "push";
			fresh_node3->Rs = "_";
			fresh_node3->Rt = "_";
			fresh_node3->reg_dest = "r3";
			call_expr_list->push_back(fresh_node3);
			
			if(expr_list_list != NULL) {
			if(expr_list_list->size() > 1) { 
				for(index = expr_list_list->end(); index != expr_list_list->begin(); index--) {
					if(index == expr_list_list->end())
						index--;
					temp_expr_list = (*index);
					if(temp_expr_list != NULL) {
						if(temp_expr_list->size() == 1) {
							threeAC_node * temp_node = temp_expr_list->back();
							threeAC_node * fresh_node = new threeAC_node;
							fresh_node->op_value = "push";
							fresh_node->Rs = "_";
							fresh_node->Rt = "_";
							
							int param_local = 0;
							int id_slot = find_param_or_local_slot(current_function_scope, temp_node->op_value, param_local);
							stringstream temp_string;
							temp_string << id_slot;
							
							fresh_node->reg_dest = (param_local)? "$p" + temp_string.str() : "$l" + temp_string.str();
							if(fresh_node->reg_dest != "$p0" && fresh_node->reg_dest != "$l0")
								call_expr_list->push_back(fresh_node);
							else {
								fresh_node->reg_dest = temp_node->op_value;
								call_expr_list->push_back(fresh_node);
							}
						}
						else {
							threeAC_node * temp_node = temp_expr_list->back();
							threeAC_node * fresh_node = new threeAC_node;
							fresh_node->op_value = "push";
							fresh_node->Rs = "_";
							fresh_node->Rt = "_";
							fresh_node->reg_dest = temp_node->reg_dest;
							call_expr_list->push_back(fresh_node);
						}
					}
				}
			}
				index = expr_list_list->begin();
				temp_expr_list = (*index);
				if(temp_expr_list != NULL) {
					if(temp_expr_list->size() == 1) {
						threeAC_node * temp_node = temp_expr_list->back();
						threeAC_node * fresh_node = new threeAC_node;
						fresh_node->op_value = "push";
						fresh_node->Rs = "_";
						fresh_node->Rt = "_";
							
						int param_local = 0;
						int id_slot = find_param_or_local_slot(current_function_scope, temp_node->op_value, param_local);
						stringstream temp_string;
						temp_string << id_slot;
							
						fresh_node->reg_dest = (param_local)? "$p" + temp_string.str() : "$l" + temp_string.str();
						if(fresh_node->reg_dest != "$p0" && fresh_node->reg_dest != "$l0")
							call_expr_list->push_back(fresh_node);
						else {
							fresh_node->reg_dest = temp_node->op_value;
							call_expr_list->push_back(fresh_node);
						}
					}
					else {
						threeAC_node * temp_node = temp_expr_list->back();
						threeAC_node * fresh_node = new threeAC_node;
						fresh_node->op_value = "push";
						fresh_node->Rs = "_";
						fresh_node->Rt = "_";
						fresh_node->reg_dest = temp_node->reg_dest;
						call_expr_list->push_back(fresh_node);
					}
				}
			}
			
			threeAC_node * jsr_node = new threeAC_node;
			jsr_node->op_value = "jsr";
			jsr_node->Rs = "_";
			jsr_node->Rt = "_";
			jsr_node->reg_dest = "FUNC_" + function_name;
			call_expr_list->push_back(jsr_node);

			for(int i = 0; i < parameter_count; i++) {
				threeAC_node * pop_node = new threeAC_node;
				pop_node->op_value = "pop";
				pop_node->Rs = "_";
				pop_node->Rt = "_";
				pop_node->reg_dest = "_";
				call_expr_list->push_back(pop_node);
			}

			threeAC_node * pop_r3 = new threeAC_node;
			pop_r3->op_value = "pop";
			pop_r3->Rs = "_";
			pop_r3->Rt = "_";
			pop_r3->reg_dest = "r3";
			call_expr_list->push_back(pop_r3);
			
			threeAC_node * pop_r2 = new threeAC_node;
			pop_r2->op_value = "pop";
			pop_r2->Rs = "_";
			pop_r2->Rt = "_";
			pop_r2->reg_dest = "r2";
			call_expr_list->push_back(pop_r2);

			threeAC_node * pop_r1 = new threeAC_node;
			pop_r1->op_value = "pop";
			pop_r1->Rs = "_";
			pop_r1->Rt = "_";
			pop_r1->reg_dest = "r1";
			call_expr_list->push_back(pop_r1);

			threeAC_node * pop_r0 = new threeAC_node;
			pop_r0->op_value = "pop";
			pop_r0->Rs = "_";
			pop_r0->Rt = "_";
			pop_r0->reg_dest = "r0";
			call_expr_list->push_back(pop_r0);

			threeAC_node * pop_return_value = new threeAC_node;
			pop_return_value->op_type = "_";
			pop_return_value->op_value = "pop";
			pop_return_value->Rs = "_";
			pop_return_value->Rt = "_";
			set_register_Rd(pop_return_value, "$T", current_register_index);
			call_expr_list->push_back(pop_return_value);
			$$ = call_expr_list;
			};
expr_list:         	expr expr_list_tail {
			list_data * expr_list_list = $1;
			list_data_list * expr_list_tail_list = $2;
			list_data_list * new_expr_list = new list_data_list;
			if(expr_list_list != NULL) {
				new_expr_list->push_back(expr_list_list);
				if(expr_list_tail_list != NULL)
					new_expr_list->splice(new_expr_list->end(), *expr_list_tail_list);
			}
			$$ = new_expr_list;
			} | { $$ = NULL; };
expr_list_tail:    	COMMA expr expr_list_tail {
			list_data * expr_list_list = $2;
			list_data_list * expr_list_tail_list = $3;
			list_data_list * new_expr_list = new list_data_list;
			if(expr_list_list != NULL) {
				new_expr_list->push_back(expr_list_list);
				if(expr_list_tail_list != NULL)
					new_expr_list->splice(new_expr_list->end(), *expr_list_tail_list);
			}
			$$ = new_expr_list;
			} | { $$ = NULL; };
primary:           	OPENPARENTHESIS expr CLOSEPARENTHESIS { $$ = $2; } | id {
			threeAC_node * fresh_node = new threeAC_node;
			list_data * primary_list = new list_data;
			fresh_node->op_value = $1;
			symbol_table_tree * temp_search = new symbol_table_tree;
			temp_search = check_leaf($1, current_function_scope);
			if(temp_search != NULL)
			     	  fresh_node->op_type = temp_search->leaf_type;
			else {
				temp_search = check_leaf($1, "GLOBAL");
				if(temp_search != NULL)
					 fresh_node->op_type = temp_search->leaf_type;
			}
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
			set_register_Rd(fresh_node, "$T", current_register_index);
			$$ = fresh_node;
			} | MINUSOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "SUB";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node, "$T", current_register_index);
			$$ = fresh_node;
			};
mulop:             	MULTIPLYOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "MUL";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node, "$T", current_register_index);
			$$ = fresh_node;
			} | DIVIDEOPERATOR {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_type = "DIV";
			fresh_node->op_value = $1;
			set_register_Rd(fresh_node, "$T", current_register_index);
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
				set_register_Rd(fresh_node1, "LOCATION_", label_number);
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
if_stmt_start:		IF { start_block_scope("BLOCK", "_"); };
if_stmt_end:		ENDIF { end_block_scope(); };
else_part:         	else_part_start decl stmt_list { end_block_scope(); $$ = $3; } | { $$ = NULL; };
else_part_start:	ELSE { start_block_scope("BLOCK", "_"); };

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
					set_register_Rd(fresh_node, "$T", current_register_index);
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					expr_list1->push_back(fresh_node);

					temp_compop->right_child_op_value = fresh_node->reg_dest;
					temp_compop->right_child_op_type = fresh_node->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = fresh_node->op_type;
					set_register_Rd(temp_compop, "LOCATION_", label_number);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
				else {
					temp_compop->right_child_op_value = temp_expr2->reg_dest;
					temp_compop->right_child_op_type = temp_expr2->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = temp_expr2->op_type;
					set_register_Rd(temp_compop, "LOCATION_", label_number);
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
					set_register_Rd(fresh_node, "$T", current_register_index);
					fresh_node->op_value = (fresh_node->op_type == "INT")? "STOREI" : "STOREF";
					expr_list1->push_back(fresh_node);

					temp_compop->right_child_op_value = fresh_node->reg_dest;
					temp_compop->right_child_op_type = fresh_node->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = fresh_node->op_type;
					set_register_Rd(temp_compop, "LOCATION_", label_number);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
				else {
					temp_compop->right_child_op_value = temp_expr2->reg_dest;
					temp_compop->right_child_op_type = temp_expr2->op_type;
					temp_compop->Rs = temp_compop->left_child_op_value;
					temp_compop->Rt = temp_compop->right_child_op_value;
					temp_compop->op_type = temp_expr2->op_type;
					set_register_Rd(temp_compop, "LOCATION_", label_number);
					expr_list1->splice(expr_list1->end(), *expr_list2);
					expr_list1->push_back(temp_compop);
					format_condition_node(expr_list1);
				}
			}
			$$ = expr_list1;
			} | TRUE { $$ = NULL; } | FALSE {
			list_data * cond_list = new list_data;
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_value = "jmp";
			fresh_node->Rs = "_";
			fresh_node->Rt = "_";
			set_register_Rd(fresh_node, "LOCATION_", label_number);
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
			list_data::iterator index;
			threeAC_node * temp_cond = cond_list->back();
			threeAC_node * fresh_node1 = new threeAC_node;
			threeAC_node * fresh_node2 = new threeAC_node;
			threeAC_node * fresh_node3 = new threeAC_node;
			temp_cond->loop_exit = 1;
			fresh_node1->op_value = "label";
			fresh_node1->Rs = "_";
			fresh_node1->Rt = "_";
			fresh_node1->loop_header = 1;
			set_register_Rd(fresh_node1, "WHILE_LOOP_START_", label_number);
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
			fresh_node2->loop_exit = 1;
			while_stmt_list->push_back(fresh_node2);
			for(index = while_stmt_list->begin(); index != while_stmt_list->end(); index++) {
				if((*index)->op_value == "break") {
					(*index)->op_value = "jmp";
					(*index)->reg_dest = temp_cond->reg_dest;
				}
				else if((*index)->op_value == "continue") {
				        (*index)->op_value = "jmp";
				        (*index)->reg_dest = fresh_node1->reg_dest;
				}
			}
			$$ = while_stmt_list;
			};
while_stmt_start:	WHILE { start_block_scope("BLOCK", "_"); };
while_stmt_end:		ENDWHILE { end_block_scope(); };
/*ECE573 ONLY*/
control_stmt:		return_stmt { $$ = $1; } | CONTINUE SEMICOLON {
			threeAC_node * fresh_node = new threeAC_node;
			list_data * continue_stmt_list = new list_data;
			fresh_node->op_value = "continue";
			continue_stmt_list->push_back(fresh_node);
			$$ = continue_stmt_list;
			} | BREAK SEMICOLON {
			threeAC_node * fresh_node = new threeAC_node;
			list_data * break_stmt_list = new list_data;
			fresh_node->op_value = "break";
			break_stmt_list->push_back(fresh_node);
			$$ = break_stmt_list;
			};
loop_stmt:         	while_stmt { $$ = $1; } | for_stmt { $$ = $1; };
init_stmt:         	assign_expr {
			current_statement_number++;
			list_data * assign_expr_list = $1;
			list_data::iterator index = assign_expr_list->begin();
			while(index != assign_expr_list->end()) {
				(*index)->statement_number = current_statement_number;
				index++;
			}
			$$ = assign_expr_list;
			} | { $$ = NULL; };
incr_stmt:      	assign_expr {
			current_statement_number++;
			list_data * assign_expr_list = $1;
			list_data::iterator index = assign_expr_list->begin();
			while(index != assign_expr_list->end()) {
				(*index)->statement_number = current_statement_number;
				index++;
			}
			$$ = assign_expr_list;
			} | { $$ = NULL; };
for_stmt:          	for_stmt_start OPENPARENTHESIS init_stmt SEMICOLON cond SEMICOLON incr_stmt CLOSEPARENTHESIS decl stmt_list for_stmt_end {
			list_data * for_stmt_list = new list_data;
			list_data * init_stmt_list = $3;
			list_data * cond_list = $5;
			list_data * incr_stmt_list = $7;
			list_data * stmt_list_list = $10;
			list_data::iterator index;
			threeAC_node * temp_cond = cond_list->back();
			threeAC_node * fresh_node1 = new threeAC_node;
			threeAC_node * fresh_node2 = new threeAC_node;
			threeAC_node * fresh_node3 = new threeAC_node;
			for_stmt_list->splice(for_stmt_list->end(), *init_stmt_list);
			temp_cond->loop_exit = 1;
			fresh_node1->op_value = "label";
			fresh_node1->Rs = "_";
			fresh_node1->Rt = "_";
			fresh_node1->loop_header = 1;
			set_register_Rd(fresh_node1, "FOR_LOOP_START_", label_number);
			for_stmt_list->push_back(fresh_node1);
			for_stmt_list->splice(for_stmt_list->end(), *cond_list);
			for_stmt_list->splice(for_stmt_list->end(), *stmt_list_list);
			for_stmt_list->splice(for_stmt_list->end(), *incr_stmt_list);

			fresh_node3->reg_dest = fresh_node1->reg_dest;
			fresh_node3->Rs = "_";
			fresh_node3->Rt = "_";
			fresh_node3->op_value = "jmp";
			for_stmt_list->push_back(fresh_node3);

			fresh_node2->op_value = "label";
			fresh_node2->Rs = "_";
			fresh_node2->Rt = "_";
			fresh_node2->reg_dest = temp_cond->reg_dest;
			fresh_node2->loop_exit = 1;
			for_stmt_list->push_back(fresh_node2);
			for(index = for_stmt_list->begin(); index != for_stmt_list->end(); index++) {
				if((*index)->op_value == "break") {
					(*index)->op_value = "jmp";
					(*index)->reg_dest = temp_cond->reg_dest;
				}
				else if((*index)->op_value == "continue") {
				        (*index)->op_value = "jmp";
				        (*index)->reg_dest = fresh_node1->reg_dest;
				}
			}
			$$ = for_stmt_list;
			};
for_stmt_start:		FOR { start_block_scope("BLOCK", "_"); };
for_stmt_end:		ENDFOR { end_block_scope(); };

%%

