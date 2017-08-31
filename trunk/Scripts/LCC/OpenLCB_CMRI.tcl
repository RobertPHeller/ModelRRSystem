#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Aug 28 14:06:47 2017
#  Last Modified : <170831.1402>
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


## @page OpenLCB_CMRI OpenLCB CMRI Node
# @brief OpenLCB CMRI node
#
# @section CMRISYNOPSIS SYNOPSIS
#
# OpenLCB_CMRI [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section CMRIDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for one or 
# more CMRI nodes on a CMRI network.  
#
# @section CMRIPARAMETERS PARAMETERS
#
# none
#
# @section CMRIOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_CMRI.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is cmriconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section CMRICONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" 
# chapter of the User Manual for the details on the schema for this XML 
# formatted file.  Also note that this program contains a built-in editor for 
# its own configuration file. 
#
#
# @section CMRIAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_CMRI]

package require CmriSupport 1.2
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
                                                                       [info script]]]] Messages]]

snit::integer posint -min 0
snit::integer byte   -min 0 -max 255
snit::enum    comp   -values {== !=}
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
    
snit::type InputEvent {
    pragma -hastypeinfo no -hastypedestroy no -hasinstances no

    typemethod validate {object} {
        if {[llength $object] != 5} {
            error [_ "Not an InputEvent: list does not have exactly 5 elements: %s" $object]
        } else {
            lassign $object ev ib mask comp val
            if {[catch {lcc::EventID validate $ev} why]} {
                error [_ "Not an InputEvent: %s" $why]
            }
            if {[catch {posint validate $ib} why]} {
                error [_ "Not an InputEvent: %s" $why]
            }
            if {[catch {Binary8 validate $mask} why]} {
                error [_ "Not an InputEvent: %s" $why]
            }
            if {[catch {Binary8 validate $val} why]} {
                error [_ "Not an InputEvent: %s" $why]
            }
            if {[catch {comp validate $comp} why]} {
                error [_ "Not an InputEvent: %s" $why]
            }
            return $object
        }
    }
}

snit::listtype InputEventList -type InputEvent -minlen 0

snit::type OutputEvent {
    pragma -hastypeinfo no -hastypedestroy no -hasinstances no

    typemethod validate {object} {
        if {[llength $object] != 4} {
            error [_ "Not an OutputEvent: list does not have exactly 4 elements: %s" $object]
        } else {
            lassign $object ev ob mask bits
            if {[catch {lcc::EventID validate $ev} why]} {
                error [_ "Not an OutputEvent: %s" $why]
            }
            if {[catch {posint validate $ob} why]} {
                error [_ "Not an OutputEvent: %s" $why]
            }
            if {[catch {Binary8 validate $mask} why]} {
                error [_ "Not an OutputEvent: %s" $why]
            }
            if {[catch {Binary8 validate $bits} why]} {
                error [_ "Not an OutputEvent: %s" $why]
            }
            return $object
        }
    }
}


snit::listtype OutputEventList -type OutputEvent -minlen 0

