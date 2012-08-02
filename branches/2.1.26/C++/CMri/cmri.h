/* 
 * ------------------------------------------------------------------
 * cmri.h - C/MRI interface header
 * Created by Robert Heller on Sat Mar 13 11:19:14 2004
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.13  2007/10/22 17:17:27  heller
 * Modification History: 10222007
 * Modification History:
 * Modification History: Revision 1.12  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.11  2007/02/21 20:48:21  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.9  2007/02/21 20:39:19  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.8  2007/02/21 20:21:20  heller
 * Modification History: SWIG Hackery
 * Modification History:
 * Modification History: Revision 1.7  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.6  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.5  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.4  2005/11/04 19:06:33  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
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
#include <strings.h>
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

/** @defgroup CMRI CMRI
 * @brief CMR/I C++ Serial Port Interface.
 *
 * This is a Linux implementation of Bruce Chubb's C/MRI
 * QBASIC serial port code ported to C++.  This code
 * works (tested) with 2.2 kernels and GLIBC 2.1 (RedHat 6.2) and 2.4
 * kernels and GLIBC 2.2 (RedHat 7.3). And it can use any serial port device
 * supported by these kernels.  That is, in addition to the standard
 * four COM ports, it can also use the various supported multi-port
 * cards as well.
 * 
 * The code is presently ``hardwired'' to use the Linux termios interface. I
 * wanted to get the code up and running and presently I don't have any machines
 * running other operating systems to test other low-level terminal I/O code.
 * MS-Windows users do have access to Bruce Chubb's C/MRI QBasic and Visual 
 * Basic code, so there is no rush at this point to support MS-Windows, although
 * for MS-Windows who might want to use my forthcoming Tcl/Tk MRI code I'll
 * probably want to port this code to run under MS-Windows.  This header and
 * the class interface specification won't change much.  There will probably be
 * lots of fun with ifdef in the C++ file.  Since this is open source code, I
 * would hope that some enterprising MS-Windows C++ programmer will take up the
 * ``gauntlet'' and do the MS-Windows port.  (Ditto for MacOSX and FreeBSD
 * programmers.)
 *
 * Basically, the way this code works is to use a class (described on in
 * CMri) to interface to the serial port, which may have 
 * one or more serial port cards (a mix of USICs, SUSICs, and SMINIs).  A given 
 * class instance interfaces to all of the cards on attached to a given serial 
 * port.  There are three public member functions, one to initialize a given 
 * board (described in CMri::InitBoard), one to set the 
 * output ports (described in CMri::Outputs), and one to 
 * poll the state of the input ports (described in
 * CMri::Inputs).
 *
 * I was inspired to write this code after reading the four part series in 
 * Model Railroader
 * and reading the download package for the SMINI card.  I
 * already have a copy of Bruce Chubb's Build Your Own Universal
 * Computer Interface, but the SMINI looks like a great option for
 * small ``remote'' locations of a layout where there are a few turnouts
 * and a some signals, such as a small junction, interchange yard, or
 * isolated industrial spur.
 *
 * @author Robert Heller @<heller\@deepsoft.com@>
 *
 * @{ */

/**  
 * @brief CMR/I C++ Serial Port Interface.
 *
 * This is a Linux implementation of Bruce Chubb's C/MRI
 * QBASIC serial port code ported to C++.  This code
 * works (tested) with 2.2 kernels and GLIBC 2.1 (RedHat 6.2) and 2.4
 * kernels and GLIBC 2.2 (RedHat 7.3). And it can use any serial port device
 * supported by these kernels.  That is, in addition to the standard
 * four COM ports, it can also use the various supported multi-port
 * cards as well.
 * 
 * The code is presently ``hardwired'' to use the Linux termios interface. I
 * wanted to get the code up and running and presently I don't have any machines
 * running other operating systems to test other low-level terminal I/O code.
 * MS-Windows users do have access to Bruce Chubb's C/MRI QBasic and Visual 
 * Basic code, so there is no rush at this point to support MS-Windows, although
 * for MS-Windows who might want to use my forthcoming Tcl/Tk MRI code I'll
 * probably want to port this code to run under MS-Windows.  This header and
 * the class interface specification won't change much.  There will probably be
 * lots of fun with ifdef in the C++ file.  Since this is open source code, I
 * would hope that some enterprising MS-Windows C++ programmer will take up the
 * ``gauntlet'' and do the MS-Windows port.  (Ditto for MacOSX and FreeBSD
 * programmers.)
 *
 * Basically, the way this code works is to use a class (described on in
 * CMri) to interface to the serial port, which may have 
 * one or more serial port cards (a mix of USICs, SUSICs, and SMINIs).  A given 
 * class instance interfaces to all of the cards on attached to a given serial 
 * port.  There are three public member functions, one to initialize a given 
 * board (described in CMri::InitBoard), one to set the 
 * output ports (described in CMri::Outputs), and one to 
 * poll the state of the input ports (described in
 * CMri::Inputs).
 *
 * I was inspired to write this code after reading the four part series in 
 * Model Railroader
 * and reading the download package for the SMINI card.  I
 * already have a copy of Bruce Chubb's Build Your Own Universal
 * Computer Interface, but the SMINI looks like a great option for
 * small ``remote'' locations of a layout where there are a few turnouts
 * and a some signals, such as a small junction, interchange yard, or
 * isolated industrial spur.
 *
 * @author Robert Heller @<heller\@deepsoft.com@>
 *
 */
