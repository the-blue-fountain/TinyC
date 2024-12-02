// ternary operators, if-else conditions, function calls (simple and nested)
int myfunc(int x, int y, int d) 
{
	int ans = d;
	if(x>y)  // if-else
		ans += x;
	else
	{
   		ans *= y;
	}
	return ans;
}

int min(int x, int y) 
{
   int min_val;
   // ternary operator
   min_val = x>y ? y : x; 
   return min_val;
}

// a random function to test nested function calls
int nested(int x, int y)
{
	int ans = 1;
	if(x < 3) 
	{
		ans = myfunc(x, y, 5);
	}
	return ans;
}

int main() 
{
	int diff, x, y;
	int b = 5;
	diff = nested(10, b);
	x = 6;
	y = 32;
	b = myfunc(min(x, 3), min(5, y), 2);
	return 0;
}