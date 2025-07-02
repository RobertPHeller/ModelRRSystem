#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue May 16 11:52:37 2017
#  Last Modified : <170516.1431>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
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


## @page CMRI_Slave Raspberry Pi as a C/MRI slave
# @brief Raspberry Pi as a C/MRI slave
#
# @section CMRI_SlaveSYNOPSIS SYNOPSIS
#
# CMRI_Slave [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section CMRI_SlaveDESCRIPTION DESCRIPTION
# @section CMRI_SlavePARAMETERS PARAMETERS
# @section CMRI_SlaveOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# CMRI_Slave.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is cmri_slaveconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section CMRI_SlaveCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section CMRI_SlaveAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] CMRI_Slave]

package require Tclwiringpi;#  require the Tclwiringpi package
package require snit;#     require the SNIT OO framework
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::enum PinModes -values {disabled in out high low}

snit::type GPIOPinNo {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
    
    typevariable BCMPins -array {
        0 17
        1 18
        2 27
        3 22
        4 23
        5 24
        6 25
        7 4
        21 5
        22 6
        23 13
        24 19
        25 26
        26 12
        27 16
        28 20
        29 21
    }
    typevariable GPIOPins -array {
        17 0
        18 1
        27 2
        22 3
        23 4
        24 5
        25 6
        4 7
        5 21
        6 22
        13 23
        19 24
        26 25
        12 26
        16 27
        20 28
        21 29
    }
    typemethod validate {pinno} {
        if {[info exists BCMPins($pinno)]} {
            return $pinno
        } else {
            error [_ "Not a GPIO pin number: %s" $pinno]
        }
    }
    typemethod AllPins {} {
        return [lsort -integer [array names BCMPins]]
    }
    typemethod BCMPinNo {gpiopinno} {
        if {[info exists BCMPins($gpiopinno)]} {
            return $BCMPins($gpiopinno)
        } else {
            error [_ "Not a GPIO pin number: %s" $gpiopinno]
        }
    }
    typemethod GPIOPinNo {bcmpinno} {
        if {[info exists GPIOPins($bcmpinno)]} {
            return $GPIOPins($bcmpinno)
        } else {
            error [_ "Not a BCM pin number: %s" $bcmpinno]
        }
    }
}


