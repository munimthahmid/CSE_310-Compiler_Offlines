#include<iostream>
#include<string>
#include<fstream>
#include "2005097_Tree.h"
#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

using namespace std;
extern std::ofstream code;
extern std::ofstream temp;
extern int line_count;


class SymbolInfo
{
public:
    string name;
    string type;
    bool isFunction;
    SymbolInfo *next;
    int pos_x;
    int pos_y;
    int begin;
    int end;
    bool isTerminal;
    bool voidChecked;
    bool modulusChecked;
    Tree<string> parseTree;
    CustomVector<string>parameterList;
    CustomVector<string>parameterTypeList;
    CustomVector<bool>isArray;
    CustomVector<string>idList;
    CustomVector<string>idTypeList;
    CustomVector<int>arrLengthList;
    CustomVector<int>functionVariablesPosition;
    SymbolInfo* parent;
    stack<string>currentAX;


//ICG

    bool isLeaf;
    string scopeId;
    string varAsmName;


    bool codeStarted=false;

    int funcTotalOffset;

    SymbolInfo * currentFunc;

    vector<pair<string,string>>globalVariableList;


    vector<string>varAsmNameList;
    vector<int>offsetList;
    vector<string>varRealNameList;
    int offset=0;
    bool printFlag;

    bool expressionBegin;
    bool firstTwoTermEvaluated;

    int val;
    bool stackPushed;
    bool isId;

    string thisSymbolsTrueLabel;
    string thisSymbolsFalseLabel;
    string thisSymbolsLabel;
    string thisSymbolsNextLabel;

    bool isIfElse;


    bool isIncrement;
    bool isDecrement;


    int currentLabel;
    vector<string>labels;


    int currentFuncParameterSize;

    bool returned;
    string returnLabel;

    string skipElseAndJumpHere;

    bool partOfLogicExpression;
    bool leftOfLogicOp;
    string thisSymbolsLabelForLogicOp;
    string trueOrFalseLabelForLogicOp;   
    string nextSymbolsLabelForLogicOp;

    bool logicAnd;
    bool logicOr;
    bool isSimpleExpression;


    bool isForLoop;
    bool isIncLabel;

    string statementLabel;
    string nextLabel;

    string incLabel;
    string checkLabel;

    bool isWhileLoop;

    bool isThisArray;
    vector<int>varArrLengthList;

    bool containsNegative;

    string prevFuncName;
    string currentFuncName;
    stack<string>functionsCalled;

int getOffset(string name)
{
    for(int i=0;i<varRealNameList.size();i++)
    {   
        if(varRealNameList[i]==name)
        {
            return offsetList[i];
        }
    }
}

int extractNumber(const std::string& str) {
    size_t startPos = str.find_first_of("0123456789");
    
    std::string numStr = str.substr(startPos);
    
    int num = atoi(numStr.c_str());
    
    if (str[startPos - 1] == '-') {
        num = -num;
    }
    
    return num;
}


string getAsmName(string name)
{
    for(int i=0;i<varRealNameList.size();i++)
    {
        if(name==varRealNameList[i])
        {
            return varAsmNameList[i];
        }
    }
    return "-1";
}

void printLabel()
{
    string label="L"+ ++currentLabel;
    temp<<label<<": "<<endl;
    labels.push_back(label);
}
void printLabel(string label)
{
    labels.push_back(label);
    if(!label.empty())
    temp<<label<<": "<<endl;
}
bool isSimpleId;
void handleGlobalArrAndInt(SymbolInfo* variable, SymbolInfo* logicExpression)
{
    

            //handle case like x[2]=3, x[2+3]=(5+3) etc
            // like x[2]=3
            bool global;
           
            string realName=variable->parameterList.data[0];
            string name=getAsmName(realName);
            if(name=="-1") 
            {
                name=realName;
                global=true;
            }
            if(global)
            {
                if(variable->stackPushed==false) temp<<"	MOV AX, "<<variable->val<<endl;

                
                else temp<<"	POP AX"<<endl;
                

                temp<<"	PUSH AX"<<endl;

//can only handle if logicexpression->val exists
                if(logicExpression->containsNegative)
                {
                   temp<<"	POP AX"<<endl; //index
                   temp<<"	POP BX"<<endl; //val
                   temp<<"	PUSH AX"<<endl;
                   temp<<"	PUSH BX"<<endl;
                }

                 //pushing the index of array in the stack


    //now store the value to be stored in AX    

            if(logicExpression->stackPushed==false)
            {
                   if(logicExpression->isId==false)
            temp<<"	MOV AX, "<<logicExpression->val<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(logicExpression->parameterList.data[0]) != "-1" ? getAsmName(logicExpression->parameterList.data[0]) : logicExpression->parameterList.data[0]) << endl;
            }
            else temp<<"	POP AX"<<endl;

         
            

            //get the index in BX

            temp<<"	POP BX"<<endl;

    //store the value to be saved in stack
            temp<<"	PUSH AX"<<endl;

            temp<<"	MOV AX, 2"<<endl;
            temp<<"	MUL BX"<<endl;
            //calculated index now on BX
            temp<<"	MOV BX, AX          ; Line "<<variable->begin<<endl;

            temp<<"	POP AX"<<endl;
            temp<<"	MOV "<<name<<"[BX], AX"<<endl;


            // temp<<"	PUSH AX"<<endl;

            }

}
void handleLocalArrAndInt(SymbolInfo* variable,SymbolInfo* logicExpression)
{
    bool global;
           
    string realName=variable->parameterList.data[0];
    string name=getAsmName(realName);
    if(name=="-1") 
        {
            name=realName;
            global=true;
        }
    if(!global)
    {
        int size=getArrSize(realName);
         if(variable->stackPushed==false)
            {
                   if(variable->isId==false)
            temp<<"	MOV AX, "<<variable->val<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(variable->parameterList.data[0]) != "-1" ? getAsmName(variable->parameterList.data[0]) : variable->parameterList.data[0]) << endl;
            }
            else temp<<"	POP AX"<<endl;

        temp<<"	PUSH AX"<<endl;
         if(logicExpression->stackPushed==false)
            {
                   if(logicExpression->isId==false)
            temp<<"	MOV AX, "<<logicExpression->val<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(logicExpression->parameterList.data[0]) != "-1" ? getAsmName(logicExpression->parameterList.data[0]) : logicExpression->parameterList.data[0]) << endl;
            }
            else temp<<"	POP AX"<<endl;
        temp<<"	POP BX"<<endl;
        temp<<"	PUSH AX"<<endl;
        temp<<"	MOV AX, 2"<<endl;
        temp<<"	MUL BX"<<endl;
        temp<<"	MOV BX, AX"<<endl;
        temp<<"	MOV AX, "<<getOffset(realName)<<endl;
        temp<<"	SUB AX, BX"<<endl;
        temp<<"	MOV BX, AX          ; Line "<<variable->begin<<endl;
        temp<<"	POP AX"<<endl;
        temp<<"	MOV SI, BX"<<endl;
        temp<<"	NEG SI"<<endl;
        temp<<"	MOV [BP+SI], AX"<<endl;
    }


}
void handleIntAndGlobalArr(SymbolInfo* variable,SymbolInfo* logicExpression)
{
            bool global;
    
            string realName=logicExpression->parameterList.data[0];
            string name=getAsmName(realName);
            if(name=="-1") 
            {
                name=realName;
                global=true;
            }
            if(global)
            {
                  if(logicExpression->stackPushed==false) temp<<"	MOV AX, "<<logicExpression->val<<endl;

                 else temp<<"	POP AX"<<endl;

            temp<<"	PUSH AX"<<endl;
            temp<<"	POP BX"<<endl;

            temp<<"	MOV AX, 2"<<endl;

            temp<<"	MUL BX"<<endl;

            temp<<"	MOV BX, AX          ; Line "<<variable->begin<<endl;
            temp<<"	MOV AX,"<<name<<"[BX]"<<endl;
            temp << "	MOV " << (getAsmName(variable->parameterList.data[0]) != "-1" ? getAsmName(variable->parameterList.data[0]) : variable->parameterList.data[0])<<", AX"<<endl;

            }

}
void handleIntAndLocalArr(SymbolInfo* variable,SymbolInfo* logicExpression)
{
     bool global;
    
            string realName=logicExpression->parameterList.data[0];
            string name=getAsmName(realName);
            if(name=="-1") 
            {
                name=realName;
                global=true;
            }
            string varRealName=variable->parameterList.data[0];
            string varName=getAsmName(varRealName);
            if(varName=="-1")
            {
                varName=varRealName;

            }
            if(!global)
            {
            int size=getArrSize(realName);
            if(logicExpression->stackPushed==false)
            {
                   if(logicExpression->isId==false)
            temp<<"	MOV AX, "<<logicExpression->val<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(logicExpression->parameterList.data[0]) != "-1" ? getAsmName(logicExpression->parameterList.data[0]) : logicExpression->parameterList.data[0]) << endl;
            }
            else temp<<"	POP AX"<<endl;
            temp<<"	PUSH AX"<<endl;
            temp<<"	POP BX"<<endl;

            temp<<"	MOV AX, 2"<<endl;

            temp<<"	MUL BX"<<endl;

            temp<<"	MOV BX, AX"<<endl;

            temp<<"	MOV AX,"<<currentFunc->funcTotalOffset<<endl;
            temp<<"	SUB AX, BX"<<endl;
            temp<<"	MOV BX, AX          ; Line "<<variable->begin<<endl;
            temp<<"	MOV SI, BX"<<endl;
            temp<<"	NEG SI"<<endl;
            temp<<"	MOV AX ,[BP+SI]"<<endl;
            temp<<"	MOV "<<varName<<", AX"<<endl;
            }

}

