/* 
 * ------------------------------------------------------------------
 * raildriver.y - Rail driver protocol parser
 * Created by Robert Heller on Tue Feb  1 08:36:21 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/03/01 22:51:38  heller
 * Modification History: March 1 Lock down
 * Modification History:
 * Modification History: Revision 1.1  2005/02/12 22:19:23  heller
 * Modification History: Rail Driver code -- first lock down
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <RaildriverServer.h>

#define TRUE true
#define FALSE false

%}

/* Goal Token */
%start command

/* Parser Name */
%name RaildriverParser

/*%define LSP_NEEDED 1*/

/* Bison++ Class defines: class name, its inheritence, its constructor, and
 * its members
 */

%define CLASS RaildriverParser
%define INHERIT : public RaildriverServer
%define CONSTRUCTOR_PARAM int sock, struct sockaddr_in *sockaddr
%define CONSTRUCTOR_INIT : RaildriverServer(sock,sockaddr,this)
%define CONSTRUCTOR_CODE currentPos = NULL; \
			/*YY_RaildriverParser_DEBUG_FLAG = 1;*/
%define MEMBERS void ResetPtr(char *buffer) {currentPos = buffer;/*yylloc.text = buffer;*/} \
		private:\
		void yyerror1(char *message,char *s);\
		char *currentPos;\
		char word[4096];

/* Verbose error messages */
%define ERROR_VERBOSE
/* Enable debugging code */
%define DEBUG 1

/* Token union type */
%union {
	int ival;
	char *sval;
	RaildriverIO::Eventmask_bits eval;
}

/* Tokens */
%token <sval> LEDDIGITS
%token        BADSYMBOL

%token EXIT CLEAR MASK LED
%token REVERSER THROTTLE AUTOBRAKE INDEPENDBRK BAILOFF HEADLIGHT
%token WIPER DIGITAL1 DIGITAL2 DIGITAL3 DIGITAL4 DIGITAL5 DIGITAL6
%token SPEAKER ON OFF POLLVALUES

/* Non terminal types */
%type  <eval> maskbits maskbit

  
%%

/* Commands */
command : EXIT '\n' {DoExit();}
	| CLEAR '\n' {ClearMask();}
	| MASK maskbits '\n' {AddMask($2);}
	| POLLVALUES maskbits '\n' {PollValues($2);}
	| LED LEDDIGITS '\n' {LedDisplay($2);}
	| SPEAKER ON '\n' {SpeakerOn();}
	| SPEAKER OFF '\n' {SpeakerOff();}
	;

/* Mask bits accumlator */
maskbits : {$$ = RaildriverIO::NONE_M;}
	 | maskbits maskbit {$$ = (RaildriverIO::Eventmask_bits) ($1 | $2);}
	 ;

/* Single mask bit names */
maskbit : REVERSER {$$ = RaildriverIO::REVERSER_M;}
	| THROTTLE {$$ = RaildriverIO::THROTTLE_M;}
	| AUTOBRAKE {$$ = RaildriverIO::AUTOBRAKE_M;}
	| INDEPENDBRK {$$ = RaildriverIO::INDEPENDBRK_M;}
	| BAILOFF {$$ = RaildriverIO::BAILOFF_M;}
	| HEADLIGHT {$$ = RaildriverIO::HEADLIGHT_M;}
	| WIPER {$$ = RaildriverIO::WIPER_M;}
	| DIGITAL1 {$$ = RaildriverIO::DIGITAL1_M;}
	| DIGITAL2 {$$ = RaildriverIO::DIGITAL2_M;}
	| DIGITAL3 {$$ = RaildriverIO::DIGITAL3_M;}
	| DIGITAL4 {$$ = RaildriverIO::DIGITAL4_M;}
	| DIGITAL5 {$$ = RaildriverIO::DIGITAL5_M;}
	| DIGITAL6 {$$ = RaildriverIO::DIGITAL6_M;}

%%

static char rcsid[] = "$Id$";

/*
 * Lexical analyser: return next non-terminal token.
 * 	Defined tokens: command name words, maskbit names, and LEDDIGITS.
 *	Whitespace is needed, but gobbled by the lexical analyser,  EOL == '\n'.
 *
 *
 */
