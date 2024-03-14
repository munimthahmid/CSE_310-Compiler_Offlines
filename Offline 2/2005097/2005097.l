%option noyywrap
%x STRINGSTATE
%x SINGLECOMMENTSTATE
%x MULTICOMMENTSTATE
%{
#include<bits/stdc++.h>
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
#include "2005097_SymbolTable.h"
using namespace std;
int line_count=1;
int begin_line;
int error_count=0;
int warning_count=0;
string currentString;
string currentLogString;
string currentComment;
string currentLogComment;
bool multiLineString=false;
bool multiLineComment=false;

SymbolTable *symbolTable;
ofstream tokenout;
ofstream logout;
bool endScopeAtBegin[1000];
int endScopeIndex=0;

string remove_whitespace_from_string(string s)
{
	remove(s.begin(),s.end(),' ');
	remove(s.begin(),s.end(),'\t');
	return s;
}
void countLeadingSpacesAndTabs(string& line, int& spaceCount, int& tabCount) {
    // Reset counts for each line
    spaceCount = 0;
    tabCount = 0;


    for (char ch : line) {
        if (ch == ' ') {
            spaceCount++;
        }
		else if(ch=='\t')
		{
			tabCount++;
		} else {
            break;
        }
    }

}
int find_required_tab(string name)
{
	int dotCount = 0;

    for (char ch : name) {
        if (ch == '.') {
            dotCount++;
        }
    }

    return dotCount;
}

string handleEscapeCharacters(string input) {
    string result = input;

    size_t pos = result.find("\\t");
    while (pos != std::string::npos) {
        result.replace(pos, 2, "\t");  
        pos = result.find("\\t", pos + 1);
    }

    pos = result.find("\\n");
    while (pos != std::string::npos) {
        result.replace(pos, 2, "\n");  
        pos = result.find("\\n", pos + 1);
    }


    return result;
}

%}
WHITESPACE [ \t\f\v]+ 
MULTICHAR \'(\\)?[A-Za-z ]{2,}\'
UNFINISHED_CONST_CHAR \'(\\)?[A-Za-z]|\'|\\|\'\\\'
EMPTY_CONST_CHAR \'\'

LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
RELOP [<>=!]=?
UNRECOGNIZED [^a-zA-Z0-9_\r\n]
INVALID_SUFFIX [0-9]+[a-zA-Z_]+
ILL_FORMED_NUMBER ([0-9])?+\.[0-9]+(E[-0-9]+(\.[-0-9]){1,})|([0-9]+E([0-9]+)?(\.[-0-9]){1,})|[0-9]+\.([0-9]+\.)+([0-9]+E([0-9]+)?)+|[0-9]+(\.(E[0-9]+)+)+
FLOAT_ERROR  (([0-9]+)?\.[0-9]+\.[0-9]+)|(([0-9]+)?\.[0-9]+E(0-9)+\.[0-9]+)|([0-9]+)?\.[0-9]+(\.[0-9]+)+
CONST_FLOAT ([0-9])?+\.[0-9]+(E[-0-9]+)?|([0-9]+E[0-9]+)
ID [A-Za-z_][A-Za-z0-9_]*
CONST_CHAR \'(\\)?[A-Za-z]\'


%%
(\r\n)+{WHITESPACE}? {
		string newString;
		newString+=yytext;
		int newLineCount=0;
		for(int i=0;i<newString.size();i++)
		{
			if(newString[i]=='\n') 
			{
				line_count++;
				newLineCount++;
			}
		}						
		for(int i=0;i<newLineCount;i++)
			newString=newString.substr(2);
		int spaceCount=0;
		int tabCount=0;
			

			countLeadingSpacesAndTabs(newString,spaceCount,tabCount);


			string id;
			if(endScopeAtBegin[line_count]==false)
			id=symbolTable->currentScopeTable->getId();
			else id=symbolTable->currentScopeTable->getParentScope()->getId();
			int required_tab=find_required_tab(id);
			int current_tab=tabCount;
			int current_space=spaceCount;
			if(current_tab==required_tab && current_space==0)
				{
			

				}
			else if(current_space!=0)
				{

			logout<<"Line# "<<line_count<<": Warning, tab requrired but got space."<<endl;
			warning_count++;
				}
			else
				{
			logout<<"Line# "<<line_count<<": warning, "<<required_tab<<" of tabs needed but got "<<current_tab<<" tabs."<<endl;

			warning_count++;
			}


	


				
	}
{WHITESPACE} {}