snit::type CMRI_Slave {
    pragma -hastypeinfo no   -hastypedestroy no -hasinstances   no
    
    #** This class implements a C/MRI slave (node) running on a Raspberry Pi
    # using the GPIO pins on the Raspberry Pi as the I/O pins.
    #
    
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  address;#           The "Address" of the node.
    typevariable  portchan;#          Channel to the serial I/O port.
    typevariable  GPIOCMD;#           gpio command
    
    #* Array of CardType code bytes.
    typevariable CardType_Byte -array {}
    #* Start of Text.  Used at the start of message blocks.
    typevariable STX 2
    #* End of text.  Used at the end of message blocks.
    typevariable ETX 3
    #* Data Link Escape.  Used to escape special codes.
    typevariable DLE 16
    #* Address code.
    typevariable AddressCode
    #* Initialize message.  Initialize a serial interface board.
    typevariable Init
    #* Transmit message.  Send data to output ports.
    typevariable Transmit
    #* Poll message.  Request the board to read its input ports.
    typevariable Poll
    #* Read message.  Generated by a board in response to a Poll message.
    typevariable Read
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the serial port and waits for C/MRI commands.
        
        ## Initialize typevariables.
        scan "NXM" %c%c%c CardType_Byte(USIC) CardType_Byte(SUSIC) \
              CardType_Byte(SMINI)
        scan "A" %c AddressCode
        scan "I" %c Init
        scan "T" %c Transmit
        scan "P" %c Poll
        scan "R" %c Read
        set GPIOCMD [auto_execok "gpio"]
        
        global argv
        global argc
        global argv0
        
        set debugnotvis 1
        set debugIdx [lsearch -exact $argv -debug]
        if {$debugIdx >= 0} {
            set debugnotvis 0
            set argv [lreplace $argv $debugIdx $debugIdx]
        }
        set configureator no
        set configureIdx [lsearch -exact $argv -configure]
        if {$configureIdx >= 0} {
            set configureator yes
            set argv [lreplace $argv $configureIdx $configureIdx]
        }
        set sampleconfiguration no
        set sampleconfigureIdx [lsearch -exact $argv -sampleconfiguration]
        if {$sampleconfigureIdx >= 0} {
            set sampleconfiguration yes
            set argv [lreplace $argv $sampleconfigureIdx $sampleconfigureIdx]
        }
        set conffile [from argv -configuration "cmri_slaveconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        if {$configureator} {
            $type ConfiguratorGUI $conffile
            return
        }
        if {$sampleconfiguration} {
            $type SampleConfiguration $conffile
            return
        }
       
        set deflogfilename [format {%s.log} [file tail $argv0]]
        set logfilename [from argv -log $deflogfilename]
        if {[file extension $logfilename] ne ".log"} {append logfilename ".log"}
        close stdin
        close stdout
        close stderr
        set null /dev/null
        if {$::tcl_platform(platform) eq "windows"} {
            set null nul
        }
        open $null r
        open $null w
        set logchan [open $logfilename w]
        fconfigure $logchan  -buffering none
        
        ::log::lvChannelForall $logchan
        ::log::lvSuppress info 0
        ::log::lvSuppress notice 0
        ::log::lvSuppress debug $debugnotvis
        ::log::lvCmdForall [mytypemethod LogPuts]
        
        ::log::logMsg [_ "%s starting" $type]
        
        ::log::log debug "*** $type typeconstructor: argv = $argv"
        
        if {[catch {open $conffile r} conffp]} {
            ::log::logError [_ "Could not open %s because: %s" $conffile $conffp]
            exit 99
        }
        set confXML [read $conffp]
        close $conffp
        if {[catch {ParseXML create %AUTO% $confXML} configuration]} {
            ::log::logError [_ "Could not parse configuration file %s: %s" $conffile $configuration]
            exit 98
        }
        set portnameele [$configuration getElementsByTagName "serialport"]
        if {[llength $portnameele] > 0} {
            set portnameele [lindex $portnameele 0]
            set portname [$portnameele data]
        } else {
            set portname /dev/ttyAMA0;# built-in serial port
        }
        set baudele [$configuration getElementsByTagName "baudrate"]
        if {[llength $baudele] > 0} {
            set baudele [lindex $baudele 0]
            set baud [$baudele data]
        } else {
            set baud 9600
        }
        set addressele [$configuration getElementsByTagName "address"]
        if {[llength $addressele] > 0} {
            set addressele [lindex $addressele 0]
            set address [$addressele data]
        } else {
            set address 0
        }
        
        
        if {[catch {open $portname r+} portchan]} {
            set theerror $portchan
            catch {unset portchan}
            ::log::logError [_ "Failed to open port %s because %s." $portname $theerror]
            exit 99
        }
        if {[catch {fconfigure $portchan -mode}]} {
            close $portchan
            catch {unset portchan}
            ::log::logError [_ "%s is not a terminal port." $portname]
            exit 99
        }
        set stop 1
        if {$baud > 28800} {set stop 2}
        if {[catch {fconfigure $portchan -mode $baud,n,8,$stop \
             -blocking no -buffering none \
             -encoding binary -translation binary \
             -handshake none} err]} {
            close $portchan
            catch {unset portchan}
            ::log::logError [_ "Cannot configure port %s because %s." $portname $err]
            exit 99
        }
        fileevent $portchan readable [mytypemethod _incoming]
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod _incoming {} {
        set thebyte 0
        while {$thebyte != $STX} {
            if {![$type _readbyte thebyte]} {
                ::log::logError [_ "There was a receive error."]
                exit 99
            }
        }
        if {![$type _readbyte thebyte]} {
            ::log::logError [_ "There was a receive error."]
            exit 99
        }
        if {($thebyte - $AddressCode) != $address} {
            # Not for us. Gobble the message and drop it on the floor.
            $type _readbyte thebyte
            while {$thebyte != $ETX} {
                if {$thebyte == $DLE} {
                    $type _readbyte thebyte
                }
                $type _readbyte thebyte
            }
            return
        }
        if {![$type _readbyte thebyte]} {
            ::log::logError [_ "There was a receive error."]
            exit 99
        }
        if {$thebyte == $Poll} {
            $type _sendBits
        } elseif {$thebyte == $Transmit} {
            $type _getandsetbits [$type _getmessageData]
        } elseif {$thebyte == $Init} {
            $type _initializePorts [$type _getmessageData]
        }
    }
    typemethod _getmessageData {} {
        # Read message data after a Transmit or Init message.
        set data [list]
        $type _readbyte thebyte
        while {$thebyte != $ETX} {
            if {$thebyte == $DLE} {
                $type _readbyte thebyte
            }
            lappend data $thebyte
            $type _readbyte thebyte
        }
        return $data
    }
    typemethod _sendBits {} {
        $type _readbyte thebyte;# Gobble ETX
        # -- read all inputs and assemble into bytes.
        # append one byte for each 8 input pins to result
        set result [list 0 0 0];# dummy 24 input bits
        $type _transmit $Read $result
    }
    typemethod _getandsetbits {bitlist} {
        # bitlist -- list of bytes.  Set output ports from this list 
        # (8 ports per 8-bit element)
    }
    typemethod _initializePorts {initmessage} {
        # initmessage -- init message
        # Card type
        set ct [lindex $initmessage 0]
        # Delay
        set dl [expr {([lindex $initmessage 1] << 8) | [lindex $initmessage 2]}]
        # Number of signals
        set ns [lindex $initmessage 3]
        set cards [lrange $initmessage 4 end]
        # Init the card (?)
    }
    typemethod _transmit {mt ob} {
        # Transmit bytes (ob)
        set tb [list 0x0ff 0x0ff $STX [expr {$AddressCode + $address}] $mt]
 	foreach obi $ob {
            if {$obi == $STX || $obi == $ETX || $obi == $DLE} {
                lappend tb $DLE
            }
            lappend tb $obi
	}
        lappend tb $ETX
        puts -nonewline $portchan [binary format c* $tb]
    }
    typevariable _timeout 0
    typemethod _readevent {} {
        incr _timeout -1
    }
    typemethod _readbyte {thebytevar} {
        #* Read a single byte from the serial interface.
        # Used by the _incoming typemethod.
        # Returns false on error and true on success.
        # @param thebytevar A name of a variable to put the byte read.
        #   Undefined if there was an error.
        #
        
        upvar $thebytevar thebyte
        foreach {in out} [fconfigure $portchan -queue] {break}
        #puts stderr "*** $type _readbyte (at start): in = $in"
        for {set i 0} {$i < 10000} {incr i} {
            if {$in > 0} {
                set therawbyte [read $portchan 1]
                binary scan $therawbyte c thebyte
                set thebyte [expr {$thebyte & 0x0ff}]
                #puts stderr "*** $type _readbyte: read $thebyte"
                return true
            }
            set _timeout 0
            set aid [after 100 incr [myvar _timeout]]
            set savedfe [fileevent $portchan readable]
            fileevent $portchan readable [mymethod _readevent]
            vwait [mytypevar _timeout]
            fileevent $portchan readable $savedfe
            after cancel $aid
            foreach {in out} [fconfigure $portchan -queue] {break}
            #puts stderr "*** $type _readbyte: in = $in,  _timeout = $_timeout"
        }
        return false
    }
}
        
vwait forever
