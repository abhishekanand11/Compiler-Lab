%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>



struct typestruct{
		int value;
		int type;
		int tag;
		char *name;
		struct typestruct* down;
		struct typestruct* left;
		struct typestruct* center;
		struct typestruct* right;
	};

typedef struct typestruct typestruct;
struct typestruct * makenode (int,int,char*,typestruct*,typestruct*,typestruct*,typestruct*);
%}
ws		[ ]
wss		{ws}{ws}+
nl		[\n]
nls		{nl}{nl}+
tab		[\t]
tabs		{tab}{tab}+
letter		[A-Za-z]
digit		[0-9]
id		{letter}({letter}|{digit})*
number 		 {digit}+

%%
{ws}		{}
{wss}		{}
{nl}		{}
{nls}		{}
{tab}		{}
{tabs}		{}
{number}	{char *name = (char *)malloc(sizeof(yytext)); strcpy(name,yytext);
			 yylval.typestructure = makenode(0,atoi(yytext),name,NULL,NULL,NULL,NULL);return NUMBER;}
if      	{return IF;}
boolean		{return  BOOLEAN;}
TRUE		{return TRUE;}
FALSE		{return FALSE;}
then		{return THEN;}
else    	{return ELSE;}
do			{return DO;}
decl 		{ return DECL;}
enddecl		{ return ENDDECL;}
integer		{ return INTEGER;}
begin		{ return BEGINS;}
endif		{return ENDIF;}
return		{return RETURN;}	
end		{return END;}
read		{return READ;}
while		{return WHILE;}
write		{return WRITE;}
endwhile	{return ENDWHILE;}
record		{return RECORD;}
main		{return MAIN;}
AND		{return AND;}
OR		{return OR;}
NOT		{return NOT;}
{id}		{char *name = (char *)malloc(sizeof(yytext)); strcpy(name,yytext);
			yylval.typestructure = makenode(1,0,name,NULL,NULL,NULL,NULL); return IDENTIFIER;}
"<"		{return LESSTHAN;}
"<="		{return LESSTHANEQUALTO;}
"="		{return EQUALTO;}
"<>"		{return NOTEQUAL;}
">"		{return GREATERTHAN;}
">="		{return GREATERTHANEQUALTO;}
";"		{return SEMICOLON;}
"("		{return LP;}
")"	   	{return RP;}
"{" 		{return LCB;}
"}"		{return RCB;}
"=="		{return BE;}
","		{return COMMA;}
"["		{return LSB;}
"]"		{return RSB;}
"%"		{return MOD;}
"&"		{return ADDRESS;}
"+"		{return ADD;}
"-"		{return SUB;}
"*"		{return MUL;}
"/"		{return DIV;}
"//".*		{}
"!="		{return NE;}
