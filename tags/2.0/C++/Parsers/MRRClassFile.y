/* 
 * ------------------------------------------------------------------
 * MRRClassFile.y - MRR System Special Trackwork Class file parser
 * Created by Robert Heller on Sun Aug  6 14:30:46 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/14 18:09:37  heller
 * Modification History: Initial revision
 * Modification History:
 * Modification History: Revision 2.4  2000/11/10 00:25:42  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.3  1995/09/12 02:43:09  heller
 * Modification History: Write actual parser, with support.
 * Modification History:
 * Revision 2.2  1995/08/06  19:36:27  heller
 * Add in ParseFile.
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
#include <ctype.h>
#include <stdlib.h>
#include <string>
#include <string.h>
#include <math.h>
#include <ParseFile.h>
#include <Class.h>

#define TRUE true
#define FALSE false

const double INCHESperMM =  25.3807106598,
		    FEETperMM = 25.3807106598 * 12.0,
		    YARDSperMM = 25.3807106598 * 12.0 * 3.0,
		    METERSperMM = 1000.0,
		    CENTIMETERSperMM = 100.0,
		    HOScale = 1.0 / 87.0,
		    NScale = 1.0 / 160.0,
		    OScale = 1.0 / 43.5,
		    IScale = 1.0 / 32.0,
		    GScale = 1.0 / 22.5;

#define RADIANS(x) (((x) / 180.0) * M_PI)

%}

%start file

%name MRRClassFile
%define LSP_NEEDED 1
%define CLASS MRRClassFile
%define INHERIT : public ClassFile
%define CONSTRUCTOR_PARAM string filename
%define CONSTRUCTOR_INIT : ClassFile (filename,this)
%define CONSTRUCTOR_CODE hasHandle = FALSE; CurrentScale = 1.0;\
			 tempVector = NULL;tempVectorSize=0;\
			 /*YY_MRRClassFile_DEBUG_FLAG = 1;*/
%define MEMBERS virtual ~MRRClassFile() {if (tempVector != NULL) delete tempVector;}\
		int fieldflag;\
		friend int MRRParseFile_Init(Tcl_Interp *interp);\
		int Handlize(Tcl_Interp *interp);\
		int MyHandle(Tcl_Interp *interp,char *handlebuffer);\
		int TclFunction(Tcl_Interp *interp,int argc, char *argv[]);\
		private:\
		void yyerror1(char *message,char *s);\
		double CurrentScale;\
		static void_pt Handles;\
		bool hasHandle;\
		Segment **tempVector;\
		int tempVectorSize,tempVectorIndex;\
		void AllocTempVector(int newSize);\
		bool InsertSegment(Segment *newSeg);

%define ERROR_VERBOSE
%define DEBUG 1

%union {
	int ival;
	char *sval;
	float fval;
	Segment *sgval;
	NextElement *nxval;
}


%token <ival> INTEGER
%token <ival> HEXNUMBER
%token <sval> SYMBOL
%token <fval> FLOAT
%token <sval> STRING
%token        UNTERMSTRING
%type <nxval> next
%type <fval> distance number unitfactor units scale scalefactor angle
%type <ival> onetwo
%type <sgval> segment 

%token SET SCALE INCHES FEET YARDS METERS MILIMETERS
%token CENTIMETERS HO N I O G

%token CLASS

%token DEFINE TURNOUT CROSS TABLE SEGMENT MAIN DIVERGENCE
%token NONE EMPTY LEG POINTS SEGMENTS 

%%

file : {CurrentScale = 1.0;} file1;

file1 :
      | file1 definition
      ;

definition : setscale
	   | class
	   | defturnout
	   | defcross
	   | deftable
	   ;

distance : number {$$ = $1;}
         | number unitfactor {$$ = $1 * $2;}
         ;


number : INTEGER	{$$ = (float) $1;}
       | FLOAT		{$$ = $1;}
       ;

unitfactor : units	{$$ = $1;}
	   | scale units {$$ = $1 * $2;}
	   ;

