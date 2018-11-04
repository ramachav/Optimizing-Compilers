%{
#include <stdlib.h>
#include <stdio.h>
#include "../src/asm_maker.h"
#include "../autogenerate/parser.tab.hh"	/* Making sure the scanner compiles properly */
#include <string>
#include <iostream>
#include <list>
using namespace std;

extern char *yytext;
list_data assign_expr_list;
list_data rw_id_list;
list_data threeAC_list;
list_instr tiny_list;
list_instr inter_tiny_list;
list_data inter_list;
%}

DIGIT [0-9]
IDENTIFIER [A-Za-z][A-Za-z0-9]*
INTLITERAL [0-9]+
FLOATLITERAL [0-9]+\.[0-9]*
STRINGLITERAL \"[^"]*\"
COMMENT --[^\n]*\n
WHITESPACE [ |\t|\n]+

START_PROGRAM PROGRAM
_BEGIN BEGIN
_END END
FUNCTION_START FUNCTION
READ_FROM READ
WRITE_TO WRITE
IF_STMT IF
ELSE_STMT ELSE
END_IF_STMT ENDIF
WHILE_LOOP_STMT WHILE
END_WHILE_LOOP_STMT ENDWHILE
RETURN_STMT RETURN
INTEGER_TYPE INT
VOID_TYPE VOID
STRING_TYPE STRING
FLOAT_TYPE FLOAT
CORRECT_ANS TRUE
WRONG_ANS FALSE
FOR_LOOP_STMT FOR
END_FOR_LOOP_STMT ENDFOR
CONTINUE_STMT CONTINUE
BREAK_STMT BREAK
ASSIGNOPERATOR ":="
ADDOPERATOR "+"
MINUSOPERATOR "-"
MULTIPLYOPERATOR "*"
DIVIDEOPERATOR "/"
SEMICOLON ";"
COMMA ","
OPENPARENTHESIS "("
CLOSEPARENTHESIS ")"
EQUALS_TO "="
NOT_EQUALS_TO "!="
LESS_THAN "<"
GREATER_THAN ">"
LESS_THAN_EQUAL "<="
GREATER_THAN_EQUAL ">="

%%

{COMMENT}   ;

{START_PROGRAM} {return PROGRAM;}
{_BEGIN} {return _BEGIN;}
{_END} {return _END;}
{FUNCTION_START} {return FUNCTION;}
{READ_FROM} {return READ;}
{WRITE_TO} {return WRITE;}
{IF_STMT} {return IF;}
{ELSE_STMT} {return ELSE;}
{END_IF_STMT} {return ENDIF;}
{WHILE_LOOP_STMT} {return WHILE;}
{END_WHILE_LOOP_STMT} {return ENDWHILE;}
{RETURN_STMT} {return RETURN;}
{INTEGER_TYPE} {yylval.leaf_string_value = strdup(yytext); return INT;}
{VOID_TYPE} {return VOID;}
{STRING_TYPE} {yylval.leaf_string_value = strdup(yytext); return STRING;}
{FLOAT_TYPE} {yylval.leaf_string_value = strdup(yytext); return FLOAT;}
{CORRECT_ANS} {return TRUE;}
{WRONG_ANS} {return FALSE;}
{FOR_LOOP_STMT} {return FOR;}
{END_FOR_LOOP_STMT} {return ENDFOR;}
{CONTINUE_STMT} {return CONTINUE;}
{BREAK_STMT} {return BREAK;}

{IDENTIFIER} {yylval.leaf_string_value = strdup(yytext); return IDENTIFIER;}
{INTLITERAL} {yylval.leaf_string_value = strdup(yytext); return INTLITERAL;}
{FLOATLITERAL} {yylval.leaf_string_value = strdup(yytext); return FLOATLITERAL;}
{STRINGLITERAL} {yylval.leaf_string_value = strdup(yytext); return STRINGLITERAL;}

{ASSIGNOPERATOR} {return ASSIGNOPERATOR;}
{ADDOPERATOR} {yylval.leaf_string_value = strdup(yytext); return ADDOPERATOR;}
{MINUSOPERATOR} {yylval.leaf_string_value = strdup(yytext); return MINUSOPERATOR;}
{MULTIPLYOPERATOR} {yylval.leaf_string_value = strdup(yytext); return MULTIPLYOPERATOR;}
{DIVIDEOPERATOR} {yylval.leaf_string_value = strdup(yytext); return DIVIDEOPERATOR;}
{EQUALS_TO} {yylval.leaf_string_value = strdup(yytext); return EQUALS_TO;}
{NOT_EQUALS_TO} {yylval.leaf_string_value = strdup(yytext); return NOT_EQUALS_TO;}
{LESS_THAN} {yylval.leaf_string_value = strdup(yytext); return LESS_THAN;}
{GREATER_THAN} {yylval.leaf_string_value = strdup(yytext); return GREATER_THAN;}
{LESS_THAN_EQUAL} {yylval.leaf_string_value = strdup(yytext); return LESS_THAN_EQUAL;}
{GREATER_THAN_EQUAL} {yylval.leaf_string_value = strdup(yytext); return GREATER_THAN_EQUAL;} 
{SEMICOLON} {return SEMICOLON;}
{COMMA} {return COMMA;}
{OPENPARENTHESIS} {return OPENPARENTHESIS;}
{CLOSEPARENTHESIS} {return CLOSEPARENTHESIS;}
{WHITESPACE} ;

%%