\" {
	begin_line=line_count;
	BEGIN STRINGSTATE;
}


<STRINGSTATE>\n {

	if(currentString[currentString.size()-2]!='\\')
	{

	string newString="\"";
	newString+=currentLogString;
	logout<<"Error at line# "<<line_count++<<": UNFINISHED_STRING "<<newString<<endl;
	error_count++;
	currentString.clear();
	currentLogString.clear();
	BEGIN INITIAL;
	}
	else
	{
	char last=currentString.back();
	currentString.pop_back();
	currentString.pop_back();

	line_count++;
	multiLineString=true;

	// currentString+=" ";
	currentLogString+=yytext;

	}
	
	
}

<STRINGSTATE>\\t {
	currentString+='	';
	currentLogString+="\\t";
}


<STRINGSTATE>[^\"] {
	currentString += yytext;	
    
	currentLogString+=yytext;

}
<STRINGSTATE>\\n {
	currentString+='\n';
	currentLogString+="\\n";
}
<STRINGSTATE>\\\" {
	currentString+='\"';
	currentLogString+="\\\"";
}
<STRINGSTATE>\\' {
	currentString+='\'';
	currentLogString+="\\'";
}
<STRINGSTATE>\\\\ {
	currentString+='\\';
	currentLogString+="\\\\";
}
<STRINGSTATE>\" {
	string newString="\"";
		newString+=currentLogString;
		newString+="\"";
    if (multiLineString) {
		

        tokenout << "<MULTI LINE STRING, " << currentString << ">" << endl;
        logout << "Line# " << begin_line << ": Token <MULTI LINE STRING> Lexeme " << newString << " found" << endl;
    } else {
        tokenout << "<SINGLE LINE STRING, " << currentString << ">" << endl;
        logout << "Line# " << begin_line << ": Token <SINGLE LINE STRING> Lexeme " << newString << " found" << endl;
    }
    multiLineString = false;
    currentString.clear();
	currentLogString.clear();
    BEGIN INITIAL;
}
<STRINGSTATE><<EOF>> {
	string newString="\"";
	newString+=currentLogString;
	logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<newString<<endl;
	error_count++;
	currentString.clear();
	currentLogString.clear();
	BEGIN INITIAL;
}
\/\/ {
	begin_line=line_count;
	BEGIN SINGLECOMMENTSTATE;
}
<SINGLECOMMENTSTATE>\\ {
	currentComment+=yytext;
}
<SINGLECOMMENTSTATE>\n {



		int size=currentComment.size();
		if(currentComment[size-2]!='\\')
		{
		string newString="//";
		newString+=currentComment;
		newString.pop_back();
 		logout << "Line# " << begin_line << ": Token <SINGLE LINE COMMENT> Lexeme " << newString << " found" << std::endl;
        currentComment.clear();
        BEGIN INITIAL;
		}
		else
		{
			currentComment+=yytext;
		}
		line_count++;
       
}
<SINGLECOMMENTSTATE>[^\\\n] {


	currentComment+=yytext;
}
<SINGLECOMMENTSTATE><<EOF>> {

		string newString="//";
		newString+=currentComment;
		logout << "Line# " << begin_line << ": Token <SINGLE LINE COMMENT> Lexeme " << newString << " found" << endl;
        currentComment.clear();
        BEGIN INITIAL;

}
\/\* { 
	begin_line=line_count;
    BEGIN MULTICOMMENTSTATE;
}

<MULTICOMMENTSTATE>[^*\n] {
    // Match any character except '*' and \n
    currentComment += yytext;
}

<MULTICOMMENTSTATE>\*[^\/] {
    // Match '*' not followed by '/'
    currentComment += yytext;
}
<MULTICOMMENTSTATE>\n {
	currentComment+=yytext;
	line_count++;

}