snit::type OpenLCB_CMRI {
    #** This class implements a OpenLCB interface to one or more
    # CMRI nodes
    #
    # Each instance manages one node.  typemethods implement the overall
    # OpenLCB node and the CMRI network -- all of the CMRI nodes are assumed to
    # be on one RS485 "network" attached to a single serial port.
    #
    # Instance options:
    # @arg -description A description of the node.
    # @arg -type The type of node, one of SUSIC, USIC, or SMINI. No default 
    #                  value.
    # @arg -address The address of the node.  Default is 0.
    # @arg -cardmap The card type map.  Only used with SUSIC and USIC. 
    #                       Default is {}.
    # @arg -yellowmap The yellow bi-color LED map.  Only used with the SMINI
    #                       card type. Default is {0 0 0 0 0 0}.
    # @arg -numberofyellow The number of yellow bi-color LED signals. Only
    #                       for SMINI cards.  Default is 0.
    # @arg -inputports The number of 8-bit input ports.  Default 0 (3 for 
    #                       SMINI cards).
    # @arg -outputports The number of 8-bit output ports.  Default 0 (6 for 
    #                       SMINI cards).
    # @arg -delay The delay value to use.  Only meaningful for older (USIC)
    #                       cards.  Default is 0.
    # @arg -inputeventlist A list of lists describing each input bitfield that 
    #                      produces an event.  The sublists describe one
    #                      input event and contain 5 elements: 
    #                      an eventid, the input byte no., a mask, 
    #                      a compare op, and a value to compare to.
    # @arg -outputeventlist A list of lists describing each output bitfield 
    #                       that consumes an event.
    # @par
    
    component cmrinode -inherit yes
    #** Low-level node to handle CMRI nodes
    option -inputeventlist -default {} -readonly yes -type InputEventList
    variable inputevents -array {}
    variable inputstates -array {}
    option -outputeventlist -default {} -readonly yes -type OutputEventList
    variable outputbitfields -array {}
    option -description -readonly yes -default ""
    constructor {args} {
        ::log::log debug "*** $type create $self $args"
        install cmrinode using CmriSupport::CmriNode %AUTO% \
              -type [from args -type] \
              -address [from args -address 0] \
              -cardmap [from args -cardmap] \
              -yellowmap [from args -yellowmap] \
              -numberofyellow [from args -numberofyellow 0] \
              -inputports [from args -inputports] \
              -outputports [from args -outputports] \
              -delay [from args -delay 0]
        ::log::log debug "*** $type create $self: cmrinode is $cmrinode, args are $args"
        $self configurelist $args
        foreach inev [$self cget -inputeventlist] {
            lassign $inev ev ib mask comp val
            set inputevents($ib,$mask,$comp,$val) $ev
            set inputstates($ib,$mask,$comp,$val) unknown
            lappend eventsproduced $ev
        }
        foreach outev [$self cget -outputeventlist] {
            lassign $outev ev ob mask bits
            set outputbitfields($ev) [list $ob $mask $bits]
            lappend eventscomsumed $ev
        }
    }
    method Read {eventid} {
        set inputbytes [$self inputs]
        set events [list]
        foreach ib_mask_comp_val [array names inputevents] {
            lassign [split $ib_mask_comp_val {,}] ib mask comp val
            set mask [Binary8 valueof $mask]
            set val  [Binary8 valueof $val]
            set ev $inputevents($ib_mask_comp_val)
            if {$eventid eq "*" || [$eventid match $ev]} {
                set byte [lindex $inputbytes $ib]
                set bitfield [expr {$byte & $mask}]
                set expr [list $bitfield $comp $val]
                if {[expr $expr]} {
                    lappend events [list $ev valid]
                    set inputstates($ib_mask_comp_val) true
                } else {
                    lappend events [list $ev invalid]
                    set inputstates($ib_mask_comp_val) false
                }
            }
        }
        return $events
    }
    method Poll {} {
        set inputbytes [$self inputs]
        set events [list]
        foreach ib_mask_comp_val [array names inputevents] {
            lassign [split $ib_mask_comp_val {,}] ib mask comp val
            set mask [Binary8 valueof $mask]
            set val  [Binary8 valueof $val]
            set ev $inputevents($ib_mask_comp_val)
            set byte [lindex $inputbytes $ib]
            set bitfield [expr {$byte & $mask}]
            set expr [list $bitfield $comp $val]
            if {[expr $expr]} {
                if {$inputstates($ib_mask_comp_val) eq "unknown"} {
                    lappend events $ev
                    set inputstates($ib_mask_comp_val) true
                } elseif {!$inputstates($ib_mask_comp_val)} {
                    lappend events $ev
                    set inputstates($ib_mask_comp_val) true
                }
            } else {
                set inputstates($ib_mask_comp_val) false
            }
        }
        foreach event $events {
            $type sendEvent $event
        }
    }
    method consumeEvent {event} {
        foreach ev [array names outputbitfields] {
            if {[$event match $ev]} {
                ::log::log debug "*** $self consumeEvent: event is [$event cget -eventidstring], ev is [$ev cget -eventidstring]"
                lassign $outputbitfields($ev) ob mask bits
                set mask [Binary8 valueof $mask]
                set bits [Binary8 valueof $bits]
                ::log::log debug "*** $self consumeEvent: ob = $ob, mask = $mask, bits = $bits"
                $self setbitfield $ob $mask $bits
                return true
            }
        }
        return false
    }
    method canConsume {} {
        return [expr {[llength [array names outputbitfields]] > 0}]
    }
    method canProduce {} {
        return [expr {[llength [array names inputevents]] > 0}]
    }
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  nodelist {};#       Node list
    typevariable  consumers {};#      Nodes that consume events
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Nodes that produce events
    typevariable  eventsproduced {};# Events produced.
    typevariable  defaultpollinterval 500;# Default poll interval
    typevariable  pollinterval 500;#  Poll interval
    typevariable  port "/dev/ttyS0"
    typevariable  baud 9600
    typevariable  maxtries 10000
    typecomponent xmlnodeconfig;# Common node config object
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages CMR/I nodes, consuming or producing
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
        set conffile [from argv -configuration "cmriconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmlnodeconfig [XmlConfiguration create %AUTO% {
                             <configure>
                               <string option="-description" tagname="description">Description</string>
                               <enum option="-type" tagname="type" enums="SUSIC USIC SMINI">Node type</enum>
                               <int option="-address" tagname="address" min="0" max="127">Node Address</int>
                               <list option="-cardmap" tagname="cardmap" mincount="0" maxcount="unlimited">Card Map</list>
                               <list option="-yellowmap" tagname="yellowmap" mincount="0" maxcount="6">Yellow bi-color LED Map</list>
                               <int option="-numberofyellow" tagname="numberofyellow" min="0">Number of yellow bi-color LED signals</int>
                               <int option="-inputports" tagname="inputports" min="0">Number of 8-bit input ports</int>
                               <int option="-outputports" tagname="outputports" min="0">Number of 8-bit output ports</int>
                               <int option="-delay" tagname="delay" min="0">Delay Value for USIC cards</int>
                               <group option="-inputeventlist" tagname="input" mincount="0" maxcount="unlimited" repname="Input">
                                 <eventid tagname="eventid">Event ID</eventid>
                                 <int tagname="byte" min="0">Byte Number</int>
                                 <bytebits tagname="mask">Mask</bytebits>
                                 <enum tagname="comp" enums="== !=">Compare Op</enum>
                                 <bytebits tagname="value">Value to compare to</bytebits>
                               </group>
                               <group option="-outputeventlist" tagname="output" repname="Output" mincount="0" maxcount="unlimited">
                                 <eventid tagname="eventid">Event ID</eventid>
                                 <int tagname="byte" min="0">Byte Number</int>
                                 <bytebits tagname="mask">Mask</bytebits>
                                 <bytebits tagname="value">Value to store</bytebits>
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
        getIdentification [$configuration getElementsByTagName "identification"]  nodename nodedescriptor
        set pollele [$configuration getElementsByTagName "pollinterval"]
        if {[llength $pollele] > 0} {
            set pollele [lindex $pollele 0]
            set pollinterval [$pollele data]
        }
        #<port></port>
        set portele [$configuration getElementsByTagName "port"]
        if {[llength $portele] > 0} {
            set portele [lindex $portele]
            set port [$portele data]
        }
        #<baud></baud>
        set baudele [$configuration getElementsByTagName "baud"]
        if {[llength $baudele] > 0} {
            set baudele [lindex $baudele 0]
            set baud [$baudele data]
        }
        #<maxtries></maxtries>
        set maxtriesele [$configuration getElementsByTagName "maxtries"]
        if {[llength $maxtriesele] > 0} {
            set maxtriesele [lindex $maxtriesele 0]
            set maxtries [$maxtriesele data]
        }
        #CmriSupport openport port baud maxtries
        CmriSupport::CmriNode openport $port $baud $maxtries
        
        foreach node [$configuration getElementsByTagName "node"] {
            ::log::log debug "*** $type typeconstructor: node is $node"
            set nodecommand [$xmlnodeconfig processConfig $node [list $type create %AUTO%]]
            ::log::log debug "*** $type typeconstructor: nodecommand = $nodecommand"
            set nod [eval $nodecommand]
            if {[$nod canConsume]} {lappend consumers $nod}
            if {[$nod canProduce]} {lappend producers $nod}
            lappend nodelist $nod
        }
        if {[llength $nodelist] == 0} {
            ::log::logError [_ "No nodes specified!"]
            exit 93
        }
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB CMR/I" \
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
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
        foreach ev $eventsproduced {
            $transport ProducerIdentified $ev unknown
        }
        
        after $pollinterval [mytypemethod _poll]
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod _poll {} {
        #** Polling function.  Polls all of the sensors.
        
        foreach p $producers {
            $p Poll
        }
        after $pollinterval [mytypemethod _poll]
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
                if {$validity eq "valid"} {
                    foreach c $consumers {
                        ::log::log debug "*** $type _eventHandler: node is [$c cget -address]"
                        ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                        $c consumeEvent $eventid
                    }
                }
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
                foreach p $producers {
                    foreach evstate [$p Read $eventid] {
                        foreach {ev state} $evstate {break}
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
                foreach p $producers {
                    foreach evstate [$p Read *] {
                        foreach {ev state} $evstate {break}
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            report {
                foreach c $consumers {
                    ::log::log debug "*** $type _eventHandler: node is [$c cget -address]"
                    ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $c consumeEvent $eventid
                    
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
    typecomponent editContextMenu
    typevariable    portname
    typevariable    baudrate 9600
    typevariable    maximumtries 10000
    typevariable    pollinginterval 500;# polling interval.
    typecomponent   nodes;# Node list
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
            {command "[_m {Menu|Help|EventExchange node for CMR/I nodes}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for CMR/I nodes"}}
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_CMRI/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_CMRI -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set pollele [SimpleDOMElement %AUTO% -tag "pollinterval"]
        $cdi addchild $pollele
        $pollele setdata 500
        set portele [SimpleDOMElement %AUTO% -tag "port"]
        $cdi addchild $portele
        $portele setdata /dev/ttyS0
        set baudele [SimpleDOMElement %AUTO% -tag "baud"]
        $cdi addchild $baudele
        $baudele setdata 9600
        set maxtriesele [SimpleDOMElement %AUTO% -tag "maxtries"]
        $cdi addchild $maxtriesele
        $maxtriesele setdata 10000
        set node [SimpleDOMElement %AUTO% -tag "node"]
        $cdi addchild $node
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $node addchild $descrele
        $descrele setdata "Sample Node (SMINI card at address 0)"
        set cardtype [SimpleDOMElement %AUTO% -tag "type"]
        $node addchild $cardtype
        $cardtype setdata SMINI
        set address [SimpleDOMElement %AUTO% -tag "address"]
        $node addchild $address
        $address setdata 0
        set input [SimpleDOMElement %AUTO% -tag "input"]
        $node addchild $input
        set event [SimpleDOMElement %AUTO% -tag "eventid"]
        $input addchild $event
        $event setdata [$generateEventID nextid]
        set byte [SimpleDOMElement %AUTO% -tag "byte"]
        $input addchild $byte
        $byte setdata 0
        set mask [SimpleDOMElement %AUTO% -tag "mask"]
        $input addchild $mask
        $mask setdata B00000001
        set comp [SimpleDOMElement %AUTO% -tag "comp"]
        $input addchild $comp
        $comp setdata "=="
        set value [SimpleDOMElement %AUTO% -tag "value"]
        $input addchild $value
        $value setdata B00000001
        set input [SimpleDOMElement %AUTO% -tag "input"]
        $node addchild $input
        set event [SimpleDOMElement %AUTO% -tag "eventid"]
        $input addchild $event
        $event setdata [$generateEventID nextid]
        set byte [SimpleDOMElement %AUTO% -tag "byte"]
        $input addchild $byte
        $byte setdata 0
        set mask [SimpleDOMElement %AUTO% -tag "mask"]
        $input addchild $mask
        $mask setdata B00000001
        set comp [SimpleDOMElement %AUTO% -tag "comp"]
        $input addchild $comp
        $comp setdata "=="
        set value [SimpleDOMElement %AUTO% -tag "value"]
        $input addchild $value
        $value setdata B00000000
        set input [SimpleDOMElement %AUTO% -tag "input"]
        $node addchild $input
        set event [SimpleDOMElement %AUTO% -tag "eventid"]
        $input addchild $event
        $event setdata [$generateEventID nextid]
        set byte [SimpleDOMElement %AUTO% -tag "byte"]
        $input addchild $byte
        $byte setdata 0
        set mask [SimpleDOMElement %AUTO% -tag "mask"]
        $input addchild $mask
        $mask setdata B00000010
        set comp [SimpleDOMElement %AUTO% -tag "comp"]
        $input addchild $comp
        $comp setdata "=="
        set value [SimpleDOMElement %AUTO% -tag "value"]
        $input addchild $value
        $value setdata B00000010
        set input [SimpleDOMElement %AUTO% -tag "input"]
        $node addchild $input
        set event [SimpleDOMElement %AUTO% -tag "eventid"]
        $input addchild $event
        $event setdata [$generateEventID nextid]
        set byte [SimpleDOMElement %AUTO% -tag "byte"]
        $input addchild $byte
        $byte setdata 0
        set mask [SimpleDOMElement %AUTO% -tag "mask"]
        $input addchild $mask
        $mask setdata B00000010
        set comp [SimpleDOMElement %AUTO% -tag "comp"]
        $input addchild $comp
        $comp setdata "=="
        set value [SimpleDOMElement %AUTO% -tag "value"]
        $input addchild $value
        $value setdata B00000000
        set output [SimpleDOMElement %AUTO% -tag "output"]
        $node addchild $output
        set event [SimpleDOMElement %AUTO% -tag "eventid"]
        $output addchild $event
        $event setdata [$generateEventID nextid]
        set byte [SimpleDOMElement %AUTO% -tag "byte"]
        $output addchild $byte
        $byte setdata 0
        set mask [SimpleDOMElement %AUTO% -tag "mask"]
        $output addchild $mask
        $mask setdata B00000001
        set value [SimpleDOMElement %AUTO% -tag "value"]
        $output addchild $value
        $value setdata B00000001
        set output [SimpleDOMElement %AUTO% -tag "output"]
        $node addchild $output
        set event [SimpleDOMElement %AUTO% -tag "eventid"]
        $output addchild $event
        $event setdata [$generateEventID nextid]
        set byte [SimpleDOMElement %AUTO% -tag "byte"]
        $output addchild $byte
        $byte setdata 0
        set mask [SimpleDOMElement %AUTO% -tag "mask"]
        $output addchild $mask
        $mask setdata B00000001
        set value [SimpleDOMElement %AUTO% -tag "value"]
        $output addchild $value
        $value setdata B00000000
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
        set cdis [$configuration getElementsByTagName OpenLCB_CMRI -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_CMRI container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_CMRI Configuration Editor (%s)" $conffile]
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
        $xmlnodeconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
        set portLE [LabelEntry $frame.portLE \
                    -label [_m "Label|CMR/I Network Serial Port"] \
                    -textvariable [mytypevar portname]]
        pack $portLE -fill x -expand yes
        set portele [$cdi getElementsByTagName "port"]
        if {[llength $portele] > 0} {
            set portname [[lindex $portele 0] data]
        }
        
        set baudrateLE [LabelComboBox $frame.baudrateLE \
                        -label [_m "Label|Baud Rate"] \
                        -textvariable [mytypevar baudrate] \
                        -values [list 9600 19200 28800 57600 115200]]
        pack $baudrateLE -fill x -expand yes
        set baudele [$cdi getElementsByTagName "baud"]
        if {[llength $baudele] > 0} {
            set baudrate [[lindex $baudele 0] data]
        }
        set maximumtriesLE [LabelSpinBox $frame.maximumtriesLE \
                            -label [_m "Label|Maximum Tries"] \
                            -textvariable [mytypevar maximumtries] \
                            -range {1 10000 1}]
        pack $maximumtriesLE -fill x -expand yes
        set maxtele [$cdi getElementsByTagName "maxtries"]
        if {[llength $maxtele] > 0} {
            set maximumtries [[lindex $maxtele 0] data]
        }
        
        set pollintervalLE [LabelSpinBox $frame.pollintervalLE \
                            -label [_m "Label|Poll Interfal"] \
                            -textvariable [mytypevar pollinginterval] \
                            -range {100 5000 10}]
        pack $pollintervalLE -fill x -expand yes
        set pollele [$cdi getElementsByTagName "pollinterval"]
        if {[llength $pollele] > 0} {
            set pollele [lindex $pollele 0]
            set pollinginterval [$pollele data]
        }
        
        set nodes [ScrollTabNotebook $frame.nodes]
        pack $nodes -expand yes -fill both
        foreach node [$cdi getElementsByTagName "node"] {
            set nodeframe [$xmlnodeconfig createGUI $nodes node $cdi \
                          $node [_m "Label|Delete Node"] \
                          [mytypemethod _addframe] [mytypemethod _delframe]]
        }
        set addnode [ttk::button $frame.addnode \
                       -text [_m "Label|Add another node"] \
                       -command [mytypemethod _addblanknode]]
        pack $addnode -fill x
    }
    typemethod _addframe {parent frame count} {
        $nodes add $frame -text [_ "Node %d" $count] -sticky news
    }
    typemethod _delframe {frame} {
        $nodes forget $frame
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
        set cdis [$configuration getElementsByTagName OpenLCB_CMRI -depth 1]
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
        
        set portele [$cdi getElementsByTagName "port"]
        if {[llength $portele] < 1} {
            set portele [SimpleDOMElement %AUTO% -tag "port"]
            $cdi addchild $portele
        }
        $portele setdata $portname
        set baudele [$cdi getElementsByTagName "baud"]
        if {[llength $baudele] < 1} {
            set baudele [SimpleDOMElement %AUTO% -tag "baud"]
            $cdi addchild $baudele
        }
        $baudele setdata $baudrate
        set maxtele [$cdi getElementsByTagName "maxtries"]
        if {[llength $maxtele] < 1} {
            set maxtele [SimpleDOMElement %AUTO% -tag "maxtries"]
            $cdi addchild $maxtele
        }
        $maxtele setdata $maximumtries
        
        set pollele [$cdi getElementsByTagName "pollinterval"]
        if {[llength $pollele] < 1} {
            set pollele [SimpleDOMElement %AUTO% -tag "pollinterval"]
            $cdi addchild $pollele
        }
        $pollele setdata $pollinginterval
        
        foreach node [$cdi getElementsByTagName "node"] {
            $xmlnodeconfig copyFromGUI $nodes $node warnings
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
    typemethod _addblanknode {} {
        #** Create a new blank node.
        
        set cdis [$configuration getElementsByTagName OpenLCB_CMRI -depth 1]
        set cdi [lindex $cdis 0]
        set node [SimpleDOMElement %AUTO% -tag "node"]
        $cdi addchild $node
        set nodeframe [$xmlnodeconfig createGUI $nodes node $cdi $node \
                      [_m "Label|Delete Node"] \
                      [mytypemethod _addframe] [mytypemethod _delframe]]
    }
    
    


}


vwait forever
