%{
#include <stdio.h>
int yylex(void);
#include <stdlib.h>
 
struct typestruct{
		int type; ;//0->void,1->int,2->boolean
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


struct Gsymbol {
					//@@@@@##### LOCAL SYMBOLS #####@@@@@
char *NAME; // Name of the Identifier
int TYPE; // TYPE can be INTEGER or BOOLEAN
		/***The TYPE field must be a TypeStruct if user defined types are allowed***/
int SIZE; // Size field for arrays
int BINDING; // Address of the Identifier in Memory
struct Gsymbol *NEXT; // Pointer to next Symbol Table Entry */
}*groot,*gtype;


struct Lsymbol {
					//@@@@@##### GLOBAL SYMBOLS #####@@@@@
char *NAME; // Name of the Identifier
int TYPE; // TYPE can be INTEGER or BOOLEAN
		/***The TYPE field must be a TypeStruct if user defined types are allowed***/
int BINDING; // Address of the Identifier in Memory
struct Lsymbol *NEXT; // Pointer to next Symbol Table Entry */
} *lroot,*ltype;

void Linstall(char *NAME,int TYPE);
void Ginstall(char *NAME,int TYPE,int SIZE); // Installation
struct Gsymbol *Glookup(char *NAME); // Look up for a global identifier
struct Lsymbol *Llookup(char *NAME); // Look up for a global identifier
int typeseen;
%}



%token 	NUMBER IF THEN ELSE DECL ENDDECL INTEGER BEGINS ENDIF RETURN END READ WHILE WRITE ENDWHILE RECORD AND OR NOT
%token	IDENTIFIER LESSTHAN LESSTHANEQUALTO EQUALTO NOTEQUAL GREATERTHAN GREATERTHANEQUALTO SEMICOLON BOOLEAN WHITESPACE WHITESPACES 
%token	TAB TABS ADD SUB MUL DIV MAIN DO TRUE FALSE
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

 
%type <typestructure> programme functions NUMBER IDENTIFIER BOOLEAN  TRUE FALSE
%type <typestructure> declstatements  start start_body statements functional
%type <typestructure> arith_expr character ifcond_expr while_cond condition assignment var conditional statement
%union{
	char *string;
	int type;
	struct typestruct *typestructure;
	}
%%
programme: gdeclaration functions  {$$ = $2;}
		| functions {$$ = $1;}
	;
functions: INTEGER MAIN LP RP LCB declstatements RCB {$$ = makenode(1,0,"mainfunc",NULL,$6,NULL,NULL);printTree($$);}
	;
type: BOOLEAN{typeseen = 2;}
	|INTEGER{typeseen = 1;}
	;
declstatements:  declaration start  {$$ = $2;}
				| start {$$ = $1;}
	;
gdeclaration: DECL gdecl_body ENDDECL
	;
gdecl_body: gdecl_body type gvars_decl SEMICOLON
			|type gvars_decl SEMICOLON 
	;
gvars_decl: ch 
		|gvars_decl COMMA ch 
	;
ch: IDENTIFIER {Ginstall($1->name,typeseen,0);}
		|IDENTIFIER LSB NUMBER RSB{Ginstall($1->name,typeseen,$3->value);}
	;
declaration: DECL decl_body ENDDECL
	;
decl_body: decl_body type vars_decl SEMICOLON 
		|type vars_decl SEMICOLON 
	;
vars_decl: IDENTIFIER{Linstall($1->name,typeseen);}
		|vars_decl COMMA IDENTIFIER{Linstall($3->name,typeseen);}
	;
start: BEGINS start_body END {$$=$2;}
	;
start_body: statements RETURN arith_expr SEMICOLON {$$ = $1;$$->value = $3->value;}
	;
statements: statements statement {$$=$2; $$->down=$1;}
			| statement{$$=$1;}	
;
assignment: character EQUALTO arith_expr SEMICOLON {$$ = makenode(1,0,"=",$1,NULL,$3,NULL); if ($1->type == $3->type)
																		{$$->type = 0;} else {printf("type error");}}
			|character EQUALTO condition SEMICOLON{$$ = makenode(1,0,"=",$1,NULL,$3,NULL); if ($1->type == $3->type)
																		{$$->type = 0;} else {printf("type error");}}
	;
character: IDENTIFIER{$$=$1;gtype = Glookup($1->name);
							ltype = Llookup($1->name);
							if (ltype){$$->type = ltype->TYPE;}
							else if(gtype){$$->type = gtype->TYPE;}
							else {printf("identifier %s not defined \n",$1->name);}}
			|IDENTIFIER LSB arith_expr RSB{$$=$1; $$->tag=$3->value+2;
							gtype = Glookup($1->name);
							if(gtype){$$->type = gtype->TYPE;}
							else {printf("identifier %s not defined \n",$1->name);}}
			|ADDRESS IDENTIFIER {$$=$2;}
	;
arith_expr:LP arith_expr RP{$$=$2;}
		|arith_expr ADD arith_expr{$$=makenode(1,0,"+",$1,NULL,$3,NULL); if ($1->type == 1 && $3->type ==1)
																				{$$->type =1;} else {printf("type error");}}
		|arith_expr SUB arith_expr{$$=makenode(1,0,"-",$1,NULL,$3,NULL); if ($1->type == 1 && $3->type ==1)
																				{$$->type =1;} else {printf("type error");}}
		|arith_expr MUL arith_expr{$$=makenode(1,0,"*",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =1;} else {printf("type error");}}
		|arith_expr DIV arith_expr{$$=makenode(1,0,"/",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =1;} else {printf("type error");}}
		|arith_expr MOD arith_expr{$$=makenode(1,0,"MOD",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =1;} else {printf("type error");}}
		|var{$$=$1;}
	;
var: NUMBER{$$=$1;$$->type = 1;}
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
		|arith_expr BE arith_expr{$$=makenode(1,0,"==",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =2;} else {printf("type error");}}
		|arith_expr NE arith_expr{$$=makenode(1,0,"!=",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =2;} else {printf("type error");}}
		|arith_expr GREATERTHANEQUALTO arith_expr{$$=makenode(1,0,">=",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =2;} else {printf("type error");}}
		|arith_expr GREATERTHAN arith_expr{$$=makenode(1,0,">",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =2;} else {printf("type error");}}
		|arith_expr LESSTHAN arith_expr{$$=makenode(1,0,"<",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =2;} else {printf("type error");}}
		|arith_expr LESSTHANEQUALTO arith_expr{$$=makenode(1,0,"<=",$1,NULL,$3,NULL);if ($1->type == 1 && $3->type ==1)
																				{$$->type =2;} else {printf("type error");}}
		|condition AND condition{$$=makenode(1,0,"AND",$1,NULL,$3,NULL);if ($1->type == 2 && $3->type ==2)
																				{$$->type =2;} else {printf("type error");}}
		|condition OR condition{$$=makenode(1,0,"OR",$1,NULL,$3,NULL);if ($1->type == 2 && $3->type ==2)
																				{$$->type =2;} else {printf("type error");}}
		|NOT condition{$$=makenode(1,0,"NOT",$2,NULL,NULL,NULL);if ($2->type == 2)
																				{$$->type =2;} else {printf("type error");}}
		|TRUE{$1=makenode(1,0,"True",NULL,NULL,NULL,NULL);$$=$1;$$->type=2;}
		|FALSE{$1=makenode(1,0,"False",NULL,NULL,NULL,NULL);$$=$1;$$->type=2;}
	;

functional: READ LP IDENTIFIER RP SEMICOLON{$$=makenode(1,0,"read",$3,NULL,NULL,NULL);}
		|WRITE LP arith_expr RP SEMICOLON{$$=makenode(1,0,"write",$3,NULL,NULL,NULL);}
	;

statement: assignment {$$=$1;}
		| conditional {$$=$1;}
		| functional{$$=$1;}
	;



%%

typestruct* makenode (int tag,int value,char* name,typestruct* left,typestruct* center,typestruct* right,typestruct* down)
{
struct typestruct* temp = (typestruct *)malloc(sizeof(typestruct));
			temp->type = 3;
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

struct Gsymbol *Glookup(char *NAME)
{
	struct Gsymbol * gtemp = groot;
	
	while (gtemp) 
	{
		if (strcmp(gtemp->NAME,NAME)==0)
			{
			return gtemp;
			}
		else 
			{
			gtemp = gtemp->NEXT;
			}
	}
	
			return NULL;
}

struct Lsymbol *Llookup(char *NAME)
{
	struct Lsymbol * ltemp = lroot;
	
	while (ltemp) 
	{
		if (strcmp(ltemp->NAME,NAME)==0)
			{
			return ltemp;
			}
		else 
			{
				ltemp = ltemp->NEXT;
			}
	}
			return NULL;
}


void Linstall(char *NAME  , int TYPE)
{
	struct Lsymbol * ltemp = lroot;
	if (Llookup(NAME)== NULL)
	{
	struct Lsymbol * temp = (struct Lsymbol *)malloc(sizeof (struct Lsymbol));
	temp->NAME = NAME;
	temp->TYPE = TYPE;
	temp->NEXT = ltemp;
	lroot = temp;
	
	}
	else
		{
			printf("identifier %s already declared \n ",NAME);
		}
} 

void Ginstall(char *NAME  , int TYPE, int SIZE)
{
	struct Gsymbol * gtemp = groot;
	if (Glookup(NAME)== NULL)
	{
	struct Gsymbol * temp = (struct Gsymbol *)malloc(sizeof (struct Gsymbol));
	temp->NAME = NAME;
	temp->TYPE = TYPE;
	temp->SIZE = SIZE;
	temp->NEXT = gtemp;
	groot = temp;
	}
	else
		{
			printf("identifier %s already declared \n",NAME);
		}
} 


		
int main (void) 
	{
 	return yyparse();
	}

int yyerror (char *msg) 
	{
	 return fprintf (stderr, "YACC: %s\n", msg);
	}
