/* 
 * ------------------------------------------------------------------
 * MRRLayoutFile.y - MRR System Layout file parser
 * Created by Robert Heller on Sun Aug  6 14:52:37 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.6  2000/11/10 00:25:42  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Revision 2.5  1995/09/17  21:05:33  heller
 * Add in support for checkword
 * Add in NonROW's depth info (ZMin, ZMax, and Transparency)
 *
 * Revision 2.4  1995/09/12  02:43:56  heller
 * Fix constants (share them with MRRClassFile)
 * Update semantic error messages.
 * Add "EMPTY" NextElement
 *
 * Revision 2.3  1995/09/09  22:53:53  heller
 * Complete parser (lots of code!)
 *
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
#include <Tree.h>
#include <Turnout.h>
#include <Block.h>
#include <Signal.h>
#include <Cross.h>
#include <Table.h>
#include <NonROW.h>
#include <tcl.h>
#include <MRRSigExpr.tab.h>

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

%start file

%name MRRLayoutFile
%define LSP_NEEDED 1
%define CLASS MRRLayoutFile
%define INHERIT : public LayoutFile
%define CONSTRUCTOR_PARAM string filename
%define CONSTRUCTOR_INIT : LayoutFile (filename,this)
%define CONSTRUCTOR_CODE hasHandle = FALSE; CurrentScale = 1.0;\
			 tempVector = NULL;tempVectorSize=0;tempXs = tempYs = NULL;tempXYsize = 0;\
			 /*YY_MRRLayoutFile_DEBUG_FLAG = 1;*/
%define MEMBERS virtual ~MRRLayoutFile() {if (tempVector != NULL) delete tempVector;\
					  if (tempXs != NULL) delete tempXs;\
					  if (tempYs != NULL) delete tempYs;}\
		friend int MRRParseFile_Init(Tcl_Interp *interp);\
		int Handlize(Tcl_Interp *interp);\
		int MyHandle(Tcl_Interp *interp,char *handlebuffer);\
		int TclFunction(Tcl_Interp *interp,int argc, char *argv[]);\
		private:\
		static bool table_inited;\
		static Tcl_HashTable ReservedWordTable;\
		void init_table();\
		bool check_word(char *word);\
		void yyerror1(char *message,char *s);\
		int fieldflag;\
		double CurrentScale;\
		static void_pt Handles;\
		bool hasHandle;\
		Table *FINDTABLE(string name) {return trees->lookuptable(name);}\
		Turnout *FINDTURNOUT(string name) {return trees->lookupturnout(name);}\
		Block *FINDBLOCK(string name) {return trees->lookupblock(name);}\
		Signal *FINDSIGNAL(string name) {return trees->lookupsignal(name);}\
		Cross *FINDCROSS(string name) {return trees->lookupcross(name);}\
		NonROW *FINDNONROW(string name) {return trees->lookupnonrow(name);}\
		void SETTREE(string name) {(void)trees->SelectCurrentTree(name);}\
		void backpointers(Segment *list);\
		Segment **tempVector;\
		int tempVectorSize,tempVectorIndex;\
		void AllocTempVector(int newSize);\
		bool InsertSegment(Segment *newSeg);\
		int tempXYsize,tempXindex,tempYindex; double *tempXs, *tempYs;\
		void AllocTempXY(int newSize);\
		bool InsertTempXY(double XY);\
		bool doX;

%define ERROR_VERBOSE
%define DEBUG 1

%union {
	int ival;
	char *sval;
	float fval;
	Segment *sgval;
	NextElement *nxval;
	AspectList *aspval;
	Expr *exprval;
	GrObject *grval;
	NonROW::TransparencyType ttval;
}


%token <ival> INTEGER
%token <ival> HEXNUMBER
%token <sval> SYMBOL
%token <sval> ELEMENTNAME
%token <fval> FLOAT
%token <sval> STRING
%token        UNTERMSTRING BADSYMBOL

