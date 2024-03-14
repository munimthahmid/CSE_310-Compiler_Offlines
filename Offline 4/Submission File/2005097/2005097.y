%{

#include<bits/stdc++.h>
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
#include "2005097_SymbolTable.h"
#include "2005097_CustomVector.h"
#include "2005097_Tree.h"

ofstream logout;
ofstream errorout;
ofstream ptout;
ofstream code;
ofstream temp;
ofstream opt;
SymbolTable *symbolTable;
Tree<string>parseTree;
extern int line_count;
extern int error_count;
extern char* yytext;
extern int yyerrflag;
int yyparse(void);
int yylex(void);
bool funcDefinition=false;
CustomVector<string>globalparameterList;
CustomVector<string>globalparameterTypeList;
string definedFuncName;
bool errorFlag=false;
int stackOffset;
void yyerror(const char *s) {
    
}
extern FILE *yyin;
extern int line_count;
using namespace std;
vector<pair<string,string>>mylist;
bool initialScope=false;
int parameterLine=0;

bool is_empty_line(const string& line) {
    return line.find_first_not_of(' ') == string::npos;
}

bool is_push_pop(const string& line) {
    return line.find("PUSH AX") != string::npos || line.find("POP AX") != string::npos;
}
	
void optimize_asm(const string& input_file, const string& output_file) {
    ifstream input(input_file);
    ofstream output(output_file);
	vector<string> lines;
    string line;
    if (!input.is_open()) {
        cerr << "Error: Unable to open input file: " << input_file << endl;
        return;
    }

    if (!output.is_open()) {
        cerr << "Error: Unable to open output file: " << output_file << endl;
        return;
    }
	 while (getline(input, line)) {
        if (!is_empty_line(line)) {
            lines.push_back(line);
        }
    }

    for (size_t i = 0; i < lines.size(); ++i) {
        if (is_push_pop(lines[i]) && i + 1 < lines.size() && is_push_pop(lines[i + 1])) {
            ++i;
            continue;
        }
        output << lines[i] << endl;
    }

    input.close();
    output.close();
}


void insertFunctionWithParameters(SymbolInfo *id,int begin,CustomVector<string>parameterList=CustomVector<string>(),CustomVector<string>parameterTypeList=CustomVector<string>())
{
	parameterLine=begin;
	definedFuncName=id->getName();
	SymbolInfo* lookUp=symbolTable->lookUp(id->getName());
	if(lookUp!=nullptr)
	{

		SymbolInfo* currentSymbol=symbolTable->lookUp(id->getName());
		
		if(currentSymbol->isFunction==false)
		{
			errorout<<"Line# "<<begin<<": '"<<id->getName()<<"' "<<"redeclared as different kind of symbol"<<endl;
			error_count++;

		}
		// did we filled the func's parameter list while declaring?- Yes
		else if(currentSymbol->parameterList.size!=parameterList.size)
		{
			errorout<<"Line# "<<begin<<": Conflicting types for '"<<id->getName()<<"'"<<endl;
			error_count++;


		}
		else if (currentSymbol->getType()!=id->getType())
		{
			errorout<<"Line# "<<begin<<": Conflicting types for '"<<id->getName()<<"'"<<endl;
			error_count++;


		}


	}


			//temporarily store the parameters in the global list.
		for(int i=0;i<parameterList.size;i++)
		{


			globalparameterList.push_back(parameterList.data[i]);
			globalparameterTypeList.push_back(parameterTypeList.data[i]);
		}


	

}
    
%}




%union{
SymbolInfo* symbol;
char* str;}




%token<symbol> RELOP ASSIGNOP LOGICOP  NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON IF ELSE FOR  INT FLOAT VOID   WHILE  CHAR DOUBLE RETURN   ADDOP MULOP INCOP CONST_INT CONST_FLOAT CONST_CHAR ID PRINTLN DECOP BITOP DO SWITCH DEFAULT BREAK CASE CONTINUE 
%token <str> ERROR_TOKEN


