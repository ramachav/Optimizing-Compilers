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
  string leaf_type = "INT";
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
%type <leaf_string_value> read_stmt write_stmt
%type <ast_node> expr expr_prefix factor factor_prefix addop mulop
%type <ast_node> postfix_expr assign_expr assign_stmt primary

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
string_decl: 	 	STRING id ASSIGNOPERATOR str SEMICOLON {leaf_type = "STRING"; create_leaf($2, leaf_type, $4, 0, 0); };
str:			STRINGLITERAL;

/* Variable Declaration */
var_decl:      		var_type id_list SEMICOLON;
var_type:       	FLOAT {leaf_type = "FLOAT"; } | INT {leaf_type = "INT"; };
any_type:       	var_type | VOID; 
id_list:		id {create_leaf($1, leaf_type, "_", 0, 0); } id_tail;
id_tail:        	COMMA id {create_leaf($2, leaf_type, "_", 0, 0); } id_tail |;

/* Function Paramater List */
param_decl_list:        param_decl param_decl_tail |;
param_decl:	        var_type id {create_leaf($2, $1, "_", 0, 0); };
param_decl_tail:        COMMA param_decl param_decl_tail |;

/* Function Declarations */
func_declarations:      func_decl func_declarations |;
func_decl:	        FUNCTION any_type id {start_block_scope($3); } OPENPARENTHESIS param_decl_list CLOSEPARENTHESIS _BEGIN func_body _END {end_block_scope(); };
func_body:	        decl stmt_list; 

/* Statement List */
stmt_list:		stmt stmt_list |;
stmt:			base_stmt | if_stmt | loop_stmt;
base_stmt:		assign_stmt | read_stmt | write_stmt | control_stmt;

/* Basic Statements */
assign_stmt:       	assign_expr SEMICOLON;
assign_expr:        	id ASSIGNOPERATOR expr {
			threeAC_node * temp_expr = $3;
			threeAC_node * fresh_node = new threeAC_node;

			fresh_node->Rt = "_";
			fresh_node->reg_dest = $1;
			fresh_node->op_value = ":=";
			if(temp_expr->op_value == "+" || temp_expr->op_value == "-" || temp_expr->op_value == "*" || temp_expr->op_value == "/")
				fresh_node->Rs = temp_expr->reg_dest;
			else
				fresh_node->Rs = temp_expr->op_value;
			fresh_node->op_type = temp_expr->op_type;
			threeAC_list.push_back(fresh_node);
			symbol_table_tree * temp_search = new symbol_table_tree;
			temp_search = check_leaf($1, "GLOBAL");
			if(temp_search != NULL)
				format_node(threeAC_list, temp_search->leaf_type);
			};
read_stmt:          	read OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON {
			leaf_type = "Read_Write";
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
				threeAC_list.push_back(fresh_node);
				}
				rw_id_list.clear();
			}
			};
read:			READ {leaf_type = "Read_Write"; };
write_stmt:         	write OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON {
			leaf_type = "Read_Write";
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
				threeAC_list.push_back(fresh_node);
				}
				rw_id_list.clear();
			}
			};
write:			WRITE {leaf_type = "Read_Write"; };
return_stmt:        	RETURN expr SEMICOLON;

/* Expressions */
expr:			expr_prefix factor {
			if($1 == NULL)
			      $$ = $2;
			else if($1 != NULL) {
			     threeAC_node * temp_factor = $2;
			     threeAC_node * temp_expr = $1;
			     if(temp_factor->op_value == "+" || temp_factor->op_value == "-" || temp_factor->op_value == "*" || temp_factor->op_value == "/") 
			      		temp_expr->right_child_op_value = temp_factor->reg_dest;
			      else
					temp_expr->right_child_op_value = temp_factor->op_value;
			      temp_expr->right_child_op_type = temp_factor->op_type;
			      temp_expr->Rs = temp_expr->left_child_op_value;
			      temp_expr->Rt = temp_expr->right_child_op_value;
			      threeAC_list.push_back(temp_expr);
			      $$ = temp_expr;
			}
			};
expr_prefix:       	expr_prefix factor addop {
			if($1 == NULL) {
			      threeAC_node * temp_factor = $2;
			      threeAC_node * temp_addop = $3;
			      if(temp_factor->op_value == "+" || temp_factor->op_value == "-" || temp_factor->op_value == "*" || temp_factor->op_value == "/") 
			      		temp_addop->left_child_op_value = temp_factor->reg_dest;
			      else
					temp_addop->left_child_op_value = temp_factor->op_value;
			      temp_addop->left_child_op_type = temp_factor->op_type;
			      if(temp_factor->op_type == "INT")
			      		temp_addop->op_type = "INT";
			      else if(temp_factor->op_type == "FLOAT")
			      	   	temp_addop->op_type = "FLOAT";
			      $$ = temp_addop;
			}
			else if($1 != NULL) {
			      threeAC_node * temp_factor = $2;
			      threeAC_node * temp_expr = $1;
			      threeAC_node * temp_addop = $3;
			      if(temp_factor->op_value == "+" || temp_factor->op_value == "-" || temp_factor->op_value == "*" || temp_factor->op_value == "/") 
			      		temp_expr->right_child_op_value = temp_factor->reg_dest;
			      else
					temp_expr->right_child_op_value = temp_factor->op_value;
			      temp_expr->right_child_op_type = temp_factor->op_type;
			      temp_expr->Rs = temp_expr->left_child_op_value;
			      temp_expr->Rt = temp_expr->right_child_op_value;
			      threeAC_list.push_back(temp_expr);	//Now the instruction is complete so put it on the three AC code list
			      if(temp_factor->op_type == "INT")
			      		temp_addop->op_type = "INT";
			      else if(temp_factor->op_type == "FLOAT")
			      	   	temp_addop->op_type = "FLOAT";
			      temp_addop->left_child_op_value = temp_expr->reg_dest;
			      temp_addop->left_child_op_type = temp_expr->op_type;
			      $$ = temp_addop;
			}			      
			} | { $$ = NULL; };
