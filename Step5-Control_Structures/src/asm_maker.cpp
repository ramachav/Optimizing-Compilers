#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <list>
#include <iostream>
#include <sstream>
#include "asm_maker.h"
using namespace std;

extern FILE *yyin;
extern int yylex();
extern char *yytext;
extern int yyparse();
extern list_data assign_expr_list;
extern list_data rw_id_list;
extern list_data threeAC_list;
extern list_instr tiny_list;
extern list_instr inter_tiny_list;
extern list_data inter_list;
extern int current_register_index;
extern int label_number;
int block_count = 0;
string current_leaf_scope;
string current_branch_scope;
symbol_table_tree * stem;

void create_leaf(string name_leaf, string type_leaf, string string_leaf, float float_leaf, int int_leaf) {

  if(type_leaf == "Read_Write") {
    if(check_leaf(name_leaf, "GLOBAL") != NULL) {
      threeAC_node * fresh_node = new threeAC_node;
      symbol_table_tree * rw_leaf = check_leaf(name_leaf, "GLOBAL");
      if(rw_leaf->leaf_type == "INT")
	fresh_node->op_value = "read_write_int";
      else if(rw_leaf->leaf_type == "FLOAT")
	fresh_node->op_value = "read_write_float";
      else if(rw_leaf->leaf_type == "STRING")
	fresh_node->op_value = "read_write_string";
      fresh_node->Rs = rw_leaf->leaf_name;
      fresh_node->Rt = "_";
      fresh_node->reg_dest = "_";
      fresh_node->op_type = rw_leaf->leaf_type;
      rw_id_list.push_back(fresh_node);
    }
  }
  else {
    if(check_leaf(name_leaf, current_leaf_scope) != NULL) {
      //dalloc_symbol_table_tree();
      cout<<"DECLARATION ERROR "<<name_leaf<<"\n";
      exit(0);
    }
    else {
      symbol_table_tree * current_leaf = new symbol_table_tree;
      symbol_table_tree * leaf_jumper;

      leaf_jumper = stem;
      while(leaf_jumper->next_leaf != NULL) leaf_jumper = leaf_jumper->next_leaf;

      current_leaf->leaf_name = name_leaf;
      current_leaf->leaf_scope = current_leaf_scope;
      current_leaf->branch_scope = current_branch_scope;
      current_leaf->leaf_type = type_leaf;
      current_leaf->has_sub_leaves = 0;
      current_leaf->next_leaf = NULL;

      if(type_leaf == "STRING")
	current_leaf->leaf_string = string_leaf;
      else if(type_leaf == "INT")
	current_leaf->leaf_int = int_leaf;
      else if(type_leaf == "FLOAT")
	current_leaf->leaf_float = float_leaf;

      leaf_jumper->next_leaf = current_leaf;
    }
  }
}

symbol_table_tree * check_leaf(string name_leaf, string scope_leaf) {

  symbol_table_tree * current_leaf;
  if(stem->next_leaf == NULL)
    current_leaf = stem;
  else
    current_leaf = stem->next_leaf;

  if(!current_leaf->leaf_name.empty()) {
    while(current_leaf->next_leaf != NULL) {
      if(current_leaf->leaf_scope == scope_leaf && current_leaf->leaf_name == name_leaf)
	return current_leaf;
      else
	current_leaf = current_leaf->next_leaf;
    }
  }
  return NULL;
	    
}

symbol_table_tree * check_branch(string scope_branch) {
  
  symbol_table_tree * current_branch;
  if(stem->next_leaf == NULL)
    current_branch = stem;
  else
    current_branch = stem->next_leaf;
  
  symbol_table_tree * temp = (stem->next_leaf == NULL)? stem : stem->next_leaf;

  if(!temp->leaf_name.empty()) {
    while(temp->next_leaf != NULL) {
      if(scope_branch == temp->leaf_scope)
	return current_branch;
      else {
	temp = temp->next_leaf;
	current_branch = temp;
      }
    }
  }
  return NULL;
}

