#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Jun 6 11:01:16 2017
#  Last Modified : <170717.1300>
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


## @page OpenLCB_PiMCP23017_signal.tcl OpenLCB PiMCP23017 as signal driver node
# @brief OpenLCB PiMCP23017 as signal driver node
#
#
# @section PiMCP23017SIGSYNOPSIS SYNOPSIS
#
# OpenLCB_PiMCP23017_signal [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section PiMCP23017SIGDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for the GPIO pins
# provided by a MCP23017 I2C port expander on a Raspberry Pi.  This version 
# groups the pins as signal heads.  All pins are set as outputs.
#
# @section PiMCP23017SIGPARAMETERS PARAMETERS
#
# None
#
# @section PiMCP23017SIGOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_PiMCP23017_signal.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is pimcp23017signalconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section PiMCP23017SIGCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section PiMCP23017SIGAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_PiMCP23017_signal]


package require Tclwiringpi;#  require the Tclwiringpi package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::enum CommonMode -values {anode cathode}

snit::integer LEDCount -min 1 -max 8

snit::type GPIOPinNo {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
    typemethod validate {pinno} {
        if {$pinno < 0 || $pinno > 15} {
            error [_ "Not a GPIO pin number: %s" $pinno]
        } else {
            return $pinno
        }
    }
    typemethod AllPins {} {
        return [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]
    }
    typemethod gpioPinNo {pinno} {
        $type validate $pinno
        return [expr {64 + $pinno}]
    }
    typemethod mcp23017PinNo {gpiopinno} {
        set pin [expr {$gpiopinno - 64}]
        $type validate $pin
        return $pin
    }
}

snit::type Binary8 {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
        
    typemethod validate {value} {
        if {[regexp {^B[01]{8}$} $value] < 1} {
            error [_ "Not a Binary8 value: %s" $value]
        } else {
            return $value
        }
    }
    typemethod valueof {value} {
        if {[regexp {^B([01]{8})$} $value => bits] < 1} {
            error [_ "Not a Binary8 value: %s" $value]
        } else {
            set result 0
            foreach b [split $bits ""] {
                set result [expr {($result << 1) + $b}]
            }
            return $result
        }
    }
    typemethod convertto {byte} {
        set result B
        for {set i 7} {$i >= 0} {incr i -1} {
            append result [expr {($byte >> $i) & 1}]
        }
        return $result
    }
}
    
snit::type Aspect {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
        
    typemethod validate {value} {
        if {[llength $value] == 2} {
            lcc::EventID validate [lindex $value 0]
            Binary8 validate [lindex $value 1]
        } else {
            error [_ "Not a valid aspect: %s" $value]
        }
    }
}    
snit::listtype AspectList -minlen 1 -type Aspect

snit::integer MCP23017Addr -min 0 -max 7

