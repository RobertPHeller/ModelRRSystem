/* 
 * ------------------------------------------------------------------
 * cmri.cc - C/MRI interface code
 * Created by Robert Heller on Sat Mar 13 12:52:49 2004
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2004/05/22 15:01:53  heller
 * Modification History: Updates after live tests with a Super Mini node.
 * Modification History:
 * Modification History: Revision 1.4  2004/04/14 23:17:38  heller
 * Modification History: Removed default args in C++ code.
 * Modification History:
 * Modification History: Revision 1.3  2004/03/16 14:49:28  heller
 * Modification History: Code comments added
 * Modification History:
 * Modification History: Revision 1.2  2004/03/16 02:37:39  heller
 * Modification History: Base class documentation
 * Modification History:
 * Modification History: Revision 1.1  2004/03/14 05:20:17  heller
 * Modification History: First Alpha Release Lockdown
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

static char rcsid[] = "$Id$";

#include <cmri.h>
#include "gettext.h"

using namespace cmri;


/*
 * List class implementation code
 */

// Constructor: allocate a vector to hold the list.
List::List(int l)
{
	elements = new int[l];
	length = l;
}

// Destructor: deallocate the vector allocated in the constructor.
List::~List()
{
	delete elements;
}

// Read/Write indexing accessor.
int & List::operator [](int i)
{
	static int dummy;
	dummy = 0;
	if (i < 0 || i >= length) return dummy;
	else return elements[i];
}

// Read only indexing accessor.
int List::operator [](int i) const
{
	if (i < 0 || i >= length) return 0;
	else return elements[i];
}

// Resize method: allocate fresh memory, copy the existing elements, and
// free up the old memory.
void List::Resize(int l)
{
	int *newelements;
	int i,cl;
	if (l < 0) return;
	newelements = new int[l];
	if (length < l) cl = length;
	else cl = l;
	for (i = 0; i < cl; i++) newelements[i] = elements[i];
	delete elements;
	elements = newelements;
	length = l;
}


/*
 * CMri class implementation code
 */



// Constructor.  Open the serial port and condition it for C/MRI use.

