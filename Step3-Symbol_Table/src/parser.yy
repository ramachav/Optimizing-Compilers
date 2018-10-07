%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "../src/fileparser.hpp"
  
  extern int yylex();
  extern int yylineno;
  extern char *yytext;

  char * leaf_type = (char*)"INT";
  
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
}

%type <leaf_string_value> id str var_type

%token PROGRAM
%token _BEGIN
%token _END
%token FUNCTION
%token READ
%token WRITE
%token IF
%token ELSE
%token ENDIF
%token WHILE
%token ENDWHILE
%token RETURN
%token INT
%token VOID
%token STRING
%token FLOAT
%token TRUE
%token FALSE
%token FOR
%token ENDFOR
%token CONTINUE
%token BREAK
%token <leaf_string_value> IDENTIFIER
%token <leaf_int_value> INTLITERAL
%token <leaf_float_value> FLOATLITERAL
%token <leaf_string_value> STRINGLITERAL
%token ASSIGNOPERATOR
%token ADDOPERATOR
%token MINUSOPERATOR
%token MULTIPLYOPERATOR
%token DIVIDEOPERATOR
%token EQUALS_TO
%token NOT_EQUALS_TO
%token LESS_THAN
%token GREATER_THAN
%token LESS_THAN_EQUAL
%token GREATER_THAN_EQUAL
%token SEMICOLON
%token COMMA
%token OPENPARENTHESIS
%token CLOSEPARENTHESIS

%%

/* Program */
program:		PROGRAM id _BEGIN pgm_body _END;
id:	   		IDENTIFIER;
pgm_body:		decl func_declarations;
decl:	   		string_decl decl | var_decl decl |;

/* Global String Declaration */
string_decl: 	 	STRING id ASSIGNOPERATOR str SEMICOLON {leaf_type = (char*)"STRING"; create_leaf($2, leaf_type, $4, 0, 0); };
str:			STRINGLITERAL;

/* Variable Declaration */
var_decl:      		var_type id_list SEMICOLON;
var_type:       	FLOAT {leaf_type = (char*)"FLOAT"; } | INT {leaf_type = (char*)"INT"; };
any_type:       	var_type | VOID; 
id_list:		id {create_leaf($1, leaf_type, NULL, 0, 0); } id_tail;
id_tail:        	COMMA id {create_leaf($2, leaf_type, NULL, 0, 0); } id_tail |;

/* Function Paramater List */
param_decl_list:        param_decl param_decl_tail |;
param_decl:	        var_type id {create_leaf($2, $1, NULL, 0, 0); };
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
assign_expr:        	id ASSIGNOPERATOR expr;
read_stmt:          	READ {leaf_type = (char*)"Read_Write"; } OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON;
write_stmt:         	WRITE {leaf_type = (char*)"Read_Write"; } OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON;
return_stmt:        	RETURN expr SEMICOLON;

/* Expressions */
expr:			expr_prefix factor;
expr_prefix:       	expr_prefix factor addop |;
factor:            	factor_prefix postfix_expr;
factor_prefix:     	factor_prefix postfix_expr mulop |;
postfix_expr:      	primary | call_expr;
call_expr:         	id OPENPARENTHESIS expr_list CLOSEPARENTHESIS;
expr_list:         	expr expr_list_tail |;
expr_list_tail:    	COMMA expr expr_list_tail |;
primary:           	OPENPARENTHESIS expr CLOSEPARENTHESIS | id | INTLITERAL | FLOATLITERAL;
addop:             	ADDOPERATOR | MINUSOPERATOR;
mulop:             	MULTIPLYOPERATOR | DIVIDEOPERATOR;

/* Complex Statements and Condition */ 
if_stmt:                IF {start_block_scope((char*)"BLOCK"); } OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list else_part ENDIF {end_block_scope(); };
else_part:         	ELSE {start_block_scope((char*)"BLOCK"); } decl stmt_list {end_block_scope(); } |;
cond:              	expr compop expr | TRUE | FALSE;
compop:            	EQUALS_TO | NOT_EQUALS_TO | LESS_THAN | GREATER_THAN | LESS_THAN_EQUAL | GREATER_THAN_EQUAL;
while_stmt:        	WHILE {start_block_scope((char*)"BLOCK"); } OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list ENDWHILE {end_block_scope(); };

/*ECE573 ONLY*/
control_stmt:		return_stmt | CONTINUE SEMICOLON | BREAK SEMICOLON;
loop_stmt:         	while_stmt | for_stmt;
init_stmt:         	assign_expr |;
incr_stmt:      	assign_expr |;
for_stmt:          	FOR {start_block_scope((char*) "BLOCK"); } OPENPARENTHESIS init_stmt SEMICOLON cond SEMICOLON incr_stmt CLOSEPARENTHESIS decl stmt_list ENDFOR {end_block_scope(); };

%%

