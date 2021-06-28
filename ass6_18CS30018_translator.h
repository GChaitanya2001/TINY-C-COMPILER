#ifndef ASS6_18CS30018_TRANSLATOR_H
#define ASS6_18CS30018_TRANSLATOR_H
#include <bits/stdc++.h>
using namespace std;

#define size_of_char 1
#define size_of_int 4
#define size_of_float 8
#define size_of_ptr 4

extern char* yytext;
//To detect the line at which error occurs
extern int yylineno;
extern int yyparse();	

class entry_type;			
class sym_entry;			
class sym_table;			
class quad;				
class quad_array;	

//Global Variable Declaration
extern sym_table* curr_table;		// Current Symbol table
extern sym_table* glb_table;		// Global Symbol table
extern quad_array q;			// Array of Quads
extern sym_entry* curr_symbol;	// A Pointer to the current symbol


//Class definitions

// class for each quad
class quad 
{ 
public:
 	//fields
	string op;	// Operator
	string result;	// Result
	string arg1;	// Argument 1
	string arg2;	// Argument 2

	//methods
	void print ();	// Print Quad
	
	//constructors
	quad (string result, string arg1, string op = "EQ", string arg2 = "");	
	quad (string result, int arg1, string op = "EQ", string arg2 = "");	
	quad (string result, float arg1, string op = "EQ", string arg2 = "");	
};

// class for the array of quads
class quad_array 
{ 
 public:
         // Vector of quads
	vector <quad> array;  
	
	// Print the quad_array 
	void print ();		
};

// class for the 'type' of a symbol in symbol table
class entry_type 
{ 
public:
        //constructor
	entry_type(string type, entry_type* ptr = NULL, int width = 1);
	
	//fields
	string type;
	entry_type* ptr;		
	int width;			
};

// class for each Entry in a symbol table
class sym_entry 
{ 
public:
        //fields
	string name;		// Name of the symbol
	entry_type *type;	// type of the Symbol
	string initial_value;	// initial values (if any).
	string category;    	// global, local or param
	int size;	// size of the symbol.
	int offset;	// Offset from the base pointer.
	sym_table* nested;	// Pointer to the nested symbol curr_table

       //methods
	sym_entry (string name, string t="INTEGER", entry_type* ptr = NULL, int width = 0); //constructor declaration
	sym_entry* update(entry_type * t); 	// A method to update different fields of an existing entry.
};

// class for Symbol table
class sym_table 
{ 
public:
        //fields
	string name;  // Name of curr_table
	int count;	// Count of temporary variables
	list<sym_entry> curr_table; 	// The curr_table of symbols
	sym_table* parent;	// Immediate parent of the symbol curr_table
	map<string, int> ar; //activation record

	//methods
	sym_table (string name="NULL");
	sym_entry* lookup (string name);  // Lookup for a symbol in symbol curr_table
	void print();	// Prints the symbol curr_table
	void update();	// Update offset of the complete symbol curr_table
};


/*structs for non-terminals, attributes corresponding to them */

//struct containing Attributes for expressions
struct expr 
{
	string type;  //to store whether the expression is of type int or bool
	
	// Valid for non-boolean type expressions
	sym_entry* loc;  // Pointer to the symbol curr_table entry

	// Valid for boolean type expressions
	list<int> TL;	// True List 
	list<int> FL;	// False List 
	
	// Valid for statement expressions
	list<int> NL; // Next List
};

//struct containig Attributes for statements
struct statement 
{
	list<int> NL; // Next List
};

//struct containing Attributes for array
struct arr 
{
	string cat;
	sym_entry* loc;	// Temporary used for computing array address
	sym_entry* array;      // Pointer to symbol curr_table
	entry_type* type;	// type of the subarray generated
};


//Global functions required for the translator.

// Checks whether two symbols in symbol table are of same type.
bool typecheck(sym_entry* &s1, sym_entry* &s2);

// Checks whether two 'entry_type' objects are of same type.		
bool typecheck(entry_type* t1, entry_type* t2);

/*Overloading 'emit' function*/
void emit(string op, string result, string arg1="", string arg2 = "");  
void emit(string op, string result, int arg1, string arg2 = "");	
void emit(string op, string result, float arg1, string arg2 = ""); 

// TAC for type conversion in program.
sym_entry* conv (sym_entry*, string);		

/*Inserts i as the target label for each of the quads on the list pointed to by 'p'*/
void backpatch (list <int> p, int i);	

/*Creates new list containing only i, an index into the quad_array*/
list<int> makelist (int i);

/* Concatenates two lists into a single list*/		
list<int> merge (list<int> &lst1, list <int> &lst2);	

/* Converts any expression (int) to bool*/
void convertInt2Bool (expr*);	

/* Converts bool to expression (int)*/	
void convertBool2Int (expr*);		

/*Changes the current symbol table*/
void changeTable (sym_table* newtable);  

/* Returns the index of next quad to be generated.*/   
int nextinstr();		

/* Generates a new temporary variable and inserts it to the current symbol curr_table*/
sym_entry* gentemp (entry_type* t, string init = ""); 

/* Calculate size of any symbol type*/ 
int size_alloc (entry_type*);

/* For printing type of symbol recursive printing of type*/
string print_type(entry_type*);	

#endif