<MULTICOMMENTSTATE>\*\/ {
    // End of multi-line comment
	string newString="/*";
	newString+=currentComment;
	newString+="*/";
    logout << "Line# " << begin_line << ": Token <MULTI LINE COMMENT> Lexeme " << newString << " found" << std::endl;
    currentComment.clear();
    BEGIN INITIAL;
}
<MULTICOMMENTSTATE><<EOF>> {
	string newString="/*";
	newString+=currentComment;
	logout<<"Error at line# "<<begin_line<<": UNFINISHED_COMMENT "<<newString<<endl;
	error_count++;
	currentComment.clear();
    BEGIN INITIAL;
}

 
"<"		|
"<="	|
">"		|
">="	|
"=="	|
"!=" {

            tokenout<<"<RELOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<" found"<<endl;
			
	}		

"="	{


            tokenout<<"<ASSIGNOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl;
			
		}




"&&"		|

"||" {


            tokenout<<"<LOGICOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <LOGICOP> Lexeme "<<yytext<<" found"<<endl;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}


"&"		|
"|"	|
"^"		|
"<<"	|
">>" {


            tokenout<<"<BITOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <BITOP> Lexeme "<<yytext<<" found"<<endl;
		
	}



"!"	{


            tokenout<<"<NOT, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <NOT> Lexeme "<<yytext<<" found"<<endl;
			
		}

"("	{


            tokenout<<"<LPAREN, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<" found"<<endl;
			
		}

")"	{


            tokenout<<"<RPAREN, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<" found"<<endl;
			
		}

"{"	{


            tokenout<<"<LCURL, "<<yytext<<">"<<endl;
			symbolTable->enter();
            logout<<"Line# "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<" found"<<endl;
			
		}

"}"	{

			symbolTable->exit();
            tokenout<<"<RCURL, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<" found"<<endl;
			
		}

"["	{


            tokenout<<"<LSQUARE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <LSQUARE> Lexeme "<<yytext<<" found"<<endl;
			
		}

"]"	{


            tokenout<<"<RSQUARE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <RSQUARE> Lexeme "<<yytext<<" found"<<endl;
			
		}

","	{


            tokenout<<"<COMMA, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <COMMA> Lexeme "<<yytext<<" found"<<endl;
			
		}

";"	{


            tokenout<<"<SEMICOLON, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <SEMICOLON> Lexeme "<<yytext<<" found"<<endl;
			
		}



"if"	{
            tokenout<<"<IF, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <IF> Lexeme "<<yytext<<" found"<<endl;
		}
		
"else"	{
			
            tokenout<<"<ELSE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <ELSE> Lexeme "<<yytext<<" found"<<endl;
		}

"for" {
			tokenout<<"<FOR, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <FOR> Lexeme "<<yytext<<" found"<<endl;
}

"do" {
			tokenout<<"<DO, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <DO> Lexeme "<<yytext<<" found"<<endl;
}

"int" {
			tokenout<<"<INT, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <INT> Lexeme "<<yytext<<" found"<<endl;
}

"float" {
			tokenout<<"<FLOAT, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <FLOAT> Lexeme "<<yytext<<" found"<<endl;
}

"void" {
			tokenout<<"<VOID, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <VOID> Lexeme "<<yytext<<" found"<<endl;
}

"switch" {
			tokenout<<"<SWITCH, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <SWITCH> Lexeme "<<yytext<<" found"<<endl;
}

"default" {
			tokenout<<"<DEFAULT, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <DEFAULT> Lexeme "<<yytext<<" found"<<endl;
}

"while" {
			tokenout<<"<WHILE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <WHILE> Lexeme "<<yytext<<" found"<<endl;
}

"break" {
			tokenout<<"<BREAK, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <BREAK> Lexeme "<<yytext<<" found"<<endl;
}
"char" {
			tokenout<<"<CHAR, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <CHAR> Lexeme "<<yytext<<" found"<<endl;
}

"double" {
			tokenout<<"<DOUBLE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <DOUBLE> Lexeme "<<yytext<<" found"<<endl;
}

