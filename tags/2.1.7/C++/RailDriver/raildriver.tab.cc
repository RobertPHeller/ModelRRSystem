#define YY_RaildriverParser_h_included

/*  A Bison++ parser, made from raildriver.y  */

 /* with Bison++ version bison++ Version 1.21-8, adapted from GNU bison by coetmeur@icdc.fr
  */


#line 1 "/usr/lib/bison.cc"
/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */
/* Skeleton output parser for bison,
   Copyright (C) 1984, 1989, 1990 Bob Corbett and Richard Stallman

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 1, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* HEADER SECTION */
#if defined( _MSDOS ) || defined(MSDOS) || defined(__MSDOS__) 
#define __MSDOS_AND_ALIKE
#endif
#if defined(_WINDOWS) && defined(_MSC_VER)
#define __HAVE_NO_ALLOCA
#define __MSDOS_AND_ALIKE
#endif

#ifndef alloca
#if defined( __GNUC__)
#define alloca __builtin_alloca

#elif (!defined (__STDC__) && defined (sparc)) || defined (__sparc__) || defined (__sparc)  || defined (__sgi)
#include <alloca.h>

#elif defined (__MSDOS_AND_ALIKE)
#include <malloc.h>
#ifndef __TURBOC__
/* MS C runtime lib */
#define alloca _alloca
#endif

#elif defined(_AIX)
#include <malloc.h>
#pragma alloca

#elif defined(__hpux)
#ifdef __cplusplus
extern "C" {
void *alloca (unsigned int);
};
#else /* not __cplusplus */
void *alloca ();
#endif /* not __cplusplus */

#endif /* not _AIX  not MSDOS, or __TURBOC__ or _AIX, not sparc.  */
#endif /* alloca not defined.  */
#ifdef c_plusplus
#ifndef __cplusplus
#define __cplusplus
#endif
#endif
#ifdef __cplusplus
#ifndef YY_USE_CLASS
#define YY_USE_CLASS
#endif
#else
#ifndef __STDC__
#define const
#endif
#endif
#include <stdio.h>
#define YYBISON 1  

/* #line 73 "/usr/lib/bison.cc" */
#line 85 "raildriver.tab.cc"
#line 42 "raildriver.y"

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <raildriverthread.h>
#include <raildriver.tab.h>

#define TRUE true
#define FALSE false

#define YY_RaildriverParser_CLASS  RaildriverParser
#define YY_RaildriverParser_INHERIT  : public RD_Threads
#define YY_RaildriverParser_CONSTRUCTOR_PARAM  int sock, struct sockaddr_in *sockaddr,RD_Event *event
#define YY_RaildriverParser_CONSTRUCTOR_INIT  : RD_Threads(sock,sockaddr,this,event)
#define YY_RaildriverParser_CONSTRUCTOR_CODE  currentPos = NULL; \
			/*YY_RaildriverParser_DEBUG_FLAG = 1;*/
#define YY_RaildriverParser_MEMBERS  void ResetPtr(char *buffer) {currentPos = buffer;/*yylloc.text = buffer;*/} \
		private:\
		void yyerror1(char *message,char *s);\
		char *currentPos;\
		char word[4096];
#define YY_RaildriverParser_ERROR_VERBOSE 
#define YY_RaildriverParser_DEBUG  1

#line 75 "raildriver.y"
typedef union {
	int ival;
	char *sval;
	RD_Event::Eventmask_bits eval;
} yy_RaildriverParser_stype;
#define YY_RaildriverParser_STYPE yy_RaildriverParser_stype

#line 73 "/usr/lib/bison.cc"
/* %{ and %header{ and %union, during decl */
#define YY_RaildriverParser_BISON 1
#ifndef YY_RaildriverParser_COMPATIBILITY
#ifndef YY_USE_CLASS
#define  YY_RaildriverParser_COMPATIBILITY 1
#else
#define  YY_RaildriverParser_COMPATIBILITY 0
#endif
#endif

#if YY_RaildriverParser_COMPATIBILITY != 0
/* backward compatibility */
#ifdef YYLTYPE
#ifndef YY_RaildriverParser_LTYPE
#define YY_RaildriverParser_LTYPE YYLTYPE
#endif
#endif
#ifdef YYSTYPE
#ifndef YY_RaildriverParser_STYPE 
#define YY_RaildriverParser_STYPE YYSTYPE
#endif
#endif
#ifdef YYDEBUG
#ifndef YY_RaildriverParser_DEBUG
#define  YY_RaildriverParser_DEBUG YYDEBUG
#endif
#endif
#ifdef YY_RaildriverParser_STYPE
#ifndef yystype
#define yystype YY_RaildriverParser_STYPE
#endif
#endif
/* use goto to be compatible */
#ifndef YY_RaildriverParser_USE_GOTO
#define YY_RaildriverParser_USE_GOTO 1
#endif
#endif

/* use no goto to be clean in C++ */
#ifndef YY_RaildriverParser_USE_GOTO
#define YY_RaildriverParser_USE_GOTO 0
#endif

#ifndef YY_RaildriverParser_PURE

/* #line 117 "/usr/lib/bison.cc" */
#line 167 "raildriver.tab.cc"

#line 117 "/usr/lib/bison.cc"
/*  YY_RaildriverParser_PURE */
#endif

/* section apres lecture def, avant lecture grammaire S2 */

/* #line 121 "/usr/lib/bison.cc" */
#line 176 "raildriver.tab.cc"

#line 121 "/usr/lib/bison.cc"
/* prefix */
#ifndef YY_RaildriverParser_DEBUG

/* #line 123 "/usr/lib/bison.cc" */
#line 183 "raildriver.tab.cc"

#line 123 "/usr/lib/bison.cc"
/* YY_RaildriverParser_DEBUG */
#endif


#ifndef YY_RaildriverParser_LSP_NEEDED

