%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

struct TreeNode {
    char* type;
    char* value;
    int num_children;
    struct TreeNode** children;
};

struct TreeNode* create_node(char* type, char* value) {
    struct TreeNode* node = (struct TreeNode*)malloc(sizeof(struct TreeNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->num_children = 0;
    node->children = NULL;
    return node;
}

void add_child(struct TreeNode* parent, struct TreeNode* child) {
    if (!parent || !child) return;
    parent->num_children++;
    parent->children = (struct TreeNode**)realloc(parent->children, parent->num_children * sizeof(struct TreeNode*));
    parent->children[parent->num_children - 1] = child;
}

extern int yylex();
extern char *yytext;
extern int yylineno;
int currline = -1;
int dept = 1;

extern struct TreeNode * root;
void yyerror(char *s);

void indent() {
    for (int i = 0; i < dept; i++) {
        printf("\t");
    }
}

void put(char* s) {
    if (yylineno != currline) {
        printf("LINE: %d\n", yylineno);
        currline = yylineno;
    }

    indent();
    printf("%s", s);
}

%}

/* Token Declaration */
%union {
    char* str_value;
    struct TreeNode* node;
}

%type <node> primary_expression postfix_expression argument_expression_list
       unary_expression unary_operator cast_expression multiplicative_expression
       additive_expression shift_expression relational_expression equality_expression
       AND_expression exclusive_OR_expression inclusive_OR_expression
       logical_AND_expression logical_OR_expression conditional_expression
       assignment_expression assignment_operator expression constant_expression
       declaration init_declarator_list storage_class_specifier
       type_specifier specifier_qualifier_list type_qualifier function_specifier
       declarator direct_declarator pointer parameter_type_list parameter_list
       parameter_declaration identifier_list type_name initializer initializer_list
       designation designator_list designator statement labeled_statement
       compound_statement block_item_list block_item expression_statement
       selection_statement iteration_statement jump_statement translation_unit
       external_declaration function_definition declaration_list

%type <node> argument_expression_list_opt init_declarator_list_opt init_declarator
%type <node> specifier_qualifier_list_opt pointer_opt assignment_expression_opt
%type <node> type_qualifier_list identifier_list_opt designation_opt
%type <node> block_item_list_opt expression_opt declaration_list_opt

%type <node> type_qualifier_list_opt

%type <node> declaration_specifiers
%type <node> declaration_specifiers_opt

%token <str_value> IDENTIFIER CONSTANT STRING_LITERAL

%token AUTO REGISTER SIGNED STRUCT TYPEDEF UNION UNSIGNED HASH

%token ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE
%token SQUARE_BRACKET_OPEN SQUARE_BRACKET_CLOSE
%token CURLY_BRACKET_OPEN CURLY_BRACKET_CLOSE

%token UNARY_INCREMENT UNARY_DECREMENT NOT
%token MUL DIV MOD PLUS MINUS COMPLEMENT XOR
%token DOT DOTS COMMA QUES_MARK COLON SEMICOLON
%token IMPLIES 

%token BITWISE_LEFT BITWISE_RIGHT BITWISE_AND BITWISE_OR
%token LOGICAL_AND LOGICAL_OR
%token LESS_THAN GREATER_THAN LESS_EQUAL GREATER_EQUAL EQUAL NOT_EQUAL

%token ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN PLUS_ASSIGN MINUS_ASSIGN 
%token BITWISE_LEFT_ASSIGN BITWISE_RIGHT_ASSIGN BITWISE_AND_ASSIGN XOR_ASSIGN BITWISE_OR_ASSIGN

%token EXTERN STATIC VOID CHAR SHORT INT LONG FLOAT DOUBLE CONST RESTRICT VOLATILE INLINE SIZEOF 

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN 

%precedence LOWER_THAN_ELSE
%precedence ELSE

%start translation_unit

%%

/* 1. EXPRESSIONS */

primary_expression 
    : IDENTIFIER
    {
        $$ = create_node("primary_expression", $1);
        put("primary_expression -> IDENTIFIER\n");
    }
    | CONSTANT
    {
        $$ = create_node("primary_expression", $1);
        put("primary_expression -> CONSTANT\n");
    }
    | STRING_LITERAL
    {
        $$ = create_node("primary_expression", $1);
        put("primary_expression -> STRING_LITERAL\n");
    }
    | ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE
    {
        $$ = create_node("primary_expression", "(expression)");
        add_child($$, $2);
        put("primary_expression -> '(' expression ')'\n");
    }
    ;

postfix_expression 
    : primary_expression
    {
        $$ = create_node("postfix_expression", NULL);
        add_child($$, $1);
        put("postfix_expression -> primary_expression\n");
    }
    | postfix_expression SQUARE_BRACKET_OPEN expression SQUARE_BRACKET_CLOSE
    {
        $$ = create_node("postfix_expression", "postfix_expression[expression]");
        add_child($$, $1);
        add_child($$, $3);
        put("postfix_expression -> postfix_expression '[' expression ']'\n");
    }
    | postfix_expression ROUND_BRACKET_OPEN argument_expression_list_opt ROUND_BRACKET_CLOSE
    {
        $$ = create_node("postfix_expression", "(args)");
        add_child($$, $1);
        if ($3) add_child($$, $3);
        put("postfix_expression -> postfix_expression '(' argument_expression_list_opt ')'\n");
    }
    | postfix_expression DOT IDENTIFIER
    {
        $$ = create_node("postfix_expression", strcat("postfix_expression ", strcat(". ", $3)));
        add_child($$, $1);
        put("postfix_expression -> postfix_expression '.' IDENTIFIER\n");
    }
    | postfix_expression IMPLIES IDENTIFIER
    {
        $$ = create_node("postfix_expression", strcat("postfix_expression ", strcat("-> ", $3)));
        add_child($$, $1);
        put("postfix_expression -> postfix_expression '->' IDENTIFIER\n");
    }
    | postfix_expression UNARY_INCREMENT
    {
        $$ = create_node("postfix_expression", "++");
        add_child($$, $1);
        put("postfix_expression -> postfix_expression '++'\n");
    }
    | postfix_expression UNARY_DECREMENT
    {
        $$ = create_node("postfix_expression", "--");
        add_child($$, $1);
        put("postfix_expression -> postfix_expression '--'\n");
    }
    ;

argument_expression_list_opt 
    : argument_expression_list
    { 
        $$ = $1; 
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

argument_expression_list 
    : assignment_expression
    {
        $$ = create_node("argument_expression_list", NULL);
        add_child($$, $1);
        put("argument_expression_list -> assignment_expression\n");
    }
    | argument_expression_list COMMA assignment_expression
    {
        $$ = $1;
        add_child($$, $3);
        put("argument_expression_list -> argument_expression_list ',' assignment_expression\n");
    }
    ;

unary_expression 
    : postfix_expression
    {
        $$ = create_node("unary_expression", NULL);
        add_child($$, $1);
        put("unary_expression -> postfix_expression\n");
    }
    | UNARY_INCREMENT unary_expression
    {
        $$ = create_node("unary_expression", "++");
        add_child($$, $2);
        put("unary_expression -> '++' unary_expression\n");
    }
    | UNARY_DECREMENT unary_expression
    {
        $$ = create_node("unary_expression", "--");
        add_child($$, $2);
        put("unary_expression -> '--' unary_expression\n");
    }
    | unary_operator cast_expression
    {
        $$ = create_node("unary_expression", "unary_operator");
        add_child($$, $1);
        add_child($$, $2);
        put("unary_expression -> unary_operator cast_expression\n");
    }
    | SIZEOF unary_expression
    {
        $$ = create_node("unary_expression", "sizeof");
        add_child($$, $2);
        put("unary_expression -> 'sizeof' unary_expression\n");
    }
    | SIZEOF ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE
    {
        $$ = create_node("unary_expression", "sizeof(type_name)");
        add_child($$, $3);
        put("unary_expression -> 'sizeof' '(' type_name ')'\n");
    }
    ;

unary_operator
    : BITWISE_AND
    {
        $$ = create_node("unary_operator", "&");
        put("unary_operator -> '&'\n");
    }
    | MUL
    {
        $$ = create_node("unary_operator", "*");
        put("unary_operator -> '*'\n");
    }
    | PLUS
    {
        $$ = create_node("unary_operator", "+");
        put("unary_operator -> '+'\n");
    }
    | MINUS
    {
        $$ = create_node("unary_operator", "-");
        put("unary_operator -> '-'\n");
    }
    | COMPLEMENT
    {
        $$ = create_node("unary_operator", "~");
        put("unary_operator -> '~'\n");
    }
    | NOT
    {
        $$ = create_node("unary_operator", "!");
        put("unary_operator -> '!'\n");
    }
    ;

cast_expression 
    : unary_expression
    {
        $$ = $1;
        put("cast_expression -> unary_expression\n");
    }
    | ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE cast_expression
    {
        $$ = create_node("cast_expression", "(type_name)");
        add_child($$, $2);
        add_child($$, $4);
        put("cast_expression -> '(' type_name ')' cast_expression\n");
    }
    ;

multiplicative_expression 
    : cast_expression
    {
        $$ = $1;
        put("multiplicative_expression -> cast_expression\n");
    }
    | multiplicative_expression MUL cast_expression
    {
        $$ = create_node("multiplicative_expression", "*");
        add_child($$, $1);
        add_child($$, $3);
        put("multiplicative_expression -> multiplicative_expression '*' cast_expression\n");
    }
    | multiplicative_expression DIV cast_expression
    {
        $$ = create_node("multiplicative_expression", "/");
        add_child($$, $1);
        add_child($$, $3);
        put("multiplicative_expression -> multiplicative_expression '/' cast_expression\n");
    }
    | multiplicative_expression MOD cast_expression
    {
        $$ = create_node("multiplicative_expression", "%");
        add_child($$, $1);
        add_child($$, $3);
        put("multiplicative_expression -> multiplicative_expression '%' cast_expression\n");
    }
    ;

additive_expression 
    : multiplicative_expression
    {
        $$ = $1;
        put("additive_expression -> multiplicative_expression\n");
    }
    | additive_expression PLUS multiplicative_expression
    {
        $$ = create_node("additive_expression", "+");
        add_child($$, $1);
        add_child($$, $3);
        put("additive_expression -> additive_expression '+' multiplicative_expression\n");
    }
    | additive_expression MINUS multiplicative_expression
    {
        $$ = create_node("additive_expression", "-");
        add_child($$, $1);
        add_child($$, $3);
        put("additive_expression -> additive_expression '-' multiplicative_expression\n");
    }
    ;

shift_expression 
    : additive_expression
    {
        $$ = $1;
        put("shift_expression -> additive_expression\n");
    }
    | shift_expression BITWISE_LEFT additive_expression
    {
        $$ = create_node("shift_expression", "<<");
        add_child($$, $1);
        add_child($$, $3);
        put("shift_expression -> shift_expression '<<' additive_expression\n");
    }
    | shift_expression BITWISE_RIGHT additive_expression
    {
        $$ = create_node("shift_expression", ">>");
        add_child($$, $1);
        add_child($$, $3);
        put("shift_expression -> shift_expression '>>' additive_expression\n");
    }
    ;

relational_expression 
    : shift_expression
    {
        $$ = $1;
        put("relational_expression -> shift_expression\n");
    }
    | relational_expression LESS_THAN shift_expression
    {
        $$ = create_node("relational_expression", "<");
        add_child($$, $1);
        add_child($$, $3);
        put("relational_expression -> relational_expression '<' shift_expression\n");
    }
    | relational_expression GREATER_THAN shift_expression
    {
        $$ = create_node("relational_expression", ">");
        add_child($$, $1);
        add_child($$, $3);
        put("relational_expression -> relational_expression '>' shift_expression\n");
    }
    | relational_expression LESS_EQUAL shift_expression
    {
        $$ = create_node("relational_expression", "<=");
        add_child($$, $1);
        add_child($$, $3);
        put("relational_expression -> relational_expression '<=' shift_expression\n");
    }
    | relational_expression GREATER_EQUAL shift_expression
    {
        $$ = create_node("relational_expression", ">=");
        add_child($$, $1);
        add_child($$, $3);
        put("relational_expression -> relational_expression '>=' shift_expression\n");
    }
    ;

equality_expression 
    : relational_expression
    {
        $$ = $1;
        put("equality_expression -> relational_expression\n");
    }
    | equality_expression EQUAL relational_expression
    {
        $$ = create_node("equality_expression", "==");
        add_child($$, $1);
        add_child($$, $3);
        put("equality_expression -> equality_expression '==' relational_expression\n");
    }
    | equality_expression NOT_EQUAL relational_expression
    {
        $$ = create_node("equality_expression", "!=");
        add_child($$, $1);
        add_child($$, $3);
        put("equality_expression -> equality_expression '!=' relational_expression\n");
    }
    ;

AND_expression 
    : equality_expression
    {
        $$ = $1;
        put("AND_expression -> equality_expression\n");
    }
    | AND_expression BITWISE_AND equality_expression
    {
        $$ = create_node("AND_expression", "&");
        add_child($$, $1);
        add_child($$, $3);
        put("AND_expression -> AND_expression '&' equality_expression\n");
    }
    ;

exclusive_OR_expression 
    : AND_expression
    {
        $$ = $1;
        put("exclusive_OR_expression -> AND_expression\n");
    }
    | exclusive_OR_expression XOR AND_expression
    {
        $$ = create_node("exclusive_OR_expression", "^");
        add_child($$, $1);
        add_child($$, $3);
        put("exclusive_OR_expression -> exclusive_OR_expression '^' AND_expression\n");
    }
    ;

inclusive_OR_expression 
    : exclusive_OR_expression
    {
        $$ = $1;
        put("inclusive_OR_expression -> exclusive_OR_expression\n");
    }
    | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
    {
        $$ = create_node("inclusive_OR_expression", "|");
        add_child($$, $1);
        add_child($$, $3);
        put("inclusive_OR_expression -> inclusive_OR_expression '|' exclusive_OR_expression\n");
    }
    ;

logical_AND_expression 
    : inclusive_OR_expression
    {
        $$ = $1;
        put("logical_AND_expression -> inclusive_OR_expression\n");
    }
    | logical_AND_expression LOGICAL_AND inclusive_OR_expression
    {
        $$ = create_node("logical_AND_expression", "&&");
        add_child($$, $1);
        add_child($$, $3);
        put("logical_AND_expression -> logical_AND_expression '&&' inclusive_OR_expression\n");
    }
    ;

logical_OR_expression 
    : logical_AND_expression
    {
        $$ = $1;
        put("logical_OR_expression -> logical_AND_expression\n");
    }
    | logical_OR_expression LOGICAL_OR logical_AND_expression
    {
        $$ = create_node("logical_OR_expression", "||");
        add_child($$, $1);
        add_child($$, $3);
        put("logical_OR_expression -> logical_OR_expression '||' logical_AND_expression\n");
    }
    ;

conditional_expression 
    : logical_OR_expression
    {
        $$ = $1;
        put("conditional_expression -> logical_OR_expression\n");
    }
    | logical_OR_expression QUES_MARK expression COLON conditional_expression
    {
        $$ = create_node("conditional_expression", "? :");
        add_child($$, $1);
        add_child($$, $3);
        add_child($$, $5);
        put("conditional_expression -> logical_OR_expression '?' expression ':' conditional_expression\n");
    }
    ;

assignment_expression 
    : conditional_expression
    {
        $$ = $1;
        put("assignment_expression -> conditional_expression\n");
    }
    | unary_expression assignment_operator assignment_expression
    {
        $$ = create_node("assignment_expression", "assignment");
        add_child($$, $1);
        add_child($$, $2);
        add_child($$, $3);
        put("assignment_expression -> unary_expression assignment_operator assignment_expression\n");
    }
    ;

assignment_operator
    : ASSIGN
    {
        $$ = create_node("assignment_operator", "=");
        put("assignment_operator -> '='\n");
    }
    | MUL_ASSIGN
    {
        $$ = create_node("assignment_operator", "*=");
        put("assignment_operator -> '*='\n");
    }
    | DIV_ASSIGN
    {
        $$ = create_node("assignment_operator", "/=");
        put("assignment_operator -> '/='\n");
    }
    | MOD_ASSIGN
    {
        $$ = create_node("assignment_operator", "%=");
        put("assignment_operator -> '%='\n");
    }
    | PLUS_ASSIGN
    {
        $$ = create_node("assignment_operator", "+=");
        put("assignment_operator -> '+='\n");
    }
    | MINUS_ASSIGN
    {
        $$ = create_node("assignment_operator", "-=");
        put("assignment_operator -> '-='\n");
    }
    | BITWISE_LEFT_ASSIGN
    {
        $$ = create_node("assignment_operator", "<<=");
        put("assignment_operator -> '<<='\n");
    }
    | BITWISE_RIGHT_ASSIGN
    {
        $$ = create_node("assignment_operator", ">>=");
        put("assignment_operator -> '>>='\n");
    }
    | BITWISE_AND_ASSIGN
    {
        $$ = create_node("assignment_operator", "&=");
        put("assignment_operator -> '&='\n");
    }
    | XOR_ASSIGN
    {
        $$ = create_node("assignment_operator", "^=");
        put("assignment_operator -> '^='\n");
    }
    | BITWISE_OR_ASSIGN
    {
        $$ = create_node("assignment_operator", "|=");
        put("assignment_operator -> '|='\n");
    }
    ;

expression 
    : assignment_expression
    {
        $$ = $1;
        put("expression -> assignment_expression\n");
    }
    | expression COMMA assignment_expression
    {
        $$ = create_node("expression", ",");
        add_child($$, $1);
        add_child($$, $3);
        put("expression -> expression ',' assignment_expression\n");
    }
    ;

constant_expression 
    : conditional_expression
    {
        $$ = $1;
        put("constant_expression -> conditional_expression\n");
    }
    ;

declaration 
    : declaration_specifiers init_declarator_list_opt SEMICOLON
    {
        $$ = create_node("declaration", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("declaration -> declaration_specifiers init_declarator_list_opt ';'\n");
    }
    ;

init_declarator_list_opt 
    : init_declarator_list
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

init_declarator_list 
    : init_declarator
    {
        $$ = create_node("init_declarator_list", NULL);
        add_child($$, $1);
        put("init_declarator_list -> init_declarator\n");
    }
    | init_declarator_list COMMA init_declarator
    {
        $$ = $1;
        add_child($$, $3);
        put("init_declarator_list -> init_declarator_list ',' init_declarator\n");
    }
    ;

init_declarator 
    : declarator
    {
        $$ = $1;
        put("init_declarator -> declarator\n");
    }
    | declarator ASSIGN initializer
    {
        $$ = create_node("init_declarator", "=");
        add_child($$, $1);
        add_child($$, $3);
        put("init_declarator -> declarator '=' initializer\n");
    }
    ;

storage_class_specifier 
    : EXTERN
    {
        $$ = create_node("storage_class_specifier", "extern");
        put("storage_class_specifier -> 'extern'\n");
    }
    | STATIC
    {
        $$ = create_node("storage_class_specifier", "static");
        put("storage_class_specifier -> 'static'\n");
    }
    ;

type_specifier 
    : VOID
    {
        $$ = create_node("type_specifier", "void");
        put("type_specifier -> 'void'\n");
    }
    | CHAR
    {
        $$ = create_node("type_specifier", "char");
        put("type_specifier -> 'char'\n");
    }
    | SHORT
    {
        $$ = create_node("type_specifier", "short");
        put("type_specifier -> 'short'\n");
    }
    | INT
    {
        $$ = create_node("type_specifier", "int");
        put("type_specifier -> 'int'\n");
    }
    | LONG
    {
        $$ = create_node("type_specifier", "long");
        put("type_specifier -> 'long'\n");
    }
    | FLOAT
    {
        $$ = create_node("type_specifier", "float");
        put("type_specifier -> 'float'\n");
    }
    | DOUBLE
    {
        $$ = create_node("type_specifier", "double");
        put("type_specifier -> 'double'\n");
    }
    ;

specifier_qualifier_list 
    : type_specifier specifier_qualifier_list_opt
    {
        $$ = create_node("specifier_qualifier_list", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("specifier_qualifier_list -> type_specifier specifier_qualifier_list_opt\n");
    }
    | type_qualifier specifier_qualifier_list_opt
    {
        $$ = create_node("specifier_qualifier_list", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("specifier_qualifier_list -> type_qualifier specifier_qualifier_list_opt\n");
    }
    ;

specifier_qualifier_list_opt 
    : specifier_qualifier_list
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

type_qualifier 
    : CONST
    {
        $$ = create_node("type_qualifier", "const");
        put("type_qualifier -> 'const'\n");
    }
    | RESTRICT
    {
        $$ = create_node("type_qualifier", "restrict");
        put("type_qualifier -> 'restrict'\n");
    }
    | VOLATILE
    {
        $$ = create_node("type_qualifier", "volatile");
        put("type_qualifier -> 'volatile'\n");
    }
    ;

function_specifier 
    : INLINE
    {
        $$ = create_node("function_specifier", "inline");
        put("function_specifier -> 'inline'\n");
    }
    ;

declarator 
    : pointer_opt direct_declarator
    {
        $$ = create_node("declarator", NULL);
        if ($1) add_child($$, $1);
        add_child($$, $2);
        put("declarator -> pointer_opt direct_declarator\n");
    }
    ;

direct_declarator 
    : IDENTIFIER
    {
        $$ = create_node("direct_declarator", $1);
        put("direct_declarator -> IDENTIFIER\n");
    }
    | ROUND_BRACKET_OPEN declarator ROUND_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "(declarator)");
        add_child($$, $2);
        put("direct_declarator -> '(' declarator ')'\n");
    }
    | direct_declarator SQUARE_BRACKET_OPEN type_qualifier_list_opt assignment_expression_opt SQUARE_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "direct_declarator[type_qualifier_list_opt assignment_expression_opt]");
        add_child($$, $1);
        if ($3) add_child($$, $3);
        if ($4) add_child($$, $4);
        put("direct_declarator -> direct_declarator '[' type_qualifier_list_opt assignment_expression_opt ']'\n");
    }
    | direct_declarator SQUARE_BRACKET_OPEN STATIC type_qualifier_list_opt assignment_expression SQUARE_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "[static assignment_expression]");
        add_child($$, $1);
        if ($4) add_child($$, $4);
        add_child($$, $5);
        put("direct_declarator -> direct_declarator '[' 'static' type_qualifier_list_opt assignment_expression ']'\n");
    }
    | direct_declarator SQUARE_BRACKET_OPEN type_qualifier_list STATIC assignment_expression SQUARE_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "[type_qualifier_list static assignment_expression]");
        add_child($$, $1);
        add_child($$, $3);
        add_child($$, $5);
        put("direct_declarator -> direct_declarator '[' type_qualifier_list 'static' assignment_expression ']'\n");
    }
    | direct_declarator SQUARE_BRACKET_OPEN type_qualifier_list_opt MUL SQUARE_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "[*]");
        add_child($$, $1);
        if ($3) add_child($$, $3);
        put("direct_declarator -> direct_declarator '[' type_qualifier_list_opt '*' ']'\n");
    }
    | direct_declarator ROUND_BRACKET_OPEN parameter_type_list ROUND_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "(parameter_type_list)");
        add_child($$, $1);
        add_child($$, $3);
        put("direct_declarator -> direct_declarator '(' parameter_type_list ')'\n");
    }
    | direct_declarator ROUND_BRACKET_OPEN identifier_list_opt ROUND_BRACKET_CLOSE
    {
        $$ = create_node("direct_declarator", "(identifier_list_opt)");
        add_child($$, $1);
        if ($3) add_child($$, $3);
        put("direct_declarator -> direct_declarator '(' identifier_list_opt ')'\n");
    }
    ;

