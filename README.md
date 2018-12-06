# Optimizing-Compilers
Compilers class where I created and optimized a compiler in C++ using flex and bison. The compiler was written for a simplified language known as Tiny.

Tiny is a very simple assembly code interpreter. 

The executable runs on Sun architectures

---------------------------------------
an example Tiny program (a longer program is attached at the end):<br />

var i <br />
str prompt "enter a number: " <br />
str announce "\nthe square is" <br />

label myloop       ; main loop<br />
sys writes prompt <br />
sys readi i  <br />
move i r3 <br />
muli i r3 <br />
                   ; some more comment    <br />
sys writes announce	<br />
sys writei r3      ; 	<br />
cmpi 1 r3  <br />
jne myloop   <br />
sys halt           ; optional if at end   <br />
end <br />

---------------------------------------

Tiny simulates an architecture that has 4 data registers, a stack pointer (sp),
a frame pointer (fp) and both integer an floating point arithmetic. All data
elements have size 1. The data representation is unknown to the user.
<br />
Tiny accepts the following assembly codes:
<br />
var id				; reserves and names a memory cell. first letter alphanum <br />
                                  then alphanum with punctuations, case sensitive <br />
                                ; both integer and real (float) have the size of one memory cell <br />
str sid    "a string constant"  ; the only operation on string constants is sys writes sid <br />
                                  strings can include \n for end-of-line <br />

;  var and str declarations must preceed all code and labels (during debugging, <br />
;  enforcement of this rule can be disabled. See the "mix" command line option) <br />

label target	           ; a jump target	<br />
move opmrl opmr 	       ; only one operand can be a memory id or stack variable <br />
addi opmrl reg         	; integer addition, reg = reg + op1 <br />
addr opmrl reg         	; real (i.e. floatingpoint) addition <br />
subi opmrl reg         	; computes reg = reg - op1 <br />
subr opmrl reg <br />
muli opmrl reg      	   ; computes reg = reg * op1 <br />
mulr opmrl reg	<br />
divi opmrl reg       	  ; computes reg = reg /  op1 <br />
divr opmrl reg	<br />
inci reg             	  ; increment the (integer) register value by 1 <br />
deci reg               	; decrement the (integer) register value by 1 <br />
cmpi opmrl reg         	; integer comparison; must preceed  a conditional jump; <br />
                         it compares the first operand with the second op and <br />
			 sets  the "processor status". (The status remains the <br />
			 same until the next cmp instruction is executed.) <br />
                         E.g, a subsequent jgt will jump if op1 > op2 <br />


push opmrl      	       ; push a data item onto the stack. Operand can be <br />
                       	;   omitted, in which case an empty element is pushed. <br />
pop  opmr              ; pops an element from the stack. If the operand is <br />
                       ;   non-empty, the element is moved there <br />
jsr target             ; jump to target and push the current pc onto the stack <br />
ret                    ; pop an address from the stack and jump there <br />
link x                 ; push frame pointer (fp) onto stack, copy sp into fp, <br />
                       ;   push x empty cells onto stack <br />
unlnk                  ; copy fp into sp, pop fp from stack <br />

cmpr opmrl reg         ; real comparison <br />
jmp target             ; unconditional jump <br />
jgt target             ; jump if (op1 of the preceeding cmp was) greater (than op2) <br />
jlt target             ; jump if less than <br />
jge target             ; jump if greater of equal <br />
jle target             ; jump if less or equal <br />
jeq target             ; jump if equal <br />
jne target             ; jump if not equal <br />
sys readi  opmr        ; system call for reading an integer from input <br />
sys readr  opmr        ; system call for reading a real value  <br />
sys writei opmr        ; system call for outputting an integer <br />
sys writer opmr        ; system call for outputting an integer <br />
sys writes sid         ; system call for outputting a string constant <br />
sys halt               ; system call to end the execution <br />
end                    ; end of the assembly code (not an opcode) <br />


notation used for the operands: <br />
 id      stands for the name of a memory location <br />
 sid     stands for the name of a string constant <br />
 x       stands for an integer number <br />
 target  stands for the name of a jump target <br />
 $offset stands for a stack variable at address fp+offset <br />
 reg     stands for a  register, named r0,r1,r2, or r3, case insensitive <br />
 opmrl   stands for a memory id, stack variable, register or a number (literal),  <br />
         the format for real is digit*[.digit*][E[+|-]digit*] <br />
 opmr    stands for a memory id, stack variable, or a register <br />
 
 ; semicolon leads in a comment (which is ignored by the interpreter). It can <br />
   be at the beginning on a line or after an assembly code <br />

data representation: <br />

No assumption can be made about the representations. Real and integer cannot be <br />
mixed.  Using an integer where a real is expected (and vice versa) leads to <br />
undefined results. <br />

-------------------------------
Running tiny <br />
syntax : tiny sourcefile [d1|d2|d3 [mix]] <br />

the second argument generates debug output <br />
d1: print a program listing <br />
d2: d1 +  print each line as it gets interpreted <br />
d2: d2 + print machine status and variable content at each step <br />

mix: allow  declarations inbetween code <br />

-----------------------------

A longer sample program. The program asks for a number and prints 5 asterisk <br />
triangles with this length. <br />

var length <br />
str star "*" <br />
str prompt "enter number: " <br />
str eol "\n" <br />

move 0 r2 <br />
sys writes prompt <br />
sys readi length <br />
move 1 r3 <br />
label outerloop <br />
move r3 r0 <br />
label starloop <br />
sys writes star <br />
subi 1 r0 <br />
cmpi 0 r0 <br />
jne starloop <br />
sys writes eol <br />
addi 1 r3 <br />
cmpi length r3 <br />
jge outerloop <br />
move 1 r3 <br />
addi 1 r2 <br />
cmpi 4 r2 <br />
jge outerloop <br />
sys halt <br />
end
