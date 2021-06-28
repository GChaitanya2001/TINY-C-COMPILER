%{
#include <stdio.h>
#include <iostream>
#include <cstdlib>
#include <string>
#include <sstream>
#include "ass6_18CS30018_translator.h"
#include <bits/stdc++.h>

extern int yylex();
extern int yylineno;
void yyerror(string s);
extern string curr_type;
vector <string> str_all;

using namespace std;

%}
%union {
  int intval;
  char* charval;
  char unary_op;
  int instr;
  sym_entry* symp;
  entry_type* symtp;
  expr* E;
  statement* S;
  arr* A;
} 
//KeyWord Tokens
%token BREAK
%token CASE
%token CHAR
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE 
%token ELSE
%token EXTERN
%token FLOAT
%token FOR
%token GOTO
%token IF
%token INT
%token LONG
%token RETURN
%token SHORT
%token SIZEOF
%token STATIC
%token SWITCH
%token VOID
%token WHILE
%token CONST
%token RESTRICT
%token VOLATILE
%token INLINE

//constant tokens
%token<intval> INT_CONST
%token<charval> FLOAT_CONST
%token<charval> CHAR_CONST

//String Literal token
%token<charval> STR_LITERAL

//Identifier token
%token<symp> ID

//Punctuators tokens
%token SQ_LBRACE
%token SQ_RBRACE
%token RO_LBRACE
%token RO_RBRACE
%token FL_LBRACE
%token FL_RBRACE
%token DOT
%token MEM_OP
%token INCREMENT_OP
%token DECREMENT_OP
%token BIT_AND
%token MULT_OP
%token ADD_OP
%token MINUS_OP
%token BIT_COMPL
%token NOT_OP
%token DIV_OP
%token REM
%token L_SHIFT
%token R_SHIFT
%token LT
%token GT
%token LT_EQ
%token GT_EQ
%token EQ
%token NEQ
%token BIT_XOR
%token BIT_OR
%token LOGIC_AND
%token LOGIC_OR
%token QUERY
%token COLON
%token SEMI_COLON
%token VAR_ARG_LIST
%token ASSIGN
%token MULT_ASGN
%token DIV_ASGN
%token REM_ASGN
%token ADD_ASGN
%token MINUS_ASGN
%token LS_ASGN
%token RS_ASGN
%token BIT_AND_ASGN
%token BIT_XOR_ASGN
%token BIT_OR_ASGN
%token COMMA
%token HASH

//start non-terminal symbol
%start translation_unit

//To prevent Dangling-Else ambiguity
%right THEN ELSE

//Non-terminals for expressions
%type <E> expression
%type <E> primary_expression 
%type <E> multiplicative_expression
%type <E> additive_expression
%type <E> shift_expression
%type <E> relational_expression
%type <E> equality_expression
%type <E> AND_expression
%type <E> exclusive_OR_expression
%type <E> inclusive_OR_expression
%type <E> logical_AND_expression
%type <E> logical_OR_expression
%type <E> conditional_expression
%type <E> assignment_expression
%type <E> expression_statement
%type <E> function_definition
	
%type <intval> argument_expression_list

%type <A> postfix_expression
%type <A> unary_expression
%type <A> cast_expression

%type <unary_op> unary_operator
%type <symp> constant initializer
%type <symp> direct_declarator init_declarator declarator
%type <symtp> pointer
	
//Auxillary non terminals M and N
%type <instr> M
%type <S> N

//Statements
%type <S> statement
%type <S> labeled_statement 
%type <S> compound_statement
%type <S> selection_statement
%type <S> iteration_statement
%type <S> jump_statement
%type <S> block_item
%type <S> block_item_list

%%

M :
	{	
	   //Marker Rule for backpatching
	   $$ = nextinstr();
	}
	;


N : 
	{ 	
	    //Fall-through Guard Rule for backpatching 
	    $$  = new statement();
	    $$->NL = makelist(nextinstr());
	    emit ("GOTOOP","");
	}
	;

	
CT :
	{ 	 
	  /*A rule used while shifting from a symbol table to its nested symbol table*/	       								
		if (curr_symbol->nested==NULL) changeTable(new sym_table(""));	
		else 
		{
			changeTable (curr_symbol ->nested);						
			emit ("FUNCTION", curr_table->name);
		}
	}
	;	

primary_expression : ID
		       {
		          //Action for identifier
			  $$ = new expr();
			  $$->loc = $1;
			  $$->type = "NONBOOL";
		       }
		    | constant
		       {
		          //Primary Action fro constants
			  $$ = new expr();
			  $$->loc = $1;
		       }
		    | STR_LITERAL
		       {
		          //Action for string lieral which is converted into a char pointer
			  $$ = new expr();
			  entry_type* tmp = new entry_type("PTR");
			  $$->loc = gentemp(tmp, $1);
			  $$->loc->type->ptr = new entry_type("CHAR");
			  
			  str_all.push_back($1);
			  stringstream strs;
			  strs << str_all.size()-1;
			  string temp_str = strs.str();
			  char* intStr = (char*) temp_str.c_str();
			  string str = string(intStr);
			  emit("STREQ", $$->loc->name, str);
		       }
		    | RO_LBRACE expression RO_RBRACE
		       {
			  $$ = $2;
		       }
		    ;	 