pointer 
    : MUL type_qualifier_list_opt
    {
        $$ = create_node("pointer", "*");
        if ($2) add_child($$, $2);
        put("pointer -> '*' type_qualifier_list_opt\n");
    }
    | MUL type_qualifier_list_opt pointer
    {
        $$ = create_node("pointer", "*");
        if ($2) add_child($$, $2);
        add_child($$, $3);
        put("pointer -> '*' type_qualifier_list_opt pointer\n");
    }
    ;
pointer_opt
 
    : pointer
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

assignment_expression_opt 
    : assignment_expression
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

type_qualifier_list 
    : type_qualifier
    {
        $$ = create_node("type_qualifier_list", NULL);
        add_child($$, $1);
        put("type_qualifier_list -> type_qualifier\n");
    }
    | type_qualifier_list type_qualifier
    {
        $$ = $1;
        add_child($$, $2);
        put("type_qualifier_list -> type_qualifier_list type_qualifier\n");
    }
    ;

type_qualifier_list_opt 
    : type_qualifier_list
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

parameter_type_list 
    : parameter_list
    {
        $$ = create_node("parameter_type_list", NULL);
        add_child($$, $1);
        put("parameter_type_list -> parameter_list\n");
    }
    | parameter_list COMMA DOTS
    {
        $$ = create_node("parameter_type_list", "...,");
        add_child($$, $1);
        put("parameter_type_list -> parameter_list ',' '...'\n");
    }
    ;

