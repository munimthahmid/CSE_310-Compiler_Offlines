#include<iostream>
#include<string>
#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"

class SymbolTable
{
public:
    ScopeTable *currentScopeTable;
    int tableCount=0;

    SymbolTable(int n)
    {
        currentScopeTable = new ScopeTable(n);
        tableCount++;
    }
    ~SymbolTable();

    void enter();
    void printAll();
    void exit();

    bool insertSymbolInCurrentScope(string name,string type);
    bool removeFromCurrentScope(string name);
    SymbolInfo* lookUp(string name);
    SymbolInfo* lookUp2(string name);

};
#endif // SYMBOLTABLE_H