%type <nxval> next
%type <fval> distance number unitfactor units scale scalefactor angle
%type <ival> onetwo
%type <sgval> seglist segment segments
%type <sval> ename
%type <aspval> headspecs headspec
%type <ival> aspectcolor
%type <exprval> expression
%type <grval> grobject rectangle oval text polygon
%type <ttval> transparency

%token SET SIZE MINX MINY MAXX MAXY SCALE INCHES FEET YARDS METERS MILIMETERS
%token CENTIMETERS HO N I O G

%token MAXMOUNTGRADE MAXNORMGRADE MAXFLYGRADE MINRADIUS MINEASEMENT MINTFROG
%token MINXOFROG MINLADFROG MINTANTRACKCENTERS MINCURVTRACKCENTERS
%token MINSCSTRAIGHT MINVCLEAR NORMVCLEAR STANDARDS USE TREE

%token DEFINE TURNOUT BLOCK CROSS TABLE SIGNAL NONROW SEGMENT MAIN DIVERGENCE
%token NONE EMPTY ADDRESS LEG POINTS SEGMENTS HEADS RED GREEN YELLOW

%token POLYGON TEXT OVAL RECTANGLE

%token OPAQUE TRANSLUCENT TRANSPARENT

%token AND OR NOT POINT

%%

file : {CurrentScale = 1.0;} file1;

file1 :
      | file1 definition
      ;

definition : setsize
	   | defsignal
	   | setscale
	   | setstandards
	   | usetree
	   | defturnout
	   | defblock
	   | defcross
	   | deftable
	   | defnonrow
	   ;


setsize : SET SIZE {fieldflag = 0;} ss1 ss1 ss1 ss1;

ss1 : MINX distance {if ((fieldflag & 0x01) != 0)
			{yyerror("duplicate MINX in SET SIZE");
					YYERROR;}
		   MinX = $2; fieldflag |= 0x01;}
    | MINY distance {if ((fieldflag & 0x02) != 0)
			{yyerror("duplicate MINY in SET SIZE");
					YYERROR;}
		   MinY = $2; fieldflag |= 0x02;}
    | MAXX distance {if ((fieldflag & 0x04) != 0)
			{yyerror("duplicate MAXX in SET SIZE");
					YYERROR;}
		   MaxX = $2; fieldflag |= 0x04;}
    | MAXY distance {if ((fieldflag & 0x08) != 0)
			{yyerror("duplicate MAXY in SET SIZE");
					YYERROR;}
		   MaxY = $2; fieldflag |= 0x08;}
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

setstandards : SET STANDARDS {fieldflag = 0;} ss2s;

ss2s : ss2s ss2
     | ss2
     ;