/* #line 128 "/usr/lib/bison.cc" */
#line 193 "raildriver.tab.cc"

#line 128 "/usr/lib/bison.cc"
 /* YY_RaildriverParser_LSP_NEEDED*/
#endif



/* DEFAULT LTYPE*/
#ifdef YY_RaildriverParser_LSP_NEEDED
#ifndef YY_RaildriverParser_LTYPE
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;

#define YY_RaildriverParser_LTYPE yyltype
#endif
#endif
/* DEFAULT STYPE*/
      /* We used to use `unsigned long' as YY_RaildriverParser_STYPE on MSDOS,
	 but it seems better to be consistent.
	 Most programs should declare their own type anyway.  */

#ifndef YY_RaildriverParser_STYPE
#define YY_RaildriverParser_STYPE int
#endif
/* DEFAULT MISCELANEOUS */
#ifndef YY_RaildriverParser_PARSE
#define YY_RaildriverParser_PARSE yyparse
#endif
#ifndef YY_RaildriverParser_LEX
#define YY_RaildriverParser_LEX yylex
#endif
#ifndef YY_RaildriverParser_LVAL
#define YY_RaildriverParser_LVAL yylval
#endif
#ifndef YY_RaildriverParser_LLOC
#define YY_RaildriverParser_LLOC yylloc
#endif
#ifndef YY_RaildriverParser_CHAR
#define YY_RaildriverParser_CHAR yychar
#endif
#ifndef YY_RaildriverParser_NERRS
#define YY_RaildriverParser_NERRS yynerrs
#endif
#ifndef YY_RaildriverParser_DEBUG_FLAG
#define YY_RaildriverParser_DEBUG_FLAG yydebug
#endif
#ifndef YY_RaildriverParser_ERROR
#define YY_RaildriverParser_ERROR yyerror
#endif
#ifndef YY_RaildriverParser_PARSE_PARAM
#ifndef __STDC__
#ifndef __cplusplus
#ifndef YY_USE_CLASS
#define YY_RaildriverParser_PARSE_PARAM
#ifndef YY_RaildriverParser_PARSE_PARAM_DEF
#define YY_RaildriverParser_PARSE_PARAM_DEF
#endif
#endif
#endif
#endif
#ifndef YY_RaildriverParser_PARSE_PARAM
#define YY_RaildriverParser_PARSE_PARAM void
#endif
#endif
#if YY_RaildriverParser_COMPATIBILITY != 0
/* backward compatibility */
#ifdef YY_RaildriverParser_LTYPE
#ifndef YYLTYPE
#define YYLTYPE YY_RaildriverParser_LTYPE
#else
/* WARNING obsolete !!! user defined YYLTYPE not reported into generated header */
#endif
#endif
#ifndef YYSTYPE
#define YYSTYPE YY_RaildriverParser_STYPE
#else
/* WARNING obsolete !!! user defined YYSTYPE not reported into generated header */
#endif
#ifdef YY_RaildriverParser_PURE
#ifndef YYPURE
#define YYPURE YY_RaildriverParser_PURE
#endif
#endif
#ifdef YY_RaildriverParser_DEBUG
#ifndef YYDEBUG
#define YYDEBUG YY_RaildriverParser_DEBUG 
#endif
#endif
#ifndef YY_RaildriverParser_ERROR_VERBOSE
#ifdef YYERROR_VERBOSE
#define YY_RaildriverParser_ERROR_VERBOSE YYERROR_VERBOSE
#endif
#endif
#ifndef YY_RaildriverParser_LSP_NEEDED
#ifdef YYLSP_NEEDED
#define YY_RaildriverParser_LSP_NEEDED YYLSP_NEEDED
#endif
#endif
#endif
#ifndef YY_USE_CLASS
/* TOKEN C */

/* #line 236 "/usr/lib/bison.cc" */
#line 306 "raildriver.tab.cc"
#define	LEDDIGITS	258
#define	BADSYMBOL	259
#define	EXIT	260
#define	CLEAR	261
#define	MASK	262
#define	LED	263
#define	REVERSER	264
#define	THROTTLE	265
#define	AUTOBRAKE	266
#define	INDEPENDBRK	267
#define	BAILOFF	268
#define	HEADLIGHT	269
#define	WIPER	270
#define	DIGITAL1	271
#define	DIGITAL2	272
#define	DIGITAL3	273
#define	DIGITAL4	274
#define	DIGITAL5	275
#define	DIGITAL6	276
#define	SPEAKER	277
#define	ON	278
#define	OFF	279
#define	POLLVALUES	280


#line 236 "/usr/lib/bison.cc"
 /* #defines tokens */
#else
/* CLASS */
#ifndef YY_RaildriverParser_CLASS
#define YY_RaildriverParser_CLASS RaildriverParser
#endif
#ifndef YY_RaildriverParser_INHERIT
#define YY_RaildriverParser_INHERIT
#endif
#ifndef YY_RaildriverParser_MEMBERS
#define YY_RaildriverParser_MEMBERS 
#endif
#ifndef YY_RaildriverParser_LEX_BODY
#define YY_RaildriverParser_LEX_BODY  
#endif
#ifndef YY_RaildriverParser_ERROR_BODY
#define YY_RaildriverParser_ERROR_BODY  
#endif
#ifndef YY_RaildriverParser_CONSTRUCTOR_PARAM
#define YY_RaildriverParser_CONSTRUCTOR_PARAM
#endif
#ifndef YY_RaildriverParser_CONSTRUCTOR_CODE
#define YY_RaildriverParser_CONSTRUCTOR_CODE
#endif
#ifndef YY_RaildriverParser_CONSTRUCTOR_INIT
#define YY_RaildriverParser_CONSTRUCTOR_INIT
#endif
/* choose between enum and const */
#ifndef YY_RaildriverParser_USE_CONST_TOKEN
#define YY_RaildriverParser_USE_CONST_TOKEN 0
/* yes enum is more compatible with flex,  */
/* so by default we use it */ 
#endif
#if YY_RaildriverParser_USE_CONST_TOKEN != 0
#ifndef YY_RaildriverParser_ENUM_TOKEN
#define YY_RaildriverParser_ENUM_TOKEN yy_RaildriverParser_enum_token
#endif
#endif

