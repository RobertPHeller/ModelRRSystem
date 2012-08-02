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

#include <stdio.h>
#include <errno.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <string.h>
#include <sys/time.h>
#include <syslog.h>
#include <ctype.h>
#include <RaildriverIO.h>

/*
 * Log functions, defined in main program.
 */
extern void log(const char* message);
extern void lperror(const char* prefix);
extern void logprintf(const char *format, ...);

// Magic constants:
const unsigned short int RaildriverIO::PIEngineering = 0x05f3;		// PIEngineering's Vender code.
const unsigned short int RaildriverIO::RailDriverModernDesktop = 0x00D2;	// Rail Driver product code.
const int RaildriverIO::LEDCommand = 134;			// Command code to set the LEDs.
const int RaildriverIO::SpeakerCommand = 133;		// Command code to set the speaker state.

/*
 * Lookup device in the USB device tree.
 */
bool RaildriverIO::FindRailDriver(const char *device)
{
  struct usb_device *dev;		/* Device pointer. */
  struct usb_bus *bus;			/* Bus pointer. */
  struct usb_config_descriptor *config;	/* Device configuration pointer. */
  struct usb_interface *interface;	/* Interface pointer. */
  struct usb_interface_descriptor *ainterface; /* Interface descriptor pointer. */
  int ddir,dfile,ibus,idev;		/* Bus and device indexes. */

#ifdef DEBUG
  logprintf("*** RaildriverIO::FindRailDriver(%s)\n",device);
#endif
  // Get the bus (ddir) and device (dfile) indexes. From the device pathname.
  sscanf(device,"/proc/bus/usb/%03d/%03d",&ddir,&dfile);

#ifdef DEBUG
  logprintf("*** RaildriverIO::FindRailDriver: ddir = %d, dfile = %d\n",ddir,dfile);
#endif
  // For all busses...
  for (bus = usb_get_busses(); bus; bus = bus->next) {
    // Get Bus number (ibus).
    sscanf(bus->dirname,"%03d",&ibus);
#ifdef DEBUG
    logprintf("*** RaildriverIO::FindRailDriver: bus->dirname = '%s', ibus = %d\n",bus->dirname,ibus);
#endif
    // Is the bus number the same as the requested bus number?  If not, try the next bus.
    if (ibus != ddir) continue;
    // For all devices on this bus...
    for (dev = bus->devices; dev; dev = dev->next) {
    	// Get this device number (idev).
    	sscanf(dev->filename,"%03d",&idev);
    	// Is the device number the same as the requested device number?
    	// If not, try the next device.
    	if (idev != dfile) continue;
        int i, j, k;		/* Additional indexes. */
        // For all configurations on this device...
	for (i = 0; i < dev->descriptor.bNumConfigurations; i++) {
	  // Get this configuration.
	  config = &dev->config[i];
	  // For all interfaces on this configuration...
	  for (j = 0; j < config->bNumInterfaces; j++) {
	    // Get this interface.
	    interface = &config->interface[j];
	    // For all alternive settings on this interface...
	    for (k = 0; k < interface->num_altsetting; k++) {
	      // Get this alternive setting.
	      ainterface = &interface->altsetting[k];
	      // If this is the HID interface, get its interface number and
	      // stash the device object. Return true (we found it).
	      if (ainterface->bInterfaceClass == USB_CLASS_HID) {
	        theInterface = ainterface->bInterfaceNumber;
	        rdriverdev = dev;
	        return(true);
	      }
	    }
	  }
	 }
    }
  }
  // Falling out -- did not find the interface, return false.
  return false;
}


/* Constructor -- initialize things, find the device, open it and set things up.
 */
RaildriverIO::RaildriverIO(const char *device)
{
	int status;		/* Status result codes. */
	
	usb_init();				/* Initialize libusb. */
	usb_find_busses();			/* Find all busses. */
	usb_find_devices();			/* Find all devices. */
	// Find the Rail Driver.
	if (FindRailDriver(device)) {
		// Open the device.
		rdHandle = usb_open(rdriverdev);
		// Die if open fails.
		if (rdHandle == NULL) {
			logprintf("RaildriverIO::RaildriverIO: usb_open failed: %s\n",usb_strerror());
			exit(99);
		}
#ifdef LIBUSB_HAS_DETACH_KERNEL_DRIVER_NP
		// Attempt to detach the kernel driver.
#ifdef DEBUG
		logprintf("*** RaildriverIO::RaildriverIO: calling usb_detach_kernel_driver_np\n");
#endif
		status = usb_detach_kernel_driver_np(rdHandle,theInterface);
		if (status < 0) {
			logprintf("RaildriverIO::RaildriverIO: usb_detach_kernel_driver_np failed: %s\n",
				usb_strerror());
			/*exit(99);*/
		}
#endif
#ifdef DEBUG
		logprintf("*** RaildriverIO::RaildriverIO: theInterface = %d\n",theInterface);
#endif
		// Claim the interface.
#ifdef DEBUG
		logprintf("***RaildriverIO::RaildriverIO: calling usb_claim_interface\n");
#endif
		status = usb_claim_interface(rdHandle,theInterface);
		if (status < 0) {
			logprintf("usb_claim_interface failed: %s\n",
					usb_strerror());
			exit(99);
		}
		/* Set the  speedometer LED to 000 -- let operator know we've
		 * got the device.
		 */
		SetLEDS("000");	
	} else {
		logprintf("RaildriverIO::RaildriverIO: Could not find the rail driver.\n");
		exit(99);
	}			
		
}