units : INCHES		{$$ = INCHESperMM;}
      | FEET		{$$ = FEETperMM;}
      | YARDS		{$$ = YARDSperMM;}
      | METERS		{$$ = METERSperMM;}
      | MILIMETERS	{$$ = 1.0;}
      | CENTIMETERS	{$$ = CENTIMETERSperMM;}
      ;

scale : SCALE		{$$ = CurrentScale;}

setscale : SET SCALE scalefactor {CurrentScale = $3;}
	 ;

scalefactor : HO	{$$ = HOScale;}
	    | N		{$$ = NScale;}
	    | I		{$$ = IScale;}
	    | O		{$$ = OScale;}
	    | G		{$$ = GScale;}
	    | number	{$$ = 1.0 / $1;}
	    ;

onetwo : INTEGER	{if ($1 == 1 || $1 == 2) $$ = $1;
			 else {yyerror("expected a 1 or a 2");YYERROR;}
			}
next : NONE		{ $$ = new NextElement();}
     | EMPTY		{ $$ = NULL;}
     ;


angle : number {double x = RADIANS($1); if (x < 0 || x >= (M_PI * 2))
					{yyerror("Angle too large");YYERROR;}
		$$ = x;}
      ;

segment : '{' distance distance distance next distance distance distance next angle '}'
		{$$ = new Segment($2,$3,$4,$5,$6,$7,$8,$9,$10);}
	;		

defturnout : define TURNOUT SYMBOL MAIN segment
						    DIVERGENCE segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {TurnoutClass* t = FINDTURNOUT($3);
	      if (t->Tag() != Class::TurnoutMenu)
	      {yyerror1("Redeclaration to new type!",$3);YYERROR;}
	      if (t->ValidP == TRUE)
	      {yyerror1("Redeclaration!",$3);YYERROR;}
	      t->Main1 = $5;
	      t->D1 = $7;
	      t->Length = $8;
	      t->MainSpeed = $10;
	      t->DivergenceSpeed = $12;
	      t->ReadStateScript = $13;
	      t->ActuateScript = $14;
	      t->ValidP = TRUE;
	     }
	   | define TURNOUT SYMBOL MAIN segment
						    DIVERGENCE onetwo segment 
						    DIVERGENCE onetwo segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {if ($7 == $10)
	      {yyerror1("Need two different DIVERGENCE segments",$3);YYERROR;}
	      TurnoutClass* t = FINDTURNOUT($3);
	      if (t->Tag() != Class::TurnoutMenu)
	      {yyerror1("Redeclaration to new type!",$3);YYERROR;}
	      if (t->ValidP == TRUE)
	      {yyerror1("Redeclaration!",$3);YYERROR;}
	      t->Main1 = $5;
	      if ($7 == 1) t->D1 = $8;
	      else t->D2 = $8;
	      if ($10 == 1) t->D1 = $11;
	      else t->D2 = $11;
	      t->Length = $12;
	      t->MainSpeed = $14;
	      t->DivergenceSpeed = $16;
	      t->ReadStateScript = $17;
	      t->ActuateScript = $18;
	      t->ValidP = TRUE;
	     }
	   | define TURNOUT SYMBOL  MAIN onetwo segment
						    MAIN onetwo segment 
						    DIVERGENCE onetwo segment 
						    DIVERGENCE onetwo segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {if ($5 == $8)
	      {yyerror1("Need two different MAIN segments",$3);YYERROR;}
	      if ($11 == $14)
	      {yyerror1("Need two different DIVERGENCE segments",$3);YYERROR;}
	      TurnoutClass* t = FINDTURNOUT($3);
	      if (t->Tag() != Class::TurnoutMenu)
	      {yyerror1("Redeclaration to new type!",$3);YYERROR;}
	      if (t->ValidP == TRUE)
	      {yyerror1("Redeclaration!",$3);YYERROR;}
	      if ($5 == 1) t->Main1 = $6;
	      else t->Main2 = $6;
	      if ($8 == 1) t->Main1 = $9;
	      else t->Main2 = $9;
	      if ($11 == 1) t->D1 = $12;
	      else t->D2 = $12;
	      if ($14 == 1) t->D1 = $15;
	      else t->D2 = $15;
	      t->Length = $16;
	      t->MainSpeed = $18;
	      t->DivergenceSpeed = $20;
	      t->ReadStateScript = $21;
	      t->ActuateScript = $22;
	      t->ValidP = TRUE;
	     }
	      
	   | define TURNOUT SYMBOL MAIN onetwo segment
						    MAIN onetwo segment 
						    DIVERGENCE  segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {if ($5 == $8)
	      {yyerror1("Need two different MAIN segments",$3);YYERROR;}
	      TurnoutClass* t = FINDTURNOUT($3);
	      if (t->Tag() != Class::TurnoutMenu)
	      {yyerror1("Redeclaration to new type!",$3);YYERROR;}
	      if (t->ValidP == TRUE)
	      {yyerror1("Redeclaration!",$3);YYERROR;}
	      if ($5 == 1) t->Main1 = $6;
	      else t->Main2 = $6;
	      if ($8 == 1) t->Main1 = $9;
	      else t->Main2 = $9;
	      t->D1 = $11;
	      t->Length = $12;
	      t->MainSpeed = $14;
	      t->DivergenceSpeed = $16;
	      t->ReadStateScript = $17;
	      t->ActuateScript = $18;
	      t->ValidP = TRUE;
	     }
	   ;

