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
RaildriverIO::RaildriverIO(short int thebus, short int thedevice,char **outmessage)
{
  libusb_device **list;			/* Device list */
  int status;		/* Status result codes. */
  static char buffer[1024];	/* for error messages */

  bindmrrdomain();	// bind message catalog domain

  status = libusb_init(NULL);
  if (status < 0) {
    if (outmessage != NULL) {
      sprintf(buffer,_("libusb_init failed: %d\n"), status);
      *outmessage = new char[strlen(buffer)+1];
      strcpy(*outmessage,buffer);
    }
    return;
  }

#ifdef DEBUG
  fprintf(stderr,"*** RaildriverIO::RaildriverIO: thebus = %03d, thedevice = %03d\n",thebus,thedevice);
#endif
  // Get device list
  ssize_t cnt = libusb_get_device_list(NULL, &list);
  ssize_t i = 0;
  int err = 0;
  if (cnt < 0) {
  }
  rdriverdev = NULL;
  theInterface = -1;
  
  // For all devices...
  for (i = 0; i < cnt; i++) {
    libusb_device *dev = list[i];
#ifdef DEBUG
    fprintf(stderr,"*** RaildriverIO::RaildriverIO: i = %d\n",i);
    fprintf(stderr,"*** RaildriverIO::RaildriverIO: libusb_get_bus_number(dev) = %03d\n",libusb_get_bus_number(dev));
#endif
    // Is the bus number the same as the requested bus number?  If not, try the next bus.
    if (libusb_get_bus_number(dev) != thebus) continue;
#ifdef DEBUG
    fprintf(stderr,"*** RaildriverIO::RaildriverIO: libusb_get_device_address(dev) = %03d\n",libusb_get_device_address(dev));
#endif
    
    // Is the device number the same as the requested device number?
    // If not, try the next device.
    if (libusb_get_device_address(dev) != thedevice) continue;
    struct libusb_device_descriptor descr;
    if (!libusb_get_device_descriptor(dev,&descr)) {
      
      uint8_t ic = 0;
      // For all configurations on this device...
      for (ic = 0; ic < descr.bNumConfigurations; ic++) {
	struct libusb_config_descriptor *config;
	if (!libusb_get_config_descriptor(dev,ic,&config)) {
	  uint8_t j = 0;
	  // For all interfaces on this configuration...
	  for (j = 0; j < config->bNumInterfaces; j++) {
	    const struct libusb_interface * interface = &config->interface[j];
	    int k = 0;
	    // For all alternive settings on this interface...
	    for (k = 0; k < interface->num_altsetting; k++) {
	      // Get this alternive setting.
	      const libusb_interface_descriptor *ainterface = &interface->altsetting[k];
	      // If this is the HID interface, get its interface number and
	      // stash the device object. We found it.
#ifdef DEBUG
	      fprintf(stderr,"*** RaildriverIO::RaildriverIO: ainterface->bInterfaceClass = %d\n",ainterface->bInterfaceClass);
#endif
	      if (ainterface->bInterfaceClass == LIBUSB_CLASS_HID) {
		theInterface = ainterface->bInterfaceNumber;
		rdriverdev = dev;
		break;
	      }
	    }
	  }
	}
      }
    }
  }
  if (rdriverdev != NULL) {
    err = libusb_open(rdriverdev,&rdHandle);
    // Die if open fails.
    if (err) {
      if (outmessage != NULL) {
        sprintf(buffer,_("RaildriverIO::RaildriverIO: usb_open failed: %d\n"),err);
	*outmessage = new char[strlen(buffer)+1];
	strcpy(*outmessage,buffer);
      }
      return;
    }
//#ifdef LIBUSB_HAS_DETACH_KERNEL_DRIVER_NP
    // Attempt to detach the kernel driver.
#ifdef DEBUG
    fprintf(stderr,"*** RaildriverIO::RaildriverIO: calling usb_detach_kernel_driver_np\n");
#endif
    err = libusb_detach_kernel_driver(rdHandle,theInterface);
    if (err != 0 && err != LIBUSB_ERROR_NOT_FOUND) {
      if (outmessage != NULL) {
	sprintf(buffer,_("RaildriverIO::RaildriverIO: libusb_detach_kernel_driver failed: %d\n"),
		err);
	*outmessage = new char[strlen(buffer)+1];
	strcpy(*outmessage,buffer);
      }
      return;
    }
//#endif
#ifdef DEBUG
    fprintf(stderr,"*** RaildriverIO::RaildriverIO: theInterface = %d\n",theInterface);
#endif
    // Claim the interface.
#ifdef DEBUG
    fprintf(stderr,"***RaildriverIO::RaildriverIO: calling usb_claim_interface\n");
#endif
    err = libusb_claim_interface(rdHandle,theInterface);
    if (err) {
      if (outmessage != NULL) {
      	sprintf(buffer,_("libusb_claim_interface failed: %d\n"),err);
      	*outmessage = new char[strlen(buffer)+1];
	strcpy(*outmessage,buffer);
      }
      return;
    }
    /* Set the  speedometer LED to 000 -- let operator know we've
     * got the device.
     */
    SetLEDS("000");	
  } else {
    if (outmessage != NULL) {
      sprintf(buffer,_("RaildriverIO::RaildriverIO: Could not find the rail driver.\n"));
      *outmessage = new char[strlen(buffer)+1];
      strcpy(*outmessage,buffer);
    }
    return;
  }
  libusb_free_device_list(list, 1);
}