%type<symbol> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements statement expression_statement expression logic_expression variable rel_expression simple_expression term unary_expression factor argument_list arguments declaration_list LCURL_BEGIN
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%start start
%%
start : program { 
 	

	$$=new SymbolInfo("program","start");
	$$->begin=$1->begin;
	$$->end=$1->end;
		
	$$->parseTree.insert($$->type);
    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;

	
	$$->addChild({$1});
	

	// parseTree.preOrder();
	$$->parseTree.preOrder();
	// $$->preOrder();
	string result=symbolTable->printAll();
	$$->postOrder();
	// $$->parseTree.deleteTree();
	//ok
	
	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	logout<<"start : program "<<endl;
};
program : program unit { 
 	

	$$=new SymbolInfo("program unit","program");
	$$->begin=$1->begin;
	$$->end=$2->end;

	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->addChild({$1,$2});

	logout<<"program : program unit "<<endl;
}
| unit { 
 	

	$$=new SymbolInfo("unit","program");
	$$->begin=$1->begin;
	$$->end=$1->end;

	$$->parseTree.insert($$->type);
    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->addChild({$1});
	

	logout<<"program : unit "<<endl; //done
}
;
unit : var_declaration { 
 	

	$$=new SymbolInfo("var_declaration","unit");
	$$->begin=$1->begin;
	$$->end=$1->end;
	node<string>* root=parseTree.makeRoot($$->type);

	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);


	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});


	logout<<"unit : var_declaration  "<<endl; //done
}
| func_declaration { 
 	

	$$=new SymbolInfo("func_declaration","unit");
	$$->begin=$1->begin;
	$$->end=$1->end;


	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->addChild({$1});

	logout<<"unit : func_declaration "<<endl;
}
| func_definition { 

	$$=new SymbolInfo("func_definition","unit");
	$$->begin=$1->begin;
	$$->end=$1->end;

	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});


	logout<<"unit : func_definition  "<<endl;
}
;
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  { 


 	

	if(!symbolTable->lookUp($2->getName()))
	{
	
		bool insert=symbolTable->insertSymbolInCurrentScope($2->getName(),$1->getName(),true);

	}

	if(symbolTable->lookUp($2->getName()))
	{
		SymbolInfo *currentSymbol=symbolTable->lookUp($2->getName());

		for(int i=0;i<$4->parameterList.size;i++)
		{
			currentSymbol->parameterList.push_back($4->parameterList.data[i]);
			currentSymbol->parameterTypeList.push_back($4->parameterTypeList.data[i]);

			$$->parameterList.push_back($4->parameterList.data[i]);
			$$->parameterTypeList.push_back($4->parameterTypeList.data[i]);
		}
	}


	$$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON","func_declaration");
	$$->begin=$1->begin;
	$$->end=$6->end;




	$$->parseTree.insert($$->type);

	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$5->parseTree.insert($5->type); 
	$5->parseTree.root->begin=$5->begin;
	$5->parseTree.root->end=$5->end;
	$5->parseTree.root->isLeaf=true;
    $5->addChildLeaf($5);	$6->parseTree.insert($6->type); 
	$6->parseTree.root->begin=$6->begin;
	$6->parseTree.root->end=$6->end;
	$6->parseTree.root->isLeaf=true;
    $6->addChildLeaf($6);
	


	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;
	terminalsChild3->data=$5->name;
	terminalsChild4->data=$6->name;



    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);
    $5->parseTree.root->childNodes.push_back(terminalsChild3);
    $6->parseTree.root->childNodes.push_back(terminalsChild4);


	$2->parseTree.root->name=$2->name;
	$2->parseTree.root->type=$2->type;

	$3->parseTree.root->name=$3->name;
	$3->parseTree.root->type=$3->type;

	$5->parseTree.root->name=$5->name;
	$5->parseTree.root->type=$5->type;

	$6->parseTree.root->name=$6->name;
	$6->parseTree.root->type=$6->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
    $$->parseTree.root->childNodes.push_back($6->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$6->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->addChild({$1,$2,$3,$4,$5,$6});


	logout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "<<endl;

}
| type_specifier ID LPAREN RPAREN SEMICOLON { 

 	


	bool insert=symbolTable->insertSymbolInCurrentScope($2->getName(),$1->getName(),true);
	$$=new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON","func_declaration");
	$$->begin=$1->begin;
	$$->end=$5->end;


	$$->parseTree.insert($$->type);

	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);	$5->parseTree.insert($5->type); 
	$5->parseTree.root->begin=$5->begin;
	$5->parseTree.root->end=$5->end;
	$5->parseTree.root->isLeaf=true;
    $5->addChildLeaf($5);


	

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;
	terminalsChild3->data=$4->name;
	terminalsChild4->data=$5->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);
    $5->parseTree.root->childNodes.push_back(terminalsChild4);

	$2->parseTree.root->name = $2->name;
	$2->parseTree.root->type = $2->type;

	$3->parseTree.root->name = $3->name;
	$3->parseTree.root->type = $3->type;

	$4->parseTree.root->name = $4->name;
	$4->parseTree.root->type = $4->type;

	$5->parseTree.root->name = $5->name;
	$5->parseTree.root->type = $5->type;

	


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$5->end;

	$$->addChild({$1,$2,$3,$4,$5});



	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;
}
;
func_definition : type_specifier ID LPAREN parameter_list RPAREN {insertFunctionWithParameters(new SymbolInfo($2->getName(),$1->getName()),$4->end,$4->parameterList,$4->parameterTypeList);} compound_statement  { 
 	
	

	string tables=symbolTable->printAll();
	logout<<tables;
	symbolTable->exit();
	$$=new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement","func_definition");
	

	if(errorFlag==false)

	{


		$$->begin=$1->begin;
		$$->end=$7->end;
		//now insert the func name!
	SymbolInfo *function=symbolTable->lookUp($2->getName());

	//if not defined already then insert the func name
	if(function==nullptr)
	{
	symbolTable->currentScopeTable->insert($2->getName(),$1->getName(),true);
	SymbolInfo *function=symbolTable->lookUp($2->getName());
	for(int i=0;i<globalparameterList.size;i++)
	{
		function->parameterList.push_back(globalparameterList.data[i]);
		function->parameterTypeList.push_back(globalparameterTypeList.data[i]);


		

		$$->parameterList.push_back(globalparameterList.data[i]);
		$$->parameterTypeList.push_back(globalparameterTypeList.data[i]);


		$2->parameterList.push_back(globalparameterList.data[i]);
		$2->parameterTypeList.push_back(globalparameterTypeList.data[i]);
	}


	}


	globalparameterList.clear();
	globalparameterTypeList.clear();
	

	
	$$->parseTree.insert($$->type);


	//only for leafs

	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$5->parseTree.insert($5->type); 
	$5->parseTree.root->begin=$5->begin;
	$5->parseTree.root->end=$5->end;
	$5->parseTree.root->isLeaf=true;
    $5->addChildLeaf($5);	

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;
	terminalsChild3->data=$5->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);
    $5->parseTree.root->childNodes.push_back(terminalsChild3);

	$2->parseTree.root->name = $2->name;
	$2->parseTree.root->type = $2->type;

	$3->parseTree.root->name = $3->name;
	$3->parseTree.root->type = $3->type;

	$5->parseTree.root->name = $5->name;
	$5->parseTree.root->type = $5->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
    $$->parseTree.root->childNodes.push_back($7->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$7->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1,$2,$3,$4,$5,$7});


	logout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;

	}
	else
	{
	$$->begin=$1->begin;
	$$->end=$5->end;
	errorout<<"Line# "<<$3->end<<": Syntax error at parameter list of function definition"<<endl;
	error_count++;
	SymbolInfo *errorSymbol=new SymbolInfo("error","parameter_list");

	errorSymbol->begin=$3->end;
	errorSymbol->end=$5->begin;
	globalparameterList.clear();
	globalparameterTypeList.clear();
	

	$$->parseTree.insert($$->type);

	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	errorSymbol->parseTree.insert(errorSymbol->type); 
	errorSymbol->parseTree.root->begin=errorSymbol->begin;
	errorSymbol->parseTree.root->end=errorSymbol->end;
	errorSymbol->parseTree.root->isLeaf=true;

	$5->parseTree.insert($5->type); 
	$5->parseTree.root->begin=$5->begin;
	$5->parseTree.root->end=$5->end;
	$5->parseTree.root->isLeaf=true;
    $5->addChildLeaf($5);
		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;
	terminalsChild3->data=errorSymbol->name;
	terminalsChild4->data=$5->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);
    errorSymbol->parseTree.root->childNodes.push_back(terminalsChild3);
    $5->parseTree.root->childNodes.push_back(terminalsChild4);



	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

    $3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;

    $5->parseTree.root->name = $5->name;
    $5->parseTree.root->type = $5->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back(errorSymbol->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$5->end;
	errorFlag=false;
	}
	

	
}
| type_specifier ID LPAREN RPAREN  {{insertFunctionWithParameters(new SymbolInfo($2->getName(),$1->getName()),$2->end);}} compound_statement { 
 	

	$$=new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement","func_definition");
	$$->begin=$1->begin;
	$$->end=$6->end;



	//print the symbol table without name
	
	string tables=symbolTable->printAll();
	logout<<tables;
	symbolTable->exit();

	//now insert the func name!
	SymbolInfo *function=symbolTable->lookUp($2->getName());

	//if not defined already then insert the func name
	if(function==nullptr)
	{
	symbolTable->currentScopeTable->insert($2->getName(),$1->getName(),true);
	
	}

	$$->parseTree.insert($$->type);

	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);
		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;
	terminalsChild3->data=$4->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);


    $2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

    $3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;

    $4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;



	

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($6->parseTree.root);
	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$6->end;

	$$->addChild({$1,$2,$3,$4,$6});




	logout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
}
;
parameter_list : parameter_list COMMA type_specifier ID { 

	$$=new SymbolInfo("parameter_list COMMA type_specifier ID","parameter_list");
	$$->begin=$1->begin;
	$$->end=$4->end;


	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	$$->parameterList.push_back($4->getName());
	$$->parameterTypeList.push_back($3->getName());




	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$4->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $4->parseTree.root->childNodes.push_back(terminalsChild2);


    $2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

    $4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;




    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);

	$$->addChild({$1,$2,$3,$4});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$4->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;



	logout<<"parameter_list  : parameter_list COMMA type_specifier ID"<<endl;
}

| parameter_list COMMA type_specifier { 
 	

	$$=new SymbolInfo("parameter_list COMMA type_specifier","parameter_list");
	$$->begin=$1->begin;
	$$->end=$3->end;

	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

	$$->parseTree.insert($$->type);

	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);


    $2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->addChild({$1,$2,$3});


	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"parameter_list  : parameter_list COMMA type_specifier"<<endl;


}

