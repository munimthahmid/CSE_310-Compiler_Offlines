#include<iostream>
#include<string>
#include<sstream>
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
ScopeTable::~ScopeTable()
    {
        // out<<"	ScopeTable# "<<this->id<<" deleted"<<endl;

        for (size_t i = 0; i < tableSize; ++i)
        {
            SymbolInfo *current = symbolInfos[i];
   
            delete current;
        }

    }

    bool ScopeTable::insert(string name, string type)
    {
        SymbolInfo *s = new SymbolInfo(name, type);
        int index = hash(name);
        int cnt = 0;
        SymbolInfo *cur = symbolInfos[index];
        if(lookUp2(name)!=nullptr) 
        {

            return false; //already exist
        }
        if (cur == nullptr)
        {
            symbolInfos[index] = s;
            s->set_pos_x(index + 1);
            s->set_pos_y(cnt + 1);
            // out << "	Inserted  at position <" << s->get_pos_x() << ", " << s->get_pos_y() << "> of ScopeTable# "<<this->getId()<< endl;
        }
        else
        {
            while (cur->getNextSymbol() != nullptr)
            {
                cur = cur->getNextSymbol();
                cnt++;
            }

            s->set_pos_x(index + 1);
            s->set_pos_y(cnt + 2);
            cur->setNextSymbol(s);
            // out << "	Inserted  at position <" << s->get_pos_x() << ", " << s->get_pos_y() << "> of ScopeTable# "<<this->getId()<< endl;

        }

        return true;
    }
    SymbolInfo* ScopeTable::lookUp(string name)
    {
        int index = hash(name);
        SymbolInfo *cur = symbolInfos[index];
      

        while (cur != nullptr && cur->getName() != name)
        {
            cur = cur->getNextSymbol();
        }

        if (cur == nullptr)
        {
            return nullptr;
        }
        else
        {
            // out << "	'" << name << "' found at position <" << cur->get_pos_x() << ", " << cur->get_pos_y() << "> of ScopeTable# " << this->getId() << endl;

            return cur;
        }
    }


    SymbolInfo* ScopeTable::lookUp2(string name)
    {
        int index = hash(name);
        SymbolInfo *cur = symbolInfos[index];
        while (cur != nullptr && cur->getName() != name)
        {
            cur = cur->getNextSymbol();
        }

        if (cur == nullptr)
        {
            return nullptr;
        }
        else
        {

            return cur;
        }
    }


    bool ScopeTable::deleteSymbol(string name)
    {
        if (lookUp2(name) == nullptr)
        {
            return false;
        }
        else
        {
            int index = hash(name);
            SymbolInfo *cur = symbolInfos[index];
            if (cur->getName() == name)
            {
                SymbolInfo *nextSymbol = cur->getNextSymbol();
                                    


                if (nextSymbol != nullptr)
                {

                    symbolInfos[index] = nextSymbol;
                    nextSymbol->set_pos_y(nextSymbol->get_pos_y()-1);

                    delete cur;
                    cur=nullptr;
                }
                else
                {
                    symbolInfos[index] = nullptr;
                    delete cur;
                    cur = nullptr;
                }
            }
            else
            {
                SymbolInfo *prev = cur;
                while (cur->getNextSymbol()->getName() != name)
                {
                    prev = cur;
                    cur = cur->getNextSymbol();
                }
                prev->setNextSymbol(cur->getNextSymbol());
                delete cur;
                cur = nullptr;
            }
            return true;
        }
    }
    string ScopeTable::printScopeTable()
    {
        std::ostringstream logout2;
        logout2 << "	ScopeTable# " << id << "\n";
        for (int i = 0; i < tableSize; i++)
        {
            logout2 <<"	"<< i + 1;
            SymbolInfo *cur = cur = symbolInfos[i];
            while (cur != nullptr)
            {
                logout2 << " --> ";
                logout2 << "(";
                logout2 << cur->getName();
                logout2<< ",";
                logout2 << cur->getType();
                logout2 << ")";
                cur = cur->getNextSymbol();
            }
            logout2 << endl;
        }
        return logout2.str();
    }

    SymbolInfo** ScopeTable::getSymbolInfos()
    {
        return symbolInfos;
    }
    size_t ScopeTable::getTableSize()
    {
        return tableSize;
    }
    ScopeTable* ScopeTable::getParentScope()
    {
        return parentScope;
    }
    void ScopeTable::setSymbolInfos(SymbolInfo **infos)
    {
        this->symbolInfos = infos;
    }
    void ScopeTable::setTableSize(size_t size)
    {
        this->tableSize = size;
    }
    void ScopeTable::setParentScope(ScopeTable *parent)
    {
        this->parentScope = parent;
    }
    void ScopeTable::setId(string s)
    {
        id = s;
    }
    string ScopeTable::getId()
    {
        return id;
    }
    void ScopeTable::incrementExitCount()
    {
        this->exit_count++;
    }

    unsigned long long ScopeTable::hash(const string &s)
    {
        unsigned long long hash_value = 0;

        for (char ch : s)
        {
            hash_value = (ch+ (hash_value << 6) + (hash_value << 16) - hash_value) ;
        }

        return (hash_value) % tableSize;
    }