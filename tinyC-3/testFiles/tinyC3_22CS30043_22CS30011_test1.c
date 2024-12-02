// declaration of variables(int, float, char), 1D array, 2D array, functions and arithmetic operations

// global declarations
int myVar_1 = 100;
float _myFloatVar2 = 50.25;

// Integer Constants
int a = 123;
int b = 0;

// Floating Constants
float c = 1.23;
float d = 3.14e-10;

// Character Constants
char ch1 = 'a';
char ch2 = '\n';

// String Literals
char *str1 = "Hello, World!";
char *str2 = "'C' Programming";

//arrays
int testint, matint[12];	// 1D array declaration
float matfloat[2][2];	// 2D array declaration
int a = 4, *p, b;	// pointer declaration
void quotient(int i, float d); // function declaration
char c;		

void main()
{
	// Variable Declaration
	int x = 120;
	int y = 17, sum, diff, prod, div, rem, and, or;
	// Character definitions
	char ch='c', d = 'a'; 

	// Arithmetic Operations
	sum = x+y;
	diff = x-y;
	prod = x*y;
	div = x/y;
	rem = x%y;
	and = x&y;
	or = x|y;
	
	y = y<<2;
	x = x>>1;

	return 0;
}
