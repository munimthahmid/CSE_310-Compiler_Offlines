// helper.cpp
#include "2005097_CustomVector.h"
template <typename T>
class node {
public:
    T data;
    CustomVector<node<T>*> childNodes;
};
// Define member functions for CustomVector class template
template <typename T>
CustomVector<T>::~CustomVector() {
    delete[] data;
}

template <typename T>
void CustomVector<T>::push_back(const T& value) {
    if (size == capacity) {
        capacity *= 2;
        T* newData = new T[capacity];

        for (size_t i = 0; i < size; ++i) {
            newData[i] = data[i];
        }

        delete[] data;
        data = newData;
    }

    data[size++] = value;
}

template <typename T>
void CustomVector<T>::pop_back() {
    if (size > 0) {
        --size;
    }
}

template <typename T>
size_t CustomVector<T>::getSize() const {
    return size;
}

template <typename T>
size_t CustomVector<T>::getCapacity() const {
    return capacity;
}
template <typename T>
void CustomVector<T>::clear() {
    delete[] data;
    size = 0;
    capacity = 100;
    data = new T[capacity];
}
template <typename T>
void CustomVector<T>::print() const {
    for (size_t i = 0; i < size; ++i) {
        cout << data[i] << " ";
    }
    cout << std::endl;
}
template <typename T>
bool  CustomVector<T>::empty()
{
    if(size==0) return true;
    else return false;
}

// Explicit instantiation for int
template class CustomVector<int>;
// CustomVector.cpp

template class CustomVector<std::string>;
template class CustomVector<bool>;
template class CustomVector<node<int>*>;
template class CustomVector<node<string>*>;  


