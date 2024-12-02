#ifndef _TRANSLATE_H
#define _TRANSLATE_H

#include <bits/stdc++.h>

using namespace std;

// MACROS
#define ltsit list<sym>::iterator
#define ltiit list<int>::iterator
#define ltstit list<symtable*>::iterator
#define qdit vector<quad>::iterator
#define ltsym list<sym>
#define ltst list<symtable*>


// class declarations
class sym;					
class symboltype;				
class symtable;					
class quad;						
class quadArray;				


// CLASSES

// symbol container
class sym {                                    
	
	public:
		string name; // name of symbol			
		symboltype *type; // symbol type (which is also a class as elaborated below)		
		int size; // symbol size			
		int offset;	// offset of symbol			
		symtable* nested; 
		string val; // initial value of symbol

		// Constructor
		sym (string , string t="int", symboltype* ptr = NULL, int width = 0);
		// Update the ST Entry 
		// A method to update symboltype of current symbol (and change size etc. accordingly)
		sym* update(symboltype*); 	
};

//symbol type container
class symboltype {                            
	
    public:
		string type;				// string name for type of symbol
		int width;			    // width (for size of array), constructur assigns 1 by default
		symboltype* arrtype;		// arrtype, needed for multidim arrays 
		// Constructor
		symboltype(string , symboltype* ptr = NULL, int width = 1);
};

// Symbol Table
class symtable { 				
	
    public: 
		string name;				// Name	
		int count;				// Number of temporary variables
		ltsym table; 			// a list of symbols (sym)
		symtable* parent;		// parent symbol table of current symbol table
		// Constructor
		symtable (string name="NULL");
		// Lookup for a symbol in symbol table
		sym* lookup (string);		
		// Print the symbol table					
		void print();	
		// Update the symbol table      			
		void update();						        			
};

// quad class
class quad {                   
			
	public:
		string res;				// Result of expression
		string op;				// Operator of experssion
		string arg1;				// First Argument
		string arg2;				// Second Argument

		// Functions to print the quad
		void print();	
		void print1();          
		void print2();

		// Constructors (arg2 delafults to none)
		quad (string , string , string op = "=", string arg2 = "");			
		quad (string , int , string op = "=", string arg2 = "");				
		quad (string , float , string op = "=", string arg2 = "");			
};

// quadArray class contains
// 1. a vector of quads
class quadArray                
{ 		
	public:
		vector <quad> Array;   // 1
		// Print the quadArray
		void print();								
};

// Denotes basic variable types (not user defined)
class basicType {                                
	
    public:
		// type name (e.g. float)
		vector <string> type;			
		// type size (in bytes)
		vector <int> size;			
		// add a new basic type
		void addType(string ,int );
};

// STRUCTS

// Statement
struct Statement {
	// nextlist for statements
	list<int> nextList;		
};

// Array (to handle 1D and multi D arrays) 
struct Array {
	// Used for type of Array: may be ptr or arr
	string atype;				
	// Location used to compute address of Array
	sym* location;			
	// pointer to the symbol table entry	
	sym* Array;				
	// type of the subarray generated (needed for multidim arrays)
	symboltype* type;		
};

// Expression
struct Expression {
	// pointer to the symbol table entry
	sym* location;			
	// to store type of expression out of int, char, float, bool
	string type; 				
	// truelist for boolean expressions
	list<int> trueList;		
	// falselist for boolean expressions
	list<int> falseList;	
	// for statement expressions
	list<int> nextList;		
};


// typedefs
typedef Expression* expr;
typedef symboltype symtyp;

// extern (include external variables)
extern char* yytext;
extern int yyparse();
extern symtable* ST;			// denotes the current Symbol Table
extern symtable* globalST;		// global symbol table
extern sym* currSymbolPtr;		// pointer to current symbol
extern quadArray Q;				// quad array (for TAC)
extern basicType bt;            // basic types
extern bool debug_on;			// bool for printing debug output

// just to format the output
void formatOutput(int);

// generate a temporary variable and insert it in the current symbol table
sym* gentemp (symtyp* , string init = "");	  

// Emit Functions
void emit(string , string , int, string arg = "");		  
void emit(string , string , float , string arg = "");   
void emit(string , string , string arg1="", string arg2 = "");

// Backpatch dangling exits with the given address.
void backpatch (list <int>, int);

// Create a new list containing the initial value.
list<int> makelist (int);  // Generate a new list with an integer.

// Merge two lists of dangling exits.
list<int> merge (list<int> &l1, list<int> &l2);  // Combine two lists into one.

// Returns the next instruction number.
int nextinstr();  

// Print debugging output.
void debug();  

// Convert symbol to target type.
sym* convertType(sym*, string);  

// Compare two symbol table entries.
bool TypeCheck(sym* &s1, sym* &s2);  

// Compare symboltype attributes.
bool TypeCheck(symtyp*, symtyp*);  

// Compute size of a symbol type.
int computeSize(symtyp*);  

// Print the type name of a symbol.
string printType(symtyp*);  

//Converters
string convertInt2String(int);  
string convertFloat2String(float);  
void convertInt2Bool(expr);  
void convertBool2Int(expr);  

#endif