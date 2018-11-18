#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <list>
#include <set>
#include <sstream>
using namespace std;

typedef set<string> set_data;

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
  int is_parameter;
  int slot_number;
  symbol_table_tree *next_leaf;       //Pointer to the next leaf node

  symbol_table_tree() {
    leaf_name = "_";
    leaf_type = "_";
    leaf_scope = "_";
    branch_scope = "_";
    leaf_string = "_";
    leaf_int = 0;
    leaf_float = 0.0;
    has_sub_leaves = 0;
    is_parameter = 0;
    slot_number = 0;
    next_leaf = NULL;
  }

};

class tiny_instr {
public:
  string opcode;
  string Rs;
  string Rt;
  string Rd;

  tiny_instr() {
    opcode = "_";
    Rs = "_";
    Rt = "_";
    Rd = "_";
  }
};

class reg_file {
 public:
  string register_number;
  int dirty;

  reg_file() {
    register_number = "FREE";
    dirty = 0;
  }
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
  threeAC_node * predecessor0;
  threeAC_node * predecessor1;
  threeAC_node * successor0;
  threeAC_node * successor1;
  set_data GEN;
  set_data KILL;
  set_data live_in;
  set_data live_out;

  threeAC_node() {
    op_type = "_";
    op_value = "_";
    Rs = "_";
    Rt = "_";
    reg_dest = "_";
    left_child_op_value = "_";
    right_child_op_value = "_";
    left_child_op_type = "_";
    right_child_op_type = "_";
    predecessor0 = NULL;
    predecessor1 = NULL;
    successor0 = NULL;
    successor1 = NULL;
    
  }
};

typedef list<threeAC_node *> list_data;
typedef list<list_data *> list_data_list;
typedef list<tiny_instr *> list_instr;

void create_leaf(string name_leaf, string type_leaf, string string_leaf, float float_leaf, int int_leaf, int is_param);
symbol_table_tree * check_leaf(string name_leaf, string scope_leaf);
symbol_table_tree * check_branch(string scope_branch);

//Parser file functions (used to create an entry in the current symbol table when the non-terminal is encountered)
void start_block_scope(string name, string type);
void end_block_scope();

//Delete the symbol table (de-allocate it's memory) and print out functions
void dalloc_symbol_table_tree();
void print_symbol_table_tree(symbol_table_tree *stem);

void print_threeAC_code(list_data ptr);
void print_tiny_code(list_instr ptr);
void print_inter_list(list_data ptr, string helpful_info);
void print_inter_node(threeAC_node * temp_node, string helpful_info);
void print_set(set_data temp_set, string helpful_info);
	       
void create_tiny_code(list_data ptr); 
void convert_STto3AC(); 
void set_register_Rd(threeAC_node * temp_node, string identifier, int& specific_counter);
void set_register_Rs(threeAC_node * temp_node);
void clean_3ac_list(list_data ptr); 
void clean_tiny_list(list_instr ptr); 
void format_node(list_data * ptr, string data_type);
void format_condition_node(list_data * ptr);
void format_params_and_locals(list_data * ptr, string scope);
void set_up_predecessor_and_successor(list_data * ptr);
void set_up_gen_and_kill(list_data * ptr);
void set_up_in_and_out(list_data * ptr);
void find_IR_node(list_data * ptr, threeAC_node * temp);
void register_reallocate(list_data * ptr);

int count_function_params_or_locals(string scope, int params_or_locals);
int find_param_or_local_slot(string scope, string name, int& param_or_local);

