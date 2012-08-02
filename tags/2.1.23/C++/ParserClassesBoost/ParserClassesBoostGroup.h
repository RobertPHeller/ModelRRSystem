/* 
 * ------------------------------------------------------------------
 * Begin.h - Beginning of internals documentation.
 * Created by Robert Heller on Sun Nov  6 11:06:11 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.1  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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
 * $Id: Begin.h 483 2007-04-19 17:23:25Z heller $
 *  
 */

/** @defgroup ParserClassesBoost ParserClassesBoost
  * @brief File-based parser classes (Boost version).
  *
  * These are file-based parser classes.  Right now only one parser for XTrkCAD
  * layout files.  Other classes might be added later.
  *
  * Included are classes used by the XTrkCAD parser.  These classes are used to
  * store the track plan information in an XTrkCAD layout file, specificly
  * as it relates to operating issues, such as dispatching and signaling.
  *
  * The track plan is loaded into a directed graph representation, where each
  * node is one logical piece of trackwork.  From this graph representation
  * a schematic display could be created in a semi-automated way.
  *
  * This version features the use of the Boost Graph Library as the underlying
  * structure for the track graph built from reading in XTrkCAD layout files.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */

/** @brief File-based parser classes (Boost version).
  *
  * These are file-based parser classes.  Right now only one parser for XTrkCAD
  * layout files.  Other classes might be added later.
  *
  * Included are classes used by the XTrkCAD parser.  These classes are used to
  * store the track plan information in an XTrkCAD layout file, specificly
  * as it relates to operating issues, such as dispatching and signaling.
  *
  * The track plan is loaded into a directed graph representation, where each
  * node is one logical piece of trackwork.  From this graph representation
  * a schematic display could be created in a semi-automated way.
  *
  * This version features the use of the Boost Graph Library as the underlying
  * structure for the track graph built from reading in XTrkCAD layout files.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */

namespace Parsers {

/** MRRXtrkCad parser class.
  *
  * Include MRRXtrkCad.tab.h to get this class (the docs are wrong).
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  */

class MRRXtrkCad : public LayoutFile
{
public:

enum YY_MRRXtrkCad_ENUM_TOKEN { YY_MRRXtrkCad_NULL_TOKEN=0

 ,INTEGER=258
 ,FLOAT=259
 ,STRING=260
 ,RESTOFLINE=261
 ,MULTILINE=262
 ,EOL=263
 ,UNTERMSTRING=264
 ,NOTWORD=265
 ,END=266
 ,_VERSION=267
 ,TITLE=268
 ,MAPSCALE=269
 ,ROOMSIZE=270
 ,SCALE=271
 ,HO=272
 ,N=273
 ,O=274
 ,LAYERS=275
 ,CURRENT=276
 ,STRUCTURE=277
 ,DRAW=278
 ,CURVE=279
 ,TURNOUT=280
 ,TURNTABLE=281
 ,STRAIGHT=282
 ,CAR=283
 ,JOINT=284
 ,NOTE=285
 ,TEXT=286
 ,MAIN=287
 ,B=288
 ,J=289
 ,D=290
 ,L=291
 ,M=292
 ,F=293
 ,T=294
 ,E=295
 ,G=296
 ,A=297
 ,P=298
 ,S=299
 ,C=300
 ,X=301
 ,Y=302
 ,Q=303
 ,BLOCK=304
 ,TRK=305
 ,SWITCHMOTOR=306

     };

public:
 int yyparse(void);
 virtual void yyerror(char *msg) ;







 virtual int yylex() ;
 yy_MRRXtrkCad_stype yylval;

 yyltype yylloc;

 int yynerrs;
 int yychar;


public:
 int yydebug;

public:
 /** @brief The constructor function.
   *
   * The constructor is the only function that is directly called from user
   * code.  See LayoutFile for all other access methods.
   */
 MRRXtrkCad(const char * filename);
public:
 virtual ~MRRXtrkCad() {} private: int lookup_word(const char *word) const; void yyerror1(const char *message,const char *s) const; bool scanEol,scanToEND; int fieldflag; double CurrentScale;
};

};	

