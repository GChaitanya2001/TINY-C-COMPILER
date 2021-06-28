int printStr(char *ch)
 {
      int i=0;
      for(i=0;ch[i]!='\0';i++);
      __asm__ __volatile__ ("syscall"::"a"(1), "D"(1), "S"(ch), "d"(i));
      return(i);
 }
 
 int printInt(int n){
	char buff[100];
	int i=0,j,k,bytes;
	if (n==0) buff[i++]='0';
	else {
		if(n<0) {
			buff[i++]='-';
			n=-n;
		}
		int dg=0;
		while (n) {
			dg=n%10;
			buff[i++]=(char)(dg+'0');
			n/=10;
		}
		if(buff[0]=='-') j=1;
		else j=0;
		k=i-1;
		char temp;
		/*reversing the arr*/
		while (j<k) {
			temp=buff[j];
			buff[j++]=buff[k];
			buff[k--]=temp;
		}
	}
	bytes=i;
	/*inline asm commands for system call to print "buff" till "bytes" length to STDOUT*/
	__asm__ __volatile__ (
	"movl $1, %%eax \n\t"
	"movq $1, %%rdi \n\t"
	"syscall \n\t"
	:
	:"S"(buff),"d"(bytes)
	);
return bytes;
}

int readInt(int *eP) {
	char buff[1];
	char n[20];
	int num=0,len=0,i;
	while (1) {
	 __asm__ __volatile__ ("syscall"::"a"(0), "D"(0), "S"(buff), "d"(1));/*reading inputs one by one from STDIN to buff*/
		if(buff[0]=='\t'||buff[0]=='\n'||buff[0]==' ') break;/*breaks at the first encounter of whitespace*/
		else if (((int)buff[0]-'0'>9||(int)buff[0]-'0'<0)&& buff[0]!='-') *eP=1;/*only '-' or digits are allowed, else error*/
		else{
			n[len++]=buff[0]; 
		}
	}
	if(len>9||len==0){/*less than 9 bits allowed, keePing in mind the range of int in C*/
		*eP=1;
		return 0;
	}
	if (n[0]=='-') {
		if(len==1) {
			*eP=1;
			return 0;
		}
		for (i=1;i<len;i++) {
			if(n[i]=='-') *eP=1;/*a number can contain '-' only at the starting of the number*/
			num*=10;
			num+=(int)n[i]-'0';
		}
		num=-num;
	}
	else{
		for (i=0;i<len;i++) {
			if (n[i]=='-') *eP=1;/*a number can contain '-' only at the starting of the number*/
			num*=10;
			num+=(int)n[i]-'0';
		}
	}
	return num;/*number is returned*/
}
