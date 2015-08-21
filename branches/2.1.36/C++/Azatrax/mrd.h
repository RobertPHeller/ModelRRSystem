/* 
 * ------------------------------------------------------------------
 * mrd.h - Azatrax MRD Class
 * Created by Robert Heller on Mon Jun 25 13:02:55 2012
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

#ifndef _MRD_H_
#define _MRD_H_

#include <Azatrax.h>

/** @addtogroup Azatrax
  * @{
  */

namespace azatrax {

#ifdef SWIG
%nodefaultctor MRD;
#endif
  
/** @brief MRD I/O Class.
  *
  * MRD interface class.
  *
  * This class implements the interface logic for a MRD2-S or MRD2-U device.
  *
  * The constructor opens a connection to a MRD2-S or MRD2-U device, given
  * its serial number.  Each MRD2-S or MRD2-U device has a unique, factory
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

class MRD : public Azatrax {
#ifndef SWIGTCL8
protected:
	/** Base constructor.
	  *
	  * @param serialnumber The serial number of the device to open.
	  * @param outmessage To hold an error message, if any.
	  */
	MRD(const char *serialnumber, char **outmessage=NULL) :
		Azatrax(serialnumber,idMRDProduct,outmessage) {}
	friend class Azatrax;
#endif
public:
#ifdef SWIGTCL8
	enum OperatingMode_Type { NonTurnoutSeparate,
				  NonTurnoutDirectionSensing, 
				  TurnoutSolenoid, 
				  TurnoutMotor };
#else
	/** Operating Mode codes. */
	enum OperatingMode_Type {
	/** Non Turnout, separate (-U always reports this). */
	NonTurnoutSeparate=0x31,
	/** Non Turnout, Direction Sensing */
	NonTurnoutDirectionSensing=0x32,
	/** Turnout, Solenoid (momentary action) */
	TurnoutSolenoid=0x34,
	/** Turnout, Motor (sustained action) */
	TurnoutMotor=0x37
	};
#endif
	/** Base destructor.
	  */
	~MRD() {}
	/** @brief Set channel 1 relays and status bits.
	  *
	  * Sets the relays and status bits as it a train activated
	  * channel 1 (-S, turnour mode only).
	  */
	ErrorCode SetChan1() const {return sendByte(cmd_SetChan1);}
		
	/** @brief Set channel 2 relays and status bits.
	  *
	  * Sets the relays and status bits as it a train activated
	  * channel 2 (-S, turnour mode only).
	  */
	ErrorCode SetChan2() const {return sendByte(cmd_SetChan2);}
	/** @brief Clear `ExternallyChanged' status bit.
	  *
	  * Clear `ExternallyChanged' status bit (data packet byte 2).
	  */
	ErrorCode ClearExternallyChanged() const {return sendByte(cmd_ClearExternallyChanged);}
	/** @brief Disable external changes of turnout state.
	  *
	  * Disable external changes of turnout state (-S only).
	  */
	ErrorCode DisableExternal() const {return sendByte(cmd_DisableExternal);}
	/** @brief Enable external changes of turnout state.
	  *
	  * Enable external changes of turnout state (-S only).
	  */
	ErrorCode EnableExternal() const {return sendByte(cmd_EnableExternal);}
	/** @brief Identify 2.
	  *
	  * Identify 2 - Flashes sensor 2's LED.
	  */
	ErrorCode Identify_2() const {return sendByte(cmd_Identify_2);}
	/** @brief Identify 1 and 2.
	  *
	  * Identify 1 and 2 - Flashes sensor 1 and 2 LEDs.
	  */
	ErrorCode Identify_1_2() const {return sendByte(cmd_Identify_1_2);}
	/** @brief Reset Stopwatch.
	  *
	  * ResetStopwatch - Stops the stopwatch and resets time to 0.
	  */
	ErrorCode ResetStopwatch() const {return sendByte(cmd_ResetStopwatch);}
	/** Sensor one active. */
	bool Sense_1() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.sense_1 == 1;
	}
	/** Sensor two active. */
	bool Sense_2() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.sense_2 == 1;
	}
	/** Latch one. */
	bool Latch_1() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.latch_1 == 1;
	}
	/** Latch two. */
	bool Latch_2() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.latch_2 == 1;
	}
	/** Has Relays? */
	bool HasRelays() const {
		status1_union b;
		b.theByte = stateDataPacket.status1;
		return b.theBits.modtype == 1;
	}
	/** Reset status? */
	bool ResetStatus() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.resetStatus == 1;
	}
	/** Stopwatch Ticking? */
	bool StopwatchTicking() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.stopwatchTicking == 1;
	}
	/** Externally changed? */
	bool ExternallyChanged() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.externallyChanged == 1;
	}
	/** Allowing External Changes? */
	bool AllowingExternalChanges() const {
		status2_union b;
		b.theByte = stateDataPacket.status2;
		return b.theBits.allowExternalChanges == 1;
	}
	/** @brief Operating mode.
	  *
	  * Returns the operating mode.
	  */
	OperatingMode_Type OperatingMode() const {
		return (OperatingMode_Type)stateDataPacket.operatingMode;
	}
	/** @brief Stopwatch time.
	  *
	  * Returns the current Stopwatch time.
	  *   @param fract 1/100s of a second.
	  *   @param seconds Whole seconds.
	  *   @param minutes Whole minutes.
	  *   @param hours   Whole hours.
	  */
	void Stopwatch(uint8_t &fract, uint8_t &seconds, uint8_t &minutes,
			uint8_t &hours) const {
		fract = stateDataPacket.stopwatchFract;
		seconds = stateDataPacket.stopwatchSeconds;
		minutes = stateDataPacket.stopwatchMinutes;
		hours = stateDataPacket.stopwatchHours;
	}
#ifndef SWIGTCL8
private:
	/** Status byte 1 union type */
	union status1_union {
		/** Status byte as a byte */
		uint8_t theByte;
		/** Status byte as bit fields */
		struct {
			/** Sense 1 */
			unsigned int sense_1:1;
			/** Sense 2 */
			unsigned int sense_2:1;
			/** Latch 1 */
			unsigned int latch_1:1;
			/** Latch 2 */
			unsigned int latch_2:1;
			/** Module type */
			unsigned int modtype:1;
			/** Reserved bits */
			unsigned int reserved:3;
		} theBits;
	};
	/** Status byte 2 union type */
	union status2_union {
		/** Status byte as a byte */
		uint8_t theByte;
		/** Status byte as bit fields */
		struct {
			/** Reset Status */
			unsigned int resetStatus:1;
			/** Stopwatch Ticking */
			unsigned int stopwatchTicking:1;
			/** Externally Changed */
			unsigned int externallyChanged:1;
			/** Allow External Changes */
			unsigned int allowExternalChanges:1;
			/** Reserved bits */
			unsigned int reserved:4;
		} theBits;
	};

#endif
  
};

};

/** @} */
#endif // _MRD_H_

