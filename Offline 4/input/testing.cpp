#include <iostream>
#include <string>
#include <cstdlib> // For atoi function

int extractNumber(const std::string& str) {
    size_t startPos = str.find_first_of("0123456789");
    
    std::string numStr = str.substr(startPos);
    
    int num = atoi(numStr.c_str());
    
    if (str[startPos - 1] == '-') {
        num = -num;
    }
    
    return num;
}

int main() {
    std::string str1 = "[BP-2]";
    std::string str2 = "[BP+4]";

    int num1 = extractNumber(str1);
    int num2 = extractNumber(str2);

    std::cout << "Extracted number from " << str1 << ": " << num1 << std::endl;
    std::cout << "Extracted number from " << str2 << ": " << num2 << std::endl;

    return 0;
}
