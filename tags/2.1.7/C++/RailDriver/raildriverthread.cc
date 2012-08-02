/* 
 * ------------------------------------------------------------------
 * raildriverthread.cc - Rail Driver Thread implementation.
 * Created by Robert Heller on Fri Jan 28 10:49:38 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/01/08 19:05:54  heller
 * Modification History: Jan 8, 2007 Lockdown
 * Modification History:
 * Modification History: Revision 1.3  2005/03/01 22:51:38  heller
 * Modification History: March 1 Lock down
 * Modification History:
 * Modification History: Revision 1.2  2005/02/20 17:15:56  heller
 * Modification History: Fix wiper/headlight, update documentation
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
#include <raildriverthread.h>
#include <raildriver.tab.h>
#include <syslog.h>

extern void log(const char* message);
extern void lperror(const char* prefix);
extern void logprintf(const char *format, ...);

// Magic constants:
const int RD_Event::PIEngineering = 0x05f3;		// PIEngineering's Vender code.
const int RD_Event::RailDriverModernDesktop = 0x00D2;	// Rail Driver product code.
const int RD_Event::LEDCommand = 134;			// Command code to set the LEDs.
const int RD_Event::SpeakerCommand = 133;		// Command code to set the speaker state.

bool RD_Event::FindRailDriver(const char *device)
{
  struct usb_device *dev;		/* Device pointer. */
  struct usb_bus *bus;			/* Bus pointer. */
  struct usb_config_descriptor *config;	/* Device configuration pointer. */
  struct usb_interface *interface;	/* Interface pointer. */
  struct usb_interface_descriptor *ainterface; /* Interface descriptor pointer. */
  int ddir,dfile,ibus,idev;		/* Bus and device indexes. */

#ifdef DEBUG
  logprintf("*** RD_Event::FindRailDriver(%s)\n",device);
#endif
  // Get the bus (ddir) and device (dfile) indexes. From the device pathname.
  sscanf(device,"/proc/bus/usb/%03d/%03d",&ddir,&dfile);

#ifdef DEBUG
  logprintf("*** RD_Event::FindRailDriver: ddir = %d, dfile = %d\n",ddir,dfile);