| type_specifier ID { 

	$$=new SymbolInfo("type_specifier ID","parameter_list");
	$$->begin=$1->begin;
	$$->end=$2->end;

	$$->parameterList.push_back($2->getName());
	$$->parameterTypeList.push_back($1->getName());

	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);

    $2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1,$2});


	logout<<"parameter_list  : type_specifier ID"<<endl;



}
| type_specifier { 
 	

	$$=new SymbolInfo("type_specifier","parameter_list");
	$$->begin=$1->begin;
	$$->end=$1->end;

	//all scope will be here 
	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});


	logout<<"parameter_list  : type_specifier"<<endl;

}
|type_specifier error { 

	$$=new SymbolInfo("type_specifier ID","parameter_list");
	$$->begin=$1->begin;
	$$->end=$1->end;
	errorFlag=true;

	$$->parameterList.push_back("NN");
	$$->parameterTypeList.push_back($1->getName());

	

	logout<<"parameter_list  : type_specifier ID"<<endl;
    logout << "Error at line no " << line_count << " : " << "syntax error" << endl;




}
;
compound_statement : LCURL_BEGIN statements RCURL { 
 	
	
	$$=new SymbolInfo("LCURL statements RCURL","compound_statement");
	$$->begin=$1->begin;
	$$->end=$3->end;
	
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$3->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);


    $1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

    $3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;


	// $$->parseTree.preOrder();
	// ptout<<endl;
	// ptout<<endl;
	// ptout<<endl;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"compound_statement : LCURL statements RCURL  "<<endl;



}
| LCURL_BEGIN RCURL { 
 	

	string tables=symbolTable->printAll();
	$$=new SymbolInfo("LCURL RCURL","compound_statement");

	$$->begin=$1->begin;
	$$->end=$2->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
	
    $1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

    $2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);

	$$->addChild({$1,$2});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"compound_statement : LCURL RCURL  "<<endl;




}
;
LCURL_BEGIN :LCURL {
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->type=$1->type;

	symbolTable->enter();
	SymbolInfo *function=symbolTable->lookUp(definedFuncName);


	//function is just declared for the first time
		//insert the parameters in the symbol table.
		for(int i=0;i<globalparameterList.size;i++)
		{
				bool insert=symbolTable->insertSymbolInCurrentScope(globalparameterList.data[i],globalparameterTypeList.data[i]);

		if(!insert)
		{
				if(!insert)
		{
			errorout<<"Line# "<<parameterLine<<": Redefinition of parameter '"<<globalparameterList.data[i]<<"'"<<endl;
			error_count++;

		}
		}
		}

	



}
var_declaration : type_specifier declaration_list SEMICOLON { 


	if($2->idList.data[0]!="error")
	{
		for(int i=0;i<$2->idList.size;i++)
	{
		bool insert;
		if($1->getName()!="VOID")
		{

			
			if($2->isArray.data[i]==false)
		{
			 insert=symbolTable->insertSymbolInCurrentScope($2->idList.data[i],$1->getName());
				
		}
		else
		{
			 insert=symbolTable->insertSymbolInCurrentScope($2->idList.data[i],"ARRAY",false,true);

		}

		if(!insert)
		{

			SymbolInfo *currentSymbol=symbolTable->currentScopeTable->lookUp($2->idList.data[i]);
			if(currentSymbol->type!=$1->getName())
			{
				errorout<<"Line# "<<$2->begin<<": Conflicting types for'"<<$2->idList.data[i]<<"'"<<endl;
				error_count++;

			}

		}
		else
		{
			//inserted;
			SymbolInfo *currentSymbol=symbolTable->currentScopeTable->lookUp($2->idList.data[i]);
			string scopeId=symbolTable->currentScopeTable->getId();
			currentSymbol->scopeId=scopeId;
			if(scopeId=="1")
			{
				currentSymbol->varAsmName=currentSymbol->name;
			}
			else
			{
				// stackOffset+=2;
				// string offset=to_string(stackOffset);
				// string name= "[BP-" + offset + "]";


				// $$->varAsmNameList.push_back(name);
				// $$->stackOffsetList.push_back(stackOffset);

			}

		}
		}
		else
		{
			errorout<<"Line# "<<$1->begin<<": Variable or field '"<<$2->idList.data[i]<<"' declared void"<<endl;
			error_count++;

			
		}
		
	}

	}

 	

	$$=new SymbolInfo("type_specifier declaration_list SEMICOLON","var_declaration");
	$$->begin=$1->begin;
	$$->end=$3->end;


	$$->parseTree.insert($$->type);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$3->name;

    $3->parseTree.root->childNodes.push_back(terminalsChild1);

    $3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;




    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->addChild({$1,$2,$3});




	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	for(int i=0;i<$2->idList.size;i++)
	{
		$$->parseTree.root->idList.push_back($2->idList.data[i]);
		$$->parseTree.root->isArray.push_back($2->isArray.data[i]);
		$$->parseTree.root->arrLengthList.push_back($2->arrLengthList.data[i]);

		$$->idList.push_back($2->idList.data[i]);
		$$->isArray.push_back($2->isArray.data[i]);
		$$->idTypeList.push_back($1->getName());
		$$->arrLengthList.push_back($2->arrLengthList.data[i]);

	}

	
	$$->scopeId=symbolTable->currentScopeTable->getId();





	if(errorFlag==false)
	{
	logout<<"var_declaration : type_specifier declaration_list SEMICOLON  "<<endl; //done
		
	}
	errorFlag=false;

	//will push here into symbol table

}

