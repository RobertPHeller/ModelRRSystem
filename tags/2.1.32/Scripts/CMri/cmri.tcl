#* 
#* ------------------------------------------------------------------
#* cmri.tcl - C/MRI interface entirely in Tcl
#* Created by Robert Heller on Mon Apr 23 08:57:04 2012
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

## @defgroup Cmri Cmri 
#  @brief CMR/I Tcl Serial Port Interface.
# 
#  This is a cross-platform implementation of Bruce Chubb's C/MRI
#  QBASIC serial port code ported to Tcl. This code has been tested with 
#  Tcl 8.4.
#  
#  Basically, the way this code works is to use a SNIT class (described on in
#  CMri) to interface to the serial port, which may have 
#  one or more serial port cards (a mix of USICs, SUSICs, and SMINIs).  A given 
#  class instance interfaces to all of the cards on attached to a given serial 
#  port.  There are three public member functions, one to initialize a given 
#  board (described in CMri::InitBoard), one to set the 
#  output ports (described in CMri::Outputs), and one to 
#  poll the state of the input ports (described in
#  CMri::Inputs).
# 
#  I was inspired to write this code after reading the four part series in 
#  Model Railroader and reading the download package for the SMINI card.  I
#  already have a copy of Bruce Chubb's Build Your Own Universal
#  Computer Interface, but the SMINI looks like a great option for
#  small ``remote'' locations of a layout where there are a few turnouts
#  and a some signals, such as a small junction, interchange yard, or
#  isolated industrial spur.
#
#  @author Robert Heller @<heller\@deepsoft.com@>
# 
#  @{


package require gettext
package require snit


namespace eval cmri {
  ##  
  #  @brief CMR/I Tcl Serial Port Interface.
  # 
  #  This is a cross-platform implementation of Bruce Chubb's C/MRI
  #  QBASIC serial port code ported to Tcl. This code has been tested with 
  #  Tcl 8.4.
  #  
  #  Basically, the way this code works is to use a SNIT class (described on in
  #  CMri) to interface to the serial port, which may have 
  #  one or more serial port cards (a mix of USICs, SUSICs, and SMINIs).  A given 
  #  class instance interfaces to all of the cards on attached to a given serial 
  #  port.  There are three public member functions, one to initialize a given 
  #  board (described in CMri::InitBoard), one to set the 
  #  output ports (described in CMri::Outputs), and one to 
  #  poll the state of the input ports (described in
  #  CMri::Inputs).
  # 
  #  I was inspired to write this code after reading the four part series in 
  #  Model Railroader
  #  and reading the download package for the SMINI card.  I
  #  already have a copy of Bruce Chubb's Build Your Own Universal
  #  Computer Interface, but the SMINI looks like a great option for
  #  small ``remote'' locations of a layout where there are a few turnouts
  #  and a some signals, such as a small junction, interchange yard, or
  #  isolated industrial spur.
  # 
  #
  #  @author Robert Heller @<heller\@deepsoft.com@>
  # 
  #  @section cmri_package Package provided
  #
  #  Cmri 2.0.0
  #

  snit::enum CardType -values {
    ## @enum CardType 
    # Card type codes.
    #
    USIC 
    ## Classic Universal Serial Interface Card.
    SUSIC 
    ## Super Classic Universal Serial Interface Card.
    SMINI
    ## SMINI Super Mini node.
  }

  snit::integer uatype -min 0 -max 127
  ## @typedef int uatype
  # @brief Board address type.
  # 
  # An integer in the range from 0 to 127, inclusive.
  #

  snit::integer ubyte  -min 0 -max 255
  ## @typedef unsigned char ubyte
  # @brief Unsigned byte.
  #
  # 8-bit unsigned byte.
  #
  snit::listtype ByteList -type cmri::ubyte
  ## @typedef list<cmri::ubyte> ByteList
  # List of bytes.
  #
  # Contains a list of unsigned bytes.