constant
	: INT_CONST
	 {
	    //Integer is converted into a stream of characters
	    stringstream str_st;
	    str_st << $1;
	    string temp_str = str_st.str();
	    char* int_str = (char*) temp_str.c_str();
	    string str = string(int_str);
	    $$ = gentemp(new entry_type("INTEGER"), str);
	    emit("EQ", $$->name, $1);
	}
	| FLOAT_CONST
	 {
	     /*Action for float constants: generating a temp and emit the quad*/
	     $$ = gentemp(new entry_type("FLOAT"), string($1));
	     emit("EQ", $$->name, string($1));
	 }
	| CHAR_CONST
	 {
	     /*Actions for character constants: generating a temp and emit the quad*/
	    $$ = gentemp(new entry_type("CHAR"),$1);
	    emit("CHAREQ", $$->name, string($1));
	 }
	;

postfix_expression
		   : primary_expression
		     {
		        //creating a array type struct and initializing fields
		   	$$ = new arr();
			$$->array = $1->loc;
			$$->loc = $$->array;
			$$->type = $1->loc->type;
		     }
		   | postfix_expression SQ_LBRACE expression SQ_RBRACE
		   	{
		   		$$ = new arr();
				$$->array = $1->loc; // copy the base
				$$->type = $1->type->ptr;  // type = type of element
				$$->loc = gentemp(new entry_type("INTEGER"));	// store computed address
				// New address =(if only) already computed address+ ($3 * new width)
				if ($1->cat=="ARR")
				{
				    sym_entry* t = gentemp(new entry_type("INTEGER"));
				    stringstream strs;
				    strs << size_alloc($$->type);
				    string temp_str = strs.str();
				    char* int_str = (char*) temp_str.c_str();
				    string str = string(int_str);				
		 		    emit ("MULT", t->name, $3->loc->name, str);
				    emit ("ADD", $$->loc->name, $1->loc->name, t->name);
				}
		 		else 
		 		{
		 		    stringstream strs;
				    strs <<size_alloc($$->type);
				    string temp_str = strs.str();
				    char* int_str_temp = (char*) temp_str.c_str();
				    string str1 = string(int_str_temp);		
			 	    emit("MULT", $$->loc->name, $3->loc->name, str1);
		 		}
				$$->cat = "ARR";
		   	}
		   | postfix_expression RO_LBRACE RO_RBRACE 
		      {
			//no action yet
		      }
		   | postfix_expression RO_LBRACE argument_expression_list RO_RBRACE
		        {
		            $$ = new arr();
			    $$->array = gentemp($1->type);
			    stringstream strs;
			    strs << $3;
			    string temp_str = strs.str();
			    char* inttostr = (char*) temp_str.c_str();
			    string str = string(inttostr);		
			    emit("CALL", $$->array->name, $1->array->name, str);
		        }
		   | postfix_expression DOT ID
		        { /*no action yet*/}
		   | postfix_expression MEM_OP ID
		   	 { /*no action yet*/}
		   | postfix_expression INCREMENT_OP
		   	 {
		   	     $$ = new arr();
			     // copy $1 to $$ and emit
			     $$->array = gentemp($1->array->type);
			     emit("EQ", $$->array->name, $1->array->name);
			     // emit quad for increment operation
			     emit ("ADD", $1->array->name, $1->array->name, "1");
		   	 }
		   | postfix_expression DECREMENT_OP
		        {
		             $$ = new arr();
			      // copy $1 to $$
			     $$->array = gentemp($1->array->type);
			     emit ("EQ", $$->array->name, $1->array->name);
			      // emit quad for decrement operation
			     emit ("SUB", $1->array->name, $1->array->name, "1");
		        }
		   | RO_LBRACE type_name RO_RBRACE FL_LBRACE initializer_list FL_RBRACE
		   	 {
		   	 	//Actions for expressions containing initiliazer list
		   	       $$ = new arr();
		               $$->array = gentemp(new entry_type("INTEGER"));
			       $$->loc = gentemp(new entry_type("INTEGER"));
		   	 }
		   | RO_LBRACE type_name RO_RBRACE FL_LBRACE initializer_list COMMA FL_RBRACE
		         {
		              //Actions for comma separted expressions containing initiliazer list
			    	$$ = new arr();
				$$->array = gentemp(new entry_type("INTEGER"));
				$$->loc = gentemp(new entry_type("INTEGER"));
		         }
		   ;
			       
argument_expression_list 
	                 : assignment_expression
	                    {
	                       //emits a parameters required during function call
	                       emit ("PARAM", $1->loc->name);
				$$ = 1;
	                    }
	                 | argument_expression_list COMMA assignment_expression
	                    {
	                       //emits a comma sepearted parameters list required during function call
	                       emit ("PARAM", $3->loc->name);
			       $$ = $1+1;
	                    }
	                 ;
	
		                
