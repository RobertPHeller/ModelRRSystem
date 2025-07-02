#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Nov 30 10:02:35 2017
#  Last Modified : <171204.1203>
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


## @page OpenLCB_QuadSignal OpenLCB program for the MCP23017-based quad signal head HAT
# @brief OpenLCB OpenLCB for the MCP23017-based quad signal head HAT
#                                                                               
#                                                                               
# @section QuadSignalSYNOPSIS SYNOPSIS
#
# OpenLCB_QuadSignal  [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section QuadSignalDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for the 
# MCP23017-based quad signal head HAT for the Raspberry Pi. Each signal mast 
# can have 1, 2, or 3 "heads".  Each head has four "lamps" (unused lamps can 
# be set to "None"). For a given aspect, a lamp can be on, off, blink, or 
# reverse blink.
#
# @section QuadSignalPARAMETERS PARAMETERS
#
# None
#
# @section QuadSignalOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_QuadSignal.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is quadsignalconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section QuadSignalCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section QuadSignalAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_QuadSignal]

package require Tclwiringpi;#  require the Tclwiringpi package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common config code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::enum CommonMode -values {anode cathode}

snit::type LampID {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
    typevariable LampMap -array {
        H1-G 3
        H1-Y 2
        H1-R 1
        H1-L 0
        H2-G 7
        H2-Y 6
        H2-R 5
        H2-L 4
        H3-G 11
        H3-Y 10
        H3-R 9
        H3-L 8
        H4-G 15
        H4-Y 14
        H4-R 13
        H4-L 12
    }
    typemethod validate {lampid} {
        if {[string toupper $lampid] in [array names LampMap]} {
            return $lampid
        } elseif {[string toupper $lampid] eq "NONE"} {
            return $lampid
        } else {
            error [_ "Not a LampID: %s" $lampid]
        }
    }
    typemethod AllLampIDs {} {
        return [lsort [array names LampMap]]
    }
    typemethod gpioPinNo {lampid} {
        $type validate $lampid
        if {[string toupper $lampid] eq "NONE"} {
            return -1
        } else {
            return [expr {64 + $LampMap([string toupper $lampid])}]
        }
    }
}

snit::enum Effect -values {off on blink reverseblink}

snit::type OneLamp {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
    typemethod validate {value} {
        if {[llength $value] == 2} {
            LampID validate [lindex $value 0]
            Effect validate [lindex $value 1]
        } else {
            error [_ "Not a valid OneLamp: %s" $value]
        }
    }
}

snit::listtype Head -minlen 4 -maxlen 4 -type OneLamp

snit::listtype HeadList -minlen 1 -maxlen 3 -type Head

snit::type Aspect {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
    typemethod validate {value} {
        #puts stderr "*** Aspect validate $value"
        if {[llength $value] == 3} {
            #puts stderr "*** Aspect validate: value element 0 is [lindex $value 0]"
            lcc::EventID validate [lindex $value 0]
            #puts stderr "*** Aspect validate: value element 1 is [lindex $value 1]"
            #puts stderr "*** Aspect validate: value element 2 is [lindex $value 2]"
            set heads [lindex $value 2]
            HeadList validate $heads
        } else {
            error [_ "Not a valid Aspect: %s" $value]
        }
    }
}

snit::listtype AspectList -minlen 0 -type Aspect

snit::integer MCP23017Addr -min 0 -max 7

