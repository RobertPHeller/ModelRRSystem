/* 
 * ------------------------------------------------------------------
 * MRRXtrkCad.y - 
 * Created by Robert Heller on Sun Jul 28 10:05:44 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.8  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.7  2005/11/04 19:06:34  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.6  2002/10/17 00:01:37  heller
 * Modification History: Update Parser to full functionality.
 * Modification History:
 * Modification History: Implement turnout body, track length, and turntable support.
 * Modification History:
 * Modification History: Revision 1.5  2002/09/25 23:56:50  heller
 * Modification History: Add in support for block gaps and turntables
 * Modification History:
 * Modification History: Revision 1.4  2002/09/24 04:20:18  heller
 * Modification History: MRRXtrkCad => TrackGraph
 * Modification History:
 * Modification History: Revision 1.3  2002/07/28 14:06:34  heller
 * Modification History: Add it copyright notice headers
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
#include <iostream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ParseFile.h>
#include <IntegerList.h>
/*#include <Tree.h>*/

#define TRUE true
#define FALSE false

extern const double INCHESperMM /* =  25.3807106598*/,
		    FEETperMM /* = 25.3807106598 * 12.0*/,
		    YARDSperMM /* = 25.3807106598 * 12.0 * 3.0 */,
		    METERSperMM /* = 1000.0 */,
		    CENTIMETERSperMM /* = 100.0 */,
		    HOScale /* = 1.0 / 87.0 */,
		    NScale /* = 1.0 / 160.0 */,
		    OScale /* = 1.0 / 43.5 */,
		    IScale /* = 1.0 / 32.0 */,
		    GScale /*= 1.0 / 22.5 */;

#define RADIANS(x) (((x) / 180.0) * M_PI)

%}

%start layout


%name MRRXtrkCad

%define CLASS MRRXtrkCad
%define INHERIT : public LayoutFile

%define CONSTRUCTOR_PARAM const char * filename
%define CONSTRUCTOR_INIT : LayoutFile (filename,this)
%define CONSTRUCTOR_CODE CurrentScale = 1.0;\
			 scanEol = false; \
			 scanToEND = false;\
			 /*YY_MRRLayoutFile_DEBUG_FLAG = 1;*/
%define MEMBERS virtual ~MRRXtrkCad() {}\
		private:\
		int lookup_word(const char *word) const;\
		void yyerror1(const char *message,const char *s) const;\
		bool scanEol,scanToEND; \
		int fieldflag;\
		double CurrentScale;

%define LSP_NEEDED 1


%define ERROR_VERBOSE
%define DEBUG 1

/* Type Union */
/* Union of token types:
 <ival> Integer values.
 <sval> String values.
 <fval> Float values.
 <tb> TrackBody pointer values.
 <tbe> TrackBodyElt pointer values.
 <trb> TurnoutBody pointer values.
 <trbe> TurnoutBodyElt pointer values.
 <il> IntegerList pointer values.
*/

%union {
	int ival;
	char *sval;
	float fval;
	TrackBody *tb;
	TrackBodyElt *tbe;
	TurnoutBody *trb;
	TurnoutBodyElt *trbe;
	IntegerList *il;
}


/* Base tokens that return values. */
/* INTEGER <ival> Integer Constants. */
%token <ival> INTEGER
/* FLOAT <fval> Floating Point Constants. */
%token <fval> FLOAT
/* STRING <sval> General quoted strings. */
%token <sval> STRING
/* RESTOFLINE <sval> Unquoted string taking up the rest of the line. */
%token <sval> RESTOFLINE
/* MULTILINE <sval> Unquoted string spaning multiple lines, terminated
   by a line containing only the word END. */