namespace cmri {

#ifdef SWIGTCL8
/*
 * Typemaps for handling the List class.  This maps a Tcl list of integers to
 * a List class instance.
 */

%typedef List *ListP;	// Help SWIG's pattern matching

/*
 * Input method: convert a Tcl list (of integers) to a freshly allocated List 
 * object.
 */

%typemap(in) const List * {
	Tcl_Obj **objvPtr;
	int       objcPtr,i;
	if (Tcl_ListObjGetElements(interp,$input,&objcPtr,&objvPtr) != TCL_OK)
		return(TCL_ERROR);
	$1 = new List(objcPtr);
	for (i = 0; i < objcPtr; i++) {
		if (Tcl_GetIntFromObj(interp,objvPtr[i],&((*$1)[i])) != TCL_OK)
			return(TCL_ERROR);
	}
}

%typemap(freearg) const List * {
	delete $1;
}


/*
 * Output (function result) method: convert the List object pointer to a Tcl
 * list.  Free up the List object pointer.  If the result was a NULL, return
 * an empty Tcl list.
 */

%typemap(out) ListP {
	int i, length;
	if ($1 == NULL) length = 0;
	else length = $1->Length();
	Tcl_Obj * tcl_result = $result;
	Tcl_SetListObj(tcl_result,0,NULL);
	for (i = 0; i < length; i++) {
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewIntObj((*$1)[i])) != TCL_OK)
			return TCL_ERROR;
	}
	if ($1 != NULL) delete $1;
}

/*
 * Typemap for the CardType Enum.  Map the first character of the input string
 * to the CardType Enum type OR the CardType Enum name to the  CardType Enum type.
 */

%typemap(in) CardType {
	char *p;
	Tcl_Obj * tcl_result = Tcl_GetObjResult(interp);
	p = Tcl_GetString($input);
	if (p == NULL || strlen(p) < 1) {
		Tcl_SetStringObj(tcl_result,"Missing CardType, should be one of N, X, M, USIC, SUSIC, or SMINI!",-1);
		return TCL_ERROR;
	}
	switch (toupper(p[0])) {
		case 'N': $1 = USIC; break;
		case 'X': $1 = SUSIC; break;
		case 'M': $1 = SMINI; break;
		default:
			if (strncasecmp(p,"USIC",strlen(p)) == 0) $1 = USIC;
			else if (strncasecmp(p,"SUSIC",strlen(p)) == 0) $1 = SUSIC;
			else if (strncasecmp(p,"SMINI",strlen(p)) == 0) $1 = SMINI;
			else {
				Tcl_SetStringObj(tcl_result,"Bad CardType, should be one of N, X, M, USIC, SUSIC, or SMINI! Got: ",-1);
				Tcl_AppendObjToObj(tcl_result,$input);
				return TCL_ERROR;
			}
	}
}

/*
 * Type map to handle error messages.  Hide this parameter from Tcl, but return
 * it as a second result, returning TCL_ERROR, if there is an error message.
 */

%typemap(in,numinputs=0) char **outmessage {
	$1 = new char*;
	*$1 = NULL;
}

%typemap(argout) char **outmessage {
	Tcl_Obj * tcl_result = $result;
	if (*$1 != NULL) {
		int mlen = strlen(*$1);
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*$1,mlen)) != TCL_OK) {
			delete *$1;
			delete $1;
			return TCL_ERROR;
		}
		delete *$1;
		delete $1;
		return TCL_ERROR;
	}
	delete $1;
}

#endif


