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
extern int function_slot_counter;
extern int function_param_counter;
extern string current_function_scope;
int block_count;
string current_leaf_scope;
string current_branch_scope;
symbol_table_tree * stem;

void create_leaf(string name_leaf, string type_leaf, string string_leaf, float float_leaf, int int_leaf, int is_param) {

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
      //delete fresh_node;
      //delete rw_leaf;
    }
    else {
      if(check_leaf(name_leaf, current_function_scope) != NULL) {
	threeAC_node * fresh_node = new threeAC_node;
	symbol_table_tree * rw_leaf = check_leaf(name_leaf, current_function_scope);
	if(rw_leaf->leaf_type == "INT")
	  fresh_node->op_value = "read_write_int";
	else if(rw_leaf->leaf_type == "FLOAT")
	  fresh_node->op_value = "read_write_float";
	else if(rw_leaf->leaf_type == "STRING")
	  fresh_node->op_value = "read_write_string";

	stringstream temp_string;
	temp_string << rw_leaf->slot_number;
	fresh_node->Rs = (rw_leaf->is_parameter)? "$p" + temp_string.str() : "$l" + temp_string.str();
	fresh_node->Rt = "_";
	fresh_node->reg_dest = "_";
	fresh_node->op_type = rw_leaf->leaf_type;
	rw_id_list.push_back(fresh_node);
	//delete fresh_node;
	//delete rw_leaf;
      }
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
      current_leaf->is_parameter = is_param;
      current_leaf->slot_number = is_param? ++function_param_counter : ++function_slot_counter;
      current_leaf->next_leaf = NULL;

      if(type_leaf == "STRING")
	current_leaf->leaf_string = string_leaf;
      else if(type_leaf == "INT")
	current_leaf->leaf_int = int_leaf;
      else if(type_leaf == "FLOAT")
	current_leaf->leaf_float = float_leaf;

      leaf_jumper->next_leaf = current_leaf;
      //delete current_leaf;    //To be verified later on
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
    while(current_leaf != NULL) {
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
  //delete temp;
  return NULL;
}

void start_block_scope(string name) {
  function_slot_counter = 0;
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
  new_leaf->is_parameter = 0;
  new_leaf->slot_number = function_slot_counter;
  new_leaf->next_leaf = NULL;

  symbol_table_tree * temp;
  
  temp = stem;
  while(temp->next_leaf != NULL)
    temp = temp->next_leaf;
  
  temp->next_leaf = new_leaf;
  //delete new_leaf;     //To be verified later on
}

void end_block_scope() {

  symbol_table_tree * scope_end;
  
  scope_end = check_branch(current_branch_scope);
  current_leaf_scope = current_branch_scope;
  current_branch_scope = scope_end->leaf_scope;
  //delete scope_end;
}

void dalloc_symbol_table_tree() {
  
  symbol_table_tree * temp;
  symbol_table_tree * temp_next;
  temp = stem;
  
  while(temp->next_leaf != NULL) {
    temp_next = temp->next_leaf;
    delete temp;
    temp = temp_next;
  }
  //delete temp;
  //delete temp_next;
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
	cout<<";Symbol table "<<temp_stem->leaf_scope<<"\n";
      else if(temp_stem->leaf_scope == "BLOCK")
	cout<<";Symbol table "<<temp_stem->leaf_scope<<"\n";
      else
	cout<<";Symbol table "<<temp_stem->leaf_scope<<"\n";
    }
    else {
      if(temp_stem->leaf_type == "STRING")
	cout<<";name "<<temp_stem->leaf_name<<" type "<<temp_stem->leaf_type<<" value "<<temp_stem->leaf_string<<"\n";
      else if(temp_stem->leaf_type == "INT" || temp_stem->leaf_type == "FLOAT")
	cout<<";name "<<temp_stem->leaf_name<<" type "<<temp_stem->leaf_type<<" scope "<<temp_stem->leaf_scope<<"\n";
    }
    temp_stem = temp_stem->next_leaf;
  }
  //delete temp_stem;
}

int count_function_params_or_locals(string scope, int params_or_locals) {
  symbol_table_tree * temp = (stem->next_leaf == NULL)? stem : stem->next_leaf;
  int counter = 0;
  if(temp->leaf_name.empty())
    return 0;
  else {
    while(temp != NULL) {
      if(temp->leaf_scope == scope) {
	if(params_or_locals && temp->is_parameter)
	  counter++;
	else if(!params_or_locals && !(temp->is_parameter) && !(temp->has_sub_leaves))
	  counter++;
      }
      temp = temp->next_leaf;
    }
  }
  //delete temp;
  return counter;
}

int find_param_or_local_slot(string scope, string name, int& param_or_local) {
  symbol_table_tree * temp = (stem->next_leaf == NULL)? stem : stem->next_leaf;
  if(temp->leaf_name.empty()) {
    //delete temp;
    return 0;
  }
  else {
    while(temp != NULL) {
      if(temp->leaf_scope == scope) {
	if(temp->leaf_name == name) {
	  param_or_local = temp->is_parameter;
	  int temp_slot_number = temp->slot_number;
	  //delete temp;
	  return temp_slot_number;
	}
      }
      temp = temp->next_leaf;
    }
  }
  //delete temp;
  return 0;     //Couldn't find the parameter/local variable
}

