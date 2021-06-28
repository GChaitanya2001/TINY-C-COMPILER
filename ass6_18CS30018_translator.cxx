#include "ass6_18CS30018_translator.h"

//Symbol_Table_Global
sym_table* glb_table;	

// refers to type of latest entry
string curr_type;	

//refers to current symbol table
sym_table* curr_table;	

//refers  to current symbol
sym_entry* curr_symbol; 

// Array of quads
quad_array q;						

//Constructors for 'quad' class
quad::quad (string result, string arg1, string op, string arg2): result (result), arg1(arg1), arg2(arg2), op (op){};

quad::quad (string result, int arg1, string op, string arg2): result (result), arg2(arg2), op (op) 
{
  /*converting 'int' type argument to string to match with the type of field, 'arg1', defined*/
   stringstream stream;
   stream << arg1;
   string en_str = stream.str();
   char* int_to_str = (char*)en_str.c_str();
   string str = string(int_to_str);
   this->arg1 = str;
}

quad::quad (string result, float arg1, string op, string arg2): result (result), arg2(arg2), op (op) 
{
    /*converting 'int' type argument to string to match with the type of field defined*/
    std::ostringstream en;
    en << arg1;
    this->arg1 = en.str();
}


//This method prints a quad 
void quad::print() 
{
	// Printing Binary Operations
	if (op=="ADD")	{
	    cout << result << " = " << arg1 << " + " << arg2;
	}
	else if (op=="MULT"){
	    cout << result << " = " << arg1 << " * " << arg2;
	}
	else if (op=="SUB"){
	    cout << result << " = " << arg1 << " - " << arg2;
	 }
	else if (op=="DIV")	{
	    cout << result << " = " << arg1 << " / " << arg2;
	}
	else if (op=="XOR"){
	    cout << result << " = " << arg1 << " ^ " << arg2;
	 }
	else if (op=="BITAND")	{
	    cout << result << " = " << arg1 << " & " << arg2;
	 }
	 else if (op=="INCLOR"){
	    cout << result << " = " << arg1 << " | " << arg2;
	 }
	 else if (op=="REMOP"){
	    cout << result << " = " << arg1 << " % " << arg2;
	 }
	// Printing Relational Operations
	else if (op=="EQOP")	{
	     cout << "if " << arg1 <<  " == " << arg2 << " goto " << result;
	  }
	else if (op=="NEOP")	{
	     cout << "if " << arg1 <<  " != " << arg2 << " goto " << result;
	  }
	 else if (op=="GTE") {
	     cout << "if " << arg1 <<  " >= " << arg2 << " goto " << result;
	  }
	else if (op=="LTE") {
	     cout << "if " << arg1 <<  " <= " << arg2 << " goto " << result;
	  }
	else if (op=="LT") {
	     cout << "if " << arg1 <<  " < "  << arg2 << " goto " << result;
	 }
	else if (op=="GT") {
	     cout << "if " << arg1 <<  " > "  << arg2 << " goto " << result;
	  }
	else if (op=="GOTOOP")	{
	    cout << "goto " << result;
	  }		
	//Printing Shift Operations
	else if (op=="EQ"){
	   cout << result << " = " << arg1 ;
	  }
	else if (op=="LEFTOP"){
	    cout << result << " = " << arg1 << " << " << arg2;
	  }
	else if (op=="RIGHTOP")
	  {
	    cout << result << " = " << arg1 << " >> " << arg2;
	  }
					
	//Printing Unary Operators
	else if (op=="AMP"){
	    cout << result << " = &" << arg1;
	  }
	else if (op=="LPTR"){
	    cout << "*" << result << " = " << arg1;
	   }
	else if (op=="RPTR"){
	    cout << result	<< " = *" << arg1;
	  }
	else if (op=="BCOMPL"){
	        cout << result << " = ~" << arg1;
	   }
	 else if (op=="UMINUS"){
	    cout << result << " = -" << arg1;
	   }
	else if (op=="NOTOP"){
	      cout << result << " = !" << arg1;
	   }
       //Printing Miscellaneous Operations
       else if (op=="FUNCTION"){
	      cout << result << ": ";
	  }
	else if (op=="ENDFUNC") {
		cout << " ";
	}
	else if (op=="RARR"){
	      cout << result << " = " << arg1 << "[" << arg2 << "]";
	  }
	else if (op=="LARR"){
	      cout << result << "[" << arg1 << "]" <<" = " <<  arg2;
	  }
	else if (op=="RETRN"){
	       cout << "return " << result;
	  }
	else if (op=="PARAM"){
	       cout << "param " << result;
	  }
	else if (op=="CALL"){
	      cout << result << " = " << "call " << arg1<< ", " << arg2;
	  }	
	//else {cout << "op";}
	cout << endl;
}