parameter_list 
    : parameter_declaration
    {
        $$ = create_node("parameter_list", NULL);
        add_child($$, $1);
        put("parameter_list -> parameter_declaration\n");
    }
    | parameter_list COMMA parameter_declaration
    {
        $$ = $1;
        add_child($$, $3);
        put("parameter_list -> parameter_list ',' parameter_declaration\n");
    }
    ;

parameter_declaration 
    : declaration_specifiers declarator
    {
        $$ = create_node("parameter_declaration", NULL);
        add_child($$, $1);
        add_child($$, $2);
        put("parameter_declaration -> declaration_specifiers declarator\n");
    }
    | declaration_specifiers
    {
        $$ = create_node("parameter_declaration", NULL);
        add_child($$, $1);
        put("parameter_declaration -> declaration_specifiers\n");
    }
    ;

identifier_list 
    : IDENTIFIER
    {
        $$ = create_node("identifier_list", $1);
        put("identifier_list -> IDENTIFIER\n");
    }
    | identifier_list COMMA IDENTIFIER
    {
        $$ = $1;
        add_child($$, create_node("identifier", $3));
        put("identifier_list -> identifier_list ',' IDENTIFIER\n");
    }
    ;

identifier_list_opt 
    : identifier_list
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

type_name 
    : specifier_qualifier_list
    {
        $$ = $1;
        put("type_name -> specifier_qualifier_list\n");
    }
    ;

