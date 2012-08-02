/* 
 * ------------------------------------------------------------------
 * cmri.h - C/MRI interface header
 * Created by Robert Heller on Sat Mar 13 11:19:14 2004
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2004/04/15 00:03:25  heller
 * Modification History: Hacked to compile under RH 6.2
 * Modification History: (sys/select.h broken)
 * Modification History:
 * Modification History: Revision 1.2  2004/03/16 02:37:39  heller
 * Modification History: Base class documentation
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

#ifndef _CMRI_H_
#define _CMRI_H_

#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#else
#include <sys/types.h>
#include <unistd.h>
#endif
#include <sys/time.h>

//@Man: C/MRI C++ Serial Port Interface.
/*@Doc:
  \typeout{Generated from $Id$.}
  This is a Linux implementation of Bruce Chubb's C/MRI\cite{Chubb89}
  QBASIC\cite{ChubbBAS04} serial port code ported to C++.  This code
  works with 2.2 kernels and GLIBC 2.1 (RedHat 6.2) and 2.4 kernels and
  GLIBC 2.2 (RedHat 7.3). And it can use any serial port device
  supported by these kernels.  That is, in addition to the standard
  four COM ports, it can also use the various supported multi-port
  cards as well.
  
  The code is presently ``hardwired'' to use the Linux termios interface. I
  wanted to get the code up and running and presently I don't have any machines
  running other operating systems to test other low-level terminal I/O code.
  MS-Windows users do have access to Bruce Chubb's C/MRI QBasic and Visual 
  Basic code, so there is no rush at this point to support MS-Windows, although
  for MS-Windows who might want to use my forthcoming Tcl/Tk MRI code I'll
  probably want to port this code to run under MS-Windows.  This header and
  the class interface specification won't change much.  There will probably be
  lots of fun with ifdef in the C++ file.  Since this is open source code, I
  would hope that some enterprising MS-Windows C++ programmer will take up the
  ``gauntlet'' and do the MS-Windows port.  (Ditto for MacOSX and FreeBSD
  programmers.)

  Basically, the way this code works is to use a class (described on page
  \pageref{Class:CMri}) to interface to the serial port, which may have 
  one or more serial port cards (a mix of USICs, SUSICs, and SMINIs).  A given 
  class instance interfaces to all of the cards on attached to a given serial 
  port.  There are three public member functions, one to initialize a given 
  board (described on page \pageref{Class:CMri:InitBoard}), one to set the 
  output ports (described on page \pageref{Class:CMri:Outputs}), and one to 
  poll the state of the input ports (described on page 
  \pageref{Class:CMri:Inputs}).

  I was inspired to write this code after reading the four part series in 
  {\it Model
  Railroader}\cite{ChubbMRJan04,ChubbMRFeb04,ChubbMRMar04,ChubbMRApr04}
  and reading the download package for the SMINI card\cite{Chubb04}.  I
  already have a copy of Bruce Chubb's {\it Build Your Own Universal
  Computer Interface}, but the SMINI looks like a great option for
  small ``remote'' locations of a layout where there are a few turnouts
  and a some signals, such as a small junction, interchange yard, or
  isolated industrial spur.

 */



/*@ManDoc: \label{Class:List}
  A C++ mapping for a Tcl list.  Re-sizable (manually only). Used to pass
  lists of integers (such as port values) to and from the low-level code,
  where these values are encoded and decoded to/from the serial interface
  cards.
 */

class List {
public:
	/*@ManDoc: \label{Class:List:Constructor} The constructor.  Construct a
	  vector of a specific number of elements. */
	List(
		//@ManDoc: The number of elements to allocate.
		int l=0
	);
	/*@ManDoc: \label{Class:List:Destructor} The destructor.  Free up
          memory. */ 
	~List();
	/*@ManDoc: \label{Class:List:Length} The \verb=Length()= member
	  function returns the length of the vector. */
	int Length() const {return length;}
	/*@ManDoc: \label{Class:List:rwaccessor} Read/write indexing accessor.
	  Returns a reference to the $i^{th}$ element. */
	int & operator [](
		//@ManDoc: The index to access.
		int i
	);
	/*@ManDoc: \label{Class:List:roaccessor} Read only indexing accessor.
	  Returns the value of the $i^{th}$ element. */
	int operator [](
		//@ManDoc: The index to access.
		int i
	) const;
	/*@ManDoc: \label{Class:List:Resize} The \verb=Resize()= member
	  function re-sizes the vector.  If the vector is shortened, 
	  elements off the end are discarded. */
	void Resize(
		//@ManDoc: The number of elements to allocate.
		int l
	);
private:
	//@ManDoc: Length of the allocated vector.
	int length;
	//@ManDoc: Vector of elements.
	int *elements;
};

