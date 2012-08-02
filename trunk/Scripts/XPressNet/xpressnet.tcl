#* 
#* ------------------------------------------------------------------
#* xpressnet.tcl - XPressNet interface entirely in Tcl
#* Created by Robert Heller on Tue Apr 24 12:09:32 2012
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2012  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 


## @defgroup XPressNetModule XPressNetModule
# @brief XPressNet interface code.
#
# These are Tcl SNIT classes that interface to the Lenz XPressNet
# interface used on Lenz DCC Command Units.  There is a low-level collection
# of Tcl SNIT classes that handles the low-level Serial I/O interface and there
# is a higher level interface that defines a Tcl Event to handle the
# asyncronious aspects of the low-level XPressNet serial I/O, by entering the
# Lenz XPressnet interface into Tcl's Event processing system.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @{

package require gettext
package require snit

namespace eval xpressnet {
  ## @brief Namespace that holds the XPressNet interface code.
  #
  # This is a cross-platform implementation the XPressNet serial port interface.
  # Based on documentation provided by Lenz Elektronik
  # GMBH (6/2003 third edition). This code works with Tcl 8.4 and later and
  # uses SNIT to implement the classes as snit::types.
  #
  # Basically, the way this code works is to use a class to interface to the
  # serial port attached to one of Lenz's serial port adapters (LI100, LI100F,
  # or LI101). This code should also work with the LiUSB interface as well.
  #
  #
  # @author Robert Heller \<heller\@deepsoft.com\>
  #
  # @section xpressnet_package Package provided
  #
  # Xpressnet 2.0.0
  #

  snit::enum TypeCode -values {
  ## @enum TypeCode
  # Response types.
  #
	NO_RESPONSE_AVAILABLE 
	## No response available.
	NORMAL_OPERATION_RESUMED
	## Normal operation resumed.
	TRACK_POWER_OFF 
	## Track power off.
	EMERGENCY_STOP 
	##   Emergency stop.
	SERVICE_MODE_ENTRY 
	##   Service mode entry.
	PROGRAMMING_INFO_SHORT_CIRCUIT
	##   Programming info. ``short-circuit''.
	PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND
	##   Programming info. ``data byte not found''.
	PROGRAMMING_INFO_COMMAND_STATION_BUSY
	##   Programming info. ``command station busy''.
	PROGRAMMING_INFO_COMMAND_STATION_READY
	##   Programming info. ``command station ready''.
	SERVICE_MODE_RESPONSE 
	##   Service mode response.
	SOFTWARE_VERSION
	##   Software version.
	COMMAND_STATION_STATUS 
	##   Command station status.
	TRANSFER_ERRORS
	##   Transfer errors.
	COMMAND_STATION_BUSY 
	##   Command station busy.
	INSTRUCTION_NOT_SUPPORTED
	##   Instruction not supported by command station.
	ACCESSORY_DECODER_INFORMATION
	##   Accessory decoder information.
	LOCOMOTIVE_INFORMATION 
	##   Locomotive information.
	FUNCTION_STATUS
	##   Function status.
	LOCOMOTIVE_ADDRESS 
	##   Locomotive address.
	DOUBLE_HEADER_INFORMATION
	##   Double header information.
	DOUBLE_HEADER_MU_ERROR 
	##   Double header or MU error.
	LI100_MESSAGE
	##   LI100 Messages.
	LI100_VERSION 
	##   LI100 Version Numbers.
	LI101_XPRESSNET_ADDRESS
	##   LI101 XPressNet Address.
  }
  snit::integer nibble -min 0 -max 0x0f
  ## @typedef int nibble
  # A 4 bit unsigned integer.

  snit::integer ubyte -min 0 -max 0x0ff
  ## @typedef unsigned char ubyte
  # An 8 bit unsigned integer.

  snit::enum PowerUpMode -values {
  ## @enum PowerUpMode
  # Power up modes
    Manual
    ## Manual mode.
    Automatic
    ## Automatic mode.
  }

  snit::integer DecoderLongAddress -min 0 -max 0x3fff
  ## @typedef short int DecoderLongAddress
  # Decoder address, an unsigned 14 bit integer.

  snit::enum NibbleCode -values {
  ## @enum NibbleCode
  # Accessory nibble code.
    Lower
    ## Lower nibble.
    Upper
    ## Upper nibble.
  }
  snit::integer ElementAddress -min 0 -max 0x03
  ## @typedef int ElementAddress
  # A 2 bit unsigned integer
  snit::integer S_14 -min 0 -max 14
  ## @typedef int S_14
  # 14 Speed steps.
  snit::integer S_27 -min 0 -max 27
  ## @typedef int S_27
  # 27 Speed steps.
  snit::integer S_28 -min 0 -max 28
  ## @typedef int S_28
  # 28 Speed steps.
  snit::integer S_128 -min 0 -max 126
  ## @typedef int S_128
  # 128 Speed steps.
  snit::integer u10 -min 0 -max 0x3ff
  ## @typedef int u10 
  # An unsigned 10 bit integer.
  snit::integer u3 -min 0 -max 0x07
  ## @typedef int u3
  # An unsigned 3 bit integer.
  snit::integer u7 -min 0 -max 0x7f
  ## @typedef int u7
  # An unsigned 7 bit integer.
  snit::integer ConsistAddress -min 1 -max 99
  ## @typedef int ConsistAddress
  # Multi-unit Address.