void start_block_scope(string name) {

  current_branch_scope = current_leaf_scope;
  if(name == "BLOCK") {
    stringstream temp_string;
    string int2string;
    temp_string << block_count;
    block_count++;
    int2string = temp_string.str();
    current_leaf_scope = name + " " + int2string;
  }
  else
    current_leaf_scope = name;
  symbol_table_tree * new_leaf = new symbol_table_tree;
  new_leaf->leaf_name = current_leaf_scope;
  new_leaf->branch_scope = current_branch_scope;
  new_leaf->leaf_scope = current_leaf_scope;
  new_leaf->has_sub_leaves = 1;
  new_leaf->next_leaf = NULL;

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
      if(temp_stem->leaf_scope == "GLOBAL")
	cout<<"Symbol table "<<temp_stem->leaf_scope<<"\n";
      else if(temp_stem->leaf_scope == "BLOCK")
	cout<<"Symbol table "<<temp_stem->leaf_scope<<"\n";
      else
	cout<<"Symbol table "<<temp_stem->leaf_scope<<"\n";
    }
    else {
      if(temp_stem->leaf_type == "STRING")
	cout<<"name "<<temp_stem->leaf_name<<" type "<<temp_stem->leaf_type<<" value "<<temp_stem->leaf_string<<"\n";
      else if(temp_stem->leaf_type == "INT" || temp_stem->leaf_type == "FLOAT")
	cout<<"name "<<temp_stem->leaf_name<<" type "<<temp_stem->leaf_type<<"\n";
    }
    temp_stem = temp_stem->next_leaf;
  }
}

void set_register_Rd(threeAC_node * temp_node) {
  string int2string;
  stringstream temp_string;
  temp_string << current_register_index;
  current_register_index++;
  int2string = temp_string.str();
  temp_node->reg_dest = "$T" + int2string;
}

void set_register_Rs(threeAC_node * temp_node) {
  stringstream temp_string;
  string int2string;
  temp_string << current_register_index;
  current_register_index++;
  int2string = temp_string.str();
  temp_node->Rs = "$T" + int2string;
}

void set_dest_label(threeAC_node * temp_node) {
  stringstream temp_string;
  string int2string;
  temp_string << label_number;
  label_number++;
  int2string = temp_string.str();
  temp_node->reg_dest = "LOCATION_" + int2string;
}

void print_threeAC_code(list_data ptr) {
  list_data::iterator index;
  printf("\n;Intermediate Representation\n\n");
  for(index = ptr.begin(); index != ptr.end(); index++)
    cout<<";"<<(*index)->op_value<<" "<<(*index)->Rs<<" "<<(*index)->Rt<<" "<<(*index)->reg_dest<<"\n";
}

void print_tiny_code(list_instr ptr) {
  list_instr::iterator index;
  printf("\n;Tiny Assembly Code\n\n");
  for(index = ptr.begin(); index != ptr.end(); index++) {
    if((*index)->opcode != "_" && (*index)->Rs != "")
      cout<<(*index)->opcode<<" ";
    if((*index)->Rs != "_")
      cout<<(*index)->Rs<<" ";
    if((*index)->Rt != "_")
      cout<<(*index)->Rt<<" ";
    if((*index)->Rd != "_")
      cout<<(*index)->Rd<<" ";
    printf("\n");
  }
}

void print_inter_list(list_data ptr, string helpful_info) {
  list_data::iterator index;
  cout<<"\n\n;"<<helpful_info<<"\n\n";
  for(index = ptr.begin(); index != ptr.end(); index++)
    cout<<";Opcode: "<<(*index)->op_value<<" \t Src1: "<<(*index)->Rs<<" \t Src2: "<<(*index)->Rt<<" \t Dest: "<<(*index)->reg_dest<<"\n";
}