defcross : define CROSS SYMBOL LEG onetwo segment LEG onetwo segment
			INTEGER ':' INTEGER
	   {if ($5 == $8)
	    {yyerror1("Need two different LEG segments",$3);YYERROR;}
	    CrossClass *c = FINDCROSS($3);
	    if (c->Tag() != Class::CrossMenu)
	    {yyerror1("Redeclaration to new type!",$3);YYERROR;}
	    if (c->ValidP == TRUE)
	    {yyerror1("Redeclaration!",$3);YYERROR;}
	    if ($5 == 1) c->Leg1 = $6;
	    else c->Leg2 = $6;
	    if ($8 == 1) c->Leg1 = $9;
	    else c->Leg2 = $9;
	    c->Length = $10;
	    c->Speed = $12;
	    c->ValidP = TRUE;
	   }
	;

segvector : '[' segvector1 ']'

segvector1 :
	   | segvector1 segment		{if (!InsertSegment($2))
					 {yyerror("Too many segment elements");YYERROR;}
	   				}
	   ;


deftable : define TABLE SYMBOL POINTS INTEGER
						SEGMENTS INTEGER
							{AllocTempVector($7);}
							segvector 
						INTEGER ':' INTEGER 
						STRING STRING
	{if ($5 <= 0) {yyerror1("Must have at least one point",$3);YYERROR;}
	 if ($7 <= 0) {yyerror1("Must have at least one segment",$3);YYERROR;}
	 if ($7 != tempVectorIndex) {yyerror1("Segment vector length mismatch",$3);YYERROR;}
	 TableClass *t = FINDTABLE($3);
         if (t->Tag() != Class::TableMenu)
	 {yyerror1("Redeclaration to new type!",$3);YYERROR;}
	 if (t->ValidP == TRUE)
	 {yyerror1("Redeclaration!",$3);YYERROR;}
	 t->numberofpoints = $5;
	 t->AllocateSegments($7,tempVector);
	 t->Length = $10;
	 t->Speed = $12;
	 t->ReadStateScript = $13;
	 t->ActuateScript = $14;
	 t->ValidP = TRUE;
	}
	;

class : CLASS SYMBOL {SETCLASS($2);} ;

define : DEFINE {if (!CHECKCLASS()) {yyerror("DEFINE before first CLASS");YYERROR;}} ;

%%

static char rcsid[] = "$Id$";


struct WordId {
	char *w;
	int  Id;
};

static void BuildReservedWordsTable(WordId words[],int numWords,Tcl_HashTable *table)
{
	Tcl_InitHashTable(table,TCL_STRING_KEYS);
	for (int i=0;i<numWords;i++)
	{
		int newEntry;
		Tcl_HashEntry *entry = Tcl_CreateHashEntry(table,words[i].w,&newEntry);
		if (!newEntry)
		{
			cerr << "Opps: duplicate word: " << words[i].w << endl;
		}
		Tcl_SetHashValue(entry,(ClientData)words[i].Id);
	}
}