%token <sval> MULTILINE
/* Valueless tokens. */
/* Base tokens that do not have associated values. */
/* EOL End of line token */
%token EOL
/* Special Error tokens */
/* UNTERMSTRING Unterminated string. */
%token UNTERMSTRING
/* NOTWORD  Undefined reserved word encountered. */
%token NOTWORD
/* Reserved words. */
/* Base tokens for reserved words. */
/* END  */
%token END 
/* VERSION */
%token _VERSION
/* TITLE */
%token TITLE
/* MAPSCALE */
%token MAPSCALE
/* ROOMSIZE */
%token ROOMSIZE
/* SCALE */
%token SCALE
/* HO */
%token HO
/* N */
%token N
/* O */
%token O
/* LAYERS */
%token LAYERS
/* CURRENT */
%token CURRENT
/* STRUCTURE */
%token STRUCTURE
/* DRAW */
%token DRAW
/* CURVE */
%token CURVE
/* TURNOUT */
%token TURNOUT
/* TURNTABLE */
%token TURNTABLE
/* STRAIGHT */
%token STRAIGHT
/* CAR */
%token CAR
/* JOINT */
%token JOINT
/* NOTE */
%token NOTE
/* TEXT */
%token TEXT
/* MAIN */
%token MAIN
/* B */
%token B
/* J */
%token J
/* D */
%token D
/* L */
%token L
/* M */
%token M
/* F */
%token F
/* T */
%token T
/* E */
%token E
/* G */
%token G
/* A */
%token A
/* P */
%token P
/* S */
%token S
/* C */
%token C
/* X */
%token X
/* Y */
%token Y
/* Q */
%token Q
/* Typed non-terminals.*/
/* Non-terminals that have values. */
/* trackbody <tb> */
%type <tb> trackbody
/* turnoutbody <trb> */
%type <trb> turnoutbody
/* trackbodyelt <tbe>*/
%type <tbe> trackbodyelt
/* turnoutbodyelt <trbe> */
%type <trbe> turnoutbodyelt
/* intlist <il> */
%type <il> intlist
%%


layout : layout1 END EOL
	{cout << source_line << " lines processed in " << source_file << endl};


layout1 : definition layout1
	|
	;

definition : version
           | title
	   | mapscale
	   | roomsize
	   | scale
	   | layers
	   | structure
	   | draw
	   | curve
	   | straight
	   | turnout
	   | turntable
	   | car
	   | joint
	   | note
	   | text
	   | EOL
	   ;

version : _VERSION INTEGER FLOAT '.' INTEGER EOL;
	
title : TITLE INTEGER {scanEol = true;} RESTOFLINE EOL
	{cout << "Title " << $2 << ": " << $4 << endl};

mapscale : MAPSCALE INTEGER EOL;

roomsize : ROOMSIZE  FLOAT  X  FLOAT EOL;

scale : SCALE scalename EOL;

scalename : HO | N | O | G;

layers : LAYERS INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER
		INTEGER INTEGER STRING EOL
       | LAYERS CURRENT INTEGER EOL
       ;

structure : STRUCTURE INTEGER INTEGER INTEGER INTEGER INTEGER scalename
		      INTEGER FLOAT FLOAT INTEGER FLOAT STRING EOL structbody 
		      END EOL;

structbody : 
	   | structbodyelt structbody 
	   ;

structbodyelt : D FLOAT FLOAT EOL
              | L INTEGER INTEGER FLOAT FLOAT FLOAT INTEGER FLOAT FLOAT
		  INTEGER EOL
	      | M INTEGER INTEGER  FLOAT FLOAT FLOAT INTEGER FLOAT FLOAT
		  INTEGER INTEGER EOL
              | F INTEGER INTEGER FLOAT INTEGER EOL fblock
	      | A INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT INTEGER FLOAT FLOAT
		  EOL
	      | B INTEGER INTEGER FLOAT FLOAT FLOAT INTEGER FLOAT FLOAT INTEGER INTEGER EOL
	      | Q INTEGER INTEGER FLOAT FLOAT FLOAT INTEGER FLOAT FLOAT INTEGER EOL
	      | G INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT INTEGER EOL
	      | Y INTEGER INTEGER FLOAT INTEGER EOL fblock
	      ;
fblock : 
       | fblock1 fblock 
       ;

fblock1 : FLOAT FLOAT INTEGER EOL;	      
	      
	