class YY_RaildriverParser_CLASS YY_RaildriverParser_INHERIT
{
public: 
#if YY_RaildriverParser_USE_CONST_TOKEN != 0
/* static const int token ... */

/* #line 280 "/usr/lib/bison.cc" */
#line 379 "raildriver.tab.cc"
static const int LEDDIGITS;
static const int BADSYMBOL;
static const int EXIT;
static const int CLEAR;
static const int MASK;
static const int LED;
static const int REVERSER;
static const int THROTTLE;
static const int AUTOBRAKE;
static const int INDEPENDBRK;
static const int BAILOFF;
static const int HEADLIGHT;
static const int WIPER;
static const int DIGITAL1;
static const int DIGITAL2;
static const int DIGITAL3;
static const int DIGITAL4;
static const int DIGITAL5;
static const int DIGITAL6;
static const int SPEAKER;
static const int ON;
static const int OFF;
static const int POLLVALUES;


#line 280 "/usr/lib/bison.cc"
 /* decl const */
#else
enum YY_RaildriverParser_ENUM_TOKEN { YY_RaildriverParser_NULL_TOKEN=0

/* #line 283 "/usr/lib/bison.cc" */
#line 411 "raildriver.tab.cc"
	,LEDDIGITS=258
	,BADSYMBOL=259
	,EXIT=260
	,CLEAR=261
	,MASK=262
	,LED=263
	,REVERSER=264
	,THROTTLE=265
	,AUTOBRAKE=266
	,INDEPENDBRK=267
	,BAILOFF=268
	,HEADLIGHT=269
	,WIPER=270
	,DIGITAL1=271
	,DIGITAL2=272
	,DIGITAL3=273
	,DIGITAL4=274
	,DIGITAL5=275
	,DIGITAL6=276
	,SPEAKER=277
	,ON=278
	,OFF=279
	,POLLVALUES=280


#line 283 "/usr/lib/bison.cc"
 /* enum token */
     }; /* end of enum declaration */
#endif
public:
 int YY_RaildriverParser_PARSE (YY_RaildriverParser_PARSE_PARAM);
 virtual void YY_RaildriverParser_ERROR(char *msg) YY_RaildriverParser_ERROR_BODY;
#ifdef YY_RaildriverParser_PURE
#ifdef YY_RaildriverParser_LSP_NEEDED
 virtual int  YY_RaildriverParser_LEX (YY_RaildriverParser_STYPE *YY_RaildriverParser_LVAL,YY_RaildriverParser_LTYPE *YY_RaildriverParser_LLOC) YY_RaildriverParser_LEX_BODY;
#else
 virtual int  YY_RaildriverParser_LEX (YY_RaildriverParser_STYPE *YY_RaildriverParser_LVAL) YY_RaildriverParser_LEX_BODY;
#endif
#else
 virtual int YY_RaildriverParser_LEX() YY_RaildriverParser_LEX_BODY;
 YY_RaildriverParser_STYPE YY_RaildriverParser_LVAL;
#ifdef YY_RaildriverParser_LSP_NEEDED
 YY_RaildriverParser_LTYPE YY_RaildriverParser_LLOC;
#endif
 int   YY_RaildriverParser_NERRS;
 int    YY_RaildriverParser_CHAR;
#endif
#if YY_RaildriverParser_DEBUG != 0
 int YY_RaildriverParser_DEBUG_FLAG;   /*  nonzero means print parse trace     */
#endif
public:
 YY_RaildriverParser_CLASS(YY_RaildriverParser_CONSTRUCTOR_PARAM);
public:
 YY_RaildriverParser_MEMBERS 
};
/* other declare folow */
#if YY_RaildriverParser_USE_CONST_TOKEN != 0

/* #line 314 "/usr/lib/bison.cc" */
#line 471 "raildriver.tab.cc"
const int YY_RaildriverParser_CLASS::LEDDIGITS=258;
const int YY_RaildriverParser_CLASS::BADSYMBOL=259;
const int YY_RaildriverParser_CLASS::EXIT=260;
const int YY_RaildriverParser_CLASS::CLEAR=261;
const int YY_RaildriverParser_CLASS::MASK=262;
const int YY_RaildriverParser_CLASS::LED=263;
const int YY_RaildriverParser_CLASS::REVERSER=264;
const int YY_RaildriverParser_CLASS::THROTTLE=265;
const int YY_RaildriverParser_CLASS::AUTOBRAKE=266;
const int YY_RaildriverParser_CLASS::INDEPENDBRK=267;
const int YY_RaildriverParser_CLASS::BAILOFF=268;
const int YY_RaildriverParser_CLASS::HEADLIGHT=269;
const int YY_RaildriverParser_CLASS::WIPER=270;
const int YY_RaildriverParser_CLASS::DIGITAL1=271;
const int YY_RaildriverParser_CLASS::DIGITAL2=272;
const int YY_RaildriverParser_CLASS::DIGITAL3=273;
const int YY_RaildriverParser_CLASS::DIGITAL4=274;
const int YY_RaildriverParser_CLASS::DIGITAL5=275;
const int YY_RaildriverParser_CLASS::DIGITAL6=276;
const int YY_RaildriverParser_CLASS::SPEAKER=277;
const int YY_RaildriverParser_CLASS::ON=278;
const int YY_RaildriverParser_CLASS::OFF=279;
const int YY_RaildriverParser_CLASS::POLLVALUES=280;


#line 314 "/usr/lib/bison.cc"
 /* const YY_RaildriverParser_CLASS::token */
