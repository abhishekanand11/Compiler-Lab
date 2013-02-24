%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex(void);
    void yyerror(char *);

struct typestruct{
	int value;
	int index;
	char *name;
	struct typestruct* bottom;
	struct typestruct* left;
	struct typestruct* center;
	struct typestruct* right;
};
typedef struct typestruct typestruct;
typestruct * makenode ( int ,int ,char* ,typestruct* ,typestruct* ,typestruct* ,typestruct* );
void printTree(typestruct* );

%}
%start program

%token INT BOOL DECL ENDDECL RETURN BEGI END AND OR READ WRITE NOT
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE READ WRITE MAIN
%token OP_MINUS OP_ADD OP_MULT OP_DIVIDE OP_MODULO OP_ASSIGN 
%token RELOP_EQ RELOP_NE RELOP_LT RELOP_LE RELOP_GE RELOP_GT
%token ASSIGN LP RP  LSB RSB EOS
%token RCB LCB COMMA NUM ID TRUE FALSE ADDR 

%left OR
%left AND
%left RELOP_EQ RELOP_NE RELOP_LT RELOP_LE RELOP_GE RELOP_GT
%right OP_ASSIGN
%left OP_MINUS OP_ADD
%left OP_MULT OP_DIVIDE
%left OP_MODULO

%type <string> 
%type <type> 
%type <typestructure> program  maindef  body ID NUM
%type <typestructure> return stmts stmt bool equality expr term loc


%union{
	char *string;
	int type;
	struct typestruct *typestructure;}

%%

program:					
			|glode maindef {$$=$2;printTree($2);}
			;
glode:	DECL decls ENDDECL
		;
decls:	|	
		decls decl
		;
decl:	type ids EOS
		;
ids:	ide
		|ids COMMA ide
		;
ide:	ID
		|ID LSB NUM RSB
		;
type:	BOOL
		|INT
		;
maindef:INT MAIN LP RP body	{$$=makenode(0,0,"main",NULL,$5,NULL,NULL);}
		;
body:	LCB locde BEGI stmts return END RCB	{$$=$4;$$->value=$5->value;}
		;
locde:	DECL locdecls ENDDECL
locdecls:	|
		locdecls locdecl
		;
locdecl:	type locids EOS
		;
locids:	ID
		|locids COMMA ID
		;

return:	RETURN expr EOS {$$=$2;}
		;
stmts:				{$$=NULL;}
		stmts stmt	{$$=$2; $$->bottom=$1;}
		;
stmt:	loc OP_ASSIGN bool EOS 										{$$=makenode(0,0,"=",$1,NULL,$3,NULL);}
		|loc OP_ASSIGN expr EOS										{$$=makenode(0,0,"=",$1,NULL,$3,NULL);}
		|IF LP bool RP THEN stmts ENDIF EOS 						{$$=makenode(0,0,"branch",$3,NULL,$6,NULL);}
		|IF LP bool RP THEN stmts ELSE stmts ENDIF EOS			{$$=makenode(0,0,"branch-else",$3,$6,$8,NULL);}
		|WHILE LP bool RP DO stmts ENDWHILE EOS 				{$$=makenode(0,0,"iter",$3,NULL,$6,NULL);}
		;
loc:	ID	{$$=$1;}
		|ID LSB NUM RSB{ $$=$1; $$->index=$3->value+1;}
		;
bool:	bool OR bool	{$$=makenode(0,0,"OR",$1,NULL,$3,NULL);}
		|LP bool RP		{$$=$2;}
		|bool AND bool	{$$=makenode(0,0,"AND",$1,NULL,$3,NULL);}
		|equality		{$$=$1;}
		|TRUE			{$$=makenode(1,0,"TRUE",NULL,NULL,NULL,NULL);}
		|FALSE			{$$=makenode(0,0,"FALSE",NULL,NULL,NULL,NULL);}
		;
equality:	expr RELOP_EQ expr		{$$=makenode(0,0,"==",$1,NULL,$3,NULL);}
		|expr RELOP_NE expr			{$$=makenode(0,0,"!=",$1,NULL,$3,NULL);}
		|expr RELOP_LT expr			{$$=makenode(0,0,"<",$1,NULL,$3,NULL);}
		|expr RELOP_LE expr			{$$=makenode(0,0,"<=",$1,NULL,$3,NULL);}
		|expr RELOP_GE expr			{$$=makenode(0,0,">=",$1,NULL,$3,NULL);}
		|expr RELOP_GT expr			{$$=makenode(0,0,">",$1,NULL,$3,NULL);}
		
		;
expr:    	 expr OP_MINUS expr 		{$$=makenode(0,0,"-",$1,NULL,$3,NULL);}
		|expr OP_ADD expr				{$$=makenode(0,0,"+",$1,NULL,$3,NULL);}
		|expr OP_MULT expr				{$$=makenode(0,0,"*",$1,NULL,$3,NULL);}
		|expr OP_DIVIDE expr			{$$=makenode(0,0,"/",$1,NULL,$3,NULL);}
		|expr OP_MODULO expr			{$$=makenode(0,0,"MOD",$1,NULL,$3,NULL);}
		|term								{$$=$1;}
		;

term:  ID{$$=$1;}
		|ID LSB NUM RSB	{$$=$1;$$->index=$3->value+1;}
		|NUM{$$=$1;}
		;
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

typestruct* makenode(int value1,int index1,char* name1,typestruct* left1,typestruct* center1,typestruct* right1,typestruct* bottom1)
{
struct typestruct* temp =(typestruct *)malloc(sizeof(typestruct));
					temp->value=value1;
					temp->index=index1;
					temp->name=name1;
					temp->left=left1;
					temp->center=center1;
					temp->right=right1;
					temp->bottom=bottom1;
return temp;
}

void printTree(typestruct* temp){

	if (temp!=NULL){
		printf("( %s ",temp->name) ;
		if (temp->index>0){printf("[%d]  ",temp->index-1);}
		printTree(temp->left);
		printTree(temp->center);
		printTree(temp->right);
		printf(" )\n");
		printTree(temp->bottom);
	}
}		
int main(void) {
    yyparse();
    return 0;
}
