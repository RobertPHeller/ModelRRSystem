/* 
 * ------------------------------------------------------------------
 * sr4.h - Azatrax SR4 class
 * Created by Robert Heller on Mon Jun 25 13:16:34 2012
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2012  Robert Heller D/B/A Deepwoods Software
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

#ifndef _SR4_H_
#define _SR4_H_

#include <Azatrax.h>

/** @addtogroup Azatrax
  * @{
  */

namespace azatrax {

#ifdef SWIG
%nodefaultctor SR4;
#endif
  
/** @brief SR4 I/O Class.
  *
  * SR4 interface class.
  *
  * This class implements the interface logic for a SR4-U device.
  *
  * The constructor opens a connection to a SR4-U device, given
  * its serial number.  Each SR4-U device has a unique, factory
  * defined serial number, which is printed on a sticker attached to the
  * module. This serial number is much like the MAC address of an Ethernet
  * interface. The destructor closes the connection to the device and frees
  * any resources allocated.
  *
  * The class provides methods to send commands to the device, read back its
  * state and interrogate the state read back.  This way each class instance
  * encapsulates each device instance.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  */
  
class SR4 : public Azatrax {

#ifndef SWIGTCL8
	/** Base constructor.
	  *
	  * @param serialnumber The serial number of the device to open.
	  * @param outmessage To hold an error message, if any.
	  */
	SR4(const char *serialnumber, char **outmessage=NULL) :
		Azatrax(serialnumber,idSR4Product,outmessage) {}
	friend class Azatrax;
#endif
public:
	~SR4() {}
	/** @brief Blink relay contacts.
	  *
	  * Sets output relay contacts to blinking state.
	  *
	  * @param Q1 Blink relay Q1.
	  * @param Q2 Blink relay Q2.
	  * @param Q3 Blink relay Q3.
	  * @param Q4 Blink relay Q4.
	  * @param speed Blink speed: 0 is 4hz, 1 is 2hz, 2 is 1hz, and
	  *		 3 is .5hz.
	  */
	ErrorCode BlinkRelays(bool Q1, bool Q2, bool Q3, bool Q4,uint8_t speed) {
		uint8_t byte2;
		byte2 = 0;
		if (Q1) byte2 |= 0x01;
		if (Q2) byte2 |= 0x02;
		if (Q3) byte2 |= 0x04;
		if (Q4) byte2 |= 0x08;
		return send3Bytes(cmd_OutputRelayBlink,byte2,(speed & 0x03));
	}
	/** @brief Set output relay contacts off.
	  *
	  * @param Q1 Turn off Q1.
	  * @param Q2 Turn off Q2.
	  * @param Q3 Turn off Q3.
	  * @param Q4 Turn off Q4.
	  */
	ErrorCode RelaysOff(bool Q1, bool Q2, bool Q3, bool Q4) {
		uint8_t byte2;
		byte2 = 0;
		if (Q1) byte2 |= 0x01;
		if (Q2) byte2 |= 0x02;
		if (Q3) byte2 |= 0x04;
		if (Q4) byte2 |= 0x08;
		return send2Bytes(cmd_OutputRelayOff,byte2);
	}
	/** @brief Set output relay contacts on.
	  *
	  * @param Q1 Turn on Q1.
	  * @param Q2 Turn on Q2.
	  * @param Q3 Turn on Q3.
	  * @param Q4 Turn on Q4.
	  */
	ErrorCode RelaysOn(bool Q1, bool Q2, bool Q3, bool Q4) {
		uint8_t byte2;
		byte2 = 0;
		if (Q1) byte2 |= 0x01;
		if (Q2) byte2 |= 0x02;
		if (Q3) byte2 |= 0x04;
		if (Q4) byte2 |= 0x08;
		return send2Bytes(cmd_OutputRelayOn,byte2);
	}
	/** @brief Pulse output relay contacts.
	  *
	  * @param Q1 Pulse Q1.
	  * @param Q2 Pulse Q2.
	  * @param Q3 Pulse Q3.
	  * @param Q4 Pulse Q4.
	  * @param duration Pulse duration in 0.5 second units.
	  */
	ErrorCode PulseRelays(bool Q1, bool Q2, bool Q3, bool Q4,uint8_t duration) {
		uint8_t byte2;
		byte2 = 0;
		if (Q1) byte2 |= 0x01;
		if (Q2) byte2 |= 0x02;
		if (Q3) byte2 |= 0x04;
		if (Q4) byte2 |= 0x08;
		return send3Bytes(cmd_OutputRelayPulse,byte2,duration);
	}
	/** @brief Enable/Disable descrete input lines from affecting outputs.
	  *
	  * When enabled, I1 & I2 affect Q1 & Q2 (switch 1), I3 & I4 affect Q3 & Q4
	  * (switch 2).
	  *
	  * @param I1 Enable/Disable I1.
	  * @param I2 Enable/Disable I2.
	  * @param I3 Enable/Disable I3.
	  * @param I4 Enable/Disable I4.
	  */
	  ErrorCode OutputRelayInputControl(bool I1, bool I2,
					    bool I3, bool I4) {
	  	uint8_t byte2;
	  	byte2 = 0;
		if (I1) byte2 |= 0x01;
		if (I2) byte2 |= 0x02;
		if (I3) byte2 |= 0x04;
		if (I4) byte2 |= 0x08;
		return send2Bytes(cmd_OutputRelayInputControl,byte2);
	}
	/** Sense 1, return true if input line 1 was activated since last get status. */
	bool Sense_1_Latch() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_1 == 1;
	}
	/** Sense 2, return true if input line 2 was activated since last get status. */
	bool Sense_2_Latch() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_2 == 1;
	}
	/** Sense 3, return true if input line 3 was activated since last get status. */
	bool Sense_3_Latch() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_3 == 1;
	}
	/** Sense 4, return true if input line 4 was activated since last get status. */
	bool Sense_4_Latch() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_4 == 1;
	}
	/** Q1 state, return true if Q1 is closed. */
	bool Q1_State() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.Q1_state == 1;
	}
	/** Q2 state, return true if Q2 is closed. */
	bool Q2_State() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.Q2_state == 1;
	}
	/** Q3 state, return true if Q3 is closed. */
	bool Q3_State() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.Q3_state == 1;
	}
	/** Q4 state, return true if Q4 is closed. */
	bool Q4_State() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.Q4_state == 1;
	}
	/** Input 1 enabled? Return true if I1 can affect outputs. */
	bool Input_1_Enabled() const {
		status3_union b;
		b.theByte = stateDataPacket.status3;
		return b.theBits.input_1_enabled == 1;
	}
	/** Input 2 enabled? Return true if I2 can affect outputs. */
	bool Input_2_Enabled() const {
		status3_union b;
		b.theByte = stateDataPacket.status3;
		return b.theBits.input_2_enabled == 1;
	}
	/** Input 3 enabled? Return true if I3 can affect outputs. */
	bool Input_3_Enabled() const {
		status3_union b;
		b.theByte = stateDataPacket.status3;
		return b.theBits.input_3_enabled == 1;
	}
	/** Input 4 enabled? Return true if I4 can affect outputs. */
	bool Input_4_Enabled() const {
		status3_union b;
		b.theByte = stateDataPacket.status3;
		return b.theBits.input_4_enabled == 1;
	}
	/** Sense 1, return true if input line 1 is now activated. */
	bool Sense_1_Live() const {
		status2_union b;
		b.theByte = stateDataPacket.status4;
		return b.theBits.sense_1 == 1;
	}
	/** Sense 2, return true if input line 2 is now activated. */
	bool Sense_2_Live() const {
		status2_union b;
		b.theByte = stateDataPacket.status4;
		return b.theBits.sense_2 == 1;
	}
	/** Sense 3, return true if input line 3 is now activated. */
	bool Sense_3_Live() const {
		status2_union b;
		b.theByte = stateDataPacket.status4;
		return b.theBits.sense_3 == 1;
	}
	/** Sense 4, return true if input line 4 is now activated. */
	bool Sense_4_Live() const {
		status2_union b;
		b.theByte = stateDataPacket.status4;
		return b.theBits.sense_4 == 1;
	}