#endif
/*apres const  */
YY_RaildriverParser_CLASS::YY_RaildriverParser_CLASS(YY_RaildriverParser_CONSTRUCTOR_PARAM) YY_RaildriverParser_CONSTRUCTOR_INIT
{
#if YY_RaildriverParser_DEBUG != 0
YY_RaildriverParser_DEBUG_FLAG=0;
#endif
YY_RaildriverParser_CONSTRUCTOR_CODE;
};
#endif

/* #line 325 "/usr/lib/bison.cc" */
#line 511 "raildriver.tab.cc"


#define	YYFINAL		35
#define	YYFLAG		-32768
#define	YYNTBASE	27

#define YYTRANSLATE(x) ((unsigned)(x) <= 280 ? yytranslate[x] : 30)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,    26,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
    16,    17,    18,    19,    20,    21,    22,    23,    24,    25
};

#if YY_RaildriverParser_DEBUG != 0
static const short yyprhs[] = {     0,
     0,     3,     6,    10,    14,    18,    22,    26,    27,    30,
    32,    34,    36,    38,    40,    42,    44,    46,    48,    50,
    52,    54
};

static const short yyrhs[] = {     5,
    26,     0,     6,    26,     0,     7,    28,    26,     0,    25,
    28,    26,     0,     8,     3,    26,     0,    22,    23,    26,
     0,    22,    24,    26,     0,     0,    28,    29,     0,     9,
     0,    10,     0,    11,     0,    12,     0,    13,     0,    14,
     0,    15,     0,    16,     0,    17,     0,    18,     0,    19,
     0,    20,     0,    21,     0
};

#endif

#if YY_RaildriverParser_DEBUG != 0
static const short yyrline[] = { 0,
    92,    93,    94,    95,    96,    97,    98,   101,   102,   105,
   106,   107,   108,   109,   110,   111,   112,   113,   114,   115,
   116,   117
};

static const char * const yytname[] = {   "$","error","$illegal.","LEDDIGITS",
"BADSYMBOL","EXIT","CLEAR","MASK","LED","REVERSER","THROTTLE","AUTOBRAKE","INDEPENDBRK",
"BAILOFF","HEADLIGHT","WIPER","DIGITAL1","DIGITAL2","DIGITAL3","DIGITAL4","DIGITAL5",
"DIGITAL6","SPEAKER","ON","OFF","POLLVALUES","'\\n'","command","maskbits","maskbit",
""
};
#endif

static const short yyr1[] = {     0,
    27,    27,    27,    27,    27,    27,    27,    28,    28,    29,
    29,    29,    29,    29,    29,    29,    29,    29,    29,    29,
    29,    29
};

static const short yyr2[] = {     0,
     2,     2,     3,     3,     3,     3,     3,     0,     2,     1,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1
};

static const short yydefact[] = {     0,
     0,     0,     8,     0,     0,     8,     1,     2,     0,     0,
     0,     0,     0,    10,    11,    12,    13,    14,    15,    16,
    17,    18,    19,    20,    21,    22,     3,     9,     5,     6,
     7,     4,     0,     0,     0
};

static const short yydefgoto[] = {    33,
     9,    28
};

static const short yypact[] = {    -5,
   -20,   -18,-32768,     4,   -19,-32768,-32768,-32768,    12,   -17,
   -16,   -15,    30,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,    13,    14,-32768
};

static const short yypgoto[] = {-32768,
     6,-32768
};


#define	YYLAST		56


static const short yytable[] = {     1,
     2,     3,     4,    11,    12,     7,    10,     8,    29,    30,
    31,    13,    34,    35,     0,     0,     5,     0,     0,     6,
    14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
    24,    25,    26,     0,     0,     0,     0,    27,    14,    15,
    16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
    26,     0,     0,     0,     0,    32
};

static const short yycheck[] = {     5,
     6,     7,     8,    23,    24,    26,     3,    26,    26,    26,
    26,     6,     0,     0,    -1,    -1,    22,    -1,    -1,    25,
     9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
    19,    20,    21,    -1,    -1,    -1,    -1,    26,     9,    10,
    11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
    21,    -1,    -1,    -1,    -1,    26
};

#line 325 "/usr/lib/bison.cc"
 /* fattrs + tables */

/* parser code folow  */


/* This is the parser code that is written into each bison parser
  when the %semantic_parser declaration is not specified in the grammar.
  It was written by Richard Stallman by simplifying the hairy parser
  used when %semantic_parser is specified.  */

/* Note: dollar marks section change
   the next  is replaced by the list of actions, each action
   as one case of the switch.  */ 

