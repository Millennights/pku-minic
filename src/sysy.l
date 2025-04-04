//Flex可以根据此文件生成C语言的词法分析器
//在没有找到任何匹配规则的情况下，flex的默认处理规则是直接将该字符输出

%option noyywrap    //不使用yywrap()，当lex读取到文件末尾时，会调用yywrap(), 目的是，当有另外一个输入文件时，yywrap可以调整yyin的值并且返回0来重新开始词法分析。如果是真正的文件末尾，那么就返回1来完成分析。它可以用来解析多个文件。 代码可以写在第三段，这就能够解析多个文件。方法是使用 yyin 文件指针（见上表）指向不同的文件，直到所有的文件都被解析。
%option nounput //添加Flex默认的C函数，比如yy_scan_buffer，yy_scan_bytes，yy_scan_string
%option noinput //不使用默认的input函数
//pku-minic中不使用这些似乎是为了简化此文件

//%top{ ... }，%{ ... %}，内容都是C代码，并将代码照搬到生成的C文件中。
%{
#include <cstdlib>
#include <string>
// 因为 Flex 会用到 Bison 中关于 token 的定义
// 所以需要 include Bison 生成的头文件
#include "sysy.tab.hpp"
using namespace std;
%}

//第一段： 这里定义了某个符号对应的正则表达式

/* 空白符和注释 */
WhiteSpace    [ \t\n\r]*    //“\”用来转义元字符。同样用来覆盖字符在此表中定义的特殊意义，只取字符的本意。
LineComment   "//".*    //只处理了形如 // ... 的行注释
/* 标识符 */
Identifier    [a-zA-Z_][a-zA-Z0-9_]*
/* 整数字面量 */
Decimal       [1-9][0-9]*
Octal         0[0-7]*
Hexadecimal   0[xX][0-9a-fA-F]+

%%  //第二段：这里写 Flex/Bison 的规则。lexer扫描到某个token后做的操作。

//为token设置一个语义动作
//遇到空白符和注释时跳过
{WhiteSpace}    { /* 忽略, 不做任何操作 */ }
{LineComment}   { /* 忽略, 不做任何操作 */ }

//遇到关键字时返回对应的token
"int"           { return INT; }
"return"        { return RETURN; }

//遇到标识符就把标识符存起来（yytext）, 然后返回对应的token
//yylval用来向parser传递lexer读取到的内容
{Identifier}    { yylval.str_val = new string(yytext); return IDENT; }

{Decimal}       { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }
{Octal}         { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }
{Hexadecimal}   { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }

.               { return yytext[0]; }
//INT, RETURN, IDENT, 其实是 Bison 根据我们的定义生成的枚举 (enum)(属性在Parser处理)

%%  //第三段：这里写一些用户自定义的代码。比如你希望在生成的 C/C++ 文件里定义一个函数, 做一些辅助工作。你同时希望在之前的规则描述里调用你定义的函数。那么, 你可以把 C/C++ 的函数定义写在这里, 声明写在文件开头