void set_register_Rd(threeAC_node * temp_node, string identifier, int& specific_counter) {
  string int2string;
  stringstream temp_string;
  temp_string << specific_counter;
  specific_counter++;
  int2string = temp_string.str();
  temp_node->reg_dest = identifier + int2string;
}

void set_register_Rs(threeAC_node * temp_node) {
  stringstream temp_string;
  string int2string;
  temp_string << current_register_index;
  current_register_index++;
  int2string = temp_string.str();
  temp_node->Rs = "$T" + int2string;
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
    cout<<";Opcode: "<<(*index)->op_value<<"\tSrc1: "<<(*index)->Rs<<"\tSrc2: "<<(*index)->Rt<<"\tDest: "<<(*index)->reg_dest<<"\tOp-Type: "<<(*index)->op_type<<"\n";
}

void clean_3ac_list(list_data ptr) {
  inter_list = ptr;
  list_data::iterator index = inter_list.begin();
  ptr.clear();
  while(index != inter_list.end()) {
    if((*index)->op_value == "_")
      index++;
    else if(!((*index)->op_value == "sys writei" || (*index)->op_value == "sys writer" || (*index)->op_value == "STOREI" || (*index)->op_value == "STOREF" || (*index)->op_value == "sys writes" || (*index)->op_value == "sys readi" || (*index)->op_value == "sys readr" || (*index)->op_value == "label" || (*index)->op_value == "jmp" || (*index)->op_value == "jeq" || (*index)->op_value == "jne" || (*index)->op_value == "jlt" || (*index)->op_value == "jle" || (*index)->op_value == "jgt" || (*index)->op_value == "jge" || (*index)->op_value == "cmpr" || (*index)->op_value == "cmpi" || (*index)->op_value == "push" || (*index)->op_value == "pop" || (*index)->op_value == "link" || (*index)->op_value == "unlnk" || (*index)->op_value == "jsr" || (*index)->op_value == "ret")) {
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

      //delete fresh_node0;
      //delete fresh_node1;
    }
    else {
      tiny_instr * fresh_node = new tiny_instr;
      
      fresh_node->opcode = (*index)->opcode;
      fresh_node->Rs = (*index)->Rs;
      fresh_node->Rt = (*index)->Rt;
      fresh_node->Rd = (*index)->Rd;
      tiny_list.push_back(fresh_node);

      //delete fresh_node;
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

  //delete fresh_node1;
  //delete fresh_node2;
  //delete temp_compop;
}

void format_params_and_locals(list_data * ptr, string scope) {
  list_data::iterator index;
  for(index = ptr->begin(); index != ptr->end(); index++) {
    int param_or_local = 0;
    int slot_number = 0;
    if(find_param_or_local_slot("GLOBAL", (*index)->Rs, param_or_local) == 0) {
      slot_number = find_param_or_local_slot(scope, (*index)->Rs, param_or_local);
      if(slot_number != 0) {
	stringstream temp_string;
	temp_string << slot_number;
	(*index)->Rs = (param_or_local)? "$p" + temp_string.str() : "$l" + temp_string.str();
      }
    }
    if(find_param_or_local_slot("GLOBAL", (*index)->Rt, param_or_local) == 0) {
      slot_number = find_param_or_local_slot(scope, (*index)->Rt, param_or_local);
      if(slot_number != 0) {
	stringstream temp_string;
	temp_string << slot_number;
	(*index)->Rt = (param_or_local)? "$p" + temp_string.str() : "$l" + temp_string.str();
      }
    }
    if(find_param_or_local_slot("GLOBAL", (*index)->reg_dest, param_or_local) == 0) {
      slot_number = find_param_or_local_slot(scope, (*index)->reg_dest, param_or_local);
      if(slot_number != 0) {
	stringstream temp_string;
	temp_string << slot_number;
	(*index)->reg_dest = (param_or_local)? "$p" + temp_string.str() : "$l" + temp_string.str();
      }
    }
  }
}

void convert_STto3AC() {
  symbol_table_tree * temp_ptr = stem;
  while(temp_ptr != NULL) {
    if(temp_ptr->leaf_scope == "GLOBAL" && temp_ptr->leaf_name != "GLOBAL") { //&& temp_ptr->leaf_name[1] != 'L' && temp_ptr->leaf_name != "main") {
      if(temp_ptr->leaf_type != "STRING") {
	tiny_instr * fresh_node = new tiny_instr;
	fresh_node->opcode = "var";
	fresh_node->Rs = temp_ptr->leaf_name;
	fresh_node->Rt = "_";
	fresh_node->Rd = "_";
	tiny_list.push_front(fresh_node);

	//delete fresh_node;
      }
      else if(temp_ptr->leaf_type == "STRING") {
	tiny_instr * fresh_node = new tiny_instr;
	fresh_node->opcode = "str";
	fresh_node->Rs = temp_ptr->leaf_name;
	fresh_node->Rt = "_";
	fresh_node->Rd = temp_ptr->leaf_string;
	tiny_list.push_front(fresh_node);

	//delete fresh_node;
      }
    }
    temp_ptr = temp_ptr->next_leaf;
  }
  //delete temp_ptr;
}

void create_tiny_code(list_data ptr) {
  convert_STto3AC();
  list_data::iterator index = ptr.begin();
  string temp_value;
  tiny_instr * fresh_node0 = new tiny_instr;
  fresh_node0->Rs = "r0";
  fresh_node0->Rt = "_";
  fresh_node0->Rd = "_";
  fresh_node0->opcode = "push";
  tiny_list.push_back(fresh_node0);

  tiny_instr * fresh_node1 = new tiny_instr;
  fresh_node1->Rs = "r1";
  fresh_node1->Rt = "_";
  fresh_node1->Rd = "_";
  fresh_node1->opcode = "push";
  tiny_list.push_back(fresh_node1);

  tiny_instr * fresh_node2 = new tiny_instr;
  fresh_node2->Rs = "r2";
  fresh_node2->Rt = "_";
  fresh_node2->Rd = "_";
  fresh_node2->opcode = "push";
  tiny_list.push_back(fresh_node2);

  tiny_instr * fresh_node3 = new tiny_instr;
  fresh_node3->Rs = "r3";
  fresh_node3->Rt = "_";
  fresh_node3->Rd = "_";
  fresh_node3->opcode = "push";
  tiny_list.push_back(fresh_node3);

  tiny_instr * return_value_node = new tiny_instr;
  return_value_node->Rs = "_";
  return_value_node->Rt = "_";
  return_value_node->Rd = "_";
  return_value_node->opcode = "push";
  tiny_list.push_back(return_value_node);

  tiny_instr * main_function_call = new tiny_instr;
  main_function_call->Rs = "_";
  main_function_call->Rt = "_";
  main_function_call->Rd = "FUNC_main";
  main_function_call->opcode = "jsr";
  tiny_list.push_back(main_function_call);

  tiny_instr * halt_program = new tiny_instr;
  halt_program->opcode = "sys halt";
  halt_program->Rs = "_";
  halt_program->Rt = "_";
  halt_program->Rd = "_";
  tiny_list.push_back(halt_program);

  //delete fresh_node0;
  //delete fresh_node1;
  //delete fresh_node2;
  //delete fresh_node3;
  //delete return_value_node;
  //delete main_function_call;
  //delete halt_program;

  while(index != ptr.end()) {
    tiny_instr * fresh_node = new tiny_instr;
    fresh_node->opcode = (*index)->op_value;
    fresh_node->Rs = (*index)->Rs;
    fresh_node->Rt = (*index)->Rt;
    fresh_node->Rd = (*index)->reg_dest;
    if(fresh_node->opcode == "STOREF" || fresh_node->opcode == "STOREI")
      fresh_node->opcode = "move";
    if(fresh_node->Rs[0] == '$') {
      if(fresh_node->Rs[1] == 'T') {
	temp_value = fresh_node->Rs;
	fresh_node->Rs = "r" + temp_value.substr(2);
      }
      else if(fresh_node->Rs[1] == 'p') {
	temp_value = fresh_node->Rs;
	fresh_node->Rs = "$" + temp_value.substr(2);
      }
      else if(fresh_node->Rs[1] == 'l') {
	temp_value = fresh_node->Rs;
	fresh_node->Rs = "$-" + temp_value.substr(2);
      }
    }
    if(fresh_node->Rt[0] == '$') {
      if(fresh_node->Rt[1] == 'T') {
	temp_value = fresh_node->Rt;
	fresh_node->Rt = "r" + temp_value.substr(2);
      }
      else if(fresh_node->Rt[1] == 'p') {
	temp_value = fresh_node->Rt;
	fresh_node->Rt = "$" + temp_value.substr(2);
      }
      else if(fresh_node->Rt[1] == 'l') {
	temp_value = fresh_node->Rt;
	fresh_node->Rt = "$-" + temp_value.substr(2);
      }
    }
    if(fresh_node->Rd[0] == '$') {
      if(fresh_node->Rd[1] == 'T') {
	temp_value = fresh_node->Rd;
	fresh_node->Rd = "r" + temp_value.substr(2);
      }
      else if(fresh_node->Rd[1] == 'p') {
	temp_value = fresh_node->Rd;
	fresh_node->Rd = "$" + temp_value.substr(2);
      }
      else if(fresh_node->Rd[1] == 'l') {
	temp_value = fresh_node->Rd;
	fresh_node->Rd = "$-" + temp_value.substr(2);
      }
    }
    tiny_list.push_back(fresh_node);
    index++;
    //delete fresh_node;
  }
}

int main(int argc, char **argv) {

  int parse_return;
  block_count = 1;
  current_leaf_scope = "GLOBAL";
  current_branch_scope = "GLOBAL";
  stem = new symbol_table_tree;
  stem->next_leaf = NULL;

  start_block_scope("GLOBAL");

  if(argc > 0)
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  parse_return = yyparse();
    
  delete stem;
  return 0;
}
