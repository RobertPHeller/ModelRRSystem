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

package require snit
package require Cmri 2.0.0

## @defgroup CmriSupport Cmri Support code
#  @{

namespace eval CmriSupport {
## @brief Cmri Support code.
#
#  This is high-level code to support the CMR/I code, in the form of a SNIT
#  type object that wraps the low-level class and creates a network of boards
#  on the bus that the low-level class accesses.
#
#  @author Robert Heller @<heller\@deepsoft.com@>
#
#  @section CmriSupport_package Package provided
#
#  CmriSupport 1.2
#

  snit::integer byte -min 0 -max 255

  snit::type CmriNode {
  ## @brief CMR/I node type.  
  #
  # This Snit type defines CMR/I nodes (SUSIC, USIC, or SMINI
  # boards) on a CMR/I network.  All options are readonly.
  #
  # @author Robert Heller @<heller\@deepsoft.com@>


    typevariable _TypeCodes -array {
	SUSIC SUSIC
	USIC  USIC
	SMINI SMINI
    }
    ## @private Node type codes.

    method _ValidateType {option value} {
    ## @private Method to validate the card type.
    # @param option The option to validate.
    # @param value The value to validate.

      if {[lsearch -exact [array names _TypeCodes] [string toupper "$value"]] < 0} {
	error "Expected a valid card type for $option, got $value"
      }
      return "$value"
    }
    option -type -readonly yes -validatemethod _ValidateType
    method _ValidateAddress {option value} {
    ## @private Method to validate a card address.
    # @param option The option to validate.
    # @param value The value to validate.

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
    ## @private Method to validate a list of bytes.
    # @param option The option to validate.
    # @param value The value to validate.

      foreach e $value {
	if {[string is integer -strict "$e"] &&
	    $e >= 0 && $e <= 255} {continue}
	error "Expected a list of bytes for $option, got $value"
      }
    }
    option -cardmap -default {} -readonly yes -validatemethod _ValidateListOfBytes
    method _ValidateSixElementListOfBytes {option value} {
    ## @private Method to validate a six element list of bytes.
    # @param option The option to validate.
    # @param value The value to validate.

      $self _ValidateListOfBytes $option $value
      if {[llength $value] != 6} {
	error error "Expected a 6 element list of bytes for $option, got $value"
      }
      return $value
    }
    option -yellowmap -default {0 0 0 0 0 0} -readonly yes -validatemethod _ValidateSixElementListOfBytes
    method _ValidateByte {option value} {
    ## @private Method to validate a byte value.
    # @param option The option to validate.
    # @param value The value to validate.

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
    ## @private Method to validate a word (16-bit) value.
    # @param option The option to validate.
    # @param value The value to validate.

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
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a C4TSMINI_Block
        # type.
        
        if {$object eq ""} {
            return $object;# Empty or null objects are OK
        } elseif {[catch {$object info type} itstype]} {
            error "$object is not a $type";# object is not a SNIT type
        } elseif {$itstype eq $type} {
            return $object;# Object is of our type (CmriNode)
        } else {
            error "$object is not a $type";# object is something else
        }
    }
    option -numberofyellow -readonly yes -default 0 -validatemethod _ValidateByte
    option -inputports -readonly yes -validatemethod _ValidateByte
    option -outputports -readonly yes -validatemethod _ValidateByte
    option -delay -readonly yes -default 0 -validatemethod _ValidateWord
    typecomponent _cmriPort
    # @private Holds the open CMR/I port object.
    typemethod openport {{port "/dev/ttyS0"} {baud 9600} {maxtries 10000}} {
        ## Open the CMR/I port.  This type method opens the CMR/I port.
        # @param port The serial port connected to the CMR/I network.
        # @param baud The BAUD rate to be used.
        # @param maxtries The maximum number of retries.
        
        catch {set _cmriPort} oldport
        if {$oldport ne {}} {
            error "The port is already open ($oldport),  close it first!"
        }
        set _cmriPort [cmri::CMri create %AUTO% "$port" -baud $baud -maxtries $maxtries]
    }
    typemethod closeport {} {
    ## Close the CMR/I port.  This type method closes the CMR/I port.

      if {[catch {set _cmriPort} oldport]} {return}
      $oldport destroy
      unset _cmriPort
    }
    typemethod portopenp {} {
    ## Return port status.

      if {[catch {set _cmriPort} oldport]} {
	return no
      } else {
	return yes
      }
    }
    variable outputbuffer {}
    ## Output buffer
    
    
    constructor {args} {
        ## Constructor -- initialize a board.
        # @param name Name of the node.
        # @param ... Options:
        # @arg -type The type of node, one of SUSIC, USIC, or SMINI. No default 
        #		   value.
        # @arg -address The address of the node.  Default is 0.
        # @arg -cardmap The card type map.  Only used with SUSIC and USIC. 
        #			Default is {}.
        # @arg -yellowmap The yellow bi-color LED map.  Only used with the SMINI
        #			card type. Default is {0 0 0 0 0 0}.
        # @arg -numberofyellow The number of yellow bi-color LED signals. Only
        #			for SMINI cards.  Default is 0.
        # @arg -inputports The number of 8-bit input ports.  Default 0 (3 for 
        #			SMINI cards).
        # @arg -outputports The number of 8-bit output ports.  Default 0 (6 for 
        #			SMINI cards).
        # @arg -delay The delay value to use.  Only meaningful for older (USIC)
        #			cards.  Default is 0.
        # @par

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
      set outputbuffer {}
      for {set i 0} {$i < $options(-outputports)} {incr i} {
          lappend outputbuffer 0
      }
      
    }
    method inputs {} {
    ## Method to fetch input port values.

      return [$_cmriPort Inputs $options(-inputports) $options(-address)]
    }
    method outputs {{portvector {}}} {
    ## Method to set output ports.
    # @param portvector Vector of output ports.
    
      if {$portvector eq {}} {set portvector $outputbuffer}
      $self _ValidateListOfBytes portvector "$portvector"
      if {[llength "$portvector"] != $options(-outputports)} {
	error "Wrong number of output port values, should be $options(-outputports), got $portvector ([llength $$portvector] elements)."
      }
      set outputbuffer $portvector
      return [$_cmriPort Outputs $portvector $options(-address)]
    }
    method setport {portnum byte} {
        ## Set and send one byte to a port (rewrites all ports).
        # @param portnum Number of the output port.
        # @param byte Value to write.
        
        CmriSupport::byte validate $byte
        if {$portnum < 0 || $portnum >= $options(-outputports)} {
            error "Port number ($portnum) out of range (0..$options(-outputports))"
        }
        lset outputbuffer $portnum $byte
        puts stderr "*** $self setport: outputbuffer is $outputbuffer"
        $self outputs
    }
    method setbitfield {portnum mask bits} {
        ## Set and send a bitfield to a port (rewrites all ports).
        # @param portnum Number of the output port.
        # @param mask Bit mask.
        # @param bits Bits (must already shifted into position!).
        
        CmriSupport::byte validate $mask
        CmriSupport::byte validate $bits
        if {$portnum < 0 || $portnum >= $options(-outputports)} {
            error "Port number ($portnum) out of range (0..$options(-outputports))"
        }
        set oldbyte [lindex $outputbuffer $portnum]
        set oldbyte [expr {((~$mask) & $oldbyte) & 0x0FF}]
        set newbyte [expr {$oldbyte | $bits}]
        $self setport $portnum $newbyte
    }
  }
}

## @}
    
package provide CmriSupport 1.2