void clean_3ac_list(list_data ptr) {
  inter_list = ptr;
  list_data::iterator index = inter_list.begin();
  ptr.clear();
  while(index != inter_list.end()) {
    if((*index)->op_value == "_")
      index++;
    else if(!((*index)->op_value == "sys writei" || (*index)->op_value == "sys writer" || (*index)->op_value == "STOREI" || (*index)->op_value == "STOREF" || (*index)->op_value == "sys writes" || (*index)->op_value == "sys readi" || (*index)->op_value == "sys readr" || (*index)->op_value == "label" || (*index)->op_value == "jmp" || (*index)->op_value == "jeq" || (*index)->op_value == "jne" || (*index)->op_value == "jlt" || (*index)->op_value == "jle" || (*index)->op_value == "jgt" || (*index)->op_value == "jge" || (*index)->op_value == "cmpr" || (*index)->op_value == "cmpi")) {
      if(!((*index)->Rs == "_" || (*index)->Rt == "_" || (*index)->reg_dest == "_"))
	ptr.push_back(*index);
      index++;
    }
    else {
      ptr.push_back(*index);
      index++;
    }
    threeAC_list = ptr;
  }

  inter_list = threeAC_list;
  index = inter_list.begin();
  ptr.clear();
  int flag = 0;
  string temp_string;

  while(index != inter_list.end()) {
    if((*index)->op_value == "STOREF" && (*index)->Rs.find('$') == string::npos) {
      threeAC_node * fresh_node0 = new threeAC_node;
      threeAC_node * fresh_node1 = new threeAC_node;

      if((*index)->Rs[0] == '$')
	set_register_Rs(fresh_node0);
      else
	fresh_node0->Rs = (*index)->Rs;
      
      fresh_node0->op_value = (*index)->op_value;
      fresh_node0->Rt = "_";
      set_register_Rd(fresh_node0);
      ptr.push_back(fresh_node0);

      fresh_node1->op_value = (*index)->op_value;
      fresh_node1->Rs = fresh_node0->reg_dest;
      fresh_node1->Rt = "_";
      fresh_node1->reg_dest = (*index)->reg_dest;
      ptr.push_back(fresh_node1);

      index++;
    }
    else if((*index)->op_value == "STOREI" && (*index)->Rs.find('$') == string::npos) {
      threeAC_node * fresh_node0 = new threeAC_node;
      threeAC_node * fresh_node1 = new threeAC_node;

      if(flag) {
	fresh_node0->Rs = temp_string;
	flag = 0;
      }
      else
	fresh_node0->Rs = (*index)->Rs;
      
      fresh_node0->Rt = "_";
      fresh_node0->op_value = (*index)->op_value;
      set_register_Rd(fresh_node0);
      ptr.push_back(fresh_node0);

      fresh_node1->op_value = (*index)->op_value;
      fresh_node1->Rs = fresh_node0->reg_dest;
      fresh_node1->Rt = "_";
      fresh_node1->reg_dest = (*index)->reg_dest;
      ptr.push_back(fresh_node1);

      index++;
    }
    else {
      threeAC_node * fresh_node = new threeAC_node;
      fresh_node->op_value = (*index)->op_value;
      fresh_node->Rs = (*index)->Rs;
      fresh_node->Rt = (*index)->Rt;
      fresh_node->reg_dest = (*index)->reg_dest;
      temp_string = fresh_node->reg_dest;
      ptr.push_back(fresh_node);
      flag = 1;
      index++;
    }
  }
}

void clean_tiny_list(list_instr ptr) {
  inter_tiny_list = ptr;
  ptr.clear();
  tiny_list.clear();
  list_instr::iterator index = inter_tiny_list.begin();
  while(index != inter_tiny_list.end()) {
    if((*index)->opcode == "addi" || (*index)->opcode == "addr" || (*index)->opcode == "subi" || (*index)->opcode == "subr" || (*index)->opcode == "muli" || (*index)->opcode == "mulr" || (*index)->opcode == "divi" || (*index)->opcode == "divr") {
      tiny_instr * fresh_node0 = new tiny_instr;
      tiny_instr * fresh_node1 = new tiny_instr;
      
      fresh_node0->opcode = "move";
      fresh_node0->Rs = (*index)->Rs;
      fresh_node0->Rt = "_";
      fresh_node0->Rd = (*index)->Rd;
      tiny_list.push_back(fresh_node0);

      fresh_node1->opcode = (*index)->opcode;
      fresh_node1->Rs = (*index)->Rt;
      fresh_node1->Rt = "_";
      fresh_node1->Rd = (*index)->Rd;
      tiny_list.push_back(fresh_node1);
    }
    else {
      tiny_instr * fresh_node = new tiny_instr;
      
      fresh_node->opcode = (*index)->opcode;
      fresh_node->Rs = (*index)->Rs;
      fresh_node->Rt = (*index)->Rt;
      fresh_node->Rd = (*index)->Rd;
      tiny_list.push_back(fresh_node);
    }
    index++;
  }
}

void format_node(list_data * ptr, string data_type) {
  list_data::iterator index;
  if(!ptr->empty()) {
    for(index = ptr->begin(); index != ptr->end(); index++) {
      if(data_type == "INT" && (*index)->op_type == "INT") {
	if((*index)->op_value == "+")
	  (*index)->op_value = "addi";
	else if((*index)->op_value == "-")
	  (*index)->op_value = "subi";
	else if((*index)->op_value == "*")
	  (*index)->op_value = "muli";
	else if((*index)->op_value == "/")
	  (*index)->op_value = "divi";
	else if((*index)->op_value == ":=")
	  (*index)->op_value = "STOREI";
      }
      else if(data_type == "FLOAT" && (*index)->op_type == "FLOAT") {
	if((*index)->op_value == "+")
	  (*index)->op_value = "addr";
	else if((*index)->op_value == "-")
	  (*index)->op_value = "subr";
	else if((*index)->op_value == "*")
	  (*index)->op_value = "mulr";
	else if((*index)->op_value == "/")
	  (*index)->op_value = "divr";
	else if((*index)->op_value == ":=")
	  (*index)->op_value = "STOREF";
      }
    }
  }
}