initializer 
    : assignment_expression
    {
        $$ = $1;
        put("initializer -> assignment_expression\n");
    }
    | CURLY_BRACKET_OPEN initializer_list CURLY_BRACKET_CLOSE
    {
        $$ = create_node("initializer", "{initializer_list}");
        add_child($$, $2);
        put("initializer -> '{' initializer_list '}'\n");
    }
    | CURLY_BRACKET_OPEN initializer_list COMMA CURLY_BRACKET_CLOSE
    {
        $$ = create_node("initializer", "{initializer_list,}");
        add_child($$, $2);
        put("initializer -> '{' initializer_list ',' '}'\n");
    }
    ;

initializer_list 
    : designation_opt initializer
    {
        $$ = create_node("initializer_list", NULL);
        if ($1) add_child($$, $1);
        add_child($$, $2);
        put("initializer_list -> designation_opt initializer\n");
    }
    | initializer_list COMMA designation_opt initializer
    {
        $$ = $1;
        if ($3) add_child($$, $3);
        add_child($$, $4);
        put("initializer_list -> initializer_list ',' designation_opt initializer\n");
    }
    ;

designation 
    : designator_list ASSIGN
    {
        $$ = create_node("designation", "=");
        add_child($$, $1);
        put("designation -> designator_list '='\n");
    }
    ;

