#* 
#* ------------------------------------------------------------------
#* CmriSupport.tcl - CMRI Node Control Support
#* Created by Robert Heller on Sun May 30 19:37:31 2004
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.1  2004/06/06 13:59:45  heller
#* Modification History: Start of C/MRI Support code.
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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

#@Chapter:CmriSupport.tcl -- Defines a Snit type to wrap CMR/I nodes.
# $Id$

package require snit
package require cmri

namespace eval CmriSupport {
# Namespace containing the Cmri Support code.
# [index] CmriSupport!namespace

  snit::type CmriNode {
  # CMR/I node type.  This Snit type defines CMR/I nodes (SUSIC, USIC, or SMINI
  # boards) on a CMR/I network.  All options are readonly.
  #
  # <option> -type The type of node, one of SUSIC, USIC, or SMINI. No default 
  #		   value.
  # <option> -address The address of the node.  Default is 0.
  # <option> -cardmap The card type map.  Only used with SUSIC and USIC. 
  #			Default is {}.
  # <option> -yellowmap The yellow bi-color LED map.  Only used with the SMINI
  #			card type. Default is {0 0 0 0 0 0}.
  # <option> -numberofyellow The number of yellow bi-color LED signals. Only
  #			for SMINI cards.  Default is 0.
  # <option> -inputports The number of 8-bit input ports.  Default 0 (3 for 
  #			SMINI cards).
  # <option> -outputports The number of 8-bit output ports.  Default 0 (6 for 
  #			SMINI cards).
  # <option> -delay The delay value to use.  Only meaningful for older (USIC)
  #			cards.  Default is 0.
  # [index] CmriSupport::CmriNode!snit type

    typevariable _TypeCodes -array {
	SUSIC X
	USIC  N
	SMINI M
    }
    method _ValidateType {option value} {
    # Method to validate the card type.
    # <in> option The option to validate.
    # <in> value The value to validate.

      if {[lsearch -exact [array names _TypeCodes] [string toupper "$value"]] < 0} {
	error "Expected a valid card type for $option, got $value"
      }
      return "$value"
    }
    option -type -readonly yes -validatemethod _ValidateType
    method _ValidateAddress {option value} {
    # Method to validate a card address.
    # <in> option The option to validate.
    # <in> value The value to validate.

      if {[string is integer -strict "$value"]} {
	if {$value >= 0 && $value <= 127} {
	  return $value
	} else {
	  error "Board address for $option out of range (0..127): $value"
	}
      } else {
	error "Expected a board address for $option, got $value"
      }
    }
    option -address -default 0 -readonly yes -validatemethod _ValidateAddress
    method _ValidateListOfBytes {option value} {
    # Method to validate a list of bytes.
    # <in> option The option to validate.
    # <in> value The value to validate.

      foreach e $value {
	if {[string is integer -strict "$e"] &&
	    $e >= 0 && $e <= 255} {continue}
	error "Expected a list of bytes for $option, got $value"
      }
    }
    option -cardmap -default {} -readonly yes -validatemethod _ValidateListOfBytes
    method _ValidateSixElementListOfBytes {option value} {
    # Method to validate a six element list of bytes.
    # <in> option The option to validate.
    # <in> value The value to validate.

      $self _ValidateListOfBytes $option $value
      if {[llength $value] != 6} {
	error error "Expected a 6 element list of bytes for $option, got $value"
      }
      return $value
    }
    option -yellowmap -default {0 0 0 0 0 0} -readonly yes -validatemethod _ValidateSixElementListOfBytes
    method _ValidateByte {option value} {
    # Method to validate a byte value.
    # <in> option The option to validate.
    # <in> value The value to validate.

      if {[string is integer -strict "$value"]} {
	if {$value >= 0 && $value <= 255} {
	  return $value
	} else {
	  error "Byte value for $option out of range (0..255): $value"
	}
      } else {
	error "Expected a byte for $option, got $value"
      }
    }
    method _ValidateWord {option value} {
    # Method to validate a word (16-bit) value.
    # <in> option The option to validate.
    # <in> value The value to validate.

      if {[string is integer -strict "$value"]} {
	if {$value >= 0 && $value <= 65535} {
	  return $value
	} else {
	  error "Word value for $option out of range (0..65535): $value"
	}
      } else {
	error "Expected a 16-bit integer for $option, got $value"
      }
    }
    option -numberofyellow -readonly yes -default 0 -validatemethod _ValidateByte
    option -inputports -readonly yes -validatemethod _ValidateByte
    option -outputports -readonly yes -validatemethod _ValidateByte
    option -delay -readonly yes -default 0 -validatemethod _ValidateWord
    typecomponent _cmriPort
    # Holds the open CMR/I port object.
    typemethod openport {{port "/dev/ttyS0"} {baud 9600} {maxtries 10000}} {
    # Open the CMR/I port.  This type method opens the CMR/I port.
    # <in> port The serial port connected to the CMR/I network.
    # <in> baud The BAUD rate to be used.
    # <in> maxtries The maximum number of retries.

      if {![catch {set _cmriPort} oldport]} {
	error "The port is already open ($oldport),  close it first!"
      }
      set _cmriPort [CMri "$port" $baud $maxtries]
    }
    typemethod closeport {} {
    # Close the CMR/I port.  This type method closes the CMR/I port.

      if {[catch {set _cmriPort} oldport]} {return}
      $oldport -delete
      unset _cmriPort
    }
    typemethod portopenp {} {
    # Return port status.

      if {[catch {set _cmriPort} oldport]} {
	return no
      } else {
	return yes
      }
    }
    constructor {args} {
    # Constructor -- initialize a board.
    # <in> args Option list.

      if {![$type portopenp]} {
	error "Port is not open!  Open the port before initializing boards!"
      }
      $self configurelist $args
      switch -exact [string toupper $options(-type)] {
	SUSIC -
	USIC {
	  if {[string length "$options(-inputports)"] == 0} {
	    set options(-inputports) 0
	  }
	  if {[string length "$options(-outputports)"] == 0} {
	    set options(-outputports) 0
	  }
	  $_cmriPort InitBoard "$options(-cardmap)" $options(-inputports) \
		$options(-outputports) 0 $options(-address) \
		$_TypeCodes([string toupper $options(-type)]) \
		$options(-delay)
	}
	SMINI {
	  if {[string length "$options(-inputports)"] == 0} {
	    set options(-inputports) 3
	  }
	  if {[string length "$options(-outputports)"] == 0} {
	    set options(-outputports) 6
	  }
	  $_cmriPort InitBoard "$options(-yellowmap)" $options(-inputports) \
		$options(-outputports) $options(-numberofyellow) \
		$options(-address) \
		$_TypeCodes([string toupper $options(-type)]) 0
	}
      }
    }
    method inputs {} {
    # Method to fetch input port values.

      return [$_cmriPort Inputs $options(-inputports) $options(-address)]
    }
    method outputs {portvector} {
    # Method to set output ports.
    # <in> portvector Vector of output ports.

      $self _ValidateListOfBytes portvector "$portvector"
      if {[llength "$portvector"] != $options(-outputports)} {
	error "Wrong number of output port values, should be $options(-outputports), got $portvector ([llength $$portvector] elements)."
      }
      return [$_cmriPort Outputs $portvector $options(-address)]
    }
  }
}

    
package provide CmriSupport 1.0