#endif
  // For all busses...
  for (bus = usb_get_busses(); bus; bus = bus->next) {
    // Get Bus number (ibus).
    sscanf(bus->dirname,"%03d",&ibus);
#ifdef DEBUG
    logprintf("*** RD_Event::FindRailDriver: bus->dirname = '%s', ibus = %d\n",bus->dirname,ibus);
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


// Default constructor -- never called.
RD_Event::RD_Event() {}

// Constructor -- initialize things, find the device, open it and set things up.
RD_Event::RD_Event(const char *device)
{
	int status;		/* Status result codes. */
	
	eventMask = NONE_M;	/* Blank the event mask. */
	pthread_cond_init(&eventCond,NULL);	/* Initialize our condition. */
	pthread_mutex_init(&eventMutex,NULL);	/* Initialize event mutex. */
	pthread_mutex_init(&outputMutex,NULL);	/* Initialize output mutex. */
	outQueueHead = outQueueTail = NULL;	/* Make the out queue empty. */
	usb_init();				/* Initialize libusb. */
	usb_find_busses();			/* Find all busses. */
	usb_find_devices();			/* Find all devices. */
	// Find the Rail Driver.
	if (FindRailDriver(device)) {
		// Open the device.
		rdHandle = usb_open(rdriverdev);
		// Die if open fails.
		if (rdHandle == NULL) {
			logprintf("RD_Event::RD_Event: usb_open failed: %s\n",usb_strerror());
			exit(99);
		}
#ifdef LIBUSB_HAS_DETACH_KERNEL_DRIVER_NP
		// Attempt to detach the kernel driver.
		logprintf("RD_Event::RD_Event: calling usb_detach_kernel_driver_np\n");
		status = usb_detach_kernel_driver_np(rdHandle,theInterface);
		if (status < 0) {
			logprintf("RD_Event::RD_Event: usb_detach_kernel_driver_np failed: %s\n",
				usb_strerror());
			/*exit(99);*/
		}
#endif
#ifdef DEBUG
		logprintf("*** RD_Event::RD_Event: theInterface = %d\n",theInterface);
#endif
		// Claim the interface.
		logprintf("RD_Event::RD_Event: calling usb_claim_interface\n");
		status = usb_claim_interface(rdHandle,theInterface);
		if (status < 0) {
			logprintf("usb_claim_interface failed: %s\n",
					usb_strerror());
			exit(99);
		}
		SetLEDS("000");
	} else {
		logprintf("RD_Event::RD_Event: Could not find the rail driver.\n");
		exit(99);
	}			
		
}

// Destructor -- clean up allocated resources.

RD_Event::~RD_Event()
{
	int status;		/* Status codes. */

	pthread_cond_destroy(&eventCond);	// Destroy the condition.
	FlushOutQueue();			// Flush the output queue.
	pthread_mutex_destroy(&eventMutex);	// Destroy the mutex.
	pthread_mutex_destroy(&outputMutex);	// Destroy the mutex.
	status = usb_release_interface(rdHandle,theInterface);	// Release the interface.
	if (status < 0) {
		logprintf("usb_release_interface failed: %s\n",
				usb_strerror());
		exit(99);
	}
	status = usb_close(rdHandle);		// Close the device.
        if (status < 0) {
		logprintf("usb_close failed: %s\n",usb_strerror());
		exit(99);
        }
}

// Poll the device's state.  Called repeatedly in the main thread.
bool RD_Event::ReadInputs()
{
	Eventmask_bits temp, newMask;	// Masks.
	unsigned char reportbuffer[14];	// Buffer.
	int i, status;			// Index, status.
	bool result;			// Result value.

#ifdef DEBUG
	log("*** RD_Event::ReadInputs()\n");
#endif
	newMask = NONE_M;		// Initially, nothing has changed.
	// Read the device.
	status = usb_interrupt_read(rdHandle,1,(char *)reportbuffer,
				sizeof(reportbuffer),100);
#ifdef DEBUG
	log("*** RD_Event::ReadInputs: after usb_interrupt_read\n");
#endif
	// If the read was successful, procede to update the mask and data
	// buffer.
	if (status == sizeof(reportbuffer)) {
		// For all buffer elements and all mask bits...
		for (i = 0,temp = REVERSER_M;
		     i < status;
		     i++,temp=(Eventmask_bits)(temp << 1)) {
		     	// If byte has changes, copy it and set its mask bit.
			if (reportbuffer[i] != RDInput.ReportBuffer[i]) {
				RDInput.ReportBuffer[i] = reportbuffer[i];
				newMask = (Eventmask_bits) (newMask | temp);
#ifdef DEBUG
				logprintf("*** RD_Event::ReadInputs: reportbuffer[%d] = 0x%02x,temp = 0x%08x\n",i,reportbuffer[i],temp);
				logprintf("*** RD_Event::ReadInputs: newMask = 0x%08x\n",newMask);
#endif
			}
		}
	}
#ifdef DEBUG
	log("*** RD_Event::ReadInputs: after log\n");
#endif
	
	// Compute result.
	result = newMask != NONE_M;
	// Lock the event mask and update it.
	pthread_mutex_lock(&eventMutex);
	eventMask = newMask;
	pthread_mutex_unlock(&eventMutex);
#ifndef LIBUSBTHREADSAFE
#ifdef DEBUG
	log("*** RD_Event::ReadInputs FlushOutQueue()\n");
#endif
	FlushOutQueue();
#endif
	// Return result.
#ifdef DEBUG
	log("*** RD_Event::ReadInputs returns\n");
#endif
	return result;
}

// Called in the writer function of the socket threads.
RD_Event::Eventmask_bits RD_Event::WaitForEvents(RD_Event::Eventmask_bits mask)
{
	//int retcode;
	Eventmask_bits temp;	// Mask of updated bits.
	struct timeval now;
	struct timespec timeout;

	// Lock the event mask.
	pthread_mutex_lock(&eventMutex);
#ifdef DEBUG
	logprintf("*** RD_Event::WaitForEvents (after pthread_mutex_lock)\n");
#endif
	// Wait for it to change.
	gettimeofday(&now,NULL);
	timeout.tv_sec = now.tv_sec + 1;
	timeout.tv_nsec = now.tv_usec * 1000;
	pthread_cond_timedwait (&eventCond, &eventMutex,&timeout);
#ifdef DEBUG
	logprintf("*** RD_Event::WaitForEvents: eventMask = 0x%08x, mask = 0x%08x\n",eventMask,mask);
#endif
	// Get bits we are waiting on.
	temp = (Eventmask_bits) (eventMask & mask);
	// Unlock the event mask.
	pthread_mutex_unlock(&eventMutex);
#ifdef DEBUG
	logprintf("*** RD_Event::WaitForEvents: temp = 0x%08x\n", temp);
#endif
	// Return the set of updated bits.
	return temp;
}

// Seven segment lookup table.
static const unsigned char SevenSegment[] = {
	0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
#define BLANKSEGMENT 0x00
#define DASHSEGMENT  0x40
// Set the speedometer LEDS.
void RD_Event::SetLEDS(const char *ledstring)
{
	unsigned char buff[8];	// Segment buffer.
	int /*d,*/ id/*, status*/;	// Indexes and status.
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
			while (*digit != '\0' && !isdigit(*digit) && *digit != '_' && *digit != '-') {digit++;}
			// Out of digits? Break out of the loop/
			if (*digit == '\0') break;
			// Get seven segment code for digit.
			if (isdigit(*digit)) buff[id] = SevenSegment[(*digit) - '0'];
			else if (*digit == '_') buff[id] = BLANKSEGMENT;
			else if (*digit == '-') buff[id] = DASHSEGMENT;
			// Next character.
			digit++;
			// Is it a decimal point?  If so, or in the decimal
			// point segment.
			if (*digit == '.') {
				buff[id] |= 0x080;
				digit++;
			}
			// Next digit position.
			id--;
		}
	}
#ifdef LIBUSBTHREADSAFE
	// Write out to Rail Driver.
	status = usb_interrupt_write(rdHandle,2,(char *)buff,sizeof(buff),100);
	if (status < 0) {
		logprintf("RD_Threads::SetLEDS: usb_interrupt_write failed: %s\n",usb_strerror());
	}
#else
	// Queue output buffer
	QueueOutButter(buff);
#endif
}

