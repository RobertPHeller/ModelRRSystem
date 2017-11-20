#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Aug 10 12:44:31 2016
#  Last Modified : <170826.2103>
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


## @page OpenLCB_TrackCircuits OpenLCB Virtual Track Circuits node
# @brief OpenLCB Virtual Track Circuits node
#
# @section TrackCircuitsSYNOPSIS SYNOPSIS
#
# OpenLCB_TrackCircuits [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section TrackCircuitsDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for one or 
# more Virtual Track Circuits (much like the track circuits coded in the RR
# Cirkits Tower-LCC nodes).
#
#
# There are seven (7) regular aspect events (@b Clear, @b Advance @b Approach, 
# @b Approach @b Limited, @b Approach @b Medium, @b Approach, @b Approach 
# @b Slow, and @b Accelerated @b Tumble @b Down), plus @b Start,  @b Non-Vital 
# (@b occupied), @b Non-Vital  (@b normal), @b Power/Lamp (@b failed), and 
# @b Power/Lamp (@b normal).
#
# @subsection TrackCircuitsCodeRate Code rate and aspect.
#
# - 7 Clear.
# - 4 Advance Approach.
# - 3 Approach Limited.
# - 8 Approach Medium.
# - 2 Approach.
# - 9 Approach Slow.
# - 6 Accelerated Tumble Down.
# - 5 Non-Vital code indicating track occpancy, or a hand-thrown switch in the 
#     block out of normal correspondence.
# - M Non-Vital code indicating power off in the block, or a lamp out of 
#     condition in the block. Power Off will indicate from east end CP, lamp 
#     out from the west end CP.
# .
#
# @section TrackCircuitsPARAMETERS PARAMETERS
#
# none
#
# @section TrackCircuitsOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_TrackCircuits.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is tracksconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section TrackCircuitsCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section TrackCircuitsAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_TrackCircuits]

package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::type TrackCodes {
    #** TrackCode type.
    
    pragma -hastypeinfo no -hastypedestroy no -hasinstances no
    
    typevariable codevalues -array {
        None 0
        Code7 1
        Code4 2
        Code3 3
        Code8 4
        Code2 5
        Code9 6
        Code6 7
        Code5_occupied 8
        Code5_normal 9
        CodeM_failed 10
        CodeM_normal 11
    }
    #** Code values.
    typevariable codelabels -array {}
    #** Code Labels.
    typevariable valuemap -array {}
    #** Value map.
    
    typeconstructor {
        #** Type constructor: initialize variables.
        
        set codelabels(None) [_m "Label|None"]
        set codelabels(Code7) [_m "Label|Code 7 Clear"]
        set codelabels(Code4) [_m "Label|Code 4 Advance Approach"]
        set codelabels(Code3) [_m "Label|Code 3 Approach Limited"]
        set codelabels(Code8) [_m "Label|Code 8 Approach Medium"]
        set codelabels(Code2) [_m "Label|Code 2 Approach"]
        set codelabels(Code9) [_m "Label|Code 9 Approach Slow"]
        set codelabels(Code6) [_m "Label|Code 6 Accelerated Tumble Down"]
        set codelabels(Code5_occupied) [_m "Label|Code 5 Non-Vital (occupied)"]
        set codelabels(Code5_normal) [_m "Label|Code 5 Non-Vital (normal)"]
        set codelabels(CodeM_failed) [_m "Label|Code M Power/Lamp (failed)"]
        set codelabels(CodeM_normal) [_m "Label|Code M Power/Lamp (normal)"]
        foreach c [array names codevalues] {
            set valuemap($codevalues($c)) $c
        }
    }
    typemethod validate {object} {
        #** Validate a TrackCode/
        #
        # @param object The object to validate.
        
        #puts stderr "*** $type validate $object"
        if {[lsearch [array names codevalues] $object] < 0} {
            #puts stderr "*** $type validate: failure"
            error [_ "Not a %s: %s" $type $object]
        }
        #puts stderr "*** $type validate: success"
        return $object
    }
    typemethod CodeLabel {object} {
        #** Return a Code's label (used for UI purposes, etc.).
        #
        # @param object The object to return a label for.
        # @return The code's user friendly label.
        
        $type validate $object
        return $codelabels($object)
    }
    typemethod CodeValue {object} {
        #** Return a Code's value (used for virtual events).
        #
        # @param object The object to return a value for.
        # @return The code's value.
        
        $type validate $object
        return $codevalues($object)
    }
    typemethod CodeNeedsStart {object} {
        #** Does this code need a Code 1 Start event?
        #
        # @param object The object to check.
        # @return Flag to indicate if a Code 1 Start event is needed.
        
        $type validate $object
        if {$codevalues($object) >= 1 || $codevalues($object) <= 7} {
            return true
        } else {
            return false
        }
    }
    typemethod CodeFromEvent {baseeventid actualeventid} {
        lcc::EventID validate $baseeventid
        lcc::EventID validate $actualeventid
        set index [$actualeventid eventdiff $baseeventid]
        #puts stderr "*** $type CodeFromEvent: index = $index"
        if {[info exists valuemap($index)]} {
            return $valuemap($index)
        } else {
            return {}
        }
    }
    typemethod CodeFromValue {value} {
        if {[info exists valuemap($value)]} {
            return $valuemap($value)
        } else {
            error [_ "Not a valid code value: %s" $value]
        }
    }
    
        
    typemethod EventFromCode {code baseeventid} {
        $type validate $code
        lcc::EventID validate $baseeventid
        return [$baseeventid addtoevent $codevalues($code)]
    }
}

