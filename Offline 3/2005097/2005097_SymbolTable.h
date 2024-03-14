#include<bits/stdc++.h>
#include<string>
#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
extern std::ofstream tokenout;
extern std::ofstream logout;

class SymbolTable
{
public:
    ScopeTable *currentScopeTable;
    int tableCount=0;
    int scopeCount=1;

    SymbolTable(int n)
    {
        currentScopeTable = new ScopeTable(n);
        tableCount++;
        // cout<<"Symbol table created"<<endl;
    }
    ~SymbolTable();

    void enter();
    string printAll();
    void exit();

    bool insertSymbolInCurrentScope(string name,string type,bool isFunction=false,bool isArray=false);
    bool removeFromCurrentScope(string name);
    SymbolInfo* lookUp(string name);
    SymbolInfo* lookUp2(string name);

};
#endif // SYMBOLTABLE_H