unary_expression 
		 : postfix_expression
		    {
		  	$$ = $1;	
		    }
		 | INCREMENT_OP unary_expression
		    {
		    	//emit TAC for the expression
			emit ("ADD", $2->array->name, $2->array->name, "1");
			// Action
			$$ = $2;
		    }
		 | DECREMENT_OP unary_expression
		    {
		    	//emit TAC for the expression
			emit ("SUB", $2->array->name, $2->array->name, "1");
			// Action
			$$ = $2;
		    }
		 | unary_operator cast_expression
		    {
		    	 //Check and emit the quads for each case
		    	    $$ = new arr();
		    	    switch($1)
		    	    {
			    case '&':{
					$$->array = gentemp((new entry_type("PTR")));
					$$->array->type->ptr = $2->array->type; 
					emit ("AMP", $$->array->name, $2->array->name);
					break;
				}
			    case '*':{
					$$->cat = "PTR";
					$$->loc = gentemp ($2->array->type->ptr);
					emit ("RPTR", $$->loc->name, $2->array->name);
					$$->array = $2->array;
					break;
			        }
			   case '+':{
					$$ = $2;
					break;
				}
			   case '-':{
					$$->array = gentemp(new entry_type($2->array->type->type));
					emit ("UMINUS", $$->array->name, $2->array->name);
					break;
				}
			    case '~':{
					$$->array = gentemp(new entry_type($2->array->type->type));
					emit ("BCOMPL", $$->array->name, $2->array->name);
					break;
				}
			    case '!':{
					$$->array = gentemp(new entry_type($2->array->type->type));
					emit ("NOTOP", $$->array->name, $2->array->name);
					break;
				}
			   default: break;
			 }
			
		    }
		 | SIZEOF unary_expression
		   {
		   	/*no action yet*/
		   }
		 | SIZEOF RO_LBRACE type_name RO_RBRACE
		   {
		  	/*no action yet*/
		   }
		 ;
		 
unary_operator
		: BIT_AND
		  {$$ = '&';}
		| MULT_OP
		  {$$ = '*';}
		| ADD_OP
		  {$$ = '+';}
		| MINUS_OP
		  {$$ = '-';}
		| BIT_COMPL
		  {$$ = '~';}
		| NOT_OP
		  {$$ = '!';}
		;
		
cast_expression
		: unary_expression
		    {
		       $$=$1;
		    }
		| RO_LBRACE type_name RO_RBRACE cast_expression
		    {
		        //to be added later
			$$=$4;
		    }
		;
	
multiplicative_expression
      : cast_expression
        {
      	    $$ = new expr();
	    if ($1->cat=="ARR") 
	    { // Array
		$$->loc = gentemp($1->loc->type);
		emit("RARR", $$->loc->name, $1->array->name, $1->loc->name);
            }
            else if ($1->cat=="PTR") 
            { // Pointer
		$$->loc = $1->loc;
	    }
	    else 
	    { // otherwise
		$$->loc = $1->array;
	    }
        }
      | multiplicative_expression MULT_OP cast_expression
        {
          /*Type check the values of both operand expressions if same, generate a new temp variable and emit the quad*/
           if (typecheck ($1->loc, $3->array) )
             {
		$$ = new expr();
		$$->loc = gentemp(new entry_type($1->loc->type->type));
		emit ("MULT", $$->loc->name, $1->loc->name, $3->array->name);
	     }
	   else cout << "Operand expressions have different types."<< endl;
        }
      | multiplicative_expression DIV_OP cast_expression
        {
          /*Type check the values of both operand expressions if same, generate a new temp variable and emit the quad*/
     	   if (typecheck ($1->loc, $3->array) ) 
     	     {
			$$ = new expr();
			$$->loc = gentemp(new entry_type($1->loc->type->type));
			emit ("DIV", $$->loc->name, $1->loc->name, $3->array->name);
	     }
	   else cout << "Operand expressions have different types."<< endl;
        }
      | multiplicative_expression REM cast_expression
        {
          /*Type check the values of both operand expressions if same, generate a new temp variable and emit the quad*/
          if (typecheck ($1->loc, $3->array) ) 
            {
			$$ = new expr();
			$$->loc = gentemp(new entry_type($1->loc->type->type));
			emit ("REMOP", $$->loc->name, $1->loc->name, $3->array->name);
	    }
	  else cout << "Operand expressions have different types."<< endl;
        }
      ;
			  
additive_expression 
	: multiplicative_expression
	  {
	    $$ = $1;
	  }
	| additive_expression ADD_OP multiplicative_expression
      	  {
      	    /*Type check the values of both operand expressions if same, generate a new temp variable and emit the quad*/
      	    if (typecheck($1->loc, $3->loc)) 
      	      {
			$$ = new expr();
			$$->loc = gentemp(new entry_type($1->loc->type->type));
			emit ("ADD", $$->loc->name, $1->loc->name, $3->loc->name);
	      }
	    else cout << "Operand expressions have different types."<< endl;
      	  }
	| additive_expression MINUS_OP multiplicative_expression
	  {
	    /*Type check the values of both operand expressions if same, generate a new temp variable and emit the quad*/
	    if (typecheck($1->loc, $3->loc)) 
	    {
			$$ = new expr();
			$$->loc = gentemp(new entry_type($1->loc->type->type));
			emit ("SUB", $$->loc->name, $1->loc->name, $3->loc->name);
	    }
	    else cout << "Operand expressions have different types."<< endl;
	  }
	;
		     