snit::type CodeEventList {
    #** Code event list type.
    #
    # This is an even element list containing alternating TrackCodes and 
    # EventIDs.
    
    pragma -hastypeinfo no -hastypedestroy no -hasinstances no
    
    typemethod validate {object} {
        foreach code_event $object {
            lassign $code_event code event
            if {[catch {TrackCodes validate $code}]} {
                error [_ "Not a %s type (invalid TrackCode %s): %s" $type \
                       $code $object]
            }
            if {[catch {lcc::EventID validate $event}]} {
                error [_ "Not a %s type (invalid EventID %s): %s" $type \
                       $event $object]
            }
        }
        return $object
    }
}

snit::type Transmitter {
    #** This class implements a single transmitter.
    #
    # Instance options:
    # @arg -eventid     The event to respond to.
    # @arg -code        The code to send.
    # @par
    
    option -eventid -type lcc::EventID_or_null -readonly yes -default {}
    option -code -type TrackCodes -readonly yes -default {None}
    
    constructor {args} {
        #** Constructor: create a Transmitter instance.
        #
        # @param ... Options:
        # @arg -eventid     The event to respond to.
        # @arg -code        The code to send.
        # @par
        
        $self configurelist $args
    }
    
    method processevent {eventid} {
        #** Process an event.
        #
        # @param eventid The event to process.
        
        EventID validate $eventid
        if {[[$self cget -eventid] match $eventid]} {
            return [$self cget -code]
        } else {
            return None
        }
    }
}

snit::type Receiver {
    #** This class implements a single receiver.
    #
    # Instance options:
    # @arg -code        The code to receive.
    # @arg -eventid     The event to send.
    # @par
    
    option -code -type TrackCodes -readonly yes -default {None}
    option -eventid -type lcc::EventID_or_null -readonly yes -default {}
    
    constructor {args} {
        #** Constructor: create a Transmitter instance.
        #
        # @param ... Options:
        # @arg -code        The code to receive.
        # @arg -eventid     The event to send.
        # @par
        
        $self configurelist $args
    }
    
    method processcode {code} {
        #** Process a received code.
        #
        # @param code The received code.
        #
        
        TrackCodes validate $code
        if {$code eq [$self cget -code]} {
            return [$self cget -eventid]
        } else {
            return {}
        }
    }
}