void format_condition_node(list_data * ptr) {
  threeAC_node * temp_compop = ptr->back();
  threeAC_node * fresh_node1 = new threeAC_node;
  threeAC_node * fresh_node2 = new threeAC_node;

  if(temp_compop->op_type == "INT") {
    fresh_node1->op_type = "INT";
    fresh_node1->op_value = "cmpi";
  }
  else if(temp_compop->op_type == "FLOAT") {
    fresh_node1->op_type = "FLOAT";
    fresh_node1->op_value = "cmpr";  
  }
  fresh_node1->Rs = temp_compop->Rs;
  fresh_node1->Rt = temp_compop->Rt;
  fresh_node1->reg_dest = "_";
  
  if(temp_compop->op_value == "=") 
    fresh_node2->op_value = "jne";
  else if(temp_compop->op_value == "!=")
    fresh_node2->op_value = "jeq";
  else if(temp_compop->op_value == "<")
    fresh_node2->op_value = "jge";
  else if(temp_compop->op_value == "<=")
    fresh_node2->op_value = "jgt";
  else if(temp_compop->op_value == ">")
    fresh_node2->op_value = "jle";
  else if(temp_compop->op_value == ">=")
    fresh_node2->op_value = "jlt";
  fresh_node2->Rs = "_";
  fresh_node2->Rt = "_";
  fresh_node2->reg_dest = temp_compop->reg_dest;
  fresh_node2->op_type = temp_compop->op_type;

  ptr->pop_back();
  ptr->push_back(fresh_node1);
  ptr->push_back(fresh_node2);
}

void convert_STto3AC() {
  symbol_table_tree * temp_ptr = stem;
  while(temp_ptr != NULL) {
    if(temp_ptr->leaf_name[0] != 'B' && temp_ptr->leaf_name[1] != 'L' && temp_ptr->leaf_name != "main") {
      if(temp_ptr->leaf_type != "STRING") {
	tiny_instr * fresh_node = new tiny_instr;
	fresh_node->opcode = "var";
	fresh_node->Rs = temp_ptr->leaf_name;
	fresh_node->Rt = "_";
	fresh_node->Rd = "_";
	tiny_list.push_front(fresh_node);
      }
      else if(temp_ptr->leaf_type == "STRING") {
	tiny_instr * fresh_node = new tiny_instr;
	fresh_node->opcode = "str";
	fresh_node->Rs = temp_ptr->leaf_name;
	fresh_node->Rt = "_";
	fresh_node->Rd = temp_ptr->leaf_string;
	tiny_list.push_front(fresh_node);
      }
    }
    temp_ptr = temp_ptr->next_leaf;
  }
}

void create_tiny_code(list_data ptr) {
  convert_STto3AC();
  list_data::iterator index = ptr.begin();
  string temp_value;

  while(index != ptr.end()) {
    tiny_instr * fresh_node = new tiny_instr;
    fresh_node->opcode = (*index)->op_value;
    fresh_node->Rs = (*index)->Rs;
    fresh_node->Rt = (*index)->Rt;
    fresh_node->Rd = (*index)->reg_dest;
    if(fresh_node->opcode == "STOREF" || fresh_node->opcode == "STOREI")
      fresh_node->opcode = "move";
    if(fresh_node->Rs[0] == '$') {
      temp_value = fresh_node->Rs;
      fresh_node->Rs = "r" + temp_value.substr(2);
    }
    if(fresh_node->Rt[0] == '$') {
      temp_value = fresh_node->Rt;
      fresh_node->Rt = "r" + temp_value.substr(2);
    }
    if(fresh_node->Rd[0] == '$') {
      temp_value = fresh_node->Rd;
      fresh_node->Rd = "r" + temp_value.substr(2);
    }
    tiny_list.push_back(fresh_node);
    index++;
  }
}

int main(int argc, char **argv) {

  int parse_return;
  threeAC_node * first_node = new threeAC_node;
  
  stem = new symbol_table_tree;
  stem->next_leaf = NULL;
  current_leaf_scope = "GLOBAL";
  current_branch_scope = "GLOBAL";

  start_block_scope("GLOBAL");

  first_node->op_value = "_";
  first_node->Rs = "_";
  first_node->Rt = "_";
  first_node->reg_dest = "_";
  
  threeAC_list.push_back(first_node);
  inter_list.push_back(first_node);

  if(argc > 0)
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  parse_return = yyparse();
  return 0;
}
