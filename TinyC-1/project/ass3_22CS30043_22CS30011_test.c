/* test file
for testing the lexical analyzer
*/

#include <stdio.h>

struct Point {
    int x;
    int y;
};

struct Rectangle {
    struct Point topLeft;
    struct Point bottomRight;
};

int main() {
    // Keywords
    auto int x = 10;
    const float y = 20.5;
    if (x > 0) {
        x++;
    } else {
        x--;
    }

    // Identifiers
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

    // Structs and -> operator
    struct Point p1 = {0, 0};
    struct Point p2 = {10, 10};
    struct Rectangle rect = {p1, p2};

    struct Rectangle *rectPtr = &rect;
    int area = (rectPtr->bottomRight.x - rectPtr->topLeft.x) * 
               (rectPtr->bottomRight.y - rectPtr->topLeft.y);

    // Punctuators
    int e = a + b;
    e *= 2;
    if (e == 246) {
        e /= 2;
    }

    printf("This is a test file for testing the lexical analyzer.\n");

    return 0;
}