draw : DRAW INTEGER INTEGER INTEGER INTEGER INTEGER FLOAT FLOAT INTEGER FLOAT
	    EOL structbody END EOL;

curve : CURVE INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER FLOAT
	      FLOAT INTEGER FLOAT INTEGER FLOAT FLOAT EOL trackbody END EOL
		 {trackGraph->InsertCurveTrack($2,$17,$9,$10,$12);};

trackbody : {$$ = NULL;}
          | trackbodyelt trackbody {$$ = TrackBody::ConsTrackBody($1,$2);}
          ;

trackbodyelt : T INTEGER FLOAT FLOAT FLOAT trackbodyelt1 EOL
			{$$ = TrackBodyElt::ConnectedTrackEnd($2,$3,$4,$5);}
	     | E FLOAT FLOAT FLOAT trackbodyelt1 EOL
	     		{$$ = TrackBodyElt::UnConnectedTrackEnd($2,$3,$4);}
	     ;

trackbodyelt1 :
	      | INTEGER FLOAT FLOAT floatornullorstring
	      ;

floatornullorstring :
	    | FLOAT
	    | STRING
	    ;

straight : STRAIGHT INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER
		    EOL trackbody END EOL {trackGraph->InsertStraightTrack($2,$10);};

turnout : TURNOUT INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER
		  FLOAT FLOAT INTEGER FLOAT STRING {TurnoutBodyElt::InitTSegId();} EOL turnoutbody END EOL
		{trackGraph->InsertTurnOut($2, $9, $10, $12, $13, $16);};

turnoutbody : {$$ = NULL;}
	    | turnoutbodyelt turnoutbody {
	    	if ($1 == NULL) {$$ = $2;} else {$$ = TurnoutBody::ConsTurnoutBody($1,$2);}}
	    ;

turnoutbodyelt : trackbodyelt {$$ = TurnoutBodyElt::MakeTurnoutEnd($1);}
	       | D FLOAT FLOAT EOL {$$ = NULL;}
	       | P STRING intlist EOL {$$ = TurnoutBodyElt::MakeTurnoutRoute($2,$3);}
	       | S INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT EOL
		{$$ = TurnoutBodyElt::MakeTurnoutStraightSegment($4,$5,$6,$7);}
	       | S INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT EOL
		{$$ = TurnoutBodyElt::MakeTurnoutStraightSegment($5,$6,$8,$9);}
	       | C INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT EOL
		{$$ = TurnoutBodyElt::MakeTurnoutCurveSegment($4,$5,$6,$7,$8);}
	       | C INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT EOL
		{$$ = TurnoutBodyElt::MakeTurnoutCurveSegment($5,$6,$7,$9,$10);}
	       | J INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT INTEGER EOL
	        {$$ = TurnoutBodyElt::MakeTurnoutJointSegment($4,$5,$6,$7,$8,$9,$10);}
	       | J INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT INTEGER EOL
	        {$$ = TurnoutBodyElt::MakeTurnoutJointSegment($5,$6,$8,$9,$10,$11,$12);}
	       ;

turntable : TURNTABLE INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER
		FLOAT FLOAT INTEGER FLOAT integerornull EOL trackbody END EOL
		{trackGraph->InsertTurnTable($2,$9, $10,$12,$15);};

integerornull :
	      | INTEGER
	      ;

intlist : {$$ = NULL;}
	| intlist INTEGER {$$ = IntegerList::IntAppend($1,$2);}
	;

joint : JOINT INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER
	FLOAT FLOAT FLOAT FLOAT INTEGER INTEGER INTEGER FLOAT FLOAT INTEGER
	FLOAT EOL trackbody END EOL {trackGraph->InsertJointTrack($2,$21,$9,$10,$19,$11,$12);};

car : CAR INTEGER scalename STRING INTEGER INTEGER FLOAT FLOAT INTEGER
	  INTEGER FLOAT FLOAT INTEGER FLOAT FLOAT car1 