;
type_specifier : INT { 
 	

	$$=new SymbolInfo("INT","type_specifier");
	
	// $$->parseTree.root->setBegin(2);
	$$->begin=$1->begin;
	$$->end=$1->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1); 	// SymbolInfo* leaf=new SymbolInfo(" ",$1->name);
    //         leaf->isLeaf=true;
    //         // $1->childrens.push_back(leaf);
	// $1->isLeaf=true;

	node<string>* terminalsChild1=new node<string>;
	terminalsChild1->data=$1->name;
    $1->parseTree.root->childNodes.push_back(terminalsChild1);

	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->addChild({$1});


	$$->begin=$1->begin;
	$$->end=$1->end;



	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	


	logout<<"type_specifier	: INT "<<endl;
}
| FLOAT { 
 	

	$$=new SymbolInfo("FLOAT","type_specifier");
	$$->begin=$1->begin;
	$$->end=$1->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);

		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);

	$$->addChild({$1});

	
	$1->parseTree.root->name = $1->name;
	$1->parseTree.root->type = $1->type;



	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
	logout<<"type_specifier	: FLOAT "<<endl; //done
}
| VOID { 
 	

	$$=new SymbolInfo("VOID","type_specifier");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;





    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->addChild({$1});

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	logout<<"type_specifier	: VOID"<<endl;
}
;
declaration_list : declaration_list COMMA ID { 
 	


	$1->idList.push_back($3->getName());
	$1->isArray.push_back(false);
	$1->arrLengthList.push_back(1);


	if($$->idList.data[0]=="error")
	{

	}
	else
	{
		$$=new SymbolInfo("declaration_list COMMA ID","declaration_list");
	$$->begin=$1->begin;
	$$->end=$3->end;

	for(int i=0;i<$1->idList.size;i++)
	{
		$$->idList.push_back($1->idList.data[i]);
		$$->isArray.push_back($1->isArray.data[i]);
		$$->arrLengthList.push_back($1->arrLengthList.data[i]);
	}
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;
    $3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;






    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	logout<<"declaration_list : declaration_list COMMA ID  "<<endl; //done
	}
	
	

}
| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE { 
 	
	$1->idList.push_back($3->getName());
	$1->isArray.push_back(true);
	$1->arrLengthList.push_back(stoi($5->name));

	$$=new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE","declaration_list");
	$$->begin=$1->begin;
	$$->end=$6->end;

	for(int i=0;i<$1->idList.size;i++)
	{
		$$->idList.push_back($1->idList.data[i]);
		$$->isArray.push_back($1->isArray.data[i]);
		$$->arrLengthList.push_back($1->arrLengthList.data[i]);

	}


	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);
	$5->parseTree.insert($5->type); 
	$5->parseTree.root->begin=$5->begin;
	$5->parseTree.root->end=$5->end;
	$5->parseTree.root->isLeaf=true;
    $5->addChildLeaf($5);
	$6->parseTree.insert($6->type); 
	$6->parseTree.root->begin=$6->begin;
	$6->parseTree.root->end=$6->end;
	$6->parseTree.root->isLeaf=true;
    $6->addChildLeaf($6);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;
	node<string>* terminalsChild5=new node<string>;

	terminalsChild1->data=$2->name;
	terminalsChild2->data=$3->name;
	terminalsChild3->data=$4->name;
	terminalsChild4->data=$5->name;
	terminalsChild5->data=$6->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);
    $5->parseTree.root->childNodes.push_back(terminalsChild4);
    $6->parseTree.root->childNodes.push_back(terminalsChild5);


	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;
    $3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;
    $4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;
    $5->parseTree.root->name = $5->name;
    $5->parseTree.root->type = $5->type;
    $6->parseTree.root->name = $6->name;
    $6->parseTree.root->type = $6->type;







    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
    $$->parseTree.root->childNodes.push_back($6->parseTree.root);

	$$->addChild({$1,$2,$3,$4,$5,$6});



	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<<endl;
}
| ID { 
 	


	$$=new SymbolInfo("ID","declaration_list");
	
	$$->idList.push_back($1->getName());
	$$->isArray.push_back(false);
	$$->arrLengthList.push_back(1);

	$$->begin=$1->begin;
	$$->end=$1->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);

	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;





    $$->parseTree.root->childNodes.push_back($1->parseTree.root);


	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;


	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});



	logout<<"declaration_list : ID "<<endl; //done
}
| ID LSQUARE CONST_INT RSQUARE { 
 	




	$$=new SymbolInfo("ID LSQUARE CONST_INT RSQUARE","declaration_list");
	$$->begin=$1->begin;
	$$->end=$4->end;

	
	$$->idList.push_back($1->getName());
	$$->isArray.push_back(true);
	$$->arrLengthList.push_back(stoi($3->name));


	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$3->name;
	terminalsChild4->data=$4->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $3->parseTree.root->childNodes.push_back(terminalsChild3);
    $4->parseTree.root->childNodes.push_back(terminalsChild4);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

	$3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;

	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;






    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);



	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$4->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1,$2,$3,$4});



	logout<<"declaration_list : ID LSQUARE CONST_INT RSQUARE "<<endl;
}
| error {

	$$=new SymbolInfo("error","declaration_list");
	
	$$->isArray.push_back(false);
	$$->arrLengthList.push_back(0);

	$$->begin=line_count;
	$$->end=line_count;

	errorout<<"Line# "<<$$->end<<": Syntax error at declaration list of variable declaration"<<endl;
	error_count++;

	$$->idList.push_back($$->getName());

	$$->parseTree.insert($$->type); 
	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	$$->parseTree.root->isLeaf=true;



	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$$->name;

    $$->parseTree.root->childNodes.push_back(terminalsChild1);






	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	errorFlag=true;

	logout<<"declaration_list : ID "<<endl; //done
	logout << "Error at line no " << line_count << " : " << "syntax error" << endl;

}
|declaration_list COMMA error {
	$$=new SymbolInfo("error","declaration_list");
	
	$$->isArray.push_back(false);
	$$->arrLengthList.push_back(0);

	$$->begin=line_count;
	$$->end=line_count;

	errorout<<"Line# "<<$$->end<<": Syntax error at declaration list of variable declaration"<<endl;
	error_count++;

	$$->idList.push_back($$->getName());

	$$->parseTree.insert($$->type); 
	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	$$->parseTree.root->isLeaf=true;



	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$$->name;

    $$->parseTree.root->childNodes.push_back(terminalsChild1);






	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	errorFlag=true;

	logout<<"declaration_list : declaration_list COMMA ID  "<<endl; //done

	logout << "Error at line no " << line_count << " : " << "syntax error" << endl;
}
;
statements : statement { 
 	
	//ekhane sob kichu list e dukate hobe
	$$=new SymbolInfo("statement","statements");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
		

		
		
	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;


	$$->addChild({$1});


	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"statements : statement  "<<endl;
}
| statements statement { 
 	

	$$=new SymbolInfo("statements statement","statements");
	$$->begin=$1->begin;
	$$->end=$2->end;
	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1,$2});



	logout<<"statements : statements statement  "<<endl;

}
;
statement : var_declaration { 
 	

	$$=new SymbolInfo("var_declaration","statement");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->addChild({$1});


	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;



	logout<<"statement : var_declaration "<<endl;
}
| expression_statement { 
 	

	$$=new SymbolInfo("expression_statement","statement");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->addChild({$1});



	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"statement : expression_statement  "<<endl;
}
| compound_statement { 
 	

	$$=new SymbolInfo("compound_statement","statement");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;


	$$->addChild({$1});


	string tables=symbolTable->printAll();
	logout<<tables;
	symbolTable->exit();

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"statement : compound_statement"<<endl;
}
| FOR LPAREN expression_statement expression_statement expression RPAREN statement { 
 	

	$$=new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement","statement");
	$$->begin=$1->begin;
	$$->end=$7->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$6->parseTree.insert($6->type); 
	$6->parseTree.root->begin=$6->begin;
	$6->parseTree.root->end=$6->end;
	$6->parseTree.root->isLeaf=true;
    $6->addChildLeaf($6);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$6->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $6->parseTree.root->childNodes.push_back(terminalsChild3);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

	$6->parseTree.root->name = $6->name;
    $6->parseTree.root->type = $6->type;





    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
    $$->parseTree.root->childNodes.push_back($6->parseTree.root);
    $$->parseTree.root->childNodes.push_back($7->parseTree.root);

	$$->addChild({$1,$2,$3,$4,$5,$6,$7});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
}
| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE { 
 	

	$$=new SymbolInfo("IF LPAREN expression RPAREN statement","statement");
	$$->begin=$1->begin;
	$$->end=$5->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);			

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$4->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);

	$$->addChild({$1,$2,$3,$4,$5});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$5->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;



	logout<<"statement : IF LPAREN expression RPAREN statement"<<endl;
}
| IF LPAREN expression RPAREN statement ELSE statement { 
 	

	$$=new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement","statement");
	$$->begin=$1->begin;
	$$->end=$7->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);
	$6->parseTree.insert($6->type); 
	$6->parseTree.root->begin=$6->begin;
	$6->parseTree.root->end=$6->end;
	$6->parseTree.root->isLeaf=true;
    $6->addChildLeaf($6);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$4->name;
	terminalsChild4->data=$6->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);
    $6->parseTree.root->childNodes.push_back(terminalsChild4);



	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

	$6->parseTree.root->name = $6->name;
    $6->parseTree.root->type = $6->type;

	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);
    $$->parseTree.root->childNodes.push_back($6->parseTree.root);
    $$->parseTree.root->childNodes.push_back($7->parseTree.root);

	$$->addChild({$1,$2,$3,$4,$5,$6,$7});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$7->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;
}
| WHILE LPAREN expression RPAREN statement { 
 	

	$$=new SymbolInfo("WHILE LPAREN expression RPAREN statement","statement");
	$$->begin=$1->begin;
	$$->end=$5->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$4->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);

	$$->addChild({$1,$2,$3,$4,$5});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$5->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"statement : WHILE LPAREN expression RPAREN statement"<<endl;
}
| PRINTLN LPAREN ID RPAREN SEMICOLON { 
 	

	$$=new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON","statement");
	$$->begin=$1->begin;
	$$->end=$5->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);	$5->parseTree.insert($5->type); 
	$5->parseTree.root->begin=$5->begin;
	$5->parseTree.root->end=$5->end;
	$5->parseTree.root->isLeaf=true;
    $5->addChildLeaf($5);			

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;
	node<string>* terminalsChild4=new node<string>;
	node<string>* terminalsChild5=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$3->name;
	terminalsChild4->data=$4->name;
	terminalsChild5->data=$5->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $3->parseTree.root->childNodes.push_back(terminalsChild3);
    $4->parseTree.root->childNodes.push_back(terminalsChild4);
    $5->parseTree.root->childNodes.push_back(terminalsChild5);


	$$->addChild({$1,$2,$3,$4,$5});




	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;

	$3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;

	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;

	$5->parseTree.root->name = $5->name;
    $5->parseTree.root->type = $5->type;

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);
    $$->parseTree.root->childNodes.push_back($5->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$5->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;
}
| RETURN expression SEMICOLON { 
 	

	$$=new SymbolInfo("RETURN expression SEMICOLON","statement");
	$$->begin=$1->begin;
	$$->end=$3->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
		
	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($2->parameterList.data[i]);
		$$->parameterTypeList.push_back($2->parameterTypeList.data[i]);
	}
	

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$3->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	

	$3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);


	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"statement : RETURN expression SEMICOLON"<<endl;
}
;
expression_statement : SEMICOLON { 
 	

	$$=new SymbolInfo("SEMICOLON","expression_statement");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);


	$$->addChild({$1});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"expression_statement : SEMICOLON"<<endl;
}
| expression SEMICOLON { 
 	

	$$=new SymbolInfo("expression SEMICOLON","expression_statement");
	$$->begin=$1->begin;
	$$->end=$2->end;
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	//here 
		for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}



	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);



	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);


	$$->addChild({$1,$2});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	
	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;

	if(errorFlag==false)
	logout<<"expression_statement : expression SEMICOLON 		 "<<endl;
	errorFlag=false;


}

