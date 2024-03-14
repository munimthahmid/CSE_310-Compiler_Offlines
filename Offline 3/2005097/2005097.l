%option noyywrap 
%x STRINGSTATE
%x SINGLECOMMENTSTATE
%x MULTICOMMENTSTATE
%{
#include<bits/stdc++.h>
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
#include "2005097_SymbolTable.h"
#include "2005097_CustomVector.h"
#include "y.tab.h"



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

extern std::ofstream errorout;
extern std::ofstream logout;
extern std::ofstream ptout;


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
	/*
	
	RELOP ASSIGNOP LOGICOP  NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA
	 SEMICOLON IF ELSE FOR  INT FLOAT VOID   WHILE  CHAR DOUBLE RETURN   ADDOP MULOP 
	INCOP CONST_INT CONST_FLOAT CONST_CHAR ID PRINTLN DECOP BITOP DO SWITCH DEFAULT BREAK CASE CONTINUE
	
	
	*/
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
{NEWLINE} {
	line_count++;
}
{WHITESPACE} { 
}


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
		

        
        logout << "Line# " << begin_line << ": Token <MULTI LINE STRING> Lexeme " << newString << " found" << endl;
    } else {
        
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

			yylval.symbol=new SymbolInfo(yytext,"RELOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;

            
            logout<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<" found"<<endl;
			return RELOP;
			
	}		

"="	{

			yylval.symbol=new SymbolInfo(yytext,"ASSIGNOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl;
			return ASSIGNOP;
			
		}




"&&"		|

"||" {

			yylval.symbol=new SymbolInfo(yytext,"LOGICOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <LOGICOP> Lexeme "<<yytext<<" found"<<endl;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
			return LOGICOP;

		}


"&"		|
"|"		|
"^"		|
"<<"	|
">>" {

			yylval.symbol=new SymbolInfo(yytext,"BITOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <BITOP> Lexeme "<<yytext<<" found"<<endl;
			return BITOP;
		
	}



"!"	{

			yylval.symbol=new SymbolInfo(yytext,"NOT");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <NOT> Lexeme "<<yytext<<" found"<<endl;
			return NOT;
			
		}

"("	{

			yylval.symbol=new SymbolInfo(yytext,"LPAREN");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<" found"<<endl;
			return LPAREN;
			
		}

")"	{
			yylval.symbol=new SymbolInfo(yytext,"RPAREN");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;

            
            logout<<"Line# "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<" found"<<endl;
			return RPAREN;
			
		}

"{"	{

			yylval.symbol=new SymbolInfo(yytext,"LCURL");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<" found"<<endl;
			return LCURL;
			
		}

"}"	{
			yylval.symbol=new SymbolInfo(yytext,"RCURL");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<" found"<<endl;
			return RCURL;
			
		}

"["	{

			yylval.symbol=new SymbolInfo(yytext,"LSQUARE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <LSQUARE> Lexeme "<<yytext<<" found"<<endl;
			return LSQUARE;
			
		}

"]"	{

			yylval.symbol=new SymbolInfo(yytext,"RSQUARE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <RSQUARE> Lexeme "<<yytext<<" found"<<endl;
			return RSQUARE;
			
		}

","	{

			yylval.symbol=new SymbolInfo(yytext,"COMMA");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            logout<<"Line# "<<line_count<<": Token <COMMA> Lexeme "<<yytext<<" found"<<endl;

			return COMMA;
            
			
		}

";"	{

			yylval.symbol=new SymbolInfo(yytext,"SEMICOLON");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            logout<<"Line# "<<line_count<<": Token <SEMICOLON> Lexeme "<<yytext<<" found"<<endl;

			return SEMICOLON;
            
			
		}



"if"	{
			yylval.symbol=new SymbolInfo(yytext,"IF");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <IF> Lexeme "<<yytext<<" found"<<endl;
			return IF;

		}

"else"	{
			yylval.symbol=new SymbolInfo(yytext,"ELSE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <ELSE> Lexeme "<<yytext<<" found"<<endl;
			return ELSE;

		
		}

"for" {
			yylval.symbol=new SymbolInfo(yytext,"FOR");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <FOR> Lexeme "<<yytext<<" found"<<endl;
			return FOR;

}

"do" {
			yylval.symbol=new SymbolInfo(yytext,"DO");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <DO> Lexeme "<<yytext<<" found"<<endl;
			return DO;

}

"int" {
			yylval.symbol=new SymbolInfo(yytext,"INT");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            logout<<"Line# "<<line_count<<": Token <INT> Lexeme "<<yytext<<" found"<<endl;

			return INT;
			
}

"float" {
			yylval.symbol=new SymbolInfo(yytext,"FLOAT");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <FLOAT> Lexeme "<<yytext<<" found"<<endl;
			return FLOAT;

}

"void" {
			yylval.symbol=new SymbolInfo(yytext,"VOID");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <VOID> Lexeme "<<yytext<<" found"<<endl;
			return VOID;

}

"switch" {
			yylval.symbol=new SymbolInfo(yytext,"SWITCH");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <SWITCH> Lexeme "<<yytext<<" found"<<endl;
			return SWITCH;

}

"default" {
			yylval.symbol=new SymbolInfo(yytext,"DEFAULT");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            logout<<"Line# "<<line_count<<": Token <DEFAULT> Lexeme "<<yytext<<" found"<<endl;
			return DEFAULT;

}

"while" {
			yylval.symbol=new SymbolInfo(yytext,"WHILE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <WHILE> Lexeme "<<yytext<<" found"<<endl;
			return WHILE;

}

"break" {
			yylval.symbol=new SymbolInfo(yytext,"BREAK");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <BREAK> Lexeme "<<yytext<<" found"<<endl;
			return BREAK;

}
"char" {
			yylval.symbol=new SymbolInfo(yytext,"CHAR");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <CHAR> Lexeme "<<yytext<<" found"<<endl;
			return CHAR;

}

"double" {
			yylval.symbol=new SymbolInfo(yytext,"DOUBLE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <DOUBLE> Lexeme "<<yytext<<" found"<<endl;
			return DOUBLE;

}

"return" {
			yylval.symbol=new SymbolInfo(yytext,"RETURN");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <RETURN> Lexeme "<<yytext<<" found"<<endl;
			return RETURN;

}

"case" {
			yylval.symbol=new SymbolInfo(yytext,"CASE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <CASE> Lexeme "<<yytext<<" found"<<endl;
			return CASE;

}
"println" {
			yylval.symbol=new SymbolInfo(yytext,"PRINTLN");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <PRINTLN> Lexeme "<<yytext<<" found"<<endl;
			return CASE;

}
"continue" {
			yylval.symbol=new SymbolInfo(yytext,"CONTINUE");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <CONTINUE> Lexeme "<<yytext<<" found"<<endl;
			return CONTINUE;

}
"loop" {
			yylval.symbol=new SymbolInfo(yytext,"LOOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
			
            logout<<"Line# "<<line_count<<": Token <LOOP> Lexeme "<<yytext<<" found"<<endl;
			return LOOP;
}

"+"		|

"-"		{
			yylval.symbol=new SymbolInfo(yytext,"ADDOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;

            
            logout<<"Line# "<<line_count<<": Token <ADDOP> Lexeme "<<yytext<<" found"<<endl;
			return ADDOP;

			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}


"*"		|

"/"	|
"%"	{

			yylval.symbol=new SymbolInfo(yytext,"MULOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<" found"<<endl;
			return MULOP;

			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
	}

"++"	{

			yylval.symbol=new SymbolInfo(yytext,"INCOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<" found"<<endl;
			return INCOP;

		
		}


"--"	{

			yylval.symbol=new SymbolInfo(yytext,"DECOP");
			yylval.symbol->begin=line_count;
			yylval.symbol->end=line_count;
			yylval.symbol->isTerminal=true;
            
            logout<<"Line# "<<line_count<<": Token <DECOP> Lexeme "<<yytext<<" found"<<endl;
			return DECOP;

		
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

{INVALID_SUFFIX} {
	logout<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
	error_count++;

}
{DIGIT}+ 	{
			
				yylval.symbol=new SymbolInfo(yytext,"CONST_INT");
				yylval.symbol->begin=line_count;
				yylval.symbol->end=line_count;
				yylval.symbol->isTerminal=true;
                
                logout<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				return CONST_INT;

				
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
				yylval.symbol=new SymbolInfo(yytext,"CONST_FLOAT");
				yylval.symbol->begin=line_count;
				yylval.symbol->end=line_count;
				yylval.symbol->isTerminal=true;
			

                
                logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
				return CONST_FLOAT;
				
			}

{CONST_CHAR} {
				yylval.symbol=new SymbolInfo(yytext,"CONST_CHAR");
				string tempString(yytext+1,yyleng-2);
				yylval.symbol->begin=line_count;
				yylval.symbol->end=line_count;
				yylval.symbol->isTerminal=true;
				
				
                logout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<handleEscapeCharacters(tempString)<<" found"<<endl;	
				return CONST_CHAR;

	}
{ID} {
				yylval.symbol=new SymbolInfo(yytext,"ID");
				yylval.symbol->begin=line_count;
				yylval.symbol->end=line_count;
				yylval.symbol->isTerminal=true;
				
                logout<<"Line# "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found"<<endl;
				return ID;
				
				
}