car1 : INTEGER INTEGER INTEGER 
	  INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER 
	  FLOAT FLOAT FLOAT EOL trackbody END EOL;
     | INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER
	EOL
     ;

note : NOTE note1 EOL {scanToEND = true;} MULTILINE EOL ;

note1 : MAIN INTEGER INTEGER INTEGER INTEGER INTEGER
      | INTEGER INTEGER INTEGER INTEGER FLOAT FLOAT INTEGER INTEGER
      ;

text : TEXT INTEGER INTEGER INTEGER INTEGER INTEGER FLOAT FLOAT INTEGER STRING INTEGER EOL


%%


static char rcsid[] = "$Id$";


int MRRXtrkCad::lookup_word(const char *word) const
{
	static const struct {
		const char *w;
		int id;
	} reserved_words[] = {
		{"A", A},
		{"B", B},
		{"C", C},
		{"CAR", CAR},
		{"CURRENT", CURRENT},
		{"CURVE", CURVE },
		{"D", D},
		{"DRAW", DRAW },
		{"E", E},
		{"END", END},
		{"F", F},
		{"G", G},
		{"HO", HO},
		{"J", J},
		{"JOINT", JOINT},
		{"L", L},
		{"LAYERS", LAYERS },
		{"M", M},
		{"MAIN", MAIN}, 
		{"MAPSCALE", MAPSCALE},
		{"N", N },
		{"NOTE", NOTE},
		{"O", O},
		{"P", P},
		{"Q", Q},
		{"ROOMSIZE", ROOMSIZE},
		{"S", S},
		{"SCALE", SCALE},
		{"STRAIGHT", STRAIGHT},
		{"STRUCTURE", STRUCTURE},
		{"T", T},
		{"TEXT", TEXT},
		{"TITLE", TITLE},
		{"TURNOUT", TURNOUT},
		{"TURNTABLE", TURNTABLE},
		{"VERSION", _VERSION},
		{"X", X},
		{"Y", Y} };
	const int count = sizeof(reserved_words) / sizeof(reserved_words[0]);
	int m,l,e,comp;

//	cerr << "*** MRRXtrkCad::lookup_word(\"" << word << "\")" << endl;
	l = 0; e = count;
	while (e > l) {
		m = (l+e)/2;
		comp = strcmp(word,reserved_words[m].w);
//		cerr << "*** -: l = " << l << ", e = " << e << ", m = "
//		     << m << ",reserved_words[m].w = \"" 
//		     << reserved_words[m].w << "\", comp = " << comp << endl;
		if (comp == 0) return reserved_words[m].id;
		else if (comp < 0) e = m;
		else l = m+1;
	}
	return NOTWORD;
}

