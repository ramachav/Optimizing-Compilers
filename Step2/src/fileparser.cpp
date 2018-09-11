#include <stdio.h>
#include <stdlib.h>
#include "../autogenerate/parser.hpp"
extern FILE *yyin;
extern int yylex();
extern char *yytext;
extern int yyparse();

int main(int argc, char **argv) {

  int parse_return;
  if(argc > 0)
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  parse_return = yyparse();
  if(!parse_return)
    printf("Accepted\n");

  return 0;
}
