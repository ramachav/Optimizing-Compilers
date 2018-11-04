#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fileparser.hpp"


extern FILE *yyin;
extern int yylex();
extern char *yytext;
extern int yyparse();

int block_count = 0;
char * current_leaf_scope = NULL;
char * current_branch_scope = NULL;
symbol_table_tree * stem;

void create_leaf(char *name_leaf, char *type_leaf, char *string_leaf, float float_leaf, int int_leaf) {

  if(strcmp(type_leaf, "Read_Write")) {
    if(check_leaf(name_leaf, current_leaf_scope) != NULL) {
      dalloc_symbol_table_tree();
      printf("DECLARATION ERROR %s\n", name_leaf);
      exit(0);
    }
    else {
      symbol_table_tree * current_leaf;
      symbol_table_tree * leaf_jumper;

      leaf_jumper = stem;
      while(leaf_jumper->next_leaf != NULL) leaf_jumper = leaf_jumper->next_leaf;

      current_leaf = (symbol_table_tree *) malloc(sizeof(*current_leaf));
      current_leaf->leaf_name = name_leaf;
      current_leaf->leaf_scope = current_leaf_scope;
      current_leaf->branch_scope = current_branch_scope;
      current_leaf->leaf_type = type_leaf;
      current_leaf->has_sub_leaves = 0;

      if(!strcmp(type_leaf, "STRING"))
	current_leaf->leaf_string = string_leaf;
      else if(!strcmp(type_leaf, "INT"))
	current_leaf->leaf_int = int_leaf;
      else if(!strcmp(type_leaf, "FLOAT"))
	current_leaf->leaf_float = float_leaf;

      leaf_jumper->next_leaf = current_leaf;
    }
  }
}

symbol_table_tree * check_leaf(char *name_leaf, char *scope_leaf) {

  symbol_table_tree * current_leaf;
  if(stem->next_leaf == NULL)
    current_leaf = stem;
  else
    current_leaf = stem->next_leaf;

  if(current_leaf->leaf_name != NULL) {
    while(current_leaf->next_leaf != NULL) {
      if(!strcmp(current_leaf->leaf_scope, scope_leaf) && !strcmp(current_leaf->leaf_name, name_leaf))
	return current_leaf;
      else
	current_leaf = current_leaf->next_leaf;
    }
  }
  return NULL;
	    
}

symbol_table_tree * check_branch(char *scope_branch) {
  
  symbol_table_tree * current_branch;
  if(stem->next_leaf == NULL)
    current_branch = stem;
  else
    current_branch = stem->next_leaf;
  
  symbol_table_tree * temp = current_branch;

  if(temp->leaf_name != NULL) {
    while(temp->next_leaf != NULL) {
      if(!strcmp(scope_branch, temp->leaf_scope))
	return current_branch;
      else {
	temp = temp->next_leaf;
	current_branch = temp;
      }
    }
  }
  return NULL;
}

void start_block_scope(char * name) {

  current_branch_scope = current_leaf_scope;
  current_leaf_scope = name;
  
  symbol_table_tree * new_leaf;
  
  new_leaf = (symbol_table_tree *) malloc(sizeof(*new_leaf));
  new_leaf->leaf_name = (char*)name;
  new_leaf->branch_scope = current_branch_scope;
  new_leaf->leaf_scope = current_leaf_scope;
  new_leaf->has_sub_leaves = 1;

  symbol_table_tree * temp;
  
  temp = stem;
  while(temp->next_leaf != NULL)
    temp = temp->next_leaf;
  
  temp->next_leaf = new_leaf;
}

void end_block_scope() {

  symbol_table_tree * scope_end;
  
  scope_end = check_branch(current_branch_scope);
  current_leaf_scope = current_branch_scope;
  current_branch_scope = scope_end->leaf_scope;
}

void dalloc_symbol_table_tree() {
  
  symbol_table_tree * temp;
  symbol_table_tree * temp_next;
  temp = stem;
  
  while(temp->next_leaf != NULL) {
    temp_next = temp->next_leaf;
    free(temp);
    temp = temp_next;
  }
  
  stem = NULL;
}

void print_symbol_table_tree(symbol_table_tree *trunk) {

  symbol_table_tree * temp_stem;
  if(trunk->next_leaf == NULL)
    temp_stem = trunk;
  else
    temp_stem = trunk->next_leaf;

  while(temp_stem != NULL) {
    if(temp_stem->has_sub_leaves) {
      if(!strcmp(temp_stem->leaf_scope, "GLOBAL"))
	printf("Symbol table %s\n", temp_stem->leaf_scope);
      else if(!strcmp(temp_stem->leaf_scope, "BLOCK"))
	printf("Symbol table %s %d\n", temp_stem->leaf_scope, ++block_count);
      else
	printf("Symbol table %s\n", temp_stem->leaf_scope);
    }
    else {
      if(!strcmp(temp_stem->leaf_type, "STRING"))
	printf("name %s type %s value %s scope %s\n", temp_stem->leaf_name, temp_stem->leaf_type, temp_stem->leaf_string, temp_stem->leaf_scope);
      else if(!strcmp(temp_stem->leaf_type, "INT") || !strcmp(temp_stem->leaf_type, "FLOAT"))
	printf("name %s type %s scope %s\n", temp_stem->leaf_name, temp_stem->leaf_type, temp_stem->leaf_scope);
    }
    temp_stem = temp_stem->next_leaf;
  }
}

int main(int argc, char **argv) {

  int parse_return;

  stem = (symbol_table_tree *) malloc(sizeof(*stem));
  stem->next_leaf = NULL;
  current_leaf_scope = (char*)"GLOBAL";
  current_branch_scope = (char*)"GLOBAL";

  start_block_scope((char*)"GLOBAL");
  
  if(argc > 0)
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  parse_return = yyparse();
  if(!parse_return)
    print_symbol_table_tree(stem);
  return 0;
}
