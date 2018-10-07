%{
  #include <stdio.h>
  #include <stdlib.h>
  extern int yylex();
  extern int yylineno;
  extern char *yytext;
  void yyerror( const char *s) {
	printf("Not Accepted\n");
  	//printf("Error line %d token %s\n", yylineno, yytext);
  }

%}

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
%token IDENTIFIER
%token INTLITERAL
%token FLOATLITERAL
%token STRINGLITERAL
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
string_decl: 	 	STRING id ASSIGNOPERATOR str SEMICOLON;
str:			STRINGLITERAL;

/* Variable Declaration */
var_decl:      		var_type id_list SEMICOLON;
var_type:       	FLOAT | INT;
any_type:       	var_type | VOID; 
id_list:		id id_tail;
id_tail:        	COMMA id id_tail |;

/* Function Paramater List */
param_decl_list:        param_decl param_decl_tail |;
param_decl:	        var_type id;
param_decl_tail:        COMMA param_decl param_decl_tail |;

/* Function Declarations */
func_declarations:      func_decl func_declarations |;
func_decl:	        FUNCTION any_type id OPENPARENTHESIS param_decl_list CLOSEPARENTHESIS _BEGIN func_body _END;
func_body:	        decl stmt_list; 

/* Statement List */
stmt_list:		stmt stmt_list |;
stmt:			base_stmt | if_stmt | loop_stmt;
base_stmt:		assign_stmt | read_stmt | write_stmt | control_stmt;

/* Basic Statements */
assign_stmt:       	assign_expr SEMICOLON;
assign_expr:        	id ASSIGNOPERATOR expr;
read_stmt:          	READ OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON;
write_stmt:         	WRITE OPENPARENTHESIS id_list CLOSEPARENTHESIS SEMICOLON;
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
if_stmt:                IF OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list else_part ENDIF;
else_part:         	ELSE decl stmt_list |;
cond:              	expr compop expr | TRUE | FALSE;
compop:            	EQUALS_TO | NOT_EQUALS_TO | LESS_THAN | GREATER_THAN | LESS_THAN_EQUAL | GREATER_THAN_EQUAL;
while_stmt:        	WHILE OPENPARENTHESIS cond CLOSEPARENTHESIS decl stmt_list ENDWHILE;

/*ECE573 ONLY*/
control_stmt:		return_stmt | CONTINUE SEMICOLON | BREAK SEMICOLON;
loop_stmt:         	while_stmt | for_stmt;
init_stmt:         	assign_expr |;
incr_stmt:      	assign_expr |;
for_stmt:          	FOR OPENPARENTHESIS init_stmt SEMICOLON cond SEMICOLON incr_stmt CLOSEPARENTHESIS decl stmt_list ENDFOR;

%%