int MRRClassFile::yylex()
{
	static WordId reserved_words[] = {
		{"set", SET},
		{"scale", SCALE},
		{"class", CLASS},
		{"inches", INCHES},
		{"feet", FEET},
		{"yards", YARDS},
		{"meters", METERS},
		{"milimeters", MILIMETERS},
		{"centimeters", CENTIMETERS},
		{"ho", HO},
		{"n", N},
		{"i", I},
		{"o", O},
		{"g", G},
		{"define", DEFINE},
		{"turnout", TURNOUT},
		{"cross", CROSS},
		{"table", TABLE},
		{"segment", SEGMENT},
		{"main", MAIN},
		{"divergence", DIVERGENCE},
		{"none", NONE},
		{"empty", EMPTY},
		{"leg", LEG},
		{"points", POINTS},
		{"segments", SEGMENTS},
		};
									
	static const number_reserved = (sizeof(reserved_words) /
					sizeof(reserved_words[0]));
	static bool table_inited = FALSE;
	static Tcl_HashTable ReservedWordTable;

	static char word[256];
	if (!table_inited)
	{
		BuildReservedWordsTable(reserved_words,number_reserved,
					&ReservedWordTable);
		table_inited = TRUE;
	}

newline:
	if (lp == NULL || *lp == '\0')
	{
		lp = fgets(line_buffer,buffersize,fp);
		if (lp == NULL) return(YYEOF);
		else source_line++;
	}
	while (*lp != '\0' && *lp <= ' ') lp++;
	if (*lp == '\0') goto newline;
	if (*lp == '%') {*lp = '\0'; goto newline;}
	yylloc.first_line = source_line;
	yylloc.first_column = lp - line_buffer;
	yylloc.text = line_buffer;
	yylloc.last_line = source_line;
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
		yylloc.last_column = lp - line_buffer;
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
		while (isalpha(*lp) || *lp == '$' || *lp == '.' ||
			*lp == '_' || isdigit(*lp))
		{
			char c = *lp++;
			if (isupper(c)) c = tolower(c);
			*p++ = c;
		}
		*p = '\0';
		Tcl_HashEntry *entry = Tcl_FindHashEntry(&ReservedWordTable,
							 word);
		if (entry != NULL)
		{
			return ((int)Tcl_GetHashValue(entry));
		}
		yylval.sval = new char[strlen(word)+1];
		strcpy(yylval.sval,word);
		yylloc.last_column = lp - line_buffer;
		return(SYMBOL);
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

void MRRClassFile::yyerror(char *message)
{
	if (source_file == "")
		*errorstream << message << endl;
	else
	{
		*errorstream << source_file << ":" << source_line;
		if (yylloc.first_line == yylloc.last_line)
		{
			*errorstream << " at token '";
			for (char *s = yylloc.text+yylloc.first_column;s < yylloc.text+yylloc.last_column;s++)
				*errorstream << *s;
			*errorstream << "'";
		} else
		{
			*errorstream << " between lines " << yylloc.first_line
					<< " and " << yylloc.last_line ;
		}
		*errorstream << ": " << message << endl;
	}
}

void MRRClassFile::yyerror1(char *message,char *s)
{
	if (source_file == "")
		*errorstream << message << endl;
	else
	{
		*errorstream << source_file << ":" << source_line;
		*errorstream << " in object '" << s << "'";
		*errorstream << ": " << message << endl;
	}
}

void MRRClassFile::AllocTempVector(int newSize)
{
	if (tempVectorSize < newSize)
	{
		if (tempVector != NULL) delete tempVector;
		tempVector = new Segment*[newSize];
		tempVectorSize = newSize;
	}
	tempVectorIndex = 0;
}

bool MRRClassFile::InsertSegment(Segment *newSeg)
{
	if (tempVectorIndex < tempVectorSize)
	{
		tempVector[tempVectorIndex++] = newSeg;
		return TRUE;
	} else return FALSE;
}