//This method prints the array of quads
void quad_array::print() 
{
        //Formatting
        int count=0;
	cout << setw(32) << setfill ('+') << "+"<< endl;
	cout << "|      TAC code Generation     |" << endl;
	cout << setw(32) << setfill ('+') << "+"<< setfill (' ') << endl;
	//iterating through the quad array implemented as vector
	for (vector<quad>::iterator it = array.begin(); it!=array.end(); it++) 
	{
		//If the operation is a function name then print the quad
		if (it->op == "FUNCTION") {
			cout << "\n";
			it->print();
			cout << "\n";
			++count;
		}
		else if (it->op == "ENDFUNC" || it->op == "STREQ" || it->op == "CHAREQ") {}
		//else print the quad
		else 
		{
			cout << "\t" << setw(4) << count << ":\t";
			it->print();
			++count;
		}
	}
	
	cout << setw(120) << setfill ('+') << "+"<< endl;
}

//constructor for the 'entry_type' class
entry_type::entry_type(string type, entry_type* ptr, int width): type (type), ptr (ptr), width (width) {};

//constructor for the 'sym_entry' class
sym_entry::sym_entry(string name, string t, entry_type* ptr, int width): name(name)  
{
	type = new entry_type (t, ptr, width);
	nested = NULL;
	initial_value = "";
	category = "";
	offset = 0;
	//allocating size
	size = size_alloc(type);
}

//This method updates the 'type' of entries in the symbol table, whenever necessary
sym_entry* sym_entry::update(entry_type* dtype) 
{
	type = dtype;
	this -> size = size_alloc(dtype);
	return this;
}

//A constructor for the 'sym_table' class with fields initialized
sym_table::sym_table (string name): name (name), count(0) {}

//This method looksup for the id and adds it to the symbol table if it doesn't exist
sym_entry* sym_table::lookup (string lexeme) 
{
	sym_entry* s;
	list <sym_entry>::iterator it; 
	for (it = curr_table.begin(); it!=curr_table.end(); it++) {if (it->name == lexeme ) break;}
	if (it!=curr_table.end() ) {return &*it;}
	//creates a new entry, if an id doesnt exist
	else 
	{
	   s =  new sym_entry(lexeme);
	   s -> category = "local";
	   curr_table.push_back (*s);
	   return &curr_table.back();
	}
}

void sym_table::update()
{
	list<sym_table*> list_of_tables;
	int h;
	//For each entry in the table
	for (list <sym_entry>::iterator it1 = curr_table.begin(); it1!=curr_table.end(); it1++) 
	{
		if (it1==curr_table.begin()) 
		{
			it1->offset = 0;
			h = it1->size;
		}
		else 
		{
			//adding the offset calculated
			it1->offset = h;
			//updating offset for next step
			h= (it1->offset) + (it1->size);
		}
		if (it1->nested!=NULL) list_of_tables.push_back (it1->nested);
	}
	//Recursive call for all the symbol tables
	for (list<sym_table*>::iterator it2 = list_of_tables.begin(); it2 != list_of_tables.end(); ++it2)  (*it2)->update();
}

