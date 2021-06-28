//This test file verifies both boolean and arithmetic expression

int printStr(char *c);
int printInt(int n);
int readInt(int *eP);
int a;
int b = 1;
char ch;

int add (int a, int b) {
  int ans;
  int c = 2, d, arr[10];
  int*p;
  printStr("++++ Entered into function....\n");
  ans = a+b;
  d = 2;
  if (a>=d) {
    a++;
  }
  else {
    c = a+b;
  }
  printStr("++++ Returning from function....\n");
  return ans;
}

int main () {
  int c = 2, d, arr[10];
  int*p;
  int x, y, z;
  int eP;
  printStr("++++ Enter two numbers : \t");
  x = readInt(&eP);
  y = readInt(&eP);
  z = add(x,y);
  printStr("++++ The Sum of numbers entered = ");
  printInt(z);
  printStr("\n");
  return c;
}
