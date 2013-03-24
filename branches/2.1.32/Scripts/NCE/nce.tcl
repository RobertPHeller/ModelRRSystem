#* 
#* ------------------------------------------------------------------
#* nce.tcl - NCE Cab Bus interface
#* Created by Robert Heller on Tue May  8 09:17:19 2012
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

## @defgroup NCEModule NCEModule 
# @brief NCE Cab Bus interface code. 
#
# This is the Tcl SNIT class that interfaces with the NCE Cab Bus. It
# works with either the NCE USB Interface board (typically with the
# Power Cab) OR the NCE RS232 interface (typically used with the CS02 
# command station).
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @{

package require gettext
package require snit

namespace eval nce {
  ## @brief Namespace that holds the NCE interface code.
  #
  # This is a cross-platform implementation the NCE Cab Bus serial 
  # port interface. Based on documentation provided by NCE (usb_1.pdf 
  # and Bincmds.pdf).
  #
  # Basically, the way this code works is to use a class to interface to the
  # real RS232 port attached to a CS02 command station OR the 'virtual'
  # serial port implemented by the NCE USB Interface Board connected to the
  # NCE Cab Bus.
  #
  #
  # @author Robert Heller \<heller\@deepsoft.com\>
  #
  # @section nce_package Package provided
  #
  # NCE 1.0.0
  
  proc ErrorMessage {code} {
    ## @brief Return the error message, given the error code.
    #
    # This function returns the error message associated with a given error 
    # code.
    # @param code Error code returned.
    # @return A localized error message string.
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    switch [format %c $code] {
      0 {return [_ "Command not supported."]}
      1 {return [_ "Loco/accy/signal address out of range."]}
      2 {return [_ "Cab address or op code out of range."]}
      3 {return [_ "CV address or data out of range."]}
      4 {return [_ "Byte count out of range."]}
      ! {return [_ "Command completed successfully."]}
    }
  }
  snit::integer LocoAddress -min 0 -max 0x3fff
  ## @typedef int LocoAddress
  # Locomotive address type.
  snit::integer ConsistAddress -min 0 -max 0x7f
  ## @typedef int ConsistAddress
  # Consist address type.
  snit::integer AccessoryNumber -min 0 -max 0x3fff
  ## @typedef int AccessoryNumber
  # Accessory address type.
  snit::integer MacroNumber -min 0 -max 255
  ## @typedef int MacroNumber
  # NCE Macro number.
  snit::integer CabNumber -min 0 -max 63
  ## @typedef int CabNumber
  # Cab number type.
  snit::integer Hours -min 0 -max 23
  ## @typedef int Hours
  # Hours type.
  snit::integer Minutes -min 0 -max 59
  ## @typedef int Minutes
  # Minutes type.
  snit::integer ScaleClockRatio -min 1 -max 25
  ## @typedef int ScaleClockRatio
  # Scale clock ratio range
  snit::enum SpeedMode -values {
  ## @enum SpeedMode
      S14
      ## Fourteen speed step mode.
      S28
      ## Twenty eight speed step mode. 
      S128
      ## 128 speed step mode.
  }
  snit::enum Direction -values {
  ## @enum Direction
     Forward
     ## Forward direction.
     Reverse
     ## Reverse direction.
  }
  snit::integer EchoMode -min 0 -max 2
  ## @typedef int EchoMode
  # This is really should be an enumeration, but works as a limited range 
  # integer. Allowed values are:
  # @arg 0 No echo.
  # @arg 1 Echo 1st byte of command.
  # @arg 2 Echo entire command.
  snit::integer Speed28 -min 0 -max 28
  ## @typedef int Speed28
  # 28 speed step speeds.
  snit::integer Speed128 -min 0 -max 128
  ## @typedef int Speed128
  # 128 speed step speeds.
  snit::integer CSAddress -min 0 -max 0xffff
  ## @typedef unsigned short int CSAddress
  # CSAddress type.
  snit::integer UByte -min 0 -max 0xff
  ## @typedef unsigned char UByte
  # Unsigned byte type (data byte).
  snit::listtype RAMData -minlen 1 -maxlen 16 -type nce::UByte
  ## @typedef list RAMData
  # Datalist for RAM data, 1 to 16 unsigned bytes.
  snit::stringtype LCDMessage16 -minlen 16 -maxlen 16 -regexp {^[ -_]*$}
  ## @typedef char LCDMessage16[16]
  # Data for 16 character LCD lines.
  snit::stringtype LCDMessage8 -minlen 8 -maxlen 8 -regexp {^[ -_]*$}
  ## @typedef char LCDMessage8[8]
  # Data for 8 character LCD lines.
  snit::listtype RawPacket -minlen 3 -maxlen 6 -type nce::UByte
  ## @typedef list RawPacket
  # Raw packets for writing raw packets to the temp queue.
  snit::listtype RawTrackPacket -minlen 3 -maxlen 5 -type nce::UByte
  ## @typedef list RawTrackPacket
  # Raw packets for writing raw packets to the track queue.
  snit::listtype RAMData8 -minlen 8 -maxlen 8 -type nce::UByte
  ## @typedef list RAMData8
  # Datalist for RAM data 8 unsigned bytes.
  snit::integer MomentumLevel -min 0 -max 9
  ## @typedef int MomentumLevel
  # Momentum level.
  snit::integer AspectBits -min 0x00 -max 0x1f
  ## @typedef int AspectBits
  # Aspect bit mask.

  snit::type NCE {
    ## @brief Main NCE Cab Bus interface class.
    #
    # This class implements the interface logic to connect to the NCE Cab Bus.
    # @param port Name of the serial port connected to the NCE Cab Bus.
    # @param ... Options:
    # @arg -baud Data rate, readonly, defaults to 9600, can be one of 9600 
    #	or 19200.
    # @par
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    #
    variable ttyfd
	##  Terminal file descriptor.
    option -baud -readonly yes -default 9600 \
		-type {snit::enum -values {9600 19200}}
    constructor {{port "/dev/ttyS0"} args} {
      ## Constructor.
      # @param port Name of the serial port connected to the NCE Cab Bus.
      # @param ... Options:
      # @arg -baud Data rate, readonly, defaults to 9600, can be one of 9600
      #		or 19200.
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
      # (Check handshake)
      if {[catch {fconfigure $ttyfd -mode $options(-baud),n,8,1 \
				    -blocking no -buffering none \
				    -encoding binary -translation binary \
				    -handshake rtscts} err]} {
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
    typevariable NumberOfBytesReturned -array {}
    ## Array containing the number of bytes expected for each command.
    typeconstructor {
      for {set i [expr {int(0x80)}]} {$i <= 0xB8} {incr i} {
	switch [format {0x%02X} $i] {
	  0x82 -
	  0x9B -
	  0xA1 -
	  0xA7 -
	  0xA9 {set NumberOfBytesReturned($i) 2}
	  0x8A {set NumberOfBytesReturned($i) 4}
	  0x8C -
	  0xAA {set NumberOfBytesReturned($i) 3}
	  0x8F {set NumberOfBytesReturned($i) 16}
	  0xAB -
	  0xAC {set NumberOfBytesReturned($i) 0}
	  default {set NumberOfBytesReturned($i) 1}
	}
      }
    }
    method NOP {} {
      ## NOP, dummy instruction.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse [list 0x80]]
    }
    method AssignLogo {locoaddress cabnumber} {
      ## @brief Assign loco to cab.
      # From Bincmds.pdf:
      #   Loco address for this command is always 2 bytes. The first
      #   byte is zero in the case of a short address. If the address
      #   is long then bits 6,7 of first byte must be set to 1
      # @param locoaddress Loco address (0-9999).
      # @param cabnumber Cab number (0-63)
      # @return The response message.
      #
      nce::LocoAddress validate $locoaddress
      nce::CabNumber validate $cabnumber
      set message [list 0x81]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message $cabnumber
      return [$self _sendMessageAndReturnResponse $message]
    }
    method ReturnClock {} {
      ##  Returns the fast clock to the RS232 port in binary mode.
      # @return The response message (hours, minutes).
      return [$self _sendMessageAndReturnResponse [list 0x82]]
    }
    method StopClock {} {
      ##  Stops the scale time clock.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse [list 0x83]]
    }
    method StartClock {} {
      ## Starts the scale time clock.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse [list 0x84]]
    }
    method SetClock {hours minutes} {
      ## @brief Set the scale time clock.
      # @param hours Hours (0-23).
      # @param minutes Minutes (0-59).
      # @return The response message.
      nce::Hours validate $hours
      nce::Minutes validate $minutes
      return [$self _sendMessageAndReturnResponse [list 0x85 $hours $minutes]
    }
    method SetClockFormat {format} {
      ## @brief Set clock 12/24 hours.
      # @param format Clock format flag: true for 24 hour format, false for 
      #	12 hour format.
      # @return The response message.
      snit::boolean validate $format
      if {$format} {
	set message [list 0x86 0x01]
      } else {
	set message [list 0x86 0x00]
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method SetClockRatio {ratio} {
      ## @brief Set clock speed (ratio).
      # @param ratio Scale clock ratio, 1-25.
      # @return The response message.
      nce::ScaleClockRatio validate $ratio
      return [$self _sendMessageAndReturnResponse [list 0x87 $ratio]
    }
    method DequeuePacket {locoaddress} {
      ## @brief Dequeue packet by loco addr.
      # Reads loco address from BIN_BUFF, finds the corresponding entry in 
      # TRK_Q and deletes the packet from the TRK_Q.
      # @param locoaddress Loco address (0-9999).
      #
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      set message [list 0x88]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method EnableMain {} {
      ## Enable main trk, kill prog.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse 0x89]
    }
    method ReturnAuxilaryInputUnit {cabnumber} {
      ## @brief Returns status of Auxilary Input Unit.
      # Returns four bytes. The first 2 bytes are a bit map
      # of the 14 AIU inputs. The last 2 bytes are a bit map
      # of any changes since this command was last given.
      # If the cab is greater than 63 it will be "forced" to 0.
      # The first time this command is given for a cab after the
      # command station is powered up or reset the change bytes
      # will be 0x3fff.
      # @param cabnumber Cab number (0-63)
      #
      # @return A list of two values, the bit map of values and the 
      #	changed bitmap of values or the list {-1 -1} if the operation is
      # unsupported.
      nce::CabNumber validate $cabnumber
      set result [$self _sendMessageAndReturnResponse [list 0x8A $cabnumber]]
      if {[llength $result] == 1 && [format %c [lindex $result 0]] eq "0"} {
	return [list -1 -1]
      } else {
        set current [expr {([lindex $result 0] << 8) | [lindex $result 1]}]
        set changed [expr {([lindex $result 2] << 8) | [lindex $result 3]}]
        return [list $current $changed]
      }
    }
    method DisableMain {} {
      ## Kill main track, enable program track.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse 0x8B]
    }
    method Dummy {} {
      ## Dummy instruction returns "!" followed by CR/LF
      # @return The response message.
      return [$self _sendMessageAndReturnResponse 0x8C]
    }
    method SetLocoSpeedMode {locoaddress mode} {
      ## @brief Sets the speed mode of loco.
      # @param locoaddress Loco address (0-9999).
      # @param mode Speed step mode, one of S14, S28, or S128.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::SpeedStepMode validate $mode
      set message [list 0x8D]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      switch $mode {
	S14 {lappend message 1}
	S28 {lappend message 2}
	S128 {lappend message 3}
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteToRAM {address args} {
      ## @brief Writes bytes to a command station RAM address.
      # @param address Address to start writing to.
      # @param ... Bytes to write (upto 16).
      # @return The response message.
      nce::CSAddress validate $address
      nce::RAMData validate $args
      set message [list 0x8E [expr {($address >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}] [llength $args]]
      set i 0
      foreach b $args {
	lappend message $b
	incr i
      }
      for {} {$i < 16} {incr i} {
	lappend message 0
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method ReadFromRAM {address} {
      ## @brief Returns 16 bytes from a RAM address.
      # @param address Address to start reading from.
      # @return The response message (16 data bytes).
      nce::CSAddress validate $address
      set message [list 0x8F [expr {($address >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteLCDLine3 {cabnumber textline} {
      ## Sends a message to LCD line 3 of a cab.
      # @param cabnumber Cab Number (0-63).
      # @param textline  A string of 16 printable characters.
      # @return The response message.
      nce::CabNumber validate $cabnumber
      nce::LCDMessage16 $textline
      set message [list 0x90 $cabnumber]
      foreach b [$self _explodechars $textline] {
	lappend message $b
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteLCDLine4 {cabnumber textline} {
      ## Sends a message to LCD line 4 of a cab.
      # @param cabnumber Cab Number (0-63).
      # @param textline  A string of 16 printable characters.
      # @return The response message.
      nce::CabNumber validate $cabnumber
      nce::LCDMessage16 $textline
      set message [list 0x91 $cabnumber]
      foreach b [$self _explodechars $textline] {
	lappend message $b
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteLCDRightLine2 {cabnumber textline} {
      ## Sends a message to the right side of LCD line 2 of a cab.
      # @param cabnumber Cab Number (0-63).
      # @param textline  A string of 8 printable characters.
      # @return The response message.
      nce::CabNumber validate $cabnumber
      nce::LCDMessage8 $textline
      set message [list 0x92 $cabnumber]
      foreach b [$self _explodechars $textline] {
	lappend message $b
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteRAWPacket {sendtimes args} {
      ## @brief Reads a raw packet to put in TEMP_Q.
      # @param sendtimes Number of times to send packet, 0 means don't send 
      # 	it. 255 is the same as 254 (system limitation).
      # @param ... Packet bytes to send, 3 to 6 bytes.
      # @return The response message.
      nce::UByte validate $sendtimes
      nce::RawPacket validate $args
      set len [llength $args]
      switch $len {
	3 {set message [list 0x93 $sendtimes]}
	4 {set message [list 0x94 $sendtimes]}
	5 {set message [list 0x95 $sendtimes]}
	6 {set message [list 0x96 $sendtimes]}
      }
      foreach b $args {
	lappend message $b
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteOneByteToRAM {address byte} {
      ## @brief Writes 1 byte to a command station RAM address.
      # @param address RAM address.
      # @param byte Byte to write.
      # @return The response message.
      nce::CSAddress validate $address
      nce::UByte validate $byte
      return [$self _sendMessageAndReturnResponse [list 0x97 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}] \
		$byte]]
    }
    method WriteTwoBytesToRAM {address byte1 byte2} {
      ## @brief Writes 2 bytes to a command station RAM address.
      # @param address RAM address.
      # @param byte1 First byte to write.
      # @param byte2 Second byte to write.
      # @return The response message.
      nce::CSAddress validate $address
      nce::UByte validate $byte1
      nce::UByte validate $byte2
      return [$self _sendMessageAndReturnResponse [list 0x98 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}] \
		$byte1 $byte2]]
    }
    method Write4BytesToRAM {address byte1 byte2 byte3 byte4} {
      ## @brief Writes 4 bytes to a command station RAM address.
      # @param address RAM address.
      # @param byte1 First byte to write.
      # @param byte2 Second byte to write.
      # @return The response message.
      nce::CSAddress validate $address
      nce::UByte validate $byte1
      nce::UByte validate $byte2
      nce::UByte validate $byte3
      nce::UByte validate $byte4
      return [$self _sendMessageAndReturnResponse [list 0x99 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}] \
		$byte1 $byte2 $byte3 $byte4]]
    }
    method Write8BytesToRAM {address args} {
      ## @brief Writes 4 bytes to a command station RAM address.
      # @param address RAM address.
      # @param byte1 First byte to write.
      # @param byte2 Second byte to write.
      # @return The response message.
      nce::CSAddress validate $address
      nce::RAMData8 validate $args
      set message [list 0x9A [expr {($address >> 8) & 0x0ff}] \
			[expr {$address & 0x0ff}]]
      foreach b $args {
	lappend message $b
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method ReturnAuxilaryInputUnitShortForm {cabnumber} {
      ## @brief Returns status of Auxilary Input Unit, short form.
      # This is a short form of CMD 0x8A. It returns only the first 
      # 2 bytes of command 0x8A. The 2 bytes are a bit map of the 14 
      # AIU inputs. If the cab is greater than 63 it will be "forced" to 0.
      # @param cabnumber Cab number (0-63)
      #
      # @return The bit map of values or -1 if the operation is
      # unsupported.
      nce::CabNumber validate $cabnumber
      set result [$self _sendMessageAndReturnResponse [list 0x9B $cabnumber]]
      if {[llength $result] == 1 && [format %c [lindex $result 0]] eq "0"} {
	return -1
      } else {
        return [expr {([lindex $result 0] << 8) | [lindex $result 1]}]
      }
    }
    method ExecuteMacro {macroNumber} {
      ## Executes a previously defined macro for route control.
      # @param macroNumber The macro number.
      # @return The response message.
      nce::UByte validate $macroNumber
      return [$self _sendMessageAndReturnResponse [list 0x9C $macroNumber]]
    }
    method ReadOneByteFromRAM {address} {
      ## @brief Reads 1 byte from a command station RAM address.
      # @param address RAM address.
      # @return The data byte.
      nce::CSAddress validate $address
      return [$self _sendMessageAndReturnResponse [list 0x9D \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}]]]
    }
    method ProgramMode {} {
      ## @brief  Enters Program track mode. 
      # Power is removed from mainline and applied to program track. 
      # The queues are formatted to send reset packets.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse [list  0x9E]]
    }
    method NormalMode {} {
      ## @brief Returns from Program track mode.
      # Power is restored to mainline and removed from program track. 
      # The queues are reinitialized for normal operation.
      # @return The response message.
      return [$self _sendMessageAndReturnResponse [list  0x9F]]
    }
    method WriteCVInPagedMode  {address data} {
      ## @brief Writes a CV in paged mode.
      # @param address CV address.
      # @param data Data to write.
      # @return The response message.
      nce::CSAddress validate $address
      nce::UByte $data
      return [$self _sendMessageAndReturnResponse [list 0xA0 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}] \
		$data]]
    }
    method ReadCVInPagedMode {address} {
      ## @brief Reads a CV in paged mode.
      # @param address CV address.
      # @return The register value, -1 for unsupported or -2 for bad CV number.
      nce::CSAddress validate $address
      set result [$self _sendMessageAndReturnResponse [list  0xA1 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}]]]
      if {[llength $result] == 1 && [format %c [lindex $result 0]] eq "0"} {
	return -1
      } elseif {[format %c [lindex $result 1]] eq "3"} {
	return -2
      } else {
	return [lindex $result 0]
      }
    }
    method SetLocomotiveSpeedAndDirection {locoaddress ssm dir speed} {
      ## @brief Set locomotive speed and direction.
      # @param locoaddress Locomotive address.
      # @param ssm Speed mode (either S28 or S128).
      # @param dir Direction (either Forward or Reverse).
      # @param speed Locomotive speed (0-28, 0-128, or 255 (means emergency stop)).
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::SpeedMode validate $ssm
      nce::Direction validate $dir
      nce::UByte validate $speed
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      if {$speed == 255} {
        switch $dir {
	  Reverse {lappend message 0x05 0x00}
	  Forward {lappend message 0x06 0x00}
	}
      } else {
	switch $ssm {
	  S28 {
	    nce::Speed28 validate $speed
	    switch $dir {
	      Reverse {lappend message 0x01 $speed}
	      Forward {lappend message 0x02 $speed}
	    }
	  }
	  S128 {
	    nce::Speed128 validate $speed
	    switch $dir {
	      Forward {lappend message 0x03 $speed}
	      Reverse {lappend message 0x04 $speed}
	    }
	  }
	  default {
	    error [_ "Unsupported speed mode: %s." $ssm]
	  }
	}
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method SetLocomotiveFunctionsGroup1 {locoaddress f0 f1 f2 f3 f4} {
      ##  Set locomotive functions, group 1.
      # @param address Locomotive address.
      # @param f0 Function 0.
      # @param f1 Function 1.
      # @param f2 Function 2.
      # @param f3 Function 3.
      # @param f4 Function 4.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      snit::boolean validate $f0
      snit::boolean validate $f1
      snit::boolean validate $f2
      snit::boolean validate $f3
      snit::boolean validate $f4
      if {$f0} {
	set fbyte 0x10
      } else {
	set fbyte 0x00
      }
      if {$f1} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f2} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f3} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f4} {set fbyte [expr {$fbyte | 0x08}]}
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message 0x07 $fbyte
      return [$self _sendMessageAndReturnResponse $message]
    }
    method SetLocomotiveFunctionsGroup2 {locoaddress f5 f6 f7 f8} {
      ##  Set locomotive functions, group 2.
      # @param address Locomotive address.
      # @param f5 Function 5.
      # @param f6 Function 6.
      # @param f7 Function 7.
      # @param f8 Function 7.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      snit::boolean validate $f5
      snit::boolean validate $f6
      snit::boolean validate $f7
      snit::boolean validate $f8
      set fbyte 0x00
      if {$f5} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f6} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f7} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f8} {set fbyte [expr {$fbyte | 0x08}]}
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message 0x08 $fbyte
      return [$self _sendMessageAndReturnResponse $message]
    }
    method SetLocomotiveFunctionsGroup3 {locoaddress f9 f10 f11 f12} {
      ##  Set locomotive functions, group 3.
      # @param address Locomotive address.
      # @param f9 Function 9.
      # @param f10 Function 10.
      # @param f11 Function 11.
      # @param f12 Function 12.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      snit::boolean validate $f9
      snit::boolean validate $f10
      snit::boolean validate $f11
      snit::boolean validate $f12
      set fbyte 0x00
      if {$f9} {set fbyte [expr {$fbyte | 0x01}]}
      if {$f10} {set fbyte [expr {$fbyte | 0x02}]}
      if {$f11} {set fbyte [expr {$fbyte | 0x04}]}
      if {$f12} {set fbyte [expr {$fbyte | 0x08}]}
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message 0x09 $fbyte
      return [$self _sendMessageAndReturnResponse $message]
    }
    method AddLocomotiveToMultiUnit {locoaddress mtr samedirection} {
      ##  Add locomotive to Multi-Unit.
      # @param locoaddress Locomotive address.
      # @param mtr Multi-Unit address.
      # @param samedirection The locomotive direction is the same as the
      #        consist direction.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::ConsistAddress validate $mtr
      snit::boolean validate $samedirection
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      if {$samedirection} {
	lappend message 0x0f $mtr
      } else {
	lappend message 0x0e $mtr
      }      
      return [$self _sendMessageAndReturnResponse $message]
    }
    method RemoveLocomotiveFromMultiUnit {locoaddress mtr} {
      ##  Remove locomotive to Multi-Unit.
      # @param locoaddress Locomotive address.
      # @param mtr Multi-Unit address (not used).
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::ConsistAddress validate $mtr
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message 0x10 0
      return [$self _sendMessageAndReturnResponse $message]
    }
    method AddLeadLocomotiveToMultiUnit {locoaddress mtr samedirection} {
      ##  Add lead locomotive to Multi-Unit.
      # @param locoaddress Locomotive address.
      # @param mtr Multi-Unit address.
      # @param samedirection The locomotive direction is the same as the
      #        consist direction.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::ConsistAddress validate $mtr
      snit::boolean validate $samedirection
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      if {$samedirection} {
	lappend message 0x0b $mtr
      } else {
	lappend message 0x0a $mtr
      }      
      return [$self _sendMessageAndReturnResponse $message]
    }
    method AddRearLocomotiveToMultiUnit {locoaddress mtr samedirection} {
      ##  Add rear locomotive to Multi-Unit.
      # @param locoaddress Locomotive address.
      # @param mtr Multi-Unit address.
      # @param samedirection The locomotive direction is the same as the
      #        consist direction.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::ConsistAddress validate $mtr
      snit::boolean validate $samedirection
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      if {$samedirection} {
	lappend message 0x0d $mtr
      } else {
	lappend message 0x0c $mtr
      }      
      return [$self _sendMessageAndReturnResponse $message]
    }
    method ChangeMomentumLevel {locoaddress newlevel} {
      ## Change momentum level for loco or consist.
      # @param locoaddress Locomotive or consist address.
      # @param newlevel New momentum level (0-9).
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::MomentumLevel validate $newlevel
      set message [list 0xA2]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message 0x12 $newlevel
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteRAWTrackPacket {args} {
      ## @brief Reads a raw packet to put in TRK_Q.
      # @param ... Packet bytes to send, 3 to 5 bytes.
      # @return The response message.
      nce::RawTrackPacket validate $args
      set len [llength $args]
      switch $len {
	3 {set message [list 0xA3]}
	4 {set message [list 0xA4]}
	5 {set message [list 0xA5]}
      }
      foreach b $args {
	lappend message $b
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method WriteRegister {register data} {
      ##  Writes a register.
      # @param register The register to write to.
      # @param data The data to write.
      # @return The response message.
      nce::UByte validate $register
      nce::UByte validate $data
      return [$self _sendMessageAndReturnResponse [list 0xA6 $register $data]]
    }
    method ReadRegister {register} {
      ##  Read a register.
      # @param register The register to read from.
      # @return The register value, -1 for unsupported or -2 for bad register number.
      nce::UByte validate $register
      set result [$self _sendMessageAndReturnResponse [list 0xA7 $register]]
      if {[llength $result] == 1 && [format %c [lindex $result 0]] eq "0"} {
	return -1
      } elseif {[format %c [lindex $result 1]] eq "3"} {
	return -2
      } else {
	return [lindex $result 0]
      }
    }
    method WriteCVInDirectMode  {address data} {
      ## @brief Writes a CV in direct mode.
      # @param address CV address.
      # @param data Data to write.
      # @return The response message.
      nce::CSAddress validate $address
      nce::UByte $data
      return [$self _sendMessageAndReturnResponse [list 0xA8 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}] \
		$data]]
    }
    method ReadCVInDirectMode {address} {
      ## @brief Reads a CV in direct mode.
      # @param address CV address.
      # @return The register value, -1 for unsupported or -2 for bad CV number.
      nce::CSAddress validate $address
      set result [$self _sendMessageAndReturnResponse [list  0xA9 \
		[expr {($address >> 8) & 0x0ff}] [expr {$address & 0x0ff}]]]
      if {[llength $result] == 1 && [format %c [lindex $result 0]] eq "0"} {
	return -1
      } elseif {[format %c [lindex $result 1]] eq "3"} {
	return -2
      } else {
	return [lindex $result 0]
      }
    }
    method SoftwareVersion {} {
      ## @brief Read software version number.
      # @return The software version as three bytes.
      return [$self _sendMessageAndReturnResponse [list 0xAA]]
    }
    method SoftReset {} {
      ## @brief  Soft reset of command station. 
      # Sets command Station to power up condition.
      return [$self _sendMessageAndReturnResponse [list 0xAB]]
    }
    method HardReset {} {
      ## @brief Hard reset of command station.
      # Clears all RAM and resets command station to original fac
      # defaults. All stored information is destroyed
      #  Note: the baud rate will be set to 9600
      return [$self _sendMessageAndReturnResponse [list 0xAC]]
    }
    method MacroCommand {address macronumber} {
      ## @brief Assign address to macro.
      # @param address Accessory address (not in DCC format).
      # @param macronumber NCE macro number (0-255).
      # @return The response message.
      nce::AccessoryAddress validate $address
      nce::MacroNumber validate $macronumber
      return [$self _sendMessageAndReturnResponse [list  0xAD \
		[expr {($address >> 8) & 0x3f}]  [expr {$address & 0x0ff}] \
		0x01 $macronumber]]
    }
    method AccessoryDecoderOperation {address activateOutput} {
      ##  Accessory decoder operation request.
      # @param address Accessory address (not in DCC format).
      # @param activateOutput Output on or off.
      # @return The response message.
      nce::AccessoryAddress validate $address
      snit::boolean validate $activateOutput
      set message [list 0xAD [expr {($address >> 8) & 0x3f}] \
      			 [expr {$address & 0x0ff}]]
      if {$activateOutput} {
	lappend message 0x03 0x00
      } else {
	lappend message 0x04 0x00
      }
      return [$self _sendMessageAndReturnResponse $message]
    }
    method SetSignalAspect {address aspectBits} {
      ## @brief Set signal aspect.
      # @param address Accessory address (not in DCC format).
      # @param aspectBits Signal aspect bit mask.
      # @return The response message.
      nce::AccessoryAddress validate $address
      nce::AspectBits validate $aspectBits
      set message [list 0xAD [expr {($address >> 8) & 0x3f}] \
				[expr {$address & 0x0ff}]]
      lappend message 0x05 $aspectBits
      return [$self _sendMessageAndReturnResponse $message]
    }
    method OperatingModeProgrammingByteModeWrite {locoaddress cv data} {
      ##  Operating mode programming byte mode write.
      # @param locoaddress Locomotive address.
      # @param cv CV to set.
      # @param data Data to set.
      # @return The response message.
      nce::LocoAddress validate $locoaddress
      nce::CSAddress validate $cv
      nce::UByte validate $data
      set message [list  0xAE]
      if {$locoaddress < 256} {
	lappend message 0x00 $locoaddress
      } else {
	set highbyte [expr {0x0c0 | (($locoaddress >> 8) & 0x3f)}]
	set lowbyte  [expr {0x0ff & $locoaddress}]
	lappend message $highbyte $lowbyte
      }
      lappend message [expr {($cv >> 8) & 0x0ff}] [expr {$cv & 0x0ff}] $data
      return [$self _sendMessageAndReturnResponse $message]
    }
    method OperatingModeAccessoryProgrammingByteModeWrite {address cv data} {
      ##  Operating mode accessory programming byte mode write.
      # @param address Accessory address.
      # @param cv CV to set.
      # @param data Data to set.
      # @return The response message.
      nce::AccessoryAddress validate $address
      nce::CSAddress validate $cv
      nce::UByte validate $data
      set message [list  0xAF]
      lappend [expr {($address >> 8) & 0x3f}]  [expr {$address & 0x0ff}]
      lappend message [expr {($cv >> 8) & 0x0ff}] [expr {$cv & 0x0ff}] $data
      return [$self _sendMessageAndReturnResponse $message]
    }
    method SetCabBusAddressOfUSBBoard {cabaddress} {
      ## Set the cab bus address of the USB board.
      # @param cabaddress Cab address.
      # @return The response message.
      nce::CabAddress validate $cabaddress
      return [$self _sendMessageAndReturnResponse [list 0xB1 $cabaddress]]
    }
    method SetBinaryCommandEchoMode {mode} {
      ## Set binary command echo mode.
      # @param mode Mode to set: 0 = no echo, 1 = echo 1st byte of command, 
      #	or 2 = echo entire command.
      # @return The response message.
      nce::EchoMode validate $mode
      return [$self _sendMessageAndReturnResponse [list 0xB2 $mode]]
    }
    method _transmit {themessage} {
      ## @privatesection Transmit a message.
      if {[catch {set ttyfd}]} {
	return
      }
      puts -nonewline $ttyfd [binary format c* $themessage]
    }
    variable _timeout 0
	## Timeout or data available flag
    method _readevent {} {
	## Read event handler, toggle timeout flag.
      incr _timeout -1
    }
    method _timeoutevent {} {
	## Timeout event handler, toggle timeout flag.
      incr _timeout 1
    }
    method _readbyte {thebytevar {timeout 5}} {
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
      if {$in > 0} {
	set therawbyte [read $ttyfd 1]
	binary scan $therawbyte c thebyte
	set thebyte [expr {$thebyte & 0x0ff}]
	return true
      } elseif {$oldscript eq {}} {
	set _timeout 0
	set e [after [expr {$timeout * 1000}] [mymethod _timeoutevent]]
	fileevent $ttyfd readable [mymethod _readevent]
	vwait [myvar _timeout]
	fileevent $ttyfd readable {}
	after cancel $e
	foreach {in out} [fconfigure $ttyfd -queue] {break}
	if {$in > 0} {
	  set therawbyte [read $ttyfd 1]
	  binary scan $therawbyte c thebyte
	  set thebyte [expr {$thebyte & 0x0ff}]
	  return true
	} else {
	  return false
	}
      } else {
	return false
      }
    }
    method _readresponse {bufferVar expectnumberofbytes} {
      ## Read a response message.
      upvar $bufferVar buffer
      set buffer {}
      for {set i 0} {$i < $expectnumberofbytes} {incr i} {
	if {[$self _readbyte thebyte]} {
	  lappend buffer $thebyte
	} else {
	  break
	}
      }
      return [llength $buffer]
    }
    method _sendMessageAndReturnResponse {message} {
      ## Send a message and return a response.
      set messagecode [expr {int([lindex $message 0])}]
      $self _transmit $message
      set expectedBytes $NumberOfBytesReturned($messagecode)
      if {$expectedBytes == 0} {
	return {}
      } else {
	set buffer {}
	set count [$self _readresponse buffer $expectedBytes]
	return $buffer
      }
    }
    method _explodechars {text} {
	## Explode text into ASCII character codes.
      set asciilist {}
      foreach char [split $text {}] {
	scan $char %c asc
	lappend asciilist $asc
      }
      return $asciilist
    }      
  }
}

## @}

package provide NCE 1.0.0

