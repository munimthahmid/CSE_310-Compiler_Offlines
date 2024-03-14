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
            id = s1 + "." + s2;
        }
        out << "	ScopeTable# " << id << " created" << endl;
    }
    ScopeTable(size_t n,ScopeTable* parentScope)
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
            string s2 = to_string(parentScope->exit_count + 1);
            this->id = s1 + "." + s2;
        }
        this->parentScope=parentScope;
        out << "	ScopeTable# " << id << " created" << endl;
    }
    ~ScopeTable();

    bool insert(string name, string type);
    SymbolInfo *lookUp(string name);
    SymbolInfo *lookUp2(string name);

    bool deleteSymbol(string name);
    void printScopeTable();
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
