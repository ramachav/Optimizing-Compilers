# Register Re-allocation
The previous versions of the compiler were able to utilize up to 200 registers while generating the assembly code. This version has been updated to use only 4 registers. In order to maintain correct functionality of the program, a backwards analysis of the liveness of variables in the program was performed. Each instruction had it's GEN and KILL sets computed, along with it's LIVE IN and LIVE OUT sets. Using the information from these sets, it was determined when the registers would need to be freed, when they were available to use and when to write their dirty value back to memory. <br />
Definitions of some of the terms: <br />
GEN set: Set of all the variables that were used in a given instruction <br />
KILL set: Set of all the variables that were defined in a given instruction <br />
LIVE IN set: Set of all the variables that are LIVE coming into the instruction <br />
LIVE OUT set: Set of all the variables that are LIVE coming out of the instruction <br />
LIVE: If a variable is going to be used later on in the program <br />
