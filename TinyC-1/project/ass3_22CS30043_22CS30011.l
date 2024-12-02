%{
#include <stdio.h>

#define KEYWORD 1
#define IDENTIFIER 2
#define INTEGER_CONSTANT 3
#define FLOATING_CONSTANT 4 
#define CHARACTER_CONSTANT 5
#define STRING_LITERAL 6
#define PUNCTUATOR 7

int linecount = 1;
%}

%option noyywrap

/* digits */
digit                  [0-9]
nonzero_digit          [1-9]
digit_sequence         {digit}+
nonzero_digit_sequence {nonzero_digit}{digit}*

/* Integer Constants */
integer_constant       0|{nonzero_digit_sequence}

/* Floating Constants */
fractional_constant    ({digit_sequence}?\.{digit_sequence})|({digit_sequence}\.)
exponent_part          [eE][+-]?{digit_sequence}
floating_constant      ({fractional_constant}{exponent_part}?)|({digit_sequence}{exponent_part})

/* Character Constants */
c_char                 [^\\'\n]|\\['"\\?abfnrtv]
c_char_sequence        {c_char}+

/* String Literals */
s_char                 [^\\\"\n]|\\['"\\?abfnrtv]
s_char_sequence        {s_char}*

/* Keywords */
keyword                auto|enum|restrict|unsigned|break|extern|return|void|case|float|short|volatile|char|for|signed|while|const|goto|sizeof|Bool|continue|if|static|Complex|default|inline|struct|Imaginary|do|int|switch|double|long|typedef|else|register|union

/* Punctuators */
punctuator             \[|\]|\(|\)|\{|\}|\.|->|\+\+|\-\-|&|\*|\+|\-|\~|\!|\/|\%|<<|>>|<|<=|>|>=|==|!=|\^|\||&&|\|\||\?|:|;|\.\.\.|=|\*=|\/=|\%=|\+=|\-=|<<=|>>=|&=|\^=|\|=|,|#            

%%

{keyword}   { return KEYWORD; }

[a-zA-Z_][a-zA-Z0-9_]* { return IDENTIFIER; }

{integer_constant}     { return INTEGER_CONSTANT; }
{floating_constant}    { return FLOATING_CONSTANT; }
\'{c_char_sequence}\'  { return CHARACTER_CONSTANT; }

\"{s_char_sequence}?\" { return STRING_LITERAL; }

{punctuator}    { return PUNCTUATOR; }

\/\/[^\n]*               { /* ignore single-line comments */ }

\/\*([^*]|\*+[^*/])*\*\/ {  
    // Count the number of '\n' in the comment block
    for (int i = 0; yytext[i] != '\0'; i++) {
        if (yytext[i] == '\n') {
            linecount++;
        }
    }
}

"\n" { linecount++; }

[ \t]+ { /* ignore whitespace */ }

%%


