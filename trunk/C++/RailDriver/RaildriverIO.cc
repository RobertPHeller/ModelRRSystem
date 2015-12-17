/* 
 * ------------------------------------------------------------------
 * RaildriverIO.cc - Raildriver I/O implementation
 * Created by Robert Heller on Tue Mar 27 14:33:58 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
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

static char Id[] = "$Id$";

#include "config.h"
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>
#include <RaildriverIO.h>
#include "../gettext.h"

// Magic constants:
const unsigned short int RaildriverIO::PIEngineering = 0x05f3;		// PIEngineering's Vender code.
const unsigned short int RaildriverIO::RailDriverModernDesktop = 0x00D2;	// Rail Driver product code.
const int RaildriverIO::LEDCommand = 134;			// Command code to set the LEDs.
const int RaildriverIO::SpeakerCommand = 133;		// Command code to set the speaker state.


/* Constructor -- initialize things, find the device, open it and set things up.
 */
RaildriverIO::RaildriverIO(const char *hidraw,char **outmessage)
{
    int status;		/* Status result codes. */
    static char buffer[1024];	/* for error messages */
    int err = 0;
    static char path[256];      /* for the path name */
    
    bindmrrdomain();	// bind message catalog domain

    if (path == NULL || *path == '\0') {
        rdriverdev = hid_open ( PIEngineering, RailDriverModernDesktop, NULL );
    } else {
        sprintf(path,"/dev/%s",hidraw);
        rdriverdev = hid_open_path ( path );
    }
    
    if (rdriverdev == NULL) {
        if (outmessage != NULL) {
            sprintf(buffer,_("RaildriverIO::RaildriverIO: hid_open failed\n"));
            *outmessage = new char[strlen(buffer)+1];
            strcpy(*outmessage,buffer);
        }
        return;
    }
    /* Set the  speedometer LED to 000 -- let operator know we've
     * got the device.
     */
    SetLEDS("000");	
}

// Destructor -- clean up allocated resources.

RaildriverIO::~RaildriverIO()
{
    int status;		/* Status codes. */

    hid_close(rdriverdev);
    hid_exit();
}

// Poll the device's state.  Called repeatedly in the main thread.
bool RaildriverIO::ReadInputs(RaildriverIO::Eventmask_bits &newMask, int &status)
{
	Eventmask_bits temp;		// Mask.
	unsigned char reportbuffer[14];	// Buffer.
	int i, xfered;			// Index, status.
        bool result;			// Result value.
        wchar_t tempstring[64];

#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs()\n");
#endif
	newMask = NONE_M;		// Initially, nothing has changed.
	// Read the device.
	//xfered = 0;

        xfered = hid_read_timeout(rdriverdev,(unsigned char *)reportbuffer,sizeof(reportbuffer),100);
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs: after xfered: xfered = %d\n",xfered);
#endif
	// If the read was successful, procede to update the mask and data
	// buffer.
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs: before test, xfered == sizeof(reportbuffer) is %d\n",xfered == sizeof(reportbuffer));
#endif
	if (xfered == sizeof(reportbuffer)) {
		// For all buffer elements and all mask bits...
		for (i = 0,temp = REVERSER_M;
		     i < xfered;
		     i++,temp=(Eventmask_bits)(temp << 1)) {
		     	// If byte has changed, copy it and set its mask bit.
#ifdef DEBUG
			fprintf(stderr,"*** RaildriverIO::ReadInputs (before test): reportbuffer[%d] = 0x%02x,temp = 0x%08x\n",i,reportbuffer[i],temp);
			fprintf(stderr,"*** RaildriverIO::ReadInputs (before test): RDInput.ReportBuffer[%d] = 0x%02x\n",i,RDInput.ReportBuffer[i]);
#endif
			if (reportbuffer[i] != RDInput.ReportBuffer[i]) {
				RDInput.ReportBuffer[i] = reportbuffer[i];
				newMask = (Eventmask_bits) (newMask | temp);
#ifdef DEBUG
				fprintf(stderr,"*** RaildriverIO::ReadInputs: reportbuffer[%d] = 0x%02x,temp = 0x%08x\n",i,reportbuffer[i],temp);
				fprintf(stderr,"*** RaildriverIO::ReadInputs: newMask = 0x%08x\n",newMask);
#endif
			}
		}
        }
        status = hid_get_manufacturer_string(rdriverdev,tempstring,sizeof(tempstring)-1);
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs: after log\n");
#endif
	
	// Compute result.
	result = newMask != NONE_M;
	// Return result.
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs returns\n");
#endif
	return result;
}


// Seven segment lookup table.
static const unsigned char SevenSegment[] = {
	0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
#define BLANKSEGMENT 0x00
#define DASHSEGMENT  0x40
#define DPSEGMENT    0x80
// Set the speedometer LEDS.
void RaildriverIO::SetLEDS(const char *ledstring,char **outmessage)
{
	unsigned char buff[8];	// Segment buffer.
	int id,status,xfered;	// Indexes and status.
	const char *digit;	// Current digit.
	static char buffer[1024];

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = LEDCommand;		// Set up LED Command code.
	// If there is a LED string...
	if (ledstring != NULL) {
		id = 3;			// Start with the leftmost digit.
		digit = ledstring;	// First digit.
		// While there are both digits and digit positions.
		while (*digit != '\0' && id > 0) {
			// Skip non digits.
			while (*digit != '\0' && !isdigit(*digit) &&
			       *digit != '_' && *digit != '-') {digit++;}
			// Out of digits? Break out of the loop/
			if (*digit == '\0') break;
			// Get seven segment code for digit.
			if (isdigit(*digit)) buff[id] = SevenSegment[(*digit) - '0'];
			else if (*digit == '_') buff[id] = BLANKSEGMENT;
			else if (*digit == '-') buff[id] = DASHSEGMENT;
			// Next character.
			digit++;
			// Is it a decimal point?  If so, OR in the decimal
			// point segment.
			if (*digit == '.') {
				buff[id] |= DPSEGMENT;
				digit++;
			}
			// Next digit position.
			id--;
		}
	}
	// Write out to Rail Driver.
    
        status = hid_write(rdriverdev,(unsigned char *)buff,sizeof(buff));
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::SetLEDS(): LEDs set, status = %d, xfered = %d\n",status,xfered);
#endif
	if (status < sizeof(buff)) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("RaildriverIO::SetLEDS: hid_write failed: %ls\n"),hid_error(rdriverdev));
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	}
}

// Turn speaker on.
void RaildriverIO::SpeakerOn(char **outmessage)
{
	unsigned char buff[8];
	int status,xfered;
	static char buffer[1024];

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = SpeakerCommand;	// Speaker command.
	buff[6] = 1;			// On.
	// Write out to Rail Driver.
        status = hid_write(rdriverdev,(unsigned char *)buff,sizeof(buff));
	if (status < sizeof(buff)) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("RaildriverIO::SpeakerOn: hid_write failed: %ls\n"),hid_error(rdriverdev));
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	}
}

// Turn speaker off.
void RaildriverIO::SpeakerOff(char **outmessage)
{
	unsigned char buff[8];
	int status,xfered;
	static char buffer[1024];

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = SpeakerCommand;	// Speaker command
	buff[6] = 0;			// Off.
	// Write out to Rail Driver.
	status = hid_write(rdriverdev,(unsigned char *)buff,sizeof(buff));
	if (status < sizeof(buff)) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("RaildriverIO::SpeakerOff: hid_write failed: %ls\n"),hid_error(rdriverdev));
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	}
}