// Turn speaker on.
void RD_Event::SpeakerOn()
{
	unsigned char buff[8];
	//int status;

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = SpeakerCommand;	// Speaker command.
	buff[6] = 1;			// On.
#ifdef LIBUSBTHREADSAFE
	// Write out to Rail Driver.
	status = usb_interrupt_write(rdHandle,2,(char *)buff,sizeof(buff),100);
	if (status < 0) {
		logprintf("RD_Threads::SpeakerOn: usb_interrupt_write failed: %s\n",usb_strerror());
	}
#else
	// Queue output buffer
	QueueOutButter(buff);
#endif
}

// Turn speaker off.
void RD_Event::SpeakerOff()
{
	unsigned char buff[8];
	//int status;

	memset(buff,0,sizeof(buff));	// Clear buffer.
	buff[0] = SpeakerCommand;	// Speaker command
	buff[6] = 0;			// Off.
#ifdef LIBUSBTHREADSAFE
	// Write out to Rail Driver.
	status = usb_interrupt_write(rdHandle,2,(char *)buff,sizeof(buff),100);
	if (status < 0) {
		logprintf("RD_Threads::SpeakerOff: usb_interrupt_write failed: %s\n",usb_strerror());
	}
#else
	// Queue output buffer
	QueueOutButter(buff);
#endif
}

void RD_Event::QueueOutButter(unsigned char buff[8])
{
	pthread_mutex_lock(&outputMutex);
	struct outQueueElement *newQueueElement = new struct outQueueElement();
	memcpy(newQueueElement->buff,buff,8);
	newQueueElement->nextQueueElement = NULL;
	if (outQueueTail == NULL) {
		outQueueHead = outQueueTail = newQueueElement;
	} else {
		outQueueTail->nextQueueElement = newQueueElement;
		outQueueTail = newQueueElement;
	}
	pthread_mutex_unlock(&outputMutex);
}