// Destructor -- clean up allocated resources.

RaildriverIO::~RaildriverIO()
{
	int status;		/* Status codes. */

	status = libusb_release_interface(rdHandle,theInterface);	// Release the interface.
	libusb_close(rdHandle);		// Close the device.
}

#define INPUTENDPOINT  0x81	/* Input endpoint: read report buffer */
#define OUTPUTENDPOINT 0x02	/* Output endpoint: set LEDS, turn speaker on/off */

// Poll the device's state.  Called repeatedly in the main thread.
bool RaildriverIO::ReadInputs(RaildriverIO::Eventmask_bits &newMask, int &status)
{
	Eventmask_bits temp;		// Mask.
	unsigned char reportbuffer[14];	// Buffer.
	int i, xfered;			// Index, status.
	bool result;			// Result value.

#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs()\n");
#endif
	newMask = NONE_M;		// Initially, nothing has changed.
	// Read the device.
	//xfered = 0;
	status = libusb_interrupt_transfer(rdHandle, INPUTENDPOINT, (unsigned char *)reportbuffer,sizeof(reportbuffer),&xfered,100);
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::ReadInputs: after usb_interrupt_read: status = %d, xfered = %d\n",status,xfered);
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
	
	status = libusb_interrupt_transfer(rdHandle,OUTPUTENDPOINT,(unsigned char *)buff,sizeof(buff),&xfered,100);
#ifdef DEBUG
	fprintf(stderr,"*** RaildriverIO::SetLEDS(): LEDs set, status = %%%%d, xfered = %%%%d\n",status,xfered);
#endif
	if (status != 0) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("RaildriverIO::SetLEDS: usb_interrupt_write failed: %d\n"),status);
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
	status = libusb_interrupt_transfer(rdHandle,OUTPUTENDPOINT,(unsigned char *)buff,sizeof(buff),&xfered,100);
	if (status != 0) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("RaildriverIO::SpeakerOn: usb_interrupt_write failed: %d\n"),status);
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
	status = libusb_interrupt_transfer(rdHandle,OUTPUTENDPOINT,(unsigned char *)buff,sizeof(buff),&xfered,100);
	if (status != 0) {
	  if (outmessage != NULL) {
	    sprintf(buffer,_("RaildriverIO::SpeakerOff: usb_interrupt_write failed: %d\n"),status);
	    *outmessage = new char[strlen(buffer)+1];
	    strcpy(*outmessage,buffer);
	  }
	}
}



