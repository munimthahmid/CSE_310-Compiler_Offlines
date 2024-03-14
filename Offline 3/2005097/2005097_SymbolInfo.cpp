  #include<iostream>
  #include<string>
  using namespace std;
  #include "2005097_SymbolInfo.h"

  SymbolInfo::~SymbolInfo()
    {

    }
    string SymbolInfo::getName()
    {
        return name;
    }
    string SymbolInfo::getType()
    {
        return type;
    }
    void SymbolInfo::setName(string name)
    {
        this->name = name;
    }

    void SymbolInfo::setNextSymbol(SymbolInfo *s)
    {
        this->next = s;
        if(s!=nullptr) s->next = nullptr;
    }
    SymbolInfo* SymbolInfo::getNextSymbol()
    {
        return this->next;
    }
    void SymbolInfo::setType(string type)
    {
        this->type = type;
    }

    int SymbolInfo::get_pos_x()
    {
        
        return pos_x;
    }
    bool SymbolInfo:: getIsFunction()
    {
        return isFunction;
    }
    void SymbolInfo::setIsFunction(bool isF)
    {
        isFunction=isF;
    }
    int SymbolInfo::get_pos_y()
    {
        return pos_y;
    }
    void SymbolInfo::set_pos_x(int val)
    {
        pos_x = val;
    }
    void SymbolInfo::set_pos_y(int val)
    {
        pos_y = val;
    }