void RD_Event::FlushOutQueue()
{
	int status;

	pthread_mutex_lock(&outputMutex);
	struct outQueueElement *element = outQueueHead;
	while (element != NULL) {
		logprintf("RD_Threads::FlushOutQueue: calling usb_interrupt_write, %d bytes\n",sizeof(element->buff));
		status = usb_interrupt_write(rdHandle,2,(char *)element->buff,sizeof(element->buff),100);
		if (status < 0) {
			logprintf("RD_Threads::FlushOutQueue: usb_interrupt_write failed: %s\n",usb_strerror());
		}
		outQueueHead = element->nextQueueElement;
		delete element;
		element = outQueueHead;
	}
	outQueueTail = outQueueHead;
	pthread_mutex_unlock(&outputMutex);
}


// Thread list.
RD_Threads *RD_Threads::thread_list = NULL;

RD_Threads::RD_Threads() {}	/* Never called. */

// Constructor -- set up all system resources needed.
RD_Threads::RD_Threads(int sock, struct sockaddr_in *sockaddr,
			RaildriverParser *p,RD_Event *event)
{
	int retcode;		// Return codes.
	sockfd = sock;		// Save our socket file descriptor.
	remotesockaddr = *sockaddr;	// And our client address.
	parser = p;		// And our parser.
	theEvent = event;	// And the device event instance.
#ifdef DEBUG
	sprintf(writebuffer,"*** RD_Threads::RD_Threads(): remotesockaddr.sin_addr.s_addr = 0x%08x\n",remotesockaddr.sin_addr.s_addr);
	log(writebuffer);
#endif
	// Log out connection.
	sprintf(writebuffer,"Connection from %d.%d.%d.%d:%d accepted\n",
		((remotesockaddr.sin_addr.s_addr) >>  0) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >>  8) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 16) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 24) & 0x0ff,
		remotesockaddr.sin_port);
	log(writebuffer);
	// Initialize our mutexes.
	pthread_mutex_init(&write_mutex,NULL);
	pthread_mutex_init(&read_mutex,NULL);
	// Initiatize our event mask.
	event_mask = RD_Event::NONE_M;
	// Initialize our thread ids.
	read_thread = 0;
	write_thread = 0;
	// Initialize our death flag.
	killme = false;
	// Add ourselves to the thread list.
	next = thread_list;
	thread_list = this;
	// Create our read thread.
	retcode = pthread_create(&read_thread,NULL,read_thread_function,
			   (void *)this);
	if (retcode != 0) {
		errno = retcode;
		lperror("RD_Threads: pthread_create (read)");
		killme = true;
		return;
#ifdef DEBUG
	} else {
		logprintf("*** RD_Threads: pthread_create (read): thread %ld created\n",(long int)read_thread);
#endif
	}
	// Create our write thread.
	retcode = pthread_create(&write_thread,NULL,write_thread_function,
			   (void *)this);
	if (retcode != 0) {
		errno = retcode;
		lperror("RD_Threads: pthread_create (write)");
		killme = true;
		return;
#ifdef DEBUG
	} else {
		logprintf("*** RD_Threads: pthread_create (write): thread %ld created\n",(long int)write_thread);
#endif
	}
}


// Destructor -- free up all system resources.
RD_Threads::~RD_Threads()
{
#ifdef DEBUG
	log("*** RD_Threads::~RD_Threads()\n");
#endif
	int retcode;	// Return codes.
	RD_Threads **ptr; // For walking the thread list.
	void *retval;	// Thread result (discarded).
	killme = true;	// Mark us dead.
	//theEvent->BroadcastEvents();
	sleep(1);
	// If there was a read thread, cancel it and join it.
	if (read_thread != 0) {
#ifdef DEBUG
		logprintf("*** Canceling read thread %ld\n",(long int)read_thread);
#endif
		pthread_cancel(read_thread);
		retcode = pthread_join (read_thread, &retval);
		read_thread = 0;
	}
	// Destroy the read mutex.
	pthread_mutex_destroy(&read_mutex);
	// If there was a write thread, cancel it and join it.
	if (write_thread != 0) {
#ifdef DEBUG
		logprintf("*** Canceling write thread %ld\n",(long int)write_thread);
#endif
		pthread_cancel(write_thread);
		sleep(1);
		retcode = pthread_join (write_thread, &retval);
		write_thread = 0;
	}
	// Destroy the write mutex
	pthread_mutex_destroy(&write_mutex);
	close(sockfd);	// Close our socket.
	// Take us off the thread list.
	for (ptr = &thread_list;
	     *ptr != this && *ptr != NULL; 
	     ptr = &((*ptr)->next)) {}
	if (*ptr == this) {
		*ptr = next;
	}
	// Log us closed.
	sprintf(writebuffer,"Connection from %d.%d.%d.%d:%d closed\n",
		((remotesockaddr.sin_addr.s_addr) >>  0) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >>  8) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 16) & 0x0ff,
		((remotesockaddr.sin_addr.s_addr) >> 24) & 0x0ff,
		remotesockaddr.sin_port);
	log(writebuffer);
}

