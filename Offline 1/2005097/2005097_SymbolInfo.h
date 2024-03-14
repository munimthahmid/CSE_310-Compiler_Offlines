#include<iostream>
#include<string>
#include<fstream>
#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

using namespace std;
extern ifstream in;
extern ofstream out;
class SymbolInfo
{
private:
    string name;
    string type;
    SymbolInfo *next;
    int pos_x;
    int pos_y;

public:
    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
    }
    ~SymbolInfo();
    string getName();
    string getType();
    string setName(string name);
    void setNextSymbol(SymbolInfo *s);
    SymbolInfo *getNextSymbol();
    void setType(string type);

    int get_pos_x();
    int get_pos_y();
    void set_pos_x(int val);
    void set_pos_y(int val);
};
#endif // SYMBOLINFO_H
