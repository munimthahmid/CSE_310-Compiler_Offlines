#include <iostream>
#include <string>
#include <sstream>
#include "2005097_SymbolInfo.h"
#include "2005097_ScopeTable.h"
#include "2005097_SymbolTable.h"

const int MAX_TOKENS = 10;
const int MAX_STACK_SIZE=100;

using namespace std;

int main()
{
    int tableSize;
    in >> tableSize;
    in.ignore();

    SymbolTable *symbolTable = new SymbolTable(tableSize);
    int commandcount = 0;
    string command;
    while (true)
    {
        string inputLine;
        commandcount++;

        getline(in, inputLine);

        string tokens[MAX_TOKENS];
        std::istringstream iss(inputLine);
        int tokenCount = 0;

        while (iss >> tokens[tokenCount] && tokenCount < MAX_TOKENS)
        {
            ++tokenCount;
        }

        if (tokens[0] == "I")
        {
            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount != 3)
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else
            {
                if(symbolTable->currentScopeTable->lookUp2(tokens[1])!=nullptr)
                {
                    out<<"	'"<<tokens[1]<<"' already exists in the current ScopeTable# "<<symbolTable->currentScopeTable->getId()<<endl;
                }
                else
                {
                    symbolTable->insertSymbolInCurrentScope(tokens[1],tokens[2]);
                }

            }

        }

        else if (tokens[0] == "Q")
        {

            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount != 1)
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else
            {
                ScopeTable* cur = symbolTable->currentScopeTable;
                ScopeTable* next = nullptr;

                while (cur != nullptr)
                {
                    next = cur->getParentScope();
                    delete cur;
                    cur = next;  // Update cur to the next node
                }

            }
            break;
        }
        else if (tokens[0] == "L")
        {
            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount != 2) 
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else
            {
                SymbolInfo *s=symbolTable->lookUp(tokens[1]);
                if (s == nullptr)
                {
                    out << "	'" << tokens[1] << "' not found in any of the ScopeTables" << endl;
                }
            }
        }
        else if (tokens[0] == "T")
        {
            out<<"id :"<<symbolTable->currentScopeTable->getId()<<endl;
        }
        else if (tokens[0] == "P")
        {
            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount != 2)
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else if (tokens[1] == "C")
            {
                symbolTable->currentScopeTable->printScopeTable();
            }
            else if (tokens[1]=="A")
            {
                symbolTable->printAll();
            }
            else
            {
                out<<"	Invalid argument for the command P"<<endl;
            }
        }
        else if (tokens[0] == "D")
        {
            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount != 2)
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else
            {
                int x, y;
                SymbolInfo *s=symbolTable->lookUp2(tokens[1]);
                if (s != nullptr)
                {
                    x = s->get_pos_x();
                    y = s->get_pos_y();
                }

                bool done = symbolTable->removeFromCurrentScope(tokens[1]);
                if (done)
                {
                    out << "	Deleted '" << tokens[1] << "' from position <" << x << ", " << y << "> of ScopeTable# " << symbolTable->currentScopeTable->getId() << endl;
                }
                else
                {
                    out << "	Not found in the current ScopeTable# " << symbolTable->currentScopeTable->getId() << endl;
                }
            }
        }
        else if(tokens[0]=="S")
        {
            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount > 2)
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else
            {
                symbolTable->enter();
            }
        }
        else if(tokens[0]=="E")
        {
            out << "Cmd " << commandcount << ": ";
            for (int i = 0; i < tokenCount - 1; i++)
            {
                out << tokens[i] << " ";
            }
            out << tokens[tokenCount - 1] << endl;

            if (tokenCount !=1)
            {
                out << "	Wrong number of arguments for the command " << tokens[0] << endl;
            }
            else
            {
                symbolTable->exit();

            }

        }
    }
}