  snit::type CommandStationResponse {
    ## @brief General response class.
    #
    # All responses are delegated from this class, via a component element.
    #
    # @param -responsetype This readonly option contains the response type and
    # 		determines the type of object installed in the actual response
    #		component.
    # @par
    # Additional parameters are passed to the actual response constructors.
    # @author Robert Heller \<heller\@deepsoft.com\>
    #
    component actualresponse
    delegate method * to actualresponse

    option -responsetype -readonly yes -default NO_RESPONSE_AVAILABLE \
		-type xpressnet::TypeCode

    variable _time_stamp
    ## @private Holds the time stamp of the response.
    method TimeStamp {} {
      ## Return the time stamp of the response.
      return $_time_stamp
    }
    method ResponseType {} {
      ## Return the response type.
      return $options(-responsetype)
    }
    constructor {args} {
      ## @brief Constructor.
      #  Construct a response object. The actual response is installed as a
      # component of this object.
      #
      # @param -responsetype This readonly option contains the response type and
      # 	determines the type of object installed in the actual response
      #		component.
      # @par
      # Additional parameters are passed to the actual response constructors.
      #

      puts stderr "*** $type create $args"
      set options(-responsetype) [from args -responsetype]
      set _time_stamp [clock clicks -milliseconds]
      switch $options(-responsetype) {
	NO_RESPONSE_AVAILABLE -
	NORMAL_OPERATION_RESUMED -
	EMERGENCY_STOP -
	TRACK_POWER_OFF -
	SERVICE_MODE_ENTRY -
	PROGRAMMING_INFO_SHORT_CIRCUIT -
	PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND -
	PROGRAMMING_INFO_COMMAND_STATION_BUSY -
	PROGRAMMING_INFO_COMMAND_STATION_READY -
	TRANSFER_ERRORS -
	COMMAND_STATION_BUSY -
	INSTRUCTION_NOT_SUPPORTED {
	}
	SERVICE_MODE_RESPONSE {
	  set actualresponse [eval [list xpressnet::ServiceModeResponse %%AUTO%%] $args]
	}
	SOFTWARE_VERSION {
	  set actualresponse [eval [list xpressnet::SoftwareVersion %%AUTO%%] $args]
	}
	COMMAND_STATION_STATUS {
	  set actualresponse [eval [list xpressnet::CommandStationStatus %%AUTO%%] $args]
	}
	ACCESSORY_DECODER_INFORMATION {
	  set actualresponse [eval [list xpressnet::AccessoryDecoderInformation %%AUTO%%] $args]
	}
	LOCOMOTIVE_INFORMATION {
	  set actualresponse [eval [list xpressnet::LocomotiveInformation %%AUTO%%] $args]
	}
	FUNCTION_STATUS {
	  set actualresponse [eval [list xpressnet::FunctionStatus %%AUTO%%] $args]
	}
	LOCOMOTIVE_ADDRESS {
	  set actualresponse [eval [list xpressnet::LocomotiveAddress %%AUTO%%] $args]
	}
	DOUBLE_HEADER_INFORMATION {
	  set actualresponse [eval [list xpressnet::DoubleHeaderInformation %%AUTO%%] $args]
	}
	DOUBLE_HEADER_MU_ERROR {
	  set actualresponse [eval [list xpressnet::DoubleHeaderMuError %%AUTO%%] $args]
	}
	LI100_MESSAGE {
	  set actualresponse [eval [list xpressnet::LI100Message %%AUTO%%] $args]
	}
	LI100_VERSION {
	  set actualresponse [eval [list xpressnet::LI100VersionNumbers %%AUTO%%] $args]
	}
	LI101_XPRESSNET_ADDRESS {
	  set actualresponse [eval [list xpressnet::LI101XPressNetAddress %%AUTO%%] $args]
	}
      }
    }
  }
  snit::type ServiceModeResponse {
    ## @brief Service mode response.
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    #

    constructor {modebits CE D} {
	## @brief Constructor.
	#  @param modebits First data byte (contains mode bit).
	#  @param CE Second data byte (contains C or E value).
	#  @param D Third data byte (contains D value).
	#

#      puts stderr "*** $type create $modebits $CE $D"
      if {$modebits == 0x10} {
	set _service_mode RegisterPaged
      } else {
	set _service_mode DirectCV
      }
      set _cv $CE
      set _data $D
    }
    method ServiceMode {} {
	##  Return the service mode.
      return $_service_mode
    }
    method CV {} {
	##  Return the CV value.
      return $_cv
    }
    method Data {} {
	##  Return the data value.
      return $_data
    }
    variable _service_mode
	## @privatesection
	##  The service mode.
    variable _cv
	##  The CV value.
    variable _data
	##  The data value.
  }
  snit::type SoftwareVersion {
## @brief Software version.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    constructor {majornibble minornibble {cst 0xff}} {
	## @brief Constructor.
	#  @param majornibble Major version number.
	#  @param minornibble Minor version number.
	#  @param cst Command station type.

#      puts stderr "*** $type create $majornibble $minornibble $cst"
      set _major $majornibble
      set _minor $minornibble
      switch [format {0x%02x} $cst] {
	0x00 {set _command_station_type LZ100}
	0x01 {set _command_station_type LH200}
	0x02 {set _command_station_type DPC}
	default {set _command_station_type Unknown}
      }
    }
    method Major {} {
	##  Return major version number.
      return $_major
    }
    method Minor {} {
	##  Return minor version number.
      return $_minor
    }
    method CommandStationTypeCode {} {
	##  Return command station type.
      return $_command_station_type
    }
    variable _major
        ## @privatesection
	##  Major version number.
    variable _minor
	##  Minor version number.
    variable _command_station_type
	##  Command station type.
  }
  snit::type CommandStationStatus {
## Command station status.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    constructor {statusbyte} {
	## @brief Constructor.
	# @param statusbyte Status byte.

#      puts stderr "*** $type create $statusbyte"
      set _emergency_off 0
      set _emergency_stop 0
      set _start_mode Manual
      set _service_mode 0
      set _poweringup 0
      set _RAM_check_error 0
      if {(statusbyte & 0x01) != 0} {set _emergency_off 1}
      if {(statusbyte & 0x02) != 0} {set _emergency_stop 1}
      if {(statusbyte & 0x04) != 0} {set _start_mode Automatic}
      if {(statusbyte & 0x08) != 0} {set _service_mode 1}
      if {(statusbyte & 0x40) != 0} {set _poweringup 1}
      if {(statusbyte & 0x080) != 0} {set _RAM_check_error 0}
    }
    method EmergencyOff {} {
	##  Return emergency off flag.
      return $_emergency_off
    }
    method EmergencyStop {} {
	##  Return emergency stop flag.
      return $_emergency_stop
    }
    method StartMode {} {
	##  Return start mode.
      return $_start_mode
    }
    method ServiceMode {} {
	##  Return service mode.
      return $_service_mode
    }
    method PoweringUp {} {
	##  Return powering up flag.
      return $_poweringup
    }
    method RAMCheckError {} {
	##  Return RAM check error flag.
      return $_RAM_check_error
    }
    variable _emergency_off
        ## @privatesection
	##  Emergency off flag.
    variable _emergency_stop
	##  Emergency stop flag.
    variable _start_mode
	##  Start mode.
    variable _service_mode
	##  Service mode flag.
    variable _poweringup
	##  Powering up flag.
    variable _RAM_check_error
	##  RAM check error flag.
  }
  snit::type AccessoryDecoderInformation {
## Accessory decoder information.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    constructor {count args} {
	## @brief Constructor.
	# @param count Number of Accessory Decoder feedback elements
	#		   (1 through 7).
	# @param args Address and data bytes.

#      puts stderr "*** $type create $count $args"
      if {$count < 0 || $count > 7} {
	set _numberOfFeedbackElements 0
	error [_ "Bad feedback element count: %d, should be between 0 and 7 inclusive." $count]
      } else {
	if {[llength $args] != ($count * 2)} {
	  set _numberOfFeedbackElements 0
	  error [_ "Arg count error: should be %d args, got %d args!" [expr {($count * 2) + 1}] [expr {[llength $args] + 1}]]
	  return
	}
	set _numberOfFeedbackElements $count
	set _address {}
	set _completed {}
	set _accessory_type {}
	set _nibble {}
	set _t1 {}
	set _t2 {}
        foreach {a itnz} $args {
	  lappend _address $a
	  if {(itnz & 0x080) != 0} {
	    lappend _completed 0
	  } else {
	    lappend _completed 1
	  }
	  switch [format {0x%02x} [expr {(itnz & 0x60) >> 5}]] {
	    0x00 {lappend _accessory_type AccessoryWithoutFeedback}
	    0x01 {lappend _accessory_type AccessoryWithFeedback}
	    0x02 {lappend _accessory_type FeedbackModule}
	    0x03 {lappend _accessory_type Reserved}
	  }
	  if {(itnz & 0x10) == 0} {
	    lappend _nibble Lower
	  } else {
	    lappend _nibble Upper
	  }
	  switch [format {0x%02x} [expr {(itnz & 0x0C) >> 2}]] {
	    0x00 {lappend _t1 NotControlled}
	    0x01 {lappend _t1 Left}
	    0x02 {lappend _t1 Right}
	    0x03 {lappend _t1 Invalid}
	  }
	  switch [format {0x%02x} [expr {(itnz & 0x03)}]] {
	    0x00 {lappend _t2 NotControlled}
	    0x01 {lappend _t2 Left}
	    0x02 {lappend _t2 Right}
	    0x03 {lappend _t2 Invalid}
	  }
	}
      }
    }
    method NumberOfFeedbackElements {} {
	##  Return the number of feedback elements.
      return $_numberOfFeedbackElements
    }
    method Address {index} {
	##  Return address.
	#  @param index Element index.
      if {$index >= 0 || $index < $_numberOfFeedbackElements} {
	return [lindex $_address $index]
      } else {
        return 0
      }
    }
    method Completed {index} {
	##  Return completed flag.
	# @param index Element index.
      if {$index >= 0 || $index < $_numberOfFeedbackElements} {
	return [lindex $_completed $index]
      } else {
        return 0
      }
    }
    method AccessoryType {index} {
	##  Return accessory type.
	# @param index Element index.
      if {$index >= 0 || $index < $_numberOfFeedbackElements} {
	return [lindex $_accessory_type $index]
      } else {
        return 0
      }
    }
    method Nibble {index} {
	##  Return nibble code.
	# @param index Element index.
      if {$index >= 0 || $index < $_numberOfFeedbackElements} {
	return [lindex $_nibble $index]
      } else {
        return 0
      }
    }
    method TurnoutStatus {index nibble} {
	##  Return turnout status.
	#  @param index Element index.
	#  @param nibble Which turnout?
      if {$index >= 0 || $index < $_numberOfFeedbackElements} {
	switch $nibble {
	  Lower {return [lindex $_t1 $index]}
	  Upper {return [lindex $_t2 $index]}
	  default {return Invalid}
	}
      } else {
        return 0
      }
    }
    variable _numberOfFeedbackElements
	## @privatesection
	##  Number of Accessory Decoder feedback elements.
    variable _address
	##  Address value.
    variable _completed
	##  Completion flag.
    variable _accessory_type
	##  Accessory type.
    variable _nibble
	##  Nibble value.
    variable _t1
	##  Lower nibble turnout status.
    variable _t2
	##  Upper nibble turnout status.
  }
  snit::enum SpeedStepModeCode -values {
	## Speed step mode code.
	S14
	##  14 speed step mode.
	S27
	##  27 speed step mode.
	S28
	##  28 speed step mode.
	S128
	##  128 speed step mode.
  }
  snit::enum DirectionCode -values {
	##  Direction flag.
	Forward
	##  Forward.
	Reverse
	##  Reverse.
  }
  snit::type LocomotiveInformation {
## Locomotive information.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    method Address {} {
	##  Return address.
      return $_address
    }
    method Available {} {
	##  Return available flag.
      return $_available
    }
    method Direction {} {
	##  Return direction.
      return $_direction
    }
    method SpeedStepMode {} {
	##  Return speed step mode.
      return $_speedstep
    }
    method Speed {} {
	##  Return speed.
      return $_speed
    }
    method Function {f} {
	##  Return function status.
	# @param f Function whose status to return.
      switch $f {
	0 {return $_function0}
	1 {return $_function1}
	2 {return $_function2}
	3 {return $_function3}
	4 {return $_function4}
	5 {return $_function5}
	6 {return $_function6}
	7 {return $_function7}
	8 {return $_function8}
	9 {return $_function9}
	10 {return $_function10}
	11 {return $_function11}
	12 {return $_function12}
	default {return 0}
      }
    }
    method MTR {} {
	##  Return Muti-unit address.
      return $_mtraddress
    }
    method Address2 {} {
	##  Return the address of second unit in double header.
      return $_address2
    }
    constructor {a {avail 0} {dir {}} {ssm {}} {s 0} {f0 0} {f1 0} {f2 0} 
		 {f3 0} {f4 0} {f5 0} {f6 0} {f7 0} {f8 0} {f9 0} {f10 0}
		 {f11 0} {f12 0} {mtraddr 0} {addr2 0xffff}} {
	## @brief Constructor.
	# @param a Locomotive address.
	# @param avail Available flag.
	# @param dir Direction.
	# @param ssm Speed step mode.
	# @param s Locomotive speed.
	# @param f0 Function 0 status.
	# @param f1 Function 1 status.
	# @param f2 Function 2 status.
	# @param f3 Function 3 status.
	# @param f4 Function 4 status.
	# @param f5 Function 5 status.
	# @param f6 Function 6 status.
	# @param f7 Function 7 status.
	# @param f8 Function 8 status.
	# @param f9 Function 9 status.
	# @param f10 Function 10 status.
	# @param f11 Function 11 status.
	# @param f12 Function 12 status.
	# @param mtraddr MTR address.
	# @param addr2 Double header address.

#      puts stderr "*** $type create $a $avail $dir $ssm $s $f0 $f1 $f2 $f3 $f4 $f5 $f6 $f7 $f8 $f9 $f10 $f11 $f12 $mtraddr $addr2"
      set _address $a
      set _available $avail
      if {$avail} {
	xpressnet::DirectionCode validate $dir
	xpressnet::SpeedStepModeCode validate $ssm
      }
      set _direction $dir
      set _speedstep $ssm
      set _speed $s
      set _function0 $f0
      set _function1 $f1
      set _function2 $f2
      set _function3 $f3
      set _function4 $f4
      set _function5 $f5
      set _function6 $f6
      set _function7 $f7
      set _function8 $f8
      set _function9 $f9
      set _function10 $f10
      set _function11 $f11
      set _function12 $f12
      set _address2 $addr2
      set _mtraddress $mtraddr
    }
    variable _address
	## @privatesection
	##  Locomotive address.
    variable _available
	##  Locomotive is available.
    variable _direction
	##  Locomotive direction.
    variable _speedstep
	##  Locomotive speed step mode.
    variable _speed
	##  Locomotive speed.
    variable _function0
	##  Function 0.
    variable _function1
	##  Function 1.
    variable _function2
	##  Function 2.
    variable _function3
	##  Function 3.
    variable _function4
	##  Function 4.
    variable _function5
	##  Function 5.
    variable _function6
	##  Function 6.
    variable _function7
	##  Function 7.
    variable _function8
	##  Function 8.
    variable _function9
	##  Function 9.
    variable _function10
	##  Function 10.
    variable _function11
	##  Function 11.
    variable _function12
	##  Function 12.
    variable _mtraddress
	##  Multi-unit address.
    variable _address2
	##  Double header address.
  }
  snit::type FunctionStatus {
## Function status.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    constructor {s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12} {
	## @brief Constructor.
	# @param s0 Function 0 is monemtary flag.
	# @param s1 Function 1 is monemtary flag.
	# @param s2 Function 2 is monemtary flag.
	# @param s3 Function 3 is monemtary flag.
	# @param s4 Function 4 is monemtary flag.
	# @param s5 Function 5 is monemtary flag.
	# @param s6 Function 6 is monemtary flag.
	# @param s7 Function 7 is monemtary flag.
	# @param s8 Function 8 is monemtary flag.
	# @param s9 Function 9 is monemtary flag.
	# @param s10 Function 10 is monemtary flag.
	# @param s11 Function 11 is monemtary flag.
	# @param s12 Function 12 is monemtary flag.

#      puts stderr "*** $type create $s0 $s1 $s2 $s3 $s4 $s5 $s6 $s7 $s8 $s9 $s10 $s11 $s12"
      set _status0 $s0
      set _status1 $s1
      set _status2 $s2
      set _status3 $s3
      set _status4 $s4
      set _status5 $s5
      set _status6 $s6
      set _status7 $s7
      set _status8 $s8
      set _status9 $s9
      set _status10 $s10
      set _status11 $s11
      set _status12 $s12
    }      
    method Status {f} {
	##  Return selected status flag.
	# @param f  Function whose status to return.
      switch $f {
	0 {return $_status0}
	1 {return $_status1}
	2 {return $_status2}
	3 {return $_status3}
	4 {return $_status4}
	5 {return $_status5}
	6 {return $_status6}
	7 {return $_status7}
	8 {return $_status8}
	9 {return $_status9}
	10 {return $_status10}
	11 {return $_status11}
	12 {return $_status12}
	default {return 0}
      }
    }
    variable _status0
	## @privatesection
	##  Status 0.
    variable _status1
	##  Status 1.
    variable _status2
	##  Status 2.
    variable _status3
	##  Status 3.
    variable _status4
	##  Status 4.
    variable _status5
	##  Status 5.
    variable _status6
	##  Status 6.
    variable _status7
	##  Status 7.
    variable _status8
	##  Status 8.
    variable _status9
	##  Status 9.
    variable _status10
	##  Status 10.
    variable _status11
	##  Status 11.
    variable _status12
	##  Status 12.
  }
  snit::type LocomotiveAddress {
## Locomotive address.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    constructor {k a} {
	## @brief Constructor.
	# @param k K (address type code).
	# @param a Address.

#      puts stderr "*** $type create $k $a"
      switch $k {
	0 {set _addressType Normal}
	1 {set _addressType DoubleHeader}
	2 {set _addressType MultiUnitBase}
	3 {set _addressType MultiUnit}
	4 {set _addressType OtherOrNone}
	default {set _addressType OtherOrNone}
      }
      set _address $a
    }
    method AddressType {} {
	##  Return address type.
      return $_addressType
    }
    method Address {} {
	##  Return address.
      return $_address
    }
    variable _addressType
	## @privatesection
	##  Address type.
    variable _address
	##  Address.
  }
  snit::type DoubleHeaderInformation {
## Double header information.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    method Address {} {
	##  Return address.
      return $_address
    }
    method Available {} {
	##  Return available flag.
      return $_available
    }
    method Direction {} {
	##  Return direction.
      return $_direction
    }
    method SpeedStepMode {} {
	##  Return speed step mode.
      return $_speedstep
    }
    method Speed {} {
	##  Return speed.
      return $_speed
    }
    method Address2 {} {
	##  Return the address of second unit in double header.
      return $_address2
    }
    method Function {f} {
	##  Return function status.
	# @param f Function whose status to return.
      switch $f {
	0 {return $_function0}
	1 {return $_function1}
	2 {return $_function2}
	3 {return $_function3}
	4 {return $_function4}
	5 {return $_function5}
	6 {return $_function6}
	7 {return $_function7}
	8 {return $_function8}
	9 {return $_function9}
	10 {return $_function10}
	11 {return $_function11}
	12 {return $_function12}
	default {return 0}
      }
    }
    method Address2 {} {
      return $_address2
    }
    constructor {a addr2 avail dir ssm s f0 f1 f2 f3 f4 {f5 0} {f6 0} {f7 0} 
		 {f8 0} {f9 0} {f10 0} {f11 0} {f12 0}} {
	## @brief Constructor.
	# @param a Locomotive address.
	# @param addr2 Double header address.
	# @param avail Available flag.
	# @param dir Direction.
	# @param ssm Speed step mode.
	# @param s Locomotive speed.
	# @param f0 Function 0 status.
	# @param f1 Function 1 status.
	# @param f2 Function 2 status.
	# @param f3 Function 3 status.
	# @param f4 Function 4 status.
	# @param f5 Function 5 status.
	# @param f6 Function 6 status.
	# @param f7 Function 7 status.
	# @param f8 Function 8 status.
	# @param f9 Function 9 status.
	# @param f10 Function 10 status.
	# @param f11 Function 11 status.
	# @param f12 Function 12 status.

#      puts stderr "*** $type create $a $addr2 $avail $dir $ssm $s $f0 $f1 $f2 $f3 $f4 $f5 $f6 $f7 $f8 $f9 $f10 $f11 $f12"
      set _address $a
      set _available $avail
      if {$avail} {
	xpressnet::DirectionCode validate $dir
	xpressnet::SpeedStepModeCode validate $ssm
      }
      set _direction $dir
      set _speedstep $ssm
      set _speed $s
      set _function0 $f0
      set _function1 $f1
      set _function2 $f2
      set _function3 $f3
      set _function4 $f4
      set _function5 $f5
      set _function6 $f6
      set _function7 $f7
      set _function8 $f8
      set _function9 $f9
      set _function10 $f10
      set _function11 $f11
      set _function12 $f12
      set _address2 $addr2
    }
    variable _address
	## @privatesection
	##  Locomotive address.
    variable _available
	##  Locomotive is available.
    variable _direction
	##  Locomotive direction.
    variable _speedstep
	##  Locomotive speed step mode.
    variable _speed
	##  Locomotive speed.
    variable _function0
	##  Function 0.
    variable _function1
	##  Function 1.
    variable _function2
	##  Function 2.
    variable _function3
	##  Function 3.
    variable _function4
	##  Function 4.
    variable _function5
	##  Function 5.
    variable _function6
	##  Function 6.
    variable _function7
	##  Function 7.
    variable _function8
	##  Function 8.
    variable _function9
	##  Function 9.
    variable _function10
	##  Function 10.
    variable _function11
	##  Function 11.
    variable _function12
	##  Function 12.
    variable _address2
	##  Double header address.
  }
  snit::enum ErrorTypeCode -values {
	##  Error type code.
	NotOperatedOr0
	##   One of the locomotives has not been operated by
	#	   the XpressNet device assembling the Double 
	#	   Header/Multi Unit or locomotive 0 was selected. 
	UsedByAnotherDevice
	##   One of the locomotives of the Double Header/Multi
	#	   Unit is being used by another XpressNet device.
	UsedInANotherDHMU
	##   One of the locomotives is already in another
	#	   Double Header/Multi Unit. 
	SpeedNotZero
	##  The speed of one of the locomotives is not zero.
	NotMU
	##  The locomotive is not a multi-unit.
	NotMUBaseAddress
	##  The locomotive is not a multi-unit base address.
	CantDelete
	##  It is not possible to delete the locomotive.
	StackFull
	##  The command station stack is full.
  }
  snit::type DoubleHeaderMuError {
## Double header or MU error.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    variable _error
	##  @private Error type.
    constructor {e} {
	## @brief Constructor.
	# @param e Error type.

#      puts stderr "*** $type create $e"
      xpressnet::ErrorTypeCode validate $e
      set _error $e
    }
    method Error {} {
	##  Return error type code.
      return $_error
    }
  }
  snit::enum MessageTypeCode -values {
  ##  Message type code.
	ErrorBetweenLI100AndPC
	##   Error occured between the interface and the PC.
	#	(Timeout durring data communication with the PC.) 
	ErrorBetweenLI100AndCommandStation
	##   Error occured between the interface and the
	#	command station. (Timeout durring data 
	#	communication with the command station.)
	UnknownCommunicationsError
	##   Unknown communication error. (Command station
	#	addressed the LI100 with request for 
	#	acknowledgement.) 
	Success
	##   Instruction was successfully sent to the command
	#	station or normal operations have resumed after a 
	#	timeout. 
	NoTimeslot
	##   The command station is no longer providing the
	#	LI100 a timeslot for communication.
	BufferOverflow
	##   Buffer overflow in the LI100.
	Other
	##   Other messages (undefined).
  }
  snit::type LI100Message {
## LI100 messages.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    variable _message_type
	## @private The message type.
    constructor {mbyte} {
	## @brief Constructor.
	# @param mbyte Message byte.

#      puts stderr "*** $type create $mbyte"
      switch $mbyte {
	1 {set _message_type ErrorBetweenLI100AndPC}
	2 {set _message_type ErrorBetweenLI100AndCommandStation}
	3 {set _message_type UnknownCommunicationsError}
	4 {set _message_type Success}
	5 {set _message_type NoTimeslot}
	6 {set _message_type BufferOverflow}
	default {set _message_type Other}
      }
    }
    method MessageType {} {
	##  Return the message type.
      return $_message_type
    }

  }
  snit::type LI100VersionNumbers {
## LI100 Version Numbers.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    variable _hardware_version
        ##  @private Hardware version.
    variable _software_version
	##  @private Software version.
    constructor {hv sv} {
	## @brief Constructor.
	# @param mbyte Message byte.

#      puts stderr "*** $type create $hv $"
      set _hardware_version $hv
      set _software_version $sv
    }
    method HardwareVersion {} {
	##  Return hardware version.
      return $_hardware_version
    }
    method SoftwareVersion {} {
	##  Return software version.
      return $_software_version
    }
  }
  snit::type LI101XPressNetAddress {
## LI101 XPress Net Address
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    variable _address
        ##  @private Address.
    constructor {addr} {
	## @brief Constructor.
	# @param mbyte Message byte.

#      puts stderr "*** $type create $addr"
      set _address $addr
    }
    method Address {} {
	##  Return XPressNet address.
      return $_address
    }
  }
  snit::type XPressNet {
## @brief Main XPressNet interface class.
#
# This class implements the interface logic to connect to the XpressNet.
#
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    variable ttyfd
	##  @private Terminal file descriptor.
    variable responseList {}
	##  @private Response list.
    constructor {{port "/dev/ttyS0"}} {
	##  The constructor opens
	# the serial port and initializes the port.
	# @param port The serial port device file.

#      puts stderr "*** $type create $port"
      if {[catch {open $port r+} ttyfd]} {
	set theerror $ttyfd
	catch {unset ttyfd}
	error [_ "Failed to open port %s because %s." $port $theerror]
	return
      }
#      puts stderr "*** $type create: port opened: $ttyfd"
      if {[catch {fconfigure $ttyfd -mode}]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "%s is not a terminal port." $port]
	return
      }
#      puts stderr "*** $type create: port is a tty"
      if {[catch {fconfigure $ttyfd -mode 19200,n,8,1 \
				    -blocking no -buffering none \
				    -encoding binary -translation binary \
				    -handshake rtscts} err]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "Cannot configure port %s because %s." $port $err]
	return
      }