#if YY_RaildriverParser_USE_GOTO != 0
/* 
 SUPRESSION OF GOTO : on some C++ compiler (sun c++)
  the goto is strictly forbidden if any constructor/destructor
  is used in the whole function (very stupid isn't it ?)
 so goto are to be replaced with a 'while/switch/case construct'
 here are the macro to keep some apparent compatibility
*/
#define YYGOTO(lb) {yy_gotostate=lb;continue;}
#define YYBEGINGOTO  enum yy_labels yy_gotostate=yygotostart; \
                     for(;;) switch(yy_gotostate) { case yygotostart: {
#define YYLABEL(lb) } case lb: {
#define YYENDGOTO } } 
#define YYBEGINDECLARELABEL enum yy_labels {yygotostart
#define YYDECLARELABEL(lb) ,lb
#define YYENDDECLARELABEL  };
#else
/* macro to keep goto */
#define YYGOTO(lb) goto lb
#define YYBEGINGOTO 
#define YYLABEL(lb) lb:
#define YYENDGOTO
#define YYBEGINDECLARELABEL 
#define YYDECLARELABEL(lb)
#define YYENDDECLARELABEL 
#endif
/* LABEL DECLARATION */
YYBEGINDECLARELABEL
  YYDECLARELABEL(yynewstate)
  YYDECLARELABEL(yybackup)
/* YYDECLARELABEL(yyresume) */
  YYDECLARELABEL(yydefault)
  YYDECLARELABEL(yyreduce)
  YYDECLARELABEL(yyerrlab)   /* here on detecting error */
  YYDECLARELABEL(yyerrlab1)   /* here on error raised explicitly by an action */
  YYDECLARELABEL(yyerrdefault)  /* current state does not do anything special for the error token. */
  YYDECLARELABEL(yyerrpop)   /* pop the current state because it cannot handle the error token */
  YYDECLARELABEL(yyerrhandle)  
YYENDDECLARELABEL
/* ALLOCA SIMULATION */
/* __HAVE_NO_ALLOCA */
#ifdef __HAVE_NO_ALLOCA
int __alloca_free_ptr(char *ptr,char *ref)
{if(ptr!=ref) free(ptr);
 return 0;}

#define __ALLOCA_alloca(size) malloc(size)
#define __ALLOCA_free(ptr,ref) __alloca_free_ptr((char *)ptr,(char *)ref)

#ifdef YY_RaildriverParser_LSP_NEEDED
#define __ALLOCA_return(num) \
            return( __ALLOCA_free(yyss,yyssa)+\
		    __ALLOCA_free(yyvs,yyvsa)+\
		    __ALLOCA_free(yyls,yylsa)+\
		   (num))
#else
#define __ALLOCA_return(num) \
            return( __ALLOCA_free(yyss,yyssa)+\
		    __ALLOCA_free(yyvs,yyvsa)+\
		   (num))
#endif
#else
#define __ALLOCA_return(num) return(num)
#define __ALLOCA_alloca(size) alloca(size)
#define __ALLOCA_free(ptr,ref) 
#endif

/* ENDALLOCA SIMULATION */

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (YY_RaildriverParser_CHAR = YYEMPTY)
#define YYEMPTY         -2
#define YYEOF           0
#define YYACCEPT        __ALLOCA_return(0)
#define YYABORT         __ALLOCA_return(1)
#define YYERROR         YYGOTO(yyerrlab1)
/* Like YYERROR except do call yyerror.
   This remains here temporarily to ease the
   transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */
#define YYFAIL          YYGOTO(yyerrlab)
#define YYRECOVERING()  (!!yyerrstatus)
#define YYBACKUP(token, value) \
do                                                              \
  if (YY_RaildriverParser_CHAR == YYEMPTY && yylen == 1)                               \
    { YY_RaildriverParser_CHAR = (token), YY_RaildriverParser_LVAL = (value);                 \
      yychar1 = YYTRANSLATE (YY_RaildriverParser_CHAR);                                \
      YYPOPSTACK;                                               \
      YYGOTO(yybackup);                                            \
    }                                                           \
  else                                                          \
    { YY_RaildriverParser_ERROR ("syntax error: cannot back up"); YYERROR; }   \
while (0)

#define YYTERROR        1
#define YYERRCODE       256

#ifndef YY_RaildriverParser_PURE
/* UNPURE */
#define YYLEX           YY_RaildriverParser_LEX()
#ifndef YY_USE_CLASS
/* If nonreentrant, and not class , generate the variables here */
int     YY_RaildriverParser_CHAR;                      /*  the lookahead symbol        */
YY_RaildriverParser_STYPE      YY_RaildriverParser_LVAL;              /*  the semantic value of the */
				/*  lookahead symbol    */
int YY_RaildriverParser_NERRS;                 /*  number of parse errors so far */
#ifdef YY_RaildriverParser_LSP_NEEDED
YY_RaildriverParser_LTYPE YY_RaildriverParser_LLOC;   /*  location data for the lookahead     */
			/*  symbol                              */
#endif
#endif


#else
/* PURE */
#ifdef YY_RaildriverParser_LSP_NEEDED
#define YYLEX           YY_RaildriverParser_LEX(&YY_RaildriverParser_LVAL, &YY_RaildriverParser_LLOC)
#else
#define YYLEX           YY_RaildriverParser_LEX(&YY_RaildriverParser_LVAL)
#endif
#endif
#ifndef YY_USE_CLASS
#if YY_RaildriverParser_DEBUG != 0
int YY_RaildriverParser_DEBUG_FLAG;                    /*  nonzero means print parse trace     */
/* Since this is uninitialized, it does not stop multiple parsers
   from coexisting.  */
#endif
#endif



/*  YYINITDEPTH indicates the initial size of the parser's stacks       */

#ifndef YYINITDEPTH
#define YYINITDEPTH 200
#endif

/*  YYMAXDEPTH is the maximum size the stacks can grow to
    (effective only if the built-in stack extension method is used).  */

#if YYMAXDEPTH == 0
#undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 10000
#endif


#if __GNUC__ > 1                /* GNU C and GNU C++ define this.  */
#define __yy_bcopy(FROM,TO,COUNT)       __builtin_memcpy(TO,FROM,COUNT)
#else                           /* not GNU C or C++ */

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */

#ifdef __cplusplus
static void __yy_bcopy (char *from, char *to, int count)
#else
#ifdef __STDC__
static void __yy_bcopy (char *from, char *to, int count)
#else
static void __yy_bcopy (from, to, count)
     char *from;
     char *to;
     int count;
#endif
#endif
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}
#endif

int
#ifdef YY_USE_CLASS
 YY_RaildriverParser_CLASS::
#endif
     YY_RaildriverParser_PARSE(YY_RaildriverParser_PARSE_PARAM)
#ifndef __STDC__
#ifndef __cplusplus
#ifndef YY_USE_CLASS
/* parameter definition without protypes */
YY_RaildriverParser_PARSE_PARAM_DEF
#endif
#endif
#endif
{
  register int yystate;
  register int yyn;
  register short *yyssp;
  register YY_RaildriverParser_STYPE *yyvsp;
  int yyerrstatus;      /*  number of tokens to shift before error messages enabled */
  int yychar1=0;          /*  lookahead token as an internal (translated) token number */

  short yyssa[YYINITDEPTH];     /*  the state stack                     */
  YY_RaildriverParser_STYPE yyvsa[YYINITDEPTH];        /*  the semantic value stack            */

  short *yyss = yyssa;          /*  refer to the stacks thru separate pointers */
  YY_RaildriverParser_STYPE *yyvs = yyvsa;     /*  to allow yyoverflow to reallocate them elsewhere */

#ifdef YY_RaildriverParser_LSP_NEEDED
  YY_RaildriverParser_LTYPE yylsa[YYINITDEPTH];        /*  the location stack                  */
  YY_RaildriverParser_LTYPE *yyls = yylsa;
  YY_RaildriverParser_LTYPE *yylsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
#define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  int yystacksize = YYINITDEPTH;

#ifdef YY_RaildriverParser_PURE
  int YY_RaildriverParser_CHAR;
  YY_RaildriverParser_STYPE YY_RaildriverParser_LVAL;
  int YY_RaildriverParser_NERRS;
#ifdef YY_RaildriverParser_LSP_NEEDED
  YY_RaildriverParser_LTYPE YY_RaildriverParser_LLOC;
#endif
#endif

  YY_RaildriverParser_STYPE yyval;             /*  the variable used to return         */
				/*  semantic values from the action     */
				/*  routines                            */

  int yylen;
/* start loop, in which YYGOTO may be used. */
YYBEGINGOTO

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    fprintf(stderr, "Starting parse\n");
#endif
  yystate = 0;
  yyerrstatus = 0;
  YY_RaildriverParser_NERRS = 0;
  YY_RaildriverParser_CHAR = YYEMPTY;          /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;
#ifdef YY_RaildriverParser_LSP_NEEDED
  yylsp = yyls;
#endif

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
YYLABEL(yynewstate)

  *++yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Give user a chance to reallocate the stack */
      /* Use copies of these so that the &'s don't force the real ones into memory. */
      YY_RaildriverParser_STYPE *yyvs1 = yyvs;
      short *yyss1 = yyss;
#ifdef YY_RaildriverParser_LSP_NEEDED
      YY_RaildriverParser_LTYPE *yyls1 = yyls;
#endif

      /* Get the current used size of the three stacks, in elements.  */
      int size = yyssp - yyss + 1;

#ifdef yyoverflow
      /* Each stack pointer address is followed by the size of
	 the data in use in that stack, in bytes.  */
#ifdef YY_RaildriverParser_LSP_NEEDED
      /* This used to be a conditional around just the two extra args,
	 but that might be undefined if yyoverflow is a macro.  */
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yyls1, size * sizeof (*yylsp),
		 &yystacksize);
#else
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yystacksize);
#endif

      yyss = yyss1; yyvs = yyvs1;