snit::type OpenLCB_QuadSignal {
    #** This class implements a OpenLCB interface to the QuadSignalDriver HAT
    # boards.  These HAT boards use a MCP23017 I2C port expander to drive upto
    # 16 LED signal lamps, aranged as 4 sets of 4, each set of 4 is a "head".
    #
    # Each instance manages one "mast".  Each mast has 1 to 4 heads. The 
    # typemethods implement the overall OpenLCB node.
    #
    # Instance options:
    # @arg -description The description of the signal mast.  This is any human
    #                   readable text.  (It could be the signal name or the
    #                   mast identification, etc.)
    # @arg -aspectlist The Aspects for this signal.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  mastlist {};#       Mast list
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  baseI2Caddress 0x20;# Base I2C address.
    typevariable  defaultI2CAddr 7;#  Default I2C address offset
    typevariable  I2CAddr 7;#         I2C address offset
    typecomponent xmlmastconfig;#     Common Mast config object
    typevariable  blinkstate 0;#      Global Current blink state
    typevariable  ON {};#             LED On value (set by common mode)
    typevariable  OFF {};#            LED Off value (set by common mode)
    
    typecomponent editContextMenu
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
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
        set conffile [from argv -configuration "quadsignalconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmlmastconfig [XmlConfiguration create %AUTO% {
                             <configure>
                             <string option="-description" 
                                     tagname="description">Description</string>
                             <group option="-aspectlist" tagname="aspect" 
                                    repname="Aspect" mincount="0" 
                                    maxcount="unlimited">
                               <eventid tagname="eventid">Event ID</eventid>
                               <string tagname="name">Name</string>
                               <group tagname="head" repname="Head" 
                                      mincount="1" maxcount="unlimited">
                                 <group tagname="lamp" repname="Lamp"
                                        mincount="4" maxcount="4">
                                   <enum tagname="id" enums="None H1-G H1-Y H1-R H1-L H2-G H2-Y H2-R H2-L H3-G H3-Y H3-R H3-L H4-G H4-Y H4-R H4-L" default="None">Lamp ID</enum>
                                   <enum tagname="effect" enums="off on blink reverseblink" default="off">Effect</enum>
                                 </group>
                               </group>
                             </group>
                             </configure>}]
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
        
        getTransport [$configuration getElementsByTagName "transport"] \
              transportConstructor transportOpts
        
        set nodename ""
        set nodedescriptor ""
        getIdentification [$configuration getElementsByTagName "identification"] nodename nodedescriptor
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB Quad Head" \
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
        
        set commonmode [$configuration getElementsByTagName "commonmode"]
        ::log::log debug "*** $type typeconstructor: commonmode is $commonmode"
        if {[llength $commonmode] > 0} {
            set commonmode [[lindex $commonmode 0] data]
            ::log::log debug "*** $type typeconstructor: commonmode is $commonmode" 
            switch [string tolower $commonmode] {
                anode {
                    set ON $::HIGH
                    set OFF $::LOW
                }
                cathode {
                    set ON $::LOW
                    set OFF $::HIGH
                }
            }
        } else {
            set ON $::HIGH
            set OFF $::LOW
        }
        ::log::log debug "*** $type typeconstructor: ON is $ON, OFF is $OFF"
        for {set i 0} {$i < 16} {incr i} {
            pinMode [expr {$i + 64}] $::OUTPUT
            pullUpDnControl [expr {$i + 64}] $::PUD_UP
            digitalWrite [expr {$i + 64}] $OFF
        }
        
        
        foreach mast [$configuration getElementsByTagName "mast"] {
            set mastcommand [$xmlmastconfig processConfig $mast [list $type create %AUTO%]]
            set mastobj [eval $mastcommand]
            lappend mastlist $mastobj
        }
        if {[llength $mastlist] == 0} {
            ::log::logError [_ "No masts specified!"]
            exit 92
        }
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
        after 1000 [mytypemethod _ticktock]
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod _ticktock {} {
        set blinkstate [expr {~$blinkstate}]
        foreach mast $mastlist {
            $mast doblink
        }
        after 1000 [mytypemethod _ticktock]
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
                #foreach ev $eventsproduced {
                #    if {[$eventid match $ev]} {
                #        $transport ProducerIdentified $ev unknown
                #    }
                #}
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
                #foreach ev $eventsproduced {
                #    $transport ProducerIdentified $ev unknown
                #}
            }
            report {
                foreach m $mastlist {
                    ::log::log debug "*** $type _eventHandler: mast is [$m cget -description]"
                    ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $m consumeEvent $eventid
                    
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
    typevariable    mcp23017address 7;# The address of the MCP23017
    typevariable    thecommonmode anode
    typecomponent   mastnotebook;# Mast Notebook
    typecomponent   generateEventID
    
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_QuadSignal/>}
    typemethod SampleConfiguration {conffile} {
        #** Generate a Sample Configuration
        #
        # @param conffile Name of the configuration file.
        #
        
        package require GenerateEventID 1.0
        set conffilename $conffile
        set confXML $default_confXML
        if {[file exists $conffilename]} {
            puts -nonewline stdout [_ {Configuration file (%s) already exists. Replace it [yN]? } $conffilename]
            flush stdout
            set answer [string toupper [string index [gets stdin] 0]]
            if {$answer ne "Y"} {exit 1}
        }
        set configuration [ParseXML create %AUTO% $confXML]
        set cdis [$configuration getElementsByTagName OpenLCB_QuadSignal -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set i2caddrele [SimpleDOMElement %AUTO% -tag "i2caddress"]
        $cdi addchild $i2caddrele
        $i2caddrele setdata 7
        set comm [SimpleDOMElement %AUTO% -tag "commonmode"]
        $cdi addchild $comm
        $comm setdata anode
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set mast [SimpleDOMElement %AUTO% -tag "mast"]
        $cdi addchild $mast
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $mast addchild $descrele
        $descrele setdata "Sample Signal Mast"
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $mast addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID currentid]
        set aspectname [SimpleDOMElement %AUTO% -tag "name"]
        $aspect addchild $aspectname
        $aspectname setdata "Stop"
        set head [SimpleDOMElement %AUTO% -tag "head"]
        $aspect addchild $head
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata H1-R
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata on
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $mast addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID currentid]
        set aspectname [SimpleDOMElement %AUTO% -tag "name"]
        $aspect addchild $aspectname
        $aspectname setdata "Apprach"
        set head [SimpleDOMElement %AUTO% -tag "head"]
        $aspect addchild $head
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata H1-Y
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata on
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $mast addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID currentid]
        set aspectname [SimpleDOMElement %AUTO% -tag "name"]
        $aspect addchild $aspectname
        $aspectname setdata "Clear"
        set head [SimpleDOMElement %AUTO% -tag "head"]
        $aspect addchild $head
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata H1-G
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata on
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set lamp [SimpleDOMElement %AUTO% -tag "lamp"]
        $head addchild $lamp
        set id [SimpleDOMElement %AUTO% -tag "id"]
        $lamp addchild $id
        $id setdata None
        set effect [SimpleDOMElement %AUTO% -tag "effect"]
        $lamp addchild $effect
        $effect setdata off
        set attrs [$cdi cget -attributes]
        lappend attrs lastevid [$generateEventID currentid]
        $cdi configure -attributes $attrs
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
            close $conffp
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
        package require GenerateEventID 1.0
        
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
        set cdis [$configuration getElementsByTagName OpenLCB_QuadSignal -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_QuadSignal container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_QuadSignal Configuration Editor (%s)" $conffile]
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
        TransportGUI $frame $cdi
        set lastevid [$cdi attribute lastevid]
        if {$lastevid eq {}} {
            set nidindex [lsearch -exact $transopts -nid]
            if {$nidindex >= 0} {
                incr nidindex
                set nid [lindex $transopts $nidindex]
            } else {
                set nid "05:01:01:01:22:00"
            }
            set evlist [list]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $nid] 1 end] {
                lappend evlist [scan $oct %02x]
            }
            lappend evlist 0 0
            set generateEventID [GenerateEventID create %AUTO% \
                                 -baseeventid [lcc::EventID create %AUTO% -eventidlist $evlist]]
        } else {
            set generateEventID [GenerateEventID create %AUTO% \
                                 -baseeventid [lcc::EventID create %AUTO% -eventidstring $lastevid]]
        }
        $xmlmastconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
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
        set commonmodeLE [LabelComboBox $frame.commonmodeLE \
                          -label [_m "Label|Common Mode"] \
                          -textvariable [mytypevar thecommonmode] \
                          -values {anode cathode} \
                          -editable no]
        pack $commonmodeLE -fill x -expand yes
        set commonmode [$cdi getElementsByTagName "commonmode"]
        if {[llength $commonmode] > 0} {
            set commonmode [lindex $commonmode 0]
            set thecommonmode [$commonmode data]
        }
        
        set mastnotebook [ScrollTabNotebook $frame.masts]
        pack $mastnotebook -expand yes -fill both
        foreach mast [$cdi getElementsByTagName "mast"] {
            set mastframe [$xmlmastconfig createGUI $mastnotebook \
                             mast $cdi $mast [_m "Label|Delete Mast"] \
                             [mytypemethod _addframe] [mytypemethod _delframe]]
        }
        set addmast [ttk::button $frame.addmast \
                    -text [_m "Label|Add another mast"] \
                    -command [mytypemethod _addblankmast]]
        pack $addmast -fill x
    }
    typemethod _addframe {parent frame count} {
        $mastnotebook add $frame -text [_ "Mast %d" $count] -sticky news
    }
    typemethod _delframe {frame} {
        $mastnotebook forget $frame
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
        set cdis [$configuration getElementsByTagName OpenLCB_QuadSignal -depth 1]
        set cdi [lindex $cdis 0]
        set lastevid [$cdi attribute lastevid]
        if {$lastevid eq {}} {
            set attrs [$cdi cget -attributes]
            lappend attrs lastevid [$generateEventID currentid]
            $cdi configure -attributes $attrs
        } else {
            set attrs [$cdi cget -attributes]
            set findx [lsearch -exact $attrs lastevid]
            incr findx
            set attrs [lreplace $attrs $findx $findx [$generateEventID currentid]]
            $cdi configure -attributes $attrs
        }
        CopyTransFromGUI $cdi
        CopyIdentFromGUI $cdi
        set i2caddrele [$configuration getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] < 1} {
            set i2caddrele [SimpleDOMElement %AUTO% -tag "i2caddress"]
            $cdi addchild $i2caddrele
        }
        $i2caddrele setdata $mcp23017address
        set commonmode [$configuration getElementsByTagName "commonmode"]
        if {[llength $commonmode] < 1} {
            set commonmode [SimpleDOMElement %AUTO% -tag "commonmode"]
            $cdi addchild $commonmode
        }
        $commonmode setdata $thecommonmode
        
        foreach mast [$cdi getElementsByTagName "mast"] {
            $xmlmastconfig copyFromGUI $mastnotebook $mast warnings
        }
        
        if {$warnings > 0} {
            tk_messageBox -type ok -icon info \
                  -message [_ "There were %d warnings.  Please correct and try again." $warnings]
            return no
        }
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
            close $conffp
        }
        return yes
    }
    typemethod _exit {} {
        #** Exit function.  Bound to the Exit file menu item.
        # Does not save the configuration data!
        
        ::exit
    }
    typemethod _addblankmast {} {
        #** Create a new blank mast.
        
        set cdis [$configuration getElementsByTagName OpenLCB_QuadSignal -depth 1]
        set cdi [lindex $cdis 0]
        set mast [SimpleDOMElement %AUTO% -tag "mast"]
        $cdi addchild $mast
        set mastframe [$xmlmastconfig createGUI $mastnotebook \
                         mast $cdi $mast [_m "Label|Delete Mast"] \
                         [mytypemethod _addframe] [mytypemethod _delframe]]
    }
    
    #*** Mast instances
    option -aspectlist -readonly yes -type AspectList -default {}
    option -description -readonly yes -default {}
    variable currentaspect {}
    constructor {args} {
        # Construct an instance for a signal mast
        #
        # @param ... Options:
        # @arg -aspectlist The Aspects for this signal.
        # @arg -description Description of the pin.
        # @par
        
        $self configurelist $args
        foreach e_n_hs [$self cget -aspectlist] {
            lassign $e_n_hs e n hs
            ::log::log debug "*** $type create $self: e: $e, n: $n, hs: $hs"
            lappend eventsconsumed $e
        }
    }
    method consumeEvent {event} {
        #** Handle an incoming event.
        #
        # @param event The event to handle.
        
        ::log::log debug "*** $self consumeEvent $event"
        foreach aspevnameheads [$self cget -aspectlist] {
            lassign $aspevnameheads aspev name heads
            if {[$event match $aspev]} {
                set currentaspect $aspevnameheads
                return true
            }
        }
        return false
    }
    method doblink {} {
        if {$currentaspect eq {}} {
            return
        }
        lassign $currentaspect aspev name heads
        ::log::log debug "*** $self doblink: heads: $heads"
        foreach h $heads {
            ::log::log debug "*** $self doblink: h: $h"
            foreach l $h {
                ::log::log debug "*** $self doblink: l: $l"
                lassign $l id effect
                set pin [LampID gpioPinNo $id]
                if {$pin < 0} {continue}
                ::log::log debug "*** $self doblink: pin = $pin, effect = $effect"
                switch $effect {
                    on {digitalWrite $pin $ON}
                    off {digitalWrite $pin $OFF}
                    blink {
                        if {$blinkstate} {
                            digitalWrite $pin $ON
                        } else {
                            digitalWrite $pin $OFF
                        }
                    }
                    reverseblink {
                        if {$blinkstate} {
                            digitalWrite $pin $OFF
                        } else {
                            digitalWrite $pin $ON
                        }
                    }
                }
            }
        }
    }
}

vwait forever
