//test file to check functions and iterations and also some of the
//functions created in assignment 2

int printStr(char *c);
int printInt(int i);
int readInt(int *eP);


int fib_iter(int a){
  int f=1,f_1=0;
  int i=1,temp;
  while(i<a) {
    temp=f;
    f=f+f_1;
    f_1=temp;
    i=i+1;
  }
  printStr("\nThe fibonacci number is : ");
  printInt(f);
  return f;
}

int main () {
  printStr("\nProgram to evaluate iterative fib...");
  printStr("\n+++++ Enter a number : ");
  int i,ep;
  i=readInt(&ep);

  printStr("\n++++ Calling Iterative Fib Function +++++");
  int j;
  j=fib_iter(i);
  printStr("\n++++ Returned from Recursive Fib function ++++\n");
  return;
}
