#!/bin/bash

yacc -d -y -v 2005097.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o  y.tab.c
echo 'Generated the parser object file'
flex 2005097.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ 2005097_SymbolInfo.cpp 2005097_ScopeTable.cpp 2005097_SymbolTable.cpp 2005097_Tree.cpp 2005097_CustomVector.cpp -c
echo 'Generated symbol table and helper object files'
g++ 2005097_SymbolInfo.o 2005097_ScopeTable.o 2005097_SymbolTable.o 2005097_Tree.o 2005097_CustomVector.o y.o l.o -lfl -o executable
echo 'All ready, running'
./executable input.c

rm executable
rm y.*
rm lex.yy.c
rm *.o