designation_opt 
    : designation
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

designator_list 
    : designator
    {
        $$ = create_node("designator_list", NULL);
        add_child($$, $1);
        put("designator_list -> designator\n");
    }
    | designator_list designator
    {
        $$ = $1;
        add_child($$, $2);
        put("designator_list -> designator_list designator\n");
    }
    ;

designator 
    : SQUARE_BRACKET_OPEN constant_expression SQUARE_BRACKET_CLOSE
    {
        $$ = create_node("designator", "[constant_expression]");
        add_child($$, $2);
        put("designator -> '[' constant_expression ']'\n");
    }
    | DOT IDENTIFIER
    {
        $$ = create_node("designator", strcat(". ", $2));
        put("designator -> '.' IDENTIFIER\n");
    }
    ;

/* STATEMENTS */

statement 
    : labeled_statement
    {
        $$ = $1;
        put("statement -> labeled_statement\n");
    }
    | compound_statement
    {
        $$ = $1;
        put("statement -> compound_statement\n");
    }
    | expression_statement
    {
        $$ = $1;
        put("statement -> expression_statement\n");
    }
    | selection_statement
    {
        $$ = $1;
        put("statement -> selection_statement\n");
    }
    | iteration_statement
    {
        $$ = $1;
        put("statement -> iteration_statement\n");
    }
    | jump_statement
    {
        $$ = $1;
        put("statement -> jump_statement\n");
    }
    ;