"return" {
			tokenout<<"<RETURN, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <RETURN> Lexeme "<<yytext<<" found"<<endl;
}

"case" {
			tokenout<<"<CASE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <CASE> Lexeme "<<yytext<<" found"<<endl;
}
"continue" {
			tokenout<<"<CONTINUE, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <CONTINUE> Lexeme "<<yytext<<" found"<<endl;
}

"+"		|

"-"		{


            tokenout<<"<ADDOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <ADDOP> Lexeme "<<yytext<<" found"<<endl;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}


"*"		|

"/"	|
"%"	{


            tokenout<<"<MULOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<" found"<<endl;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
	}

"++"		|

"--"		{


            tokenout<<"<INCOP, "<<yytext<<">"<<endl;
            logout<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<" found"<<endl;
		
		}


{EMPTY_CONST_CHAR} {
		logout<<"Error at line# "<<line_count<<": EMPTY_CONST_CHAR "<<yytext<<endl;
		error_count++;
}
{MULTICHAR} {
		logout<<"Error at line# "<<line_count<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
		error_count++;

}
{UNFINISHED_CONST_CHAR} {
	logout<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
	error_count++;
}

{UNRECOGNIZED} {
	logout<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
	error_count++;
	

}
{}

{INVALID_SUFFIX} {
	logout<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
	error_count++;

}
{DIGIT}+ 	{
			

                tokenout<<"<CONST_INT, "<<yytext<<">"<<endl;
                logout<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				
			}

{ILL_FORMED_NUMBER} {
		logout<<"Error at line# "<<line_count<<": ILLFORMED_NUMBER "<<yytext<<endl;
		error_count++;

}

{FLOAT_ERROR} {
	logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
	error_count++;
	
}			


{CONST_FLOAT} 	{
			

                tokenout<<"<CONST_FLOAT, "<<yytext<<">"<<endl;
                logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
				
			}

{CONST_CHAR} {
				
				string tempString(yytext+1,yyleng-2);
				
				tokenout<<"<CONST_CHAR, "<<handleEscapeCharacters(tempString)<<">"<<endl;
                logout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<handleEscapeCharacters(tempString)<<" found"<<endl;	
}	
{ID} {

				tokenout<<"<ID, "<<yytext<<">"<<endl;
                logout<<"Line# "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found"<<endl;
				bool insert=symbolTable->insertSymbolInCurrentScope(yytext,"ID");
				if(insert==true)
				{
					string result=symbolTable->printAll();
					logout<<result;
					

				}
				else
				{
					logout<<"	"<<yytext<<" already exists in the current ScopeTable"<<endl;
				}
}



<<EOF>> {
	string result=symbolTable->printAll();
	logout<<result;

    logout<<"Total lines: "<<line_count<<endl;
    logout<<"Total errors: "<<error_count<<endl;
	logout<<"Total warnings: "<<warning_count<<endl;
    return 0;
}



			

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	string fileName=argv[1];
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	std::ifstream inputFile(fileName);  

    if (!inputFile.is_open()) {
        std::cerr << "Error opening the file." << std::endl;
        return 1;
    }

    std::string line;
    int lineCount = 0;
	endScopeAtBegin[endScopeIndex]=false;
	endScopeIndex++;

    while (std::getline(inputFile, line)) {
        int spacesBeforeFirstChar = 0;
        int tabsBeforeFirstChar = 0;

        countLeadingSpacesAndTabs(line, spacesBeforeFirstChar, tabsBeforeFirstChar);
		string temp=remove_whitespace_from_string(line);
		if(temp[0]=='}') 
		{
			endScopeAtBegin[endScopeIndex]=true;
			endScopeIndex++;
		}
		else 
		{
			endScopeAtBegin[endScopeIndex]=false;
			endScopeIndex++;
		}
		

    
    }

    inputFile.close();
	

    logout.open("log.txt");
    tokenout.open("token.txt");
	symbolTable=new SymbolTable(10);
	string result=symbolTable->printAll();
	yyin= fin;
	yylex();
	fclose(yyin);

    tokenout.close();
    logout.close();
	return 0;
}