snit::type OpenLCB_TrackCircuits {
    #** This class implements a OpenLCB virtual track circuits node.
    #
    # Each instance manages one virtual track circuit.  The typemethods 
    # implement the overall OpenLCB node.
    #
    # Instance options:
    # @arg -description Description (name) of the track.
    # @arg -transmitters A list of transmitter code events.
    # @arg -transmitbaseevent The transmit base event.
    # @arg -receivebaseevent The revceive base event.
    # @arg -code1startevent The Code 1 Start event.
    # @arg -receivers   A list of receiver code events.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    variable transmitters {}
    variable receivers {}
    option -description -readonly yes -default {}
    option -transmitters -readonly yes -default {} -type CodeEventList
    option -transmitbaseevent -readonly yes -default {} -type lcc::EventID_or_null
    option -receivebaseevent -readonly yes -default {} -type lcc::EventID_or_null
    option -code1startevent -readonly yes -default {} -type lcc::EventID_or_null
    option -receivers -readonly yes -default {} -type CodeEventList
    
    constructor {args} {
        #** Construct one track circuit.
        #
        # @param ... Options:
        # @arg -description Description (name) of the track.
        # @arg -transmitters A list of transmitter code events.
        # @arg -transmitbaseevent The transmit base event.
        # @arg -receivebaseevent The revceive base event.
        # @arg -code1startevent The Code 1 Start event.
        # @arg -receivers   A list of receiver code events.
        # @par
        
        ::log::log debug "*** $type create $self $args"
        $self configurelist $args
        ::log::log debug "*** $type create $self: [llength [$self cget -transmitters]] transmitters"
        foreach c_e [$self cget -transmitters] {
            ::log::log debug "*** $type create $self: c_e is $c_e"
            lassign $c_e c e
            ::log::log debug "*** $type create $self: c is $c, e is $e"
            lappend transmitters [Transmitter create %AUTO% -eventid $e -code $c]
        }
        ::log::log debug "*** $type create $self: [llength $transmitters] transmitters created"
        foreach c_e [$self cget -receivers] {
            lassign $c_e c e
            lappend receivers [Receiver create %AUTO% -code $c -eventid $e]
        }
    }
    method myproducedevents {} {
        #** Return a list of events this track produces.
        
        ::log::log debug "*** $self myproducedevents"
        set havec1 no
        set producedevents [list]
        ::log::log debug "*** $self myproducedevents: [llength $transmitters] transmitters"
        foreach t $transmitters {
            set code [$t cget -code]
            if {$code eq "None"} {continue}
            ::log::log debug "*** $self myproducedevents: transmit code is $code"
            set codeevent [TrackCodes EventFromCode $code [$self cget -transmitbaseevent]]
            ::log::log debug "*** $self myproducedevents: codeevent is $codeevent"
            lappend producedevents $codeevent
        }
        foreach r $receivers {
            set code [$r cget -code]
            set e    [$r cget -eventid]
            ::log::log debug "*** $self myproducedevents: receive code is $code, e is $e"
            lappend producedevents $e
            if {!$havec1 && [TrackCodes CodeNeedsStart $code]} {
                lappend producedevents [$self cget -code1startevent]
                set havec1 yes
            }
        }
        return $producedevents
    }
    method myconsumedevents {} {
        #** Return a list of events this track circuit comsumes.
        
        ::log::log debug "*** $self myconsumedevents"
        set consumedevents [list]
        foreach t $transmitters {
            set e [$t cget -eventid]
            ::log::log debug "*** $self myconsumedevents: for $t, e is $e"
            if {$e ne {}} {
                lappend consumedevents $e
            }
        }
        foreach r $receivers {
            set c [$r cget -code]
            set e [TrackCodes EventFromCode $c [$self cget -receivebaseevent]]
            ::log::log debug "*** $self myconsumedevents: for $r, c is $c, and e is $e"
            lappend consumedevents $e
        }
        return $consumedevents
    }
    method processevent {event} {
        #** Process an incoming event.
        # The event is either an event that triggers a transmitter or it is a
        # virtual code event, which triggers a receiver.
        # If a transmitter is triggered, a virtual code event is generated.
        # If a receiver is triggered, an aspect event is generated, possibly 
        # preceded by a Code 1 Start event.
        
        ::log::log debug "*** $self processevent $event ([$event cget -eventidstring])"
        foreach t $transmitters {
            set code [$t processevent $event]
            ::log::log debug "*** $self processevent: transmitter code is $code"
            if {$code eq "None"} {continue}
            set codeevent [TrackCodes EventFromCode $code [$self cget -transmitbaseevent]]
            $type sendevent $codeevent
            $codeevent destroy

        }
        set code [TrackCodes CodeFromEvent [$self cget -receivebaseevent] $event]
        ::log::log debug "*** $self processevent: received code (?) = '$code'"
        if {$code ne {}} {
            foreach r $receivers {
                set event [$r processcode $code]
                if {$event ne {}} {
                    set delay 0
                    switch $code {
                        Code7 {set delay 224}
                        Code4 {set delay 320}
                        Code3 {set delay 496}
                        Code8 {set delay 944}
                        Code2 {set delay 688}
                        Code9 {set delay 816}
                        Code6 {set delay 600}
                        Code5_occupied -
                        Code5_normal -
                        CodeM_failed -
                        CodeM_normal {set delay 496}
                    }
                    if {$delay > 0} {
                        after $delay [mymethod sendmyevent [TrackCodes CodeNeedsStart $code] $event]
                    } else {
                        $self sendmyevent [TrackCodes CodeNeedsStart $code] $event
                    }
                }
            }
        }
    }
    method sendmyevent {code1startneeded event} {
        #** Actually send the event.  This memthod might be called after a 
        # delay.
        #
        # @param code1startneeded Flag to indicate if a Code 1 Start event is 
        # needed.
        # @param event The event to send.
        
        if {$code1startneeded} {
            set e [$self cget -code1startevent]
            if {$e ne {}} {
                $type sendevent $e
            }
        }
        $type sendevent $event
    }
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  alltracks [list];#  All tracks
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  eventsproduced {};# Events produced.
    typecomponent editContextMenu
    typecomponent xmltrackcircuitconfig
    typecomponent generateEventID
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages virtual track circuits.
        
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
        set conffile [from argv -configuration "tracksconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmltrackcircuitconfig [XmlConfiguration create %AUTO% {
  <configure>
    <string tagname="description" option="-description">Description</string>
    <group tagname="transmitter" option="-transmitters" repname="Command"
           mincount="0" maxcount="unlimited">
      <enum tagname="code" 
            enums="None Code7 Code4 Code3 Code8 Code2 Code9 Code6 Code5_occupied Code5_normal CodeM_failed CodeM_normal">The following Track Code will be sent</enum>
      <eventid tagname="eventid">when this event occurs</eventid>
    </group>
    <eventid tagname="transmitbaseevent" option="-transmitbaseevent" roundup="16">Transmit Group Base Link</eventid>
    <eventid tagname="receivebaseevent" option="-receivebaseevent" roundup="16">Receive Group Base Link</eventid>
    <eventid tagname="code1startevent" option="-code1startevent" roundup="16">Upon reception of 'Code 1 Start', this event will be sent</eventid>
    <group repname="Action" tagname="receiver" option="-receivers"
           mincount="0" maxcount="unlimited">
      <enum tagname="code" enums="None Code7 Code4 Code3 Code8 Code2 Code9 Code6 Code5_occupied Code5_normal CodeM_failed CodeM_normal">Upon reception of this Track Code</enum>
      <eventid tagname="eventid">this event will be sent</eventid>
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
        getTransport [$configuration getElementsByTagName "transport"] \
              transportConstructor transportOpts
        set nodename ""
        set nodedescriptor ""
        getIdentification [$configuration getElementsByTagName "identification"]  nodename nodedescriptor
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB Track Circuits" \
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
        ::log::log debug "*** $type typeconstructor: transport = $transport"
        
        foreach track [$configuration getElementsByTagName "track"] {
            set trackcommand [$xmltrackcircuitconfig processConfig $track [list $type create %AUTO%]]
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set track [eval $trackcommand]
            ::log::log debug "*** $type typeconstructor: track is $track"
            foreach pev [$track myproducedevents] {
                lappend eventsproduced $pev
            }
            ::log::log debug "*** $type typeconstructor: eventsproduced is $eventsproduced"
            foreach cev [$track myconsumedevents] {
                lappend eventsconsumed $cev
            }
            ::log::log debug "*** $type typeconstructor: eventsconsumed is $eventsconsumed"
            lappend alltracks $track
            ::log::log debug "*** $type typeconstructor: alltracks is $alltracks"
        }
        if {[llength $alltracks] == 0} {
            ::log::logError [_ "No tracks specified!"]
            exit 93
        }
        if {[llength $eventsconsumed] == 0} {
            ::log::logError [_ "No events consumed!"]
            exit 92
        }
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
        foreach ev $eventsproduced {
            $transport ProducerIdentified $ev unknown
        }
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    
    
    
    typemethod sendevent {event} {
        #** Send an event.  First the event is passed to each track circuit to 
        # see if it is of local interest.  Then it is sent out on the network.
        #
        # @param event The event to send.
        
        $transport ProduceEvent $event
        foreach track $alltracks {
            $track processevent $event
        }
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
                    foreach t $alltracks {
                        ::log::log debug "*** $type _eventHandler: track is [$t cget -description]"
                        ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                        $t processevent $eventid
                        
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
                foreach t $alltracks {
                    ::log::log debug "*** $type _eventHandler: track is [$t cget -description]"
                    ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $t processevent $eventid
                    
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
    typecomponent   tracks;# Track list
    
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
            {command "[_m {Menu|Help|EventExchange node for virtual track circuits}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for virtual track circuits"}}
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_TrackCircuits/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_TrackCircuits -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        $cdi addchild $track
        set description [SimpleDOMElement %AUTO% -tag "description"]
        $track addchild $description
        $description setdata "Sample Track"
        set enabled [SimpleDOMElement %AUTO% -tag "enabled"]
        $track addchild $enabled
        for {set c 1} {$c < 11} {incr  c} {
            set thecode [TrackCodes CodeFromValue $c]
            set transmitter [SimpleDOMElement %AUTO% -tag "transmitter"]
            $track addchild $transmitter
            set code [SimpleDOMElement %AUTO% -tag "code"]
            $transmitter addchild $code
            $code setdata $thecode
            set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
            $transmitter addchild $eventid
            $eventid setdata [$generateEventID nextid]
        }
        set transmitbaseevent [SimpleDOMElement %AUTO% -tag "transmitbaseevent"]
        $track addchild $transmitbaseevent
        $transmitbaseevent setdata [$generateEventID nextid -roundup 16]
        set receivebaseevent [SimpleDOMElement %AUTO% -tag "receivebaseevent"]
        $track addchild $receivebaseevent
        $receivebaseevent setdata [$generateEventID nextid -roundup 16]
        set code1startevent [SimpleDOMElement %AUTO% -tag "code1startevent"]
        $track addchild $code1startevent
        $code1startevent setdata [$generateEventID nextid -roundup 16]
        for {set c 1} {$c < 11} {incr  c} {
            set thecode [TrackCodes CodeFromValue $c]
            set receiver [SimpleDOMElement %AUTO% -tag "receiver"]
            $track addchild $receiver
            set code [SimpleDOMElement %AUTO% -tag "code"]
            $receiver addchild $code
            $code setdata $thecode
            set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
            $receiver addchild $eventid
            $eventid setdata [$generateEventID nextid]
        }
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
        set cdis [$configuration getElementsByTagName OpenLCB_TrackCircuits -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_TrackCircuits container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_TrackCircuits Configuration Editor (%s)" $conffile]
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
        $xmltrackcircuitconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
        set tracks [ScrollTabNotebook $frame.tracks]
        pack $tracks -expand yes -fill both
        foreach track [$cdi getElementsByTagName "track"] {
            set trackframe [$xmltrackcircuitconfig createGUI $tracks track \
                            $cdi $track [_m "Label|Delete Track"] \
                            [mytypemethod _addframe] \
                            [mytypemethod _delframe]]
        }
        set addtrack [ttk::button $frame.addtrack \
                      -text [_m "Label|Add another track"] \
                      -command [mytypemethod _addblanktrack]]
        pack $addtrack -fill x
    }
    typemethod _addblanktrack {} {
        #** Create a new blank track.
        
        set cdis [$configuration getElementsByTagName OpenLCB_TrackCircuits -depth 1]
        set cdi [lindex $cdis 0]
        set track [SimpleDOMElement %AUTO% -tag "track"]
        $cdi addchild $track
        set trackframe [$xmltrackcircuitconfig createGUI $tracks track \
                            $cdi $track [_m "Label|Delete Track"] \
                            [mytypemethod _addframe] \
                            [mytypemethod _delframe]]
    }
    typemethod _delframe {frame} {
        $tracks forget $frame
    }
    typemethod _addframe {parent frame count} {
        $parent add $frame -text [_m "LABEL|Track %d" $count] -sticky news
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
        set cdis [$configuration getElementsByTagName OpenLCB_TrackCircuits -depth 1]
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
        foreach track [$cdi getElementsByTagName "track"] {
            $xmltrackcircuitconfig copyFromGUI $tracks $track warnings
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
    
}


vwait forever
