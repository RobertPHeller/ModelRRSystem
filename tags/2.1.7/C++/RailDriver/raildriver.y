/* 
 * ------------------------------------------------------------------
 * raildriver.y - Rail driver protocol parser
 * Created by Robert Heller on Tue Feb  1 08:36:21 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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
#include <raildriverthread.h>
#include <raildriver.tab.h>

#define TRUE true
#define FALSE false

%}

%start command

%name RaildriverParser

/*%define LSP_NEEDED 1*/
%define CLASS RaildriverParser
%define INHERIT : public RD_Threads
%define CONSTRUCTOR_PARAM int sock, struct sockaddr_in *sockaddr,RD_Event *event
%define CONSTRUCTOR_INIT : RD_Threads(sock,sockaddr,this,event)
%define CONSTRUCTOR_CODE currentPos = NULL; \
			/*YY_RaildriverParser_DEBUG_FLAG = 1;*/
%define MEMBERS void ResetPtr(char *buffer) {currentPos = buffer;/*yylloc.text = buffer;*/} \
		private:\
		void yyerror1(char *message,char *s);\
		char *currentPos;\
		char word[4096];

%define ERROR_VERBOSE
%define DEBUG 1

%union {
	int ival;
	char *sval;
	RD_Event::Eventmask_bits eval;
}

%token <sval> LEDDIGITS
%token        BADSYMBOL

%token EXIT CLEAR MASK LED
%token REVERSER THROTTLE AUTOBRAKE INDEPENDBRK BAILOFF HEADLIGHT
%token WIPER DIGITAL1 DIGITAL2 DIGITAL3 DIGITAL4 DIGITAL5 DIGITAL6
%type  <eval> maskbits maskbit
%token SPEAKER ON OFF POLLVALUES
  
%%

command : EXIT '\n' {DoExit();}
	| CLEAR '\n' {ClearMask();}
	| MASK maskbits '\n' {AddMask($2);}
	| POLLVALUES maskbits '\n' {PollValues($2);}
	| LED LEDDIGITS '\n' {LedDisplay($2);}
	| SPEAKER ON '\n' {SpeakerOn();}
	| SPEAKER OFF '\n' {SpeakerOff();}
	;

maskbits : {$$ = RD_Event::NONE_M;}
	 | maskbits maskbit {$$ = (RD_Event::Eventmask_bits) ($1 | $2);}
	 ;

maskbit : REVERSER {$$ = RD_Event::REVERSER_M;}
	| THROTTLE {$$ = RD_Event::THROTTLE_M;}
	| AUTOBRAKE {$$ = RD_Event::AUTOBRAKE_M;}
	| INDEPENDBRK {$$ = RD_Event::INDEPENDBRK_M;}
	| BAILOFF {$$ = RD_Event::BAILOFF_M;}
	| HEADLIGHT {$$ = RD_Event::HEADLIGHT_M;}
	| WIPER {$$ = RD_Event::WIPER_M;}
	| DIGITAL1 {$$ = RD_Event::DIGITAL1_M;}
	| DIGITAL2 {$$ = RD_Event::DIGITAL2_M;}
	| DIGITAL3 {$$ = RD_Event::DIGITAL3_M;}
	| DIGITAL4 {$$ = RD_Event::DIGITAL4_M;}
	| DIGITAL5 {$$ = RD_Event::DIGITAL5_M;}
	| DIGITAL6 {$$ = RD_Event::DIGITAL6_M;}

%%

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