#ifdef YY_RaildriverParser_LSP_NEEDED
      yyls = yyls1;
#endif
#else /* no yyoverflow */
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	{
	  YY_RaildriverParser_ERROR("parser stack overflow");
	  __ALLOCA_return(2);
	}
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;
      yyss = (short *) __ALLOCA_alloca (yystacksize * sizeof (*yyssp));
      __yy_bcopy ((char *)yyss1, (char *)yyss, size * sizeof (*yyssp));
      __ALLOCA_free(yyss1,yyssa);
      yyvs = (YY_RaildriverParser_STYPE *) __ALLOCA_alloca (yystacksize * sizeof (*yyvsp));
      __yy_bcopy ((char *)yyvs1, (char *)yyvs, size * sizeof (*yyvsp));
      __ALLOCA_free(yyvs1,yyvsa);
#ifdef YY_RaildriverParser_LSP_NEEDED
      yyls = (YY_RaildriverParser_LTYPE *) __ALLOCA_alloca (yystacksize * sizeof (*yylsp));
      __yy_bcopy ((char *)yyls1, (char *)yyls, size * sizeof (*yylsp));
      __ALLOCA_free(yyls1,yylsa);
#endif
#endif /* no yyoverflow */

      yyssp = yyss + size - 1;
      yyvsp = yyvs + size - 1;
#ifdef YY_RaildriverParser_LSP_NEEDED
      yylsp = yyls + size - 1;
#endif

#if YY_RaildriverParser_DEBUG != 0
      if (YY_RaildriverParser_DEBUG_FLAG)
	fprintf(stderr, "Stack size increased to %d\n", yystacksize);
#endif

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    fprintf(stderr, "Entering state %d\n", yystate);
#endif

  YYGOTO(yybackup);
