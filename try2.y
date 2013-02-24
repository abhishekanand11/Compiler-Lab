%{
#include <stdio.h>
int yylex(void);
#include <stdlib.h>
 
struct typestruct{
		int value;
		int tag;
		char *name;
		struct typestruct* down;
		struct typestruct* left;
		struct typestruct* center;
		struct typestruct* right;
	};
typedef struct typestruct typestruct;
struct typestruct * makenode (int,int,char*,typestruct*,typestruct*,typestruct*,typestruct*);
void printTree(typestruct* );

%}

%token 	NUMBER IF THEN ELSE DECL ENDDECL INTEGER BEGINS ENDIF RETURN END READ WHILE WRITE ENDWHILE RECORD AND OR NOT
%token	IDENTIFIER LESSTHAN LESSTHANEQUALTO EQUALTO NOTEQUAL GREATERTHAN GREATERTHANEQUALTO SEMICOLON BOOLEAN WHITESPACE WHITESPACES 
%token	TAB TABS ADD SUB MUL DIV MAIN DO
%token	NE COMMENT ADDRESS MOD RSB LSB COMMA BE RCB LCB LP RP NEWLINE NEWLINES
%left OR
%left AND
%left NOT
%left LESSTHAN LESSTHANEQUALTO NOTEQUAL GREATERTHAN GREATERTHANEQUALTO
%right EQUALTO
%left ADD SUB
%left DIV MUL
%left MOD 
%start programme

%type <string> 
%type <type>  
%type <typestructure> programme functions NUMBER IDENTIFIER BOOLEAN
%type <typestructure> declstatements  start start_body statements functional
%type <typestructure> arith_expr character ifcond_expr while_cond condition assignment var conditional statement
%union{
	char *string;
	int type;
	struct typestruct *typestructure;
	}
%%
programme: declaration functions  {$$ = $2;}
		| functions {$$ = $1;}
	;
functions: INTEGER MAIN LP RP LCB declstatements RCB {$$ = makenode(1,0,"mainfunc",NULL,$6,NULL,NULL);printTree($$);}
	;
type: BOOLEAN|INTEGER
	;
declstatements:  declaration start  {$$ = $2;}
				| start {$$ = $1;}
	;
declaration: DECL decl_body ENDDECL
	;
decl_body: type vars_decl SEMICOLON 
	;
start: BEGINS start_body END {$$=$2;}
	;
start_body: statements RETURN arith_expr SEMICOLON {$$ = $1;$$->value = $3->value;}
	;
statements: statements statement {$$=$2; $$->down=$1;}
			| statement{$$=$1;}	
;
assignment: character EQUALTO arith_expr SEMICOLON {$$ = makenode(1,0,"=",$1,NULL,$3,NULL);}
	;
character: IDENTIFIER{$$=$1;}
			|IDENTIFIER LSB NUMBER RSB{$$=$1; $$->tag=$3->value+2;}
			|ADDRESS IDENTIFIER {$$=$2;}
	;
arith_expr:LP arith_expr RP{$$=$2;}
		|arith_expr ADD arith_expr{$$=makenode(1,0,"+",$1,NULL,$3,NULL);}
		|arith_expr SUB arith_expr{$$=makenode(1,0,"-",$1,NULL,$3,NULL);}
		|arith_expr MUL arith_expr{$$=makenode(1,0,"*",$1,NULL,$3,NULL);}
		|arith_expr DIV arith_expr{$$=makenode(1,0,"/",$1,NULL,$3,NULL);}
		|arith_expr MOD arith_expr{$$=makenode(1,0,"MOD",$1,NULL,$3,NULL);}
		|var{$$=$1;}
	;
var: NUMBER{$$=$1;}
		|character{$$=$1;}
	;
conditional: ifcond_expr{$$=$1;}
		|while_cond{$$=$1;}
	;
ifcond_expr:IF  condition  THEN statements ENDIF SEMICOLON{$$=makenode(1,0,"if",$2,NULL,$4,NULL);}
			| IF  condition  THEN statements ELSE statements  ENDIF SEMICOLON{$$=makenode(1,0,"ifelse",$2,$4,$6,NULL);}
	;

while_cond:WHILE  condition  DO statements ENDWHILE SEMICOLON{$$=makenode(1,0,"while",$2,NULL,$4,NULL);}
	;
condition: 	LP condition RP{$$=$2;}
		|arith_expr BE arith_expr{$$=makenode(1,0,"==",$1,NULL,$3,NULL);}
		|arith_expr NE arith_expr{$$=makenode(1,0,"!=",$1,NULL,$3,NULL);}
		|arith_expr GREATERTHANEQUALTO arith_expr{$$=makenode(1,0,">=",$1,NULL,$3,NULL);}
		|arith_expr GREATERTHAN arith_expr{$$=makenode(1,0,">",$1,NULL,$3,NULL);}
		|arith_expr LESSTHAN arith_expr{$$=makenode(1,0,"<",$1,NULL,$3,NULL);}
		|arith_expr LESSTHANEQUALTO arith_expr{$$=makenode(1,0,"<=",$1,NULL,$3,NULL);}
		|condition AND condition{$$=makenode(1,0,"AND",$1,NULL,$3,NULL);}
		|condition OR condition{$$=makenode(1,0,"OR",$1,NULL,$3,NULL);}
		|NOT condition{$$=makenode(1,0,"NOT",$2,NULL,NULL,NULL);}
		|BOOLEAN{$$=$1;}
	;

functional: READ LP IDENTIFIER RP SEMICOLON{$$=makenode(1,0,"read",$3,NULL,NULL,NULL);}
		|WRITE LP arith_expr RP SEMICOLON{$$=makenode(1,0,"write",$3,NULL,NULL,NULL);}
	;

statement: assignment {$$=$1;}
		| conditional {$$=$1;}
		| functional{$$=$1;}
	;
vars_decl: IDENTIFIER
		|vars_decl COMMA IDENTIFIER
	;

%%

typestruct* makenode (int tag,int value,char* name,typestruct* left,typestruct* center,typestruct* right,typestruct* down)
{
struct typestruct* temp = (typestruct *)malloc(sizeof(typestruct));
			temp->tag =  tag;
			temp->value =  value;
			temp->name =  name;
			temp->down =  down;
			temp->left = left;
			temp->center =  center;
			temp->right =  right;
return temp;
}

void printTree(typestruct* temp)
{

	if (temp!=NULL)
	{	
		printTree(temp->down);
		printf("( %s ",temp->name) ;
		if (temp->tag>1){printf("[%d] ",temp->tag-2);}
		printTree(temp->left);
		printTree(temp->center);
		printTree(temp->right);
		printf(" )\n");
		
	}
}		
int main (void) {
 	return yyparse();
	
	}
int yyerror (char *msg) {
	 return fprintf (stderr, "YACC: %s\n", msg);
	}
