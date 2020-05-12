%{
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);}
#define MAX_LINE_LENG 256
int linenum = 1,i=0,j=0;
char buf[MAX_LINE_LENG];
char tmp[MAX_LINE_LENG];
char tmp1[MAX_LINE_LENG];
char c;
char *locate;
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
		free(symbolTables->items[i]->value);
		char * b = malloc(sizeof(char)*strlen(s));
		strcpy(b,s);
		symbolTables->items[i]->value=b;
		return;
	}

	while(symbolTables->hasvalue[symbolTables->count] && symbolTables->count<symbolTables->size){
		symbolTables->count++;
	}
	sitem *p = malloc(sizeof(sitem));
	p->key = symbolTables->count;
	char * b = malloc(sizeof(char)*strlen(s));
	strcpy(b,s);
	p->value = b;
	symbolTables->items[symbolTables->count] = p;
	symbolTables->hasvalue[symbolTables->count] = 1;
}
%}
%x C_COMMENT
real [+-]?[0-9]+\.[0-9]+
iderror [0-9]+[A-Za-z]+ 
nothing "//".*
delimiters [=(){}\[\];\.:,\+\-\*\/%><!]|"&&"|"\|\|"|"<="|">="|"=="|"!="
string \"[^"^\n]*\"
keywords "boolean"|"break"|"char"|"case"|"class"|"continue"|"def"|"do"|"else"|"exit"|"false"|"float"|"for"|"if"|"int"|"null"|"object"|"print"|"println"|"repeat"|"return"|"string"|"to"|"true"|"type"|"val"|"var"|"while"
id [a-zA-Z]+[0-9]*[A-Za-z]*
number [0-9]+
char [A-Za-z]
%%
"/*"            { 	LIST;
					BEGIN(C_COMMENT); 
				}
<C_COMMENT>"*/" { 	LIST;
					BEGIN(INITIAL); 
				}
<C_COMMENT>\n   {  	LIST;
        			printf("%d: %s", linenum++, buf);
        			buf[0] = '\0';}
<C_COMMENT>.    { LIST;}
{nothing} {LIST;};
{iderror} {LIST;
		 printf("%d:%s\n", linenum+1, buf);
         printf("bad character:'%s'\n",yytext);
         exit(-1);}
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
				yymore();
			}else{	
				tmp[0]='"';
				tmp[1]='"';
				tmp[2]= 0;
				memset(tmp1,0,MAX_LINE_LENG);
				strcpy(tmp1,yytext);
				locate = strstr(tmp1,tmp);
				i=locate-tmp1;
				while(i>0){
					for(j=i;j<strlen(tmp1)-1;j++){
						tmp1[j]=tmp1[j+1];
					}
					tmp1[strlen(tmp1)-1]=0;
					locate = strstr(tmp1,tmp);
					i=locate-tmp1;
				}
				tokenString("string",tmp1);
			}
			memset(tmp,0,MAX_LINE_LENG);
			unput(c);}			
\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }
{real} tokenString("real",yytext);
{number} tokenInteger("integer",atoi(yytext));
{keywords} {
			puts("into keyword");
			memset(tmp,0,MAX_LINE_LENG);
			strcpy(tmp,yytext);
			for(i=0;i<strlen(tmp);i++){
				tmp[i] = toupper(tmp[i]);
			}
			token(tmp);
			memset(tmp,0,MAX_LINE_LENG);}
{id} {
			tokenString("id",yytext);
			insert(yytext);}
. 	{
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
    }	
%%


main(int argc, char *argv[])
{
if(argc==2){
	yyin = fopen(argv[1],"r");
}else{
	puts("Format error!");
	return;
}
memset(tmp,0,MAX_LINE_LENG);
symbolTables = create();
yylex();
puts("Symbol Table:");
dump();
}

