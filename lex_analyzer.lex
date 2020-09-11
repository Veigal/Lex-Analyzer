/* Analisador léxico - Leonardo Veiga, Pedro Accorsi e Rafaela Kreusch*/

/* Todo*/
/* Identificar contexto*/
/* Classificar ponteiros*/

%option noyywrap

%{

#include <math.h>

int aux=0;

int getNumber(){
	return ++aux;
}
%}


DIGIT	[0-9]
WORD	[a-zA-Z][a-zA-Z0-9]*
DFLOAT [0-9]"."[0-9]*
LINE_COMMENT [//].*[\n]
INC [#include <].*[>]
STR ["].*["]

ARRAY       [[][DIGIT]*[]]
VAR_NORMAL  {WORD}[{ARRAY}]*
VAR_POINTER [&]{WORD}

VAR_POINTER_PARENT \*\(({WORD})+\)


VAR {VAR_NORMAL}|{VAR_POINTER}|{VAR_POINTER_PARENT}
%%

{LINE_COMMENT}

"/*"([^*]|\*+[^*/])*\*+"/"		{ printf("Bloco de comentario");}

auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|string {
	printf("[reserved_word, %s]", yytext);
}

{INC} {	
	printf("[INCLUDE, %s]", yytext);
}

{DIGIT}+{VAR} { printf("[Expressao nao identificada: %s (%d)]", yytext, atoi(yytext));}

{DIGIT}+ { printf("[num, %d]", getNumber());}

{DFLOAT} {printf("[num, %s]", yytext);}

{VAR}	{printf("[id, %s]", yytext);}

{STR} 	{printf("[[string_literal, %s]", yytext);}


"<"|"<="|"=="|"!="|">="|">" {printf("[Relational_Op, %s]", yytext);}

"+"|"-"|"*"|"/"|"++"|"--" {printf("[Arith_Op, %s]", yytext);}

"=" {printf("[Attrib_Op, %s]", yytext);}

"(" {printf("[l_paren, %s]", yytext);}

")" {printf("[r_paren, %s]", yytext);}

"{" {printf("[l_braces, %s]", yytext);}

"}" {printf("[r_braces, %s]", yytext);}

"," {printf("[comma, %s]", yytext);}

";" {printf("[semicolon, %s]", yytext);}

"[" {printf("[l_bracket, %s]", yytext);}

"]" {printf("[l_bracket, %s]", yytext);}

"{"[\^{}}\n]*"}"	

[ \t]+ {printf("\t");}	

[ \n]+ {printf("\n");}		

.	printf("Caractere nao reconhecido: %s", yytext);

%%

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
