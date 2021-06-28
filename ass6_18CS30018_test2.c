//Test file to check basic statements, expression, readInt and printInt library 
//Also checks the recursive fibonacci function to check the function call and return methodology

int printStr(char *c);
int printInt(int i);
int readInt(int *eP);

int main()
{
	int a = 13, b = 30;
	int c = 22;
	int d = 2;
	int incr = 2;
	printStr("\n++++ Before changes +++++\n");
	printStr("\t a = ");
	printInt(a);
	printStr("\t b = ");
	printInt(b);
	printStr("\t c = ");
	printInt(c);
	printStr("\t d = ");
	printInt(d);
	printStr("\t incr = ");
	printInt(incr);
		
   if(b > a)
   {
	if(c > d)
	{
	   incr = incr + c;
	   incr = incr + b;
	   d = b+c;
	 }
	else
	{
	  incr = incr + d;
	  incr = incr + b;
	  a = b-d;
	}
     }
	else
	{
		if(c > d)
		{
			incr = incr + c;
			incr = incr + a;
			c = a+b;
		}
		else
		{
			incr = incr + d;
			incr = incr + a;
		}
	}
	printStr("\n++++ After changes +++++\n");
	printStr("\t a = ");
	printInt(a);
	printStr("\t b = ");
	printInt(b);
	printStr("\t c = ");
	printInt(c);
	printStr("\t d = ");
	printInt(d);
	printStr("\t incr = ");
	printInt(incr);
	printStr("\n");
   return 0;
}