snit::type OpenLCB_PiMCP23017_signal {
    #** This class implements a OpenLCB interface to the GPIO pins of a
    # MCP23017 I2C port expander on a Raspberry Pi, with the pins being used
    # as signal drivers.
    #
    # Each instance manages one pin.  The typemethods implement the overall
    # OpenLCB node.
    #
    # Instance options:
    # @arg -pinnumber The first pin number.
    # @arg -ledcount  The number of LEDs in the head/mast (note: bicolor LEDs
    # count as 2 each!).
    # @arg -common    The Common Mode (anode or cathode).
    # @arg -aspectlist The Aspects for this signal.
    # @arg -description Description of the signal.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  signallist {};#     Signal list
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  baseI2Caddress 0x20;# Base I2C address.
    typevariable  defaultI2CAddr 7;#  Default I2C address offset
    typevariable  I2CAddr 7;#         I2C address offset
    
    
    typecomponent editContextMenu
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages GPIO pins, consuming or producing
        # events.
        
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
        set conffile [from argv -configuration "pimcp23017signalconf.xml"]
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
        set transcons [$configuration getElementsByTagName "transport"]
        set constructor [$transcons getElementsByTagName "constructor"]
        if {$constructor eq {}} {
            ::log::logError [_ "Transport constructor missing!"]
            exit 97
        }
        set options [$transcons getElementsByTagName "options"]
        set transportOpts {}
        if {$options ne {}} {
            set transportOpts [$options data]
        } else {
            ::log::log debug "*** $type typeconstructor: no options."
        }
        
        set transportConstructors [info commands ::lcc::[$constructor data]]
        if {[llength $transportConstructors] > 0} {
            set transportConstructor [lindex $transportConstructors 0]
        }
        if {$transportConstructor eq {}} {
            ::log::logError [_ "No valid transport constructor found!"]
            exit 96
        }
        set nodename ""
        set nodedescriptor ""
        set ident [$configuration getElementsByTagName "identification"]
        if {[llength $ident] > 0} {
             set ident [lindex $ident 0]
             set nodenameele [$ident getElementsByTagName "name"]
             if {[llength $nodenameele] > 0} {
                 set nodename [[lindex $nodenameele 0] data]
             }
             set nodedescriptorele [$ident getElementsByTagName "description"]
             if {[llength $nodedescriptorele] > 0} {
                 set nodedescriptor [[lindex $nodedescriptorele 0] data]
             }
        }
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB PiMCP23017" \
                          -softwareversion "1.0" \
                          -nodename $nodename \
                          -nodedescription $nodedescriptor \
                          -additionalprotocols {EventExchange} \
                          ] \
                          $transportOpts} transport]} {
            ::log::logError [_ "Could not open OpenLCBNode: %s" $transport]
            exit 95
        }
        $transport SendVerifyNodeID
        set i2caddrele [$configuration getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] > 0} {
            set i2caddrele [lindex $i2caddrele 0]
            set I2CAddr [expr {[$i2caddrele data] & 0x07}]
        }
        # Connect to the MCP23017, with GPIO pins 64 through 79 (0 through 15
        # on the MCP23017).
        mcp23017Setup 64 [expr {$baseI2Caddress | $I2CAddr}]
        
        foreach signal [$configuration getElementsByTagName "signal"] {
            set signalcommand [list $type create %AUTO%]
            set pinno [$signal getElementsByTagName "number"]
            if {[llength $pinno] != 1} {
                ::log::logError [_ "Missing or multiple pin numbers"]
                exit 94
            }
            set thepin [$pinno data]
            GPIOPinNo validate $thepin
            lappend signalcommand -pinnumber $thepin
            set ledcount [$signal getElementsByTagName "ledcount"]
            if {[llength $ledcount] != 1} {
                ::log::logError [_ "Missing or multiple ledcount"]
                exit 93
            }
            set thecount [$ledcount data]
            LEDCount validate $thecount
            set lastpin [expr {$thepin + $thecount - 1}]
            GPIOPinNo validate $lastpin
            lappend signalcommand -ledcount $thecount
            set common [$signal getElementsByTagName "common"]
            if {[llength $common] == 1} {
                set thecommon [$common data]
                CommonMode validate $thecommon
                lappend signalcommand -common $thecommon
            }
            set description [$signal getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend pincommand -description [[lindex $description 0] data]
            }
            set aspectlist [list]
            foreach aspect [$signal getElementsByTagName "aspect"] {
                set evele [$aspect getElementsByTagName "eventid"]
                if {[llength $evele] != 1} {
                    error [_ "Missing or multiple aspect events"]
                }
                set ev [lcc::EventID create %AUTO% -eventidstring [[lindex $evele 0] data]]
                set aspectbitsele  [$aspect getElementsByTagName "bits"]
                if {[llength $aspectbitsele] != 1} {
                    error [_ "Missing or multiple aspect bits"]
                }
                set aspectbits [[lindex $aspectbitsele 0] data]
                Binary8 validate $aspectbits
                lappend aspectlist [list $ev $aspectbits]
                lappend eventsconsumed $ev
            }
            AspectList validate $aspectlist
            lappend signalcommand -aspectlist $aspectlist
            set signalobj [eval $signalcommand]
            lappend signallist $signalobj
        }
        if {[llength $signallist] == 0} {
            ::log::logError [_ "No signals specified!"]
            exit 92
        }
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod sendEvent {event} {
        #** Send an event, after first checking for local consumtion.
        #
        # @param event The event to process
        
        foreach c $consumers {
            $c consumeEvent $event
        }
        $transport ProduceEvent $event
    }
    
    typemethod _eventHandler {command eventid {validity {}}} {
        #* Event Exchange handler.  Handle Event Exchange messages.
        #
        # @param command The type of event operation.
        # @param eventid The eventid.
        # @param validity The validity of the event.
        
        switch $command {
            consumerrangeidentified {
            }
            consumeridentified {
            }
            producerrangeidentified {
            }
            produceridentified {
            }
            learnevents {
            }
            identifyconsumer {
                foreach ev $eventsconsumed {
                    if {[$eventid match $ev]} {
                        $transport ConsumerIdentified $ev unknown
                    }
                }
            }
            identifyproducer {
                foreach ev $eventsproduced {
                    if {[$eventid match $ev]} {
                        $transport ProducerIdentified $ev unknown
                    }
                }
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
                foreach ev $eventsproduced {
                    $transport ProducerIdentified $ev unknown
                }
            }
            report {
                foreach s $signallist {
                    ::log::log debug "*** $type _eventHandler: signal is [$s cget -pinnumber]"
                    ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $s consumeEvent $eventid
                    
                }
            }
        }
    }
    typemethod _messageHandler {message} {
        #** General message handler.
        #
        # @param message The OpenLCB message
        
        switch [format {0x%04X} [$message cget -mti]] {
            0x0490 -
            0x0488 {
                #* Verify Node ID
                $transport SendMyNodeVerifcation
            }
            0x0828 {
                #* Protocol Support Inquiry
                $transport SendMySupportedProtocols [$message cget -sourcenid]
            }
            0x0DE8 {
                #* Simple Node Information Request
                $transport SendMySimpleNodeInfo [$message cget -sourcenid]
            }
            default {
            }
        }
    }
    
    
    #*** Configuration GUI
    
    typecomponent main;# Main Frame.
    typecomponent scroll;# Scrolled Window.
    typecomponent editframe;# Scrollable Frame
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typevariable    mcp23017address 7;# The address of the MCP23017
    typecomponent   signalnotebook;# Signal Notebook
    typevariable    signalcount 0;# signal count
    typevariable    aspectcounts -array {}
    
    typevariable status {};# Status line
    typevariable conffilename {};# Configuration File Name
    
    #** Menu.
    typevariable _menu {
        "[_m {Menu|&File}]" {file:menu} {file} 0 {
            {command "[_m {Menu|File|&Save}]" {file:save} "[_ {Save}]" {Ctrl s} -command "[mytypemethod _save]"}
            {command "[_m {Menu|File|Save and Exit}]" {file:saveexit} "[_ {Save and exit}]" {} -command "[mytypemethod _saveexit]"}
            {command "[_m {Menu|File|&Exit}]" {file:exit} "[_ {Exit}]" {Ctrl q} -command "[mytypemethod _exit]"}
        } "[_m {Menu|&Edit}]" {edit} {edit} 0 {
            {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut} -state disabled}
            {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy} -state disabled}
            {command "[_m {Menu|Edit|&Paste}]" {edit:paste} "[_ {Paste selection from the paste buffer}]" {Ctrl c} -command {StdMenuBar EditPaste}}
            {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear} -state disabled}
            {command "[_m {Menu|Edit|&Delete}]" {edit:delete edit:havesel} "[_ {Delete selection}]" {Ctrl d}  -command {StdMenuBar EditClear} -state disabled}
            {separator}
            {command "[_m {Menu|Edit|Select All}]" {edit:selectall} "[_ {Select everything}]" {} -command {StdMenuBar EditSelectAll}}
            {command "[_m {Menu|Edit|De-select All}]" {edit:deselectall edit:havesel} "[_ {Select nothing}]" {} -command {StdMenuBar EditSelectNone} -state disabled}
        } "[_m {Menu|&Help}]" {help} {help} 0 {
            {command "[_m {Menu|Help|On &Help...}]" {help:help} "[_ {Help on help}]" {} -command {HTMLHelp help Help}}
            {command "[_m {Menu|Help|On &Version}]" {help:help} "[_ {Version}]" {} -command {HTMLHelp help Version}}
            {command "[_m {Menu|Help|Warranty}]" {help:help} "[_ {Warranty}]" {} -command {HTMLHelp help Warranty}}
            {command "[_m {Menu|Help|Copying}]" {help:help} "[_ {Copying}]" {} -command {HTMLHelp help Copying}}
            {command "[_m {Menu|Help|EventExchange node for Raspberry Pi GPIO pins}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for Raspberry Pi GPIO pins"}}
        }
    }
    
    typemethod edit_checksel {} {
        if {[catch {selection get}]} {
            $main setmenustate edit:havesel disabled
        } else {
            $main setmenustate edit:havesel normal
        }
    }
    # Default (empty) XML Configuration.
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_PiMCP23017_Signal/>}
    typemethod SampleConfiguration {conffile} {
        #** Generate a Sample Configuration
        #
        # @param conffile Name of the configuration file.
        #
        
        set conffilename $conffile
        set confXML $default_confXML
        if {[file exists $conffilename]} {
            puts -nonewline stdout [_ {Configuration file (%s) already exists. Replace it [yN]? } $conffilename]
            flush stdout
            set answer [string toupper [string index [gets stdin] 0]]
            if {$answer ne "Y"} {exit 1}
        }
        set configuration [ParseXML create %AUTO% $confXML]
        set cdis [$configuration getElementsByTagName OpenLCB_PiMCP23017_Signal -depth 1]
        set cdi [lindex $cdis 0]
        set transcons [SimpleDOMElement %AUTO% -tag "transport"]
        $cdi addchild $transcons
        set constructor [SimpleDOMElement %AUTO% -tag "constructor"]
        $transcons addchild $constructor
        $constructor setdata "CANGridConnectOverTcp"
        set transportopts [SimpleDOMElement %AUTO% -tag "options"]
        $transcons addchild $transportopts
        $transportopts setdata {-port 12021 -nid 05:01:01:01:22:00 -host localhost}
        set ident [SimpleDOMElement %AUTO% -tag "identification"]
        $cdi addchild $ident
        set nameele [SimpleDOMElement %AUTO% -tag "name"]
        $ident addchild $nameele
        $nameele setdata "Sample Name"
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $ident addchild $descrele
        $descrele setdata "Sample Description"
        set eid 0
        set i2caddrele [SimpleDOMElement %AUTO% -tag "i2caddress"]
        $cdi addchild $i2caddrele
        $pollele setdata 7
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $signal addchild $descrele
        $descrele setdata "Sample Signal"
        set signalno [SimpleDOMElement %AUTO% -tag "number"]
        $signal addchild $signalno
        $signalno setdata 0
        set ledcount [SimpleDOMElement %AUTO% -tag "ledcount"]
        $signal addchild $ledcount
        $ledcount setdata 3
        set  common [SimpleDOMElement %AUTO% -tag "common"]
        $signal addchild $common
        $common setdata "cathode"
        set eid 0
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"]
        $aspect addchild $aspectbits
        $aspectbits setdata B00100001;# green over red
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00010001;# yellow over red 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001001;# red over red 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001010;# red over yellow 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001100;# red over green 
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
        }
        ::exit
    }
    typemethod ConfiguratorGUI {conffile} {

        #** Configuration GUI
        # 
        # Create the Configuration tool GUI.
        #
        # @param conffile Name of the configuration file.
        
        package require Tk
        package require tile
        package require ParseXML
        package require LabelFrames
        package require ScrollableFrame
        package require ScrollWindow
        package require MainFrame
        package require snitStdMenuBar
        package require ButtonBox
        package require ScrollTabNotebook
        package require HTMLHelp 2.0
        
        set HelpDir [file join [file dirname [file dirname [file dirname \
                                                            [info script]]]] Help]
        HTMLHelp setDefaults "$HelpDir" "index.html#toc"
        
        set editContextMenu [StdEditContextMenu .editContextMenu]
        $editContextMenu bind Entry
        $editContextMenu bind TEntry
        $editContextMenu bind Text
        $editContextMenu bind ROText
        $editContextMenu bind Spinbox
        
        set conffilename $conffile
        set confXML $default_confXML
        if {![catch {open $conffile r} conffp]} {
            set confXML [read $conffp]
            close $conffp
        }
        if {[catch {ParseXML create %AUTO% $confXML} configuration]} {
            set confXML $default_confXML
            set configuration [ParseXML create %AUTO% $confXML]
        }
        set cdis [$configuration getElementsByTagName OpenLCB_PiMCP23017_Signal -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_PiMCP23017_Signal container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_PiMCP23017_signal Configuration Editor (%s)" $conffile]
        set main [MainFrame .main -menu [subst $_menu] \
                  -textvariable [mytypevar status]]
        pack $main -expand yes -fill both
        [$main getmenu edit] configure -postcommand [mytypemethod edit_checksel]
        set f [$main getframe]
        set scroll [ScrolledWindow $f.scroll -scrollbar vertical \
                    -auto vertical]
        pack $scroll -expand yes -fill both
        set editframe [ScrollableFrame \
                       [$scroll getframe].editframe -constrainedwidth yes]
        $scroll setwidget $editframe
        set frame [$editframe getframe]
        set transconsframe [ttk::labelframe $frame.transportconstuctor \
                            -labelanchor nw -text [_m "Label|Transport"]]
        pack $transconsframe -fill x -expand yes
        set transconstructor [LabelFrame $transconsframe.transconstructor \
                              -text [_m "Label|Constructor"]]
        pack $transconstructor -fill x -expand yes
        set cframe [$transconstructor getframe]
        set transcname [ttk::entry $cframe.transcname \
                        -state readonly \
                        -textvariable [mytypevar transconstructorname]]
        pack $transcname -side left -fill x -expand yes
        set transcnamesel [ttk::button $cframe.transcnamesel \
                           -text [_m "Label|Select"] \
                           -command [mytypemethod _seltransc]]
        pack $transcnamesel -side right
        set transoptsframe [LabelFrame $transconsframe.transoptsframe \
                              -text [_m "Label|Constructor Opts"]]
        pack $transoptsframe -fill x -expand yes
        set oframe [$transoptsframe getframe]
        set transoptsentry [ttk::entry $oframe.transoptsentry \
                        -state readonly \
                        -textvariable [mytypevar transopts]]
        pack $transoptsentry -side left -fill x -expand yes
        set tranoptssel [ttk::button $oframe.tranoptssel \
                         -text [_m "Label|Select"] \
                         -command [mytypemethod _seltransopt]]
        pack $tranoptssel -side right
        
        set transcons [$cdi getElementsByTagName "transport"]
        if {[llength $transcons] == 1} {
            set constructor [$transcons getElementsByTagName "constructor"]
            if {[llength $constructor] == 1} {
                set transconstructorname [$constructor data]
            }
            set coptions [$transcons getElementsByTagName "options"]
            if {[llength $coptions] == 1} {
                set transopts [$coptions data]
            }
        }
        set identificationframe [ttk::labelframe $frame.identificationframe \
                            -labelanchor nw -text [_m "Label|Identification"]]
        pack $identificationframe -fill x -expand yes
        set identificationname [LabelFrame $identificationframe.identificationname \
                                -text [_m "Label|Name"]]
        pack $identificationname -fill x -expand yes
        set nframe [$identificationname getframe]
        set idname [ttk::entry $nframe.idname \
                        -textvariable [mytypevar id_name]]
        pack $idname -side left -fill x -expand yes
        set identificationdescrframe [LabelFrame $identificationframe.identificationdescrframe \
                              -text [_m "Label|Description"]]
        pack $identificationdescrframe -fill x -expand yes
        set dframe [$identificationdescrframe getframe]
        set identificationdescrentry [ttk::entry $dframe.identificationdescrentry \
                        -textvariable [mytypevar id_description]]
        pack $identificationdescrentry -side left -fill x -expand yes
        set ident [$cdi getElementsByTagName "identification"]
        if {[llength $ident] == 1} {
            set nameele [$ident getElementsByTagName "name"]
            if {[llength $nameele] == 1} {
                set id_name [$nameele data]
            }
            set descrele [$ident getElementsByTagName "description"]
            if {[llength $descrele] == 1} {
                set id_description [$descrele data]
            }
        }
        
        set i2caddressLE [LabelSpinBox $frame.i2caddressLE \
                            -label [_m "Label|I2C Address offset"] \
                            -textvariable [mytypevar mcp23017address] \
                            -range {0 7 1}]
        pack $i2caddressLE -fill x -expand yes
        set i2caddrele [$cdi getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] > 0} {
            set i2caddrele [lindex $i2caddrele 0]
            set mcp23017address [$i2caddrele data]
        }
        set signalnotebook [ScrollTabNotebook $frame.signals]
        pack $signalnotebook -expand yes -fill both
        foreach signal [$cdi getElementsByTagName "signal"] {
            $type _create_and_populate_signal $signal
        }
        set addsignal [ttk::button $frame.addsignal \
                    -text [_m "Label|Add another signal"] \
                    -command [mytypemethod _addblanksignal]]
        pack $addsignal -fill x
    }
    typevariable warnings
    typemethod _saveexit {} {
        #** Save and Exit.  Bound to the Save and Exit file menu item
        # Saves the contents of the GUI as an XML file and then exits.
        
        if {[$type _save]} {
            $type _exit
        }
    }
    typemethod _save {} {
        #** Save.  Bound to the Save file menu item.
        # Saves the contents of the GUI as an XML file.
        
        set warnings 0
        set cdis [$configuration getElementsByTagName OpenLCB_PiMCP23017_Signal -depth 1]
        set cdi [lindex $cdis 0]
        set transcons [$cdi getElementsByTagName "transport"]
        if {[llength $transcons] < 1} {
            set transcons [SimpleDOMElement %AUTO% -tag "transport"]
            $cdi addchild $transcons
        }
        set constructor [$transcons getElementsByTagName "constructor"]
        if {[llength $constructor] < 1} {
            set constructor [SimpleDOMElement %AUTO% -tag "constructor"]
            $transcons addchild $constructor
        }
        $constructor setdata $transconstructorname
        set coptions [$transcons getElementsByTagName "options"]
        if {[llength $coptions] < 1} {
            set coptions [SimpleDOMElement %AUTO% -tag "options"]
            $transcons addchild $coptions
        }
        $coptions setdata $transopts
        
        set ident [$cdi getElementsByTagName "identification"]
        if {[llength $ident] < 1} {
            set ident [SimpleDOMElement %AUTO% -tag "identification"]
            $cdi addchild $ident
        }
        set nameele [$ident getElementsByTagName "name"]
        if {[llength $nameele] < 1} {
            set nameele [SimpleDOMElement %AUTO% -tag "name"]
            $ident addchild $nameele
        }
        $nameele setdata $id_name 
        set descrele [$ident getElementsByTagName "description"]
        if {[llength $descrele] < 1} {
            set descrele [SimpleDOMElement %AUTO% -tag "description"]
            $ident addchild $descrele
        }
        $descrele setdata $id_description
        set i2caddrele [$configuration getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] < 1} {
            set i2caddrele [SimpleDOMElement %AUTO% -tag "i2caddress"]
            $cdi addchild $i2caddrele
        }
        $i2caddrele setdata $mcp23017address
        
        foreach signal [$cdi getElementsByTagName "signal"] {
            $type _copy_signal_from_gui_to_XML $signal
        }
        
        if {$warnings > 0} {
            tk_messageBox -type ok -icon info \
                  -message [_ "There were %d warnings.  Please correct and try again." $warnings]
            return no
        }
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
        }
        return yes
    }
    typemethod _copy_signal_from_gui_to_XML {signal} {
        #** Copy from the GUI to the Signal XML
        #
        # @param signal Signal XML element.
        
        set fr [$signal attribute frame]
        set frbase $signalnotebook.$fr
        set pinno [$signal getElementsByTagName "number"]
        if {[llength $pinno] < 1} {
            set pinno [SimpleDOMElement %AUTO% -tag "number"]
            $signal addchild $pinno
        }
        $pinno setdata [$frbase.pinno get]
        set ledcount [$signal getElementsByTagName "ledcount"]
        if {[llength $ledcount] < 1} {
            set ledcount [SimpleDOMElement %AUTO% -tag "ledcount"]
            $signal addchild $ledcount
        }
        set count [$frbase.ledcount get]
        set lastpin [expr {[$pinno data] + $count - 1}]
        if {[catch {GPIOPinNo validate $lastpin}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "LED Count exceeds the remaining available pins: %d (%d-%d)" $count [$pinno data] $lastpin]
            incr warnings
            set lastpin 15
            set count [expr {$lastpin - [$pinno data] + 1}]
        }
        $ledcount setdata $count
        set common [$signal getElementsByTagName "common"]
        if {[llength $common] < 1} {
            set common [SimpleDOMElement %AUTO% -tag "common"]
            $signal addchild $common
        }
        $common setdata [$frbase.common get]
        set description_ [$frbase.description get]
        if {$description_ eq ""} {
            set description [$signal getElementsByTagName "description"]
            if {[llength $description] == 1} {
                $signal removeChild $description
            }
        } else {
            set description [$signal getElementsByTagName "description"]
            if {[llength $description] < 1} {
                set description [SimpleDOMElement %AUTO% -tag "description"]
                $signal addchild $description
            }
            $description setdata $description_
        }
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _copy_aspect_from_gui_to_XML $signal $aspect
        }
    }
    typemethod _copy_aspect_from_gui_to_XML {signal aspect} {
        #** Copy from the GUI to the Signal's aspect XML
        #
        # @param signal Signal XML element.
        # @param aspect Aspect XML element.
        
        set fr [$signal attribute frame]
        set frbase $signalnotebook.$fr
        set afr [$aspect attribute frame]
        set afrbase $frbase.aspectNB.$afr
        set evstring [$afrbase.eventidLE get]
        set aspbits  [$afrbase.aspbitsLE get]
        if {[catch {Binary8 validate $aspbits}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Illformed Aspect bits: %s!" $aspbits]
            incr warnings
            set aspectbitsele [$aspect getElementsByTagName "bits"]
            if {[llength $aspectbitsele] > 0} {
                $aspect removeChild $aspectbitsele
            }
        } else {
            set aspectbitsele [$aspect getElementsByTagName "bits"]
            if {[llength $aspectbitsele] < 1} {
                set aspectbitsele [SimpleDOMElement %AUTO% -tag "bits"]
                $aspect addchild $aspectbitsele
            }
            $aspectbitsele setdata $aspbits
        }
        if {[catch {lcc::eventidstring validate $evstring}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Event ID for aspect %s is not a valid event id string: %s!" $aspbits $evstring]
            incr warnings
            set eventidele [$aspect getElementsByTagName "eventid"]
            if {[llength $eventidele] > 0} {
                $aspect removeChild $eventidele
            }
        } else {
            set eventidele [$aspect getElementsByTagName "eventid"]
            if {[llength $eventidele] < 1} {
                set eventidele [SimpleDOMElement %AUTO% -tag "eventid"]
                $aspect addchild $eventidele
            }
            $eventidele setdata $evstring
        }
    }
    typemethod _exit {} {
        #** Exit function.  Bound to the Exit file menu item.
        # Does not save the configuration data!
        
        ::exit
    }
    typemethod _seltransc {} {
        #** Select a transport constructor.
        
        set result [lcc::OpenLCBNode selectTransportConstructor]
        if {$result ne {}} {
            if {$result ne $transconstructorname} {set transopts {}}
            set transconstructorname [namespace tail $result]
        }
    }
    typemethod _seltransopt {} {
        #** Select transport constructor options.
        
        if {$transconstructorname ne ""} {
            set transportConstructors [info commands ::lcc::$transconstructorname]
            ::log::log debug "*** $type typeconstructor: transportConstructors is $transportConstructors"
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
            if {$transportConstructor ne {}} {
                set optsdialog [list $transportConstructor \
                                drawOptionsDialog]
                foreach x $transopts {lappend optsdialog $x}
                set transportOpts [eval $optsdialog]
                if {$transportOpts ne {}} {
                    set transopts $transportOpts
                }
            }
        }
    }
    typemethod _create_and_populate_signal {signal} {
        #** Create a tab for a  signal and populate it.
        #
        # @param signal The signal XML element.
        
        incr signalcount
        set fr signal$signalcount
        set f [$signal attribute frame]
        if {$f eq {}} {
            set attrs [$signal cget -attributes]
            lappend attrs frame $fr
            $signal configure -attributes $attrs
        } else {
            set attrs [$signal cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $signal configure -attributes $attrs
        }
        set signalframe [ttk::frame \
                      $signalnotebook.$fr]
        $signalnotebook add $signalframe \
              -text [_ "Signal %d" $signalcount] -sticky news
        set pinno_ [LabelSpinBox $signalframe.pinno \
                    -label [_m "Label|Start Pin Number"] \
                    -range {0 15 1}]
        $pinno_ set 0
        pack $pinno_ -fill x -expand yes
        set pinno [$signal getElementsByTagName "number"]
        if {[llength $pinno] == 1} {
            $pinno_ set [$pinno data]
        }
        set ledcount_ [LabelSpinBox $signalframe.ledcount \
                       -label [_m "Label|LED Count"] \
                       -range {1 8 1}]
        $ledcount_ set 1
        pack $ledcount_ -fill x -expand yes
        set ledcount [$signal getElementsByTagName "ledcount"]
        if {[llength $ledcount] == 1} {
            $ledcount_ set [$ledcount data]
        }
        set common_ [LabelComboBox $signalframe.common \
                     -label [_m "Label|Common"] \
                     -values [CommonMode cget -values] \
                     -editable no]
        $common_ set cathode
        pack $common_ -fill x -expand ye
        set common [$signal getElementsByTagName "common"]
        if {[llength $common] == 1} {
            $common_ set [$common data]
        }
        set description_ [LabelEntry $signalframe.description \
                          -label [_m "Label|Description"]]
        pack $description_ -fill x -expand yes
        set description [$signal getElementsByTagName "description"]
        if {[llength $description] == 1} {
            $description_ configure -text [$description data]
        }
        # aspects...  
        set aspectNB [ScrollTabNotebook $signalframe.aspectNB]
        pack $aspectNB -fill both -expand yes
        if {![info exists aspectcounts($fr)]} {
            set aspectcounts($fr) 0
        }
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _create_and_populate_signal_aspect $signal $aspect
        }
        set addaspect [ttk::button $signalframe.addaspect \
                       -text [_m "Label|Add another aspect"] \
                       -command [mytypemethod _addaspect $signal]]
        pack $addaspect -fill x
        set delsignal [ttk::button $signalframe.deletesignal \
                       -text [_m "Label|Delete signal"] \
                       -command [mytypemethod _deleteSignal $signal]]
        pack $delsignal -fill x
    }
    typemethod _create_and_populate_signal_aspect {signal aspect} {
        #** Create and populate a signal aspect instance.
        #
        # @param signal Signal XML element.
        # @param aspect Aspect XML element.
        
        #puts stderr "$type _create_and_populate_signal_aspect $signal $aspect"
        set fr [$signal attribute frame]
        set frbase $signalnotebook.$fr
        incr aspectcounts($fr)
        set afr aspect$aspectcounts($fr)
        set af [$aspect attribute frame]
        #puts stderr "$type _create_and_populate_signal_aspect: fr = $fr, frbase = $frbase, afr = $afr, af = $af"        
        if {$af eq {}} {
            set attrs [$aspect cget -attributes]
            lappend attrs frame $afr
            $aspect configure -attributes $attrs
        } else {
            set attrs [$aspect cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $afr]
            $aspect configure -attributes $attrs
        }
        set aspectframe [ttk::frame \
                         $frbase.aspectNB.$afr]
        #puts stderr "$type _create_and_populate_signal_aspect: aspectframe = $aspectframe"
        $frbase.aspectNB add $aspectframe \
              -text [_ "Aspect %d" $aspectcounts($fr)] -sticky news
        set afrbase $aspectframe
        #puts stderr "$type _create_and_populate_signal_aspect: afrbase = $afrbase"
        set eventidLE [LabelEntry $afrbase.eventidLE \
                   -label [_m "Label|Event ID"]]
        pack $eventidLE -fill x -expand yes
        set eventidele [$aspect getElementsByTagName "eventid"]
        if {[llength $eventidele] < 1} {
            $eventidLE configure -text "00.00.00.00.00.00.00.00"
        } else {
            $eventidLE configure -text [[lindex $eventidele 0] data]
        }
        set aspbitsLE [LabelEntry $afrbase.aspbitsLE \
                       -label [_m "Label|Aspect Bits"]]
        pack $aspbitsLE -fill x -expand yes
        set aspectbitsele [$aspect getElementsByTagName "bits"]
        if {[llength $aspectbitsele] < 1} {
            $aspbitsLE configure -text [Binary8 convertto 0]
        } else {
            $aspbitsLE configure -text [[lindex $aspectbitsele 0] data]
        }
        set delaspect [ttk::button $afrbase.deleteaspect \
                       -text [_m "Label|Delete aspect"] \
                       -command [mytypemethod _deleteAspect $signal $aspect]]
        pack $delaspect -fill x
    }
    typemethod _addblanksignal {} {
        #** Create a new blank signal.
        
        set cdis [$configuration getElementsByTagName OpenLCB_PiMCP23017_Signal -depth 1]
        set cdi [lindex $cdis 0]
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        $type _create_and_populate_signal $signal
    }
    typemethod _deleteSignal {signal} {
        #** Delete a signal
        #
        # @param signal The signal's XML element.
        
        set fr [$signal attribute frame]
        set cdis [$configuration getElementsByTagName OpenLCB_PiMCP23017_Signal -depth 1]
        set cdi [lindex $cdis 0]
        $type _deleteallaspects $signal
        $cdi removeChild $signal
        $signalnotebook forget $signalnotebook.$fr
        destroy $signalnotebook.$fr
    }
    typemethod _deleteallaspects {signal} {
        #** Delete all aspects of a signal
        #
        # @param signal The signal whose aspects are to be removed.
        
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _deleteAspect $signal $aspect
        }
    }
    typemethod _addaspect {signal} {
        #** Add an aspect to a signal.
        #
        # @param signal The signal's XML element.
        
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        $type _create_and_populate_signal_aspect $signal $aspect
    }
    typemethod _deleteAspect {signal aspect} {
        #** Delete a signal's aspect
        #
        # @param signal The signal's XML element.
        # @param aspect The aspects's XML element.
        
        #puts stderr "*** type _deleteAspect $signal $aspect"
        set fr [$signal attribute frame]
        #puts stderr "*** type _deleteAspect: fr = $fr"
        set frbase $signalnotebook.$fr
        #puts stderr "*** type _deleteAspect: frbase = $frbase"
        set afr [$aspect attribute frame]
        #puts stderr "*** type _deleteAspect: afr = $afr"
        set afrbase $frbase.aspectNB.$afr
        #puts stderr "*** type _deleteAspect: afrbase = $afrbase"
        $frbase.aspectNB forget $afrbase
        $signal removeChild $aspect
        destroy $afrbase
    }
    
    
    
    #*** Signal instances
    option -pinnumber -readonly yes -type GPIOPinNo -default 0
    option -ledcount -readonly yes -type LEDCount -default 1
    option -common   -readonly yes -type CommonMode -default cathode
    option -aspectlist -readonly yes -type AspectList \
          -default {{11.22.33.44.55.66.77.88 B00000000}}
    option -description -readonly yes -default {}
    constructor {args} {
        # Construct an instance for a GPIO pin
        #
        # @param ... Options:
        # @arg -pinnumber The pin number
        # @arg -ledcount  The number of LEDs in the head/mast (note: bicolor LEDs
        # count as 2 each!).
        # @arg -common    The Common Mode (anode or cathode).
        # @arg -aspectlist The Aspects for this signal.
        # @arg -description Description of the pin.
        # @par
        
        $self configurelist $args
        set gpiopinno [GPIOPinNo gpioPinNo [$self cget -pinnumber]]
        for {set i 0} {$i < [$self cget -ledcount]} {incr i} {
            set pin [expr {$gpiopinno + $i}]
            pinMode $pin $::OUTPUT
            switch [$self cget -common] {
                anode {
                    digitalWrite $pin $::HIGH
                }
                cathode {
                    digitalWrite $pin $::LOW
                }
            }
        }
    }
    method consumeEvent {event} {
        #** Handle an incoming event.
        #
        # @param event The event to handle.
        
        ::log::log debug "*** $self consumeEvent $event"
        foreach aspevbits [$self cget -aspectlist] {
            foreach {aspev bits} $aspevbits {break}
            if {[$event match $aspev]} {
                set byte [Binary8 valueof $bits]
                set gpiopinno [GPIOPinNo gpioPinNo [$self cget -pinnumber]]
                for {set i 0} {$i < [$self cget -ledcount]} {incr i} {
                    set pin [expr {$gpiopinno + $i}]
                    set pvalue [expr {($byte >> $i) & 0x01}]
                    ::log::log debug "*** $self consumeEvent: pvalue = $pvalue, pin = $pin"
                    if {$pvalue == 1} {
                        switch [$self cget -common] {
                            anode {
                                digitalWrite $pin $::LOW
                            }
                            cathode {
                                digitalWrite $pin $::HIGH
                            }
                        }
                    } else {
                        switch [$self cget -common] {
                            anode {
                                digitalWrite $pin $::HIGH
                            }
                            cathode {
                                digitalWrite $pin $::LOW
                            }
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}

vwait forever


