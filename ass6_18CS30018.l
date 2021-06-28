/*Flex Specifications(Interactive mode) for tinyC language*/

/*C definitions and declarations*/
%{
  #include <stdio.h>
  #include <string.h>
  #include "ass6_18CS30018_translator.h" 
  #include "y.tab.h"
  extern void yyerror(const char* s); 
%} 

%option noyywrap
%option yylineno

/*white spaces*/
WS	[ \t\n]+

/* Regular Expression Definitions for 'Identifiers'*/
IDENTIFIER_NONDIGIT	"_"|[a-zA-Z]
DIGIT			[0-9]
IDENTIFIER		{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*	 

/* Regular Expression Definitions for 'Constants'*/

/*integer constants*/
ZERO			"0"
NONZERO_DIGIT		[1-9]
INTEGER_CONST		{ZERO}|{NONZERO_DIGIT}{DIGIT}*

/*float constants*/
SIGN			[+-]
DIGIT_SEQ		{DIGIT}+
FRACTIONAL_CONST	({DIGIT_SEQ}?"."{DIGIT_SEQ})|({DIGIT_SEQ}".")
EXPONENT_PART		("e"{SIGN}?{DIGIT_SEQ})|("E"{SIGN}?{DIGIT_SEQ})
FLOAT_CONST     	({FRACTIONAL_CONST}{EXPONENT_PART}?)|({DIGIT_SEQ}{EXPONENT_PART})

/*character constant*/
ESCAPE_SEQ		"\\'"|"\\""|"\\?"|"\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
C_CHAR			{ESCAPE_SEQ}|[^'\\\n]
C_CHAR_SEQ		{C_CHAR}+
CHARACTER_CONST	\'{C_CHAR_SEQ}\'

/*Regular Expression Definition for 'String literals'*/
S_CHAR		{ESCAPE_SEQ}|[^"\\\n)]
S_CHAR_SEQ	{S_CHAR}+
STRING_LITERAL	\"{S_CHAR_SEQ}?\"

/* Regular Expression Definition for 'Comments'*/
SINGLE_LINE_COMMENT	"//"[^\n]*
MULTI_LINE_COMMENT	"/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*"*"+"/"
COMMENT		{SINGLE_LINE_COMMENT}|{MULTI_LINE_COMMENT}

%%
		/*Translation rules for tinyC*/

		/*rules for Keywords*/
"break"	{return BREAK;}
"case"		{return CASE;}
"char"		{return CHAR;}
"continue"	{return CONTINUE;}
"default"	{return DEFAULT;}
"do"		{return DO;}
"double"	{return DOUBLE;}
"else"		{return ELSE;}
"extern"	{return EXTERN;}
"float"	{return FLOAT;}
"for"		{return FOR;}
"goto"		{return GOTO;}
"if"		{return IF;}
"int"		{return INT;}
"long"		{return LONG;}
"return"	{return RETURN;}
"short"	{return SHORT;}
"sizeof"	{return SIZEOF;}
"static"	{return STATIC;}
"switch"	{return SWITCH;}
"void"		{return VOID;}
"while"	{return WHILE;}
"const"	{return CONST;}
"restrict"	{return RESTRICT;}
"volatile"	{return VOLATILE;}
"inline"	{return INLINE;}


		/*rules for Constants*/
{INTEGER_CONST}     { yylval.intval = atoi(yytext);
			 return INT_CONST;}
		    
{FLOAT_CONST}	{  yylval.charval = yytext;
		   return FLOAT_CONST; }
		
{CHARACTER_CONST}  { yylval.charval = yytext;
		       return CHAR_CONST;}

		/*rules for String literals*/
{STRING_LITERAL}    { yylval.charval = yytext;
			return STR_LITERAL;}
			
		/*rules for Identifiers*/
{IDENTIFIER}	{  yylval.symp = curr_table->lookup(yytext);
		   return ID; }

		/*rules for Punctuators*/
"["	{return SQ_LBRACE;}		
"]"	{return SQ_RBRACE;}
"("	{return RO_LBRACE;}
")"	{return RO_RBRACE;}
"{"	{return FL_LBRACE;}
"}"	{return FL_RBRACE;}
"."	{return DOT;}
"->"	{return MEM_OP;}
"++"	{return INCREMENT_OP;}
"--"	{return DECREMENT_OP;}
"&"	{return BIT_AND;}
"*"	{return MULT_OP;}
"+"	{return ADD_OP;}
"-"	{return MINUS_OP;}
"~"	{return BIT_COMPL;}
"!"	{return NOT_OP;}
"/"	{return DIV_OP;}
"%"	{return REM;}
"<<"	{return L_SHIFT;}
">>"	{return R_SHIFT;}
"<"	{return LT;}
">"	{return GT;}
"<="	{return LT_EQ;}
">="	{return GT_EQ;}
"=="	{return EQ;}
"!="	{return NEQ;}
"^"	{return BIT_XOR;}
"|"	{return BIT_OR;}
"&&"	{return LOGIC_AND;}
"||"	{return LOGIC_OR;}
"?"	{return QUERY;}
":"	{return COLON;}
";"	{return SEMI_COLON;}
"..."	{return VAR_ARG_LIST;}
"="	{return ASSIGN;}
"*="	{return MULT_ASGN;}
"/="	{return DIV_ASGN;}
"%="	{return REM_ASGN;}
"+="	{return ADD_ASGN;}
"-="	{return MINUS_ASGN;}
"<<="	{return LS_ASGN;}
">>="	{return RS_ASGN;}
"&="	{return BIT_AND_ASGN;}
"^="	{return BIT_XOR_ASGN;}
"|="	{return BIT_OR_ASGN;}
","	{return COMMA;}
"#"	{return HASH;}

             /*rules for comments*/
{WS}|{COMMENT}	{ /*no action needed for white spaces*/ }		
%%

