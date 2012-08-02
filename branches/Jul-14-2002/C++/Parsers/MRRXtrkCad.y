%header{
#include <stdio.h>
#include <iostream.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ParseFile.h>
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
			 /*YY_MRRLayoutFile_DEBUG_FLAG = 1;*/
%define MEMBERS virtual ~MRRXtrkCad() {}\
		private:\
		int lookup_word(const char *word) const;\
		void yyerror1(const char *message,const char *s) const;\
		bool scanEol; \
		int fieldflag;\
		double CurrentScale;\
		Table *FINDTABLE(const char * name) \
			{return trees->lookuptable(name);}\
		Turnout *FINDTURNOUT(const char * name) \
			{return trees->lookupturnout(name);}\
		Block *FINDBLOCK(const char * name) \
			{return trees->lookupblock(name);}\
		Signal *FINDSIGNAL(const char * name) \
			{return trees->lookupsignal(name);}\
		Cross *FINDCROSS(const char * name) \
			{return trees->lookupcross(name);}\
		NonROW *FINDNONROW(const char * name) \
			{return trees->lookupnonrow(name);}\
		void SETTREE(const char * name) \
			{(void)trees->SelectCurrentTree(name);}

%define LSP_NEEDED 1


%define ERROR_VERBOSE
%define DEBUG 1

%union {
	int ival;
	char *sval;
	float fval;
}

/* Value tokens */
%token <ival> INTEGER
%token <fval> FLOAT
%token <sval> STRING
%token <sval> RESTOFLINE
/* End of line token */
%token EOL
/* Special Error tokens */
%token        UNTERMSTRING NOTWORD
/* Reserved words */
%token END 
%token VERSION TITLE MAPSCALE ROOMSIZE SCALE HO N O LAYERS CURRENT
%token STRUCTURE D L DRAW F CURVE T E G A TURNOUT STRAIGHT P S C CAR X

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
	   | car
	   | EOL
	   ;

version : VERSION INTEGER FLOAT '.' INTEGER EOL
	{if ($3 != 3.0) {
		yyerror("Can only handle Version 3.0.x XTrkCad files!");YYERROR;
	}} ;
	
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
              | F INTEGER INTEGER FLOAT INTEGER EOL fblock
	      | A INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT INTEGER FLOAT FLOAT
		  EOL
	      | G INTEGER INTEGER FLOAT FLOAT FLOAT FLOAT INTEGER EOL
	      ;
fblock : 
       | fblock1 fblock 
       ;

fblock1 : FLOAT FLOAT INTEGER EOL;	      
	      
	

draw : DRAW INTEGER INTEGER INTEGER INTEGER INTEGER FLOAT FLOAT INTEGER FLOAT
	    EOL structbody END EOL;

curve : CURVE INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER FLOAT
	      FLOAT INTEGER FLOAT INTEGER FLOAT FLOAT EOL trackbody END EOL;

trackbody : 
          | trackbodyelt trackbody
          ;

trackbodyelt : T INTEGER FLOAT FLOAT FLOAT trackbodyelt1 EOL
	     | E FLOAT FLOAT FLOAT trackbodyelt1 EOL
	     ;

trackbodyelt1 :
	      | INTEGER FLOAT FLOAT FLOAT
	      ;

straight : STRAIGHT INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER
		    EOL trackbody END EOL;

turnout : TURNOUT INTEGER INTEGER INTEGER INTEGER INTEGER scalename INTEGER
		  FLOAT FLOAT INTEGER FLOAT STRING EOL turnoutbody END EOL;

turnoutbody : 
	    | turnoutbodyelt turnoutbody 
	    ;

turnoutbodyelt : trackbodyelt
	       | D FLOAT FLOAT EOL
	       | P STRING intlist EOL
	       | S INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT EOL
	       | C INTEGER FLOAT FLOAT FLOAT FLOAT FLOAT FLOAT EOL
	       ;

intlist :
	| intlist INTEGER
	;
	
car : CAR INTEGER scalename STRING INTEGER INTEGER FLOAT FLOAT INTEGER
	  INTEGER FLOAT FLOAT INTEGER FLOAT FLOAT INTEGER INTEGER INTEGER 
	  INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER INTEGER 
	  FLOAT FLOAT FLOAT EOL trackbody END EOL;

%%

static char rcsid[] = "$Id$";


int MRRXtrkCad::lookup_word(const char *word) const
{
	static const struct {
		const char *w;
		int id;
	} reserved_words[] = {
		{"A", A},
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
		{"L", L},
		{"LAYERS", LAYERS },
		{"MAPSCALE", MAPSCALE},
		{"N", N },
		{"O", O},
		{"P", P},
		{"ROOMSIZE", ROOMSIZE},
		{"S", S},
		{"SCALE", SCALE},
		{"STRAIGHT", STRAIGHT},
		{"STRUCTURE", STRUCTURE},
		{"T", T},
		{"TITLE", TITLE},
		{"TURNOUT", TURNOUT},
		{"VERSION", VERSION},
		{"X", X} };
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