CMri::CMri(const char *port, int baud,int maxtries,char **outmessage)
{
	/*
	 * Bind gettext domain for error messages.
	 */
	bindmrrdomain();

	/*
	 * BAUD rate constant map
	 * see 'man termios' for constant list.
	 */
	static struct {
		int baud, bconst;
	} baudrates[] = {
		{0, B0},
		{50, B50},
		{75, B75},
		{110, B110},
		{134, B134},
		{150, B150},
		{200, B200},
		{300, B300},
		{600, B600},
		{1200, B1200},
		{1800, B1800},
		{2400, B2400},
		{4800, B4800},
		{9600, B9600},
		{19200, B19200},
		{38400, B38400} };
#define num_baudrates (sizeof(baudrates) / sizeof(baudrates[0]))
	// Error message buffer.
	static char messageBuffer[2048];
	// Misc. integers.
	int ibaud, i;

#ifdef DEBUG
	fprintf(stderr,"*** CMri(%s,%d,%d)\n",port,baud,maxtries);
#endif

	// Open port.
	ttyfd = open(port,O_RDWR|O_NOCTTY|O_NONBLOCK);
	// Open failure?  Create an error message.
	if (ttyfd < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Failed to open port %1$s because %2$s."),port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return;
	}
	// Not a serial port?  Close it and create an error message.
	if (!isatty(ttyfd)) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("%s is not a terminal port."),port);
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Get a prestine copy of the serial port's current settings.
	if (tcgetattr(ttyfd,&savedtermios) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Cannot get termios struct for %1$s because %2$s."),port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Get a second copy of the serial port's current settings, to be modified.
	if (tcgetattr(ttyfd,&currenttermios) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Cannot get termios struct for %1$s because %2$s."),port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Set the terminal to be raw
	cfmakeraw(&currenttermios);
	// Lookup the BAUD rate setting
	ibaud = B9600;
	for (i = 0; i < (int)num_baudrates; i++) {
		if (baud == baudrates[i].baud) {
			ibaud = baudrates[i].bconst;
			break;
		}
	}
	// Set the input speed
	if (cfsetispeed(&currenttermios,ibaud) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Cannot set termios struct in speed for %1$s because %2$s."),port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// And output speed
	if (cfsetospeed(&currenttermios,ibaud) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Cannot set termios struct out speed for %1$s because %2$s."),port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Disable all flow control (the C/MRI boards don't handle it).
	currenttermios.c_iflag &= ~IXON;
	currenttermios.c_iflag &= ~IXOFF;
	currenttermios.c_cflag &= ~CRTSCTS;

	// Add a second stop bit at higher speeds
	if (baud > 28800) currenttermios.c_cflag |= CSTOPB;
	else currenttermios.c_cflag &= ~CSTOPB;
	// Disable all parity bit handling
	currenttermios.c_cflag &= ~(PARENB|PARODD);
	// Disable modem control lines.
	currenttermios.c_cflag |= CLOCAL;

	// Set the port settings.
	if (tcsetattr(ttyfd,TCSANOW,&currenttermios) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Cannot set termios struct for %1$s because %2$s."),port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Remember the maximum tries.
	MaxTries = maxtries;
	return;
}

// Destructor: reset the port's state and close it.
CMri::~CMri()
{
	// If port was never open, just return
	if (ttyfd < 0) return;
	// Reset port's settings
	tcsetattr(ttyfd,TCSANOW,&savedtermios);
	// And close it
	close(ttyfd);
}


// InitBoard method: initialize one board.
void CMri::InitBoard(const List *CT,int ni, int no,int ns,int ua,
		     CardType card,int dl,char **outmessage)
{
    // Output buffer (card type map or yellow signal map
    static unsigned char ob[256];
    // Error message buffer
    static char messageBuffer[2048];
    // Various integers: counts and indexes
    int nscnt, i, j, ctlen = CT->Length();
    int lm, nict, noct, cti;

    // If the port is not open, create an error message and return.
    if (ttyfd < 0) {
    	if (outmessage != NULL) {
    	    strcpy(messageBuffer,_("The port is not open!"));
    	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return;
    }
    // Check the range of the card address.
    if (ua < 0 || ua > 127) {
	if (outmessage != NULL) {
	    sprintf(messageBuffer,_("The address (ua) is out of range: %d."),ua);
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return;
    }
    /*
     * Check the contents of the CT list, making sure that it makes sense
     * and is consistent and legal.
     */
    switch (card) {
	case USIC:
	case SUSIC:
	    ns = ctlen;		/* ns parameter not used with USIC and SUSIC cards.  CT list length used instead. */
	    // Verify that the input and output port counts are consistent with
	    // the board map and make sure that the board map is 'legal'.
	    nict = noct = 0;
	    for (i = 0; i < ns; i++) {
	    	cti = (*CT)[i];			// Get a four board set
	    	for (j = 0; j < 4; j++) {	// For each board...
	    	    int card = (cti & 0x03);	// Get one board's code
	    	    cti >>= 2;			// Next board
	    	    cti &= 0x3f;
	    	    switch (card) {		// Switch on card type.
	    	    	case 1: nict++; break;	// Input card
	    	    	case 2: noct++; break;	// Output card
			// No card, make sure this is last element.
	    	    	case 0: if (cti == 0 && (i+1) == ns) break; 
	    	    	case 3:	// Invalid card type OR hole
	    	    	    if (outmessage != NULL) {
	    	    	    	sprintf(messageBuffer,_("Invalid card type (CT) at index %1$d (%2$d) or card type positioning error."),i,(*CT)[i]);
	    	    	    	*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			    }
			    return;
		    }
		}
		// Check convert cards to ports
		if (card == USIC) {
			noct *= 3;
			nict *= 3;
		} else {
			noct *= 4;
			nict *= 4;
		}
		// Verify output port count
		if (noct != no) {
		    if (outmessage != NULL) {
		    	sprintf(messageBuffer,_("The number of output ports counted in the card type vector (%1$d) not equal to the number of output cards (no): %2$d."),noct,no);
		    	*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		    }
		    return;
		}
		// Verify input port count
		if (nict != ni) {
		    if (outmessage != NULL) {
		    	sprintf(messageBuffer,_("The number of input ports counted in the card type vector (%1$d) not equal to number of input cards (ni): %2$d."),nict,ni);
		    	*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		    }
		    return;
		}
	    }
	    break;
	case SMINI:
	    // Verify fixed counts for Super-mini card
	    if (ni != 3) {
		if (outmessage != NULL) {
		    sprintf(messageBuffer,_("The number of input ports must be = 3 for SMINI, got %d."),ni);
		    *outmessage = new char[strlen(messageBuffer)+1];
		    strcpy(*outmessage,messageBuffer);
		}
		return;
	    }
	    if (no != 6) {
		if (outmessage != NULL) {
		    sprintf(messageBuffer,_("The number of output ports must be = 6 for SMINI, got %d."),no);
		    *outmessage = new char[strlen(messageBuffer)+1];
		    strcpy(*outmessage,messageBuffer);
		}
		return;
	    }
	    // Check the count of yellow signals
	    if (ns < 0 || ns > 24) {
		if (outmessage != NULL) {
		    sprintf(messageBuffer,_("The number of yellow signals is out of the range of 0 to 24 for SMINI, got %d."),ns);
		    *outmessage = new char[strlen(messageBuffer)+1];
		    strcpy(*outmessage,messageBuffer);
		}
		return;
	    }
	    // The map is always 6 elements
	    if (ctlen > 6) ctlen = 6;
	    nscnt = 0;
	    // Check and count yellow signals
	    for (i = 0; i < ctlen; i++) {
		cti = (*CT)[i];
		while (cti > 1) {
		    if ((cti & 0x03) == 3) {
			nscnt++;
			cti >>= 2;
			cti &= 0x3f;
		    } else if ((cti & 0x03) == 0) {
			cti >>= 2;
			cti &= 0x3f;
		    } else if ((cti & 0x03) == 2) {
			cti >>= 1;
			cti &= 0x7f;
		    } else {
			break;
		    }
		}
		// Extra bit -- map is bad
		if (cti != 0) {
		    if (outmessage != NULL) {
			sprintf(messageBuffer,_("The card type at index %1$d is invalid: %2$d for a SMINI."),i,(*CT)[i]);
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		    }
		    return;
		}
	    }
	    // Count does not match the map
	    if (ns != nscnt) {
		if (outmessage != NULL) {
		    strcpy(messageBuffer,_("The signal count from the card type vector is not equal to the number of signals for a SMINI."));
		    *outmessage = new char[strlen(messageBuffer)+1];
		    strcpy(*outmessage,messageBuffer);
		}
		return;
	    }
	    break;
    }
    // Build the initialization message.
    ob[0] = (char) card;	// Card type
    ob[1] = (dl >> 8) & 0x0ff;	// Delay High byte
    ob[2] = dl & 0x0ff;		// Delay Low byte
    ob[3] = ns;			// ns: Number of signals or size of card map
    lm = 3;			// Last used element of the initialization message.
    switch (card) {
	case USIC:
	case SUSIC:		// Copy card map
	    for (i = 0; i < ns; i++) {
	    	ob[++lm] = (*CT)[i];
	    }
	    break;
	case SMINI:		// Copy signal map, if any
	    if (ns > 0) {
	    	for (i = 0; i < 6; i++) {
	    	    if (i < ctlen) {
	    	    	ob[++lm] = (*CT)[i];
		    } else {
		    	ob[++lm] = 0;
		    }
		}
	    }
	    break;
    }
    // Send initialize message
    if (!transmit(ua,Init,ob,lm+1)) {
    	if (outmessage != NULL) {
    	    sprintf(messageBuffer,_("There was a transmision error: %s."),strerror(errno));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
    }
    return;    
}

// Outputs method: set output ports.
void CMri::Outputs(const List *ports,int ua,char **outmessage)
{
    // Output buffer
    static unsigned char ob[256];
    // Error message buffer
    static char messageBuffer[2048];
    // index and count of ports
    int i, no = ports->Length();

    // If port is not open, complain
    if (ttyfd < 0)  {
    	if (outmessage != NULL) {
    	    strcpy(messageBuffer,_("The port is not open!"));
    	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return;
    }
    // Check card address range
    if (ua < 0 || ua > 127) {
	if (outmessage != NULL) {
	    sprintf(messageBuffer,_("The address (ua) is out of range: %d."),ua);
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return;
    }
    // Copy port values to output buffer
    for (i = 0; i < no; i++) ob[i] = (*ports)[i];
    // Send it to the card.
    if (!transmit(ua,Transmit,ob,no)) {
    	if (outmessage != NULL) {
    	    sprintf(messageBuffer,_("There was a transmision error: %s."),strerror(errno));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
    }
    return;
}

// Inputs method: poll and read the input ports
List *CMri::Inputs(int ni,int ua,char **outmessage)
{
    // Error message buffer
    static char messageBuffer[2048];
    // Result list
    List *result;
    // Index
    int i;
    // Data byte
    unsigned char thebyte;

#ifdef DEBUG
    fprintf(stderr,"*** CMri::Inputs(%d,%d)\n",ni,ua);
#endif

    // If port is not open, complain
    if (ttyfd < 0)  {
    	if (outmessage != NULL) {
    	    strcpy(messageBuffer,_("The port is not open!"));
    	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
    // Check card address range
    if (ua < 0 || ua > 127) {
	if (outmessage != NULL) {
	    sprintf(messageBuffer,_("The address (ua) is out of range: %d."),ua);
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
    // Send a Poll message
    if (!transmit(ua,Poll,NULL,0)) {
    	if (outmessage != NULL) {
    	    sprintf(messageBuffer,_("There was a transmision error: %s."),strerror(errno));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
    // Loop, waiting for a Start Of Text (STX) byte
    thebyte = 0;
    while (thebyte != STX) {
	if (!readbyte(thebyte)) {
    	    if (outmessage != NULL) {
    		sprintf(messageBuffer,_("There was a receive error: %s."),strerror(errno));
		*outmessage = new char[strlen(messageBuffer)+1];
		strcpy(*outmessage,messageBuffer);
	    }
	    return NULL;
        }
#ifdef DEBUG
	fprintf(stderr,"*** -: thebyte = %02x, expecting %02x\n",thebyte,STX);
#endif
    }
    // Read card address byte
    if (!readbyte(thebyte)) {
    	if (outmessage != NULL) {
    	    sprintf(messageBuffer,_("There was a receive error: %s."),strerror(errno));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
#ifdef DEBUG
    fprintf(stderr,"*** -: thebyte = %02x, expecting %02x\n",thebyte,ua+'A');
#endif
    // Check for card address match
    if ((thebyte - 'A') != ua) {
    	if (outmessage != NULL) {
    	   sprintf(messageBuffer,_("Received a bad address (ua) = %d."),thebyte - 'A');
    	   *outmessage = new char[strlen(messageBuffer)+1];
	   strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
    // Get message type byte
    if (!readbyte(thebyte)) {
    	if (outmessage != NULL) {
    	    sprintf(messageBuffer,_("There was a receive error: %s."),strerror(errno));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
#ifdef DEBUG
    fprintf(stderr,"*** -: thebyte = %02x, expecting %02x\n",thebyte,Read);
#endif
    // Make sure it is a Read message type
    if (thebyte != Read) {
    	if (outmessage != NULL) {
    	   sprintf(messageBuffer,_("The received message was not a Read message for address %d."),ua);
    	   *outmessage = new char[strlen(messageBuffer)+1];
	   strcpy(*outmessage,messageBuffer);
	}
	return NULL;
    }
    // Allocate result list
    result = new List(ni);
    // Read each port byte
    for (i = 0; i < ni; i++) {
    	// Get next byte
    	if (!readbyte(thebyte)) {
    	    if (outmessage != NULL) {
    	    	sprintf(messageBuffer,_("There was a receive error: %s."),strerror(errno));
		*outmessage = new char[strlen(messageBuffer)+1];
		strcpy(*outmessage,messageBuffer);
	    }
	    delete result;
	    return NULL;
	}
#ifdef DEBUG
	fprintf(stderr,"*** -: thebyte = %02x\n",thebyte);
#endif
	// STX or ETX without a DLE???
	if (thebyte == STX || thebyte == ETX) {
	    if (outmessage != NULL) {
	    	sprintf(messageBuffer,_("There was no DLE ahead of STX or ETX for address (ua): %d."),ua);
	    	*outmessage = new char[strlen(messageBuffer)+1];
		strcpy(*outmessage,messageBuffer);
	    }
	    delete result;
	}
	// If a DLE, read another byte
	if (thebyte == DLE) {
	    if (!readbyte(thebyte)) {
		if (outmessage != NULL) {
		    sprintf(messageBuffer,_("There was a receive error: %s."),strerror(errno));
		    *outmessage = new char[strlen(messageBuffer)+1];
		    strcpy(*outmessage,messageBuffer);
	        }
		delete result;
		return NULL;
	    }
	}
	// Stash result byte in result list
	(*result)[i] = thebyte;
    }
    // Read End of Text byte
    if (!readbyte(thebyte)) {
    	if (outmessage != NULL) {
    	    sprintf(messageBuffer,_("There was a receive error: %s."),strerror(errno));
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	}
	delete result;
	return NULL;
    }
#ifdef DEBUG
    fprintf(stderr,"*** -: thebyte = %02x, expecting %02x\n",thebyte,ETX);
#endif
    // Not ETX?
    if (thebyte != ETX) {
    	if (outmessage != NULL) {
    	   sprintf(messageBuffer,_("An ETX not properly received for ua address %d."),ua);
    	   *outmessage = new char[strlen(messageBuffer)+1];
	   strcpy(*outmessage,messageBuffer);
	}
	delete result;
	return NULL;
    }
    // All good, return the port value list
    return result;
}
	    
// (Private) transmit method: transmit data to a board
bool CMri::transmit(int ua, char mt, unsigned char ob[], int lm)
{
	// Transmit buffer
	unsigned char tb[256];
	// buffer length, index
	int tp, i;

	// Message header bytes
	tb[0] = 0x0ff;		// First sync byte
	tb[1] = 0x0ff;		// Second sync byte
	tb[2] = STX;		// Start of Text
	tb[3] = ua + 'A';	// Card address
	tb[4] = mt;		// Message type
	tp = 5;			// Bytes so far
	if (mt != Poll) {	// Poll message is done, others have data
		// Pack all data bytes
		for (i = 0; i < lm; i++) {
			// If data byte is a special value, escape it with a DLE
			if (ob[i] == STX || ob[i] == ETX || ob[i] == DLE) {
				tb[tp++] = DLE;
			}
			// Pack data byte
			tb[tp++] = ob[i];
		}
	}
	tb[tp++] = ETX;		// Add an End of Text
#ifdef DEBUG
	fprintf(stderr,"*** in transmit: %d bytes: ",tp);
	for (i = 0; i < tp; i++) fprintf(stderr,"0x%02x ",tb[i]);
	fprintf(stderr,"\n");
#endif
	// Send data to card.  If there was an error return false otherwise
	// return true
	if (write(ttyfd,tb,tp) != tp) return false;
	else return true;
}

// (Private) readbyte method:  Read a byte from the serial port.
bool CMri::readbyte(unsigned char& thebyte)
{
    // Fd set for reading
    fd_set readset;
    // Timeout structure
    static struct timeval timeout;
    // Try count, result status
    int tries, status;

    // For MaxTries times...
    for (tries = MaxTries; tries > 0; tries--) {
	FD_SET(ttyfd,&readset);		// Set fd of interest
	timeout.tv_sec = 0;		// Timeout: 0 seconds
	timeout.tv_usec = 1000;		// Timeout: 1000 uSets (1 mSec)
	// Use select to check port
	status = select(ttyfd+1,&readset,NULL,NULL,&timeout);
#ifdef DEBUG
	fprintf(stderr,"*** in CMri::readbyte: tries = %d, status = %d\n",tries,status);
#endif
	if (status < 0) return false;	// Select itself had an error
	if (status > 0 && FD_ISSET(ttyfd,&readset)) {		// Data available!
	    status = read(ttyfd,&thebyte,1);	// Read a byte
	    // If read was successful return true, otherwise return false.
	    if (status == 1) return true;
	    else if (errno == EAGAIN) continue;
	    else return false;
	}
    }
    // No data after maxtries -- set error code to timeout and return false.
    errno = ETIMEDOUT;
    return false;
}