int MRRXtrkCad::yylex()
{
	static char word[4096];

	yylloc.first_line = source_line;
	if (lp != NULL) yylloc.first_column = lp - line_buffer;
	else yylloc.first_column = 0;
	yylloc.text = line_buffer;
	yylloc.last_line = source_line;
	if (lp == NULL || *lp == '\0')
	{
		lp = fgets(line_buffer,buffersize,fp);
		if (lp == NULL) return(YYEOF);
		else source_line++;
		yylloc.first_line = source_line;
		yylloc.last_line = source_line;
	}
	yylloc.first_column = lp - line_buffer;
	if (scanEol)
	{
		char *p = word;
		while (*lp != '\0' && *lp != '\n') *p++ = *lp++;
		*p = '\0';
		yylval.sval = new char[strlen(word)+1];
		strcpy(yylval.sval,word);
		yylloc.last_column = lp - line_buffer;
		scanEol = false;
		return(RESTOFLINE);
	}
	if (scanToEND)
	{
		char *temp = new char [4096];
		char *p = temp;
		int nLeft = 4096, nSize = 4096;
		while (scanToEND) {
			char *q = word;
			while (*lp != '\0' && *lp != '\n') *q++ = *lp++;
			*q++ = '\0';
			for (q = word; *q <= ' ' && *q != '\0'; q++) ;
			if (strcmp(q,"END") == 0) {
				*p = '\0';
				yylval.sval = temp;
				yylloc.last_column = lp - line_buffer;
				scanToEND = false;
				return (MULTILINE);
			} else {
				if ((strlen(word) + 1) > nLeft) {
					*p = '\0';
					char *temp1 = new char[nSize+4096];
					strcpy(temp1,temp);
					p = temp1 + (p-temp);
					delete temp;
					temp = temp1;
					nLeft += 4096;
					nSize += 4096;
				}
				strcpy(p,word);
				p += strlen(word);
				nLeft -= strlen(word);
				*p++ = '\n';
				nLeft--;
				yylloc.first_line = source_line;
				yylloc.first_column = 0;
				lp = fgets(line_buffer,buffersize,fp);
				if (lp == NULL) return(YYEOF);
				else source_line++;
				yylloc.first_line = source_line;
				yylloc.last_line = source_line;
			}
		}
	}
	while (*lp != '\0' && *lp <= ' ' && *lp != '\n') lp++;
	if (*lp == '\n') {
		lp = NULL;
		yylloc.last_column = strlen(line_buffer);
		return (EOL);
	}
	if (*lp == '#') {
		lp = NULL;
		yylloc.last_column = strlen(line_buffer);
		return (EOL);
	}
	if (isdigit(*lp) ||
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
			yylloc.last_column = lp - line_buffer;
			return(FLOAT);
		}
		*p = '\0';
		yylval.ival = atoi(word);
		yylloc.last_column = lp - line_buffer;
		return(INTEGER);
	} else if (isalpha(*lp))
	{
		char *p = word;
		while (isalpha(*lp))
		{
			char c = *lp++;
			if (islower(c)) c = toupper(c);
			*p++ = c;
		}
		*p = '\0';
		yylloc.last_column = lp - line_buffer;
		return lookup_word(word);
	} else if (*lp == '"')
	{
		lp++;
		char *p = word;
		while (*lp != '"' && *lp != '\n' && *lp != '\0')
		{
			if (*lp == '\\')
			{
				lp++;
				*p++ = *lp++;
				if (*lp == '\0')
				{
					lp = fgets(line_buffer,buffersize,fp);
					if (lp == NULL) return(YYEOF);
					else source_line++;
					yylloc.last_line = source_line;
				}
			} else *p++ = *lp++;
		}
		yylloc.last_column = (lp+1) - line_buffer;
		if (*lp != '"')
		{
			static char mbuff[128];
			sprintf(mbuff,
		"Unterminated string constant, posible start on line %d",
				yylloc.first_line);
			yyerror(mbuff); 
			return(UNTERMSTRING);
		} else
		{
			*p = '\0';
			lp++;
			yylval.sval = new char[strlen(word)+1];
			strcpy(yylval.sval,word);
			yylloc.last_column = lp - line_buffer;
			return(STRING);
		}
	} else
	{
		yylloc.last_column = (lp+1) - line_buffer;
		return(*lp++);
	}
}

void MRRXtrkCad::yyerror(char *message)
{
	if (source_file == NULL || strlen(source_file) == 0)
		*errorstream << message << endl;
	else
	{
		*errorstream << source_file << ":" << source_line;
		if (yylloc.first_line == yylloc.last_line)
		{
			*errorstream << " at token '";
			for (char *s = yylloc.text+yylloc.first_column;
				   s < yylloc.text+yylloc.last_column;
				   s++) *errorstream << *s;
			*errorstream << "'";
		} else
		{
			*errorstream << " between lines " << yylloc.first_line
					<< " and " << yylloc.last_line ;
		}
		*errorstream << ": " << message << endl;
	}
}

void MRRXtrkCad::yyerror1(const char *message,const char *s) const
{
	if (source_file == NULL || strlen(source_file) == 0)
		*errorstream << message << endl;
	else
	{
		*errorstream << source_file << ":" << source_line;
		*errorstream << " in object '" << s << "'";
		*errorstream << ": " << message << endl;
	}
}