factor:            	factor_prefix postfix_expr {
			if($1 == NULL)
			      $$ = $2;
			else if($1 != NULL) {
			      threeAC_node * temp_factor = $1;
			      threeAC_node * temp_post = $2;
			      temp_factor->right_child_op_value = temp_post->op_value;
			      temp_factor->right_child_op_type = temp_post->op_type;
			      temp_factor->Rs = temp_factor->left_child_op_value;
			      temp_factor->Rt = temp_factor->right_child_op_value;
			      threeAC_list.push_back(temp_factor);	//Now the instruction is complete so put it on the three AC code list

			      $$ = temp_factor;
			}
			};
factor_prefix:     	factor_prefix postfix_expr mulop {
			if($1 == NULL) {
			      threeAC_node * temp_post = $2;
			      threeAC_node * temp_mulop = $3;
			      temp_mulop->left_child_op_value = temp_post->op_value;
			      temp_mulop->left_child_op_type = temp_post->op_type;
			      if(temp_post->op_type == "INT")
			      		temp_mulop->op_type = "INT";
			      else if(temp_post->op_type == "FLOAT")
			      	   	temp_mulop->op_type = "FLOAT";
			      $$ = temp_mulop;
			}
			else if($1 != NULL) {
			      threeAC_node * temp_post = $2;
			      threeAC_node * temp_factor = $1;
			      threeAC_node * temp_mulop = $3;
			      temp_factor->right_child_op_value = temp_post->op_value;
			      temp_factor->right_child_op_type = temp_post->op_type;
			      temp_factor->Rs = temp_factor->left_child_op_value;
			      temp_factor->Rt = temp_factor->right_child_op_value;
			      threeAC_list.push_back(temp_factor);	//Now the instruction is complete so put it on the three AC code list
			      if(temp_post->op_type == "INT")
			      		temp_mulop->op_type = "INT";
			      else if(temp_post->op_type == "FLOAT")
			      	   	temp_mulop->op_type = "FLOAT";
			      temp_mulop->left_child_op_value = temp_factor->reg_dest;
			      temp_mulop->left_child_op_type = temp_factor->op_type;
			      $$ = temp_mulop;
			}
			} | { $$ = NULL; };
postfix_expr:      	primary { $$ = $1; } | call_expr;
call_expr:         	id OPENPARENTHESIS expr_list CLOSEPARENTHESIS;
expr_list:         	expr expr_list_tail |;
expr_list_tail:    	COMMA expr expr_list_tail |;
primary:           	OPENPARENTHESIS expr CLOSEPARENTHESIS { $$ = $2; } | id {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_value = $1;
			symbol_table_tree * temp_search = new symbol_table_tree;
			temp_search = check_leaf($1, "GLOBAL");
			if(temp_search != NULL)
				fresh_node->op_type = temp_search->leaf_type;
			$$ = fresh_node;
			} | INTLITERAL {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_value = $1;
			fresh_node->op_type = "INT";
			$$ = fresh_node;
			} | FLOATLITERAL {
			threeAC_node * fresh_node = new threeAC_node;
			fresh_node->op_value = $1;
			fresh_node->op_type = "FLOAT";
			$$ = fresh_node;
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
if_stmt:                IF {start_block_scope("BLOCK"); } OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list else_part ENDIF {end_block_scope(); };
else_part:         	ELSE {start_block_scope("BLOCK"); } decl stmt_list {end_block_scope(); } |;
cond:              	expr compop expr | TRUE | FALSE;
compop:            	EQUALS_TO | NOT_EQUALS_TO | LESS_THAN | GREATER_THAN | LESS_THAN_EQUAL | GREATER_THAN_EQUAL;
while_stmt:        	WHILE {start_block_scope("BLOCK"); } OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list ENDWHILE {end_block_scope(); };

/*ECE573 ONLY*/
control_stmt:		return_stmt | CONTINUE SEMICOLON | BREAK SEMICOLON;
loop_stmt:         	while_stmt | for_stmt;
init_stmt:         	assign_expr |;
incr_stmt:      	assign_expr |;
for_stmt:          	FOR {start_block_scope("BLOCK"); } OPENPARENTHESIS init_stmt SEMICOLON cond SEMICOLON incr_stmt CLOSEPARENTHESIS decl stmt_list ENDFOR {end_block_scope(); };

%%