//This method prints the symbol table
void sym_table::print() 
{
	list<sym_table*> list_of_tables;
	string table_name = this->name + "()";
	cout << setw(125) << setfill ('+') << "+"<< endl;
	cout << "ST . " << setfill (' ') << left << setw(50)  << table_name ;
	cout << right << setw(60) << "Parent: ";
	if (this->parent!=NULL)  cout << this -> parent->name ; 
	else cout << "null" ;
	cout << endl;
	cout << setw(125) << setfill ('~') << "~"<< endl;
	cout << setfill (' ') << left << setw(10) << "NAME";
	cout << left << setw(2)<<"|";
	cout << left << setw(20) << "TYPE";
	cout << left << setw(2)<<"|";
	cout << left << setw(10) << "CATEGORY";
	cout << left << setw(2)<<"|";
	cout << left << setw(40) << "INITIAL VALUE" ;
	cout << left << setw(2)<<"|";
	cout << left << setw(10) << "SIZE" ;
	cout << left << setw(2)<<"|";
	cout << left << setw(10) << "OFFSET";
	cout << left << setw(2)<<"|";
	cout << left << "NESTED TABLE" ;
	cout << endl;
	cout << setw(125) << setfill ('~') << "~"<< setfill (' ') << endl;
	for (list <sym_entry>::iterator it = curr_table.begin(); it!=curr_table.end(); it++) 
	{
	   string stype = print_type(it->type);
	   if(stype != "_")
	   {
	   cout << left << setw(10) << it->name;
	   cout << left << setw(2)<<"|";
	   cout << left << setw(20) <<  stype;
	   cout << left << setw(2)<<"|";
	   cout << left << setw(10) << it->category;
	   cout << left << setw(2)<<"|";
	   cout << left << setw(40) <<  it->initial_value;
	   cout << left << setw(2)<<"|";
	   cout << left << setw(10) << it->size;
	   cout << left << setw(2)<<"|";
	   cout << left << setw(10) << it->offset ;
	   cout << left << setw(2)<<"|";
	   cout << left;
	   
	   if (it->nested == NULL) {cout << "null" <<  endl;}	
	   else 
		{
			cout << it->nested->name << endl;
			list_of_tables.push_back (it->nested);
		}
	   }
	}
	cout << setw(125) << setfill ('~') << "~"<< setfill (' ') << endl;
	cout << endl;
for (list<sym_table*>::iterator it2 = list_of_tables.begin();it2 != list_of_tables.end(); ++it2)  (*it2)->print();		
}

//Global function definitions

/*Overloading the emit function, used for creating a quad from the fields and adds it to quad array*/
void emit(string op, string result, string arg1, string arg2) {q.array.push_back(*(new quad(result,arg1,op,arg2)));}

void emit(string op, string result, int arg1, string arg2) {q.array.push_back(*(new quad(result,arg1,op,arg2)));}

void emit(string op, string result, float arg1, string arg2) {q.array.push_back(*(new quad(result,arg1,op,arg2)));}

//changes the currently active table
void changeTable (sym_table* newtable) {curr_table = newtable;} 

//A functions that returns the next instruction number
int nextinstr() {return q.array.size();}

//This method emits the quad for the type conversion statements
sym_entry* conv (sym_entry* s, string t) 
{
	sym_entry* en = gentemp(new entry_type(t));
	if (s->type->type=="CHAR") {
		if (t=="INTEGER") {
		        //quad for char to int conversion
			emit ("EQ", en->name, "char2int(" + s->name + ")");
			return en;}
		if (t=="FLOAT") {
			//quad for char to float conversion 
			emit ("EQ", en->name, "char2float(" + s->name + ")");
			return en;}
		return s;
	}
	else if (s->type->type=="INTEGER" ) {
		if (t=="FLOAT") {
		        //quad for int to float conversion
			emit ("EQ", en->name, "int2float(" + s->name + ")");
			return en;}
		else if (t=="CHAR") {
		        //quad for int to char conversion
			emit ("EQ", en->name, "int2char(" + s->name + ")");
			return en;}
		return s;
	}
	else if (s->type->type=="FLOAT" ) {
		if (t=="INTEGER") {
			//quad for float to int conversion
			emit ("EQ", en->name, "float2int(" + s->name + ")");
			return en;}
		else if (t=="CHAR") {
		        //quad for float to char conversion
			emit ("EQ", en->name, "float2char(" + s->name + ")");
			return en;}
		return s;	
	}
	return s;
}

//makelist function for creating list of labels
list<int> makelist (int i) 
{
    list<int> new_l;
    new_l.push_back(i);
    return new_l;
}

//merges two lists containing labels
list<int> merge (list<int> &list1, list <int> &list2) 
{
    list<int> merged;
    merged.merge(list1);
    merged.merge(list2);
    return merged;
}