#ifndef SWIG
/** @brief A C++ mapping for a Tcl list.
  *
  * Re-sizable (manually only). Used to pass lists of integers (such as
  * port values) to and from the low-level code, where these values are
  * encoded and decoded to/from the serial interface
  * cards.
  *
  * @author Robert Heller @<heller\@deepsoft.com@>
  */
class List {
public:
	/** @brief Constructor.
	  * Construct a vector of a specific number of elements. 
	  * @param l The number of elements to allocate. 
	  */
	List(int l=0);
	/** @brief Destructor.
	  *  Free up memory. 
	  */ 
	~List();
	/** The Length() member function returns the length of the vector. 
	  */
	int Length() const {return length;}
	/** @brief Read/write indexing accessor.
 	  * Returns a reference to the @f$i^{th}@f$ element.
	  * @param i The index to access. 
	  */
	int & operator [](int i);
	/** @brief Read only indexing accessor.
	  *  Returns the value of the @f$i^{th}@f$ element.
	  * @param i The index to access.
	  */
	int operator [](int i) const;
	/** The Resize() member function re-sizes the vector.  If the vector
	  * is shortened, elements off the end are discarded.
	  * @param l The number of elements to allocate. 
	  */
	void Resize(int l);
private:
	/**  Length of the allocated vector.
	  */
	int length;
	/**  Vector of elements.
	  */
	int *elements;
};

/** Pointer typedef.
  */
typedef List *ListP;

/** Card type codes.
  */
enum CardType {
	/** Classic Universal Serial Interface Card.
	  */
	USIC='N',
	/** Super Classic Universal Serial Interface Card.
	  */
	SUSIC='X',
	/** Super Mini node.
	  */
	SMINI='M'
};

/** Special ASCII codes used in the data-link.
  */
enum ASCIICtrlCodes {
	/**  Start of Text.  Used at the start of message blocks.
	  */
	STX = 2,
	/**  End of text.  Used at the end of message blocks.
	  */
	ETX = 3,
	/**  Data Link Escape.  Used to escape special codes.
	  */
	DLE = 16
};

/**  Message type codes.
  */
enum MessageTypes   {
	/**  Initialize message.  Initialize a serial interface board.
	  */
	Init = 'I', 
	/**  Transmit message.  Send data to output ports.
	  */
	Transmit = 'T',
	/**  Poll message.  Request the board to read its input ports.
	  */
	Poll = 'P',
	/**  Read message.  Generated by a board in response to a Poll message.
	  */
	Read = 'R'
};

#endif

/** @brief Main C/MRI interface class.
  *
  * This class implements the interface logic for
  * all of the boards on a given serial bus, attached to a given serial (COM) 
  * port.  This class effectively implements in C++ under Linux what the QBasic
  * serial I/O subroutines implemented by Bruce Chubb implement under MS-Windows.
  *
  * The constructor opens the serial port and does low-level serial I/O setup
  * (BAUD rate, etc.). This is the first part of the INIT subroutine.
  *
  * The InitBoard() member function initializes a selected board (the 
  * second part of the INIT subroutine) and the Inputs() and 
  * Output() member functions correspond to the INPUTS and 
  * OUTPUTS subroutines.
  *
  * The private members, transmit() and readbyte() correspond 
  * to the TXPACK and RXBYTE subroutines.
  *
  * All of the public member functions can take a pointer to a place to store
  * an allocated (with new()) string containing an error message.  If 
  * NULL is passed, no error reporting is done--error checking is still 
  * done, just that the calling program gets no indication of it, except that 
  * the Inputs() function will return NULL.  If the message 
  * pointer is non NULL, a char array is allocated with 
  * new() and this array is filled with an error message. The calling 
  * program should delete this memory when it is done with it, otherwise
  * the calling program will leak memory.  If there are no errors, this pointer
  * is not changed.  The calling program should initialize this pointer to
  * NULL and then test for a non NULL value as an indication of
  * a possible error.  The SWIG interface hides the outmessage parameter and
  * automagically allocates a pointer to receive error messages.  The SWIG
  * interface code checks this pointer and uses it to raise a Tcl error if
  * an error message was generated.
  *
  * @author Robert Heller @<heller\@deepsoft.com@>
  */
