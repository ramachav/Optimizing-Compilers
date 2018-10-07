#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct symbol_table_struct {
  char *leaf_name;
  char *leaf_type;
  char *leaf_scope;
  char *branch_scope;
  char *leaf_string;
  int leaf_int;
  float leaf_float;
  int has_sub_leaves;
  struct symbol_table_struct *next_leaf;       //Pointer to the next leaf node
}symbol_table_tree;

void create_leaf(char *name_leaf, char *type_leaf, char *string_leaf, float float_leaf, int int_leaf);
symbol_table_tree * check_leaf(char *name_leaf, char *scope_leaf);
symbol_table_tree * check_branch(char *scope_branch);

//Parser file functions (used to create an entry in the current symbol table when the non-terminal is encountered)
void start_block_scope(char * name);
void end_block_scope();

//Delete the symbol table (de-allocate it's memory) and print out the symbol table tree
void dalloc_symbol_table_tree();
void print_symbol_table_tree(symbol_table_tree *stem);