#ifndef SWIGTCL8
private:
	/** Status byte 1 union type (Outputs)*/
	union status1_union {
		/** Status byte as a byte */
		uint8_t theByte;
		/** Status byte as bit fields */
		struct {
			/** Q1 state */
			unsigned int Q1_state:1;
			/** Q2 state */
			unsigned int Q2_state:1;
			/** Q3 state */
			unsigned int Q3_state:1;
			/** Q4 state */
			unsigned int Q4_state:1;
			/** reserved bits */
			unsigned int reservered:4;
		} theBits;
	};
	/** Status byte 2 union type (Input sense) */
	union status2_union {
		/** Status byte as a byte */
		uint8_t theByte;
		/** Status byte as bit fields */
		struct {
			/** Sense 1 */
			unsigned int sense_1:1;
			/** Sense 2 */
			unsigned int sense_2:1;
			/** Sense 3 */
			unsigned int sense_3:1;
			/** Sense 4 */
			unsigned int sense_4:1;
			/** Reserved bits */
			unsigned int reserved:4;
		} theBits;
	};
	/** Status byte 3 union type (Input Control Status) */
	union status3_union {
		/** Status byte as a byte */
		uint8_t theByte;
		/** Status byte as bit fields */
		struct {
			/** Input 1 enabled? */
			unsigned int input_1_enabled:1;
			/** Input 2 enabled? */
			unsigned int input_2_enabled:1;
			/** Input 3 enabled? */
			unsigned int input_3_enabled:1;
			/** Input 4 enabled? */
			unsigned int input_4_enabled:1;
			/** Reserved bits */
			unsigned int reserved:4;
		} theBits;
	};
#endif
};

};

/** @} */
#endif // _SR4_H_