shift_expression 
		  : additive_expression
		     {
		  	$$ = $1;
		     }
		  | shift_expression L_SHIFT additive_expression
		     {
		 /*Type check the values of both operand expressions if int, generate a new temp variable and emit the quad*/
		     	if ($3->loc->type->type == "INTEGER") 
		     	{
				$$ = new expr();
				$$->loc = gentemp (new entry_type("INTEGER"));
				emit ("LEFTOP", $$->loc->name, $1->loc->name, $3->loc->name);
			}
			else cout << "Operand expressions have different types."<< endl;
		     }
		  | shift_expression R_SHIFT additive_expression
		     {
	/*Type check the values of both operand expressions if int, generate a new temp variable and emit the quad*/     
		       if ($3->loc->type->type == "INTEGER") 
		       {
				$$ = new expr();
				$$->loc = gentemp (new entry_type("INTEGER"));
				emit ("RIGHTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		       }
			else cout << "Operand expressions have different types."<< endl;
		     }
		  ;
		  
relational_expression
		 : shift_expression
		    {
		    	$$ = $1;
		    }
		 | relational_expression LT shift_expression
		    {
          /*Type check the values of both operand expressions if same,create TL and FL of expression and emit the quad*/
		      if (typecheck ($1->loc, $3->loc) ) 
		      {
				$$ = new expr();
				$$->type = "BOOL";
				$$->TL = makelist (nextinstr());
				$$->FL = makelist (nextinstr()+1);
				emit("LT", "", $1->loc->name, $3->loc->name);
				emit ("GOTOOP", "");
		      }
		      else cout << "Operand expressions have different types."<< endl;
		    }
		 | relational_expression GT shift_expression
		    {
         /*Type check the values of both operand expressions if same,create TL and FL of expression and emit the quad*/
		      if (typecheck ($1->loc, $3->loc) ) 
		       {
				$$ = new expr();
				$$->type = "BOOL";
				$$->TL = makelist (nextinstr());
				$$->FL = makelist (nextinstr()+1);
				emit("GTE", "", $1->loc->name, $3->loc->name);
				emit ("GOTOOP", "");
			}
		      else cout << "Operand expressions have different types."<< endl;
		    }
		 | relational_expression LT_EQ shift_expression
		    {
	  /*Type check the values of both operand expressions if same,create TL and FL of expression and emit the quad*/
		      if (typecheck ($1->loc, $3->loc) ) 
		      {
				$$ = new expr();
				$$->type = "BOOL";
				$$->TL = makelist (nextinstr());
				$$->FL = makelist (nextinstr()+1);
				emit("LTE", "", $1->loc->name, $3->loc->name);
				emit ("GOTOOP", "");
		       }
			else cout << "Operand expressions have different types."<< endl;
		    }
		 | relational_expression GT_EQ shift_expression
		   {
        /*Type check the values of both operand expressions if same,create TL and FL of expression and emit the quad*/
		      if (typecheck ($1->loc, $3->loc) ) 
		      {
				$$ = new expr();
				$$->type = "BOOL";
				$$->TL = makelist (nextinstr());
				$$->FL = makelist (nextinstr()+1);
				emit("GTE", "", $1->loc->name, $3->loc->name);
				emit ("GOTOOP", "");
		      }
		      else cout << "Operand expressions have different types."<< endl;
		   }
		 ;
		     
equality_expression
		: relational_expression
		  {
		    $$ = $1;
		  }
		| equality_expression EQ relational_expression
		  {
		    if (typecheck ($1->loc, $3->loc)) 
		      {
		        //type conversion from bool to int
			convertBool2Int ($1);
			convertBool2Int ($3);
			$$ = new expr();
			$$->type = "BOOL";
			//update TL and FL of the expression
			$$->TL = makelist (nextinstr());
			$$->FL = makelist (nextinstr()+1);
			//emit quads
			emit("EQOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		      }
		      else cout << "Operand expressions have different types."<< endl;
		  }
		| equality_expression NEQ relational_expression
		  {
		    if (typecheck ($1->loc, $3->loc) ) 
		     {
		       //type conversion from bool to int 
			convertBool2Int ($1);
			convertBool2Int ($3);
			$$ = new expr();
			$$->type = "BOOL";
			//update TL and FL of the expression
			$$->TL = makelist (nextinstr());
			$$->FL = makelist (nextinstr()+1);
			//emit quads
			emit("NEOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		      }
		     else cout << "Operand expressions have different types."<< endl;
		  }
		;
		    
AND_expression
		: equality_expression
		  {
		     $$ = $1;
		  }
		| AND_expression BIT_AND equality_expression
		  {
		     if (typecheck ($1->loc, $3->loc) ) 
		     {
			// type conversion from bool to int
			convertBool2Int ($1);
			convertBool2Int ($3);
			$$ = new expr();
			$$->type = "NONBOOL";
			//Generate temp
			$$->loc = gentemp (new entry_type("INTEGER"));
			//emit quad
			emit ("BITAND", $$->loc->name, $1->loc->name, $3->loc->name);
		     }
		     else cout << "Operand expressions have different types."<< endl;
		  }
		;
		
exclusive_OR_expression
	   : AND_expression
	     {
	       $$ = $1;
	     }
	   | exclusive_OR_expression BIT_XOR AND_expression
	     {
	       if (typecheck ($1->loc, $3->loc)) 
	       {
		    // type conversion from bool to int
		     convertBool2Int ($1);
		     convertBool2Int ($3);
		     $$ = new expr();
		     $$->type = "NONBOOL";
		     //generate temp
		     $$->loc = gentemp (new entry_type("INTEGER"));
		     //emit quad
		     emit ("XOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Operand expressions have different types."<< endl;
	     }
	   ;
			 		     
inclusive_OR_expression
      : exclusive_OR_expression
         {
            $$ = $1;
         }
      | inclusive_OR_expression BIT_OR exclusive_OR_expression
         {
            if (typecheck ($1->loc, $3->loc) ) 
            {
		// type conversion from bool to int
		convertBool2Int ($1);
		convertBool2Int ($3);
		$$ = new expr();
		$$->type = "NONBOOL";
		$$->loc = gentemp (new entry_type("INTEGER"));
		emit ("INCLOR", $$->loc->name, $1->loc->name, $3->loc->name);
	    }
	    else cout << "Operand expressions have different types."<< endl;
         }
      ;

			
logical_AND_expression
      : inclusive_OR_expression
        {
            $$ = $1;
        }
      | logical_AND_expression N LOGIC_AND M inclusive_OR_expression
        {
                convertInt2Bool($5);
		//backpatch NL of  N
		backpatch($2->NL, nextinstr());
		//convert $1 to bool
		convertInt2Bool($1);
		$$ = new expr();
		$$->type = "BOOL";
		//backpatch $1 using M
		backpatch($1->TL, $4);
		$$->TL = $5->TL;
		$$->FL = merge ($1->FL, $5->FL);  
        }
      ;
			
logical_OR_expression
	: logical_AND_expression
	  {
	    $$ = $1;
	  }
	| logical_OR_expression N LOGIC_OR M logical_AND_expression
	  {
	        convertInt2Bool($5);
		// convert $1 to bool and backpatch using N
		backpatch($2->NL, nextinstr());
		convertInt2Bool($1);
		$$ = new expr();
		$$->type = "BOOL";
		//backpatch $$ using M
		backpatch ($$->FL, $4);
		$$->TL = merge ($1->TL, $5->TL);
		$$->FL = $5->FL;
	  }
	;
			
conditional_expression
	: logical_OR_expression
	  {
	     $$ = $1;  
	  }
	| logical_OR_expression N QUERY M expression N COLON M conditional_expression
          {
               $$->loc = gentemp($5->loc->type);
		$$->loc->update($5->loc->type);
		emit("EQ", $$->loc->name, $9->loc->name);
		list<int> l = makelist(nextinstr());
		emit ("GOTOOP", "");
		backpatch($6->NL, nextinstr());
		emit("EQ", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextinstr());
		l = merge (l, m);
		emit ("GOTOOP", "");
		backpatch($2->NL, nextinstr());
		convertInt2Bool($1);
		backpatch ($1->TL, $4);
		backpatch ($1->FL, $8);
		backpatch (l, nextinstr());
          }
	;
		
assignment_expression
	: conditional_expression
	  {
	    $$ = $1;
	  }
	| unary_expression assignment_operator assignment_expression
          {
               if($1->cat=="ARR") 
               {
			$3->loc = conv($3->loc, $1->type->type);
			emit("LARR", $1->array->name, $1->array->name, $3->loc->name);	
        	}
		else if($1->cat=="PTR") 
		{
			emit("LPTR", $1->array->name, $3->loc->name);	
		}
		else
		{
			$3->loc = conv($3->loc, $1->array->type->type);
			emit("EQ", $1->array->name, $3->loc->name);
		}
		$$ = $3;
          }
	;
			
assignment_operator
		  	: ASSIGN
		  	  {
		  	     //no action yet
		  	  }
		  	| MULT_ASGN
		  	  {
		  	    //no action yet
		  	  }
		  	| DIV_ASGN
		  	  {
		  	    //no action yet
		  	  }
		  	| REM_ASGN
		  	  {
		  	    //no action yet
		  	  }
			| ADD_ASGN
			  {
			    //no action yet
			  }
			| MINUS_ASGN
			  {
			    //no action yet
			  }
			| LS_ASGN
			  {
			    //no action yet
			  }
			| RS_ASGN
			  {
			     //no action yet
			  }
			| BIT_AND_ASGN
			  {
			    //no action yet
			  }
			| BIT_XOR_ASGN
			  {
			    //no action yet
			  }
			| BIT_OR_ASGN
			  {
			     //no action yet
			  }
			;
			
expression
	     : assignment_expression 
	      {
	         $$ = $1;
	      }
	     | expression COMMA assignment_expression
	      {
	        //no action yet
	      }
	     ;
	     
constant_expression
		    : conditional_expression
		    {
		      //no action yet
		    }
		    ; 


declaration
	      : declaration_specifiers init_declarator_list_opt SEMI_COLON
	        {
	           //no action yet
	        }
	      ;

init_declarator_list_opt
			: 
			| init_declarator_list
			;

declaration_specifiers_opt
	: 
	| declaration_specifiers
	;

declaration_specifiers
   :storage_class_specifier declaration_specifiers_opt
    {
      //no action yet
    }
   |type_specifier declaration_specifiers_opt
    {
        //no action yet
    }
   |type_qualifier declaration_specifiers_opt
    {
      //no action yet
    }
   |function_specifier declaration_specifiers_opt
    {
       //no action yet
    }
   ;	
		   
init_declarator_list
		: init_declarator
		{
		   //no action yet
		}
		| init_declarator_list COMMA init_declarator
		{
		    //no action yet
		}
		;
			
init_declarator 
		: declarator
		 {
		   $$ = $1;
		 }
		| declarator ASSIGN initializer
		 {
		   if ($3->initial_value != "") $1->initial_value = $3->initial_value;
		   emit ("EQ", $1->name, $3->name);
		 }
		;
		
storage_class_specifier
			: EXTERN
			 {
			   //no action yet
			 }
			| STATIC
			 {
			   //no action yet
			 }
			;
			
type_specifier
		: VOID
		  {
		    curr_type = "VOID"; 
		  }
		| CHAR
		  {
		    curr_type = "CHAR";
		  }
		| SHORT
		  {
		    //no action yet
		  }
		| INT
		  {
		    curr_type = "INTEGER";
		  }
		| LONG
		  {
		    //no action yet
		  }
		| FLOAT
		  {
		     curr_type = "FLOAT";
		  }
		| DOUBLE
		;

specifier_qualifier_list_opt
				: specifier_qualifier_list
				|
				;
		
specifier_qualifier_list
	: type_specifier specifier_qualifier_list_opt
	{
	  //no action yet
	}
	| type_qualifier specifier_qualifier_list_opt
	{
	  //no action yet
	}
	;
			
				
type_qualifier
		: CONST
		{
		  //no action yet
		}
		| RESTRICT
		{
		  //no action yet
		}
		| VOLATILE
		{
		  //no action yet
		}
		;
		
function_specifier
		    : INLINE
		      {
		       //no action yet
		      }
		    ;
	    		    
declarator
	  : pointer direct_declarator 
	      {
		entry_type * t = $1;
		while (t->ptr !=NULL) t = t->ptr;
		t->ptr = $2->type;
		$$ = $2->update($1);
	      }
	 | direct_declarator
	      {
		//no action yet
              }
	 ;	  
	    
type_qualifier_list_opt 
			   : type_qualifier_list
			   |
			   ;
	    
direct_declarator
		  : ID
		    {
		       $$ = $1->update(new entry_type(curr_type));
		       curr_symbol = $$;
		    }
		  | RO_LBRACE declarator RO_RBRACE
		    {
		       $$ = $2;
		    }
		  | direct_declarator SQ_LBRACE type_qualifier_list assignment_expression SQ_RBRACE
		    {
		        //no action yet
		    }
		  | direct_declarator SQ_LBRACE type_qualifier_list SQ_RBRACE
		    {
		        //no action yet
		    }
		  | direct_declarator SQ_LBRACE assignment_expression SQ_RBRACE
		    {
		        entry_type *t = $1 -> type;
			entry_type *prev = NULL;
			while (t->type == "ARR") 
			{
				prev = t;
				t = t->ptr;
			}
			if (prev==NULL)
			{
				int temp = atoi($3->loc->initial_value.c_str());
				entry_type* s = new entry_type("ARR", $1->type, temp);
				$$ = $1->update(s);
			}
			else 
			{
				prev->ptr =  new entry_type("ARR", t, atoi($3->loc->initial_value.c_str()));
				$$ = $1->update ($1->type);
			}
		    }
		  | direct_declarator SQ_LBRACE SQ_RBRACE
		    {
		        entry_type *t = $1 -> type;
			entry_type *prev = NULL;
			while (t->type == "ARR") {
				prev = t;
				t = t->ptr;
			}
			if (prev==NULL) {
				entry_type* s = new entry_type("ARR", $1->type, 0);
				$$ = $1->update(s);
			}
			else {
				prev->ptr =  new entry_type("ARR", t, 0);
				$$ = $1->update ($1->type);
			}
		    }
		  | direct_declarator SQ_LBRACE STATIC type_qualifier_list_opt assignment_expression SQ_RBRACE
		    {
		       //no action yet   
		    }
		  | direct_declarator SQ_LBRACE type_qualifier_list MULT_OP SQ_RBRACE
		    {
		       //no action yet
		    }
		  |direct_declarator SQ_LBRACE MULT_OP SQ_RBRACE
		    {
		       //no action yet
		    }
		  | direct_declarator RO_LBRACE CT parameter_type_list RO_RBRACE
		    {
		        curr_table->name = $1->name;
		        if ($1->type->type !="VOID") 
		        {
				sym_entry *s = curr_table->lookup("return");
				s->update($1->type);		
		        }
			$1->nested=curr_table;
			$1->category="function";
			$1->size = 0;
			curr_table->parent = glb_table;
			// Come back to global symbol table
			changeTable (glb_table); 
			curr_symbol = $$;
		    }
		  | direct_declarator RO_LBRACE identifier_list RO_RBRACE
		    {
		       //no action yet
		    }
		  | direct_declarator RO_LBRACE CT RO_RBRACE
		    {
		        curr_table->name = $1->name;
		        if ($1->type->type !="VOID") 
		        {
				sym_entry *s = curr_table->lookup("return");
				s->update($1->type);		
			}
			$1->nested=curr_table;
			$1->category = "function";
			$1->size = 0;
			curr_table->parent = glb_table;
			// Come back to global symbol table
			changeTable (glb_table);   
			curr_symbol = $$;
		    }
		  ;
		  
pointer
	 : MULT_OP type_qualifier_list
	   {
	       //no action yet
	   }
	 | MULT_OP
	   {
	       $$ = new entry_type("PTR");
	   }
	 | MULT_OP type_qualifier_list pointer
	   {
	       //no action yet
	   }
	 | MULT_OP pointer
	   {
	      $$ = new entry_type("PTR", $2);
	   }
	 ;
	 
type_qualifier_list
		    : type_qualifier
		      {
		          //no action yet
		      }
		    | type_qualifier_list type_qualifier
		      {
		        //no action yet
		      }
		    ;
		    
parameter_type_list
		    : parameter_list
		      {
		         //no action yet
		      }
		    | parameter_list COMMA VAR_ARG_LIST
		      {
		         //no action yet
		      }
		    ;
		 
parameter_list
		: parameter_declaration
		 {
		    //no action yet
		 }
		| parameter_list COMMA parameter_declaration
		 {
		    //no action yet
		 }
		;
		
parameter_declaration
			: declaration_specifiers declarator
			  {
			     $2 -> category = "param";
			  }
			| declaration_specifiers
			  {
			     //no action yet
			  }
			;
			
identifier_list
		: ID
		  {
		     //no action yet
		  }
		| identifier_list COMMA ID
		   {
		      //no action yet
		   }
		;
		
type_name
	   : specifier_qualifier_list 
	      {
	         //no action yet
	      }
	   ;
	   
initializer
	   : assignment_expression
	    {
	        $$ = $1->loc;
	    }
	   | FL_LBRACE initializer_list FL_RBRACE
	    {
	       //no action yet
	    }
	   | FL_LBRACE initializer_list COMMA FL_RBRACE
	     {
	        //no action yet
	     }
	   ;

designation_opt
		: designation
		|
		;
	    		  
initializer_list
		 : designation_opt  initializer
		   {
		     //no action yet
		   }
		 | initializer_list COMMA designation_opt initializer
		   {
		     //no action yet
		   }
		 ;
		
designation
		: designator_list ASSIGN
		   {
		 	//no action yet
		   }
		;
		
designator_list
		: designator
		   {
		 	//no action yet
		   }
		| designator_list designator
		   {
		 	//no action yet
		   }
		;
		
designator
	    : SQ_LBRACE constant_expression SQ_RBRACE
	           {
		 	//no action yet
		   }
	    | DOT ID
	      {
	 	//no action yet
	      }
	    ;
	     
			   
statement
	   : labeled_statement
	      {
	        //no action yet
	      }
	   | compound_statement
	      {
	        $$ = $1;
	      }
	   | expression_statement
	      {
	         $$ = new statement();
		 $$->NL = $1->NL;
	      }
	   | selection_statement
	       {
	         $$ = $1;
	       }
	   | iteration_statement
	       {
	         $$ = $1;
	       }
	   | jump_statement
	       {
	         $$ = $1;
	       }
	   ;
	   
labeled_statement
		   : ID COLON statement
		     {
		       $$ = new statement();
		     }
		   | CASE constant_expression COLON statement
		     {
		       $$ = new statement();
		     }
		   | DEFAULT COLON statement
		     {
		       $$ = new statement();
		     }
		   ;
		   
compound_statement
		    : FL_LBRACE block_item_list FL_RBRACE
		     {
		       $$ = $2;
		     }
		    | FL_LBRACE FL_RBRACE
		     {
		       $$ = new statement();
		     }
		    ;
		    
block_item_list
		: block_item
		  {
		    $$ = $1;
		  }
		| block_item_list M block_item
		  {
		    $$=$3;
		    backpatch ($1->NL, $2);
		  }
		;
		
block_item
	    : declaration
	       {
	         $$ = new statement();
	       }
	    | statement 
	       {
	         $$ = $1;
	       }
	    ;

expression_opt
		  : expression
		  |
		  ;
		   
expression_statement
		     : expression SEMI_COLON
		      {
		        $$ = $1;
		      }
		     | SEMI_COLON 
		       {
		         $$ = new expr();
		       }
		     ;
		     
selection_statement
		     : IF RO_LBRACE expression N RO_RBRACE M statement N %prec THEN
		       {
		          //backpatching NL of N with the next instruction id
		          backpatch ($4->NL, nextinstr());
			  convertInt2Bool($3);
			  $$ = new statement();
			  backpatch ($3->TL, $6);
			  list<int> temp = merge ($3->FL, $7->NL);
			  $$->NL = merge ($8->NL, temp);
		       }
		     | IF RO_LBRACE expression N RO_RBRACE M statement N ELSE M statement
		       {
		          //backpatching NL of N with the next instruction id
		          backpatch ($4->NL, nextinstr());
			  convertInt2Bool($3);
			  $$ = new statement();
			  backpatch ($3->TL, $6);
			  backpatch ($3->FL, $10);
			  list<int> temp = merge ($7->NL, $8->NL);
			  $$->NL = merge ($11->NL,temp);
		       }
		     | SWITCH RO_LBRACE expression RO_RBRACE statement
		       {
		         //no action yet
		       }
		     ;
		     
iteration_statement 
      : WHILE M RO_LBRACE expression RO_RBRACE M statement
        {
               // M1 : go back to boolean condition expression again
	        // M2 : go to the statement if the boolean expression is true
               $$ = new statement();
		convertInt2Bool($4);
		backpatch($7->NL, $2);
		backpatch($4->TL, $6);
		$$->NL = $4->FL;
		// Emit to prevent fallthrough
		stringstream strs;
	        strs << $2;
	        string temp_str = strs.str();
	        char* inttostr = (char*) temp_str.c_str();
		string str = string(inttostr);
		//emitting TAC for looping
		emit ("GOTOOP", str);
        }
      | DO M statement M WHILE RO_LBRACE expression RO_RBRACE SEMI_COLON
        {
              //M1: go to the statement if the boolean expression is true
              //M2: go back to boolean condition expression again
               $$ = new statement();
		convertInt2Bool($7);
		backpatch ($7->TL, $2);
		backpatch ($3->NL, $4);
		// Making next list of the 'iteration statement' as false list of 'expression'
		$$->NL = $7->FL;
        }
      | FOR RO_LBRACE expression_statement M expression_statement M expression N RO_RBRACE M statement
        {
           $$ = new statement();
           //Conditional of the loop should be of boolean type
	   convertInt2Bool($5);
	   //Backpatching 
	   backpatch ($5->TL, $10);
	   backpatch ($8->NL, $4);
	   backpatch ($11->NL, $6);
	   stringstream strs;
	   strs << $6;
	   string temp_str = strs.str();
	   char* inttostr = (char*) temp_str.c_str();
	   string str = string(inttostr);
	   //emitting TAC for looping
	   emit ("GOTOOP", str);
	   $$->NL = $5->FL;
        }
      | FOR RO_LBRACE declaration expression_opt SEMI_COLON expression_opt RO_RBRACE statement{}
      ;
		      
jump_statement
		: GOTO ID SEMI_COLON
		  {
		    $$ = new statement();
		  }
		| CONTINUE SEMI_COLON
		  {
		    $$ = new statement();
		  }
		| BREAK SEMI_COLON
		  {
		    $$ = new statement();
		  }
		| RETURN expression SEMI_COLON
		  {
		    $$ = new statement();
		    emit("RETRN",$2->loc->name);
		  }
		| RETURN SEMI_COLON
		  {
		    $$ = new statement();
		    emit("RETRN","");
		  }
		;	

translation_unit
		 : external_declaration{}
		 | translation_unit external_declaration{}
		 ;
		 
external_declaration
		     : function_definition{}
		     | declaration{}
		     ;	     
		     
function_definition
       : declaration_specifiers declarator declaration_list CT compound_statement
         {
            //no action yet
         }
       | declaration_specifiers declarator CT compound_statement
         {
           //setting parent of curr_table to be glb_table
            emit("ENDFUNC", curr_table -> name);
           curr_table->parent = glb_table;
	   changeTable (glb_table);
	  
	   //setting type as function
	   //entry_type* tmp = new entry_type("FUNCTION");
	   //$2->type = tmp;
	   //$2->size = 0;
         }
       ;
			
declaration_list
		: declaration
		 {
		    //no action yet
		 }
		| declaration_list declaration
		 {
		   //no action yet
		 }
		;
						
%%     
		     		     
void yyerror(string s) {
   cout << s << " at line no " << yylineno << endl;
}
