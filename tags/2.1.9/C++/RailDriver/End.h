/* 
 * ------------------------------------------------------------------
 * End.h - End of Rail Driver section
 * Created by Robert Heller on Sun Nov  6 11:12:48 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2005/11/14 20:28:45  heller
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
 * 
 *  
 */

/** @name yy_RaildriverParser_stype
  * Parser stack type union -- the various sorts of things that can live on
  * the token stack.
  */
typedef union {
	/** Integers.
	  */
	int ival;
	/** Strings (for the LED display).
	  */
	char *sval;
	/** Eventmask bits.
	  */
	RaildriverIO::Eventmask_bits eval;
} yy_RaildriverParser_stype;

 
/** RaildriverParser parses commands sent to the daemon from client connections.
  * The following commands are supported (all reserved words are case
  * insensitive):
  *
  * EXIT
  *
  * Closes the connection to the server daemon.
  *
  * CLEAR
  *
  * Clears the event mask.  No input events are reported.
  *
  * MASK maskbitnames
  *
  * Adds input events to report.
  *
  * POLLVALUES maskbitnames
  *
  * Imediately retrieve a set of input values.
  *
  * LED leddigits
  *
  * Display something on the LED display.
  *
  * SPEAKER ON
  *
  * Turn the Raildriver's speaker on.
  *
  * SPEAKER OFF
  *
  * Turn the Raildriver's speaker off.  
  *
  * Where maskbitnames is one or more of these words, separated by white space:
  * REVERSER, THROTTLE, AUTOBRAKE, INDEPENDBRK, BAILOFF, HEADLIGHT, WIPER,
  * DIGITAL1, DIGITAL2, DIGITAL3, DIGITAL4, DIGITAL5, or DIGITAL6. See
  * {@link RaildriverServer RaildriverServer} for information on what these
  * events monitor and return.
  *
  * And leddigits is upto three decimal digits, dashes, or underscores
  * (which indicate blanks), with embeded periods (decimal points).  Excess
  * digits are quietly ignored.
  *
  */

class RaildriverParser : public RaildriverServer {
public:
	/** Constructor: create a client connection on the specified socket,
	  * from the supplied address.
	  *   @param sock The socket channel returned from accept().
	  *   @param sockaddr The remote address, also returned from accept().
	  */
	RaildriverParser(int sock, struct sockaddr_in *sockaddr);
	/** Reset the parse buffer to point to the server supplied butter.
	  *   @param buffer The start of the command line to parse.
	  */
	void ResetPtr(char *buffer);
	/** Tokens used by the parser code.
	  */
	enum yy_RaildriverParser_enum_token { YY_RaildriverParser_NULL_TOKEN=0	
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
	}; /* end of enum declaration */
	/** The parser method itself.
	  */
	int yyparse(void);
	/** Error message handler.
	  * @param msg The error message to display.
	  */
	virtual void yyerror(char *msg);
	/** The lexical analyser.
	  */
	virtual int yylex();
	/** The current token.
	  */
	yy_RaildriverParser_stype yylval;
	/** The number of errors.
	  */
	int yynerrs;
	/** The current input character.
	  */
	int yychar;
	/** The debug flag.
	  */
	int yydebug;
private:
	/** Secondary error handler, includes an offending piece of text.
	  * @param message The error message.
	  * @param s The offending text.
	  */
	void yyerror1(char *message,char *s);
	/** Current buffer location.
	  */
	char *currentPos;
	/** A buffer for the current input word.
	  */
	char word[4096];
};

//@}