YYLABEL(yybackup)

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* YYLABEL(yyresume) */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    YYGOTO(yydefault);

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (YY_RaildriverParser_CHAR == YYEMPTY)
    {
#if YY_RaildriverParser_DEBUG != 0
      if (YY_RaildriverParser_DEBUG_FLAG)
	fprintf(stderr, "Reading a token: ");
#endif
      YY_RaildriverParser_CHAR = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (YY_RaildriverParser_CHAR <= 0)           /* This means end of input. */
    {
      yychar1 = 0;
      YY_RaildriverParser_CHAR = YYEOF;                /* Don't call YYLEX any more */

#if YY_RaildriverParser_DEBUG != 0
      if (YY_RaildriverParser_DEBUG_FLAG)
	fprintf(stderr, "Now at end of input.\n");
#endif
    }
  else
    {
      yychar1 = YYTRANSLATE(YY_RaildriverParser_CHAR);

#if YY_RaildriverParser_DEBUG != 0
      if (YY_RaildriverParser_DEBUG_FLAG)
	{
	  fprintf (stderr, "Next token is %d (%s", YY_RaildriverParser_CHAR, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise meaning
	     of a token, for further debugging info.  */
#ifdef YYPRINT
	  YYPRINT (stderr, YY_RaildriverParser_CHAR, YY_RaildriverParser_LVAL);
#endif
	  fprintf (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    YYGOTO(yydefault);

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	YYGOTO(yyerrlab);
      yyn = -yyn;
      YYGOTO(yyreduce);
    }
  else if (yyn == 0)
    YYGOTO(yyerrlab);

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    fprintf(stderr, "Shifting token %d (%s), ", YY_RaildriverParser_CHAR, yytname[yychar1]);
#endif

  /* Discard the token being shifted unless it is eof.  */
  if (YY_RaildriverParser_CHAR != YYEOF)
    YY_RaildriverParser_CHAR = YYEMPTY;

  *++yyvsp = YY_RaildriverParser_LVAL;
#ifdef YY_RaildriverParser_LSP_NEEDED
  *++yylsp = YY_RaildriverParser_LLOC;
#endif

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  YYGOTO(yynewstate);

/* Do the default action for the current state.  */
YYLABEL(yydefault)

  yyn = yydefact[yystate];
  if (yyn == 0)
    YYGOTO(yyerrlab);

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
YYLABEL(yyreduce)
  yylen = yyr2[yyn];
  if (yylen > 0)
    yyval = yyvsp[1-yylen]; /* implement default value of the action */

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    {
      int i;

      fprintf (stderr, "Reducing via rule %d (line %d), ",
	       yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (i = yyprhs[yyn]; yyrhs[i] > 0; i++)
	fprintf (stderr, "%s ", yytname[yyrhs[i]]);
      fprintf (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif


/* #line 811 "/usr/lib/bison.cc" */
#line 1129 "raildriver.tab.cc"

  switch (yyn) {

case 1:
#line 92 "raildriver.y"
{DoExit();;
    break;}
case 2:
#line 93 "raildriver.y"
{ClearMask();;
    break;}
case 3:
#line 94 "raildriver.y"
{AddMask(yyvsp[-1].eval);;
    break;}
case 4:
#line 95 "raildriver.y"
{PollValues(yyvsp[-1].eval);;
    break;}
case 5:
#line 96 "raildriver.y"
{LedDisplay(yyvsp[-1].sval);;
    break;}
case 6:
#line 97 "raildriver.y"
{SpeakerOn();;
    break;}
case 7:
#line 98 "raildriver.y"
{SpeakerOff();;
    break;}
case 8:
#line 101 "raildriver.y"
{yyval.eval = RD_Event::NONE_M;;
    break;}
case 9:
#line 102 "raildriver.y"
{yyval.eval = (RD_Event::Eventmask_bits) (yyvsp[-1].eval | yyvsp[0].eval);;
    break;}
case 10:
#line 105 "raildriver.y"
{yyval.eval = RD_Event::REVERSER_M;;
    break;}
case 11:
#line 106 "raildriver.y"
{yyval.eval = RD_Event::THROTTLE_M;;
    break;}
case 12:
#line 107 "raildriver.y"
{yyval.eval = RD_Event::AUTOBRAKE_M;;
    break;}
case 13:
#line 108 "raildriver.y"
{yyval.eval = RD_Event::INDEPENDBRK_M;;
    break;}
case 14:
#line 109 "raildriver.y"
{yyval.eval = RD_Event::BAILOFF_M;;
    break;}
case 15:
#line 110 "raildriver.y"
{yyval.eval = RD_Event::HEADLIGHT_M;;
    break;}
case 16:
#line 111 "raildriver.y"
{yyval.eval = RD_Event::WIPER_M;;
    break;}
case 17:
#line 112 "raildriver.y"
{yyval.eval = RD_Event::DIGITAL1_M;;
    break;}
case 18:
#line 113 "raildriver.y"
{yyval.eval = RD_Event::DIGITAL2_M;;
    break;}
case 19:
#line 114 "raildriver.y"
{yyval.eval = RD_Event::DIGITAL3_M;;
    break;}
case 20:
#line 115 "raildriver.y"
{yyval.eval = RD_Event::DIGITAL4_M;;
    break;}
case 21:
#line 116 "raildriver.y"
{yyval.eval = RD_Event::DIGITAL5_M;;
    break;}
case 22:
#line 117 "raildriver.y"
{yyval.eval = RD_Event::DIGITAL6_M;;
    break;}
}

#line 811 "/usr/lib/bison.cc"
   /* the action file gets copied in in place of this dollarsign  */
  yyvsp -= yylen;
  yyssp -= yylen;
#ifdef YY_RaildriverParser_LSP_NEEDED
  yylsp -= yylen;
#endif

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;

#ifdef YY_RaildriverParser_LSP_NEEDED
  yylsp++;
  if (yylen == 0)
    {
      yylsp->first_line = YY_RaildriverParser_LLOC.first_line;
      yylsp->first_column = YY_RaildriverParser_LLOC.first_column;
      yylsp->last_line = (yylsp-1)->last_line;
      yylsp->last_column = (yylsp-1)->last_column;
      yylsp->text = 0;
    }
  else
    {
      yylsp->last_line = (yylsp+yylen-1)->last_line;
      yylsp->last_column = (yylsp+yylen-1)->last_column;
    }
#endif

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  YYGOTO(yynewstate);

YYLABEL(yyerrlab)   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
      ++YY_RaildriverParser_NERRS;

#ifdef YY_RaildriverParser_ERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  int size = 0;
	  char *msg;
	  int x, count;

	  count = 0;
	  /* Start X at -yyn if nec to avoid negative indexes in yycheck.  */
	  for (x = (yyn < 0 ? -yyn : 0);
	       x < (sizeof(yytname) / sizeof(char *)); x++)
	    if (yycheck[x + yyn] == x)
	      size += strlen(yytname[x]) + 15, count++;
	  msg = (char *) malloc(size + 15);
	  if (msg != 0)
	    {
	      strcpy(msg, "parse error");

	      if (count < 5)
		{
		  count = 0;
		  for (x = (yyn < 0 ? -yyn : 0);
		       x < (sizeof(yytname) / sizeof(char *)); x++)
		    if (yycheck[x + yyn] == x)
		      {
			strcat(msg, count == 0 ? ", expecting `" : " or `");
			strcat(msg, yytname[x]);
			strcat(msg, "'");
			count++;
		      }
		}
	      YY_RaildriverParser_ERROR(msg);
	      free(msg);
	    }
	  else
	    YY_RaildriverParser_ERROR ("parse error; also virtual memory exceeded");
	}
      else
#endif /* YY_RaildriverParser_ERROR_VERBOSE */
	YY_RaildriverParser_ERROR("parse error");
    }

  YYGOTO(yyerrlab1);
YYLABEL(yyerrlab1)   /* here on error raised explicitly by an action */

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (YY_RaildriverParser_CHAR == YYEOF)
	YYABORT;

#if YY_RaildriverParser_DEBUG != 0
      if (YY_RaildriverParser_DEBUG_FLAG)
	fprintf(stderr, "Discarding token %d (%s).\n", YY_RaildriverParser_CHAR, yytname[yychar1]);
#endif

      YY_RaildriverParser_CHAR = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;              /* Each real token shifted decrements this */

  YYGOTO(yyerrhandle);

YYLABEL(yyerrdefault)  /* current state does not do anything special for the error token. */

#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */
  yyn = yydefact[yystate];  /* If its default is to accept any token, ok.  Otherwise pop it.*/
  if (yyn) YYGOTO(yydefault);
#endif

YYLABEL(yyerrpop)   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#ifdef YY_RaildriverParser_LSP_NEEDED
  yylsp--;
#endif

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "Error: state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

YYLABEL(yyerrhandle)

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    YYGOTO(yyerrdefault);

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    YYGOTO(yyerrdefault);

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	YYGOTO(yyerrpop);
      yyn = -yyn;
      YYGOTO(yyreduce);
    }
  else if (yyn == 0)
    YYGOTO(yyerrpop);

  if (yyn == YYFINAL)
    YYACCEPT;

#if YY_RaildriverParser_DEBUG != 0
  if (YY_RaildriverParser_DEBUG_FLAG)
    fprintf(stderr, "Shifting error token, ");
#endif

  *++yyvsp = YY_RaildriverParser_LVAL;
#ifdef YY_RaildriverParser_LSP_NEEDED
  *++yylsp = YY_RaildriverParser_LLOC;
#endif

  yystate = yyn;
  YYGOTO(yynewstate);
/* end loop, in which YYGOTO may be used. */
  YYENDGOTO
}

/* END */

/* #line 1010 "/usr/lib/bison.cc" */
#line 1425 "raildriver.tab.cc"
#line 119 "raildriver.y"


static char rcsid[] = "$Id$";

int RaildriverParser::yylex()
{
static const struct {
	char *string;
	int   token;
} ReservedWords[] = {
	{"EXIT", EXIT},
	{"CLEAR", CLEAR},
	{"MASK", MASK},
	{"LED", LED},
	{"REVERSER", REVERSER},
	{"THROTTLE", THROTTLE},
	{"AUTOBRAKE", AUTOBRAKE},
	{"INDEPENDBRK", INDEPENDBRK},
	{"BAILOFF", BAILOFF},
	{"HEADLIGHT", HEADLIGHT},
	{"WIPER", WIPER},
	{"DIGITAL1", DIGITAL1},
	{"DIGITAL2", DIGITAL2},
	{"DIGITAL3", DIGITAL3},
	{"DIGITAL4", DIGITAL4},
	{"DIGITAL5", DIGITAL5},
	{"DIGITAL6", DIGITAL6},
	{"SPEAKER", SPEAKER},
	{"ON", ON},
	{"OFF", OFF},
	{"POLLVALUES", POLLVALUES} };
#define NumberOfReservedWords (sizeof(ReservedWords) / sizeof(ReservedWords[0]))

#ifdef DEBUG
	fprintf(stderr,"*** RaildriverParser::yylex(): currentPos = 0x%08x\n",currentPos);
#endif
	if (currentPos == NULL || *currentPos == '\0') return YYEOF;
	while (*currentPos != '\0' && *currentPos != '\n' && *currentPos <= ' ') currentPos++;
	if (*currentPos == '\0') return YYEOF;
//	yylloc.first_column = currentPos - yylloc.text;
//	yylloc.last_column  = yylloc.first_column+1;
	if (isdigit(*currentPos) || *currentPos == '_' || *currentPos == '-') {
		char *d = word;
		*d++ = *currentPos++;
		while (isdigit(*currentPos) || *currentPos == '.' || *currentPos == '_' || *currentPos == '-') *d++ = *currentPos++;
//		yylloc.last_column = currentPos - yylloc.text;
		*d = '\0';
		yylval.sval = word;
		return(LEDDIGITS);
	} else if (isalpha(*currentPos))
	{
		size_t i;
		char *s = word;
		while (isalnum(*currentPos)) *s++ = *currentPos++;
//		yylloc.last_column = currentPos - yylloc.text;
		*s = '\0';
		for (i = 0; i < NumberOfReservedWords; i++) {
			if (strcasecmp(word,ReservedWords[i].string) == 0)
			{
				return ReservedWords[i].token;
			}
		}
		return (BADSYMBOL);
	} else return *currentPos++;
}

void RaildriverParser::yyerror(char *message)
{
//	size_t toklen = yylloc.last_column - yylloc.first_column;
//	char *tokbuf = new char[toklen+1];
//	strncpy(tokbuf,yylloc.text+yylloc.first_column,toklen);
//	tokbuf[toklen] = '\0';
//	ErrFormat("503 %s: at token '%s'\n",message,tokbuf);
	ErrFormat("503 %s\n",message);
//	delete tokbuf;
}

void RaildriverParser::yyerror1(char *message,char *s)
{
	ErrFormat("504 %s: object '%s'\n",message,s);
}




