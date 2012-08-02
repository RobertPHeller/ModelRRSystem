/* 
 * ------------------------------------------------------------------
 * raildriver.h - Documentation for the raildriver parser (this file is not actually included)
 * Created by Robert Heller on Sat Feb  5 13:07:33 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2005/11/14 20:28:45  heller
 * Modification History: Nov 14, 2005 Lockdown
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

/**   Rain Driver Parser Class.
  \Label{Class:RaildriverParser}
  \TEX{\typeout{Generated from $Id$.}}
  Rail Driver Thread command parser.
    */
    
class RaildriverParser : public RD_Threads
{
	///  Parser Tokens.
	enum yy_RaildriverParser_enum_token {
		///  NULL Token.
		YY_RaildriverParser_NULL_TOKEN=0,
		/**   LED Digits token. */ 
		LEDDIGITS=258,
		/**   Bad Symbol Token. */ 
		BADSYMBOL=259,
		/**   Exit Token. */ 
		EXIT=260,
		/**   Clear (mask) Token. */ 
		CLEAR=261,
		/**   (Add) Mask Token. */ 
		MASK=262,
		/**   LED Token. */ 
		LED=263,
		/**   Reverser Token. */ 
		REVERSER=264,
		/**   Throttle Token. */ 
		THROTTLE=265,
		/**   Autobrake Token. */ 
		AUTOBRAKE=266,
		/**   Independbrk Token. */ 
		INDEPENDBRK=267,
		/**   Bailoff Token. */ 
		BAILOFF=268,
		/**   Headlight Token. */ 
		HEADLIGHT=269,
		/**   Wiper Token. */ 
		WIPER=270,
		/**   Digital1 Token. */ 
		DIGITAL1=271,
		/**   Digital2 Token. */ 
		DIGITAL2=272,
		/**   Digital3 Token. */ 
		DIGITAL3=273,
		/**   Digital4 Token. */ 
		DIGITAL4=274,
		/**   Digital5 Token. */ 
		DIGITAL5=275,
		/**   Digital6 Token. */ 
		DIGITAL6=276,
		/**   Speaker Token. */ 
		SPEAKER=277,
		/**   On Token. */ 
		ON=278,
		/**   Off Token. */ 
		OFF=279,
		/**   Pollvalues Token. */ 
		POLLVALUES=280
	};
public:
  ///  Parser function.
  int yyparse ();
  ///  Parse error function.
  virtual void yyerror(char *msg);
  ///  Lexical analyizer function.
  virtual int yylex();
  ///  Error count.
  int yynerrs;
  ///  Current character.
  int yychar;
  ///  Debug Flag.
  int yydebug;
  ///  Constructor.
  RaildriverParser(int sock, struct sockaddr_in *sockaddr);
  ///  Reset parse buffer pointer.
  void ResetPtr(char *buffer);
private:
  ///  Auxilary error function.
  void yyerror1(char *message,char *s);
  ///  Parse buffer pointer.
  char *currentPos;
  ///  Word buffer.
  char word[4096];
};

			