int RaildriverParser::yylex()
{
	/*
	 * Array of all known reserved words and the token IDs.
	 */
static const struct {
	char *string;
	int   token;
} ReservedWords[] = {
	{"EXIT", EXIT},			/* Exit command */
	{"CLEAR", CLEAR},		/* Clear command */
	{"MASK", MASK},			/* Mask command */
	{"LED", LED},			/* Led command */
	{"REVERSER", REVERSER},		/* Reverser mask bit */
	{"THROTTLE", THROTTLE},		/* Throttle mask bit */
	{"AUTOBRAKE", AUTOBRAKE},	/* Autobrake mask bit */
	{"INDEPENDBRK", INDEPENDBRK},	/* Indepenent brake mask bit */
	{"BAILOFF", BAILOFF},		/* Bailoff mask bit */
	{"HEADLIGHT", HEADLIGHT},	/* Headlight mask bit */
	{"WIPER", WIPER},		/* Wiper mask bit */
	{"DIGITAL1", DIGITAL1},		/* Digital 1 mask bit */
	{"DIGITAL2", DIGITAL2},		/* Digital 2 mask bit */
	{"DIGITAL3", DIGITAL3},		/* Digital 3 mask bit */
	{"DIGITAL4", DIGITAL4},		/* Digital 4 mask bit */
	{"DIGITAL5", DIGITAL5},		/* Digital 5 mask bit */
	{"DIGITAL6", DIGITAL6},		/* Digital 6 mask bit */
	{"SPEAKER", SPEAKER},		/* Speaker command */
	{"ON", ON},			/* ON word */
	{"OFF", OFF},			/* OFF word */
	{"POLLVALUES", POLLVALUES} };	/* Poll values command */
/* Number of reserved words */
#define NumberOfReservedWords (sizeof(ReservedWords) / sizeof(ReservedWords[0]))

#ifdef DEBUG
	fprintf(stderr,"*** RaildriverParser::yylex(): currentPos = 0x%08x\n",currentPos);
#endif
	/* At EOL? return EOF */
	if (currentPos == NULL || *currentPos == '\0') return YYEOF;
	/* Skip white space (not '\n'!) */
	while (*currentPos != '\0' && *currentPos != '\n' && *currentPos <= ' ') currentPos++;
	/* At EOL? return EOF */
	if (*currentPos == '\0') return YYEOF;
//	yylloc.first_column = currentPos - yylloc.text;
//	yylloc.last_column  = yylloc.first_column+1;
	/* Led digits??? */
	if (isdigit(*currentPos) || *currentPos == '_' || *currentPos == '-') {
		/* Accumulate the digits and return the LEDDIGITS token. */
		char *d = word;
		*d++ = *currentPos++;
		while (isdigit(*currentPos) || *currentPos == '.' || *currentPos == '_' || *currentPos == '-') *d++ = *currentPos++;
//		yylloc.last_column = currentPos - yylloc.text;
		*d = '\0';
		yylval.sval = word;
		return(LEDDIGITS);
	/* Possible reserved word? */
	} else if (isalpha(*currentPos))
	{
		/* Accumulate the word. */
		size_t i;
		char *s = word;
		while (isalnum(*currentPos)) *s++ = *currentPos++;
//		yylloc.last_column = currentPos - yylloc.text;
		*s = '\0';
		/* Lookup word in table, returning corresponding token. */
		for (i = 0; i < NumberOfReservedWords; i++) {
			if (strcasecmp(word,ReservedWords[i].string) == 0)
			{
				return ReservedWords[i].token;
			}
		}
		/* Not found? Undefined word, return error symbol (parser will fail). */
		return (BADSYMBOL);
	/* Some non alpha character: should only be '\n' -- anything else is a
	 * syntax error.  Let the parser handle it.
	 */
	} else return *currentPos++;
}

/* Handle parser error messages. */
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

/* Handled extended parser error messages. */
void RaildriverParser::yyerror1(char *message,char *s)
{
	ErrFormat("504 %s: object '%s'\n",message,s);
}




