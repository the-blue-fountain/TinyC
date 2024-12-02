#include <stdio.h>
#include<stdlib.h>
#include<string.h>
#include "lex.yy.c"

struct Node {
    char* value;
    char* token;
    int frequency;
    struct Node* next;
};

// Map structure
struct Map {
    struct Node* head;
};

struct Map* map;
// Function to create a new map
struct Map* createMap() {
    struct Map* map = (struct Map*)malloc(sizeof(struct Map));
    map->head = NULL;
    return map;
}

// Function to insert a new element into the map
void insert(struct Map* map, const char* value, const char* token, int frequency) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->value = strdup(value);
    newNode->token = strdup(token);
    newNode->frequency = frequency;
    newNode->next = map->head;
    map->head = newNode;
}

// Function to find a node by its value
struct Node* find(struct Map* map, const char* value) {
    struct Node* current = map->head;
    while (current != NULL) {
        if (strcmp(current->value, value) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

// Function to print the linked list
void printMap(struct Map* map) {
    struct Node* current = map->head;
    while (current != NULL) {
        printf("\tValue: %s,\t\tToken: %s,\t\t\n", current->value, current->token);
        current = current->next;
    }
}

// Function to free the memory used by the map
void freeMap(struct Map* map) {
    struct Node* current = map->head;
    while (current != NULL) {
        struct Node* temp = current;
        current = current->next;
        free(temp->value);
        free(temp->token);
        free(temp);
    }
    free(map);
}

//track line number
extern int linecount;

/* A helper function to print the token type */
void print_token(int token) {
    struct Node * node;
    switch(token) {
        case KEYWORD: 
            printf("KEYWORD(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "KEYWORD", 1);
            } else {
                node->frequency++;
            }
            break;
        case IDENTIFIER: 
            printf("IDENTIFIER(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "IDENTIFIER", 1);
            } else {
                node->frequency++;
            }
            break;
        case INTEGER_CONSTANT: 
            printf("INTEGER_CONSTANT(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "INTEGER_CONSTANT", 1);
            } else {
                node->frequency++;
            }
            break;
        case FLOATING_CONSTANT: 
            printf("FLOATING_CONSTANT(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "FLOATING_CONSTANT", 1);
            } else {
                node->frequency++;
            }
            break;
        case CHARACTER_CONSTANT: 
            printf("CHARACTER_CONSTANT(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "CHARACTER_CONSTANT", 1);
            } else {
                node->frequency++;
            }
            break;
        case STRING_LITERAL: 
            printf("STRING_LITERAL(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "STRING_LITERAL", 1);
            } else {
                node->frequency++;
            }
            break;
        case PUNCTUATOR: 
            printf("PUNCTUATOR(%s)", yytext); 
            node = find(map, yytext);
            if(node ==NULL){
                insert(map, yytext, "PUNCTUATOR", 1);
            } else {
                node->frequency++;
            }
            break;
        default: 
            printf("UNKNOWN TOKEN(%s)", yytext); 
            break;
    }
}

int main() {
    map = createMap();
    int token, prev = -1;

    /* Call yylex in a loop to process the entire input */
    while((token = yylex()) != 0) {
        if (prev != linecount || prev == -1) {
            printf("LINE %d:\n", linecount);
            prev = linecount;
        }
        printf("\t");
        print_token(token);
        printf("\n");
    }
    printf("\nSYMBOL TABLE:\n");
    printMap(map);
    freeMap(map);

    return 0;
}