void handleGlobalArrAndGlobalArr(SymbolInfo* variable,SymbolInfo* logicExpression)
{
            bool global1;
            bool glboal2;

    
            string logicRealName=logicExpression->parameterList.data[0];
            string logicName=getAsmName(logicRealName);
            if(logicName=="-1") 
            {
                logicName=logicRealName;
                glboal2=true;
            }
            string variableRealName=variable->parameterList.data[0];
            string varName=getAsmName(variableRealName);
            if(varName=="-1") 
            {
                varName=variableRealName;
                global1=true;
            }
            if(global1==true && glboal2==true)
            {


            
                if(variable->stackPushed==false) temp<<"	MOV AX, "<<variable->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                if(logicExpression->stackPushed==false) temp<<"	MOV AX, "<<logicExpression->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	MOV AX, "<<logicName<<"[BX]          ; Line "<<variable->begin<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	POP AX"<<endl;
                temp<<"	MOV "<<varName<<"[BX], AX"<<endl;
            }

}
void handleGlobalArrAndLocalArr(SymbolInfo* variable,SymbolInfo* logicExpression)
{
            bool global1=false;
            bool glboal2=false;

    
            string logicRealName=logicExpression->parameterList.data[0];
            string logicName=getAsmName(logicRealName);
            if(logicName=="-1") 
            {
                logicName=logicRealName;
                glboal2=true;
            }
            string variableRealName=variable->parameterList.data[0];
            string varName=getAsmName(variableRealName);
            if(varName=="-1") 
            {
                varName=variableRealName;
                global1=true;
            }
            if(global1==true && glboal2==false)
            {
                   int size=getArrSize(logicRealName);
                if(variable->stackPushed==false) temp<<"	MOV AX, "<<variable->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                if(logicExpression->stackPushed==false) temp<<"	MOV AX, "<<logicExpression->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	MOV AX,"<<getOffset(varName)<<endl;
                temp<<"	SUB AX, BX"<<endl;
                temp<<"	MOV BX, AX          ; Line "<<variable->begin<<endl;
                temp<<"	MOV SI, BX"<<endl;
                temp<<"	NEG SI"<<endl;
                temp<<"	MOV AX ,[BP+SI]"<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	POP AX"<<endl;
                temp<<"	MOV "<<varName<<"[BX], AX"<<endl;


            }
}
void handleLocalArrAndLocalArr(SymbolInfo* variable,SymbolInfo* logicExpression)
{
            bool global1=false;
            bool glboal2=false;

    
            string logicRealName=logicExpression->parameterList.data[0];
            string logicName=getAsmName(logicRealName);
            if(logicName=="-1") 
            {
                logicName=logicRealName;
                glboal2=true;
            }
            string variableRealName=variable->parameterList.data[0];
            string varName=getAsmName(variableRealName);
            if(varName=="-1") 
            {
                varName=variableRealName;
                global1=true;
            }
            if(global1==false && glboal2==false)
                  {
                   int size=getArrSize(logicRealName);
                   int size2=getArrSize(variableRealName);
                if(variable->stackPushed==false) temp<<"	MOV AX, "<<variable->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                if(logicExpression->stackPushed==false) temp<<"	MOV AX, "<<logicExpression->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	MOV AX,"<<(size+size2)*2<<endl;
                temp<<"	SUB AX, BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	MOV SI, BX"<<endl;
                temp<<"	NEG SI"<<endl;
                temp<<"	MOV AX ,[BP+SI]          ; Line "<<variable->begin<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	MOV AX, "<<(size2)*2<<endl;
                temp<<"	SUB AX, BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	POP AX"<<endl;
                temp<<"	MOV SI, BX"<<endl;
                temp<<"	NEG SI"<<endl;
                temp<<"	MOV [BP+SI], AX"<<endl;



            } 
}
void handleLocalArrAndGlobalArr(SymbolInfo* variable, SymbolInfo* logicExpression)
{
      bool global1=false;
            bool glboal2=false;

    
            string logicRealName=logicExpression->parameterList.data[0];
            string logicName=getAsmName(logicRealName);
            if(logicName=="-1") 
            {
                logicName=logicRealName;
                glboal2=true;
            }
            string variableRealName=variable->parameterList.data[0];
            string varName=getAsmName(variableRealName);
            if(varName=="-1") 
            {
                varName=variableRealName;
                global1=true;
            }
            if(global1==false && glboal2==true)
            {
                 if(variable->stackPushed==false) temp<<"	MOV AX, "<<variable->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                if(logicExpression->stackPushed==false) temp<<"	MOV AX, "<<logicExpression->val<<endl;             
                else temp<<"	POP AX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	MOV AX, "<<logicName<<"[BX]          ; Line "<<variable->begin<<endl;
                temp<<"	POP BX"<<endl;
                temp<<"	PUSH AX"<<endl;
                temp<<"	MOV AX, 2"<<endl;
                temp<<"	MUL BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
               
                temp<<"	MOV AX, "<<getOffset(variableRealName)<<endl;
                temp<<"	SUB AX, BX"<<endl;
                temp<<"	MOV BX, AX"<<endl;
                temp<<"	POP AX"<<endl;
                temp<<"	MOV SI, BX"<<endl;
                temp<<"	NEG SI"<<endl;
                temp<<"	MOV [BP+SI], AX"<<endl;
           
           
           
            }
}
void incrementDecrement(SymbolInfo* child1)
{
    if(child1->isIncrement==true && child1->isId==true)
          {

            //it is a id and it is like x++,y++
            //asm code for incrementing after multiplication is done
            //keeping AX same before and after incrementing
            string name=getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0];
            temp<<"	MOV AX, "<<name<<endl;
            temp<<"	PUSH AX"<<endl;

            temp<<"	INC AX"<<endl;
            temp<<"	MOV "<<name<<", AX"<<endl;
            temp<<"	POP AX"<<endl;
          }

                if(child1->isDecrement==true && child1->isId==true)
          {
            //it is a id and it is like x++,y++
            //asm code for incrementing after multiplication is done
            //keeping AX same before and after incrementing
            string name=getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0];
            temp<<"	MOV AX, "<<name<<endl;
            temp<<"	PUSH AX"<<endl;

            temp<<"	DEC AX"<<endl;
            temp<<"	MOV "<<name<<", AX"<<endl;
            temp<<"	POP AX"<<endl;
          }

}

    vector<SymbolInfo*>childrens;

    void addChild(std::initializer_list<SymbolInfo*> childList) 
        {
        for (SymbolInfo* child : childList) 
        {
            child->parent=this;
            childrens.push_back(child);
        }
        }

        void addChildLeaf(SymbolInfo* child)
        {
            SymbolInfo* leaf=new SymbolInfo(" ",child->name);
            child->isLeaf=true;
            child->childrens.push_back(leaf);
            leaf->parent=child;
        }


    SymbolInfo(string name, string type,bool isF=false,bool isA=false)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->isFunction=isF;
        this->isThisArray=isA;
        this->voidChecked=false;
        this->modulusChecked=false;

    }
    ~SymbolInfo();
    string getName();
    string getType();
    void setName(string name);
    void setNextSymbol(SymbolInfo *s);
    SymbolInfo *getNextSymbol();
    void setType(string type);

    int get_pos_x();
    int get_pos_y();
    bool getIsFunction();
    void setIsFunction(bool isF);
    void set_pos_x(int val);
    void set_pos_y(int val);
    void preOrder();
    void preOrderRecursive(SymbolInfo* root,int space);







void setOffsetAndName(CustomVector<string>idList,CustomVector<int>arrLengthList)
{
       
    for(int i=0;i<idList.size;i++)
    {
        offset+=arrLengthList.data[i]*2;
		string offsetstring=to_string(offset);
		string name= "[BP-" + offsetstring + "]";
        varAsmNameList.push_back(name);
        offsetList.push_back(offset);
        varRealNameList.push_back(idList.data[i]);
        varArrLengthList.push_back(arrLengthList.data[i]);


    }
  
    
}
int getArrSize(string name)
{
    for(int i=0;i<varRealNameList.size();i++)
    {
        if(varRealNameList[i]==name)
            return varArrLengthList[i];
    }
    return -1;
}
void setOffsetAndNameForParameter(SymbolInfo* id)
{
    //setting asm name for the parameters of a function
    int size=id->parameterList.size;
    currentFunc->currentFuncParameterSize=size;
    if(size!=0)
    {
        int offset=2;
     for(int i=id->parameterList.size-1;i>=0;i--)
    {
        offset+=2;
		string offsetstring=to_string(offset);
		string name= "[BP+" + offsetstring + "]";
        varAsmNameList.push_back(name);
        offsetList.push_back(offset);
        varRealNameList.push_back(id->parameterList.data[i]);
       
    }
    }
    
}