//@ManDoc: Card type codes.
enum CardType {
	//@ManDoc: Classic Universal Serial Interface Card.
	USIC='N',
	//@ManDoc: Super Classic Universal Serial Interface Card.
	SUSIC='X',
	//@ManDoc: Super Mini node.
	SMINI='M'
};

//@ManDoc: Special ASCII codes used in the data-link.
enum ASCIICtrlCodes {
	//@ManDoc: Start of Text.  Used at the start of message blocks.
	STX = 2,
	//@ManDoc: End of text.  Used at the end of message blocks.
	ETX = 3,
	//@ManDoc: Data Link Escape.  Used to escape special codes.
	DLE = 16
};

//@ManDoc: Message type codes.
enum MessageTypes   {
	//@ManDoc: Initialize message.  Initialize a serial interface board.
	Init = 'I', 
	//@ManDoc: Transmit message.  Send data to output ports.
	Transmit = 'T',
	//@ManDoc: Poll message.  Request the board to read its input ports.
	Poll = 'P',
	//@ManDoc: Read message.  Generated by a board in response to a Poll message.
	Read = 'R'
};

//@ManMemo: \label{Class:CMri}
class CMri {
public:
	/*@ManDoc: \label{Class:CMri:Constructor} The constructor opens the
	  serial port and initializes the port. */
	CMri(
		//@ManDoc: The serial port device file.
		const char *port="/dev/ttyS0", 
		//@ManDoc: The desired BAUD rate.
		int baud=9600,
		//@ManDoc: The maximum number of retries.
		int maxtries=10000,
		//@ManDoc: This holds a pointer to an error message, if any.
		char **outmessage=NULL
	);
	/*@ManDoc: \label{Class:CMri:Destructor} The destructor restores the
	  serial port's state and closes it.*/
	~CMri();
	/*@ManDoc: \label{Class:CMri:Inputs} The \verb=Inputs()= function
	  polls the interface and collects the input port values returned by 
	  the serial card.

	  The result is a freshly allocated \verb=List= object.  The calling 
	  program should free this memory with \verb=delete()=.  
	  \verb=Inputs()= returns a \verb=NULL= pointer if there was an error. */
	List *Inputs(
		/*@ManDoc: The number of input ports to be read.  Must equal
		  the number of ports on the specified card. */
		int ni,
		//@ManDoc: The card address.
		int ua=0,
		//@ManDoc: This holds a pointer to an error message, if any.
		char **outmessage=NULL
	);
	/*@ManDoc: \label{Class:CMri:Outputs} The \verb=Outputs()= function 
	  sends bytes to the output ports managed by the specified card. 
	  Since each element is written to one 8-bit output port, each element 
	  is presumed to be a integer in the range of 0 to 255. */
	void Outputs(
		/*@ManDoc: The list of port values.  Should have as many
		  elements as there are output ports. */
		const List *ports,
		//@ManDoc: The card address.
		int ua=0,
		//@ManDoc: This holds a pointer to an error message, if any.
		char **outmessage=NULL
	);
	/*@ManDoc: \label{Class:CMri:InitBoard} The \verb=InitBoard()= 
	  function initializes a given USIC, SUSIC, or SMINI card. */
	void InitBoard(

		//@ManDoc: The card type / yellow bi-color LED map. For USIC 
		//@Doc: and SUSIC cards this is the card type map.  For the SMINI 
		//@Doc:  card this is a 6 element list containing the port pairs 
		//@Doc:  for any simulated yellow bi-color LEDs. 
		//@Doc:\par 
		//@Doc:  The card type map for USIC and SUSIC is a packed array of 
		//@Doc:  2-bit values, packed 4 per element (byte) from low to high. 
		//@Doc:  Each 2-bit value is one of 0 (for no card), 1 (for an input  
		//@Doc:  card), or 2 (for an output card).  The cards must be 
		//@Doc:  ``packed'' with no open slots except at the end of the bus. 
		//@Doc:\par  
		//@Doc:  For the simulated yellow LEDs (SMINI card) the paired bits must 
		//@Doc:  be adjacent red/green bits and cannot span ports. 
		const List *CT,
		  
		//@ManDoc: The total number of input ports (must be 3 for SMINI).
		int ni,
		//@ManDoc: The total number of output ports (must be 6 or SMINI).
		int no,
		/*@ManDoc: The number of yellow bi-color LED signals.  Only
		  used for SMINI cards.  For USIC and SUSIC cards the Length()
		  member function of the \verb=CT= parameter is used. */
		int ns=0,
		//@ManDoc: The card address.
		int ua=0,
		//@ManDoc: The card type.
		CardType card=SMINI,
		//@ManDoc: The delay value to use.
		int dl=0,
		//@ManDoc: This holds a pointer to an error message, if any.
		char **outmessage=NULL
	);
private:
	//@ManDoc: Terminal file descriptor.
	int ttyfd;
	//@Man: savedtermios
	//@Type: struct termios
	//@Doc: Saved serial port settings.
	struct termios savedtermios;
	//@Man: currenttermios
	//@Type: struct termios
	//@Doc: Current serial port settings.
	struct termios currenttermios;
	//@ManDoc: Maximum number of input I/O retries.
	int MaxTries;
	/*@ManDoc: Data transmitter.  The data is built into a proper message
	  and sent out the serial port to the selected card. Returns 
	  \verb=false= on error and \verb=true= on success. */
	bool transmit(
		//@ManDoc: The card address.
		int ua, 
		//@ManDoc: The message type.
		char mt, 
		//@ManDoc: The data buffer (not used for Poll messages).
		unsigned char ob[], 
		//@ManDoc: The length of the data buffer (pass 0 for Poll messages).
		int lm
	);
	/*@ManDoc: Read a single byte from the serial interface.  Used by
	  the \verb=Inputs()= function. Returns \verb=false= on error and 
	  \verb=true= on success. */
	bool readbyte(
		/*@ManDoc: A place to put the byte read.  Undefined if there
		  was an error. */
		unsigned char& thebyte
	);
};	
/*@Doc:
  Main C/MRI interface class.  This class implements the interface logic for
  all of the boards on a given serial bus, attached to a given serial (COM) 
  port.  This class effectively implements in C++ under Linux what the QBasic
  serial I/O subroutines implemented by Bruce Chubb implement under MS-Windows.

  The constructor opens the serial port and does low-level serial I/O setup
  (BAUD rate, etc.). This is the first part of the \verb=INIT= subroutine.
  
  The \verb=InitBoard()= member function initializes a selected board (the 
  second part of the \verb=INIT= subroutine) and the \verb=Inputs()= and 
  \verb=Output()= member functions correspond to the \verb=INPUTS= and 
  \verb=OUTPUTS= subroutines.

  The private members, \verb=transmit()= and \verb=readbyte()= correspond 
  to the \verb=TXPACK= and \verb=RXBYTE= subroutines.

  All of the public member functions can take a pointer to a place to store
  an allocated (with \verb=new()=) string containing an error message.  If 
  \verb=NULL= is passed, no error reporting is done--error checking is still 
  done, just that the calling program gets no indication of it, except that 
  the \verb=Inputs()= function will return \verb=NULL=.  If the message 
  pointer is non \verb=NULL=, a \verb=char= array is allocated with 
  \verb=new()= and this array is filled with an error message. The calling 
  program should delete this memory when it is done with it, otherwise
  the calling program will leak memory.  If there are no errors, this pointer
  is not changed.  The calling program should initialize this pointer to
  \verb=NULL= and then test for a non \verb=NULL= value as an indication of
  a possible error.
 */

//@Man: References
/*@Doc:
 \relax\bibliography{../../Doc/MRR}
 \relax\bibliographystyle{plain}
 */
   

#endif // _CMRI_H_

