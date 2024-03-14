    
#include<iostream>
#include<string>
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
#include "2005097_SymbolTable.h"

    SymbolTable::~SymbolTable()
    {
        if (currentScopeTable != nullptr)

        {
            delete currentScopeTable;
        }
    }

    void SymbolTable::enter()
    {
        ScopeTable *parent = currentScopeTable;
        ScopeTable *newScopeTable = new ScopeTable(currentScopeTable->getTableSize(),currentScopeTable);
        this->currentScopeTable = newScopeTable;
        this->currentScopeTable->setParentScope(parent);
        tableCount++;
    }
    void SymbolTable::printAll()
    {
        ScopeTable* cur=currentScopeTable;
        while(cur!=nullptr)
        {
            cur->printScopeTable();
            cur=cur->getParentScope();
        }
    }
    void SymbolTable::exit()
    {
        if (currentScopeTable->getParentScope() != nullptr)
        {
            ScopeTable *cur = currentScopeTable;
            currentScopeTable = currentScopeTable->getParentScope();
            currentScopeTable->incrementExitCount();


            // Move the cout statement before deleting the scope table
            delete cur;
        }
        else
        {
            out << "	ScopeTable# 1 cannot be deleted" << endl;
        }
    }


    bool SymbolTable::insertSymbolInCurrentScope(string name,string type)
    {
        return currentScopeTable->insert(name,type);
    }
    bool SymbolTable::removeFromCurrentScope(string name)
    {
        return currentScopeTable->deleteSymbol(name);
    }
    SymbolInfo* SymbolTable::lookUp(string name)
    {
        ScopeTable *cur=currentScopeTable;
        for(int i=0; i<tableCount; i++)
        {
            if(cur->lookUp2(name)==nullptr)
            {

                if(cur->getParentScope()!=nullptr)
                    cur=cur->getParentScope();
                else break;
            }
            else return cur->lookUp(name);
        }
        return nullptr;
    }
    SymbolInfo* SymbolTable::lookUp2(string name)
    {
        ScopeTable *cur=currentScopeTable;
        for(int i=0; i<tableCount; i++)
        {
            if(cur->lookUp2(name)==nullptr)
            {

                if(cur->getParentScope()!=nullptr)
                    cur=cur->getParentScope();
                else break;
            }
            else return cur->lookUp2(name);
        }
        return nullptr;
    }
