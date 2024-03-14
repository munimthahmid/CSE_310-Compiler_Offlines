#include <bits/stdc++.h>
#include "2005097_CustomVector.h"
#ifndef TREE_H
#define TREE_H
using namespace std;
template <typename T>
class node {
public:
    T data;
    int begin;
    int end;
    bool isLeaf=false;
    CustomVector<node<T>*> childNodes;
    void setBegin(int data)
    {
        this->begin=data;
    }
    void setEnd(int data)
    {
        this->end=data;
    }
    
};
template <typename T>
class Tree {
public:
    node<T>* root;

    node<T>* insert(T data);

    node<T>* insert(T data, node<T>* parent);

    void preOrder();

    void preOrderRecursive(node<T>* root,int space);
    node<T>* find(T data);
    node<T>* findRecursive(node<T>* current, T data);
    node<T>* makeRoot(T data);
    void deleteTree();
    void deleteTreeRecursive(node<T>* current);


};
#endif