/* 
 * ------------------------------------------------------------------
 * sl2.h - Azatrax SL2 Class
 * Created by Robert Heller on Mon Jun 25 13:14:20 2012
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

#ifndef _SL2_H_
#define _SL2_H_

#include <Azatrax.h>

/** @addtogroup Azatrax
  * @{
  */

namespace azatrax {

#ifdef SWIG
%nodefaultctor SL2;
#endif
  
/** @brief SL2 I/O Class.
  *
  * SL2 interface class.
  *
  * This class implements the interface logic for a SL2-U device.
  *
  * The constructor opens a connection to a SL2-U device, given
  * its serial number.  Each SL2-U device has a unique, factory
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

class SL2 : public Azatrax {
#ifndef SWIGTCL8
	/** Base constructor.
	  *
	  * @param serialnumber The serial number of the device to open.
	  * @param outmessage To hold an error message, if any.
	  */
	SL2(const char *serialnumber, char **outmessage=NULL) :
		Azatrax(serialnumber,idSL2Product,outmessage) {}
	friend class Azatrax;
#endif
public:
	~SL2() {}
	/** @brief Sets output terminal Q1 to positive, Q2 to negative. */
	ErrorCode SetQ1posQ2neg() const {return sendByte(cmd_Q1posQ2neg);}
	/** @brief Sets output terminal Q1 to negative, Q2 to positive. */
	ErrorCode SetQ1negQ2pos() const {return sendByte(cmd_Q1negQ2pos);}
	/** @brief Outputs Q1 & Q2 both set to open circuit (disconnects switch machine #1)  */
	ErrorCode SetQ1Q2open() const {return sendByte(cmd_Q1Q2open);}
	/** @brief Sets output terminal Q3 to positive, Q4 to negative. */
	ErrorCode SetQ3posQ4neg() const {return sendByte(cmd_Q3posQ4neg);}
	/** @brief Sets output terminal Q3 to negative, Q4 to positive. */
	ErrorCode SetQ3negQ4pos() const {return sendByte(cmd_Q3negQ4pos);}
	/** @brief Outputs Q3 & Q4 both set to open circuit (disconnects switch machine #2)  */
	ErrorCode SetQ3Q4open() const {return sendByte(cmd_Q3Q4open);}
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
	bool Sense_1() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_1 == 1;
	}
	/** Sense 2, return true if input line 2 was activated since last get status. */
	bool Sense_2() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_2 == 1;
	}
	/** Sense 3, return true if input line 3 was activated since last get status. */
	bool Sense_3() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_3 == 1;
	}
	/** Sense 4, return true if input line 4 was activated since last get status. */
	bool Sense_4() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.sense_4 == 1;
	}
	/** Motor 1 direction, return true if Q1 is positive. */
	bool Motor_1_Direction() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.motor_1_direction == 1;
	}
	/** Motor 1 state, return true if Q1 and Q2 are on. */
	bool Motor_1_State() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.motor_1_state == 1;
	}
	/** Motor 2 direction, return true if Q3 is positive. */
	bool Motor_2_Direction() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.motor_2_direction == 1;
	}
	/** Motor 2 state, return true if Q3 and Q4 are on. */
	bool Motor_2_State() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.motor_2_state == 1;
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
#ifndef SWIGTCL8
private:
	/** Status byte 1 union type (Output states) */
	union status1_union {
		/** Status byte as a byte */
		uint8_t theByte;
		/** Status byte as bit fields */
		struct {
			/** Motor 1 direction */
			unsigned int motor_1_direction:1;
			/** Motor 1 state */
			unsigned int motor_1_state:1;
			/** Motor 2 direction */
			unsigned int motor_2_direction:1;
			/** Motor 2 state */
			unsigned int motor_2_state:1;
			/** Reserved bits */
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
			unsigned int reservered:4;
		} theBits;
	};
	/** Status byte 3 union type (Input control state) */
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

#endif // _SL2_H_

