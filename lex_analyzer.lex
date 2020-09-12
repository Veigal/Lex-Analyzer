/* Analisador léxico - Leonardo Veiga, Pedro Accorsi e Rafaela Kreusch*/

/* Todo*/
/* Identificar contexto*/

%option noyywrap

%{

#define MAX_VAR_LENGTH 30
#define MAX_VARS      100
#define MAX_CONTEXTS   15 

#include <math.h>
#include <stdbool.h>

//struct definition
typedef struct VariableIdentifier{
	char name[30];
	int id;
} varId;

typedef struct ContextIdentifier{
	varId variables[MAX_VARS];
} contextId;

//global var definition
int currentContext    = 0;
int idCounter         = 0 ;
bool isDeclaration    = false;
contextId allContexts[MAX_CONTEXTS];

void initContexts(){
	for(int i=0; i<MAX_CONTEXTS; i++){
		for(int j=0; j<MAX_VARS; j++){
			allContexts[i].variables[j].name[0] = '\0';
			allContexts[i].variables[j].id      = -1;
		}
	}
}

//global func implementation
void enterNewContext(){
	++currentContext;
}

void leaveContext(){
	--currentContext;
}

void addVarToContext(char *varName, int varId){
	for(int i=0; i<MAX_VARS; i++){
		if( allContexts[currentContext].variables[i].id == -1 ){
			allContexts[currentContext].variables[i].id   = varId;
			strcpy(allContexts[currentContext].variables[i].name, varName);
			return;
		}
	}
}

int getId(char *varName){
	int varId = 0;
	if(isDeclaration){
		isDeclaration = false;
		varId = idCounter++;
		addVarToContext(varName, varId);
		return varId;
	}
	for(int i=currentContext; i >= 0; i-- ){ 
		for(int j=0; j<MAX_VARS; j++){
        	if(allContexts[i].variables[j].id == -1)
				break;
				 
			if(strcmp(varName, allContexts[i].variables[j].name) == 0)
				return allContexts[i].variables[j].id;
			
		}
		
	}
	varId = idCounter++;
	addVarToContext(varName, varId);
	return varId;
}

%}


DIGIT	     [0-9]
WORD	     [a-zA-Z][a-zA-Z0-9]*
DFLOAT       [0-9]"."[0-9]*
LINE_COMMENT [//].*[\n]
INC          [#include <].*[>]
STR          ["].*["]
ARRAY        [[][DIGIT]*[]]
VAR_NORMAL   {WORD}[{ARRAY}]*
VAR_ADDRESS  [&]{WORD}

VAR_POINTER_PARENT     \*([ ])*\(([ ])*({WORD})+([ ])*\)           
VAR_POINTER            \*([ ])*({WORD})([ ])*
VAR_POINTER_OPERATION  \*([ ])*\(([ ])*({WORD})([ ])*([+]|[-]|\*|[/])*([ ])*({WORD})([ ])*\)






VAR {VAR_NORMAL}|{VAR_ADDRESS}|{VAR_POINTER_PARENT}|{VAR_POINTER}|{VAR_POINTER_OPERATION}
%%

{LINE_COMMENT}

"/*"([^*]|\*+[^*/])*\*+"/"		{ printf("Bloco de comentario");}

int|void|float|double|char|string|String {
	isDeclaration = true;
	printf("[reserved_word, %s]", yytext);

}
 
auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|string {
	printf("[reserved_word, %s]", yytext);
}

{INC} {	
	printf("[INCLUDE, %s]", yytext);
}

{DIGIT}+{VAR} { printf("[Expressao nao identificada: %s (%d)]", yytext, atoi(yytext));}
{DIGIT}+      { printf("[num, %d]", atoi(yytext))      ;}
{DFLOAT}      { printf("[num, %s]", yytext)            ;}

{VAR} { 

	printf("[%d,  %s]", getId(yytext), yytext) ;
}
{STR}         { printf("[[string_literal, %s]", yytext);}


"<"|"<="|"=="|"!="|">="|">" {printf("[Relational_Op, %s]", yytext);}

"+"|"-"|"*"|"/"|"++"|"--" {printf("[Arith_Op, %s]", yytext);}

"=" {printf("[Attrib_Op, %s]", yytext);}

"(" {printf("[l_paren, %s]", yytext);}

")" {printf("[r_paren, %s]", yytext);}

"{" { enterNewContext(); printf("[l_braces, %s]", yytext);}
"}" { leaveContext()   ; printf("[r_braces, %s]", yytext);}

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
	initContexts();
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
