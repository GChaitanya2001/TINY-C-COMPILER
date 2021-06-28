//This testfile checks whether function_definition and functional calls will work or not

int printInt(int n);
int printStr(char * c);
int readInt(int *eP);

int incr_by_2(int a)
{
    int b;
    b = a;
    b = b + 6;
    printStr("\n++++ Inside incr_by_2 function +++");
    printInt(b);
    return b;
}
int main()
{
    int a[12][8],b;
    int *acc;
    printStr("\n++++ Checking printStr +++");
    b = 21;
    acc = &b;
    printStr("\nThe Number passed to function = ");
    printInt(b);
    b=incr_by_2(b);
    printStr("\nThe number returned from the function = ");
    printInt(b);
    printStr("\n++++ Checking ReadInt, Enter a number: \t");
    b = readInt(acc);
    printStr("The integer read = ");
    printInt(b);
    printStr("\n\n");
    

    return 0;
}
