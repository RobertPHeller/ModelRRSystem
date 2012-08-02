/* 
 * ------------------------------------------------------------------
 * raildriverthread.h - Rail Driver Thread Class
 * Created by Robert Heller on Fri Jan 28 09:04:39 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2005/11/14 20:28:45  heller
 * Modification History: Nov 14, 2005 Lockdown
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

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>

#include <usb.h>

class RaildriverParser;

#ifndef _RAILDRIVERTHREAD_H_
#define _RAILDRIVERTHREAD_H_



/**     
  \TEX{\typeout{Generated from $Id$.}}
  \Label{Class:RDEvent}
  Rail Driver Event Class.  Holds all of the event information as well as the
  connection to the Rail Driver device (USB interface).  Uses the libusb API,
  specifically the bulk read and write functions.

  Publicly exposes a set of event masks and code, a set of functions to handle
  the event mask, a set of functions to access current data values, a
  function to manipulate the speedometer display and a pair of functions to
  manipulate the internal speaker in the Rail Driver unit.

  Internally there are private data structures to hold the current input state
  of all of the levers, switches and buttons.
 */

class RD_Event {
public:
	/**   \Label{Class:RDEvent:eventmaskbits}
	  Event Masks.  These are the mask bits for the Rail Driver's report
	  message.
	 */
	enum Eventmask_bits {
		/**   No bits set. */
		NONE_M		= 0,
		/**   Reverser lever. */
		REVERSER_M	= 1,
		/**   Throttle lever. */
		THROTTLE_M	= 2,
		/**   Automatic Brake lever. */
		AUTOBRAKE_M	= 4,
		/**   Independent Brake lever. */
		INDEPENDBRK_M	= 8,
		/**   Independent Brake bail off. */
		BAILOFF_M	= 16,
		/**   Wiper switch. */
		WIPER_M		= 32,
		/**   Headlight switch. */
		HEADLIGHT_M	= 64,
		/**   Blue Buttons 1-8. */
		DIGITAL1_M	= 128,
		/**   Blue Buttons 9-16. */
		DIGITAL2_M	= 256,
		/**   Blue Buttons 17-24. */
		DIGITAL3_M	= 512,
		/**   Blue Buttons 24-Zoom,Pan. */
		DIGITAL4_M	= 1024,
		/**   Pan, Cab Buttons */
		DIGITAL5_M	= 2048,
		/**   Cab Buttons, WHistle  */
		DIGITAL6_M	= 4096
	};
	/**   \Label{Class:RDEvent:eventcodes}
	  Event Codes.  These are the event codes for the Rail Driver's report
	  message.
	 */
	enum Eventcodes {
		/**   No bits set. */
		NONE		= 0,
		/**   Reverser lever. */
		REVERSER,
		/**   Throttle lever. */
		THROTTLE,
		/**   Automatic Brake lever. */
		AUTOBRAKE,
		/**   Independent Brake lever. */
		INDEPENDBRK,
		/**   Independent Brake bail off. */
		BAILOFF,
		/**   Wiper switch. */
		WIPER,
		/**   Headlight switch. */
		HEADLIGHT,
		/**   Blue Buttons 1-8. */
		DIGITAL1,
		/**   Blue Buttons 9-16. */
		DIGITAL2,
		/**   Blue Buttons 17-24. */
		DIGITAL3,
		/**   Blue Buttons 24-Zoom,Pan. */
		DIGITAL4,
		/**   Pan, Cab Buttons */
		DIGITAL5,
		/**   Cab Buttons, WHistle  */
		DIGITAL6
	};
	/**   Constructor. The argument is the pathname under the
	  /proc/bus/usb/ directory that identifies the specific device.

	  Finds and opens the device and initializes various data objects
	  including a thread mutex and cond object.*/
	RD_Event(const char *device);
	/**   Destructor. Closes the device and free up system resources.
	 */
	~RD_Event();
	/**   Return the current eventmask bits. */
	Eventmask_bits GetMask() const {return eventMask;}
	/**   Wait for one or more events.  Waits on the event condition.
	 */
	Eventmask_bits WaitForEvents(Eventmask_bits mask);
	/**   Broadcast events. Broadcasts to all threads waiting on the
	  event condition.*/
	void BroadcastEvents() {pthread_cond_broadcast(&eventCond);}
	/**   Clear all event bits. */
	void ClearAllEvents() {eventMask = NONE_M;}
	/**   Add one or more event bits.*/
	void AddEvents(Eventmask_bits mask) {
		eventMask = (Eventmask_bits)(mask | eventMask);
	}
	/**   Set the Speedometer LEDs. Does a bulk write to set the
	  speedometer LEDs on the Raid Driver unit. */
	void SetLEDS(const char *ledstring);
	///  Turn the speaker on.
	void SpeakerOn();
	///  Turn the speaker off.
	void SpeakerOff();
	///  Get Reverser value (0-255).
	unsigned char GetReverser() const {return RDInput.theBytes.Reverser;}
	///  Get Throttle value (0-255).
	unsigned char GetThrottle() const {return RDInput.theBytes.Throttle;}
	///  Get Auto Brake value (0-255).
	unsigned char GetAutoBrake() const {return RDInput.theBytes.AutoBrake;}
	///  Get Indepenent Brake value (0-255).
	unsigned char GetIndependBrake() const {return RDInput.theBytes.IndependBrake;}
	///  Get Bail Off value (0-255).
	unsigned char GetBailOff() const {return RDInput.theBytes.BailOff;}
	///  Get Headlight value (0-255).
	unsigned char GetHeadlight() const {return RDInput.theBytes.Headlight;}
	///  Get Wiper value (0-255).
	unsigned char GetWiper() const {return RDInput.theBytes.Wiper;}
	///  Get Blue Button 1.
	bool GetBlueButton1() const {return (RDInput.theBytes.Digital1 & 0x01) != 0;}
	///  Get Blue Button 2.
	bool GetBlueButton2() const {return (RDInput.theBytes.Digital1 & 0x02) != 0;}
	///  Get Blue Button 3.
	bool GetBlueButton3() const {return (RDInput.theBytes.Digital1 & 0x04) != 0;}
	///  Get Blue Button 4.
	bool GetBlueButton4() const {return (RDInput.theBytes.Digital1 & 0x08) != 0;}
	///  Get Blue Button 5.
	bool GetBlueButton5() const {return (RDInput.theBytes.Digital1 & 0x10) != 0;}
	///  Get Blue Button 6.
	bool GetBlueButton6() const {return (RDInput.theBytes.Digital1 & 0x20) != 0;}
	///  Get Blue Button 7.
	bool GetBlueButton7() const {return (RDInput.theBytes.Digital1 & 0x40) != 0;}
	///  Get Blue Button 8.
	bool GetBlueButton8() const {return (RDInput.theBytes.Digital1 & 0x080) != 0;}
	///  Get Blue Button 9.
	bool GetBlueButton9() const {return (RDInput.theBytes.Digital2 & 0x01) != 0;}
	///  Get Blue Button 10.
	bool GetBlueButton10() const {return (RDInput.theBytes.Digital2 & 0x02) != 0;}
	///  Get Blue Button 11.
	bool GetBlueButton11() const {return (RDInput.theBytes.Digital2 & 0x04) != 0;}
	///  Get Blue Button 12.
	bool GetBlueButton12() const {return (RDInput.theBytes.Digital2 & 0x08) != 0;}
	///  Get Blue Button 13.
	bool GetBlueButton13() const {return (RDInput.theBytes.Digital2 & 0x10) != 0;}
	///  Get Blue Button 14.
	bool GetBlueButton14() const {return (RDInput.theBytes.Digital2 & 0x20) != 0;}
	///  Get Blue Button 15.
	bool GetBlueButton15() const {return (RDInput.theBytes.Digital2 & 0x40) != 0;}
	///  Get Blue Button 16.
	bool GetBlueButton16() const {return (RDInput.theBytes.Digital2 & 0x080) != 0;}
	///  Get Blue Button 17.
	bool GetBlueButton17() const {return (RDInput.theBytes.Digital3 & 0x01) != 0;}
	///  Get Blue Button 18.
	bool GetBlueButton18() const {return (RDInput.theBytes.Digital3 & 0x02) != 0;}
	///  Get Blue Button 19.
	bool GetBlueButton19() const {return (RDInput.theBytes.Digital3 & 0x04) != 0;}
	///  Get Blue Button 20.
	bool GetBlueButton20() const {return (RDInput.theBytes.Digital3 & 0x08) != 0;}
	///  Get Blue Button 21.
	bool GetBlueButton21() const {return (RDInput.theBytes.Digital3 & 0x10) != 0;}
	///  Get Blue Button 22.
	bool GetBlueButton22() const {return (RDInput.theBytes.Digital3 & 0x20) != 0;}
	///  Get Blue Button 23.
	bool GetBlueButton23() const {return (RDInput.theBytes.Digital3 & 0x40) != 0;}
	///  Get Blue Button 24.
	bool GetBlueButton24() const {return (RDInput.theBytes.Digital3 & 0x080) != 0;}
	///  Get Blue Button 25.
	bool GetBlueButton25() const {return (RDInput.theBytes.Digital4 & 0x01) != 0;}
	///  Get Blue Button 26.
	bool GetBlueButton26() const {return (RDInput.theBytes.Digital4 & 0x02) != 0;}
	///  Get Blue Button 27.
	bool GetBlueButton27() const {return (RDInput.theBytes.Digital4 & 0x04) != 0;}
	///  Get Blue Button 28.
	bool GetBlueButton28() const {return (RDInput.theBytes.Digital4 & 0x08) != 0;}
	///  Get Zoom Up.
	bool GetZoomUp() const {return (RDInput.theBytes.Digital4 & 0x10) != 0;}
	///  Get Zoom Down.
	bool GetZoopDown() const {return (RDInput.theBytes.Digital4 & 0x20) != 0;}
	///  Get Pan Up.
	bool GetPanUp() const {return (RDInput.theBytes.Digital4 & 0x40) != 0;}
	///  Get Pan Right.
	bool GetPanRight() const {return (RDInput.theBytes.Digital4 & 0x080) != 0;}
	///  Get Pan Down.
	bool GetPanDown() const {return (RDInput.theBytes.Digital5 & 0x01) != 0;}
	///  Get Pan Left.
	bool GetPanLeft() const {return (RDInput.theBytes.Digital5 & 0x02) != 0;}
	///  Get Range Up.
	bool GetRangeUp() const {return (RDInput.theBytes.Digital5 & 0x04) != 0;}
	///  Get Range Down.
	bool GetRangeDown() const {return (RDInput.theBytes.Digital5 & 0x08) != 0;}
	///  Get  Emergency Brake Up.
	bool GetEBrakeUp() const {return (RDInput.theBytes.Digital5 & 0x10) != 0;}
	///  Get Emergency Brake Down.
	bool GetEBrakeDown() const {return (RDInput.theBytes.Digital5 & 0x20) != 0;}
	///  Get Alert.
	bool GetAlert() const {return (RDInput.theBytes.Digital5 & 0x40) != 0;}
	///  Get Sand.
	bool GetSand() const {return (RDInput.theBytes.Digital5 & 0x080) != 0;}
	///  Get Pantograph.
	bool GetPantograph() const {return (RDInput.theBytes.Digital6 & 0x01) != 0;}
	///  Get Bell.
	bool GetBell() const {return (RDInput.theBytes.Digital6 & 0x02) != 0;}
	///  Get Whistle Up.
	bool GetWhistleUp() const {return (RDInput.theBytes.Digital6 & 0x04) != 0;}
	///  Get Whistle Down.
	bool GetWhistleDown() const {return (RDInput.theBytes.Digital6 & 0x08) != 0;}
	///  Get Product Code Id.
	unsigned char GetProductCodeId() const {return RDInput.theBytes.ProductCodeId;}
	/**   Poll the interface. Called in the main thread.  Returns true
	  if something has changed.*/
	bool ReadInputs();
private:
	/**   Default constructor (never called). */
	RD_Event();
	///  Rail Driver vendor code.
	static const int PIEngineering;
	///  Rail Driver product code.
	static const int RailDriverModernDesktop;
	///  Find the Rail Driver device.
	bool FindRailDriver(const char *device);
	///  The interface we will be using.
	int theInterface;
	///  Rail Driver Device.
	struct usb_device *rdriverdev;
	///  Rail Driver handle.
	usb_dev_handle *rdHandle;
	///  LED Command code.
	static const int LEDCommand;
	///  Speaker command code.
	static const int SpeakerCommand;
	/**   Event mask.*/
	Eventmask_bits eventMask;
	/**   Event condition.*/
	pthread_cond_t eventCond;
	/**   Event mutex. */
	pthread_mutex_t eventMutex;
	/**   Output mutex. */
	pthread_mutex_t outputMutex;
	///  Output queue elements.
	struct outQueueElement {
		unsigned char buff[8];
		struct outQueueElement *nextQueueElement;
	} *queueHead;
	///  Head out the output queue.
	struct outQueueElement *outQueueHead;
	///  Tail out the output queue.
	struct outQueueElement *outQueueTail;
	///  Queue up an output buffer.
	void QueueOutButter(unsigned char buff[8]);
	///  Flush the output queue.
	void FlushOutQueue();
	/**  Event data. */
	/*@{*/
	union {
		/**   Event Buffer */
		unsigned char ReportBuffer[14];
		/**   Event Buffer Bytes */
		/*@{*/
		struct bytes {
			/**   Reverser, 0-255. */
			unsigned char Reverser;
			/**   Throttle, 0-255. */
			unsigned char Throttle;
			/**   Automatic Brake, 0-255. */
			unsigned char AutoBrake;
			/**   Independent Brake, 0-255. */
			unsigned char IndependBrake;
			/**   Bail Off, 0-255. */
			unsigned char BailOff;
			/**   Wiper, 1 (left), 2 (center), 3 (right). */
			unsigned char Wiper;
			/**   Headlight, 1 (left), 2 (center), 3 (right). */
			unsigned char Headlight;
			/**   Blue Buttons 1-8. */
			unsigned char Digital1;
			/**   Blue Buttons 9-16. */
			unsigned char Digital2;
			/**   Blue Buttons 17-24. */
			unsigned char Digital3;
			/**   Blue Buttons 25-28, Zoom, Pan Buttons. */
			unsigned char Digital4;
			/**   Pan, Cab buttons.*/
			unsigned char Digital5;
			/**   Cab Buttons, Whistle Switch.*/
			unsigned char Digital6;
			/**   Product Code Id, usually 210.*/
			unsigned char ProductCodeId;
		} theBytes;
		/*@}*/
	} RDInput;
	/*@}*/
};

