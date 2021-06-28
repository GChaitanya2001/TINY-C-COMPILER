//This file tests recursive fibonacci

int printStr(char *c);
int printInt(int i);
int readInt(int *eP);

int pow(int a,int n) 
{ 
   int ans1=1, i;
   for(i = 0; i<n; i++)
   {
     ans1 = ans1*a;
   }
   return ans1; 
} 
  
int main () 
{ 
  int a, n, ans;
  int eP=1;
  printStr("Program to compute nth power of 'a'...\n"); 
  printStr("Enter a number: ");
  a = readInt(&eP);
  printStr("Enter a exponent: ");
  n = readInt(&eP);
  printStr("\nnth power of 'a' is: "); 
  ans = pow(a, n);
  printInt(ans);
  printStr("\n");
  return 0; 
} 