labeled_statement 
    : IDENTIFIER COLON statement
    {
        $$ = create_node("labeled_statement", strcat($1," : statement"));
        add_child($$, create_node("identifier", $1));
        add_child($$, $3);
        put("labeled_statement -> IDENTIFIER ':' statement\n");
    }
    | CASE constant_expression COLON statement
    {
        $$ = create_node("labeled_statement", "case constant_expression: statement");
        add_child($$, $2);
        add_child($$, $4);
        put("labeled_statement -> 'case' constant_expression ':' statement\n");
    }
    | DEFAULT COLON statement
    {
        $$ = create_node("labeled_statement", "default : statement");
        add_child($$, $3);
        put("labeled_statement -> 'default' ':' statement\n");
    }
    ;

compound_statement 
    : CURLY_BRACKET_OPEN block_item_list_opt CURLY_BRACKET_CLOSE
    {
        $$ = create_node("compound_statement", "{block_item_list_opt}");
        if ($2) add_child($$, $2);
        put("compound_statement -> '{' block_item_list_opt '}'\n");
    }
    ;

block_item_list 
    : block_item
    {
        $$ = create_node("block_item_list", NULL);
        add_child($$, $1);
        put("block_item_list -> block_item\n");
    }
    | block_item_list block_item
    {
        $$ = $1;
        add_child($$, $2);
        put("block_item_list -> block_item_list block_item\n");
    }
    ;