// Read thread entry.  Get the this pointer and call the member function.
void * RD_Threads::read_thread_function(void *selfdata)
{
	RD_Threads *self = (RD_Threads *) selfdata;
	return self->reader();
}

// Reader function.  Loop processing commandds.
void * RD_Threads::reader()
{
	size_t rlen;	// Read length.
	char *p;	// Temp pointer.
	void *dummy = NULL;	// Result pointer.

	// Loop while not dead...
	while (!killme) {
		// Lock the read buffer.
		pthread_mutex_lock(&read_mutex);
		// Read the command from the client.
		rlen = recv(sockfd,readbuffer,sizeof(readbuffer)-2,MSG_NOSIGNAL);
		// Unlock the read buffer.
		pthread_mutex_unlock(&read_mutex);
		// Check for errors.
		if (rlen <= 0 && errno > 0) {
			lperror("RD_Threads::reader:recv");
			killme = true;
			break;
		}
		// Insure an EOS.
		readbuffer[rlen] = '\0';
		// Find the CR and replace with a NL.
		p = strchr(readbuffer,'\r');
		if (p != NULL) {
			*p++ = '\n';
			*p = '\0';
		}
		//log(readbuffer);
		// Set up for parsing the command.
		parser->ResetPtr(readbuffer);
		//log("*** parser->ResetPtr(readbuffer);\n");
		// Parse it.  Report problems to the client.
		if (parser->yyparse() != 0) {
			//log("*** parser->yyparse()\n");
			pthread_mutex_lock(&write_mutex);
			strcpy(writebuffer,"502 Parse error\n");
			rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
			pthread_mutex_unlock(&write_mutex);
			if (rlen < strlen(writebuffer)) {
				lperror("RD_Threads::reader:send");
				killme = true;
				break;
			}
		}
	}
	killme = true;
#ifdef DEBUG
	log("*** RD_Threads::reader() returns\n");
#endif
	return dummy;
}

// Writer function.  Get this pointer and call member function.
void * RD_Threads::write_thread_function(void *selfdata)
{
	RD_Threads *self = (RD_Threads *) selfdata;
	return self->writer();
}

// Writer member function.  Send stuff to the client.
void * RD_Threads::writer()
{
	void *dummy = NULL;	// Dummy result.
	size_t wlen;		// Write lenfth.
	RD_Event::Eventmask_bits newMask;	// Event mask.
	
	//pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS,NULL);
	// Lock the write buffer and let the client know we are ready.
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"200 Ready\n");
	wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (wlen < strlen(writebuffer)) {
		lperror("RD_Threads::writer:send");
		killme = true;
	}
	// Loop while not dead.	
	while (!killme) {
		// Wait for a mask change.
		newMask = theEvent->WaitForEvents(event_mask);
#ifdef DEBUG
		logprintf("*** RD_Threads::writer: killme = %d, newMask = %lu\n",killme,(unsigned long)newMask);
#endif
		if (killme) break;
		if (newMask == RD_Event::NONE_M) continue;
		// Data changed (real events).  Send data to clients.
		SendEventData(newMask);
	}
	killme = true;
#ifdef DEBUG
	log("*** RD_Threads::writer() returns\n");
#endif
	return dummy;
}

// Handle Exit command -- close connection (schedule our death).
void RD_Threads::DoExit(void)
{
	size_t wlen;	// Write length.

#ifdef DEBUG
	log("RD_Threads::DoExit(void)");
#endif
	// Be polite...
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"299 GOODBYE\n");
	wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (wlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
	}
	// And schedule our death.
	killme = true;
}

// Clear event mask.
void RD_Threads::ClearMask(void)
{
	size_t rlen;

#ifdef DEBUG
	log("RD_Threads::ClearMask(void)");
#endif
	// Clear mask.
	event_mask = RD_Event::NONE_M;
	// Be polite...
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (rlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
		killme = true;
	}
}