class CMri {
public:
#ifdef SWIGTCL8
	CMri(const char *port, int baud, int maxtries, char **outmessage);
#else
	/** @brief Constructor. 
	  *  The constructor opens the serial port and initializes the port.
	  * @param port The serial port device file.
	  * @param baud The desired BAUD rate.
	  * @param maxtries The maximum number of retries.
	  * @param outmessage This holds a pointer to an error message, if any.
	  */
	CMri(const char *port="/dev/ttyS0", 
	     int baud=9600,
	     int maxtries=10000,
	     char **outmessage=NULL);
#endif
	/** @brief Destructor.
	  *  The destructor restores the serial port's state and closes it.
	  */
	~CMri();
#ifdef SWIGTCL8
	ListP Inputs(int ni,int ua,char **outmessage);
#else
	/** The Inputs() function polls the interface and collects the input
	  * port values returned by the serial card. 
	  *
	  * The result is a freshly allocated List object.  The calling 
	  * program should free this memory with delete().  
	  * Inputs() returns a NULL pointer if there was an error.
	  * @param ni The number of input ports to be read.  Must equal
	  *	  the number of ports on the specified card. 
	  * @param ua The card address.
	  * @param outmessage This holds a pointer to an error message, if any.
	  */
	ListP Inputs(int ni,int ua=0,char **outmessage=NULL);
#endif
#ifdef SWIGTCL8
	void Outputs(const List *ports,int ua,char **outmessage);
#else
	/** The Outputs() function sends bytes to the output ports managed
	  * by the specified card. Since each element is written to one 8-bit 
	  * output port, each element is presumed to be a integer in the range
	  * of 0 to 255. 
	  * @param ports The list of port values.  Should have as many
	  *	  elements as there are output ports.
	  * @param ua The card address.
	  * @param outmessage This holds a pointer to an error message, if any.
	  */
	void Outputs(const List *ports,int ua=0,char **outmessage=NULL);
#endif
#ifdef SWIGTCL8
	void InitBoard(const List *CT,int ni,int no,int ns,int ua,
		       CardType card,int dl,char **outmessage);
#else
	/** The InitBoard() function initializes a given USIC, SUSIC, or
	  * SMINI card. 
	  *  @param CT The card type / yellow bi-color LED map. For USIC 
	  *	     and SUSIC cards this is the card type map.  For the SMINI 
	  *	     card this is a 6 element list containing the port pairs 
	  *	     for any simulated yellow bi-color LEDs. 
	  *	     
	  *	     The card type map for USIC and SUSIC is a packed array of 
	  *	     2-bit values, packed 4 per element (byte) from low to
	  *	     high. Each 2-bit value is one of 0 (for no card), 1 (for 
	  *	     an input card), or 2 (for an output card).  The cards
	  *	     must be "packed" with no open slots except at the end
	  *	     of the bus. 
	  *
	  *	     For the simulated yellow LEDs (SMINI card) the paired
	  * 	     bits must be adjacent red/green bits and cannot span ports.
	  * @param ni The total number of input ports (must be 3 for SMINI).
	  * @param no The total number of output ports (must be 6 or SMINI).
	  * @param ns The number of yellow bi-color LED signals.  Only
	  *	  used for SMINI cards.  For USIC and SUSIC cards the Length()
	  *	  member function of the CT parameter is used. 
	  * @param ua The card address.
	  * @param card The card type.
	  * @param dl The delay value to use.
	  * @param outmessage This holds a pointer to an error message, if any.
	  */
	void InitBoard(const List *CT,int ni,int no,int ns=0,int ua=0,
		       CardType card=SMINI,int dl=0,char **outmessage=NULL);
#endif
#ifndef SWIG
private:
	/**  Terminal file descriptor.
	  */
	int ttyfd;
	/**   Saved serial port settings.
	  */
	struct termios savedtermios;
	/**   Current serial port settings.
	  */
	struct termios currenttermios;
	/**  Maximum number of input I/O retries.
	  */
	int MaxTries;
	/** @brief  Data transmitter.
	  *  The data is built into a proper message and sent out the
	  * serial port to the selected card. Returns false on error and true
	  * on success.
	  * @param ua The card address.
	  * @param mt The message type.
	  * @param ob The data buffer (not used for Poll messages).
	  * @param lm The length of the data buffer (pass 0 for Poll messages).
	  */
	bool transmit(int ua, char mt, unsigned char ob[],int lm);
	/**   Read a single byte from the serial interface.  Used by
	  * the Inputs() function. Returns false on error and 
	  * true on success.
	  * @param thebyte A place to put the byte read.  Undefined if there
	  *	  was an error. 
	  */
	bool readbyte(unsigned char& thebyte);
#endif
};	

};

/*! @} */

#endif // _CMRI_H_