;
variable : ID { 
 	
	$$=new SymbolInfo("ID","variable");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	


	SymbolInfo *currentSymbol=symbolTable->lookUp($1->getName());
	if(currentSymbol!=nullptr)
	{
	
		$$->parameterList.push_back(currentSymbol->getName());
		$$->parameterTypeList.push_back(currentSymbol->getType());
	}
	else
	{
		errorout<<"Line# "<<$1->begin<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
		error_count++;


	}
	
		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);



	$$->addChild({$1});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;





	$$->isSimpleId=true;
	$$->isId=true;
	$$->isThisArray=false;
	$$->stackPushed=false;
	// $$->val=stoi($1->getName());
	logout<<"variable : ID 	 "<<endl;
}
| ID LSQUARE expression RSQUARE { 
 	
	SymbolInfo *currentSymbol=symbolTable->lookUp($1->getName());
	if(currentSymbol!=nullptr)
	{
		if(currentSymbol->isThisArray==false)
		{
			errorout<<"Line# "<<$1->begin<<": '"<<$1->getName()<<"' "<<"is not an array"<<endl;
			error_count++;

		}
		else
		{

		if($3->parameterTypeList.data[0]!="CONST_INT")
		{
			errorout<<"Line# "<<$3->begin<<": "<<"Array subscript is not an integer"<<endl;
			error_count++;


		}
		else
		{
			$$->parameterList.push_back(currentSymbol->getName());

			$$->parameterTypeList.push_back(currentSymbol->getType());
		
			// cout<<$$->getName()<<" got "<<currentSymbol->getName()<<endl;
		
		}
		
		}
	}
	
		
	else
	{
		errorout<<"Line# "<<$1->begin<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
		error_count++;


	}

	$$=new SymbolInfo("ID LSQUARE expression RSQUARE","variable");
	$$->begin=$1->begin;
	$$->end=$4->end;
	$$->parameterList.push_back(currentSymbol->getName());

	$$->parameterTypeList.push_back(currentSymbol->getType());

	for(int i=0;i<$3->parameterList.size;i++)
	{
		$$->parameterList.push_back($3->parameterList.data[i]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[i]);
	}


	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$4->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);

	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;





    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);


	$$->addChild({$1,$2,$3,$4});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$4->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	$$->isThisArray=true;
	$$->stackPushed=$3->stackPushed;
	$$->val=$3->val;

	logout<<"variable : ID LSQUARE expression RSQUARE  	 "<<endl;
}
;
expression : logic_expression { 
 	

	$$=new SymbolInfo("logic_expression","expression");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);

	if($1->voidChecked==true) $$->voidChecked=true;


	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});


	$$->val=$1->val;
	$$->stackPushed=$1->stackPushed;

	$$->isId=$1->isId;
	$$->isSimpleId=$1->isSimpleId;

	
	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;



	logout<<"expression 	: logic_expression	 "<<endl;
}
| variable ASSIGNOP logic_expression { 
 	

	//inc dec of logic expression here
	$$=new SymbolInfo("variable ASSIGNOP logic_expression","expression");
	$$->begin=$1->begin;
	$$->end=$3->end;
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	
			if($1->voidChecked==false)
	{
			for(int i=0;i<$1->parameterList.size;i++)
	{

	if($1->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$1->end<<": Void cannot be used in expression "<<endl;
		error_count++;


	}
	

	}
	}

	if($3->voidChecked==false)
	{
	for(int i=0;i<$3->parameterList.size;i++)
	{

	if($3->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$3->end<<": Void cannot be used in expression "<<endl;
		error_count++;


	}
	


	}
	}	
	$1->voidChecked=true;
	$3->voidChecked=true;
	$$->voidChecked=true;
		
	for(int i=0;i<$1->parameterList.size;i++)
	{
		// cout<<"in .y variable assignop"<<$1->parameterList.data[0]<<endl;
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	
	for(int i=0;i<$3->parameterList.size;i++)
	{
		$$->parameterList.push_back($3->parameterList.data[i]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[i]);
	}
	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);


	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	if($3->modulusChecked==false)
	{
			if($1->parameterTypeList.data[0]=="INT" || $1->parameterTypeList.data[0]=="CONST_INT")
	{

		for(int i=0;i<$3->parameterList.size;i++)
		{
			if($3->parameterTypeList.data[i]=="CONST_FLOAT"||$3->parameterTypeList.data[i]=="FLOAT")
			{
			errorout<<"Line# "<<$3->end<<": Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
			error_count++;


			}
		}




	}
	}

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->isSimpleId=$3->isSimpleId;
	// $1->val=$3->val;



	logout<<"expression 	: variable ASSIGNOP logic_expression 		 "<<endl;
}
| error {
	$$=new SymbolInfo("error","expression");
	

	$$->begin=line_count;
	$$->end=line_count;

	errorout<<"Line# "<<$$->end<<": Syntax error at expression of expression statement"<<endl;
	error_count++;

	$$->idList.push_back($$->getName());

	$$->parseTree.insert($$->type); 
	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	$$->parseTree.root->isLeaf=true;



	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$$->name;

    $$->parseTree.root->childNodes.push_back(terminalsChild1);






	$$->parseTree.root->begin=$$->begin;
	$$->parseTree.root->end=$$->end;
	errorFlag=true;



	logout << "Error at line no " << line_count << " : " << "syntax error" << endl;
}

