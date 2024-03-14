#include<iostream>
#include<string>
#include<fstream>
#ifndef SCOPETABLE_H
#define SCOPETABLE_H
#include "2005097_SymbolInfo.h"
class ScopeTable
{
private:
    SymbolInfo **symbolInfos;
    size_t tableSize;
    ScopeTable *parentScope=nullptr;
    string id;

public:

    int exit_count = 0;

    ScopeTable(size_t n)
    {
        tableSize = n;

        symbolInfos = new SymbolInfo *[tableSize];
        for (size_t i = 0; i < tableSize; i++)
        {
            symbolInfos[i] = nullptr;
        }

        if (parentScope == nullptr)
        {
            id = "1";
        }
        else
        {
            string s1 = parentScope->id;
            string s2 = to_string(exit_count + 1);
            int x1=stoi(s1);
            int x2=stoi(s2);
            int x=x1+x2;
            string id=to_string(x);
        }
        // out << "	ScopeTable# " << id << " created" << endl;
    }
    ScopeTable(size_t n,ScopeTable* parentScope,int scopeCount)
    {
        tableSize = n;

        symbolInfos = new SymbolInfo *[tableSize];
        for (size_t i = 0; i < tableSize; i++)
        {
            symbolInfos[i] = nullptr;
        }

        if (parentScope == nullptr)
        {
            id = "1";
        }
        else
        {
            string s1 = parentScope->id;
            string s2 = to_string(exit_count + 1);
            int x1=stoi(s1);
            int x2=stoi(s2);
            int x=x1+x2;
            
             id=to_string(scopeCount);
        }
        this->parentScope=parentScope;
        // out << "	ScopeTable# " << id << " created" << endl;
    }
    ~ScopeTable();

    bool insert(string name, string type,bool isFunction=false,bool isArray=false);
    SymbolInfo *lookUp(string name);
    SymbolInfo *lookUp2(string name);

    bool deleteSymbol(string name);
    string printScopeTable();
    SymbolInfo **getSymbolInfos();
    size_t getTableSize();
    ScopeTable *getParentScope();
    void setSymbolInfos(SymbolInfo **infos);
    void setTableSize(size_t size);
    void setParentScope(ScopeTable *parent);
    void setId(string s);
    string getId();
    void incrementExitCount();

    unsigned long long hash(const string &s);
};
#endif // SCOPETABLE_H
