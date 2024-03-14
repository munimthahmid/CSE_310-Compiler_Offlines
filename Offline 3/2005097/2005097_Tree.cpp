// Tree.cpp
#include "2005097_Tree.h"
#include <string>
extern ofstream ptout;
template <typename T>
node<T> *Tree<T>::insert(T data)
{
    root = new node<T>;
    root->data = data;

    return root;
}

template <typename T>
node<T> *Tree<T>::insert(T data, node<T> *parent)
{
    node<T> *newNode = new node<T>;
    newNode->data = data;

    parent->childNodes.push_back(newNode);
    return newNode;
}

template <typename T>
void Tree<T>::preOrder()
{
    preOrderRecursive(root, 0);
}

template <typename T>
void Tree<T>::preOrderRecursive(node<T> *root, int space)
{
    

    if (root!=nullptr && root->childNodes.getSize() != 0)
    {
         for (int i = 0; i < space; i++)
    {
        ptout<<" ";
    }
        ptout << root->data << " : ";
        node<T>* child;

        for (size_t i = 0; i < root->childNodes.getSize(); ++i)
        {
            child = root->childNodes.data[i];
            if(child!=nullptr)
            {
                if(i==root->childNodes.getSize()-1 || root->childNodes.data[i+1]==nullptr)
                {
                ptout << child->data;
                }
                else
                {
                    ptout << child->data << " ";
                }
                
            }
            
        }
        if(root->isLeaf==false)
        {
            ptout<<" 	";
        }
        else
        {
            

            ptout<<"	";
        }
        
        if(root->isLeaf==false)
        {
            ptout<<"<Line: "<<root->begin<<"-"<<child->end<<">"<<endl;
        }
        else
        {
            ptout<<"<Line: "<<root->begin<<">"<<endl;

        }
        
    for (size_t i = 0; i < root->childNodes.getSize(); ++i)
    {
        node<T> *child = root->childNodes.data[i];
        preOrderRecursive(child, space + 1);
    }
    }


}
template <typename T>
node<T> *Tree<T>::find(T data)
{
    return findRecursive(root, data);
    
}

template <typename T>
node<T> *Tree<T>::findRecursive(node<T> *current, T data)
{
    if (current == nullptr || current->data == data)
    {
        return current;
    }

    for (size_t i = 0; i < current->childNodes.getSize(); ++i)
    {
        node<T> *result = findRecursive(current->childNodes.data[i], data);
        if (result != nullptr)
        {
            return result;
        }
    }

    return nullptr;
}

template <typename T>
node<T> *Tree<T>::makeRoot(T data)
{
    node<T> *newRoot = new node<T>;
    newRoot->data = data;
    if (root != nullptr)
        newRoot->childNodes.push_back(root);
    root = newRoot;
    return root;
}
template <typename T>
void Tree<T>::deleteTree()
{
    deleteTreeRecursive(root);
    root = nullptr; // Set the root to nullptr after deleting the tree
}

template <typename T>
void Tree<T>::deleteTreeRecursive(node<T> *current)
{
    if (current == nullptr)
    {
        return;
    }

    for (size_t i = 0; i < current->childNodes.getSize(); ++i)
    {
        deleteTreeRecursive(current->childNodes.data[i]);
    }

    delete current;
}
template class Tree<string>;
template class node<string>;