block_item 
    : declaration
    {
        $$ = $1;
        put("block_item -> declaration\n");
    }
    | statement
    {
        $$ = $1;
        put("block_item -> statement\n");
    }
    ;

block_item_list_opt 
    : block_item_list
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

expression_statement 
    : expression_opt SEMICOLON
    {
        $$ = create_node("expression_statement", ";");
        if ($1) add_child($$, $1);
        put("expression_statement -> expression_opt ';'\n");
    }
    ;

expression_opt 
    : expression
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

selection_statement 
    : IF ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement %prec LOWER_THAN_ELSE
    {
        $$ = create_node("selection_statement", "if ()");
        add_child($$, $3);
        add_child($$, $5);
        put("selection_statement -> 'if' '(' expression ')' statement\n");
    }
    | IF ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement ELSE statement
    {
        $$ = create_node("selection_statement", "if () else");
        add_child($$, $3);
        add_child($$, $5);
        add_child($$, $7);
        put("selection_statement -> 'if' '(' expression ')' statement 'else' statement\n");
    }
    | SWITCH ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement
    {
        $$ = create_node("selection_statement", "switch ()");
        add_child($$, $3);
        add_child($$, $5);
        put("selection_statement -> 'switch' '(' expression ')' statement\n");
    }
    ;