;
logic_expression : rel_expression { 
 	

	$$=new SymbolInfo("rel_expression","logic_expression");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
	$$->modulusChecked=$1->modulusChecked;

	if($1->voidChecked==true) $$->voidChecked=true;


	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	$$->addChild({$1});
	$$->isSimpleId=$1->isSimpleId;

	$$->val=$1->val;
	$$->stackPushed=$1->stackPushed;

	$$->isId=$1->isId;
	
	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;
	$$->isThisArray=$1->isThisArray;


	$$->containsNegative=$1->containsNegative;






	logout<<"logic_expression : rel_expression 	 "<<endl;
}
| rel_expression LOGICOP rel_expression { 
 	
	//inc dec of rel and rel here
	$$=new SymbolInfo("rel_expression LOGICOP rel_expression","logic_expression");
	$$->begin=$1->begin;
	$$->end=$3->end;
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
		
	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	for(int i=0;i<$3->parameterList.size;i++)
	{
		$$->parameterList.push_back($3->parameterList.data[i]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[i]);
	}
	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);



	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


			if($1->voidChecked==false)
	{
			for(int i=0;i<$1->parameterList.size;i++)
	{

	if($1->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$1->end<<": Void cannot be used in expression "<<endl;
		error_count++;


	}
	

	}
	}

	if($3->voidChecked==false)
	{
			for(int i=0;i<$3->parameterList.size;i++)
	{

	if($3->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$3->end<<": Void cannot be used in expression "<<endl;
		error_count++;
	

	}


	}
	}	
	$$->voidChecked=true;
	$1->voidChecked=true;
	$3->voidChecked=true;

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);


	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->isSimpleId=false;
	$$->stackPushed=true;

	$$->val=$1->val;

	$$->isId=$1->isId;


	logout<<"logic_expression : rel_expression LOGICOP rel_expression 	 	 "<<endl;
}
;
rel_expression : simple_expression { 
 	

	$$=new SymbolInfo("simple_expression","rel_expression");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
	$$->modulusChecked=$1->modulusChecked;

	if($1->voidChecked==true) $$->voidChecked=true;


	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	$$->addChild({$1});
	$$->isSimpleId=$1->isSimpleId;

	$$->val=$1->val;
	$$->stackPushed=$1->stackPushed;

	$$->isId=$1->isId;
	
	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;
	$$->isSimpleExpression=true;
	$$->isThisArray=$1->isThisArray;

	$$->containsNegative=$1->containsNegative;




	logout<<"rel_expression	: simple_expression "<<endl;
}
| simple_expression RELOP simple_expression { 
 	
	//inc dec of simple expression and simple expression here
	$$=new SymbolInfo("simple_expression RELOP simple_expression","rel_expression");
	$$->begin=$1->begin;
	$$->end=$3->end;

	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	for(int i=0;i<$3->parameterList.size;i++)
	{
		$$->parameterList.push_back($3->parameterList.data[i]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[i]);
	}	


			if($1->voidChecked==false)
	{
			for(int i=0;i<$1->parameterList.size;i++)
	{

	if($1->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$1->end<<": Void cannot be used in expression "<<endl;
		error_count++;


	}
	

	}
	}

	if($3->voidChecked==false)
	{
			for(int i=0;i<$3->parameterList.size;i++)
	{

	if($3->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$3->end<<": Void cannot be used in expression "<<endl;
		error_count++;


	}


	}
	}	
	$$->voidChecked=true;
	$1->voidChecked=true;
	$3->voidChecked=true;

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);


	

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);


	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	$$->isSimpleId=false;

	$$->stackPushed=true;

	$$->isId=false;

	$$->isSimpleExpression=false;


	logout<<"rel_expression	: simple_expression RELOP simple_expression	  "<<endl;
}
;
simple_expression : term { 
 	

	$$=new SymbolInfo("term","simple_expression");
	$$->begin=$1->begin;
	$$->end=$1->end;
	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	$$->modulusChecked=$1->modulusChecked;
	$$->parseTree.insert($$->type);

	if($1->voidChecked==true) $$->voidChecked=true;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	$$->addChild({$1});


	$$->val=$1->val;
	$$->isSimpleId=$1->isSimpleId;
	$$->stackPushed=$1->stackPushed;

	$$->isId=$1->isId;
	
	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;
	$$->isThisArray=$1->isThisArray;

	$$->containsNegative=$1->containsNegative;



	logout<<"simple_expression : term "<<endl;
}
| simple_expression ADDOP term { 
 	
	//inc dec of simp exp and term here
	$$=new SymbolInfo("simple_expression ADDOP term","simple_expression");
	$$->begin=$1->begin;
	$$->end=$3->end;
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);

	
				if($1->voidChecked==false)
	{
			for(int i=0;i<$1->parameterList.size;i++)
	{

	if($1->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$1->end<<": VFoid cannot be used in expression "<<endl;
		error_count++;


	}
	

	}
	}

	if($3->voidChecked==false)
	{
			for(int i=0;i<$3->parameterList.size;i++)
	{

	if($3->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$3->end<<": Void cannot be used in expression "<<endl;
		error_count++;

	}


	}
	}	
	$$->voidChecked=true;
	$1->voidChecked=true;
	$3->voidChecked=true;


	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);



	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

	for(int i=0;i<$3->parameterList.size;i++)
	{
		$$->parameterList.push_back($3->parameterList.data[i]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[i]);
	}


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);


	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	int val1=$1->val;
	int val2=$3->val;
	int val;
	if($2->getName()=="+")
	val=val1+val2;
	else 
	val=val1-val2;
	$$->val=val;
	$$->stackPushed=true;
	// cout<<"simple expression value: "<<$$->val<<endl;


	logout<<"simple_expression : simple_expression ADDOP term  "<<endl;
}
;
term : unary_expression { 
 	

	$$=new SymbolInfo("unary_expression","term");


	
	$$->begin=$1->begin;
	$$->end=$1->end;
	if($1->voidChecked==true) $$->voidChecked=true;

		for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}


	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});
	$$->isSimpleId=$1->isSimpleId;
	$$->val=$1->val;
	$$->stackPushed=$1->stackPushed;
	$$->isId=$1->isId;

	
	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;
	$$->isThisArray=$1->isThisArray;

	$$->containsNegative=$1->containsNegative;




	logout<<"term :	unary_expression "<<endl;
}
| term MULOP unary_expression { 
 	
	//inc dec of term and unary_expression here
	$$=new SymbolInfo("term MULOP unary_expression","term");
	$$->begin=$1->begin;
	$$->end=$3->end;
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);	

		for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

		for(int i=0;i<$3->parameterList.size;i++)
	{
		$$->parameterList.push_back($3->parameterList.data[i]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[i]);
	}

	if($1->voidChecked==false)
	{
			for(int i=0;i<$1->parameterList.size;i++)
	{

	if($1->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$1->end<<": Void cannot be used in expression "<<endl;
		error_count++;

	}
	

	}
	}

	if($3->voidChecked==false)
	{
		for(int i=0;i<$3->parameterList.size;i++)
	{

	if($3->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$3->end<<": Void cannot be used in expression "<<endl;
		error_count++;

	}


	}
	}	



	


		for(int i=0;i<$3->parameterList.size;i++)
	{

	if($2->getName()=="%" && !($3->parameterTypeList.data[i]=="INT" ||$3->parameterTypeList.data[i]=="CONST_INT"))
	{
		$$->modulusChecked=true;
		errorout<<"Line# "<<$3->end<<": Operands of modulus must be integers "<<endl;
		error_count++;

	}


	}

	if($3->parameterList.data[0]=="0")
	{
		errorout<<"Line# "<<$3->end<<": Warning: division by zero i=0f=1Const=0"<<endl;
		error_count++;

	}

	
	$$->voidChecked=true;
	$1->voidChecked=true;
	$3->voidChecked=true;
	
		

	
		
	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;


    $2->parseTree.root->childNodes.push_back(terminalsChild1);


	

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);


	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->stackPushed=true;

	logout<<"term :	term MULOP unary_expression "<<endl;
}
;
unary_expression : ADDOP unary_expression { 
 	
	//inc dec here
	$$=new SymbolInfo("ADDOP unary_expression","unary_expression");
	$$->begin=$1->begin;
	$$->end=$2->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);		
		if($2->voidChecked==false)
		{
			for(int i=0;i<$2->parameterList.size;i++)
	{

	if($2->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$2->end<<": Void cannot be used in expression "<<endl;
		error_count++;

	}


	}
		}
			
	$$->voidChecked=true;
	$2->voidChecked=true;


	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;



		for(int i=0;i<$2->parameterList.size;i++)
	{
		$$->parameterList.push_back($2->parameterList.data[i]);
		$$->parameterTypeList.push_back($2->parameterTypeList.data[i]);
	}

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	if($1->getName()=="-") $$->containsNegative=true;
	$$->addChild({$1,$2});
	$$->stackPushed=true;





	logout<<"unary_expression : ADDOP unary_expression"<<endl;
}
| NOT unary_expression { 
 	
	//inc dec of unary expression here
	$$=new SymbolInfo("NOT unary_expression","unary_expression");
	$$->begin=$1->begin;
	$$->end=$2->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);

	for(int i=0;i<$2->parameterList.size;i++)
	{
		$$->parameterList.push_back($2->parameterList.data[i]);
		$$->parameterTypeList.push_back($2->parameterTypeList.data[i]);
	}		


	if($2->voidChecked==false)
		{
			for(int i=0;i<$2->parameterList.size;i++)
	{

	if($2->parameterTypeList.data[i]=="VOID")
	{
		errorout<<"Line# "<<$2->end<<": Void cannot be used in expression"<<endl;
		error_count++;

	}


	}
	}
	$$->voidChecked=true;
	$2->voidChecked=true;


	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);


	$$->addChild({$1,$2});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->stackPushed=true;


	logout<<"unary_expression : NOT unary_expression"<<endl;
}
| factor { 
 	

	$$=new SymbolInfo("factor","unary_expression");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);

	if($1->voidChecked==true) $$->voidChecked=true;

	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});
	

	$$->isSimpleId=$1->isSimpleId;
	$$->val=$1->val;

	//for operation like x=y+z;
	$$->isId=$1->isId;

	$$->isIncrement=$1->isIncrement;
	$$->isDecrement=$1->isDecrement;

	$$->stackPushed=$1->stackPushed;

	$$->isThisArray=$1->isThisArray;

	logout<<"unary_expression : factor "<<endl;
}
;
factor : variable { 
 	

	$$=new SymbolInfo("variable","factor");
	$$->begin=$1->begin;
	$$->end=$1->end;

	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}
	
	$$->parseTree.insert($$->type);

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	$$->addChild({$1});
	$$->isId=$1->isId;
	$$->isThisArray=$1->isThisArray;
	$$->val=$1->val;
	$$->stackPushed=$1->stackPushed;


	logout<<"factor	: variable "<<endl;
}
| ID LPAREN argument_list RPAREN { 
 	

	$$=new SymbolInfo("ID LPAREN argument_list RPAREN","factor");
	$$->begin=$1->begin;
	$$->end=$4->end;



	SymbolInfo *currentSymbol=symbolTable->lookUp($1->getName());
	
	if(currentSymbol!=nullptr && $3!=nullptr)
	{
		$$->parameterList.push_back(currentSymbol->getName());
		$$->parameterTypeList.push_back(currentSymbol->getType());

		if($3->parameterList.size==currentSymbol->parameterList.size)
	{


		for(int i=0;i<currentSymbol->parameterList.size;i++)
		{
			if( $3->parameterTypeList.data[i].find(currentSymbol->parameterTypeList.data[i])==string::npos)
			{
				errorout<<"Line# "<<$3->end<<": Type mismatch for argument "<<i+1<<" of "<<"'"<<$1->getName()<<"'"<<endl;
				error_count++;
			}
		}


	}
	else if($3->parameterList.size<currentSymbol->parameterList.size)
	{
		errorout<<"Line# "<<$3->end<<": Too few arguments to function "<<"'"<<$1->getName()<<"'"<<endl;
		error_count++;

	}
	else 
	{
		
		errorout<<"Line# "<<$3->end<<": Too many arguments to function "<<"'"<<$1->getName()<<"'"<<endl;
		error_count++;

	}
	}
	else if(currentSymbol==nullptr)
	{
		errorout<<"Line# "<<$1->begin<<": Undeclared function '"<<$1->getName()<<"'"<<endl;
		error_count++;

	}
	
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	$4->parseTree.insert($4->type); 
	$4->parseTree.root->begin=$4->begin;
	$4->parseTree.root->end=$4->end;
	$4->parseTree.root->isLeaf=true;
    $4->addChildLeaf($4);			

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;
	node<string>* terminalsChild3=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$2->name;
	terminalsChild3->data=$4->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $2->parseTree.root->childNodes.push_back(terminalsChild2);
    $4->parseTree.root->childNodes.push_back(terminalsChild3);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


	$4->parseTree.root->name = $4->name;
    $4->parseTree.root->type = $4->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);
    $$->parseTree.root->childNodes.push_back($4->parseTree.root);

	$$->addChild({$1,$2,$3,$4});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$4->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->stackPushed=true;

	logout<<"factor	: ID LPAREN argument_list RPAREN  "<<endl;
}
| LPAREN expression RPAREN { 
 	

	$$=new SymbolInfo("LPAREN expression RPAREN","factor");
	$$->begin=$1->begin;
	$$->end=$3->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);	$3->parseTree.insert($3->type); 
	$3->parseTree.root->begin=$3->begin;
	$3->parseTree.root->end=$3->end;
	$3->parseTree.root->isLeaf=true;
    $3->addChildLeaf($3);
		

	node<string>* terminalsChild1=new node<string>;
	node<string>* terminalsChild2=new node<string>;

	terminalsChild1->data=$1->name;
	terminalsChild2->data=$3->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);
    $3->parseTree.root->childNodes.push_back(terminalsChild2);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	$3->parseTree.root->name = $3->name;
    $3->parseTree.root->type = $3->type;

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->addChild({$1,$2,$3});


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->stackPushed=true;

	logout<<"factor	: LPAREN expression RPAREN   "<<endl;
}
| CONST_INT { 
 	

	$$=new SymbolInfo("CONST_INT","factor");
	$$->begin=$1->begin;
	$$->end=$1->end;

	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);		
	$$->parameterList.push_back($1->getName());
	$$->parameterTypeList.push_back($1->getType());

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);


	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->isSimpleId=true;

	$$->addChild({$1});
	$$->val=std::stoi($1->getName());
	// cout<<$$->val<<endl;


	logout<<"factor	: CONST_INT   "<<endl;
}
| CONST_FLOAT { 
 	

	$$=new SymbolInfo("CONST_FLOAT","factor");
	$$->begin=$1->begin;
	$$->end=$1->end;
	$$->parseTree.insert($$->type);
	$1->parseTree.insert($1->type); 
	$1->parseTree.root->begin=$1->begin;
	$1->parseTree.root->end=$1->end;
	$1->parseTree.root->isLeaf=true;
    $1->addChildLeaf($1);

	$$->parameterList.push_back($1->getName());
	$$->parameterTypeList.push_back($1->getType());

		
	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$1->name;

    $1->parseTree.root->childNodes.push_back(terminalsChild1);

	$1->parseTree.root->name = $1->name;
    $1->parseTree.root->type = $1->type;

	

    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});



	logout<<"factor	: CONST_FLOAT   "<<endl;
}
| variable INCOP { 
 	

	$$=new SymbolInfo("variable INCOP","factor");
	$$->begin=$1->begin;
	$$->end=$2->end;
	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);

	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

	node<string>* terminalsChild1=new node<string>;
	

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);



	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1,$2});
	$$->isId=true;
	$$->isIncrement=true;


	logout<<"factor : variable INCOP"<<endl;
}
| variable DECOP { 
 	

	$$=new SymbolInfo("variable DECOP","factor");
	$$->begin=$1->begin;
	$$->end=$2->end;

	for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);
	node<string>* terminalsChild1=new node<string>;
	

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);




	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;


    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$2->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;
	$$->addChild({$1,$2});
	$$->isId=true;

	$1->isId=true;
	$1->isDecrement=true;

	$$->isDecrement=true;



	logout<<"factor : variable DECOP"<<endl;
}
;
argument_list : arguments { 
 	

	$$=new SymbolInfo("arguments","argument_list");
	$$->begin=$1->begin;
	$$->end=$1->end;
	
		for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}

	$$->parseTree.insert($$->type);
    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	$$->addChild({$1});


	logout<<"argument_list : arguments  "<<endl;
}
| { 
 	

	$$=new SymbolInfo(" ","argument_list");
	$$->begin=line_count;
	$$->end=line_count;
	$$->parseTree.insert($$->type);

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;



	logout<<"argument_list : "<<endl;
}
;
arguments : arguments COMMA logic_expression { 
 	

	$$=new SymbolInfo("arguments COMMA	logic_expression","arguments");
	$$->begin=$1->begin;
	$$->end=$3->end;



	$$->parseTree.insert($$->type);
	$2->parseTree.insert($2->type); 
	$2->parseTree.root->begin=$2->begin;
	$2->parseTree.root->end=$2->end;
	$2->parseTree.root->isLeaf=true;
    $2->addChildLeaf($2);

		for(int i=0;i<$1->parameterList.size;i++)
	{
		$$->parameterList.push_back($1->parameterList.data[i]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[i]);
	}


	
	//it will be counted as only one argument

		$$->parameterList.push_back($3->parameterList.data[0]);
		$$->parameterTypeList.push_back($3->parameterTypeList.data[0]);
	
		

	node<string>* terminalsChild1=new node<string>;

	terminalsChild1->data=$2->name;

    $2->parseTree.root->childNodes.push_back(terminalsChild1);



	$2->parseTree.root->name = $2->name;
    $2->parseTree.root->type = $2->type;



    $$->parseTree.root->childNodes.push_back($1->parseTree.root);
    $$->parseTree.root->childNodes.push_back($2->parseTree.root);
    $$->parseTree.root->childNodes.push_back($3->parseTree.root);

	$$->addChild({$1,$2,$3});




	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$3->end;

	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;


	logout<<"arguments : arguments COMMA logic_expression "<<endl;
}
| logic_expression { 
 	

	$$=new SymbolInfo("logic_expression","arguments");
	$$->begin=$1->begin;
	$$->end=$1->end;



	//will be counted as only one argument
		$$->parameterList.push_back($1->parameterList.data[0]);
		$$->parameterTypeList.push_back($1->parameterTypeList.data[0]);
	


	$$->parseTree.insert($$->type);
    $$->parseTree.root->childNodes.push_back($1->parseTree.root);

	$$->parseTree.root->begin=$1->begin;
	$$->parseTree.root->end=$1->end;


	$$->addChild({$1});


	$$->parseTree.root->parameterList=$$->parameterList;
	$$->parseTree.root->parameterTypeList=$$->parameterTypeList;

	logout<<"arguments : logic_expression"<<endl;
};



