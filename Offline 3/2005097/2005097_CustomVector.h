#include<bits/stdc++.h>
#ifndef CUSTOMVECTOR_H
#define CUSTOMVECTOR_H
using namespace std;
template <typename T>
class CustomVector {
public:
    T* data;        
    size_t size; 
    size_t capacity; 

    CustomVector() : size(0), capacity(100) {
        data = new T[capacity];
    }
    ~CustomVector() ;

    void push_back(const T& value);

    void pop_back();
    void clear();
    size_t getSize() const;

    size_t getCapacity() const ;
    bool empty();

    void print() const ;
};
#endif 
