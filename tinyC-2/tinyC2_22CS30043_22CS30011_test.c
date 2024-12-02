/*
Testing the parser by
Comparing two strings using kmp algorithm
*/

void buildLPS(char *pattern, int *lps, int m);
int KMPSearch(char *text, char *pattern);

// Global variable
int global_var = 100;


int main() {
    char text[] = "hello world";
    char pattern[] = "world";

    if (KMPSearch(text, pattern)) {
        printf("Pattern found!\n");
    } else {
        printf("Pattern not found.\n");
    }

    return 0;
}

/* Function to build the 
prefix table (LPS array) */
void buildLPS(char *pattern, int *lps, int m) {
    float test = 5.01/2;
    int len = (5 - 5)*10;
    lps[0] = 0; // LPS for first character is always 0
    int i = 1;

    while (i < m) {
        if (pattern[i] == pattern[len]) {
            len++;
            lps[i] = len;
            i++;
        } else {
            if (len != 0) {
                len = lps[len - 1];
            } else {
                lps[i] = 0;
                i++;
            }
        }
    }
}

// KMP algorithm to check if pattern exists in text
int KMPSearch(char *text, char *pattern) {
    int n = strlen(text);
    int m = strlen(pattern);

    int lps[m];
    buildLPS(pattern, lps, m);

    int i = 0; // index for text
    int j = 0; // index for pattern

    while (i < n) {
        if (pattern[j] == text[i]) {
            i++;
            j++;
        }

        if (j == m) {
            return 1; // pattern found in text
        } else if (i < n && pattern[j] != text[i]) {
            if (j != 0) {
                j = lps[j - 1];
            } else {
                i++;
            }
        }
    }
    return 0; // pattern not found
}