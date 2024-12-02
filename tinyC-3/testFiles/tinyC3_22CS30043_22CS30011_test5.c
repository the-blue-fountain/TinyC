// recursive functions and nesting of conditional statements  
int factorial(int n){
    if(n == 1 || n == 0)
        return 1;
    return n*fact(n-1);
}

//swap variables
void swap(int *a, int *b){
    int temp = *a;
    *a = *b;
    *b = temp;
}

int fibo(int n){
    if(n == 0)
        return 0;
    if(n == 1)
        return 1;
    return fibo(n-1) + fibo(n-2);
}

int GCD(int a, int b) 
{ 
    if (a == 0) 
        return b; 
    return GCD(b % a, a); 
}

int main()  
{  
    int a, b, g;
    int fact = 42;
    int flag = 0;
    if(flag == 0)
    {
    	a = 20;
    	if(flag == 1)   
    		b = 5;
    	else
    		b = 4;
        
    }
    // nested if else statement
    else
    {
        a = 150;
    	b = 25;
    }
    // calling recursive function
    g = GCD(a, b);
    fact = factorial(a*b);
    swap(&a, &b);
    return 0;  
}  