/**   \Label{Class:RDThreads}
 Rail Driver Thread Class.  Each network socket connection gets one of these.
 Each instance creates two threads, a reader thread and a writer thread.
 */

class RD_Threads {
protected:
	///  Parser.  Parses commands coming over the network socket.
	RaildriverParser *parser;
	///  Error function.  Used to report parse errors.
	void ErrFormat(const char *format, ...);
	///  Exit function.  Closes the connection.
	void DoExit();
	///  Clear Mask function.  Clears the event mask.
	void ClearMask();
	///  Add Mask function.  Adds bits to the event mask.
	void AddMask(RD_Event::Eventmask_bits mask);
	///  Poll Values functions.  Reads the current Rail Driver buffer.
	void PollValues(RD_Event::Eventmask_bits mask);
	///  Led Display function.  Sends digits to the speedometer LEDS.
	void LedDisplay(const char *ledstring);
	///  Speaker on function.  Turns the speaker in the Rail Driver on.
	void SpeakerOn();
	///  Speaker off function.  Turns the speaker in the Rail Driver off.
	void SpeakerOff();
private:
	///  Rail driver event handler.  Points to the RD\_Event object.
	RD_Event *theEvent;
	/**   Hide default constructor. */
	RD_Threads();
	/**   Socket file descriptor. Our connection to our client. */
	int sockfd;
	/// Remote host name. The remote host address of the client.
	struct sockaddr_in remotesockaddr;
	/**   Write mutex. Mutex for the write buffer.*/
	pthread_mutex_t write_mutex;
	/**   Read mutex. Mutex for the read buffer.*/
	pthread_mutex_t read_mutex;
	/**   Our event mask. */
	RD_Event::Eventmask_bits event_mask;
	/**   Next thread in the list. */
	RD_Threads *next;
	/**   Read thread id. */
	pthread_t read_thread;
	/**   Write thread id. */
	pthread_t write_thread;
	/**   Death flag. */
	bool killme;
	/**   Read thread function. */
	static void * read_thread_function(void *selfdata);
	/**   Read thread function. */
	void * reader();
	/**   Write thread function. */
	static void * write_thread_function(void *selfdata);
	/**   Write thread function. */
	void * writer();
	/**   Thread list. */
	static RD_Threads *thread_list;
	/**   Read buffer. */
	char readbuffer[4096];
	/**   Write buffer. */
	char writebuffer[4096];
	///  Working buffer.
	char workbuffer[256];
	///  Send Event Data.
	void SendEventData(RD_Event::Eventmask_bits sendmask);
public:
	/**   Constructor. Gets the socket fd, the socket address,
	  the parser instance, and the event instance. */
	RD_Threads(int sock, struct sockaddr_in *sockaddr,
		   RaildriverParser *p,RD_Event *event);
	/**   Destructor. Free up all system resources, cancel and join
	  the threads. */
	virtual ~RD_Threads();
	/**   Return the next thread in the list. */
	RD_Threads * Next() const {return next;}
	/**   Return first element of the list. */
	static RD_Threads * First() {return thread_list;}
	/**   Return the killme flag.*/
	bool KillMe() const {return killme;}
	/**   Return the event mask. */
	RD_Event::Eventmask_bits GetMask() const {return event_mask;}
};

#endif // _RAILDRIVERTHREAD_H_

