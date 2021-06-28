#include "ass6_18CS30018_translator.h"
extern vector<string> str_all;
extern FILE *yyin;
using namespace std;

//label count
int cnt_label=0;

// map from quad number to label number
std::map<int, int> lbl_map;  

 //file name of assembly file
string assembly_filename="ass6_18CS30018_";  
  
//file stream for asm
ofstream gen_out;   

// quad_aray of quads
vector <quad> quad_ar;	

//file name of the input file
string input_file="ass6_18CS30018_test";


template<class T>
ostream &operator<<(ostream &o_str, const vector<T> &v)
{
	copy(v.begin(), v.end(), ostream_iterator<T>(o_str, " ")); 
	return o_str;
}

//Evaluates Activation Record
void compute_ar(sym_table* stab) {
	int off_par = -20, off_local = -24;
	for (list <sym_entry>::iterator it = stab->curr_table.begin(); it!=stab->curr_table.end(); it++) 
	{
		if (it->category =="param") {
			stab->ar [it->name] = off_par;
			off_par +=it->size;			
		}
		else if (it->name=="return") 
		{
		  continue;
		}
		else {
			stab->ar [it->name] = off_local;
			off_local -=it->size;		
		}
	}
}


//Computes the Offset of the symbol table
void compute_offset(sym_table* stab)
{
	int curr_offset = 4;
	if(stab->name != "Global")
	{
		for (list <sym_entry>::iterator it = stab->curr_table.begin(); it!=stab->curr_table.end(); it++) {
			if (it->category =="param") {
				it->offset = stab->ar[it->name]+24;			
			}
			else if (it->name=="return") it->offset = stab->ar[it->name];
			else {
				it->offset = stab->ar[it->name]+20;		
			}
		}
	}
}