// Add Mask bits.
void RD_Threads::AddMask(RD_Event::Eventmask_bits mask)
{
	size_t rlen;

#ifdef DEBUG
	log("RD_Threads::AddMask(RD_Event::Eventmask_bits mask)");
#endif
	// Or in mask bits.
	event_mask = (RD_Event::Eventmask_bits) (mask | event_mask);
	// Be polite...
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (rlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
		killme = true;
	}
}

void RD_Threads::PollValues(RD_Event::Eventmask_bits mask)
{

#ifdef DEBUG
	log("RD_Threads::PollValues(RD_Event::Eventmask_bits mask)");
#endif
	// Read RD Event data...
	SendEventData(mask);
}

// Display LEDs.
void RD_Threads::LedDisplay(char const * lstr)
{
	size_t rlen;

#ifdef DEBUG
	log("RD_Threads::LedDisplay(char const * lstr)");
	log(lstr);
#endif
	// Display LEDs.
	theEvent->SetLEDS(lstr);
	// Be polite.
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (rlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
		killme = true;
	}
}

// Speaker On.
void RD_Threads::SpeakerOn(void)
{
	size_t rlen;

#ifdef DEBUG
	log("RD_Threads::SpeakerOn(void)");
#endif
	// Turn speaker on.
	theEvent->SpeakerOn();
	// Be polite.
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (rlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
		killme = true;
	}
}

// Speaker Off.
void RD_Threads::SpeakerOff(void)
{
	size_t rlen;

#ifdef DEBUG
	log("RD_Threads::SpeakerOff(void)");
#endif
	// Turn speaker off.
	theEvent->SpeakerOff();
	// Be polite.
	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"201 OK\n");
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (rlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
		killme = true;
	}
}

#include <stdarg.h>

// Error output function.  Send error message to client.
void RD_Threads::ErrFormat(const char *format, ...)
{
	size_t rlen;
	va_list ap;

	pthread_mutex_lock(&write_mutex);
	va_start(ap,format);
	vsnprintf(writebuffer,sizeof(writebuffer)-1,format,ap);
	va_end(ap);
	rlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
	pthread_mutex_unlock(&write_mutex);
	if (rlen < strlen(writebuffer)) {
		lperror("RD_Threads::reader:send");
		killme = true;
	}
}