#      puts stderr "*** $type create: port fconfigure'ed"
      if {[catch {fconfigure $ttyfd -ttycontrol {BREAK 1}} err]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "Cannot send BREAK on port %s because %s." $port $err]
	return
      }
      after 200
      if {[catch {fconfigure $ttyfd -ttycontrol {BREAK 0}} err]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "Cannot clear BREAK on port %s because %s." $port $err]
	return
      }
#      puts stderr "*** $type create: BREAK sent"
      $self GetLI100VersionNumbers
#      puts stderr "*** $type create: Sent GetLI100VersionNumbers message"
      while {1} {
	set response [$self GetNextCommandStationResponse 5]
#	puts stderr "*** $type create: response is $response"
	if {$response eq {}} {
	  set mode [fconfigure $ttyfd -mode]
#	  puts stderr "*** $type create: mode is '$mode'"
	  if {$mode eq "9600,n,8,1"} {
	    close $ttyfd
	    catch {unset ttyfd}
	    error [_ "No response on port %s -- is a LI100/LI100F/LI101F connected?" $port]
	    return
	  }
	  close $ttyfd
	  set ttyfd [open $port r+]
#	  puts stderr "*** $type create: re-opened port, about to set
	  if {[catch {fconfigure $ttyfd -mode 9600,n,8,1 \
				    -blocking no -buffering none \
				    -encoding binary -translation binary \
				    -handshake rtscts} err]} {
	    close $ttyfd
	    catch {unset ttyfd}
	    error [_ "Cannot set speed to 9600 on port %s because %s." $port $err]
	    return
	  }
#	  puts stderr "*** $type create: fconfigure'd port to 9600"
	  $self GetLI100VersionNumbers
	  puts stderr "*** $type create: Resent GetLI100VersionNumbers message"
	} elseif {[$response ResponseType] eq "LI100_VERSION"} {
#	  puts stderr "*** $type create: Received LI100_VERSION response"
	  return
	} else {
	  $self GetLI100VersionNumbers
	}
      }
    }
    destructor {
	## The destructor restores
	# the serial port's state and closes it.
      if {![catch {set ttyfd}]} {close $ttyfd}
      catch {unset ttyfd}
    }
    proc _CheckForResponse_0x00 {message} {
	## @private Helper function for CheckForResponse: handles the 0x00 arm.

#	  puts stderr "*** _CheckForResponse_0x00 $message"
	  if {[lindex $message 0] == 0x01} {
	    set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype LI100_MESSAGE [lindex $message 1]]
	  } elseif {[lindex $message 0] == 0x02} {
	    if {[lindex $message 1] == 0x01} {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype LI101_XPRESSNET_ADDRESS \
				[lindex $message 2]]
	    } else {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype LI100_VERSION \
				[expr {((([lindex $message 1] & 0x0f0) >> 4) * 10) + ([lindex $message 1] & 0x0f)}] \
				[expr {((([lindex $message 2] & 0x0f0) >> 4) * 10) + ([lindex $message 2] & 0x0f)}]]
	    }
	  } else {
	    set response {}
	  }
	return $response
    }
    proc _CheckForResponse_0x40 {message} {
	## @private Helper function for CheckForResponse: handles the 0x40 arm.

#	puts stderr "*** _CheckForResponse_0x40 $message"
	  set count [expr {[lindex $message 0] & 0x0f}]
	  switch $count {
	    2 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					1 [lindex $message 1] \
					[lindex $message 2]]
	    }
	    4 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					2 [lindex $message 1] \
					[lindex $message 2] \
					[lindex $message 3] \
					[lindex $message 4]]
	    }
	    6 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					3 [lindex $message 1] \
					[lindex $message 2] \
					[lindex $message 3] \
					[lindex $message 4] \
					[lindex $message 5] \
					[lindex $message 6]]
	    }
	    8 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					4 [lindex $message 1] \
					[lindex $message 2] \
					[lindex $message 3] \
					[lindex $message 4] \
					[lindex $message 5] \
					[lindex $message 6] \
					[lindex $message 7] \
					[lindex $message 8]]
	    }
	    10 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					5 [lindex $message 1] \
					[lindex $message 2] \
					[lindex $message 3] \
					[lindex $message 4] \
					[lindex $message 5] \
					[lindex $message 6] \
					[lindex $message 7] \
					[lindex $message 8] \
					[lindex $message 9] \
					[lindex $message 10]]
	    }
	    12 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					6 [lindex $message 1] \
					[lindex $message 2] \
					[lindex $message 3] \
					[lindex $message 4] \
					[lindex $message 5] \
					[lindex $message 6] \
					[lindex $message 6] \
					[lindex $message 7] \
					[lindex $message 8] \
					[lindex $message 9] \
					[lindex $message 10] \
					[lindex $message 11] \
					[lindex $message 12]]
	    }
	    14 {
	      set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype ACCESSORY_DECODER_INFORMATION \
					7 [lindex $message 1] \
					[lindex $message 2] \
					[lindex $message 3] \
					[lindex $message 4] \
					[lindex $message 5] \
					[lindex $message 6] \
					[lindex $message 7] \
					[lindex $message 8] \
					[lindex $message 9] \
					[lindex $message 10] \
					[lindex $message 11] \
					[lindex $message 12] \
					[lindex $message 13] \
					[lindex $message 14]]
	    }
	    default {set response {}}
	  }
      return $response
    }
    proc _CheckForResponse_0x60 {message} {
	## @private Helper function for CheckForResponse: handles the 0x60 arm.

#      puts stderr "*** _CheckForResponse_0x60 $message"
      
	  if {([lindex $message 0] & 0x0f) < 1} {
	    set response {}
	    break
	  }
	  switch [format {0x%02x} [lindex $message 1]] {
	    0x00 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
	      			-responsetype TRACK_POWER_OFF]
	    }
	    0x01 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype NORMAL_OPERATION_RESUMED]
	    }
	    0x02 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype SERVICE_MODE_ENTRY]
	    }
	    0x10 {
		if {([lindex $message 0] & 0x0f) != 3} {
		  set response {}
		} else {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype SERVICE_MODE_RESPONSE \
				[lindex $message 1] [lindex $message 2] \
				[lindex $message 3]]
		}
	    }
	    0x11 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype PROGRAMMING_INFO_COMMAND_STATION_READY]
	    }
	    0x12 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype PROGRAMMING_INFO_SHORT_CIRCUIT]
	    }
	    0x13 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype PROGRAMMING_INFO_DATA_BYTE_NOT_FOUND]
	    }
	    0x14 {
		if {([lindex $message 0] & 0x0f) != 3} {
		  set response {}
		} else {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype SERVICE_MODE_RESPONSE \
				[lindex $message 1] [lindex $message 2] \
				[lindex $message 3]]
		}
	    }
	    0x1f {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype PROGRAMMING_INFO_COMMAND_STATION_BUSY]
	    }
	    0x21 {
		if {([lindex $message 0] & 0x0f) < 2} {
		  set response {}
		  break
		}
		set n1 [expr {([lindex $message 2] >> 4) & 0x0f}]
		set n2 [expr {[lindex $message 2] & 0x0f}]
		switch [expr {[lindex $message 0] & 0x0f}] {
		  2 {
			set response [xpressnet::CommandStationResponse \
					%%AUTO%% \
					-responsetype SOFTWARE_VERSION $n1 $n2]
		  }
		  3 {
			set response [xpressnet::CommandStationResponse \
					%%AUTO%% \
					-responsetype SOFTWARE_VERSION $n1 $n2 \
					[lindex $message 3]]
		  }
		  default {set response {}}
		}

	    }
	    0x22 {
		if {([lindex $message 0] & 0x0f) == 2} {
		  set response [xpressnet::CommandStationResponse \
					%%AUTO%% \
					-responsetype COMMAND_STATION_STATUS
					[lindex $message 2]]
		} else {
		  set response {}
		}
	    }
	    0x80 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype TRANSFER_ERRORS]
	    }
	    0x81 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype COMMAND_STATION_BUSY]
	    }
	    0x82 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype INSTRUCTION_NOT_SUPPORTED]
	    }
	    0x83 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				NotOperatedOr0]
	    }
	    0x84 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR 
				UsedByAnotherDevice]
	    }
	    0x85 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR 
				UsedInANotherDHMU]
	    }
	    0x86 {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR 
				SpeedNotZero]
	    }
	    default {
		set response {}
	    }
	  }
	return $response
    }
    proc _CheckForResponse_0x80 {message} {
	## @private Helper function for CheckForResponse: handles the 0x80 arm.

	  if {[lindex $message 0] == 0x81 && [lindex $message 1] == 0x00} {
	    set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype EMERGENCY_STOP]
	  } elseif {[lindex $message 0] == 0x84 || 
		    [lindex $message 0] == 0x83} {
	    if {[lindex $message 0] == 0x83 ||
		([lindex $message 4] & 0x03) == 0} {
	      set ssm S14
	      if {([lindex $message 2] & 0x0f) == 1} {
		set s 255
	      } elseif {([lindex $message 2] & 0x0f) == 0} {
		set s 0
	      } else {
		set s [expr {([lindex $message 2] & 0x0f) - 1}]
	      }
	    } else {
	      if {([lindex $message 4] & 0x03) == 1} {
		set ssm S27
	      } else {
	        set ssm S28
	      }
	      if {([lindex $message 2] & 0x1f) == 1} {
		set s 255
	      } elseif {([lindex $message 2] & 0x1f) == 0} {
	        set s 0
	      } else {
		set s [expr {([lindex $message 2] & 0x0f) - 1}]
		set s [expr {$s + ((([lindex $message 2] & 0x10) >> 4) ^ 0x01)}]
	      }
	    }
	    set addr [lindex $message 1]
	    if {([lindex $message 2] & 0x40) == 0} {
	      set dir Reverse
	    } else {
	      set dir Forward
	    }
	    set f0 [expr {([lindex $message 2] & 0x20) != 0}]
	    set f1 [expr {([lindex $message 3] & 0x01) != 0}]
	    set f2 [expr {([lindex $message 3] & 0x02) != 0}]
	    set f3 [expr {([lindex $message 3] & 0x04) != 0}]
	    set f4 [expr {([lindex $message 3] & 0x08) != 0}]
	    set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype LOCOMOTIVE_INFORMATION \
				$addr \
				[expr {([lindex $message 2] & 0x80) == 0}] \
				$dir $ssm $s $f0 $f1 $f2 $f3 $f4]
	  } else {
	    set response {}
	  }
	return $response
    }
    proc _CheckForResponse_0xa0 {message} {
	## @private Helper function for CheckForResponse: handles the 0xa0 arm.

	  if {[lindex $message 0] == 0xa4 || 
		    [lindex $message 0] == 0xa3} {
	    if {[lindex $message 0] == 0xa3 ||
		([lindex $message 4] & 0x03) == 0} {
	      set ssm S14
	      if {([lindex $message 2] & 0x0f) == 1} {
		set s 255
	      } elseif {([lindex $message 2] & 0x0f) == 0} {
		set s 0
	      } else {
		set s [expr {([lindex $message 2] & 0x0f) - 1}]
	      }
	    } else {
	      if {([lindex $message 4] & 0x03) == 1} {
		set ssm S27
	      } else {
	        set ssm S28
	      }
	      if {([lindex $message 2] & 0x1f) == 1} {
		set s 255
	      } elseif {([lindex $message 2] & 0x1f) == 0} {
	        set s 0
	      } else {
		set s [expr {([lindex $message 2] & 0x0f) - 1}]
		set s [expr {$s + ((([lindex $message 2] & 0x10) >> 4) ^ 0x01)}]
	      }
	    }
	    set addr [lindex $message 1]
	    if {([lindex $message 2] & 0x40) == 0} {
	      set dir Reverse
	    } else {
	      set dir Forward
	    }
	    set f0 [expr {([lindex $message 2] & 0x20) != 0}]
	    set f1 [expr {([lindex $message 3] & 0x01) != 0}]
	    set f2 [expr {([lindex $message 3] & 0x02) != 0}]
	    set f3 [expr {([lindex $message 3] & 0x04) != 0}]
	    set f4 [expr {([lindex $message 3] & 0x08) != 0}]
	    set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype LOCOMOTIVE_INFORMATION \
				$addr 0 $dir $ssm $s $f0 $f1 $f2 $f3 $f4]
	  } else {
	    set response {}
	  }
	return $response
    }
    proc _CheckForResponse_0xc0 {message} {
	## @private Helper function for CheckForResponse: handles the 0xc0 arm.

#	puts stderr "*** _CheckForResponse_0xc0 $message"
	  set l [expr {[lindex $message 0] & 0x0f}]
	  if {$l < 5 || $l > 6} {
	    set response {}
	    break
	  }
	  if {[lindex $message 1] != 0x04 && [lindex $message 1] != 0x05]} {
	    set response {}
	    break
	  }
	  set avail [expr {[lindex $message 1] == 0x04}]
	  set modsel 0
	  if {$l == 6} {set modsel [lindex $message 6]}
	  set addr1 [lindex $message 2]
	  set addr2 [lindex $message 5]
	  if {($modsel & 0x03) == 0} {
	    set ssm S14
	    if {([lindex $message 3] & 0x0f) == 1} {
	      set s 255
	    } elseif {([lindex $message 3] & 0x0f) == 0} {
	      set s 0
	    } else {
	      set s [expr {([lindex $message 3] & 0x0f) - 1}]
	    }
	  } else {
	    if {($modsel & 0x03) == 1} {
	      set ssm S27
	    } else {
	      set ssm S28
	    }
	    if {([lindex $message 3] & 0x1f) == 1} {
	      set s 255
	    } elseif {([lindex $message 3] & 0x1f) == 0} {
	      set s 0
	    } else {
	      set s [expr {([lindex $message 3] & 0x0f) - 1}]
	      set s [expr {$s + ((([lindex $message 3] & 0x10) >> 4) ^ 0x01)}]
	    }
	  }
	  if {([lindex $message 3] & 0x40) == 0} {
	    set dir Reverse
	  } else {
	    set dir Forward
	  }
	  set f0 [expr {([lindex $message 3] & 0x20) != 0}]
	  set f1 [expr {([lindex $message 4] & 0x01) != 0}]
	  set f2 [expr {([lindex $message 4] & 0x02) != 0}]
	  set f3 [expr {([lindex $message 4] & 0x04) != 0}]
	  set f4 [expr {([lindex $message 4] & 0x08) != 0}]
	  set response [xpressnet::CommandStationResponse %%AUTO%% \
		-responsetype DOUBLE_HEADER_INFORMATION $addr1 $addr2 $avail \
		$dir $ssm $s $f0 $f1 $f2 $f3 $f4]
	return $response
    }
    proc _CheckForResponse_0xe0 {message} {
	## @private Helper function for CheckForResponse: handles the 0xe0 arm.

#      puts stderr "*** _CheckForResponse_0xe0 $message"
	  switch [format {0x%02x} [expr {[lindex $message 0] & 0x0f}]] {
	    0x01 {
	      switch [format {0x%02x} [lindex $message 1]] {
		0x81 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				NotOperatedOr0]
		}
		0x82 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				UsedByAnotherDevice]
		}
		0x83 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				UsedInANotherDHMU]
		}
		0x84 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				SpeedNotZero]
		}
		0x85 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				NotMU]
		}
		0x86 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				NotMUBaseAddress]
		}
		0x87 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				CantDelete]
		}
		0x88 {
		  set response [xpressnet::CommandStationResponse %%AUTO%% \
				-responsetype DOUBLE_HEADER_MU_ERROR \
				StackFull]
		}
		default {
		  set response {}
		}
	      }
	    }
	    0x02 -
	    0x04 -
	    0x05 -
	    0x06 {
		set avail [expr {([lindex $message 1] & 0x08) == 0}]
		set ssm S14
		set s 0
		set f0 0
		set f1 0
		set f2 0
		set f3 0
		set f4 0
		set f5 0
		set f6 0
		set f7 0
		set f8 0
		set f9 0
		set f10 0
		set f11 0
		set f12 0
		set mtr 0
		set address 0
		switch [format {0x%02x} [expr {[lindex $message 1] & 0x07}]] {
		  0x00 {
		    set ssm S14
		    if {([lindex $message 2] & 0x0f) == 1} {
		      set s 255
		    } elseif {([lindex $message 2] & 0x0f) == 0} {
		      set s 0
		    } else {
		      set s [expr {([lindex $message 2] & 0x0f) - 1}]
		    }
		  }
		  0x01 {
		    set ssm S27
		    if {([lindex $message 2] & 0x1f) == 1} {
		      set s 255
		    } elseif {([lindex $message 2] & 0x1f) == 0} {
	 	      set s 0
		    } else {
		      set s [expr {([lindex $message 2] & 0x0f) - 1}]
		      set s [expr {$s + ((([lindex $message 2] & 0x10) >> 4) ^ 0x01)}]
		    }
		  }
		  0x02 {
		    set ssm S28
		    if {([lindex $message 2] & 0x1f) == 1} {
		      set s 255
		    } elseif {([lindex $message 2] & 0x1f) == 0} {
	 	      set s 0
		    } else {
		      set s [expr {([lindex $message 2] & 0x0f) - 1}]
		      set s [expr {$s + ((([lindex $message 2] & 0x10) >> 4) ^ 0x01)}]
		    }
		  }
		  0x04 {
		    set ssm S128
		    if {([lindex $message 2] & 0x7f) == 1} {
		      set s 255
		    } elseif {([lindex $message 2] & 0x7f) == 0} {
		      set s 0
		    } else {
		      set s [expr {([lindex $message 2] & 0x7f) - 1}]
		    }
		  }
		}
		set mtr 0
		set address 0
		if {([lindex $message 2] & 0x80) == 0} {
		  set dir Reverse
		} else {
		  set dir Forward
		}
		if {([lindex $message 0] & 0x0f) > 2} {
		  set f0 [expr {([lindex $message 3] & 0x10) != 0}]
		  set f1 [expr {([lindex $message 3] & 0x01) != 0}]
		  set f2 [expr {([lindex $message 3] & 0x02) != 0}]
		  set f3 [expr {([lindex $message 3] & 0x04) != 0}]
		  set f4 [expr {([lindex $message 3] & 0x08) != 0}]
		  set f5 [expr {([lindex $message 4] & 0x01) != 0}]
		  set f6 [expr {([lindex $message 4] & 0x02) != 0}]
		  set f7 [expr {([lindex $message 4] & 0x04) != 0}]
		  set f8 [expr {([lindex $message 4] & 0x08) != 0}]
		  set f9 [expr {([lindex $message 4] & 0x10) != 0}]
		  set f10 [expr {([lindex $message 4] & 0x20) != 0}]
		  set f11 [expr {([lindex $message 4] & 0x40) != 0}]
		  set f12 [expr {([lindex $message 4] & 0x80) != 0}]
		}
		if {([lindex $message 0] & 0x0f) == 5} {
		  set address [lindex $message 5]
		  set mtr $address
		}
		if {([lindex $message 0] & 0x0f) == 6} {
		  set mtr 0
		  set address [expr {([lindex $message 5] << 8) + [lindex $message 6]}]
		}
		switch [format {0x%02x} [expr {[lindex $message 1] & 0xf0}]] {
		  0x00 {
		    set response [xpressnet::CommandStationResponse %%AUTO%% \
					-responsetype LOCOMOTIVE_INFORMATION \
					$address $avail $dir $ssm $s $f0 $f1 \
					$f2 $f3 $f4 $f5 $f6 $f7 $f8 $f9 $f10 \
					$f11 $f12]
		  }
		  0x10 {
		    set response [xpressnet::CommandStationResponse %%AUTO%% \
					-responsetype LOCOMOTIVE_INFORMATION \
					$address $avail $dir $ssm $s $f0 $f1 \
					$f2 $f3 $f4 $f5 $f6 $f7 $f8 $f9 $f10 \
					$f11 $f12 $mtr]
		  }
		  0x20 {
		    set response [xpressnet::CommandStationResponse %%AUTO%% \
					-responsetype LOCOMOTIVE_INFORMATION \
					$address $avail $dir $ssm $s]
		  }
		  0x60 {
		    set response [xpressnet::CommandStationResponse %%AUTO%% \
					-responsetype LOCOMOTIVE_INFORMATION \
					$address $avail $dir $ssm $s $f0 $f1 \
					$f2 $f3 $f4 $f5 $f6 $f7 $f8 $f9 $f10 \
					$f11 $f12 $mtr $address]
		  }
		  default {
		    set response {}
		  }
		}
	    }
	    0x03 {
	      if {[lindex $message 1] == 0x40} {
		set response [xpressnet::CommandStationResponse %%AUTO%% \
					-responsetype LOCOMOTIVE_INFORMATION \
					[expr {([lindex $message 2] << 8) + \
						[lindex $message 3]}]]
	      } elseif {[lindex $message 1] == 0x50} {
		set response [xpressnet::CommandStationResponse %%AUTO%% 
					-responsetype FUNCTION_STATUS \
				[expr {([lindex $message 2] & 0x10) != 0}] \
				[expr {([lindex $message 2] & 0x01) != 0}] \
				[expr {([lindex $message 2] & 0x02) != 0}] \
				[expr {([lindex $message 2] & 0x04) != 0}] \
				[expr {([lindex $message 2] & 0x08) != 0}] \
				[expr {([lindex $message 3] & 0x01) != 0}] \
				[expr {([lindex $message 3] & 0x02) != 0}] \
				[expr {([lindex $message 3] & 0x04) != 0}] \
				[expr {([lindex $message 3] & 0x08) != 0}] \
				[expr {([lindex $message 3] & 0x10) != 0}] \
				[expr {([lindex $message 3] & 0x20) != 0}] \
				[expr {([lindex $message 3] & 0x40) != 0}] \
				[expr {([lindex $message 3] & 0x80) != 0}]]
	      } elseif {([lindex $message 1] & 0xf0) == 0x30} {
		set response [xpressnet::CommandStationResponse %%AUTO%% 
					-responsetype LOCOMOTIVE_ADDRESS \
					[expr {[lindex $message 1] & 0x0f}] \
					[expr {([lindex $message 2) << 8) + \
						[lindex $message 3}]]
	      } else {
		set response {}
	      }
	    }
	  }
      return $response
    }
    method CheckForResponse {{timeout 5}} {
	##  Check for a response from the command station.
	#  @param timeout Timeout in seconds

#      puts stderr "*** $self CheckForResponse $timeout"
      if {[catch {set ttyfd}]} {
	return NO_RESPONSE_AVAILABLE
      }
      if {![$self _readbyte byte $timeout]} {
	return NO_RESPONSE_AVAILABLE
      }
      set message [list $byte]
      set l [expr {($byte & 0x0f) + 1}]
      set len 1
      for {set i 0} {$i < $l} {incr i} {
	if {[$self _readbyte byte $timeout]} {
	  lappend message $byte
	  incr len
	} else {
	  break
	}
      }
#      puts stderr "*** $self CheckForResponse: message is $message"
      if {$len != (([lindex $message 0] & 0x0f) + 2)} {
	error [_ "Read error: read %d bytes, header says %d bytes -- is a LI100/LI100F/LI101 connected?" $len [expr {([lindex $message 0] & 0x0f)+2}]]
	return NO_RESPONSE_AVAILABLE
      }
      set xorbyte [lindex $message 0]
      for {set i 1} {$i <= ([lindex $message 0] & 0x0f)} {incr i} {
	set xorbyte [expr {$xorbyte ^ [lindex $message $i]}]
      }
      if {$xorbyte != [lindex $message end]} {
	error [_ "Bad X-Or-Byte: computed 0x%02x, got 0x%02x -- is a LI100/LI100F/LI101 connected?" $xorbyte [lindex $message end]]
	return NO_RESPONSE_AVAILABLE
      }
      set response {}
#      puts stderr [format {*** %s CheckForResponse: message type code is 0x%02x} $self [expr {[lindex $message 0] & 0x0f0}]]
      switch [format {0x%02x} [expr {[lindex $message 0] & 0x0f0}]] {
	0x00 {set response [_CheckForResponse_0x00 $message]}
	0x40 {set response [_CheckForResponse_0x40 $message]}
	0x60 {set response [_CheckForResponse_0x60 $message]}
	0x80 {set response [_CheckForResponse_0x80 $message]}
	0xa0 {set response [_CheckForResponse_0xa0 $message]}
	0xc0 {set response [_CheckForResponse_0xc0 $message]}
	0xe0 {set response [_CheckForResponse_0xe0 $message]}
      }
      if {$response eq {}} {
        error [_ "Bad or illformed message received, ignored."]
      }
      lappend responseList $response
      return [$response ResponseType]
    }
    method GetNextCommandStationResponse {{timeout 5}} {
	##  Return the next response from the command station.
	#  @param timeout Timeout in seconds

#      puts stderr "*** $self GetNextCommandStationResponse $timeout"
      if {[catch {set ttyfd}]} {
	return {}
      }
#      puts stderr "*** $self GetNextCommandStationResponse: tty is open..."
#      puts stderr "*** $self GetNextCommandStationResponse: responseList is $responseList"
      if {[llength $responseList] == 0 &&
	  [$self CheckForResponse $timeout] eq "NO_RESPONSE_AVAILABLE"} {
#	puts stderr "*** $self GetNextCommandStationResponse: list empty and no new response available"
	return {}
      }
      if {[llength $responseList] == 0} {return {}}
      set result [lindex $responseList 0]
      set responseList [lrange $responseList 1 end]
      return $result
    }

    method _appendXORByte {messageVar} {
	## @private Compute and append the XOR check byte
	# @param messageVar Name of the list holding the message bytes.
      upvar $messageVar message
      set xorbyte [lindex $message 0]
      foreach b [lrange $message 1 end] {
	set xorbyte [expr {$xorbyte ^ $b}]
      }
      lappend message $xorbyte
    }
    method ResumeOperations {} {
	## Resume operations request.
      $self _transmit [list 0x21 0x81 0xa0]
    }
    method StopOperations {} {
	##  Stop operations request.
      $self _transmit [list 0x21 0x80 0xa1]
    }
    method EmergencyStopAllLocomotives {} {
	##  Emergency stop all locomotives.
      $self _transmit [list 0x80 0x80]
    }
    method EmergencyStopALocomotive {la} {
	##  Emergency stop a locomotive.
	# @param la Address of the locomotive to stop.
      set message [list 0x92]
      lappend message [expr {($la >> 8) & 0x0ff}]
      lappend message [expr {$la  & 0x0ff}]
      $self _appendXORByte message
      $self _transmit $message
    }
    method RegisterModeRead {r} {
	##  Register mode read.
	# @param r Register to read.
      xpressnet::nibble validate $r
      set message [list 0x22 0x11 [expr {$r & 0x0f}]]
      $self _appendXORByte message
      $self _transmit $message 
    }
    method DirectModeCVRead {cv} {
	##  Direct mode CV read.
	# @param cv CV to read.
      xpressnet::ubyte validate $cv
      set message [list 0x22 0x15 [expr {$cv & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method PagedModeCVRead {cv} {
	##  Paged mode CV read.
	# @param cv CV to read.
      xpressnet::ubyte validate $cv
      set message [list 0x22 0x14 [expr {$cv & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method RequestForServiceModeResults {} {
	##  Request for service mode results.
      $self _transmit [list 0x21  0x10  0x31]
    }
    method RegisterModeWrite {r d} {
	##  Register mode write.
	# @param r Register to write to.
	# @param d Data to write.
      xpressnet::nibble validate $r
      xpressnet::ubyte validate $d
      set message [list 0x23 0x12 [expr {$r & 0x0f}] [expr {$d & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method DirectModeCVWrite {cv d} {
	##  Direct mode CV write.
	# @param cv CV to write to.
	# @param d Data to write.
      xpressnet::ubyte validate $cv
      xpressnet::ubyte validate $d
      set message [list 0x23 0x16 [expr {$cv & 0x0ff}] [expr {$d & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method PagedModeCVWrite {cv d} {
	##  Paged mode CV write.
	# @param cv CV to write to.
	# @param d Data to write.
      xpressnet::ubyte validate $cv
      xpressnet::ubyte validate $d
      set message [list 0x23 0x17 [expr {$cv & 0x0ff}] [expr {$d & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method CommandStationSoftwareVersion {} {
	##  Command station software version request.
      $self _transmit [list 0x21 0x21 0x00]
    }
    method CommandStationStatusRequest {} {
	##  Command station status request.
      $self _transmit [list 0x21 0x24 0x05]
    }
    method SetCommandStationPowerUpMode {mode} {
	##  Set command station power up mode.
	# @param mode Mode to set.
      xpressnet::PowerUpMode validate $mode
      set message [list 0x22 0x22]
      switch $mode {
	Manual {lappend message 0x00}
	Automatic {lappend message 0x04}
	default {lappend message 0x00}
      }
      $self _appendXORByte message
      $self _transmit $message
    }
    method AccessoryDecoderInformationRequest {address nibble} {
	##  Accessory decoder information request.
	# @param address Address of decoder.
	# @param nibble Which nibble.
      xpressnet::DecoderLongAddress validate $address
      xpressnet::NibbleCode validate $nibble
      set message [list 0x42 [expr {$address & 0x0ff}]]
      switch $nibble {
	Lower {lappend message 0x80}
	Upper {lappend message 0x81}
      }
      $self _appendXORByte message
      $self _transmit $message
    }
    method AccessoryDecoderOperation {groupaddr elementaddr activateOutput 
					useOutput2} {
	##  Accessory decoder operation request.
	# @param groupaddr Address of decoder.
	# @param elementaddr Address of element.
	# @param activateOutput Set or clear output.
	# @param useOutput2 Use output 2?
      xpressnet::DecoderLongAddress validate $groupaddr
      xpressnet::ElementAddress validate $elementaddr
      snit::boolean validate $activateOutput
      snit::boolean validate $useOutput2
      set message [list 0x52 [expr {$groupaddr & 0x0ff}]]
      set tmpbyte [expr {0x80 | (($elementaddr & 0x03) << 1)}]
      if {!$activateOutput} {set tmpbyte [expr {$tmpbyte | 0x08}]}
      if {$useOutput2} {set tmpbyte [expr {$tmpbyte | 0x01}]}
      lappend message $tmpbyte
      $self _appendXORByte message
      $self _transmit $message
    }
    proc _ADDRESS {a} {
      ## @private Helper function to insure a proper address.
      # If it is a long address (>= 100), 0x0c000 is added.
      # @param a Raw address.
      if {$a < 100} {
	return $a
      } else {
	return [expr {$a + 0x0c000}]
      }
    }
#    proc _message_hex {message} {
#	## Debug helper function.
#      set result ""
#      set sp ""
#      foreach mbyte $message {
#	append result [format "%s0x%02x" $sp $mbyte]
#	set sp " "
#      }
#      return $result
#    }
    method LocomotiveInformationRequest {address} {
	##  Locomotive information request.
	# @param address Address of locomotive.
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe3 0x00 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
				  [expr {$address & 0x0ff}]]
      $self _appendXORByte message
#      puts stderr "*** $self LocomotiveInformationRequest: message is [_message_hex $message]"
      $self _transmit $message
    }
    method FunctionStatusRequest {address} {
	##  Function status request.
	# @param address Address of locomotive.
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe3 0x07 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
				  [expr {$address & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method SetLocomotiveSpeedAndDirection {address ssm dir speed} {
	##  Set locomotive speed and direction.
	# @param address Address of locomotive.
	# @param ssm Speed step mode to use.
	# @param dir Desired direction.
	# @param speed Desired speed.
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe4]
      set addhbyte [expr {([_ADDRESS $address] >> 8) & 0x0ff}]
      set addlbyte [expr {$address & 0x0ff}]
      xpressnet::SpeedStepModeCode validate $ssm
      xpressnet::DirectionCode validate $dir
      snit::integer validate $speed
      switch $ssm {
	S27 {
	  if {$speed != 255} {xpressnet::S_27 validate $speed}
	  lappend message 0x11 $addhbyte $addlbyte
	  if {$speed == 255} {
	    set sbyte 0x01
	  } elseif {$speed == 0} {
	    set sbyte 0x00
	  } else {
	    set s14 [expr {($speed >> 1) & 0x0f}]
	    set lsb [expr {($speed & 0x01) ^ 0x01}]
	    set sbyte [expr {(($s14 + 1) & 0x0f) | ($lsb << 4)}]
	  }
	  if {$dir eq "Forward"} {set sbyte [expr {$sbyte | 0x80}]}
	  lappend message $sbyte
	}
	S28 {
	  if {$speed != 255} {xpressnet::S_28 validate $speed}
	  lappend message 0x12 $addhbyte $addlbyte
	  if {$speed == 255} {
	    set sbyte 0x01
	  } elseif {$speed == 0} {
	    set sbyte 0x00
	  } else {
	    set s14 [expr {($speed >> 1) & 0x0f}]
	    set lsb [expr {($speed & 0x01) ^ 0x01}]
	    set sbyte [expr {(($s14 + 1) & 0x0f) | ($lsb << 4)}]
	  }
	  if {$dir eq "Forward"} {set sbyte [expr {$sbyte | 0x80}]}
	  lappend message $sbyte
	}
	S128 {
	  if {$speed != 255} {xpressnet::S_128 validate $speed}
	  lappend message 0x13 $addhbyte $addlbyte
	  if {$speed == 255} {
	    set sbyte 0x01
	  } elseif {$speed == 0} {
	    set sbyte 0x00
	  } else {
	    set sbyte [expr {($speed + 1) & 0x7f}]
	  }
	  if {$dir eq "Forward"} {set sbyte [expr {$sbyte | 0x80}]}
	  lappend message $sbyte
	}
	default -
	S14 {
	  if {$speed != 255} {xpressnet::S_14 validate $speed}
	  lappend message 0x10 $addhbyte $addlbyte
	  if {$speed == 255} {
	    set sbyte 0x01
	  } elseif {$speed == 0} {
	    set sbyte 0x00
	  } else {
	    set sbyte [expr {($speed + 1) & 0x0f}]
	  }
	  if {$dir eq "Forward"} {set sbyte [expr {$sbyte | 0x80}]}
	  lappend message $sbyte
	}
      }
      $self _appendXORByte message
#      puts stderr "*** $self SetLocomotiveSpeedAndDirection: message is [_message_hex $message]"
      $self _transmit $message
    }
    method SetLocomotiveFunctionsGroup1 {address f0 f1 f2 f3 f4} {
	##  Set locomotive functions, group 1.
	# @param address Locomotive address.
	# @param f0 Function 0.
	# @param f1 Function 1.
	# @param f2 Function 2.
	# @param f3 Function 3.
	# @param f4 Function 4.
      xpressnet::DecoderLongAddress validate $address
      snit::boolean validate $f0
      snit::boolean validate $f1
      snit::boolean validate $f2
      snit::boolean validate $f3
      snit::boolean validate $f4
      set message [list 0xe4 0x20 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      if {$f0} {
	set fbyte 0x10
      } else {
	set fbyte 0x00
      }
      if {$f1} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f2} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f3} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f4} {set fbyte [expr {$fbyte | 0x08}]}
      lappend message $fbyte
      $self _appendXORByte message
#      puts stderr "*** $self SetLocomotiveFunctionsGroup1: message is [_message_hex $message]"
      $self _transmit $message
    }
    method SetLocomotiveFunctionsGroup2 {address f5 f6 f7 f8} {
	##  Set locomotive functions, group 2.
	# @param address Locomotive address.
	# @param f5 Function 5.
	# @param f6 Function 6.
	# @param f7 Function 7.
	# @param f8 Function 8.
      xpressnet::DecoderLongAddress validate $address
      snit::boolean validate $f5
      snit::boolean validate $f6
      snit::boolean validate $f7
      snit::boolean validate $f8
      set message [list 0xe4 0x21 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      set fbyte 0x00
      if {$f5} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f6} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f7} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f8} {set fbyte [expr {$fbyte | 0x08}]}
      lappend message $fbyte
      $self _appendXORByte message
      $self _transmit $message
    }
    method SetLocomotiveFunctionsGroup3 {address f9 f10 f11 f12} {
	##  Set locomotive functions, group 3.
	# @param address Locomotive address.
	# @param f9 Function 9.
	# @param f10 Function 10.
	# @param f11 Function 11.
	# @param f12 Function 12.
      xpressnet::DecoderLongAddress validate $address
      snit::boolean validate $f9
      snit::boolean validate $f10
      snit::boolean validate $f11
      snit::boolean validate $f12
      set message [list 0xe4 0x22 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      set fbyte 0x00
      if {$f9} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f10} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f11} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f12} {set fbyte [expr {$fbyte | 0x08}]}
      lappend message $fbyte
      $self _appendXORByte message
      $self _transmit $message
    }
    method SetFunctionStateGroup1 {address f0 f1 f2 f3 f4} {
	##  Set locomotive function state, group 1.
	# @param address Locomotive address.
	# @param f0 Function 0.
	# @param f1 Function 1.
	# @param f2 Function 2.
	# @param f3 Function 3.
	# @param f4 Function 4.
      xpressnet::DecoderLongAddress validate $address
      snit::boolean validate $f0
      snit::boolean validate $f1
      snit::boolean validate $f2
      snit::boolean validate $f3
      snit::boolean validate $f4
      set message [list 0xe4 0x24 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      if {$f0} {
	set fbyte 0x10
      } else {
	set fbyte 0x00
      }
      if {$f1} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f2} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f3} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f4} {set fbyte [expr {$fbyte | 0x08}]}
      lappend message $fbyte
      $self _appendXORByte message
      $self _transmit $message
    }
    method SetFunctionStateGroup2 {address f5 f6 f7 f8} {
	##  Set locomotive function state, group 2.
	# @param address Locomotive address.
	# @param f5 Function 5.
	# @param f6 Function 6.
	# @param f7 Function 7.
	# @param f8 Function 8.
      xpressnet::DecoderLongAddress validate $address
      snit::boolean validate $f5
      snit::boolean validate $f6
      snit::boolean validate $f7
      snit::boolean validate $f8
      set message [list 0xe4 0x25 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      set fbyte 0x00
      if {$f5} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f6} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f7} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f8} {set fbyte [expr {$fbyte | 0x08}]}
      lappend message $fbyte
      $self _appendXORByte message
      $self _transmit $message
    }
    method SetFunctionStateGroup3 {address f9 f10 f11 f12} {
	##  Set locomotive function state, group 3.
	# @param address Locomotive address.
	# @param f9 Function 9.
	# @param f10 Function 10.
	# @param f11 Function 11.
	# @param f12 Function 12.
      xpressnet::DecoderLongAddress validate $address
      snit::boolean validate $f9
      snit::boolean validate $f10
      snit::boolean validate $f11
      snit::boolean validate $f12
      set message [list 0xe4 0x26 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      set fbyte 0x00
      if {$f9} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f10} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f11} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f12} {set fbyte [expr {$fbyte | 0x08}]}
      lappend message $fbyte
      $self _appendXORByte message
      $self _transmit $message
    }
    method EstablishDoubleHeader {address1 address2} {
	##  Establish a double header.
	# @param address1 Locomotive address1.
	# @param address2 Locomotive address2.
      xpressnet::DecoderLongAddress validate $address1
      xpressnet::DecoderLongAddress validate $address2
      set message [list 0xe5 0x43 [expr {($address1 >> 8) & 0x0ff}] \
			[expr {$address1 & 0x0ff}] \
			[expr {($address2 >> 8) & 0x0ff}] \
			[expr {$address2 & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
      
    }
    method DissolveDoubleHeader {address1} {
	##  Dissolve a double header.
	# @param address1 Locomotive address1.
      xpressnet::DecoderLongAddress validate $address1
      $self EstablishDoubleHeader $address1 0
    }
    method OperatingModeProgrammingByteModeWrite {address cv data} {
	##  Operating mode programming byte mode write.
	# @param address Locomotive address.
	# @param cv CV to set.
	# @param data Data to set.
      xpressnet::DecoderLongAddress validate $address
      xpressnet::u10 validate $cv
      xpressnet::ubyte validate $data
      set message [list 0xe6 0x30 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}] \
			[expr {0xec | (($cv >> 8) & 0x03)}] \
			[expr {$cv & 0x0ff}] \
			[expr {$data & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method OperatingModeProgrammingBitModeWrite {address cv bitnum value} {
	##  Operating mode programming bit mode write.
	# @param address Locomotive address.
	# @param cv CV to set.
	# @param bitnum Bit number.
	# @param value Value to set.
      xpressnet::DecoderLongAddress validate $address
      xpressnet::u10 validate $cv
      xpressnet::u3  validate $bitnum
      snit::boolean validate $value
      set message [list 0xe6 0x30 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}] \
			[expr {0xeb | (($cv >> 8) & 0x03)}] \
			[expr {$cv & 0x0ff}]]
      set data [expr {$bitnum & 0x07}]
      if {$value} {set data [expr {$data | 0x08}]}
      lappend message $data
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddLocomotiveToMultiUnit {address mtr samedirection} {
	##  Add locomotive to Multi-Unit.
	# @param address Locomotive address.
	# @param mtr Multi-Unit address.
	# @param samedirection The locomotive direction is the same as the
	#	 consist direction.
      xpressnet::DecoderLongAddress validate $address
      xpressnet::ConsistAddress validate $mtr
      snit::boolean validate $samedirection
      set message [list 0xe4]
      if {$samedirection} {
	lappend message 0x40
      } else {
	lappend message 0x41
      }
      lappend message [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}] \
			[expr {$mtr & 0x07f}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method RemoveLocomotiveFromMultiUnit {address mtr} {
	##  Remove locomotive to Multi-Unit.
	# @param address Locomotive address.
	# @param mtr Multi-Unit address.
      xpressnet::DecoderLongAddress validate $address
      xpressnet::ConsistAddress validate $mtr
      set message [list 0xe4 0x42 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}] \
			[expr {$mtr & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddressInquiryNextMUMember {mtr address} {
	##  Address inquire next MU member.
	# @param mtr Multi-Unit address.
	# @param address Locomotive address.
      xpressnet::ConsistAddress validate $mtr
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe4 0x01 [expr {$mtr & 0x0ff}] \
			[expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddressInquiryPreviousMUMember {mtr address} {
	##  Address inquire previous MU member.
	# @param mtr Multi-Unit address.
	# @param address Locomotive address.
      xpressnet::ConsistAddress validate $mtr
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe4 0x02 [expr {$mtr & 0x0ff}] \
			[expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddressInquiryNextMU {mtr} {
	##  Address inquire next MU.
	# @param mtr Multi-Unit address.
      xpressnet::ConsistAddress validate $mtr
      set message [list 0xe2 0x03 [expr {$mtr & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddressInquiryPreviousMU {mtr} {
	##  Address inquire previous MU.
	# @param mtr Multi-Unit address.
      xpressnet::ConsistAddress validate $mtr
      set message [list 0xe2 0x04 [expr {$mtr & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddressInquiryNextStack {address} {
	##  Address inquire next stack.
	# @param address Locomotive address.
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe3 0x05 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method AddressInquiryPreviousStack {address} {
	##  Address inquire previous stack.
	# @param address Locomotive address.
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe3 0x06 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method DeleteLocomotiveFromStack {address} {
	##  Delete locomotive from stack.
	# @param address Locomotive address.
      xpressnet::DecoderLongAddress validate $address
      set message [list 0xe3 0x44 [expr {([_ADDRESS $address] >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method GetLI100VersionNumbers {} {
	##  Fetch version numbers from LI100F and LI101.
      $self _transmit [list 0xf0 0xf0]
    }
    method SetLI101Address {addr} {
	## Set LI101's XPressNet address.
      xpressnet::ubyte validate $addr
      set message [list 0xf2 0x01 [expr {$addr & 0x0ff}]]
      $self _appendXORByte message
      $self _transmit $message
    }
    method readevent {script} {
	## Establish an external read event handler.
	# @param script The external event handler script.
      fileevent $ttyfd readable $script
    }
    variable _timeout 0
	## @privatesection Timeout or data available flag
    method _readevent {} {
	## Read event handler, toggle timeout flag.
      incr _timeout -1
    }
    method _timeoutevent {} {
	## Timeout event handler, toggle timeout flag.
      incr _timeout 1
    }
    method _transmit {themessage} {
	## Transmit a message.
      if {[catch {set ttyfd}]} {
	return
      }
      puts -nonewline $ttyfd [binary format c* $themessage]
    }
    method _readbyte {thebytevar timeout} {
	## Read next available byte or return false.
	# @param thebytevar Name of a variable to receive the byte.
	# @param timeout Timeout in seconds.
	# 
	# If there is a defined external read event handler, the timeout
	# parameter is ignored and false is returned if there are no bytes
	# available.  The presumption is that the read is being called from
	# event handler and that means that there is data available.
      if {[catch {set ttyfd}]} {
	return false
      }
      upvar $thebytevar thebyte
      set oldscript [fileevent $ttyfd readable]
      foreach {in out} [fconfigure $ttyfd -queue] {break}
#      puts stderr "*** $self _readbyte: in = $in"
      if {$in > 0} {
        # Data available, grab the next byte.
	set therawbyte [read $ttyfd 1]
	binary scan $therawbyte c thebyte
	set thebyte [expr {$thebyte & 0x0ff}]
#	puts stderr [format "*** %s _readbyte: thebyte is 0x%02x" $self $thebyte]
	return true
      } else {
	# Data not available and there is no fileevent.
	# Perform timeout check for data arriving in the timeout period.
	set _timeout 0;# Nothing yet.
	# Set up timeout event.
	set e [after [expr {$timeout * 1000}] [mymethod _timeoutevent]]
	# Set up read event.
	fileevent $ttyfd readable [mymethod _readevent]
	# Yawn -- wait for something to happen.
	vwait [myvar _timeout]
	# It happened. Flush events.
	fileevent $ttyfd readable $oldscript
	after cancel $e
	# See if some data arrived.
	foreach {in out} [fconfigure $ttyfd -queue] {break}
# 	puts stderr "*** $self _readbyte (after timeout): in = $in"
	if {$in > 0} {
	  # YES! We have data, peel off a byte.
	  set therawbyte [read $ttyfd 1]
	  binary scan $therawbyte c thebyte
	  set thebyte [expr {$thebyte & 0x0ff}]
#	  puts stderr [format "*** %s _readbyte (after timeout): thebyte is 0x%02x" $self $thebyte]
	  return true
	} else {
	  # Nope -- fail.
	  return false
	}
      }
    }
  }
  snit::type XpressNetEvent {
## @brief XPressNet Event class.
#
# This class implements the Tcl Event interface to the XPressNet
# serial port interface.  A Tcl script is bound to XPressNet serial
# port events.  This script is called from the event procedures when
# XPressNet events occur.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
    component xpressnet
    ## @private Holds the XPressNet component.

    delegate method * to xpressnet

    variable _script
    ## @private Holds the event script.
    constructor {script {port "/dev/ttyS0"}} {
	## @brief Constructor.
	# The constructor opens serial port and initializes the port,
	# stashes the interpreter and creates an event source.
	# @param script The event script.
	# @param port The serial port device file.

#      puts stderr "*** $type create $script $port"
      install xpressnet using xpressnet::XPressNet %%AUTO%% $port
      set _script $script
      $xpressnet readevent [mymethod _eventhandler]
    }
    destructor {
	## @brief Destructor. 
	# The destructor closes the serial port and deletes the event
	# source. 
      catch {$xpressnet destroy}
      catch {unset xpressnet}
    }
    method _eventhandler {} {
	## @private The event handler.
      set last_response_type [$xpressnet CheckForResponse 5]
      if {$last_response_type ne "NO_RESPONSE_AVAILABLE"} {
	set response [$xpressnet GetNextCommandStationResponse 5]
	uplevel #0 [concat $_script $last_response_type $response]
      }
    }
  }
}

## @}

package provide Xpressnet 2.0.0
