%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tiny_l.tab.h"

#define YY_USER_ACTION column += yyleng;

extern YYSTYPE yylval;
int line = 1;
int column = 1;

int current_line = 1;
int last_token_line = 1;
%}

%option noyywrap noinput nounput

%%
"program"      { column += 7; current_line = yylineno; last_token_line = yylineno; return PROGRAM; }
"beginprogram" { column += 12; current_line = yylineno; last_token_line = yylineno; return BEGIN_PROGRAM; }
"endprogram"   { column += 10; current_line = yylineno; last_token_line = yylineno; return END_PROGRAM; }
"integer"      { column += 7; current_line = yylineno; last_token_line = yylineno; return INTEGER; }
"array"        { column += 5; current_line = yylineno; last_token_line = yylineno; return ARRAY; }
"of"           { column += 2; current_line = yylineno; last_token_line = yylineno; return OF; }
"if"           { column += 2; current_line = yylineno; last_token_line = yylineno; return IF; }
"then"         { column += 4; current_line = yylineno; last_token_line = yylineno; return THEN; }
"endif"        { column += 5; current_line = yylineno; last_token_line = yylineno; return ENDIF; }
"else"         { column += 4; current_line = yylineno; last_token_line = yylineno; return ELSE; }
"while"        { column += 5; current_line = yylineno; last_token_line = yylineno; return WHILE; }
"loop"         { column += 4; current_line = yylineno; last_token_line = yylineno; return LOOP; }
"endloop"      { column += 7; current_line = yylineno; last_token_line = yylineno; return ENDLOOP; }
"read"         { column += 4; current_line = yylineno; last_token_line = yylineno; return READ; }
"write"        { column += 5; current_line = yylineno; last_token_line = yylineno; return WRITE; }
"and"          { column += 3; current_line = yylineno; last_token_line = yylineno; return AND; }
"or"           { column += 2; current_line = yylineno; last_token_line = yylineno; return OR; }
"not"          { column += 3; current_line = yylineno; last_token_line = yylineno; return NOT; }
"true"         { column += 4; current_line = yylineno; last_token_line = yylineno; return TRUE; }
"false"        { column += 5; current_line = yylineno; last_token_line = yylineno; return FALSE; }
"-"            { column += 1; current_line = yylineno; last_token_line = yylineno; return SUB; }
"+"            { column += 1; current_line = yylineno; last_token_line = yylineno; return ADD; }
"*"            { column += 1; current_line = yylineno; last_token_line = yylineno; return MULT; }
"/"            { column += 1; current_line = yylineno; last_token_line = yylineno; return DIV; }
"="            { column += 1; current_line = yylineno; last_token_line = yylineno; return EQ; }
"<>"           { column += 2; current_line = yylineno; last_token_line = yylineno; return NEQ; }
"<="           { column += 2; current_line = yylineno; last_token_line = yylineno; return LTE; }
">="           { column += 2; current_line = yylineno; last_token_line = yylineno; return GTE; }
"<"            { column += 1; current_line = yylineno; last_token_line = yylineno; return LT; }
">"            { column += 1; current_line = yylineno; last_token_line = yylineno; return GT; }
":="           { column += 2; current_line = yylineno; last_token_line = yylineno; return ASSIGN; }
";"            { column += 1; current_line = yylineno; last_token_line = yylineno; return SEMICOLON; }
":"            { column += 1; current_line = yylineno; last_token_line = yylineno; return COLON; }
","            { column += 1; current_line = yylineno; last_token_line = yylineno; return COMMA; }
"("            { column += 1; current_line = yylineno; last_token_line = yylineno; return L_PAREN; }
")"            { column += 1; current_line = yylineno; last_token_line = yylineno; return R_PAREN; }

[0-9]+ {
    column += yyleng;
    current_line = yylineno;
    last_token_line = yylineno;
    yylval.ival = atoi(yytext);
    return NUMBER;
}

[a-zA-Z][a-zA-Z0-9_]* {
    column += yyleng;
    current_line = yylineno;
    last_token_line = yylineno;
    yylval.sval = strdup(yytext);
    return IDENT;
}

"--".*          { column += yyleng; /* skip comments */ }
[ \t]+          { column += yyleng; /* skip whitespace */ }

\n {
    yylineno++;
    column = 1;
}

. {
    printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, column, yytext);
    exit(EXIT_FAILURE);
}
%%