// Send Event data.
void RD_Threads::SendEventData(RD_Event::Eventmask_bits sendmask)
{
	size_t len, wlen;
	char /* *ptr,*/ comma, *p;
	RD_Event::Eventmask_bits testMask;
	RD_Event::Eventcodes eventCode;
	

	pthread_mutex_lock(&write_mutex);
	strcpy(writebuffer,"201 Events: ");
	len = strlen(writebuffer);
	comma = '\0';
#ifdef DEBUG
	logprintf("*** SendEventData(0x%08x)\n",(unsigned long)sendmask);
#endif
	for (testMask = RD_Event::REVERSER_M, eventCode=RD_Event::REVERSER;
	     eventCode <= RD_Event::DIGITAL6; 
	     testMask = (RD_Event::Eventmask_bits)(testMask << 1),
		eventCode = (RD_Event::Eventcodes)(eventCode + 1)) {
#ifdef DEBUG
		logprintf("*** SendEventData: testMask = 0x%08x, eventCode = %d\n",(unsigned long)testMask,eventCode);
		logprintf("*** SendEventData: (testMask & sendmask) = 0x%08x\n",(testMask & sendmask));
		logprintf("*** SendEventData: writebuffer = %s\n",writebuffer);
		logprintf("*** SendEventData: comma = %d\n",comma);
#endif
		if ((testMask & sendmask) != 0) {
			memset(workbuffer,'\0',sizeof(workbuffer));
			p = workbuffer;
			if (comma != '\0') *p++ = comma;
#ifdef DEBUG
			logprintf("*** SendEventData: workbuffer = '%s'\n",workbuffer);
#endif
			switch (eventCode) {
				case RD_Event::REVERSER:
					sprintf(p,"REVERSER=%d",
						theEvent->GetReverser());
					comma = ',';
					break;
				case RD_Event::THROTTLE:
					sprintf(p,"THROTTLE=%d",
						theEvent->GetThrottle());
					comma = ',';
					break;
				case RD_Event::AUTOBRAKE:
					sprintf(p,"AUTOBRAKE=%d",
						theEvent->GetAutoBrake());
					comma = ',';
					break;
				case RD_Event::INDEPENDBRK:
					sprintf(p,"INDEPENDBRK=%d",
						theEvent->GetIndependBrake());
					comma = ',';
					break;
				case RD_Event::BAILOFF:
					sprintf(p,"BAILOFF=%d",
						theEvent->GetBailOff());
					comma = ',';
					break;
				case RD_Event::HEADLIGHT:
					sprintf(p,"HEADLIGHT=%d",
						theEvent->GetHeadlight());
					comma = ',';
					break;
				case RD_Event::WIPER:
					sprintf(p,"WIPER=%d",
						theEvent->GetWiper());
					comma = ',';
					break;
				case RD_Event::DIGITAL1:
					strcpy(p,"DIGITAL1=("); 
					p += strlen(p);
					comma = '\0';
					if (theEvent->GetBlueButton1()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB1");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton2()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB2");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton3()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB3");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton4()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB4");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton5()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB5");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton6()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB6");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton7()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB7");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton8()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB8");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RD_Event::DIGITAL2:
					strcpy(p,"DIGITAL2=(");
					p += strlen(p);
					comma = '\0';
					if (theEvent->GetBlueButton9()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB9");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton10()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB10");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton11()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB11");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton12()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB12");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton13()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB13");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton14()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB14");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton15()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB15");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton16()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB16");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RD_Event::DIGITAL3:
					strcpy(p,"DIGITAL3=(");
					p += strlen(p);
					comma = '\0';
					if (theEvent->GetBlueButton17()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB17");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton18()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB18");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton19()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB19");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton20()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB20");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton21()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB21");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton22()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB22");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton23()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB23");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton24()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB24");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RD_Event::DIGITAL4:
					strcpy(p,"DIGITAL4=(");
					p += strlen(p);
					comma = '\0';
					if (theEvent->GetBlueButton25()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB25");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton26()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB26");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton27()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB27");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBlueButton28()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"BB28");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetZoomUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Zoom Up");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetZoopDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Zoom Down");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetPanUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Up");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetPanRight()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Right");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RD_Event::DIGITAL5:
					strcpy(p,"DIGITAL5=(");
					p += strlen(p);
					comma = '\0';
					if (theEvent->GetPanDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Down");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetPanLeft()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pan Left");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetRangeUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Range Up");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetRangeDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Range Down");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetEBrakeUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Emergency Brake Up");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetEBrakeDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Emergency Brake Down");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetAlert()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Alert");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetSand()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Sand");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
				case RD_Event::DIGITAL6:
					strcpy(p,"DIGITAL6=(");
					p += strlen(p);
					comma = '\0';
					if (theEvent->GetPantograph()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Pantograph");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetBell()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Bell");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetWhistleUp()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Whistle Up");
						p += strlen(p);
						comma = ';';
					}
					if (theEvent->GetWhistleDown()) {
						if (comma != '\0') *p++ = comma;
						strcpy(p,"Whistle Down");
						p += strlen(p);
						comma = ';';
					}
					*p++ = ')';
					*p = '\0';
					comma = ',';
					break;
			}
			workbuffer[sizeof(workbuffer)-1] = '\0';
#ifdef DEBUG
			logprintf("*** SendEventData: workbuffer = '%s'\n",workbuffer);
#endif
			if (len+strlen(workbuffer) > sizeof(writebuffer)-2) {
				strcat(writebuffer,"\n");
				wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
				if (wlen < strlen(writebuffer)) {
					lperror("RD_Threads::writer:send");
					killme = true;
					break;
				}
				strcpy(writebuffer,"201 Events: ");
				len = strlen(writebuffer);
			}
			strcat(writebuffer,workbuffer);
			len = strlen(writebuffer);
		}
	}
	if (!killme) {
		strcat(writebuffer,"\n");
		wlen = send(sockfd,writebuffer,strlen(writebuffer),MSG_NOSIGNAL);
		if (wlen < strlen(writebuffer)) {
			lperror("RD_Threads::writer:send");
			killme = true;
		}			
	}
	pthread_mutex_unlock(&write_mutex);
}
