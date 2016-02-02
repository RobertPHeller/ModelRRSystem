#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Feb 2 12:06:52 2016
#  Last Modified : <160202.1241>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#*****************************************************************************


## @defgroup LCCModule LCCModule
# @brief LCC (OpenLCB) interface code.
#
# These are Tcl SNIT classes that interface to the LCC / OpenLCB bus.
# 
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @{

package require gettext
package require snit

namespace eval lcc {
    ## @brief Namespace that holds the LCC interface code.
    #
    # This is a cross-platform implementation ...
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    # @section lcc Package provided
    #
    # LCC 1.0
    #
    
    snit::type Lcc {
        ## @brief Main LCC interface class.
        #
        # This class implements the interface logic to connect to the LCC bus.
        #
        # @author Robert Heller \<heller\@deepsoft.com\>
        #
        
    variable ttyfd
    ##  @private Terminal file descriptor.
    constructor {{port "/dev/ttyACM0"}} {
        ##  The constructor opens the serial port and initializes the port
        # @param name The name of the object to create (%AUTO% to generate a 
        # name).
        # @param port The serial port device file.
        
        #      puts stderr "*** $type create $self $port"
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
      # -- 38400 is a special case.  The setserial(8) command is used to set a
      # custom baud rate (125K).
      if {[catch {fconfigure $ttyfd -mode 38400,n,8,1 \
				    -blocking no -buffering none \
				    -encoding binary -translation binary \
				    -handshake rtscts} err]} {
	close $ttyfd
	catch {unset ttyfd}
	error [_ "Cannot configure port %s because %s." $port $err]
	return
      }
      set mode [fconfigure $ttyfd -mode]
  }
  destructor {
      ## The destructor restores
      if {![catch {set ttyfd}]} {close $ttyfd}
      catch {unset ttyfd}
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
  
