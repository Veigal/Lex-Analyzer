# Lex-Analyzer
Lexical analyzer for the C language
 
To test with multiple line argument: 

 - generate the C file with ```flex lex_analyzer.lex```
 - copy the code of the resulting file *lex_analyer.yy.c* 
 - paste the code of step 2 into https://www.onlinegdb.com/online_c_compiler
 - add the content of *input.c* as argument to the execution
 - run 

To test with single line argument

 - generate the C file with ```flex lex_analyzer.lex```
 - compile file *lex_analyer.yy.c* with ```gcc lex.yy.c -o lex_analyzer```   
 - run with ```.\lex_analyzer.exe```
 - interactively send arguments to the program and check the output
 - leave with ```CNTRL+C``` scape command