// Destructor -- clean up allocated resources.

RaildriverIO::~RaildriverIO()
{
	int status;		/* Status codes. */

	status = usb_release_interface(rdHandle,theInterface);	// Release the interface.
	if (status < 0) {
		logprintf("RaildriverIO::~RaildriverIO: usb_release_interface failed: %s\n",
				usb_strerror());
		exit(99);
	}
	status = usb_close(rdHandle);		// Close the device.
        if (status < 0) {
		logprintf("RaildriverIO::~RaildriverIO: usb_close failed: %s\n",usb_strerror());
		exit(99);
        }
}

#define INPUTENDPOINT 1		/* Input endpoint: read report buffer */
#define OUTPUTENDPOINT 2	/* Output endpoint: set LEDS, turn speaker on/off */

// Poll the device's state.  Called repeatedly in the main thread.
bool RaildriverIO::ReadInputs(RaildriverIO::Eventmask_bits &newMask)
{
	Eventmask_bits temp;		// Mask.
	unsigned char reportbuffer[14];	// Buffer.
	int i, status;			// Index, status.
	bool result;			// Result value.

#ifdef DEBUG
	log("*** RaildriverIO::ReadInputs()\n");
#endif
	newMask = NONE_M;		// Initially, nothing has changed.
	// Read the device.
	status = usb_interrupt_read(rdHandle,INPUTENDPOINT,(char *)reportbuffer,
				sizeof(reportbuffer),100);
#ifdef DEBUG
	log("*** RaildriverIO::ReadInputs: after usb_interrupt_read\n");
#endif
	// If the read was successful, procede to update the mask and data
	// buffer.
	if (status == sizeof(reportbuffer)) {
		// For all buffer elements and all mask bits...
		for (i = 0,temp = REVERSER_M;
		     i < status;
		     i++,temp=(Eventmask_bits)(temp << 1)) {
		     	// If byte has changed, copy it and set its mask bit.
			if (reportbuffer[i] != RDInput.ReportBuffer[i]) {
				RDInput.ReportBuffer[i] = reportbuffer[i];
				newMask = (Eventmask_bits) (newMask | temp);
#ifdef DEBUG
				logprintf("*** RaildriverIO::ReadInputs: reportbuffer[%d] = 0x%02x,temp = 0x%08x\n",i,reportbuffer[i],temp);
				logprintf("*** RaildriverIO::ReadInputs: newMask = 0x%08x\n",newMask);
#endif
			}
		}
	}
#ifdef DEBUG
	log("*** RaildriverIO::ReadInputs: after log\n");
#endif
	
	// Compute result.
	result = newMask != NONE_M;
	// Return result.
#ifdef DEBUG
	log("*** RaildriverIO::ReadInputs returns\n");
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
void RaildriverIO::SetLEDS(const char *ledstring)
{
	unsigned char buff[8];	// Segment buffer.
	int id,status;	// Indexes and status.
	const char *digit;	// Current digit.

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
	status = usb_interrupt_write(rdHandle,OUTPUTENDPOINT,(char *)buff,sizeof(buff),100);
	if (status < 0) {
		logprintf("RaildriverIO::SetLEDS: usb_interrupt_write failed: %s\n",usb_strerror());
	}
}

// Turn speaker on.
void RaildriverIO::SpeakerOn()
{
	unsigned char buff[8];
	int status;

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = SpeakerCommand;	// Speaker command.
	buff[6] = 1;			// On.
	// Write out to Rail Driver.
	status = usb_interrupt_write(rdHandle,OUTPUTENDPOINT,(char *)buff,sizeof(buff),100);
	if (status < 0) {
		logprintf("RaildriverIO::SpeakerOn: usb_interrupt_write failed: %s\n",usb_strerror());
	}
}

// Turn speaker off.
void RaildriverIO::SpeakerOff()
{
	unsigned char buff[8];
	int status;

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = SpeakerCommand;	// Speaker command
	buff[6] = 0;			// Off.
	// Write out to Rail Driver.
	status = usb_interrupt_write(rdHandle,OUTPUTENDPOINT,(char *)buff,sizeof(buff),100);
	if (status < 0) {
		logprintf("RaildriverIO::SpeakerOff: usb_interrupt_write failed: %s\n",usb_strerror());
	}
}