void postOrderRecursive(SymbolInfo* root) {
    if (root == nullptr)
        return;


    //now, preorder to catch func_def!
     if(root->type=="func_definition")
    {

        SymbolInfo* id=root->childrens[1];
            

       
        SymbolInfo* type_specifer=root->childrens[0];


        temp<<id->getName()<<" PROC"<<endl;
        if(id->getName()=="main")
        {
            currentFuncName=id->getName(); //setting current Func name as Main, when in main
            temp<<"	MOV AX, @DATA"<<endl;
            temp<<"	MOV DS, AX"<<endl;
        }
        temp<<"	PUSH BP"<<endl;
        temp<<"	MOV BP, SP"<<endl;
        varRealNameList.clear();
        varAsmNameList.clear();
        currentFunc=root->childrens[1];
        string label="L"+ to_string(++currentLabel);
        currentFunc->returnLabel=label;


        setOffsetAndNameForParameter(id);
        if(id->getName()=="main")
        {
             currentFunc->funcTotalOffset=0;
             offset=0;
        }
        else
        {
             currentFunc->funcTotalOffset=0;
             offset=0;
        }

        if(root->childrens.size()==6)
        {
            //with parameterList
        }
        else
        {
            //without parameterList


        }
       

    }

    if(root->type=="statement" && root->name=="PRINTLN LPAREN ID RPAREN SEMICOLON")
    {
        SymbolInfo* id=root->childrens[2];
        string name=id->getName();
        string type=id->getType();

        string asmVarName=getAsmName(name);

            if(asmVarName=="-1")
            {
                //global variable
                temp<<"	MOV AX, "<<name<<endl;
            }
            else
            {
            temp<<"	MOV AX, "<<asmVarName<<endl;
            }

            temp<<"	CALL print_output          ; Line "<<root->begin<<endl;
            temp<<"	CALL new_line"<<endl;
            printFlag=true;

    }

    if(root->name=="IF LPAREN expression RPAREN statement")
    {
        SymbolInfo* statement=root->childrens[4];
        SymbolInfo* expression=root->childrens[2];

            string label="L"+ to_string(++currentLabel);
            expression->isIfElse=true;
            expression->thisSymbolsTrueLabel=label;
            statement->thisSymbolsLabel=label;
             label="L"+ to_string(++currentLabel);
            expression->thisSymbolsNextLabel=label;
            expression->thisSymbolsFalseLabel=label; //let's set to -1 if there is no else condition



    }

     if(root->name=="IF LPAREN expression RPAREN statement ELSE statement")
    {
        SymbolInfo* statement1=root->childrens[4];
        SymbolInfo* statement2=root->childrens[6];
        SymbolInfo* expression=root->childrens[2];

            string label="L"+ to_string(++currentLabel);
            string label2="L"+ to_string(++currentLabel);

            expression->isIfElse=true;

            expression->thisSymbolsTrueLabel=label;
            statement1->thisSymbolsLabel=label;
            expression->thisSymbolsFalseLabel=label2;
            statement2->thisSymbolsLabel=label2; 
             label="L"+ to_string(++currentLabel);
            expression->thisSymbolsNextLabel=label;
            statement1->skipElseAndJumpHere=label;

    }

    if(root->type=="expression"  && root->name=="logic_expression")
    {
        SymbolInfo* child=root->childrens[0];
        child->thisSymbolsTrueLabel=root->thisSymbolsTrueLabel;
        child->thisSymbolsFalseLabel=root->thisSymbolsFalseLabel;
        child->isIfElse=root->isIfElse;
    }
    if(root->type=="logic_expression" && root->name=="rel_expression")
    {
        SymbolInfo* child=root->childrens[0];
        child->thisSymbolsTrueLabel=root->thisSymbolsTrueLabel;
        child->thisSymbolsFalseLabel=root->thisSymbolsFalseLabel;
        child->isIfElse=root->isIfElse;
    }
    //testing
    // if(root->type=="logic_expression" && root->name=="rel_expression LOGICOP rel_expression")
    // {
    //     SymbolInfo* child1=root->childrens[0];
    //     SymbolInfo* child2=root->childrens[2];
    //     child1->thisSymbolsTrueLabel=root->thisSymbolsTrueLabel;
    //     child1->thisSymbolsFalseLabel=root->thisSymbolsFalseLabel;
    //     child1->isIfElse=root->isIfElse;

    //     child2->thisSymbolsTrueLabel=root->thisSymbolsTrueLabel;
    //     child2->thisSymbolsFalseLabel=root->thisSymbolsFalseLabel;
    //     child2->isIfElse=root->isIfElse;
    // }

    // if(root->type=="rel_expression" && root->name=="simple_expression RELOP simple_expression")
    // {
    //     SymbolInfo* child1=root->childrens[0];
    //     SymbolInfo* child2=root->childrens[2];
    //     child1->thisSymbolsTrueLabel=root->thisSymbolsTrueLabel;
    //     child1->thisSymbolsFalseLabel=root->thisSymbolsFalseLabel;
    //     child1->isIfElse=root->isIfElse;

    //     child2->thisSymbolsTrueLabel=root->thisSymbolsTrueLabel;
    //     child2->thisSymbolsFalseLabel=root->thisSymbolsFalseLabel;
    //     child2->isIfElse=root->isIfElse;
    // }


    if(root->type=="statement")
    {
        string label=root->thisSymbolsLabel;
        if(label.empty()!=true)
        {
            printLabel(label);
        }
        else
        {
            string label="L"+ to_string(++currentLabel);
            printLabel(label);
            root->thisSymbolsLabel=label;
            
        }
    }
    if(root->name=="rel_expression LOGICOP rel_expression")
    {
        SymbolInfo* child1=root->childrens[0];
        SymbolInfo* child2=root->childrens[2];

        













        child1->partOfLogicExpression=true;
        child2->partOfLogicExpression=true;
        child1->leftOfLogicOp=true;
        child2->leftOfLogicOp=false;
        string label="L"+ to_string(++currentLabel);
        child2->thisSymbolsLabelForLogicOp=label;
        child1->nextSymbolsLabelForLogicOp=label;
         label="L"+ to_string(++currentLabel);

        //so that they go to same label upon true or false
        child1->trueOrFalseLabelForLogicOp=label;
        child2->trueOrFalseLabelForLogicOp=label;
        if(root->childrens[1]->getName()=="&&") 
        {
            child1->logicAnd=true;
            child2->logicAnd=true;
        }
        if(root->childrens[1]->getName()=="||") 
        {
            child1->logicOr=true;
            child2->logicOr=true;
        }
        


        

    }
    if(root->type=="rel_expression"){
        if(!root->thisSymbolsLabelForLogicOp.empty())
        printLabel(root->thisSymbolsLabelForLogicOp);
    }
    // if(root->type=="expression")
    // {
    //     if(root->isSimpleId==true)
    //     {


    //        cout<<"here we are btw"<<endl;
    //         string constInt=root->childrens[2]->parameterList.data[0];
    //         string var=root->parameterList.data[0];
    //         string asmVarName=getAsmName(var);

    //         if(asmVarName=="-1")
    //         {
    //             //global variable
    //             temp<<"	MOV AX, "<<constInt<<endl;
    //             temp<<"	MOV "<<var<<", "<<"AX"<<endl;

    //         }
    //         else
    //         {
   
    //         temp<<"	MOV AX, "<<constInt<<endl;
    //         temp<<"	MOV "<<asmVarName<<", "<<"AX"<<endl;

    //         }
    //        cout<<"here we are btw 1"<<endl;

        
            



    //     }
    // }

   if(root->name=="FOR LPAREN expression_statement expression_statement expression RPAREN statement")
    {
        SymbolInfo* exp1=root->childrens[2];
        SymbolInfo* exp2=root->childrens[3];
        SymbolInfo* exp=root->childrens[4];
        SymbolInfo* statement=root->childrens[6];
        exp1->thisSymbolsLabel="L"+ to_string(++currentLabel);
        exp2->thisSymbolsLabel="L"+ to_string(++currentLabel);
        exp->thisSymbolsLabel="L"+ to_string(++currentLabel);
        statement->thisSymbolsLabel="L"+ to_string(++currentLabel);
        exp1->isForLoop=true;
        exp2->isForLoop=true;
        exp->isForLoop=true;
        statement->isForLoop=true;
        exp->isIncLabel=true;
        statement->incLabel=exp->thisSymbolsLabel;
        exp->checkLabel=exp2->thisSymbolsLabel;

        exp2->statementLabel=statement->thisSymbolsLabel;
        root->thisSymbolsNextLabel="L"+ to_string(++currentLabel);
        exp2->nextLabel=root->thisSymbolsNextLabel;



    }


    if(root->name=="expression SEMICOLON" && root->type=="expression_statement")
    {
        SymbolInfo* child=root->childrens[0];
        printLabel(root->thisSymbolsLabel);

        child->isForLoop=root->isForLoop;
        child->statementLabel=root->statementLabel;
        child->thisSymbolsNextLabel=root->thisSymbolsNextLabel;
        child->nextLabel=root->nextLabel;
        //while loop ekhane dukbena
    }

    if(root->name=="logic_expression" && root->type=="expression")
    {
        SymbolInfo* child=root->childrens[0];
        child->isForLoop=root->isForLoop;
        child->statementLabel=root->statementLabel;
        child->thisSymbolsNextLabel=root->thisSymbolsNextLabel;
        child->nextLabel=root->nextLabel;
        child->isWhileLoop=root->isWhileLoop;
    }
     if(root->name=="rel_expression" && root->type=="logic_expression")
    {
        SymbolInfo* child=root->childrens[0];
        child->isForLoop=root->isForLoop;
         child->statementLabel=root->statementLabel;
        child->thisSymbolsNextLabel=root->thisSymbolsNextLabel;
        child->nextLabel=root->nextLabel;
        child->isWhileLoop=root->isWhileLoop;
    }

  
   
    if(root->type=="expression")
    {
        if(root->isForLoop)
        {
            printLabel(root->thisSymbolsLabel);
        }
        if(root->isWhileLoop)
        {
            printLabel(root->thisSymbolsLabel);
        }
    }

    if(root->name=="variable DECOP")
    {
        SymbolInfo* child=root->childrens[0];
        // incrementDecrement(child);
    }
    
    if(root->name=="variable INCOP")
    {
        SymbolInfo* child=root->childrens[0];
        // incrementDecrement(child);
    }
      if(root->name=="simple_expression" && root->type=="rel_expression")
    {
        
        if(root->isWhileLoop)
        {
             string name=getAsmName(root->parameterList.data[0]) != "-1" ? getAsmName(root->parameterList.data[0]) : root->parameterList.data[0];
            temp<<"	MOV AX, "<<name<<endl;
            temp<<"	PUSH AX"<<endl;

            temp<<"	DEC AX          ; Line "<<root->begin<<endl;
            temp<<"	MOV "<<name<<", AX"<<endl;
            temp<<"	POP AX"<<endl;
        }


         
         SymbolInfo* child=root->childrens[0];
        child->isForLoop=root->isForLoop;
         child->statementLabel=root->statementLabel;
        child->thisSymbolsNextLabel=root->thisSymbolsNextLabel;
        child->nextLabel=root->nextLabel;
        child->isWhileLoop=root->isWhileLoop;
        if(root->isWhileLoop)
        {
            temp<<"	CMP AX, 0"<<endl;
            temp<<"	JNE "<<root->statementLabel<<endl;
            if(!root->nextLabel.empty())
            temp<<"	JMP "<<root->nextLabel<<endl;
        }
    }

    if(root->name=="WHILE LPAREN expression RPAREN statement")
    {
        SymbolInfo* expression=root->childrens[2];
        SymbolInfo* statement=root->childrens[4];

        expression->thisSymbolsLabel="L"+ to_string(++currentLabel);
        statement->thisSymbolsLabel="L"+ to_string(++currentLabel);
        root->thisSymbolsNextLabel="L"+ to_string(++currentLabel);
        root->isWhileLoop=true;
        expression->isWhileLoop=true;
        statement->isWhileLoop=true;

        expression->statementLabel=statement->thisSymbolsLabel;
        expression->nextLabel=root->thisSymbolsNextLabel;
        statement->checkLabel=expression->thisSymbolsLabel;


    }



    // Traverse left subtree
//-----------------------------------------------------------------------------------------------------
//-------------------------------*******RECURSIVE CALL*******------------------------------------------
//-----------------------------------------------------------------------------------------------------


    // cout<<"Before "<<root->getType()<<": "<<root->getName()<<endl;
    for (int i = 0; i < root->childrens.size(); ++i) {
        SymbolInfo *child = root->childrens[i];

        postOrderRecursive(child);
    }
    // cout<<"After "<<root->getType()<<": "<<root->getName()<<endl;
   

//-----------------------------------------------------------------------------------------------------
//-------------------------------*******RECURSIVE CALL*******------------------------------------------
//-----------------------------------------------------------------------------------------------------

    // if(root->name=="unary_expression" && root->type=="term")
    // {
    //     SymbolInfo* child=root->childrens[0];
    //     incrementDecrement(child);
    // }

   if(root->name=="WHILE LPAREN expression RPAREN statement")
    {
        printLabel(root->thisSymbolsNextLabel);


    }
     if(root->type=="statement")
    {
        if(root->isForLoop)
        {
            if(!root->incLabel.empty())
           temp<<"	JMP "<<root->incLabel<<"          ; Line "<<root->begin<<endl;
        }
        if(root->isWhileLoop)
        {
            string label=root->checkLabel;
            if(label.empty()!=true)
            {

            temp<<"	JMP "<<root->checkLabel<<endl;

            }   
        

        }
    }

   
    if(root->type=="expression")
    {
        if(root->isForLoop==true && root->isIncLabel==true)  incrementDecrement(root);
        if(root->isForLoop && root->isIncLabel==true) temp<<"	JMP "<<root->checkLabel<<endl;
        
    
    }


    if(root->name=="FOR LPAREN expression_statement expression_statement expression RPAREN statement")
    {
        if(!root->thisSymbolsLabel.empty())
        printLabel(root->thisSymbolsNextLabel);
    }

    if(root->type=="statement")
    {
        if(!root->skipElseAndJumpHere.empty())
        {
            temp<<"	JMP "<<root->skipElseAndJumpHere<<"          ; Line "<<root->begin<<endl;

        }
    }

     if(root->name=="IF LPAREN expression RPAREN statement")
    {
        SymbolInfo* expression=root->childrens[2];

        printLabel(expression->thisSymbolsNextLabel);


    }

    if(root->name=="IF LPAREN expression RPAREN statement ELSE statement")
    {
       
        SymbolInfo* expression=root->childrens[2];
        printLabel(expression->thisSymbolsNextLabel);

    }
    if(root->name=="RETURN expression SEMICOLON")
    {
        SymbolInfo* child=root->childrens[1];
        if(child->stackPushed==true)
        {
            temp<<"	POP AX"<<endl;
        }
        else if(child->isSimpleId==true && child->isId==true)
        {
            //const int
            temp<<"	MOV AX, "<<child->parameterList.data[0]<<"          ; Line "<<root->begin<<endl;
        }
        else 
        {
            temp << "	MOV AX, " << (getAsmName(child->parameterList.data[0]) != "-1" ? getAsmName(child->parameterList.data[0]) : child->parameterList.data[0]) << endl;

        }
        temp<<"	JMP "<<currentFunc->returnLabel<<endl;

    }
    if(root->name=="ID LPAREN argument_list RPAREN")
    {
        SymbolInfo* parameterList=root->childrens[2];
        /*
        So basically we will write code for the function call here,i.e pushing all the parameters,
        now if it is a constant we will know by seeing its type as "CONST_INT" ,else it will be INT, global or local

        
        */
        SymbolInfo* id=root->childrens[0];
        //updating current and prev func when function call is made
        currentFuncName=id->getName();

        for(int i=0;i<parameterList->parameterList.size;i++)
        {
            string name=parameterList->parameterList.data[i];
            string type=parameterList->parameterTypeList.data[i];
            if(type=="CONST_INT")
            {
                //a const int
                temp<<"	MOV AX, "<<name<<"          ; Line "<<root->begin<<endl;
                temp<<"	PUSH AX"<<endl;
             

            }
            else
            {
                string asmName=getAsmName(name);
                if(asmName=="-1") asmName=name;
                int val=extractNumber(asmName);
                // temp<<"current: "<<functionsCalled.top()<<endl;
                // temp<<"previous: "<<prev<<endl;

                if(currentFunc->getName()=="main")
                {
                    temp<<"	MOV AX,"<<asmName<<endl;
                    temp<<"	PUSH AX"<<endl;
                }
                else if(!(currentFunc->getName() ==id->getName()))
                {
                    temp<<"	MOV AX,"<<asmName<<endl;
                    temp<<"	PUSH AX"<<endl;
                }
            
               
            
                    
                
               


            }
        }
        temp<<"	CALL "<<root->childrens[0]->getName()<<"          ; Line "<<root->begin<<endl;
        temp<<"	PUSH AX"<<endl;
        
        
    
    }

    if(root->name=="rel_expression LOGICOP rel_expression")
    {
        //printLabel(); maybe should print label?
    
        SymbolInfo* child1=root->childrens[0];
        SymbolInfo* child2=root->childrens[2];



        // if(child1->isSimpleExpression==true && child2->isSimpleExpression==true)
        // {
        //     //both are simple expression
        //     //ex. x||2, y||3, m&&n
        //     int val1=child1->val;
        //     int val2=child2->val;
        //     bool logicOr;
        //     bool logicAnd;
        //     if(root->childrens[1]->getName()=="||") logicOr=true;
        //     if(root->childrens[1]->getName()=="&&") logicAnd=true;
            
        // if(logicOr)
        // {


        //     string firstTrueLabel="L"+ to_string(++currentLabel);
        //     string firstFalseLabel="L"+ to_string(++currentLabel);
        //     string secondFalseLabel="L"+ to_string(++currentLabel);
        //     string nextLabel="L"+ to_string(++currentLabel); //this is the label where i want to go even after the statement1

        //     temp<<"printing"<<endl;

        //     if(child1->stackPushed==false)
        //     {
        //          if(child1->isId==false)
        //     temp<<"	MOV AX, "<<val1<<endl;
        //     else
        //     temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;
        //     }
        //     else
        //     {
        //         temp<<"	POP AX"<<endl;
        //     }
           

        //     temp<<"	CMP AX, 0"<<endl;

            
        //     temp<<"	JNE "<<firstTrueLabel<<endl;
        //     temp<<"	JMP "<<firstFalseLabel<<endl;
        //     printLabel(firstFalseLabel);
        //     temp<<"printing2"<<endl;

        //     if(child2->stackPushed==false)
        //     {
        //     if(child2->isId==false)
        //     temp<<"	MOV AX, "<<val2<<endl;
        //     else
        //     temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
        //     }
        //     else temp<<"	POP AX"<<endl;

                
        //     temp<<"	CMP AX,0"<<endl;

        //     temp<<"	JNE "<<firstTrueLabel<<endl; //because ekta true holei ture label e jmp
          
            
        //     temp<<"	JMP "<<secondFalseLabel<<endl; //both false so doomed
          

        //     temp<<"printing3"<<endl;

        //     printLabel(firstTrueLabel);
        //     temp<<"	MOV AX,1"<<endl;
        //     temp<<"	JMP "<<nextLabel<<endl;
        //     printLabel(secondFalseLabel);
        //     temp<<"	MOV AX,0"<<endl;
            
         
        //     printLabel(nextLabel);
        //     //sir er code e to nai. lagle uncomment korbo
        //     temp<<"	PUSH AX"<<endl;
        
        // }
        // if(logicAnd)
        // {
        //     string firstTrueLabel="L"+ to_string(++currentLabel);
        //     string firstFalseLabel="L"+ to_string(++currentLabel);
        //     string secondTrueLabel="L"+ to_string(++currentLabel);
        //     string nextLabel="L"+ to_string(++currentLabel);

            
        // //so ekhane dhorei nicchi je child1 either global/local/const hobe. but it also can be an expression
        // //like x>2. so this wasn't handled
        // if(child1->stackPushed==false)
        // {
        //      if(child1->isId==false)
        //     temp<<"	MOV AX, "<<val1<<endl;
        //     else
        //     temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;
        // }
        // else temp<<"	POP AX"<<endl;
            

        //     temp<<"	CMP AX, 0"<<endl;

            
        //     temp<<"	JNE "<<firstTrueLabel<<endl;
        //     temp<<"	JMP "<<firstFalseLabel<<endl;
        //     printLabel(firstTrueLabel);

        //     if(child2->stackPushed==false)
        //     {
        //         if(child2->isId==false)
        //     temp<<"	MOV AX, "<<val2<<endl;
        //     else
        //     temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
        //     }
        //     else temp<<"	POP AX"<<endl;

        //     temp<<"	CMP AX,0"<<endl;
        //     temp<<"	JNE "<<secondTrueLabel<<endl; 
        //     temp<<"	JMP "<<firstFalseLabel<<endl;

           
        //     printLabel(secondTrueLabel);
        //     temp<<"	MOV AX,1"<<endl;
        //     temp<<"	JMP "<<nextLabel<<endl;
        //     printLabel(firstFalseLabel);
        //     temp<<"	MOV AX,0"<<endl;
            
           
        //     printLabel(nextLabel);
        //     temp<<"	PUSH AX"<<endl;


        // }
            
        // }
        if(child1->isSimpleExpression==true && child2->isSimpleExpression==true)
        {
        int val1=child1->val;
        int val2=child2->val;
        bool logicOr;
        bool logicAnd;
        bool isIfElse=root->isIfElse;
        
      

        string finalTrueLabel=root->thisSymbolsTrueLabel;
        string finalFalseLabel=root->thisSymbolsFalseLabel;
        if(root->childrens[1]->getName()=="||") logicOr=true;
        if(root->childrens[1]->getName()=="&&") logicAnd=true;
         if(child1->stackPushed==false && child2->stackPushed==false)
        {

            
        if(logicOr)
        {


            string firstTrueLabel;
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondFalseLabel;
            string nextLabel="L"+ to_string(++currentLabel); //this is the label where i want to go even after the statement1
            if(isIfElse)
            {
                firstTrueLabel=finalTrueLabel;
                if(finalFalseLabel!="-1")
                secondFalseLabel=finalFalseLabel;
                else
                secondFalseLabel=nextLabel;
            }
            else
            {
                 firstTrueLabel="L"+ to_string(++currentLabel);
                 secondFalseLabel="L"+ to_string(++currentLabel);
            }
            if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;

            temp<<"	CMP AX, 0"<<"          ; Line "<<root->begin<<endl;

            
            temp<<"	JNE "<<firstTrueLabel<<endl;
            temp<<"	JMP "<<firstFalseLabel<<endl;
            printLabel(firstFalseLabel);

                if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            temp<<"	CMP AX,0"<<endl;

            temp<<"	JNE "<<firstTrueLabel<<endl; //because ekta true holei ture label e jmp
          
            
            temp<<"	JMP "<<secondFalseLabel<<endl; //both false so doomed
          

            if(isIfElse==false)
            {
            printLabel(firstTrueLabel);
            temp<<"	MOV AX,1"<<endl;
            temp<<"	JMP "<<nextLabel<<endl;
            printLabel(secondFalseLabel);
            temp<<"	MOV AX,0"<<endl;
            }
         
            printLabel(nextLabel);

            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;
        
        }
        if(logicAnd)
        {
            string firstTrueLabel="L"+ to_string(++currentLabel);
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondTrueLabel="L"+ to_string(++currentLabel);
            string nextLabel="L"+ to_string(++currentLabel);

            //created 4 labels

            if(isIfElse)
            {
                secondTrueLabel=finalTrueLabel;
                firstFalseLabel=finalFalseLabel;
            }
            
        //so ekhane dhorei nicchi je child1 either global/local/const hobe. but it also can be an expression
        //like x>2. so this wasn't handled
             if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;

            temp<<"	CMP AX, 0"<<endl;

            
                temp<<"	JNE "<<firstTrueLabel<<endl;
                temp<<"	JMP "<<firstFalseLabel<<endl;
                printLabel(firstTrueLabel);

                if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            temp<<"	CMP AX,0"<<endl;
            temp<<"	JNE "<<secondTrueLabel<<endl; 
            temp<<"	JMP "<<firstFalseLabel<<endl;

            if(isIfElse==false)
            {
                 printLabel(secondTrueLabel);
                temp<<"	MOV AX,1"<<"          ; Line "<<root->begin<<endl;
                temp<<"	JMP "<<nextLabel<<endl;
                printLabel(firstFalseLabel);
                temp<<"	MOV AX,0"<<endl;
            }
            
           
            printLabel(nextLabel);
            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;

        }

        }
        else if(child1->stackPushed==true && child2->stackPushed==false)
        {
            //simple_expression's holding value is in stack
            //first normal operation for the term

            if(logicOr)
        {


            string firstTrueLabel;
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondFalseLabel;
            string nextLabel="L"+ to_string(++currentLabel); //this is the label where i want to go even after the statement1
            if(isIfElse)
            {
                firstTrueLabel=finalTrueLabel;
                if(finalFalseLabel!="-1")
                secondFalseLabel=finalFalseLabel;
                else
                secondFalseLabel=nextLabel;
            }
            else
            {
                 firstTrueLabel="L"+ to_string(++currentLabel);
                 secondFalseLabel="L"+ to_string(++currentLabel);
            }
            temp<<"	POP AX"<<endl;


            temp<<"	CMP AX, 0"<<endl;

            
            temp<<"	JNE "<<firstTrueLabel<<endl;
            temp<<"	JMP "<<firstFalseLabel<<endl;
            printLabel(firstFalseLabel);

                if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<"          ; Line "<<root->begin<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            temp<<"	CMP AX,0"<<endl;

            temp<<"	JNE "<<firstTrueLabel<<endl; //because ekta true holei ture label e jmp
          
            
            temp<<"	JMP "<<secondFalseLabel<<endl; //both false so doomed
          

            if(isIfElse==false)
            {
            printLabel(firstTrueLabel);
            temp<<"	MOV AX,1"<<"          ; Line "<<root->begin<<endl;
            temp<<"	JMP "<<nextLabel<<endl;
            printLabel(secondFalseLabel);
            temp<<"	MOV AX,0"<<endl;
            }
         
            printLabel(nextLabel);

            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;
        
        }
        if(logicAnd)
        {
            string firstTrueLabel="L"+ to_string(++currentLabel);
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondTrueLabel="L"+ to_string(++currentLabel);
            string nextLabel="L"+ to_string(++currentLabel);

            if(isIfElse)
            {
                secondTrueLabel=finalTrueLabel;
                firstFalseLabel=finalFalseLabel;
            }
            

            temp<<"	POP AX"<<endl;


            temp<<"	CMP AX, 0"<<endl;

            
                temp<<"	JNE "<<firstTrueLabel<<endl;
                temp<<"	JMP "<<firstFalseLabel<<endl;
                printLabel(firstTrueLabel);

                if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            temp<<"	CMP AX,0"<<"          ; Line "<<root->begin<<endl;
            temp<<"	JNE "<<secondTrueLabel<<endl; 
            temp<<"	JMP "<<firstFalseLabel<<endl;

            if(isIfElse==false)
            {
                 printLabel(secondTrueLabel);
                temp<<"	MOV AX,1"<<endl;
                temp<<"	JMP "<<nextLabel<<endl;
                printLabel(firstFalseLabel);
                temp<<"	MOV AX,0"<<endl;
            }
            
           
            printLabel(nextLabel);
            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;

        }


        }
        else if(child1->stackPushed==false && child2->stackPushed==true)
        {
            //term is calculated now we are adding a single integer with that
            
               if(logicOr)
        {


            string firstTrueLabel;
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondFalseLabel;
            string nextLabel="L"+ to_string(++currentLabel); //this is the label where i want to go even after the statement1
            if(isIfElse)
            {
                firstTrueLabel=finalTrueLabel;
                if(finalFalseLabel!="-1")
                secondFalseLabel=finalFalseLabel;
                else
                secondFalseLabel=nextLabel;
            }
            else
            {
                 firstTrueLabel="L"+ to_string(++currentLabel);
                 secondFalseLabel="L"+ to_string(++currentLabel);
            }
             if(child1->isId==false)
              temp<<"	MOV AX, "<<val1<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;


            temp<<"	CMP AX, 0"<<"          ; Line "<<root->begin<<endl;

            
            temp<<"	JNE "<<firstTrueLabel<<endl;
            temp<<"	JMP "<<firstFalseLabel<<endl;
            printLabel(firstFalseLabel);

            temp<<"	POP AX"<<endl;
            
            temp<<"	CMP AX,0"<<endl;

            temp<<"	JNE "<<firstTrueLabel<<endl; //because ekta true holei ture label e jmp
          
            
            temp<<"	JMP "<<secondFalseLabel<<endl; //both false so doomed
          

            if(isIfElse==false)
            {
            printLabel(firstTrueLabel);
            temp<<"	MOV AX,1"<<endl;
            temp<<"	JMP "<<nextLabel<<endl;
            printLabel(secondFalseLabel);
            temp<<"	MOV AX,0"<<endl;
            }
         
            printLabel(nextLabel);

            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;
        
        }
        if(logicAnd)
        {
            string firstTrueLabel="L"+ to_string(++currentLabel);
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondTrueLabel="L"+ to_string(++currentLabel);
            string nextLabel="L"+ to_string(++currentLabel);

            if(isIfElse)
            {
                secondTrueLabel=finalTrueLabel;
                firstFalseLabel=finalFalseLabel;
            }
            
             if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;



            temp<<"	CMP AX, 0"<<"          ; Line "<<root->begin<<endl;

            
                temp<<"	JNE "<<firstTrueLabel<<endl;
                temp<<"	JMP "<<firstFalseLabel<<endl;
                printLabel(firstTrueLabel);

            temp<<"	POP AX"<<endl;
                
            temp<<"	CMP AX,0"<<endl;
            temp<<"	JNE "<<secondTrueLabel<<endl; 
            temp<<"	JMP "<<firstFalseLabel<<endl;

            if(isIfElse==false)
            {
                 printLabel(secondTrueLabel);
                temp<<"	MOV AX,1"<<endl;
                temp<<"	JMP "<<nextLabel<<endl;
                printLabel(firstFalseLabel);
                temp<<"	MOV AX,0"<<endl;
            }
            
           
            printLabel(nextLabel);
            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;

        }


        }
         else if(child1->stackPushed==true && child2->stackPushed==true)
        {
                   if(logicOr)
        {


            string firstTrueLabel;
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondFalseLabel;
            string nextLabel="L"+ to_string(++currentLabel); //this is the label where i want to go even after the statement1
            if(isIfElse)
            {
                firstTrueLabel=finalTrueLabel;
                if(finalFalseLabel!="-1")
                secondFalseLabel=finalFalseLabel;
                else
                secondFalseLabel=nextLabel;
            }
            else
            {
                 firstTrueLabel="L"+ to_string(++currentLabel);
                 secondFalseLabel="L"+ to_string(++currentLabel);
            }
            temp<<"	POP AX"<<endl;


            temp<<"	CMP AX, 0"<<endl;

            
            temp<<"	JNE "<<firstTrueLabel<<endl;
            temp<<"	JMP "<<firstFalseLabel<<endl;
            printLabel(firstFalseLabel);

            temp<<"	POP AX"<<"          ; Line "<<root->begin<<endl;
            
            temp<<"	CMP AX,0"<<endl;

            temp<<"	JNE "<<firstTrueLabel<<endl; //because ekta true holei ture label e jmp
          
            
            temp<<"	JMP "<<secondFalseLabel<<endl; //both false so doomed
          

            if(isIfElse==false)
            {
            printLabel(firstTrueLabel);
            temp<<"	MOV AX,1"<<endl;
            temp<<"	JMP "<<nextLabel<<endl;
            printLabel(secondFalseLabel);
            temp<<"	MOV AX,0"<<endl;
            }
         
            printLabel(nextLabel);

            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;
        
        }
        if(logicAnd)
        {
            string firstTrueLabel="L"+ to_string(++currentLabel);
            string firstFalseLabel="L"+ to_string(++currentLabel);
            string secondTrueLabel="L"+ to_string(++currentLabel);
            string nextLabel="L"+ to_string(++currentLabel);

            if(isIfElse)
            {
                secondTrueLabel=finalTrueLabel;
                firstFalseLabel=finalFalseLabel;

            }
            

            temp<<"	POP AX"<<endl;


            temp<<"	CMP AX, 0"<<endl;

            
                temp<<"	JNE "<<"          ; Line "<<root->begin<<firstTrueLabel<<endl;
                temp<<"	JMP "<<firstFalseLabel<<endl;
                printLabel(firstTrueLabel);

            temp<<"	POP AX"<<endl;
                
            temp<<"	CMP AX,0"<<endl;
            temp<<"	JNE "<<secondTrueLabel<<endl; 
            temp<<"	JMP "<<firstFalseLabel<<endl;

            if(isIfElse==false)
            {

                 printLabel(secondTrueLabel);
                temp<<"	MOV AX,1"<<endl;
                temp<<"	JMP "<<nextLabel<<endl;
                printLabel(firstFalseLabel);
                temp<<"	MOV AX,0"<<endl;
            }
            
           
            printLabel(nextLabel);
            if(isIfElse==false)
            temp<<"	PUSH AX"<<endl;

        }
        }
        }

       

        incrementDecrement(child1);
        incrementDecrement(child2);
   
    }
    if(root->name=="simple_expression RELOP simple_expression")
    {

        //printLabel(); maybe should print label?
        SymbolInfo* child1=root->childrens[0];
        SymbolInfo* child2=root->childrens[2];
         int val1=child1->val;
        int val2=child2->val;
        bool greater;
        bool greaterEqual;
        bool less;
        bool lessEqual;
        bool equal;
        bool notEqual;
        bool isIfElse=root->isIfElse;
        bool isForLoop=root->isForLoop;
        bool isWhileLoop=root->isWhileLoop;
        if(root->childrens[1]->getName()==">=") 
        {
            greaterEqual=true;
            greater=false;
            less=false;
            lessEqual=false;
            equal=false;
            notEqual=false;
        }
        if(root->childrens[1]->getName()==">") 
        {
            greaterEqual=false;
            greater=true;
            less=false;
            lessEqual=false;
            equal=false;
            notEqual=false;
        }
        if(root->childrens[1]->getName()=="<")
        {
             greaterEqual=false;
            greater=false;
            less=true;
            lessEqual=false;
            equal=false;
            notEqual=false;
        }
        if(root->childrens[1]->getName()=="<=") 
        {
             greaterEqual=false;
            greater=false;
            less=false;
            lessEqual=true;
            equal=false;
            notEqual=false;
        }
        if(root->childrens[1]->getName()=="==") 
        {
             greaterEqual=false;
            greater=false;
            less=false;
            lessEqual=false;
            equal=true;
            notEqual=false;
        }
        if(root->childrens[1]->getName()=="!=") 
        {
             greaterEqual=false;
            greater=false;
            less=false;
            lessEqual=false;
            equal=false;
            notEqual=true;
        }

        string finalTrueLabel=root->thisSymbolsTrueLabel;
        string finalFalseLabel=root->thisSymbolsFalseLabel;
        string trueLabel;
        string falseLabel;
        string nextLabel="L"+to_string(++currentLabel);
        if(isIfElse)
        {
            trueLabel=finalTrueLabel;
            falseLabel=finalFalseLabel;
        }
       

        else if(root->partOfLogicExpression==true && root->leftOfLogicOp==true && root->logicAnd==true )
        {
            //true hole rel er dan e je thakbe tar kache jump korbe
            trueLabel=root->nextSymbolsLabelForLogicOp;
            //false hole dead to false, but ekhane print korbo na , just JMP instruc
            //likhe dibo
            falseLabel=root->trueOrFalseLabelForLogicOp;

        }
        else  if(root->partOfLogicExpression==true && root->leftOfLogicOp==true && root->logicOr==true )
        {
            trueLabel=root->trueOrFalseLabelForLogicOp;
            //false hole dead to false, but ekhane print korbo na , just JMP instruc
            //likhe dibo
            falseLabel=root->nextSymbolsLabelForLogicOp;

        }
        else if(root->partOfLogicExpression==true && root->leftOfLogicOp==false && root->logicAnd==true )
        
        {
            //for and both true then jump to new label
            trueLabel="L"+ to_string(++currentLabel);

            //and false label alreay exist
            falseLabel=root->trueOrFalseLabelForLogicOp;
        }
        else if(root->partOfLogicExpression==true && root->leftOfLogicOp==false && root->logicOr==true )
        {
            trueLabel=root->trueOrFalseLabelForLogicOp;
            falseLabel="L"+ to_string(++currentLabel);
        }
        else if(isForLoop)
        {
            trueLabel=root->statementLabel;
            falseLabel=root->nextLabel;
        }
        else if(isWhileLoop)
        {
            trueLabel=root->statementLabel;
            falseLabel=root->nextLabel;
        }
        else
        {
            trueLabel="L"+ to_string(++currentLabel);
            falseLabel="L"+ to_string(++currentLabel);
        }



        //will write the logics here
        //two normal term
        
            if(child2->stackPushed==false)
            {
                 if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            }
            else
            {
                temp<<"	POP AX"<<endl;
            }
           



            temp<<"	MOV DX, AX"<<"          ; Line "<<root->begin<<endl;

            if(child1->stackPushed==false)
            {
                 if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else 
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;
            }
            else
            {
                temp<<"	POP AX"<<endl;
            }
           


            temp<<"	CMP AX, DX"<<endl;


            if(greaterEqual)  temp<<"	JGE "<<trueLabel<<endl;
            if(greater)  temp<<"	JG "<<trueLabel<<endl;
            if(lessEqual)  temp<<"	JLE "<<trueLabel<<endl;
            if(less)  temp<<"	JL "<<trueLabel<<endl;
            if(equal)  temp<<"	JE "<<trueLabel<<endl;
            if(notEqual)  temp<<"	JNE "<<trueLabel<<endl;
            temp<<"	JMP "<<falseLabel<<endl;
            
            if(!isIfElse && !isForLoop && !isWhileLoop)
            {


            if(!(root->partOfLogicExpression==true && root->leftOfLogicOp==true))
            {
                 printLabel(trueLabel);

                temp<<"	MOV AX, 1"<<"          ; Line "<<root->begin<<endl;
                temp<<"	JMP "<<nextLabel<<endl;
                printLabel(falseLabel);
                temp<<"	MOV AX,0"<<endl;
            }
           
            }
           
            printLabel(nextLabel);
            if(!isIfElse && !isForLoop && !isWhileLoop)
            {
                      if(!(root->partOfLogicExpression && root->leftOfLogicOp))
            temp<<"	PUSH AX"<<endl;
        }
       
    incrementDecrement(child1);
    incrementDecrement(child2);




    }

     if(root->name=="term MULOP unary_expression")
    {
        SymbolInfo* child1=root->childrens[0];
        SymbolInfo* child2=root->childrens[2];
        int val1=child1->val;
        int val2=child2->val;
        bool mul;
        bool divide;
        bool mod;
        if(root->childrens[1]->getName()=="*") {
            mul=true;
            divide=false;
            mod=false;
        }
        else if(root->childrens[1]->getName()=="/")
        {
             divide=true;
             mul=false;
             mod=false;
        }
        else if(root->childrens[1]->getName()=="%")
        {
             mod=true;
             mul=false;
             divide=false;
        }


        //will write the logics here
        if(child1->stackPushed==false && child2->stackPushed==false)
        {
              if(child2->isId==false)
              {
                 temp<<"	MOV AX, "<<val2<<"          ; Line "<<root->begin<<endl;
              }
           
            else
            {
                temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            }


            temp<<"	MOV CX, AX"<<endl;


            if(child1->isId==false)
            {
            temp<<"	MOV AX, "<<val1<<endl;

            }
            else 
            {
               string name= getAsmName(child1->parameterList.data[0]);
             temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;
            }


            temp<<"	CWD"<<endl;
            if(mul)
            {
            temp<<"	MUL CX"<<endl;
            }
            else if(divide ||mod)
            {
                //divide 
                  temp<<"	DIV CX"<<endl;
            }
          
          if(mul||divide)  temp<<"	PUSH AX"<<"          ; Line "<<root->begin<<endl;
          if(mod) temp<<"	PUSH DX"<<endl;

          
          
        }
        else if(child1->stackPushed==true && child2->stackPushed==false)
        {
            //simple_expression's holding value is in stack
            //first normal operation for the term

               if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else 
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;

            temp<<"	MOV CX, AX"<<endl;
            //now pop the value of simple expression
            temp<<"	POP AX"<<endl;
            temp<<"	CWD"<<endl;
           if(mul)
            temp<<"	MUL CX"<<"          ; Line "<<root->begin<<endl;
            else if(divide || mod)
            temp<<"	DIV CX"<<endl;
            if(mul||divide)
            temp<<"	PUSH AX"<<endl;
            if(mod)
            temp<<"	PUSH DX"<<endl;

        }
        else if(child1->stackPushed==false && child2->stackPushed==true)
        {
            
            temp<<"	POP AX"<<endl;  //child2

            temp<<"	MOV CX, AX"<<endl;
            //now pop the value of simple expression
            if(child2->isId==false)
            temp<<"	MOV AX, "<<val1<<endl; //child1
            else 
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;
            temp<<"	CWD"<<endl;
           if(mul)
            temp<<"	MUL CX"<<endl;
            else if(divide || mod)
            temp<<"	DIV CX"<<endl;
            if(mul||divide)
            temp<<"	PUSH AX"<<"          ; Line "<<root->begin<<endl;
            if(mod)
            temp<<"	PUSH DX"<<endl;
        }
        else if(child1->stackPushed==true && child2->stackPushed==true)
        {
            temp<<"	POP AX"<<endl;  //child2

            temp<<"	MOV CX, AX"<<endl;
            //now pop the value of simple expression
            temp<<"	POP AX"<<endl;  //child1

            temp<<"	CWD"<<endl;
           if(mul)
            temp<<"	MUL CX"<<endl;
            else if(divide || mod)
            temp<<"	DIV CX"<<endl;
            if(mul||divide)
            temp<<"	PUSH AX"<<endl;
            if(mod)
            temp<<"	PUSH DX"<<endl;
        }

        
         incrementDecrement(child1);
         incrementDecrement(child2);

    }


if(root->name=="ADDOP unary_expression" || root->name=="NOT unary_expression")
{

    SymbolInfo* operation=root->childrens[0];
    SymbolInfo* child1=root->childrens[1];
    int val1=child1->val;
    bool isNot;
    bool isNeg;
    bool isPos;
    if(operation->getName()=="!") isNot=true;
    if(operation->getName()=="-") isNeg=true;
    if(operation->getName()=="+") isPos=true;

    if(child1->stackPushed==false )
        {


            if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else
            temp << "MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;
            
            if(isNot) temp<<"	NOT AX"<<endl;
            if(isNeg) temp<<"	NEG AX"<<endl;
            temp<<"	PUSH AX"<<endl;
        }
        else if(child1->stackPushed==true)
        {

            temp<<"	POP AX"<<endl;
            if(isNot) temp<<"	NOT AX"<<endl;
            if(isNeg) temp<<"	NEG AX"<<"          ; Line "<<root->begin<<endl;
            temp<<"	PUSH AX"<<endl;
        }
        
        incrementDecrement(child1);

    


}
if(root->name=="variable ASSIGNOP logic_expression")
{
    SymbolInfo* variable=root->childrens[0];
    SymbolInfo* logicExpression=root->childrens[2];
    bool global;
    bool local;
    if(variable->isThisArray==true || logicExpression->isThisArray==true)
    {


        
    //     //if not array that is already handled
        if(variable->isThisArray==true && logicExpression->isThisArray==false)
        {
          handleGlobalArrAndInt(variable,logicExpression);
          handleLocalArrAndInt(variable,logicExpression);

        }


        if(variable->isThisArray==false && logicExpression->isThisArray==true)
        {
            handleIntAndGlobalArr(variable,logicExpression);
            handleIntAndLocalArr(variable,logicExpression);
          
        }

        if(variable->isThisArray==true && logicExpression->isThisArray==true)
        {
            handleGlobalArrAndGlobalArr(variable,logicExpression);
            handleGlobalArrAndLocalArr(variable,logicExpression);
            handleLocalArrAndLocalArr(variable,logicExpression);
            handleLocalArrAndGlobalArr(variable,logicExpression);
        }


        incrementDecrement(logicExpression);

        


    }

























}

     
if(root->name=="simple_expression ADDOP term")
    {
        SymbolInfo* child1=root->childrens[0];
        SymbolInfo* child2=root->childrens[2];
        int val1=child1->val;
        int val2=child2->val;


   
        bool add;
       
        if(root->childrens[1]->getName()=="+")  add=true;
        else add=false;

        //will write the logics here
        if(child1->stackPushed==false && child2->stackPushed==false)
        {


            if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else
            temp << "MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;



            temp<<"	MOV DX, AX"<<"          ; Line "<<root->begin<<endl;


            if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else 
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;



            if(add)
            {
            temp<<"	ADD AX,DX"<<endl;

            }

            else
            temp<<"	SUB AX, DX"<<endl;
            temp<<"	PUSH AX"<<endl;
        }
        else if(child1->stackPushed==true && child2->stackPushed==false)
        {
            //simple_expression's holding value is in stack
            //first normal operation for the term
             if(child2->isId==false)
            temp<<"	MOV AX, "<<val2<<endl;
            else 
            temp << "	MOV AX, " << (getAsmName(child2->parameterList.data[0]) != "-1" ? getAsmName(child2->parameterList.data[0]) : child2->parameterList.data[0]) << endl;
            temp<<"	MOV DX, AX"<<endl;
            //now pop the value of simple expression
            temp<<"	POP AX"<<endl;
            if(add)
           {
             temp<<"	ADD AX,DX"<<endl;
           }
            else
            temp<<"	SUB AX, DX"<<endl;
            temp<<"	PUSH AX"<<endl;
        }
        else if(child1->stackPushed==false && child2->stackPushed==true)
        {
            //term is calculated now we are adding a single integer with that
            
           temp<<"	POP AX"<<"          ; Line "<<root->begin<<endl;
           //term's value is on DX
           temp<<"	MOV DX,AX"<<endl;


            if(child1->isId==false)
            temp<<"	MOV AX, "<<val1<<endl;
            else
            temp << "	MOV AX, " << (getAsmName(child1->parameterList.data[0]) != "-1" ? getAsmName(child1->parameterList.data[0]) : child1->parameterList.data[0]) << endl;


           if(add)
            {
                temp<<"	ADD AX,DX"<<endl;
            }
            else
            temp<<"	SUB AX, DX"<<endl;

           temp<<"	PUSH AX"<<endl;

        }
         else if(child1->stackPushed==true && child2->stackPushed==true)
        {
            temp<<"	POP AX"<<endl;
            temp<<"	MOV DX, AX"<<endl; //child2->first pop
            temp<<"	POP AX"<<endl; //child1 ->second pop
            if(add)
            {
                temp<<"	ADD AX,DX"<<endl;
            }
            else 
            temp<<"	SUB AX,DX"<<"          ; Line "<<root->begin<<endl;
            temp<<"	PUSH AX"<<endl;
        }

        incrementDecrement(child1);
        incrementDecrement(child2);

    }

    if(root->name=="expression SEMICOLON")
    {
        SymbolInfo* child=root->childrens[0];
        incrementDecrement(child);
        //rest stuffs will be added according to necessary
        //return expression semicolon rules eo dibo? pore vaba jabe
    }
  

    //lets move it to preorder
    if(root->name=="variable ASSIGNOP logic_expression")
    {
        
        SymbolInfo* variable=root->childrens[0];
        SymbolInfo* child=root->childrens[2];
        if(variable->isThisArray==false && child->isThisArray==false)
        {
              string realName=variable->parameterList.data[0];
            string name=getAsmName(realName);
            if(name=="-1") name=realName; //if global keep the real name

        //we know our previously calculated value is in the AX FOR SURE
        //so pop it and we will do it only if IT IS NOT A SIMPLE ID
        if(child->stackPushed==false)
        {


        
         if(child->isSimpleId==true)
        {
            //const int;

            string varName=child->parameterList.data[0];
            temp<<"	MOV AX, "<<varName<<endl;
            temp<<"	MOV "<<name<<", AX"<<endl;

        }
        else if(child->isId==true)
        {

        temp << "	MOV AX, " << (getAsmName(child->parameterList.data[0]) != "-1" ? getAsmName(child->parameterList.data[0]) : child->parameterList.data[0]) << endl;

        temp<<"	MOV "<<name<<", AX"<<"          ; Line "<<root->begin<<endl;

        }
        }
        else
        {
            temp<<"	POP AX"<<endl;
        //transfer the value of AX to the local variable
        temp<<"	MOV "<<name<<", AX"<<endl;
        }

        incrementDecrement(child);
       
        }
      
        
       
    }


 
    // Traverse right subtree
    if(root->type=="factor" && root->name=="CONST_INT")
    {
        //got one integer of the expression
        //now push it onto the stack
        string value=root->childrens[0]->getName();
        currentAX.push(value);

        if(root->isSimpleId==false)
        {
            //because Simple Id is handled separately
            string constInt=root->childrens[0]->getName();

            temp<<"	MOV AX,"<<constInt<<"          ; Line "<<root->begin<<endl;
            if(expressionBegin==false) 
            {
                temp<<"	MOV DX,AX"<<endl;
                expressionBegin=true;
            }
            else 
            {
                if(firstTwoTermEvaluated==false)
                {
                    temp<<"	ADD AX,DX"<<endl;
                    temp<<"	PUSH AX"<<endl;
                    firstTwoTermEvaluated=true;
                }
                else
                {

                }
            }

            



        }

        
    }

    if(root->type=="func_definition")
    {

        SymbolInfo* id=root->childrens[1];
        printLabel(currentFunc->returnLabel);

        //post order to catch the end of function
        temp<<"	ADD SP,"<<currentFunc->funcTotalOffset<<endl;
        temp<<"	POP BP"<<endl;
        

      

        if(id->getName()=="main")
        {
            temp<<"	MOV AX,4CH"<<"          ; Line "<<root->begin<<endl;
            temp<<"	INT 21H"<<endl;
        }
       if(id->getName()!="main") 
       {

        if(currentFunc->currentFuncParameterSize!=0)
        temp<<"	RET "<<currentFunc->currentFuncParameterSize*2<<endl;
        else temp<<"	RET"<<endl;
       }
        temp<<root->childrens[1]->name<<" ENDP"<<endl;
        
        if(id->getName()=="main")
        {
             currentFunc->funcTotalOffset=0;
             offset=0;
        }
        else
        {
             currentFunc->funcTotalOffset=0;
             offset=0;
        }
       

        varRealNameList.clear();
        varAsmNameList.clear();
        varArrLengthList.clear();




        currentFunc=root->childrens[1];

        //set the assembly name for all the paramter of a function


    }

   if(root->type=="var_declaration")
    {

        

        if(root->scopeId=="1")
        {
       
            //global variable found
            for(int i=0;i<root->idList.size;i++)
            {
                code<<"	"<<root->idList.data[i]<<" DW "<<root->arrLengthList.data[i]<<" DUP (0000H)"<<endl;
            }



        }

        else
        {

          
            //local variable
            setOffsetAndName(root->idList,root->arrLengthList);
            for(int i=0;i<root->childrens[1]->idList.size;i++)
            {
                temp<<"	SUB SP,"<<root->childrens[1]->arrLengthList.data[i]*2<<endl;
                currentFunc->funcTotalOffset+=2*(root->childrens[1]->arrLengthList.data[i]);
            }

        }


    }
   


   
}



void postOrder() {

    code<<".MODEL SMALL"<<endl;
    code<<".STACK 100H"<<endl;
    code<<".Data"<<endl;
    code<<"	number DB \"00000$\""<<endl;


    temp<<".CODE"<<endl;
    if (this == nullptr)
        return;
    
    postOrderRecursive(this);
    if(printFlag==true)
    {
            ifstream txtFile("2005097_PrintLibrary.txt");
            string line;
            while(getline(txtFile,line))
            {
                temp<<line<<endl;
            }
            txtFile.close();

    }
    temp<<"end Main"<<endl;


    
}






};
#endif // SYMBOLINFO_H