%%
int main(int argc,char *argv[])
{

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	FILE *fp=fopen(argv[1],"r");
	if(fp==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

    logout.open("2005097_log.txt");
    errorout.open("2005097_error.txt");
    ptout.open("2005097_parsetree.txt");
	code.open("2005097_Code.asm");
	temp.open("2005097_Temp.asm");
	opt.open("2005097_optimized.asm");

	


	symbolTable=new SymbolTable(11);
	yyin=fp;
	yyparse();

	code.close();
	temp.close();

	ofstream codeFile("2005097_Code.asm", std::ios::app);
    ifstream tempFile("2005097_Temp.asm");

    if (!codeFile.is_open() || !tempFile.is_open()) {
        std::cerr << "Error opening files!" << std::endl;
        return 1;
    }

    string line;

    while (std::getline(tempFile, line)) {
        codeFile << line <<endl;
    }
	codeFile.close();
    tempFile.close();
	string inputfile="2005097_Code.asm";
	string outputFile="2005097_optimized.asm";
	optimize_asm(inputfile,outputFile);
   



	logout<<"Total Lines: "<<line_count<<endl;
	logout<<"Total Errors: "<<error_count<<endl;
	logout.close();
	errorout.close();
	ptout.close();
	

	/* yacc -d -y  2005097.y
	echo 'Generated the parser C file as well the header file'
	g++ -w -c -o y.o  y.tab.c
	echo 'Generated the parser object file'
	flex 2005097.l
	echo 'Generated the scanner C file'
	g++ -w -c -o l.o lex.yy.c
	# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
	echo 'Generated the scanner object file'
	g++ 2005097_SymbolInfo.cpp 2005097_ScopeTable.cpp 2005097_SymbolTable.cpp 2005097_Tree.cpp 2005097_CustomVector.cpp -c
	echo 'Generated symbol table and helper object files'
	g++ 2005097_SymbolInfo.o 2005097_ScopeTable.o 2005097_SymbolTable.o 2005097_Tree.o 2005097_CustomVector.o y.o l.o -lfl -o executable
	echo 'All ready, running'
	./executable input.c

	rm executable
	rm y.*
	rm lex.yy.c
	rm *.o */


	
	
	return 0;
}