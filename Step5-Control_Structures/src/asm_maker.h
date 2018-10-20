#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <list>
#include <sstream>
using namespace std;

class symbol_table_tree {
public:
  string leaf_name;
  string leaf_type;
  string leaf_scope;
  string branch_scope;
  string leaf_string;
  int leaf_int;
  float leaf_float;
  int has_sub_leaves;
  symbol_table_tree *next_leaf;       //Pointer to the next leaf node
};

class tiny_instr {
public:
  string opcode;
  string Rs;
  string Rt;
  string Rd;
};

class threeAC_node {
public:
  string op_type;
  string op_value;
  string Rs;
  string Rt;
  string reg_dest;
  string left_child_op_type;
  string left_child_op_value;
  string right_child_op_type;
  string right_child_op_value;
};

typedef list<threeAC_node *> list_data;
typedef list<tiny_instr *> list_instr;

void create_leaf(string name_leaf, string type_leaf, string string_leaf, float float_leaf, int int_leaf);
symbol_table_tree * check_leaf(string name_leaf, string scope_leaf);
symbol_table_tree * check_branch(string scope_branch);
threeAC_node * create_new_node();

//Parser file functions (used to create an entry in the current symbol table when the non-terminal is encountered)
void start_block_scope(string name);
void end_block_scope();

//Delete the symbol table (de-allocate it's memory) and print out functions
void dalloc_symbol_table_tree();
void print_symbol_table_tree(symbol_table_tree *stem);

void print_threeAC_code(list_data ptr);
void print_tiny_code(list_instr ptr);
void print_inter_list(list_data ptr, string helpful_info);

void create_tiny_code(list_data ptr); 
void convert_STto3AC(); 
void set_register_Rd(threeAC_node * temp_node);
void set_register_Rs(threeAC_node * temp_node);
void set_dest_label(threeAC_node * temp_node);
void clean_3ac_list(list_data ptr); 
void clean_tiny_list(list_instr ptr); 
void format_node(list_data * ptr, string data_type);
void format_condition_node(list_data * ptr);
