  #include<iostream>
  #include<string>
  using namespace std;
  #include "2005097_SymbolInfo.h"
  extern ofstream ptout2;


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

void SymbolInfo::preOrder()
{
    preOrderRecursive(this, 0);
}

void SymbolInfo::preOrderRecursive(SymbolInfo*root, int space)
{
    

    // if (root!=nullptr && root->childrens.size()!=0)
    // {
      
    // for (size_t i = 0; i < root->childrens.size(); ++i)
    // {
    //     SymbolInfo *child = root->childrens[i];
    //     preOrderRecursive(child, space + 1);
    // }

    //    for (int i = 0; i < space; i++)
    // {
    //     ptout2<<" ";
    // }
    //     ptout2 << root->type<< " : ";
    //     SymbolInfo* child;

    //     for (size_t i = 0; i < root->childrens.size(); ++i)
    //     {
    //         child = root->childrens[i];
    //         if(child!=nullptr)
    //         {
    //             if(i==root->childrens.size()-1 || root->childrens[i+1]==nullptr)
    //             {
    //             ptout2 << child->type;
    //             }
    //             else
    //             {
    //                 ptout2 << child->type << " ";
    //             }
                
    //         }
            
    //     }
       
    //     if(root->isLeaf==false)
    //     {
    //         ptout2<<" 	";
    //     }
    //     else
    //     {
            

    //         ptout2<<"	";
    //     }
        
    //     if(root->isLeaf==false)
    //     {
    //         ptout2<<"<Line: "<<root->begin<<"-"<<child->end<<">"<<endl;
    //     }
    //     else
    //     {
    //         ptout2<<"<Line: "<<root->begin<<">"<<endl;

    //     }
        




    // }


}
