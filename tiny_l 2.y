%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern int yylineno;
extern int current_line;
extern int last_token_line;

void yyerror(const char *s);
%}

%union {
    char* sval;
    int ival;
    int line;
}

%token <sval> IDENT
%token <ival> NUMBER
%token PROGRAM BEGIN_PROGRAM END_PROGRAM
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE LOOP ENDLOOP READ WRITE
%token TRUE FALSE
%token AND OR NOT
%token ADD SUB MULT DIV
%token EQ NEQ LT GT LTE GTE
%token ASSIGN
%token L_PAREN R_PAREN
%token SEMICOLON COLON COMMA

%type <line> type

%left OR
%left AND
%left EQ NEQ
%left LT GT LTE GTE
%left ADD SUB
%left MULT DIV
%right NOT
%left L_PAREN R_PAREN

%%

// Start symbol
program:
    PROGRAM IDENT SEMICOLON declarations BEGIN_PROGRAM statements END_PROGRAM
    {
        printf("Production used: program -> program_declaration variable_declarations statement_list endprogram\n");
    }
;

// Declarations
declarations:
      /* empty */
    | declarations declaration
    | declarations error SEMICOLON
      {
        yyerror("invalid declaration");
        yyerrok;
      }
;

declaration:
    IDENT COLON type SEMICOLON
        {
            printf("Variable declaration: %s: integer\n", $1);
        }
  | IDENT COLON type
        {
            fprintf(stderr, "Syntax error at line %d: ';' expected\n", $3);
            yyclearin;
            yyerrok;
        }
  | IDENT INTEGER SEMICOLON
        {
            fprintf(stderr, "Syntax error at line %d: invalid declaration (missing ':')\n", yylineno);
            yyclearin;
            yyerrok;
        }
;

type:
      INTEGER { $$ = yylineno; }
    | ARRAY L_PAREN NUMBER R_PAREN OF INTEGER { $$ = yylineno; }
;

// Statements
statements:
      /* empty */
    | statements statement
    | statements error SEMICOLON
      {
        yyerror("invalid statement");
        yyerrok;
      }
;

statement:
      assignment_statement
    | if_statement
    | while_statement
    | read_statement
    | write_statement
;

// Assignment
assignment_statement:
    IDENT ASSIGN expression SEMICOLON
        {
            printf("Assignment operation: %s := expression\n", $1);
        }
  | IDENT EQ expression SEMICOLON
        {
            fprintf(stderr, "Syntax error at line %d: ':=' expected\n", yylineno);
            yyclearin;
            yyerrok;
        }
  | IDENT ASSIGN error SEMICOLON
        {
            yyerror("incomplete expression");
            yyclearin;
            yyerrok;
        }
  | IDENT error expression SEMICOLON
        {
            yyerror("invalid assignment operator");
            yyclearin;
            yyerrok;
        }
;

// If statement
if_statement:
      IF condition THEN statements ENDIF SEMICOLON
    | IF condition THEN statements ELSE statements ENDIF SEMICOLON
;

// While loop
while_statement:
    WHILE condition LOOP statements ENDLOOP SEMICOLON
;

// Read/Write
read_statement:
    READ id_list SEMICOLON
;

write_statement:
    WRITE id_list SEMICOLON
;

// ID List
id_list:
    IDENT
    | id_list COMMA IDENT
;

// Expressions
expression:
    simple_expression
  | error
    {
        yyerror("incomplete expression");
        yyclearin;
        yyerrok;
    }
;

simple_expression:
    simple_expression ADD term
    | simple_expression SUB term
    | term
;

term:
    term MULT factor
    | term DIV factor
    | factor
;

factor:
    IDENT
    | NUMBER
    | L_PAREN expression R_PAREN
    | TRUE
    | FALSE
    | NOT factor
;

// Conditions
condition:
    expression comparison_op expression
;

comparison_op:
    EQ
    | NEQ
    | LT
    | LTE
    | GT
    | GTE
;

%%

void yyerror(const char *s) {
    if (strcmp(s, "syntax error") != 0)
        fprintf(stderr, "Syntax error at line %d: %s\n", last_token_line, s);
}

int main() {
    return yyparse();
}