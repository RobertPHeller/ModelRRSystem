#* 
#* ------------------------------------------------------------------
#* raildriver_client.tcl - Raildriver Client class
#* Created by Robert Heller on Wed May 23 07:36:59 2012
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

## @defgroup RaildriverClientModule RaildriverClientModule
# @brief Raildriver Client class code.
#
# This is the Tcl SNIT class that implements a client that connects to the
# RailDriver daemon.
#
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @{

package require gettext
package require snit

namespace eval raildriver {
  ## @brief Namespace that holds the Raildriver Client class code.
  #
  # @author Robert Heller \<heller\@deepsoft.com\>
  #
  # @section raildriver_package Package provided
  #
  # RaildriverClient 1.0.0
  #

  snit::enum RaildriverEvents -values {
	## @enum RaildriverEvents
	#
	#  These are the event codes for the Rail Driver's report
	# message.  There is a code for each of the thirteen bytes in the 
	# report buffer.
	#
    REVERSER 
	## @brief   Reverser lever.
	#
	#  This is a value between 0 and 255 representing the position 
	# of the reverser lever.
	#
    THROTTLE 
	## @brief   Throttle lever.
	#
	# This is a value between 0 and 255
	# representing the position of the throttle / dynamic brake 
	# lever.
    AUTOBRAKE 
	## @brief Automatic Brake lever.
	#
	#  This is a value between 0 and 255
	# representing the position of the automatic brake lever.
    INDEPENDBRK 
	## @brief Independent Brake lever.
	#
	# This is a value between 0 and 255
	#  representing the position of the independent brake lever.
    BAILOFF 
	## @brief Independent Brake bail off.
	#
	# This is a value between 0 and
	# 255 representing the position of the independent brake lever
	# bail off.
    WIPER 
	## @brief Wiper switch.
	#
	#  This is a value between 0 and 255
	# representing the position of the wiper switch.
    HEADLIGHT 
	## @brief Headlight switch.
	#
	#  This is a value between 0 and 255
	# representing the position of the headlight switch.
    DIGITAL1 
	## @brief Blue Buttons 1-8.
	#
	#  This is a bitfield representing 8
	# of the generic ``blue'' buttons.
    DIGITAL2 
	## @brief Blue Buttons 9-16.
	#
	#  This is a bitfield representing 8
	# of the generic ``blue'' buttons.
    DIGITAL3 
	## @brief Blue Buttons 17-24.
	#
	#   This is a bitfield representing 8
	# of the generic ``blue'' buttons.
    DIGITAL4 
	## @brief Blue Buttons 25-28, Zoom, Pan.
	#
	#  This is a bitfield
	# representing the last 4 of the generic ``blue'' buttons,
	# the zoom rocker, and one-half of the pan (2d) rocker.
    DIGITAL5 
	## @brief Pan, Cab Buttons.
	#
	#  This is a bitfield representing
	# the second half of the pan (2d) rocker, and several
	# of the two of the cab rocker switches.
    DIGITAL6
	## @brief Cab Buttons, Whistle.
	#
	# This is a bitfield representing
	# the cab buttons and the whistle lever.
  }

  snit::listtype eventlist -type raildriver::RaildriverEvents
  ## @typedef list<raildriver::RaildriverEvents> eventlist
  # List of event codes.

  snit::type RaildriverClient {
    ## @brief Raildriver Client class -- connects to the Raildriver daemon.
    # Polls at interals for Raildriver input events.
    #
    # Options:
    # @arg -port Port (on localhost) to connect to. The default is 41000.
    # @arg -pollinterval Interval in milliseconds (between 250 and 2000) to 
    #			poll the daemon. The default is 500.
    # @arg -pollevents List of events to poll for.  See 
    # 			raildriver::RaildriverEvents for the allowed element
    #			values.  The default is the empty list.
    # @arg -eventhandler A script (at the global level) to evaluate when a 
    #			message arrives from the daemon.  Two elements are
    #			appended: the message status code and the text
    #			of the message.  The default is no handler.
    # @par
    option -port -readonly yes -default 41000 -type {snit::integer -min 41000}
    option -pollinterval -default 500 -type {snit::integer -min 250 -max 2000}
    option -pollevents -default {} -type {snit::listtype -type raildriver::RaildriverEvents}
    option -eventhandler -default {}
    variable socket {}
    ## @private @brief The socket descriptor connected to the daemon.
    variable pollid
    ## @private @brief Holds the poll after id.
    constructor {args} {
      ## @brief Construct a RaildriverClient object.
      # 

#      puts stderr "*** $type create $self $args"
      $self configurelist $args
      if {[catch {socket localhost $options(-port)} socket]} {
	set err $socket
	unset socket
	error [_ "Could not connect to daemon on port %s because %s." \
			$options(-port) $err]
	return
      }
      fconfigure $socket -buffering line
      fileevent $socket readable [mymethod _readevent]
      set pollid [after $options(-pollinterval) [mymethod _poller]]
    }
    method _readevent {} {
      ## @privatesection @brief Handle messages from the daemon.
      #

#      puts stderr "*** $self _readevent"
      if {[gets $socket line] < 0} {
	catch {close $socket}
	catch {unset socket}
	catch {after cancel $pollid}
	catch {unset pollid}
        return
      } else {
	if {[regexp {^([[:digit:]]+)[[:space:]]+(.*)$} $line -> status message] > 0} {
	  set cmd $options(-eventhandler)
	  if {$cmd ne {}} {
	    uplevel #0 $cmd [list $status $message]
	  }
	}
      }
    }
    method _poller {} {
      ## @brief Polling function.

#      puts stderr "*** $self _poller"
      if {[catch {set socket}]} {return}
      if {[llength $options(-pollevents)] > 0} {
	set message POLLVALUES
	foreach event $options(-pollevents) {
	  append message " $event"
	}
	puts $socket $message
	flush $socket
      }
      set pollid [after $options(-pollinterval) [mymethod _poller]]
    }
    destructor {
      ## @publicsection @brief close the connection.

#      puts stderr "*** $self destroy"
      catch {puts $socket "EXIT"}
      catch {flush $socket}
      catch {close $socket}
      catch {unset socket}
      catch {after cancel $pollid}
    }
    method clear {} {
      ## @brief Send a CLEAR message to the daemon.

#      puts stderr "*** $self clear"
      puts $socket "CLEAR"
      flush $socket
    }
    method mask {args} {
      ## @brief Send a MASK message to the daemon.
      #
      # @param ... Mask values

#      puts stderr "*** $self mask $args"
      raildriver::eventlist validate $args
      set message MASK
      foreach event $args {
	append message " $event"
      }
      puts $socket $message
      flush $socket
    }
    method leds {ledstring} {
      ## @brief Send a LED message to the daemon.
      #
      # @param ledstring Led string to display.
      # 

#      puts stderr "*** $self leds $ledstring"
      puts $socket "LED $ledstring"
      flush $socket
    }
    method speaker {onoff} {
      ## @brief Turn the speaker on or off.
      #
      # @param onoff Boolean indicating on (true) or off (false).
      #

#      puts stderr "*** $self speaker $onoff"
      snit::boolean validate $onoff
      if {$onoff} {
	puts $socket "SPEAKER ON"
      } else {
        puts $socket "SPEAKER OFF"
      }
      flush $socket
    }
  }
}

## @}

package provide RaildriverClient 1.0.0


