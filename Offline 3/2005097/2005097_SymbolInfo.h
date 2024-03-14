#include<iostream>
#include<string>
#include<fstream>
#include "2005097_Tree.h"
#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

using namespace std;

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
    bool isThisArray;
    bool voidChecked;
    bool modulusChecked;
    Tree<string> parseTree;
    CustomVector<string>parameterList;
    CustomVector<string>parameterTypeList;
    CustomVector<bool>isArray;
    CustomVector<string>idList;
    CustomVector<int>arrLengthList;
    CustomVector<int>functionVariablesPosition;



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
};
#endif // SYMBOLINFO_H
