%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);}
#define MAX_LINE_LENG 256
int linenum = 1,i=0;
char buf[MAX_LINE_LENG];
char tmp[MAX_LINE_LENG];
char* keywords[28] = {"BOOLEAN","BREAK","CHAR","CASE","CLASS","CONTINUE","DEF","DO","ELSE","EXIT","FALSE","FLOAT","FOR","IF","INT","NULL","OBJECT","PRINT","PRINTLN","REPEAT","RETURN","STRING","TO","TRUE","TYPE","VAL","VAR","WHILE"};
char c;
typedef struct {
    int key;
    char* value;
} sitem;

typedef struct {
    int size;
    int count;
    int* hasvalue;
    sitem** items;
} s_table;

s_table* symbolTables;

s_table* create() {
    s_table* ht = malloc(sizeof(s_table));
    ht->size = 60;
    ht->count = 1;
    ht->hasvalue = malloc(sizeof(int)*ht->size);
    for(i=0;i<ht->size;i++){
    	ht->hasvalue[i]=0;
    }
    memset(ht->hasvalue,0,ht->size = 60);
    ht->items = calloc((size_t)ht->size, sizeof(sitem*));
    return ht;
}

int lookup(char *s){
	for(i=0;i<symbolTables->size;i++){
		if(symbolTables->hasvalue[i]){
			if(strcmp(symbolTables->items[i]->value,s)==0){
				return i;
			}
		}
	}
	return 0;
}
void dump(){
	for(i=0;i<symbolTables->size;i++){
		if(symbolTables->hasvalue[i]){
			puts(symbolTables->items[i]->value);
		}
	}
}
void insert(char *s){
	if(i=lookup(s)){
		//printf("free %d\n",i);
		free(symbolTables->items[i]->value);
		char * b = malloc(sizeof(char)*strlen(s));
		strcpy(b,s);
		symbolTables->items[i]->value=b;
		//printf("refresh sym %s\n",symbolTables->items[i]->value);
		return;
	}

	while(symbolTables->hasvalue[symbolTables->count] && symbolTables->count<symbolTables->size){
		symbolTables->count++;
	}
	//printf("%d___\n",symbolTables->count);
	sitem *p = malloc(sizeof(sitem));
	p->key = symbolTables->count;
	char * b = malloc(sizeof(char)*strlen(s));
	strcpy(b,s);
	p->value = b;
	//printf("insert into %d\n",symbolTables->count);
	symbolTables->items[symbolTables->count] = p;
	symbolTables->hasvalue[symbolTables->count] = 1;
}
%}
real [+-]?[0-9]+\.[0-9]+
iderror [0-9]+[A-Za-z]+ 
nothing "/*".*"*/"|"//".*
delimiters [=(){}\[\];\.:,\+\-\*\/%<!]|"&&"|"\|\|"|"<="|">="|"=="|"!="
string \"[^"]*\"

id [a-zA-Z]+[0-9]*[A-Za-z]*
number [0-9]+
char [A-Za-z]
%%
{iderror} {LIST;
		 printf("%d:%s\n", linenum+1, buf);
         printf("bad character:'%s'\n",yytext);
         exit(-1);}
{nothing} {LIST;};
{delimiters} {	
			tmp[0]='\'';
			strcat(tmp,yytext);
			strcat(tmp,"'");
			token(tmp);
			memset(tmp,0,MAX_LINE_LENG);}
[\t ]*  {LIST;}
{string} {
			c = input();
			if(c=='"'){
				unput(c);		
				yymore();
			}else{
				tokenString("string",yytext);
				unput(c);
			}}			
\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }
{real} tokenString("real",yytext);
{number} tokenInteger("integer",atoi(yytext));
{id} {
		memset(tmp,0,MAX_LINE_LENG);
		strcat(tmp,yytext);
		i=0;
		while(tmp[i]){
			tmp[i]=toupper(tmp[i]);
			i++;
		}
		for (i=0;i<27;i++){
			if(strcmp(tmp,keywords[i])==0){
				i=99;
				token(tmp);
				memset(tmp,0,MAX_LINE_LENG);
				break;
			}
		}
		if(i!=99){
			tokenString("id",yytext);
			insert(yytext);
		}
		memset(tmp,0,MAX_LINE_LENG);}
. 	{
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
    }	
%%


main()
{
memset(tmp,0,MAX_LINE_LENG);
symbolTables = create();
yyin = fopen("test.c","r");
yylex();
puts("Symbol Table:");
dump();
}

