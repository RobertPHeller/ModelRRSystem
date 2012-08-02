/* 
 * ------------------------------------------------------------------
 * RaildriverIO.h - Raildriver I/O class.
 * Created by Robert Heller on Tue Mar 27 14:17:32 2007
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

#ifndef _RAILDRIVERIO_H_
#define _RAILDRIVERIO_H_

#include <usb.h>

/** \TEX{\typeout{Generated from $Id$.}}
  * This class implements the low-level Raildriver I/O functions and provides
  * access to the two endpoints, one input (controls, switches, and buttons) and
  * one output (LED display and speaker switch).
  *
  * The Raildriver ``game'' console contains a collection of levers, buttons,
  * and switches that simulate a locomotive control stand.  There is a reverser
  * lever, a throttle, two brake levers, switches for the lights and wipers,
  * and buttons, switches, and levers for things like the bell, alerter, whistle
  * (or horn), sand, pantograph, and other functions, plus a collection of
  * general purpose buttons that can be programmed to provide any other
  * function.  The console also contains a three digit seven-segment display and
  * there is a built in speaker.
  *
  */

class RaildriverIO {
public:
	/**   \Label{Class:RDEvent:eventmaskbits}
	  * Event Masks.  These are the mask bits for the Rail Driver's report
	  * message.  Each bit represents one of the thirteen bytes in the 
	  * report buffer.
	 */
	enum Eventmask_bits {
		/** No bits set.  This is the empty mask.
		  */
		NONE_M		= 0,
		/** Reverser lever.  This is a value between 0 and 255
		  * representing the position of the reverser lever.
		  */
		REVERSER_M	= 1 << 0,
		/**   Throttle lever. This is a value between 0 and 255
		  * representing the position of the throttle / dynamic brake 
		  * lever.
		  */
		THROTTLE_M	= 1 << 1,
		/**   Automatic Brake lever.  This is a value between 0 and 255
		  * representing the position of the automatic brake lever.
		  */
		AUTOBRAKE_M	= 1 << 2,
		/**   Independent Brake lever. This is a value between 0 and 255
		  *  representing the position of the independent brake lever.
		  */
		INDEPENDBRK_M	= 1 << 3,
		/**   Independent Brake bail off. This is a value between 0 and
		  * 255 representing the position of the independent brake lever
		  * bail off.
		  */
		BAILOFF_M	= 1 << 4,
		/**   Wiper switch.  This is a value between 0 and 255
		  * representing the position of the wiper switch.
		  */
		WIPER_M		= 1 << 5,
		/**   Headlight switch.  This is a value between 0 and 255
		  * representing the position of the headlight switch.
		  */
		HEADLIGHT_M	= 1 << 6,
		/**   Blue Buttons 1-8.  This is a bitfield representing 8
		  * of the generic ``blue'' buttons.
		  */
		DIGITAL1_M	= 1 << 7,
		/**   Blue Buttons 9-16.  This is a bitfield representing 8
		  * of the generic ``blue'' buttons.
		  */
		DIGITAL2_M	= 1 << 8,
		/**   Blue Buttons 17-24.   This is a bitfield representing 8
		  * of the generic ``blue'' buttons.
		  */
		DIGITAL3_M	= 1 << 9,
		/**   Blue Buttons 25-28, Zoom, Pan.  This is a bitfield
		  * representing the last 4 of the generic ``blue'' buttons,
		  * the zoom rocker, and one-half of the pan (2d) rocker.
		  */
		DIGITAL4_M	= 1 << 10,
		/**   Pan, Cab Buttons. This is a bitfield representing
		  * the second half of the pan (2d) rocker, and several
		  * of the two of the cab rocker switches.
		  */
		DIGITAL5_M	= 1 << 11,
		/**   Cab Buttons, whistle. This is a bitfield representing
		  * the cab buttons and the whistle lever.
		  */
		DIGITAL6_M	= 1 << 12
	};
	/**   \Label{Class:RDEvent:eventcodes}
	  * Event Codes.  These are the event codes for the Rail Driver's report
	  * message.  There is a code for each of the thirteen bytes in the 
	  * report buffer.
	  */
	enum Eventcodes {
		/**   No bits set.
		  */
		NONE		= 0,
		/**   Reverser lever.  This is a value between 0 and 255
		  * representing the position of the reverser lever.
		  */
		REVERSER,
		/**   Throttle lever. This is a value between 0 and 255
		  * representing the position of the throttle / dynamic brake 
		  * lever.
		  */
		THROTTLE,
		/**   Automatic Brake lever.  This is a value between 0 and 255
		  * representing the position of the automatic brake lever.
		  */
		AUTOBRAKE,
		/**   Independent Brake lever. This is a value between 0 and 255
		  *  representing the position of the independent brake lever.
		  */
		INDEPENDBRK,
		/**   Independent Brake bail off. This is a value between 0 and
		  * 255 representing the position of the independent brake lever
		  * bail off.
		  */
		BAILOFF,
		/**   Wiper switch.  This is a value between 0 and 255
		  * representing the position of the wiper switch.
		  */
		WIPER,
		/**   Headlight switch.  This is a value between 0 and 255
		  * representing the position of the headlight switch.
		  */
		HEADLIGHT,
		/**   Blue Buttons 1-8.  This is a bitfield representing 8
		  * of the generic ``blue'' buttons.
		  */
		DIGITAL1,
		/**   Blue Buttons 9-16.  This is a bitfield representing 8
		  * of the generic ``blue'' buttons.
		  */
		DIGITAL2,
		/**   Blue Buttons 17-24.   This is a bitfield representing 8
		  * of the generic ``blue'' buttons.
		  */
		DIGITAL3,
		/**   Blue Buttons 25-28, Zoom, Pan.  This is a bitfield
		  * representing the last 4 of the generic ``blue'' buttons,
		  * the zoom rocker, and one-half of the pan (2d) rocker.
		  */
		DIGITAL4,
		/**   Pan, Cab Buttons.  This is a bitfield representing
		  * the second half of the pan (2d) rocker, and several
		  * of the two of the cab rocker switches.
		  */
		DIGITAL5,
		/**   Cab Buttons, Whistle. This is a bitfield representing
		  * the cab buttons and the whistle lever.
		  */
		DIGITAL6
	};
	/**   Constructor. The argument is the pathname under the
	  *   #/proc/bus/usb/# directory that identifies the specific device.
	  *   Finds and opens the device and initializes various data objects,
	  *   generally preparing for I/O to the connnected rail driver
	  *   console.
	  *    @param device pathname under the #/proc/bus/usb/# directory 
	  *	that identifies the specific device.
	  */
	RaildriverIO(const char *device);
	/**   Destructor. Closes the device and free up system resources.
	  */
	~RaildriverIO();
	/**   Set the Speedometer LEDs. Does a bulk write to set the
	  * speedometer LEDs on the Raid Driver unit.
	  */
	void SetLEDS(const char *ledstring);
	/**  Turn the speaker on.
	  */
	void SpeakerOn();
	/**  Turn the speaker off.
	  */
	void SpeakerOff();
	/**  Get Reverser value (0-255).
	  */
	unsigned char GetReverser() const {return RDInput.theBytes.Reverser;}
	/**  Get Throttle value (0-255).
	  */
	unsigned char GetThrottle() const {return RDInput.theBytes.Throttle;}
	/**  Get Auto Brake value (0-255).
	  */
	unsigned char GetAutoBrake() const {return RDInput.theBytes.AutoBrake;}
	/**  Get Indepenent Brake value (0-255).
	  */
	unsigned char GetIndependBrake() const {
		return RDInput.theBytes.IndependBrake;
	}
	/**  Get Bail Off value (0-255).
	  */
	unsigned char GetBailOff() const {return RDInput.theBytes.BailOff;}
	/**  Get Headlight value (0-255).
	  */
	unsigned char GetHeadlight() const {return RDInput.theBytes.Headlight;}
	/**  Get Wiper value (0-255).
	  */
	unsigned char GetWiper() const {return RDInput.theBytes.Wiper;}
	/**  Get Blue Button 1.
	  */
	bool GetBlueButton1() const {
		return (RDInput.theBytes.Digital1 & 0x01) != 0;
	}
	/**  Get Blue Button 2.
	  */
	bool GetBlueButton2() const {
		return (RDInput.theBytes.Digital1 & 0x02) != 0;
	}
	/**  Get Blue Button 3.
	  */
	bool GetBlueButton3() const {
		return (RDInput.theBytes.Digital1 & 0x04) != 0;
	}
	/**  Get Blue Button 4.
	  */
	bool GetBlueButton4() const {
		return (RDInput.theBytes.Digital1 & 0x08) != 0;
	}
	/**  Get Blue Button 5.
	  */
	bool GetBlueButton5() const {
		return (RDInput.theBytes.Digital1 & 0x10) != 0;
	}
	/**  Get Blue Button 6.
	  */
	bool GetBlueButton6() const {
		return (RDInput.theBytes.Digital1 & 0x20) != 0;
	}
	/**  Get Blue Button 7.
	  */
	bool GetBlueButton7() const {
		return (RDInput.theBytes.Digital1 & 0x40) != 0;
	}
	/**  Get Blue Button 8.
	  */
	bool GetBlueButton8() const {
		return (RDInput.theBytes.Digital1 & 0x080) != 0;
	}
	/**  Get Blue Button 9.
	  */
	bool GetBlueButton9() const {
		return (RDInput.theBytes.Digital2 & 0x01) != 0;
	}
	/**  Get Blue Button 10.
	  */
	bool GetBlueButton10() const {
		return (RDInput.theBytes.Digital2 & 0x02) != 0;
	}
	/**  Get Blue Button 11.
	  */
	bool GetBlueButton11() const {
		return (RDInput.theBytes.Digital2 & 0x04) != 0;
	}
	/**  Get Blue Button 12.
	  */
	bool GetBlueButton12() const {
		return (RDInput.theBytes.Digital2 & 0x08) != 0;
	}
	/**  Get Blue Button 13.
	  */
	bool GetBlueButton13() const {
		return (RDInput.theBytes.Digital2 & 0x10) != 0;
	}
	/**  Get Blue Button 14.
	  */
	bool GetBlueButton14() const {
		return (RDInput.theBytes.Digital2 & 0x20) != 0;
	}
	/**  Get Blue Button 15.
	  */
	bool GetBlueButton15() const {
		return (RDInput.theBytes.Digital2 & 0x40) != 0;
	}
	/**  Get Blue Button 16.
	  */
	bool GetBlueButton16() const {
		return (RDInput.theBytes.Digital2 & 0x080) != 0;
	}
	/**  Get Blue Button 17.
	  */
	bool GetBlueButton17() const {
		return (RDInput.theBytes.Digital3 & 0x01) != 0;
	}
	/**  Get Blue Button 18.
	  */
	bool GetBlueButton18() const {
		return (RDInput.theBytes.Digital3 & 0x02) != 0;
	}
	/**  Get Blue Button 19.
	  */
	bool GetBlueButton19() const {
		return (RDInput.theBytes.Digital3 & 0x04) != 0;
	}
	/**  Get Blue Button 20.
	  */
	bool GetBlueButton20() const {
		return (RDInput.theBytes.Digital3 & 0x08) != 0;
	}
	/**  Get Blue Button 21.
	  */
	bool GetBlueButton21() const {
		return (RDInput.theBytes.Digital3 & 0x10) != 0;
	}
	/**  Get Blue Button 22.
	  */
	bool GetBlueButton22() const {
		return (RDInput.theBytes.Digital3 & 0x20) != 0;
	}
	/**  Get Blue Button 23.
	  */
	bool GetBlueButton23() const {
		return (RDInput.theBytes.Digital3 & 0x40) != 0;
	}
	/**  Get Blue Button 24.
	  */
	bool GetBlueButton24() const {
		return (RDInput.theBytes.Digital3 & 0x080) != 0;
	}
	/**  Get Blue Button 25.
	  */
	bool GetBlueButton25() const {
		return (RDInput.theBytes.Digital4 & 0x01) != 0;
	}
	/**  Get Blue Button 26.
	  */
	bool GetBlueButton26() const {
		return (RDInput.theBytes.Digital4 & 0x02) != 0;
	}
	/**  Get Blue Button 27.
	  */
	bool GetBlueButton27() const {
		return (RDInput.theBytes.Digital4 & 0x04) != 0;
	}
	/**  Get Blue Button 28.
	  */
	bool GetBlueButton28() const {
		return (RDInput.theBytes.Digital4 & 0x08) != 0;
	}
	/**  Get Zoom Up.
	  */
	bool GetZoomUp() const {
		return (RDInput.theBytes.Digital4 & 0x10) != 0;
	}
	/**  Get Zoom Down.
	  */
	bool GetZoopDown() const {
		return (RDInput.theBytes.Digital4 & 0x20) != 0;
	}
	/**  Get Pan Up.
	  */
	bool GetPanUp() const {
		return (RDInput.theBytes.Digital4 & 0x40) != 0;
	}
	/**  Get Pan Right.
	  */
	bool GetPanRight() const {
		return (RDInput.theBytes.Digital4 & 0x080) != 0;
	}
	/**  Get Pan Down.
	  */
	bool GetPanDown() const {
		return (RDInput.theBytes.Digital5 & 0x01) != 0;
	}
	/**  Get Pan Left.
	  */
	bool GetPanLeft() const {
		return (RDInput.theBytes.Digital5 & 0x02) != 0;
	}
	/**  Get Range Up.
	  */
	bool GetRangeUp() const {
		return (RDInput.theBytes.Digital5 & 0x04) != 0;
	}
	/**  Get Range Down.
	  */
	bool GetRangeDown() const {
		return (RDInput.theBytes.Digital5 & 0x08) != 0;
	}
	/**  Get  Emergency Brake Up.
	  */
	bool GetEBrakeUp() const {
		return (RDInput.theBytes.Digital5 & 0x10) != 0;
	}
	/**  Get Emergency Brake Down.
	  */
	bool GetEBrakeDown() const {
		return (RDInput.theBytes.Digital5 & 0x20) != 0;
	}
	/**  Get Alert.
	  */
	bool GetAlert() const {
		return (RDInput.theBytes.Digital5 & 0x40) != 0;
	}
	/**  Get Sand.
	  */
	bool GetSand() const {
		return (RDInput.theBytes.Digital5 & 0x080) != 0;
	}
	/**  Get Pantograph.
	  */
	bool GetPantograph() const {
		return (RDInput.theBytes.Digital6 & 0x01) != 0;
	}
	/**  Get Bell.
	  */
	bool GetBell() const {
		return (RDInput.theBytes.Digital6 & 0x02) != 0;
	}
	/**  Get Whistle Up.
	  */
	bool GetWhistleUp() const {
		return (RDInput.theBytes.Digital6 & 0x04) != 0;
	}
	/**  Get Whistle Down.
	  */
	bool GetWhistleDown() const {
		return (RDInput.theBytes.Digital6 & 0x08) != 0;
	}
	/**  Get Product Code Id.  This is a unsigned char value filled in upon
	  * reading the input report buffer from the Raildriver.
	  */
	unsigned char GetProductCodeId() const {
		return RDInput.theBytes.ProductCodeId;
	}
	/**   Poll the interface. Called in the event loop.  Returns true
	  * if something has changed, that is if any of the bytes in the freshly
	  * read report buffer are different from the stored report buffer.
	  *  @param mask Mask of changed bits. This parameter is updated to
	  * reflect any changed state information.
	  */
	bool ReadInputs(Eventmask_bits &mask);
private:
	/**   Default constructor.  This constructor is never called.  It is
	  * made private to force a compiler error if an attempt is made to
	  * use it.
	  * 
	  */
	RaildriverIO() {};
	/**  Rail Driver vendor code.  This is the vendor code PI Engineering
	  * was granted for their USB products.
	  */
	static const unsigned short int PIEngineering;
	/**  Rail Driver product code. This is the product PI Engineering
	  * uses for their Rail Driver consoles.
	  */
	static const unsigned short int RailDriverModernDesktop;
	/**  Find the Rail Driver device.  Walk down the USB device tree finding
	  * our device.  This function is used during initialization to get the
	  * proper USB handle we need to perform input and output to the 
	  * Rail Driver console.
	  *  @param device The device name under #/proc/bus/usb/# as provided
	  * by the Hotplug service.
	  */
	bool FindRailDriver(const char *device);
	/**  The interface we will be using.  This is the interface index.
	  */
	int theInterface;
	/**  Rail Driver Device.  This is the USB device structure for the
	  * device.
	  */
	struct usb_device *rdriverdev;
	/**  Rail Driver handle.  This is the USB I/O handle which will be
	  * used to perform input and output operations on the Rail Driver
	  * console.
	  */
	usb_dev_handle *rdHandle;
	/**  LED Command code.  This is the command code used to change the LED
	  * display.
	  */
	static const int LEDCommand;
	/**  Speaker command code.  This is the command code used to toggle the
	  * speaker state.
	  */
	static const int SpeakerCommand;
	/** @name RDInput
	  * @type union
	  * Event data.  This is the report buffer used to hold the state of
	  * all of the levers, switches, and buttons on the Rail Driver console.
	  * It is a union of a fourteen byte buffer and a struct of bytes, one
	  * for each lever or switch or bit fields representing single buttons.
	  */
	union {
		/**   Event Buffer.  This is the I/O buffer used to hold the
		  * information about the state of the Rail Driver console.
		  */
		unsigned char ReportBuffer[14];
		/** @name theBytes
		  * @type struct
		  * Event Buffer Bytes.  These are the individual bytes or
		  * bitfields representing the Rail Driver console state.
		  */
		struct bytes {
			/**   Reverser lever, 0-255.
			  */
			unsigned char Reverser;
			/**   Throttle / Dynamic Brake lever, 0-255.
			  */
			unsigned char Throttle;
			/**   Automatic Brake lever, 0-255.
			  */
			unsigned char AutoBrake;
			/**   Independent Brake lever, 0-255.
			  */
			unsigned char IndependBrake;
			/**   Bail Off (Independent Brake lever), 0-255.
			  */
			unsigned char BailOff;
			/**   Wiper switch,  0-255.
			  */
			unsigned char Wiper;
			/**   Headlight switch, 0-255.
			  */
			unsigned char Headlight;
			/**   Blue Buttons 1-8.  This is an 8-bit bit field.
			  */
			unsigned char Digital1;
			/**   Blue Buttons 9-16.  This is an 8-bit bit field.
			  */
			unsigned char Digital2;
			/**   Blue Buttons 17-24.  This is an 8-bit bit field.
			  */
			unsigned char Digital3;
			/**   Blue Buttons 25-28, Zoom, Pan Buttons.  This is
			  * an 8-bit bit field.
			  */
			unsigned char Digital4;
			/**   Pan, Cab buttons.  This is an 8-bit bit field.
			  */
			unsigned char Digital5;
			/**   Cab Buttons, Whistle Switch.  This is an 8-bit
			  * bit field.
			  */
			unsigned char Digital6;
			/**   Product Code Id, usually 210.
			  */
			unsigned char ProductCodeId;
		} theBytes;
	} RDInput;
};



#endif // _RAILDRIVERIO_H_

