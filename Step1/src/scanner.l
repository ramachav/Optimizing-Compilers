%{
#include<stdio.h>
%}

DIGIT [0-9]
IDENTIFIER [A-Za-z][A-Za-z0-9]*
INTLITERAL [0-9]+
FLOATLITERAL [0-9]+"."[0-9]*
STRINGLITERAL \"(\\.|[^"\\])*\"
OPERATOR :=|\+|\-|\*|\/|=|!=|<|>|<=|>=|\(|\)|,|;
KEYWORD (PROGRAM|BEGIN|END|FUNCTION|READ|WRITE|IF|ELSE|ENDIF|WHILE|ENDWHILE|RETURN|INT|VOID|STRING|FLOAT|TRUE|FALSE|FOR|ENDFOR|CONTINUE|BREAK)
COMMENT --[^\n]*\n
WHITESPACE [ |\t|\n]+

%%

{COMMENT}   {}
{WHITESPACE}   {}
{KEYWORD}   {printf("\nToken Type: KEYWORD\nValue: %s", yytext);}
{IDENTIFIER}   {printf("\nToken Type: IDENTIFIER\nValue: %s", yytext);}
{INTLITERAL}   {printf("\nToken Type: INTLITERAL\nValue: %s", yytext);}
{FLOATLITERAL}   {printf("\nToken Type: FLOATLITERAL\nValue: %s", yytext);}
{STRINGLITERAL}   {printf("\nToken Type: STRINGLITERAL\nValue: %s", yytext);}
{OPERATOR}   {printf("\nToken Type: OPERATOR\nValue: %s", yytext);}

%%

int main(int argc, char **argv) {
  if(argc > 0)
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;
  yylex();
}