//A global type checking function for two 'sym_entry' objects
bool typecheck(sym_entry* &sy1, sym_entry* &sy2)
{ 	// Check if the symbols have same type or not
	entry_type* type1 = sy1->type;
	entry_type* type2 = sy2->type;
	if (typecheck (type1, type2)) {
	       return true;
	  }
	else if (sy1 = conv (sy1, type2->type)) {
	       return true;
	    }
	else if (sy2 = conv (sy2, type1->type)) {
	       return true;
	     }
	else return false;
}

//A global type checking function for two 'entry_type' objects
bool typecheck(entry_type* ty1, entry_type* ty2)
{ 	// Check if the symbol types are same or not
	if (ty1 != NULL || ty2 != NULL)
        {
		if (ty1==NULL) {
		    return false;
		  }
		if (ty2==NULL) {
		     return false;
		    }
		if (ty1->type==ty2->type) {
		     return typecheck(ty1->ptr, ty2->ptr);
		     }
		else return false;
	}
	return true;
}

/*A global function to insert i as the target label for each of the quads on the list pointed to by p.*/
void backpatch (list <int> p, int i) 
{
    stringstream st;
    st << i;
    string en_str = st.str();
    char* inttostr = (char*) en_str.c_str();
    string str = string(inttostr);
    for (list<int>::iterator it= p.begin(); it!=p.end(); it++) {q.array[*it].result = str;}
}

//type conversion from integer to boolean type
void convertInt2Bool (expr* e) 
{	// Convert any expression to bool
	if (e->type!="BOOL") 
        {
		e->FL = makelist (nextinstr());
		emit ("EQOP", "", e->loc->name, "0");
		e->TL = makelist (nextinstr());
		emit ("GOTOOP", "");
	}
	else return;
}

//type conversion from boolean to integer type
void convertBool2Int (expr* exp) 
{	// Convert any expression to int
	if (exp->type=="BOOL") {
		exp->loc = gentemp(new entry_type("INTEGER"));
		backpatch (exp->TL, nextinstr());
		emit ("EQ", exp->loc->name, "true");
		stringstream chararr;
	        chararr << nextinstr()+1;
	        string en_str = chararr.str();
	        
	       //Convert int into an array of characters
	        char* int_to_str = (char*) en_str.c_str();
		string str = string(int_to_str);
		emit ("GOTOOP", str);
		backpatch (exp->FL, nextinstr());
		emit ("EQ", exp->loc->name, "false");
	}
	else return;
}

//Generates a new enorary variable
sym_entry* gentemp(entry_type* ty, string init_val) 
{
	char en[10];
	sprintf(en, "t%02d", curr_table->count++);
	sym_entry* s1 = new sym_entry (en);
	s1->type = ty;
	s1->size=size_alloc(ty);
	s1-> initial_value = init_val;
	s1-> category = "temp";
	curr_table->curr_table.push_back(*s1);
	return &(curr_table->curr_table.back());
}

//Allocates size as per requirement
int size_alloc (entry_type* dtype)
{
	if(dtype->type=="VOID") 
	      return 0;
	else if(dtype->type=="ARR") 
	       return dtype->width * size_alloc (dtype->ptr);
	else if(dtype->type=="CHAR") 
	      return size_of_char;
	else if(dtype->type=="FLOAT") 
	       return  size_of_float;
	else if(dtype->type=="PTR") 
	      return size_of_ptr;
	else if(dtype->type=="INTEGER")
	       return size_of_int;
	else if(dtype->type=="FUNCTION") return 0;
	else return 0;
}

//prints the type of an entry, given its entry_type
string print_type (entry_type* t)
{
	if (t==NULL) 
	     return "null";
	else if(t->type=="INTEGER") 
	      return "int";
	else if(t->type=="CHAR")
	      return "char";
	else if(t->type=="PTR" && t->ptr != NULL) 
	      return print_type(t->ptr)+"*";
	else if(t->type=="FUNCTION") 
	      return "function";
	else if(t->type=="FLOAT") 
	      return "float";
	else if(t->type=="ARR") 
	{
	   stringstream stream;
	   stream << t->width;
           string en_str = stream.str();
           char* int_str = (char*) en_str.c_str();
	   string str = string(int_str);
	   return "arr(" + str + ", "+ print_type (t->ptr) + ")";
	}
	else if(t->type=="VOID")
	     return "void";
	else return "_" ;
}