  snit::type CMri {
  ## @brief Main C/MRI interface class.
  #
  # This class implements the interface logic for
  # all of the boards on a given serial bus, attached to a given serial (COM) 
  # port.  This class effectively implements in Tcl what the QBasic
  # serial I/O subroutines implemented by Bruce Chubb implement under MS-Windows.
  #
  # The constructor opens the serial port and does low-level serial I/O setup
  # (BAUD rate, etc.). This is the first part of the INIT subroutine.
  #
  # The InitBoard() member function initializes a selected board (the 
  # second part of the INIT subroutine) and the Inputs() and 
  # Output() member functions correspond to the INPUTS and 
  # OUTPUTS subroutines.
  #
  # The private members, _transmit() and _readbyte() correspond 
  # to the TXPACK and RXBYTE subroutines.
  #
  # @param port Name of the serial port connected to the Chubb RS485 bus.
  # @param ... Options:
  # @arg -baud Data rate, readonly, defaults to 9600, can be one of 9600, 
  #			19200, 28800, 57600, or 115200.
  # @arg -maxtries The maximum number of tries when reading the bus. It is
  #		readonly and defaults to 10000.  Must be an integer between 
  #		1000 and 100000.
  # @par
  # @author Robert Heller @<heller\@deepsoft.com@>
  #

    typevariable CardType_Byte -array {}
    ## @privatesection Array of CardType code bytes.
    typevariable STX 2
    ## Start of Text.  Used at the start of message blocks.
    typevariable ETX 3
    ## End of text.  Used at the end of message blocks.
    typevariable DLE 16
    ## Data Link Escape.  Used to escape special codes.
    typevariable AddressCode
    ## Address code.
    typevariable Init
    ## Initialize message.  Initialize a serial interface board.
    typevariable Transmit
    ## Transmit message.  Send data to output ports.
    typevariable Poll
    ## Poll message.  Request the board to read its input ports.
    typevariable Read
    ## Read message.  Generated by a board in response to a Poll message.
    typeconstructor {
      ## Initialize typevariables.
      scan "NXM" %c%c%c CardType_Byte(USIC) CardType_Byte(SUSIC) \
			CardType_Byte(SMINI)
      scan "A" %c AddressCode
      scan "I" %c Init
      scan "T" %c Transmit
      scan "P" %c Poll
      scan "R" %c Read
    }
    option -baud -readonly yes -default 9600 \
		-type {snit::enum -values {9600 19200 28800 57600 115200}}
    option -maxtries -readonly yes -default 10000 \
		-type {snit::integer -min 1000 -max 100000}

    variable ttyfd
    ## Terminal file descriptor.

    constructor {port args} {
      ## @publicsection Constructor.
      # @param port Name of the serial port connected to the Chubb RS485 bus.
      # @param ... Options:
      # @arg -baud Data rate, readonly, defaults to 9600, can be one of 9600,
      #                     19200, 28800, 57600, or 115200.
      # @arg -maxtries The maximum number of tries when reading the bus. It is
      #             readonly and defaults to 10000.  Must be an integer between
      #             1000 and 100000.
      # @par

      $self configurelist $args

      if {[catch {open $port r+} ttyfd]} {
	set theerror $ttyfd
	catch {unset ttyfd}
	error [_ "Failed to open port %s because %s." $port $theerror]
	return
      }
      if {[catch {fconfigure $ttyfd -mode}]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "%s is not a terminal port." $port]
	return
      }
      set stop 1
      if {$options(-baud) > 28800} {set stop 2}
      if {[catch {fconfigure $ttyfd -mode $options(-baud),n,8,$stop \
				    -blocking no -buffering none \
				    -encoding binary -translation binary \
				    -handshake none} err]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "Cannot configure port %s because %s." $port $err]
	return
      }
    }
    destructor {
      ## The destructor restores the serial port's state and closes it.
      if {![catch {set ttyfd}]} {close $ttyfd}
      catch {unset ttyfd}
    }
    method Inputs {ni {ua 0}} {
      ## The Inputs() function polls the interface and collects the input
      # port values returned by the serial card. 
      #
      # The result is a freshly allocated List object.  The calling 
      # program should free this memory with delete().  
      # Inputs() returns a NULL pointer if there was an error.
      # @param ni The number of input ports to be read.  Must equal
      #	  the number of ports on the specified card. 
      # @param ua The card address.
      #
      if {[catch {set ttyfd}]} {
	error [_ "The port is not open!"]
      }
      if {[catch {cmri::uatype validate $ua}]} {
	error [_ "The address (ua) is out of range: %d." $ua]
	return
      }
      snit::integer validate $ni
      $self _transmit $ua $Poll {}
      set thebyte 0
      while {$thebyte != $STX} {
	if {![$self _readbyte thebyte]} {
	  error [_ "There was a receive error."]
	}
      }
      if {![$self _readbyte thebyte]} {
	error [_ "There was a receive error."]
      }
      if {($thebyte - $AddressCode) != $ua} {
	error [_ "Received a bad address (ua) = %d." [expr {$thebyte - $AddressCode}]]
      }
      if {![$self _readbyte thebyte]} {
	error [_ "There was a receive error."]
      }
      if {$thebyte != $Read} {
	error [_ "The received message was not a Read message for address %d." $ua]
      }
      set result [list]
      for {set i 0} {$i < $ni} {incr i} {
	if {![$self _readbyte thebyte]} {
	  error [_ "There was a receive error."]
	}
	if {$thebyte == $STX || $thebyte == $ETX} {
	  error [_ "There was no DLE ahead of STX or ETX for address (ua): %d." $ua]
	}
	if {$thebyte == $DLE} {
	  if {![$self _readbyte thebyte]} {
	    error [_ "There was a receive error."]
	  }
	}
	lappend result $thebyte
      }
      if {![$self _readbyte thebyte]} {
	error [_ "There was a receive error."]
      }
      if {$thebyte != $ETX} {
	error [_ "An ETX not properly received for ua address %d." $ua]
      }
      return $result      
    }
    method Outputs {ports {ua 0}} {
      ## The Outputs() function sends bytes to the output ports managed
      # by the specified card. Since each element is written to one 8-bit 
      # output port, each element is presumed to be a integer in the range
      # of 0 to 255. 
      # @param ports The list of port values.  Should have as many
      #	  elements as there are output ports.
      # @param ua The card address.
      #

      #puts stderr "*** $self Outputs $ports $ua"
      if {[catch {set ttyfd}]} {
	error [_ "The port is not open!"]
      }
      if {[catch {cmri::uatype validate $ua}]} {
	error [_ "The address (ua) is out of range: %d." $ua]
	return
      }
      cmri::ByteList validate $ports
      set no [llength $ports]
      set ob [list]
      foreach b $ports {
	if {[catch {cmri::ubyte validate $b}]} {
	  error [_ "Not an unsigned byte: %s in %s." $b $ports]
	}
	lappend ob $b
      }
      $self _transmit $ua $Transmit $ob
    }
    method InitBoard {CT ni no ns ua card dl} {
      ## The InitBoard() function initializes a given USIC, SUSIC, or
      # SMINI card. 
      #  @param CT The card type / yellow bi-color LED map. For USIC 
      #	     and SUSIC cards this is the card type map.  For the SMINI 
      #	     card this is a 6 element list containing the port pairs 
      #	     for any simulated yellow bi-color LEDs. 
      #	     
      #	     The card type map for USIC and SUSIC is a packed array of 
      #	     2-bit values, packed 4 per element (byte) from low to
      #	     high. Each 2-bit value is one of 0 (for no card), 1 (for 
      #	     an input card), or 2 (for an output card).  The cards
      #	     must be "packed" with no open slots except at the end
      #	     of the bus. 
      #
      #	     For the simulated yellow LEDs (SMINI card) the paired
      # 	     bits must be adjacent red/green bits and cannot span ports.
      # @param ni The total number of input ports (must be 3 for SMINI).
      # @param no The total number of output ports (must be 6 or SMINI).
      # @param ns The number of yellow bi-color LED signals.  Only
      #	  used for SMINI cards.  For USIC and SUSIC cards the Length()
      #	  member function of the CT parameter is used. 
      # @param ua The card address.
      # @param card The card type.
      # @param dl The delay value to use.
      #
      if {[catch {set ttyfd}]} {
	error [_ "The port is not open!"]
      }
      if {[catch {cmri::uatype validate $ua}]} {
	error [_ "The address (ua) is out of range: %d." $ua]
	return
      }
      if {[catch {cmri::CardType validate $card}]} {
	error [_ "Not a valid card type: %s, should be one of USIC, SUSIC, or SMINI." $card]
      }
      cmri::ByteList validate $CT
      set ctlen [llength $CT]
      snit::integer validate $ni
      snit::integer validate $no
      snit::integer validate $ns
      snit::integer validate $dl
      switch $card {
	USIC -
	SUSIC {
	  # ns parameter not used with USIC and SUSIC cards.  
	  # CT list length used instead.
	  set ns $ctlen
	  # Verify that the input and output port counts are consistent with
	  # the board map and make sure that the board map is 'legal'.
	  set nict 0; set noct 0; set i 0
	  foreach cti $CT {
	    set cti_orig $cti
	    for {set j 0} {$j < 4} {incr j} {
	      set _card [expr {$cti & 0x03}]
	      set cti  [expr {($cti >> 2) & 0x3f}]
	      switch $_card {
		1 {incr nict}
		2 {incr noct}
		3 {error [_ "Invalid card type (CT) at index %d (%d)." $i $cti_orig]
		   return}
	      }
	      if {$_card == 0} {
		if {$cti == 0 && ($i+1) == $ns} {
		  break
		} else {
		  error [_ "Card type positioning error (CT) at index %d (%d)." $i $cti_orig]
		  return
		}
	      }
	    }
	    incr i
	  }
	  if {$card eq "USIC"} {
	    set noct [expr {$noct * 3}]
	    set nict [expr {$nict * 3}]
	  } else {
	    set noct [expr {$noct * 4}]
	    set nict [expr {$nict * 4}]
	  }
	  if {$noct != $no} {
	    error [_ "The number of output ports counted in the card type vector (%d) not equal to the number of output cards (no): %d." $noct $no]
	    return
	  }
	  if {$nict != $ni} {
	    error [_ "The number of input ports counted in the card type vector (%d) not equal to number of input cards (ni): %d." $nict $ni]
	    return
	  }
	}
	SMINI {
	  if {$ni != 3} {
	    error [_ "The number of input ports must be = 3 for SMINI, got %d." $ni]
	    return
	  }
	  if {$no != 6} {
	    error [_ "The number of output ports must be = 6 for SMINI, got %d." $no]
	    return
	  }
	  if {$ns < 0 || $ns > 24} {
	    error [_ "The number of yellow signals is out of the range of 0 to 24 for SMINI, got %d." $ns]
	    return
	  }
	  if {$ctlen > 6} {
	    set ctlen 6
	    set CT [lrange $CT 0 5]
	  }
	  set nscnt 0
	  set i 0
	  foreach cti $CT {
	    set cti_orig $cti
	    while {$cti > 1} {
	      if {($cti & 0x03) == 3} {
	        incr nscnt
		set cti [expr {($cti >> 2) & 0x3f}]
	      } elseif {($cti & 0x03) == 0} {
		set cti [expr {($cti >> 2) & 0x3f}]
	      } elseif {($cti & 0x03) == 2} {
	        set cti [expr {($cti >> 1) & 0x7ff}]
	      } else {
		break
	      }
	    }
	    if {$cti != 0} {
	      error [_ "The card type at index %d is invalid: %d for a SMINI." $i $cti_orig]
	      return
	    }
	    incr i
	  }
	  if {$ns != $nscnt} {
	    error [_ "The signal count from the card type vector is not equal to the number of signals for a SMINI."]
	    return
	  }
	}
      }
      set ob [list $CardType_Byte($card) \
		   [expr {($dl >> 8) & 0x0ff}] \
		   [expr {$dl& 0x0ff}] \
		   $ns]
      set lm 3
      switch $card {
	USIC -
	SUSIC {
	  foreach cti $CT {
	    lappend ob $cti
	    incr lm
	  }
	}
	SMINI {
	  if {$ns > 0} {
	    set i 0
	    foreach cti $CT {
	      lappend ob $cti
	      incr lm
	      incr i
	    }
	    while {$i < $ctlen} {
	      lappend ob 0
	      incr lm
	      incr i
	    }
	  }
	}
      }
      $self _transmit $ua $Init $ob
    }
    method _transmit {ua mt ob} {
      ## @privatesection
      ## @brief  Data transmitter.
      #  The data is built into a proper message and sent out the
      # serial port to the selected card. Returns false on error and true
      # on success.
      # @param ua The card address.
      # @param mt The message type.
      # @param ob The data buffer (not used for Poll messages).
      #

      #puts stderr "*** $self _transmit: ob is $ob"
      set tb [list 0x0ff 0x0ff $STX [expr {$AddressCode + $ua}] $mt]
      set tp 5
      #puts stderr [format "*** $self _transmit: mt is %c" $mt]
      if {$mt != $Poll} {
	foreach obi $ob {
	  if {$obi == $STX || $obi == $ETX || $obi == $DLE} {
	    lappend tb $DLE
	  }
	  lappend tb $obi
	}
      }
      lappend tb $ETX
      #puts stderr "*** $self _transmit: sending $tb"
      puts -nonewline $ttyfd [binary format c* $tb]
      return true
    }
    variable _timeout 0
      ## Timeout flag.
    method _readevent {} {
      ## Read event method.
      incr _timeout -1
    }
    method _readbyte {thebytevar} {
      ##   Read a single byte from the serial interface.  Used by
      # the Inputs() function. Returns false on error and 
      # true on success.
      # @param thebytevar A name of a variable to put the byte read.  
      #   Undefined if there was an error. 
      #
      upvar $thebytevar thebyte
      foreach {in out} [fconfigure $ttyfd -queue] {break}
      #puts stderr "*** $self _readbyte (at start): in = $in"
      for {set i 0} {$i < $options(-maxtries)} {incr i} {
	if {$in > 0} {
	  set therawbyte [read $ttyfd 1]
          binary scan $therawbyte c thebyte
	  set thebyte [expr {$thebyte & 0x0ff}]
          #puts stderr "*** $self _readbyte: read $thebyte"
          return true
	}
	set _timeout 0
	set aid [after 100 incr [myvar _timeout]]
	fileevent $ttyfd readable [mymethod _readevent]
	vwait [myvar _timeout]
	fileevent $ttyfd readable {}
	after cancel $aid
	foreach {in out} [fconfigure $ttyfd -queue] {break}
	#puts stderr "*** $self _readbyte: in = $in,  _timeout = $_timeout"
      }
      return false
    }
  }
}

## @}


package provide Cmri 2.0.0

