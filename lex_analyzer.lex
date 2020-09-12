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

//global func implementation
void initContexts(){
	for(int i=0; i<MAX_CONTEXTS; i++){
		for(int j=0; j<MAX_VARS; j++){
			allContexts[i].variables[j].name[0] = '\0';
			allContexts[i].variables[j].id      = -1;
		}
	}
}

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

char * cropEndOfLine(char * text){
	int len = strlen(yytext);
	if( yytext[len-1] == '\n')
		yytext[len-1] = 0;
	return yytext;
}

%}

DIGIT	               [0-9]
WORD	               [a-zA-Z][a-zA-Z0-9]*
DFLOAT                 [0-9]"."[0-9]*
LINE_COMMENT           [//].*[\n]
BLOCK_COMMENT          "/*"([^*]|\*+[^*/])*\*+"/"
INC                    [#include <].*[>]
STR                    ["].*["]
ARRAY                  [[][DIGIT]*[]]
VAR_NORMAL             {WORD}[{ARRAY}]*
VAR_ADDRESS            [&]{WORD}
VAR_POINTER_PARENT     \*([ ])*\(([ ])*({WORD})+([ ])*\)           
VAR_POINTER            \*([ ])*({WORD})([ ])*
VAR_POINTER_OPERATION  \*([ ])*\(([ ])*({WORD})([ ])*([+]|[-]|\*|[/])*([ ])*({WORD})([ ])*\)
VAR_DECLARATION        int|void|float|double|char|string|String
RESERVED_WORD          auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|string
VAR                    {VAR_NORMAL}|{VAR_ADDRESS}|{VAR_POINTER_PARENT}|{VAR_POINTER}|{VAR_POINTER_OPERATION}
RELATIONAL_OP          "<"|"<="|"=="|"!="|">="|">"     
ARITMETIC              "+"|"-"|"*"|"/"|"++"|"--"  
ATTRIBUTION            "="
OPEN_PARENTHESES       "("
CLOSE_PARENTHESES      ")"
OPEN_BRACKETS          "{"
CLOSE_BRACKETS         "}"
COMMA                  ","
END_OF_INSTRUCTION     ";"
OPEN_SQUARE_BRACKET    "["
CLOSE_SQUARE_BRACKET   "]"
  
%%

{LINE_COMMENT}              { printf("[Line comment: %s]"                       ,cropEndOfLine(yytext))  ;}
{BLOCK_COMMENT}             { printf("[comment block]"                          ,cropEndOfLine(yytext))  ;}
{VAR_DECLARATION}           { isDeclaration = true; printf("[reserved_word, %s]", yytext)                ;}
{RESERVED_WORD}             { printf("[reserved_word, %s]"                      , yytext)                ;}
{INC}                       { printf("[INCLUDE, %s]"                            , yytext)                ;}
{DIGIT}+{VAR}               { printf("[Expressao nao identificada: %s (%d)]"    , yytext, atoi(yytext))  ;}
{DIGIT}+                    { printf("[num, %d]"                                , atoi(yytext))          ;}
{DFLOAT}                    { printf("[num, %s]"                                , yytext)                ;}
{VAR}                       { printf("[%d,  %s]"                                , getId(yytext), yytext) ;}
{STR}                       { printf("[[string_literal, %s]"                    , yytext)                ;}
{RELATIONAL_OP}             { printf("[Relational_Op, %s]"                      , yytext)                ;}
{ARITMETIC}                 { printf("[Arith_Op, %s]"                           , yytext)                ;}
{ATTRIBUTION}               { printf("[Attrib_Op, %s]"                          , yytext)                ;}
{OPEN_PARENTHESES}          { printf("[l_paren, %s]"                            , yytext)                ;}
{CLOSE_PARENTHESES}         { printf("[r_paren, %s]"                            , yytext)                ;}
{OPEN_BRACKETS}             { enterNewContext(); printf("[l_braces, %s]"        , yytext)                ;}
{CLOSE_BRACKETS}            { leaveContext();    printf("[r_braces, %s]"        , yytext)                ;}
{COMMA}                     { printf("[comma, %s]"                              , yytext)                ;}
{END_OF_INSTRUCTION}        { printf("[semicolon, %s]"                          , yytext)                ;}
{OPEN_SQUARE_BRACKET}       { printf("[l_bracket, %s]"                          , yytext)                ;}
{CLOSE_SQUARE_BRACKET}      { printf("[l_bracket, %s]"                          , yytext)                ;}
"{"[\^{}}\n]*"}"	                                                                                     

%%

int main(int argc, char *argv[]){
	initContexts();
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}
