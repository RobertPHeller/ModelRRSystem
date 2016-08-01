/* 
 * ------------------------------------------------------------------
 * MRRSigExpr.y - MRR Signal Expression parser
 * Created by Robert Heller on Sun Aug  6 14:53:51 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.2  2002/09/24 04:20:18  heller
 * Modification History: MRRXtrkCad => TrackGraph
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Revision 2.5  1995/09/09  22:54:10  heller
 * Add in verbose error reporting
 * Add in error stream hook.
 *
 * Revision 2.4  1995/09/05  21:11:03  heller
 * Add verbose error reporting
 *
 * Revision 2.3  1995/09/04  00:55:44  heller
 * handle full element names (::)
 *
 * Revision 2.2  1995/09/03  22:57:50  heller
 * Update to complete version
 *
 * Revision 2.1  1995/08/06  19:08:43  heller
 * *** empty log message ***
 *
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
 * 			51 Locke Hill Road
 * 			Wendell, MA 01379-9728
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 *  
 */

%header{
#include <stdio.h>
#include <iostream.h>
#include <strstream.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <SigExpr.h>
#include <Tree.h>

#define TRUE true
#define FALSE false

%}

%start result

%name MRRSigExpr
%define CLASS MRRSigExpr
%define INHERIT : public SigExpr
%define CONSTRUCTOR_PARAM const char * Expr,TreeTable *t,ostream *es=NULL
%define CONSTRUCTOR_INIT : SigExpr (this,es)
%define CONSTRUCTOR_CODE Expression = (char *)Expr;lp = (char*)Expression;trees = t;
%define MEMBERS virtual ~MRRSigExpr() {}\
		private:\
		int fieldflag;\
		char * Expression;\
		char *lp;


%define ERROR_VERBOSE
%define DEBUG 1

%union {
	int ival;
	char *sval;
	float fval;
	Expr *eval;
}


%token <ival> INTEGER
%token <ival> HEXNUMBER
%token <sval> SYMBOL
%token <fval> FLOAT
%token <sval> STRING
%token        UNTERMSTRING
%type <ival>  onetwo
%type <eval>  expression result
%token AND OR NOT TABLE POINT MAIN DIVERGENCE TURNOUT BLOCK
%left AND OR
%right NOT

%%

result : expression   {Result = $1;}

expression : '(' expression ')' { $$ = $2; }
           | NOT expression     { $$ = new NotExpr($2); }
           | expression OR expression { $$ = new OrExpr($1,$3); }
           | expression AND expression { $$ = new AndExpr($1,$3); }
	   | TABLE   SYMBOL POINT INTEGER       {$$ = new TableExpr(FINDTABLE($2),$4); }
	   | TURNOUT SYMBOL MAIN       { $$ = new TurnExpr(FINDTURNOUT($2),0); }
	   | TURNOUT SYMBOL DIVERGENCE       { $$ = new TurnExpr(FINDTURNOUT($2),1); }
	   | TURNOUT SYMBOL DIVERGENCE onetwo       { $$ = new TurnExpr(FINDTURNOUT($2),$4); }
	   | BLOCK   SYMBOL		{ $$ = new BlockExpr(FINDBLOCK($2)); }
     ;

onetwo : INTEGER	{if ($1 == 1 || $1 == 2) $$ = $1;
			 else {yyerror("DIVERENCE must be 1 or 2");YYERROR;}
			}

%%

static char rcsid[] = "$Id$";


static bool ColonOk(int &NumColons,bool &PrevWasColon,char ch)
{
	if (ch != ':')
	{
		PrevWasColon = FALSE;
		return FALSE;
	}
	else
	{
		if (NumColons == 0)
		{
			NumColons++;
			PrevWasColon = TRUE;
			return TRUE;
		} else if (NumColons == 1 && PrevWasColon == TRUE)
		{
			NumColons++;
			return TRUE;
		} else return FALSE;
	}
}
			

int MRRSigExpr::yylex()
{
	static struct {
		char *w;
		int  cd;
	} reserved_words[] = {
		{"and", AND},
		{"or", OR},
		{"not", NOT},
		{"point", POINT},
		{"main", MAIN},
		{"divergence", DIVERGENCE},
		{"turnout", TURNOUT},
		{"table", TABLE},
		{"block", BLOCK},
	};
									
	static const int number_reserved = (sizeof(reserved_words) /
				sizeof(reserved_words[0]));

	static char word[256];

	if (lp == NULL || *lp == '\0') return(YYEOF);
	while (*lp != '\0' && *lp <= ' ') lp++;
	if (*lp == '0' && (*(lp+1) == 'x' || *(lp+1) == 'X'))
	{
		// hex number
		long int hexnum = 0;
		lp += 2;
		while (isdigit(*lp) || strchr("abcdefABCDEF",*lp) != NULL)
		{
			int ch = *lp++;
			hexnum = hexnum << 4;
			if (isdigit(ch)) hexnum += ch - '0';
			else if (ch >= 'a' && ch <= 'f') hexnum += (ch - 'a') + 10;
			else hexnum += (ch - 'A') + 10;
		}
		yylval.ival = hexnum;
		return(HEXNUMBER);
	} else if (isdigit(*lp) ||
		   ((*lp == '+' || *lp == '-') && isdigit(*(lp+1))))
	{
		char *p = word;
		*p++ = *lp++;
		while (isdigit(*lp)) *p++ = *lp++;
		if (*lp == '.')
		{
			*p++ = *lp++;
			while (isdigit(*lp)) *p++ = *lp++;
			if ((*lp == 'e' || *lp == 'E') &&
			    (isdigit(*(lp+1)) ||
			     ((*(lp+1) == '+' || *(lp+1) == '-') &&
			      isdigit(*(lp+2)))))
			{
				*p++ = *lp++;
				if (*lp == '+' || *lp == '-') *p++ = *lp++;
				while (isdigit(*lp)) *p++ = *lp++;
			}
			*p = '\0';
			yylval.fval = atof(word);
			return(FLOAT);
		}
		*p = '\0';
		yylval.ival = atoi(word);
		return(INTEGER);
	} else if (isalpha(*lp))
	{
		int colonsSeen = 0;
		bool prevWasColon = FALSE;
		char *p = word;
		while (isalpha(*lp) || *lp == '$' || *lp == '.' ||
			*lp == '_' || isdigit(*lp) || 
			ColonOk(colonsSeen,prevWasColon,*lp))
		{
			char c = *lp++;
			if (isupper(c)) c = tolower(c);
			*p++ = c;
			if (c != ':') prevWasColon = FALSE;
		}
		*p = '\0';
		for (int i = 0; i < number_reserved; i++)
		{
			if (strcmp(word,reserved_words[i].w) == 0)
				return(reserved_words[i].cd);
		}
		yylval.sval = new char[strlen(word)+1];
		strcpy(yylval.sval,word);
		return(SYMBOL);
	} else if (*lp == '"')
	{
		lp++;
		char *p = word;
		while (*lp != '"' && *lp != '\0')
		{
			if (*lp == '\\')
			{
				lp++;
				*p++ = *lp;
				if (*lp == '\0') break;
				else lp++;
			} else *p++ = *lp++;
		}
		if (*lp != '"')
		{
			yyerror("Unterminated string constant"); 
			return(UNTERMSTRING);
		} else
		{
			lp++;
			yylval.sval = new char[strlen(word)+1];
			strcpy(yylval.sval,word);
			return(STRING);
		}
	} else
	{
		return(*lp++);
	}
}

void MRRSigExpr::yyerror(char *message)
{
	*errorstream << message << "\n";
}