iteration_statement 
    : WHILE ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement
    {
        $$ = create_node("iteration_statement", "while ()");
        add_child($$, $3);
        add_child($$, $5);
        put("iteration_statement -> 'while' '(' expression ')' statement\n");
    }
    | DO statement WHILE ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE SEMICOLON
    {
        $$ = create_node("iteration_statement", "do-while");
        add_child($$, $2);
        add_child($$, $5);
        put("iteration_statement -> 'do' statement 'while' '(' expression ')' ';'\n");
    }
    | FOR ROUND_BRACKET_OPEN expression_opt SEMICOLON expression_opt SEMICOLON expression_opt ROUND_BRACKET_CLOSE statement
    {
        $$ = create_node("iteration_statement", "for (opt; opt; opt)");
        if ($3) add_child($$, $3);
        if ($5) add_child($$, $5);
        if ($7) add_child($$, $7);
        add_child($$, $9);
        put("iteration_statement -> 'for' '(' expression_opt ';' expression_opt ';' expression_opt ')' statement\n");
    }
    | FOR ROUND_BRACKET_OPEN declaration expression_opt SEMICOLON expression_opt ROUND_BRACKET_CLOSE statement
    {
        $$ = create_node("iteration_statement", "for (declaration; opt; opt)");
        add_child($$, $3);
        if ($4) add_child($$, $4);
        if ($6) add_child($$, $6);
        add_child($$, $8);
        put("iteration_statement -> 'for' '(' declaration expression_opt ';' expression_opt ')' statement\n");
    }
    ;
jump_statement 
    : GOTO IDENTIFIER SEMICOLON
    {
        $$ = create_node("jump_statement", strcat("goto ", strcat($2, " ;")));
        put("jump_statement -> 'goto' IDENTIFIER ';'\n");
    }
    | CONTINUE SEMICOLON
    {
        $$ = create_node("jump_statement", "continue;");
        put("jump_statement -> 'continue' ';'\n");
    }
    | BREAK SEMICOLON
    {
        $$ = create_node("jump_statement", "break;");
        put("jump_statement -> 'break' ';'\n");
    }
    | RETURN expression_opt SEMICOLON
    {
        $$ = create_node("jump_statement", "return;");
        if ($2) add_child($$, $2);
        put("jump_statement -> 'return' expression_opt ';'\n");
    }
    ;

/* EXTERNAL DEFINITIONS */

translation_unit 
    : external_declaration
    {
        $$ = create_node("translation_unit", NULL);
        add_child($$, $1);
        put("translation_unit -> external_declaration\n");
        root = $$;
    }
    | translation_unit external_declaration
    {
        $$ = $1;
        add_child($$, $2);
        put("translation_unit -> translation_unit external_declaration\n");
    }
    ;

external_declaration
    : function_definition
    {
        $$ = $1;
        put("external_declaration -> function_definition\n");
    }
    | declaration
    {
        $$ = $1;
        put("external_declaration -> declaration\n");
    }
    ;

function_definition
    : declaration_specifiers declarator declaration_list_opt compound_statement
    {
        $$ = create_node("function_definition", NULL);
        add_child($$, $1);
        add_child($$, $2);
        if ($3) add_child($$, $3);
        add_child($$, $4);
        put("function_definition -> declaration_specifiers declarator declaration_list_opt compound_statement\n");
    }
    ;

declaration_list
    : declaration
    {
        $$ = create_node("declaration_list", NULL);
        add_child($$, $1);
        put("declaration_list -> declaration\n");
    }
    | declaration_list declaration
    {
        $$ = $1;
        add_child($$, $2);
        put("declaration_list -> declaration_list declaration\n");
    }
    ;

declaration_list_opt
    : declaration_list
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

declaration_specifiers
    : storage_class_specifier declaration_specifiers_opt
    {
        $$ = create_node("declaration_specifiers", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("declaration_specifiers -> storage_class_specifier declaration_specifiers_opt\n");
    }
    | type_specifier declaration_specifiers_opt
    {
        $$ = create_node("declaration_specifiers", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("declaration_specifiers -> type_specifier declaration_specifiers_opt\n");
    }
    | type_qualifier declaration_specifiers_opt
    {
        $$ = create_node("declaration_specifiers", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("declaration_specifiers -> type_qualifier declaration_specifiers_opt\n");
    }
    | function_specifier declaration_specifiers_opt
    {
        $$ = create_node("declaration_specifiers", NULL);
        add_child($$, $1);
        if ($2) add_child($$, $2);
        put("declaration_specifiers -> function_specifier declaration_specifiers_opt\n");
    }
    ;

declaration_specifiers_opt
    : declaration_specifiers
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

%%


void yyerror(char *s) {  
    printf("\n!ERROR:\n LINE: %d, %s\n", yylineno, s);
    exit(1);
}


