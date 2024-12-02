/*
C file for running the parser
Please check makefile for usage
*/

#include <stdio.h>
#include <string.h>
#include <stdio.h>
#include "y.tab.c"

struct TreeNode *root;

void printTree(struct TreeNode *root, int level)
{
	if (root == NULL)
		return;
	for (int i = 0; i < level; i++)
		printf("  ");

	printf("-->");
	printf("%s", root->type);
	if (root->value != NULL)
		printf("(%s)", root->value);
	printf("\n");
	for (int i = 0; i < root->num_children; i++)
		printTree(root->children[i], level + 1);
}

int main()
{
	printf("Parse Tree will be printed at the end if parsing is successfull\n\n");
	printf("PARSING:\n");
	yyparse();
	printf("\nPARSING COMPLETE\n");
	printf("\n\n");
	printf("PARSE TREE:\n\n");
	printTree(root, 0);
}