ss2 : MAXMOUNTGRADE number {if ((fieldflag & 0x01) != 0)
				{yyerror("duplicate MAXMOUNTGRADE in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.maxMountGrade = $2;
			    else trees->CurrentTree()->Standards.maxMountGrade = $2;
			    fieldflag |= 0x01;
			   }
    | MAXNORMGRADE number {if ((fieldflag & 0x02) != 0)
				{yyerror("duplicate MAXNORMGRADE in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.maxNormGrade = $2;
			    else trees->CurrentTree()->Standards.maxNormGrade = $2;
			    fieldflag |= 0x02;
			   }
    | MAXFLYGRADE number {if ((fieldflag & 0x04) != 0)
				{yyerror("duplicate MAXFLYGRADE in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.maxFlyGrade = $2;
			    else trees->CurrentTree()->Standards.maxFlyGrade = $2;
			    fieldflag |= 0x04;
			   }
    | MINRADIUS distance {if ((fieldflag & 0x08) != 0)
				{yyerror("duplicate MINRADIUS in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minRadius = $2;
			    else trees->CurrentTree()->Standards.minRadius = $2;
			    fieldflag |= 0x08;
			   }
    | MINEASEMENT distance {if ((fieldflag & 0x10) != 0)
				{yyerror("duplicate MINEASEMENT in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minEasement = $2;
			    else trees->CurrentTree()->Standards.minEasement = $2;
			    fieldflag |= 0x10;
			   }
    | MINTFROG number {if ((fieldflag & 0x20) != 0)
				{yyerror("duplicate MINTFROG in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minTFrog = $2;
			    else trees->CurrentTree()->Standards.minTFrog = $2;
			    fieldflag |= 0x20;
			   }
    | MINXOFROG number {if ((fieldflag & 0x40) != 0)
				{yyerror("duplicate MINXOFROG in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minXOFrog = $2;
			    else trees->CurrentTree()->Standards.minXOFrog = $2;
			    fieldflag |= 0x40;
			   }
    | MINLADFROG number {if ((fieldflag & 0x080) != 0)
				{yyerror("duplicate MINLADFROG in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minLadFrog = $2;
			    else trees->CurrentTree()->Standards.minLadFrog = $2;
			    fieldflag |= 0x080;
			   }
    | MINTANTRACKCENTERS distance {if ((fieldflag & 0x100) != 0)
				{yyerror("duplicate MINTANTRACKCENTERS in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minTanTrackCenters = $2;
			    else trees->CurrentTree()->Standards.minTanTrackCenters = $2;
			    fieldflag |= 0x100;
			   }
    | MINCURVTRACKCENTERS distance {if ((fieldflag & 0x200) != 0)
				{yyerror("duplicate MINCURVTRACKCENTERS in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minCurvTrackCenters = $2;
			    else trees->CurrentTree()->Standards.minCurvTrackCenters = $2;
			    fieldflag |= 0x200;
			   }
    | MINSCSTRAIGHT distance {if ((fieldflag & 0x400) != 0)
				{yyerror("duplicate MINSCSTRAIGHT in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minSCStraight = $2;
			    else trees->CurrentTree()->Standards.minSCStraight = $2;
			    fieldflag |= 0x400;
			   }
    | MINVCLEAR distance {if ((fieldflag & 0x0800) != 0)
				{yyerror("duplicate MINVCLEAR in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.minVClear = $2;
			    else trees->CurrentTree()->Standards.minVClear = $2;
			    fieldflag |= 0x0800;
			   }
    | NORMVCLEAR distance {if ((fieldflag & 0x1000) != 0)
				{yyerror("duplicate NORMVCLEAR in SET STANDARDS");
				 YYERROR;}
			    if (trees->CurrentTree() == NULL) trees->Standards.normVClear = $2;
			    else trees->CurrentTree()->Standards.normVClear = $2;
			    fieldflag |= 0x1000;
			   }

usetree : USE TREE SYMBOL {SETTREE($3);}

onetwo : INTEGER	{if ($1 == 1 || $1 == 2) $$ = $1;
			 else {yyerror("expected a 1 or a 2");YYERROR;}
			}

ename : ELEMENTNAME		{ $$ = $1;}
      | SYMBOL			{ $$ = $1;}
      ;

next : TURNOUT ename	{ $$ = new NextElement(FINDTURNOUT($2)); }
     | BLOCK   ename    { $$ = new NextElement(FINDBLOCK($2)); }
     | CROSS   ename    { $$ = new NextElement(FINDCROSS($2)); }
     | TABLE   ename    { $$ = new NextElement(FINDTABLE($2)); }
     | NONE		{ $$ = new NextElement();}
     | EMPTY		{ $$ = NULL;}
     |			{ $$ = NULL;}
     ;


angle : number {double x = RADIANS($1); if (x < 0 || x >= (M_PI * 2))
					{yyerror("Angle too large");YYERROR;}
		$$ = x;}
      ;

segment : '{' distance distance distance next distance distance distance next angle '}'
		{$$ = new Segment($2,$3,$4,$5,$6,$7,$8,$9,$10);}
	;		

seglist : '{' segments '}' 	{if ($2 == NULL)
					 {yyerror("Blocks must have at least 1 segment");
					  YYERROR;
					 }
					 $$ = $2;backpointers($2);}
	;

segments : 			{$$ = NULL;}
	| segment segments  	{if ($2 != NULL) $1->N2 = new NextElement($2);
				 $$ = $1;}
	;



defblock : DEFINE BLOCK ename ADDRESS HEXNUMBER SEGMENT seglist INTEGER ':' INTEGER STRING STRING 
	{Block* b = FINDBLOCK($3);
	 b->Address = $5;
	 b->SegList = $7;
	 b->Length = $8;
	 b->Speed = $10;
	 b->OccupiedScript = $11;
	 b->SelectCabScript = $12;
	 b->ValidP = TRUE;
	}
	;

defturnout : DEFINE TURNOUT ename ADDRESS HEXNUMBER MAIN segment
						    DIVERGENCE segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {Turnout* t = FINDTURNOUT($3);
	      t->Address = $5;
	      t->Main1 = $7;
	      t->D1 = $9;
	      t->Length = $10;
	      t->MainSpeed = $12;
	      t->DivergenceSpeed = $14;
	      t->ReadStateScript = $15;
	      t->ActuateScript = $16;
	      t->ValidP = TRUE;
	     }
	   | DEFINE TURNOUT ename ADDRESS HEXNUMBER MAIN segment
						    DIVERGENCE onetwo segment 
						    DIVERGENCE onetwo segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {if ($9 == $12)
	      {yyerror1("Need two different DIVERGENCE segments",$3);YYERROR;}
	      Turnout* t = FINDTURNOUT($3);
	      if (t->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
	      t->Address = $5;
	      t->Main1 = $7;
	      if ($9 == 1) t->D1 = $10;
	      else t->D2 = $10;
	      if ($12 == 1) t->D1 = $13;
	      else t->D2 = $13;
	      t->Length = $14;
	      t->MainSpeed = $16;
	      t->DivergenceSpeed = $18;
	      t->ReadStateScript = $19;
	      t->ActuateScript = $20;
	      t->ValidP = TRUE;
	     }
	   | DEFINE TURNOUT ename ADDRESS HEXNUMBER MAIN onetwo segment
						    MAIN onetwo segment 
						    DIVERGENCE onetwo segment 
						    DIVERGENCE onetwo segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {if ($7 == $10)
	      {yyerror1("Need two different MAIN segments",$3);YYERROR;}
	      if ($13 == $16)
	      {yyerror1("Need two different DIVERGENCE segments",$3);YYERROR;}
	      Turnout* t = FINDTURNOUT($3);
	      if (t->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
	      t->Address = $5;
	      if ($7 == 1) t->Main1 = $8;
	      else t->Main2 = $8;
	      if ($10 == 1) t->Main1 = $11;
	      else t->Main2 = $11;
	      if ($13 == 1) t->D1 = $14;
	      else t->D2 = $14;
	      if ($16 == 1) t->D1 = $17;
	      else t->D2 = $17;
	      t->Length = $18;
	      t->MainSpeed = $20;
	      t->DivergenceSpeed = $22;
	      t->ReadStateScript = $23;
	      t->ActuateScript = $24;
	      t->ValidP = TRUE;
	     }
	      
	   | DEFINE TURNOUT ename ADDRESS HEXNUMBER MAIN onetwo segment
						    MAIN onetwo segment 
						    DIVERGENCE  segment 
						    INTEGER ':' INTEGER ',' 
						    INTEGER STRING STRING
	     {if ($7 == $10)
	      {yyerror1("Need two different MAIN segments",$3);YYERROR;}
	      Turnout* t = FINDTURNOUT($3);
	      if (t->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
	      t->Address = $5;
	      if ($7 == 1) t->Main1 = $8;
	      else t->Main2 = $8;
	      if ($10 == 1) t->Main1 = $11;
	      else t->Main2 = $11;
	      t->D1 = $13;
	      t->Length = $14;
	      t->MainSpeed = $16;
	      t->DivergenceSpeed = $18;
	      t->ReadStateScript = $19;
	      t->ActuateScript = $20;
	      t->ValidP = TRUE;
	     }
	   ;

defcross : DEFINE CROSS ename LEG onetwo segment LEG onetwo segment
			INTEGER ':' INTEGER
	   {if ($5 == $8)
	    {yyerror1("Need two different LEG segments",$3);YYERROR;}
	    Cross *c = FINDCROSS($3);
	    if (c->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
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


deftable : DEFINE TABLE ename ADDRESS HEXNUMBER POINTS INTEGER
						SEGMENTS INTEGER
							{AllocTempVector($9);}
							segvector 
						INTEGER ':' INTEGER 
						STRING STRING
	{if ($7 <= 0) {yyerror1("Must have at least one point",$3);YYERROR;}
	 if ($9 <= 0) {yyerror1("Must have at least one segment",$3);YYERROR;}
	 if ($9 != tempVectorIndex) {yyerror1("Segment vector length mismatch",$3);YYERROR;}
	 Table *t = FINDTABLE($3);
	 if (t->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
	 t->Address = $5;
	 t->numberofpoints = $7;
	 t->AllocateSegments($9,tempVector);
	 t->Length = $12;
	 t->Speed = $14;
	 t->ReadStateScript = $15;
	 t->ActuateScript = $16;
	 t->ValidP = TRUE;
	}
	;

headspecs : headspec			{$$ = $1;}
	  | headspec  ',' headspecs 	{ $1->next = $3; $$ = $1;}
          ;
	  
headspec : aspectcolor '=' expression
		{ $$ = new AspectList((($1 << Signal::TopShift) |
				     (Signal::BLACK << Signal::MiddleShift) | 
				     Signal::BLACK), $3, NULL); } 
	 | aspectcolor '-' aspectcolor '=' expression
		{ $$ = new AspectList((($1 << Signal::TopShift) |
				     ($3 << Signal::MiddleShift) |
				     Signal::BLACK), $5, NULL); }
	 | aspectcolor '-' aspectcolor '-' aspectcolor '=' expression
		{ $$ = new AspectList((($1 << Signal::TopShift) |
				     ($3 << Signal::MiddleShift) |
				     $5), $7, NULL); }
	 ;

aspectcolor : RED	{ $$ = Signal::RED; }
	    | GREEN	{ $$ = Signal::GREEN; }
	    | YELLOW	{ $$ = Signal::YELLOW; }
	    ;

expression : STRING
		    {MRRSigExpr *temp = new MRRSigExpr($1,trees,errorstream);
		     if (temp->Parse() != 0)
		     {yyerror("Error in head expression");YYERROR;}
		     $$ = temp->ReturnResult();
		     delete temp;
		    }
	   ;

defsignal : DEFINE SIGNAL ename ADDRESS HEXNUMBER
			HEADS INTEGER '<' headspecs '>' STRING
			distance distance distance angle
		{if ($7 < 1 || $7 > 3)
		 {AspectList *nx; for (AspectList *l = $9;l != NULL;l = nx)
		 		  { nx = l->next;delete l; }
		  yyerror1("Bad head count, must be 1, 2, or 3",$3);YYERROR;}
		 if (MRRCheckHeadCount($7,$9) == FALSE)
		 {AspectList *nx; for (AspectList *l = $9;l != NULL;l = nx)
		 		  { nx = l->next;delete l; }
		  yyerror1("Head count mismatch with aspect list",$3);YYERROR;
		 }
		 Signal *s = FINDSIGNAL($3);
		 if (s->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
		 s->Address = $5;
		 s->headcount = $7;
		 s->aspects = $9;
		 s->SetLightScript = $11;
		 s->X = $12; s->Y = $13; s->Z = $14; s->O = $15;
		 s->ValidP = TRUE;
		}
	  ;	 

defnonrow : DEFINE NONROW ename grobject transparency distance distance
		{NonROW *r = FINDNONROW($3);
		 if (r->ValidP == TRUE) {yyerror1("Redeclaration!",$3);YYERROR;}
		 r->Object = $4;
		 r->Transparency = $5;
		 r->ZMin = $6;
		 r->ZMax = $7;
		 r->ValidP = TRUE;
		}
	  ;

transparency : OPAQUE {$$ = NonROW::Opaque;}
	    | TRANSLUCENT {$$ = NonROW::Translucent;}
	    | TRANSPARENT {$$ = NonROW::Transparent;}
	    ;


grobject : rectangle	{$$ = $1;}
	 | oval		{$$ = $1;}
	 | text		{$$ = $1;}
	 | polygon	{$$ = $1;}
	 ;

rectangle : RECTANGLE '(' distance ',' distance ',' distance ',' distance ',' STRING ',' STRING ')'
		{$$ = new GrObject(TRUE,$3,$5,$7,$9,$11,$13);}
	 ;

oval : OVAL '(' distance ',' distance ',' distance ',' distance ',' STRING ',' STRING ')'
		{$$ = new GrObject(FALSE,$3,$5,$7,$9,$11,$13);}
	 ;

text : TEXT '(' distance ',' distance ',' STRING ',' STRING ')'
		{$$ = new GrObject($3,$5,$7,$9);}
	 ;

polygon : POLYGON '(' INTEGER {AllocTempXY($3);doX = TRUE;} ',' dvector ',' {doX = FALSE;} dvector ',' STRING ')'
		{if ($3 != tempXindex || $3 != tempYindex)
		 {yyerror("X or Y vector length mismatch in polygon");YYERROR;}
		 $$ = new GrObject($3,tempXs,tempYs,$11);
		}
	 ;

dvector : '[' dvector1 ']';
dvector1 : distance		{if (!InsertTempXY($1))
				 {yyerror("Too many segment elements");YYERROR;}}
	 | dvector1 ',' distance {if (!InsertTempXY($3))
				  {yyerror("Too many segment elements");YYERROR;}}
	 ;


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


void MRRLayoutFile::init_table()
{
	static WordId reserved_words[] = {
		{"set", SET},
		{"size", SIZE},
		{"minx", MINX},
		{"miny", MINY},
		{"maxx", MAXX},
		{"maxy", MAXY},
		{"scale", SCALE},
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
		{"maxmountgrade", MAXMOUNTGRADE},
		{"maxnormgrade", MAXNORMGRADE},
		{"maxflygrade", MAXFLYGRADE},
		{"minradius", MINRADIUS},
		{"mineasement", MINEASEMENT},
		{"mintfrog", MINTFROG},
		{"minxofrog", MINXOFROG},
		{"minladfrog", MINLADFROG},
		{"mintantrackcenters", MINTANTRACKCENTERS},
		{"mincurvtrackcenters", MINCURVTRACKCENTERS},
		{"minscstraight", MINSCSTRAIGHT},
		{"minvclear", MINVCLEAR},
		{"normvclear", NORMVCLEAR},
		{"standards", STANDARDS},
		{"use", USE},
		{"tree", TREE},
		{"define", DEFINE},
		{"turnout", TURNOUT},
		{"block", BLOCK},
		{"cross", CROSS},
		{"table", TABLE},
		{"signal", SIGNAL},
		{"nonrow", NONROW},
		{"segment", SEGMENT},
		{"main", MAIN},
		{"divergence", DIVERGENCE},
		{"none", NONE},
		{"empty", EMPTY},
		{"address", ADDRESS},
		{"leg", LEG},
		{"points", POINTS},
		{"segments", SEGMENTS},
		{"heads", HEADS},
		{"red", RED},
		{"green", GREEN},
		{"yellow", YELLOW},
		{"rectangle", RECTANGLE},
		{"oval", OVAL},
		{"text", TEXT},
		{"polygon", POLYGON},
		{"opaque", OPAQUE},
		{"translucent", TRANSLUCENT},
		{"transparent", TRANSPARENT},
		{"and", AND},
		{"or", OR},
		{"not", NOT},
		{"point", POINT},
	};

	static const number_reserved = (sizeof(reserved_words) /
					sizeof(reserved_words[0]));

	if (!table_inited)
	{
		BuildReservedWordsTable(reserved_words,number_reserved,
					&ReservedWordTable);
		table_inited = TRUE;
	}
}

bool MRRLayoutFile::check_word(char *word)
{
	init_table();

	char *lp = word;
	if (!isalpha(*lp)) return FALSE;
	int colonsSeen = 0;
	bool prevWasColon = FALSE;
	static char tmpword[4096];
	char *p = tmpword;
	while (isalpha(*lp) || *lp == '$' || *lp == '.' ||
		*lp == '_' || isdigit(*lp) ||
		ColonOk(colonsSeen,prevWasColon,*lp))
	{
		char c = *lp++;
		if (isupper(c)) c = tolower(c);
		*p++ = c;
		if (c != ':') prevWasColon = FALSE;
	}
	if (*lp != '\0') return FALSE;
	*p = '\0';
	p = tmpword;
	if (colonsSeen == 1) return FALSE;
	else if (colonsSeen == 2)
	{
		p = strrchr(tmpword,':') + 1;
	}
	Tcl_HashEntry *entry = Tcl_FindHashEntry(&ReservedWordTable,p);
	
	if (entry != NULL) return FALSE;
	if (colonsSeen > 0)
	{
		p = tmpword;
		lp = strchr(tmpword,':');
		*lp = '\0';
		entry = Tcl_FindHashEntry(&ReservedWordTable,p);
		if (entry != NULL) return FALSE;
	}
	return TRUE;
}


int MRRLayoutFile::yylex()
{
	static char word[4096];

	init_table();

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
		if (colonsSeen == 1) return(BADSYMBOL);
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
		if (colonsSeen > 0) return(ELEMENTNAME);
		else return(SYMBOL);
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

void MRRLayoutFile::yyerror(char *message)
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

void MRRLayoutFile::yyerror1(char *message,char *s)
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

void MRRLayoutFile::backpointers(Segment *list)
{
	Segment *s;
	for (s = list;s->N2->NextSegment() != NULL;s = s->N2->NextSegment())
	{
		Segment *n2 = s->N2->NextSegment();
		if (n2 != NULL) n2->N1 = new NextElement(s);
	}
}


void MRRLayoutFile::AllocTempVector(int newSize)
{
	if (tempVectorSize < newSize)
	{
		if (tempVector != NULL) delete tempVector;
		tempVector = new Segment*[newSize];
		tempVectorSize = newSize;
	}
	tempVectorIndex = 0;
}

bool MRRLayoutFile::InsertSegment(Segment *newSeg)
{
	if (tempVectorIndex < tempVectorSize)
	{
		tempVector[tempVectorIndex++] = newSeg;
		return TRUE;
	} else return FALSE;
}

void MRRLayoutFile::AllocTempXY(int newSize)
{
	if (tempXYsize < newSize)
	{
		if (tempXs != NULL) delete tempXs;
		if (tempYs != NULL) delete tempYs;
		tempXs = new double[newSize];
		tempYs = new double[newSize];
		tempXYsize = newSize;
	}
	tempYindex = tempXindex = 0;
}

bool MRRLayoutFile::InsertTempXY(double XY)
{
	if (doX)
	{
		if (tempXindex < tempXYsize)
		{
			tempXs[tempXindex++] = XY;
			return TRUE;
		} return FALSE;
	} else
	{
		if (tempYindex < tempXYsize)
		{
			tempYs[tempYindex++] = XY;
			return TRUE;
		} return FALSE;
	}
}

bool MRRLayoutFile::table_inited = FALSE;
Tcl_HashTable MRRLayoutFile::ReservedWordTable;