//Generates the assembly program
void generate_asm() {
	quad_ar = q.array;

	//updates the labels for goto
	for (vector<quad>::iterator it = quad_ar.begin(); it!=quad_ar.end(); it++) {
	int i;
	if (it->op=="GOTOOP" || it->op=="LT" || it->op=="GT" || it->op=="LTE" || it->op=="GTE" || it->op=="EQOP" || it->op=="NEOP") {
		i = atoi(it->result.c_str());
		lbl_map [i] = 1;
	}
	}
	int count = 0;
	for (std::map<int,int>::iterator it=lbl_map.begin(); it!=lbl_map.end(); ++it)
	{
		           it->second = count++;
	}
	
	list<sym_table*> tablelist;
	
	for (list <sym_entry>::iterator it = glb_table->curr_table.begin(); it!=glb_table->curr_table.end(); it++) 
	{
		if (it->nested!=NULL) tablelist.push_back (it->nested);
	}
	for (list<sym_table*>::iterator iterator = tablelist.begin(); iterator != tablelist.end(); ++iterator) 
	{
		compute_ar(*iterator);
	}

	//assembly_file
	ofstream assembly_file;
	assembly_file.open(assembly_filename.c_str());

	assembly_file << "\t.file	\"test.c\"\n";
	for (list <sym_entry>::iterator it = curr_table->curr_table.begin(); it!=curr_table->curr_table.end(); it++) {
		if (it->category!="function") {
			if (it->type->type=="CHAR") 
			{ 
				if (it->initial_value!="") {
					assembly_file << "\t.globl\t" << it->name << "\n";
					assembly_file << "\t.type\t" << it->name << ", @object\n";
					assembly_file << "\t.size\t" << it->name << ", 1\n";
					assembly_file << it->name <<":\n";
					assembly_file << "\t.byte\t" << atoi( it->initial_value.c_str()) << "\n";
				}
				else {
					assembly_file << "\t.comm\t" << it->name << ",1,1\n";
				}
			}
			if (it->type->type=="INTEGER") 
			{ 
				if (it->initial_value!="") {
					assembly_file << "\t.globl\t" << it->name << "\n";
					assembly_file << "\t.data\n";
					assembly_file << "\t.align 4\n";
					assembly_file << "\t.type\t" << it->name << ", @object\n";
					assembly_file << "\t.size\t" << it->name << ", 4\n";
					assembly_file << it->name <<":\n";
					assembly_file << "\t.long\t" << it->initial_value << "\n";
				}
				else {
					assembly_file << "\t.comm\t" << it->name << ",4,4\n";
				}
			}
		}
	}
	if (str_all.size()) {
		assembly_file << "\t.section\t.rodata\n";
		for (vector<string>::iterator it = str_all.begin(); it!=str_all.end(); it++) {
			assembly_file << ".LC" << it - str_all.begin() << ":\n";
			assembly_file << "\t.string\t" << *it << "\n";	
		}	
	}
	assembly_file << "\t.text	\n";

	vector<string> params;
	std::map<string, int> mapIt;
	for (vector<quad>::iterator it = quad_ar.begin(); it!=quad_ar.end(); it++) {
		if (lbl_map.count(it - quad_ar.begin())) {
			assembly_file << ".L" << (2*cnt_label+lbl_map.at(it - quad_ar.begin()) + 2 )<< ": " << endl;
		}

		string op = it->op;
		string result = it->result;
		string arg1 = it->arg1;
		string arg2 = it->arg2;
		string s = arg2;

		if(op=="PARAM"){
			params.push_back(result);
		}
		else {
			assembly_file << "\t";
			// Binary Operations
			if (op=="ADD") {
				bool flag=true;
				if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) flag=false ;
				else{
					char * p ;
					strtol(s.c_str(), &p, 10) ;
					if(*p == 0) flag=true ;
					else flag=false;
				}
				if (flag) {
					assembly_file << "addl \t$" << atoi(arg2.c_str()) << ", " << curr_table->ar[arg1] << "(%rbp)";
				}
				else {
					assembly_file << "movl \t" << curr_table->ar[arg1] << "(%rbp), " << "%eax" << endl;
					assembly_file << "\tmovl \t" << curr_table->ar[arg2] << "(%rbp), " << "%edx" << endl;
					assembly_file << "\taddl \t%edx, %eax\n";
					assembly_file << "\tmovl \t%eax, " << curr_table->ar[result] << "(%rbp)";
				}
			}
			else if (op=="MULT") {
				assembly_file << "movl \t" << curr_table->ar[arg1] << "(%rbp), " << "%eax" << endl;
				bool flag=true;
				if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) flag=false ;
				else{
					char * p ;
					strtol(s.c_str(), &p, 10) ;
					if(*p == 0) flag=true ;
					else flag=false;
				}
				if (flag) {
					assembly_file << "\timull \t$" << atoi(arg2.c_str()) << ", " << "%eax" << endl;
					sym_table* t = curr_table;
					string val;
				for (list <sym_entry>::iterator it = t->curr_table.begin(); it!=t->curr_table.end(); it++) {
						if(it->name==arg1) val=it->initial_value; 
					}
					mapIt[result]=atoi(arg2.c_str())*atoi(val.c_str());
				}
				else assembly_file << "\timull \t" << curr_table->ar[arg2] << "(%rbp), " << "%eax" << endl;
				assembly_file << "\tmovl \t%eax, " << curr_table->ar[result] << "(%rbp)";			
			}
			else if (op=="SUB") {
				assembly_file << "movl \t" << curr_table->ar[arg1] << "(%rbp), " << "%eax" << endl;
				assembly_file << "\tmovl \t" << curr_table->ar[arg2] << "(%rbp), " << "%edx" << endl;
				assembly_file << "\tsubl \t%edx, %eax\n";
				assembly_file << "\tmovl \t%eax, " << curr_table->ar[result] << "(%rbp)";
			}
			else if(op=="DIV") {
				assembly_file << "movl \t" << curr_table->ar[arg1] << "(%rbp), " << "%eax" << endl;
				assembly_file << "\tcltd" << endl;
				assembly_file << "\tidivl \t" << curr_table->ar[arg2] << "(%rbp)" << endl;
				assembly_file << "\tmovl \t%eax, " << curr_table->ar[result] << "(%rbp)";		
			}

			// Bit Operations
			else if (op=="REMOP")		assembly_file << result << " = " << arg1 << " % " << arg2;
			else if (op=="BITAND")		assembly_file << result << " = " << arg1 << " & " << arg2;
			else if (op=="XOR")			assembly_file << result << " = " << arg1 << " ^ " << arg2;
			else if (op=="INCLOR")		assembly_file << result << " = " << arg1 << " | " << arg2;
			
			// Shift Operations
			else if (op=="LEFTOP")		assembly_file << result << " = " << arg1 << " << " << arg2;
			else if (op=="RIGHTOP")		assembly_file << result << " = " << arg1 << " >> " << arg2;
			else if (op=="EQ")	{
				s=arg1;
				bool flag=true;
				if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) flag=false ;
				else{
					char * p ;
					strtol(s.c_str(), &p, 10) ;
					if(*p == 0) flag=true ;
					else flag=false;
				}
				if (flag) 
					assembly_file << "movl\t$" << atoi(arg1.c_str()) << ", " << "%eax" << endl;
				else
					assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), " << "%eax" << endl;
				assembly_file << "\tmovl \t%eax, " << curr_table->ar[result] << "(%rbp)";
			}			
			else if (op=="STREQ")	
			{
				assembly_file << "movq \t$.LC" << arg1 << ", " << curr_table->ar[result] << "(%rbp)";
			}
			else if (op=="CHAREQ")	
			{
				assembly_file << "movb\t$" << atoi(arg1.c_str()) << ", " << curr_table->ar[result] << "(%rbp)";
			}					
			// Relational Operations
			else if (op=="NEOP") 
			{
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tcmpl\t" << curr_table->ar[arg2] << "(%rbp), %eax\n";
				assembly_file << "\tjne .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="EQOP")
			 {
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tcmpl\t" << curr_table->ar[arg2] << "(%rbp), %eax\n";
				assembly_file << "\tje .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="LT") {
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tcmpl\t" << curr_table->ar[arg2] << "(%rbp), %eax\n";
				assembly_file << "\tjl .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="LTE") 
			{
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tcmpl\t" << curr_table->ar[arg2] << "(%rbp), %eax\n";
				assembly_file << "\tjle .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="GT") 
			{
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tcmpl\t" << curr_table->ar[arg2] << "(%rbp), %eax\n";
				assembly_file << "\tjg .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="GTE") 
			{
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tcmpl\t" << curr_table->ar[arg2] << "(%rbp), %eax\n";
				assembly_file << "\tjge .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="GOTOOP") 
			{
				assembly_file << "jmp .L" << (2*cnt_label+lbl_map.at(atoi( result.c_str() )) +2 );
			}
			
			// Unary Operators
			else if (op=="BCOMPL")		assembly_file << result 	<< " = ~" << arg1;
			else if (op=="NOTOP")			assembly_file << result 	<< " = !" << arg1;
			else if (op=="AMP") {
				assembly_file << "leaq\t" << curr_table->ar[arg1] << "(%rbp), %rax\n";
				assembly_file << "\tmovq \t%rax, " <<  curr_table->ar[result] << "(%rbp)";
			}
			else if (op=="RPTR") {
				assembly_file << "movl\t" << curr_table->ar[arg1] << "(%rbp), %eax\n";
				assembly_file << "\tmovl\t(%eax),%eax\n";
				assembly_file << "\tmovl \t%eax, " <<  curr_table->ar[result] << "(%rbp)";	
			}
			else if (op=="LPTR") {
				assembly_file << "movl\t" << curr_table->ar[result] << "(%rbp), %eax\n";
				assembly_file << "\tmovl\t" << curr_table->ar[arg1] << "(%rbp), %edx\n";
				assembly_file << "\tmovl\t%edx, (%eax)";
			} 			
			else if (op=="UMINUS") {
				assembly_file << "negl\t" << curr_table->ar[arg1] << "(%rbp)";
			}
			else if (op=="RARR") {
				int off=0;
				off=mapIt[arg2]*(-1)+curr_table->ar[arg1];
				assembly_file << "movq\t" << off << "(%rbp), "<<"%rax" << endl;
				assembly_file << "\tmovq \t%rax, " <<  curr_table->ar[result] << "(%rbp)";
			}	 			
			else if (op=="LARR") {
				int off=0;
				off=mapIt[arg1]*(-1)+curr_table->ar[result];
				assembly_file << "movq\t" << curr_table->ar[arg2] << "(%rbp), "<<"%rdx" << endl;
				assembly_file << "\tmovq\t" << "%rdx, " << off << "(%rbp)";
			}	 
			else if (op=="RETRN") {
				if(result!="") assembly_file << "movl\t" << curr_table->ar[result] << "(%rbp), "<<"%eax";
				else assembly_file << "nop";
			}
			else if (op=="PARAM") {
				params.push_back(result);
			}
			else if (op=="CALL") {
				// Symbol Table for functions
				sym_table* t = glb_table->lookup(arg1)->nested;
				int i,j=0;	
				for (list <sym_entry>::iterator it = t->curr_table.begin(); it!=t->curr_table.end(); it++) {
					i = distance ( t->curr_table.begin(), it);
					if (it->category== "param") {
					if(j==0) {
					assembly_file << "movl \t" << curr_table->ar[params[i]] << "(%rbp), " << "%eax" << endl;
					assembly_file << "\tmovq \t" << curr_table->ar[params[i]] << "(%rbp), " << "%rdi" << endl;
						j++;
					}
					else if(j==1) {
					assembly_file << "movl \t" << curr_table->ar[params[i]] << "(%rbp), " << "%eax" << endl;
					assembly_file << "\tmovq \t" << curr_table->ar[params[i]] << "(%rbp), " << "%rsi" << endl;
						j++;
					}
					else if(j==2) {
					  assembly_file << "movl \t" << curr_table->ar[params[i]] << "(%rbp), " << "%eax" << endl;
					  assembly_file << "\tmovq \t" << curr_table->ar[params[i]] << "(%rbp), " << "%rdx" << endl;
					  j++;
					}
					else if(j==3) {
					assembly_file << "movl \t" << curr_table->ar[params[i]] << "(%rbp), " << "%eax" << endl;
					assembly_file << "\tmovq \t" << curr_table->ar[params[i]] << "(%rbp), " << "%rcx" << endl;
						j++;
					}
					else {
						assembly_file << "\tmovq \t" << curr_table->ar[params[i]] << "(%rbp), " << "%rdi" << endl;							
					     }
					}
					else break;
				}
				params.clear();
				assembly_file << "\tcall\t"<< arg1 << endl;
				assembly_file << "\tmovl\t%eax, " << curr_table->ar[result] << "(%rbp)";
			}
			else if (op=="FUNCTION") {
				assembly_file <<".globl\t" << result << "\n";
				assembly_file << "\t.type\t"	<< result << ", @function\n";
				assembly_file << result << ": \n";
				assembly_file << ".LFB" << cnt_label <<":" << endl;
				assembly_file << "\t.cfi_startproc" << endl;
				assembly_file << "\tpushq \t%rbp" << endl;
				assembly_file << "\t.cfi_def_cfa_offset 8" << endl;
				assembly_file << "\t.cfi_offset 5, -8" << endl;
				assembly_file << "\tmovq \t%rsp, %rbp" << endl;
				assembly_file << "\t.cfi_def_cfa_register 5" << endl;
				curr_table = glb_table->lookup(result)->nested;
				assembly_file << "\tsubq\t$" << curr_table->curr_table.back().offset+24 << ", %rsp"<<endl;
				
				//Symbol Table for functions
				sym_table* t = curr_table;
				int i=0;
				for (list <sym_entry>::iterator it = t->curr_table.begin(); it!=t->curr_table.end(); it++) {
					if (it->category== "param") {
						if (i==0) {
							assembly_file << "\tmovq\t%rdi, " << curr_table->ar[it->name] << "(%rbp)";
							i++;
						}
						else if(i==1) {
							assembly_file << "\n\tmovq\t%rsi, " << curr_table->ar[it->name] << "(%rbp)";
							i++;
						}
						else if (i==2) {
							assembly_file << "\n\tmovq\t%rdx, " << curr_table->ar[it->name] << "(%rbp)";
							i++;
						}
						else if(i==3) {
							assembly_file << "\n\tmovq\t%rcx, " << curr_table->ar[it->name] << "(%rbp)";
							i++;
						}
					}
					else break;
				}
			}		
			else if (op=="ENDFUNC") {
				assembly_file << "leave\n";
				assembly_file << "\t.cfi_restore 5\n";
				assembly_file << "\t.cfi_def_cfa 4, 4\n";
				assembly_file << "\tret\n";
				assembly_file << "\t.cfi_endproc" << endl;
				assembly_file << ".LFE" << cnt_label++ <<":" << endl;
				assembly_file << "\t.size\t"<< result << ", .-" << result;
			}
			else assembly_file << "op";
			assembly_file << endl;
		}
	}
	assembly_file << 	"\t.ident\t	\"Compiled by 18CS30018 & 18CS10027\"\n";
	assembly_file << 	"\t.section\t.note.GNU-stack,\"\",@progbits\n";
	assembly_file.close();
	
	for (list<sym_table*>::iterator iterator = tablelist.begin(); 
		iterator != tablelist.end(); ++iterator) {
		compute_offset(*iterator);
	}
}


int main(int argc, char* argv[]) {
	input_file = input_file+string(argv[argc-1])+string(".c");
	assembly_filename = assembly_filename+string(argv[argc-1])+string(".s");
	
        glb_table = new sym_table("Global");
        curr_table = glb_table;
	yyin = fopen(input_file.c_str(),"r"); 
	
	//calling yyparse()
	int i = yyparse();
	cout << setw(32) << setfill ('+') << "+" << endl;
	
	//Printing Parser Results
	cout <<"|        Parser results        |"<<endl;
	cout << setw(32) << setfill ('+') << "+"<< setfill (' ') << endl;
	if(i) cout << "ERROR in Line no : "<< yylineno << " while parsing at "<< yytext << "\n\n" <<endl;
	else cout <<"=>  NO ERRORS!Successfully Parsed!  \n"<<endl;
	glb_table->update();
	generate_asm();
	q.print();
	cout << "\n" << endl;
	cout << setw(40) << setfill ('+') << "+"<< endl;
	cout << "|  Symbol Tables Used for the Program  |" << endl;
	cout << setw(40) << setfill ('+') << "+"<< "\n" <<endl;
	glb_table->print();
	
	return 0;
}
