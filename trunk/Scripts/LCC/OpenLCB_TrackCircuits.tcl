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
#  Last Modified : <160815.1243>
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
# @section SYNOPSIS
#
# OpenLCB_TrackCircuits [-configure] [-debug] [-configuration confgile]
#
# @section DESCRIPTION
#
# This program is a daemon that implements a OpenLCB psuedo node for one or 
# more Virtual Track Circuits (much like the track circuits coded in the RR
# Cirkits Tower-LCC nodes).  
#
# @section PARAMETERS
#
# none
#
# @section OPTIONS
#
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is tracksconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the OpenLCB Daemons (Hubs and Virtual nodes) chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_TrackCircuits]

package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
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
        if {([llength $object] % 1) != 0} {
            error [_ "Not a %s type (odd list length %d): %s" $type \
                   [llength $object] $object]
        }
        foreach {code event} $object {
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
    # @arg -enabled     Whether the track is in service or not.
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
    option -enabled -readonly yes -type snit::boolean -default false
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
        # @arg -enabled     Whether the track is in service or not.
        # @arg -transmitters A list of transmitter code events.
        # @arg -transmitbaseevent The transmit base event.
        # @arg -receivebaseevent The revceive base event.
        # @arg -code1startevent The Code 1 Start event.
        # @arg -receivers   A list of receiver code events.
        # @par
        
        $self configurelist $args
        foreach {c e} [$self cget -transmitters] {
            lappend transmitters [Transmitter create %AUTO% -eventid $e -code $c]
        }
        foreach {c e} [$self cget -receivers] {
            lappend receivers [Receiver create %AUTO% -code $c -eventid $e]
        }
    }
    method myproducedevents {} {
        #** Return a list of events this track produces.
        
        ::log::log debug "*** $self myproducedevents"
        if {![$self cget -enabled]} {return {}}
        set havec1 no
        set producedevents [list]
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
        if {![$self cget -enabled]} {return {}}
        set consumedevents [list]
        foreach t $transmitters {
            set e [$t cget -eventid]
            if {$e ne {}} {
                lappend consumedevents $e
            }
        }
        foreach r $receivers {
            set c [$r cget -code]
            set e [TrackCodes EventFromCode $c [$self cget -receivebaseevent]]
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
        if {![$self cget -enabled]} {return}
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
        set conffile [from argv -configuration "tracksconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        if {$configureator} {
            $type ConfiguratorGUI $conffile
            return
        }
        set logfilename [format {%s.log} [file tail $argv0]]
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
        set nodenameele [$configuration getElementsByTagName "name"]
        if {[llength $nodenameele] > 0} {
            set nodename [[lindex $nodenameele 0] data]
        }
        set nodedescriptor ""
        set nodedescriptorele [$configuration getElementsByTagName "description"]
        if {[llength $nodedescriptorele] > 0} {
            set nodedescriptor [[lindex $nodedescriptorele 0] data]
        }
        
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
        ::log::log debug "*** $type typeconstructor: transport = $transport"
        
        foreach track [$configuration getElementsByTagName "track"] {
            set trackcommand [list $type create %AUTO%]
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set description [$track getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend trackcommand -description [[lindex $description 0] data]
            }
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set enabled [$track getElementsByTagName "enabled"]
            if {[llength $enabled] > 0} {
                lappend trackcommand -enabled true
            } else {
                lappend trackcommand -enabled false
            }
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set transmitters [list]
            foreach transmitter [$track getElementsByTagName "transmitter"] {
                set tag [$transmitter getElementsByTagName "code"]
                if {[llength $tag] != 1} {
                    ::log::logError [_ "Transmitter missing its code. skipped!"]
                    continue
                }
                set tag [lindex $tag 0]
                set code [$tag data]
                if {[catch {TrackCodes validate $code} err]} {
                    ::log::logError $err
                    continue
                }
                set tag [$transmitter getElementsByTagName "eventid"]
                if {[llength $tag] != 1} {
                    ::log::logError [_ "Transmitter missing its eventid, skipped!"]
                    continue
                }
                set tag [lindex $tag 0]
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend transmitters $code $ev
            }
            lappend trackcommand -transmitters $transmitters
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set tag [$track getElementsByTagName "transmitbaseevent"]
            if {[llength $tag] > 0} {
                set tag [lindex $tag 0]
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend trackcommand -transmitbaseevent $ev
            }
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set tag [$track getElementsByTagName "receivebaseevent"]
            if {[llength $tag] > 0} {
                set tag [lindex $tag 0]
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend trackcommand -receivebaseevent $ev
            }
            set tag [$track getElementsByTagName "code1startevent"]
            if {[llength $tag] > 0} {
                set tag [lindex $tag 0]
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend trackcommand -code1startevent $ev
            }
            ::log::log debug "*** $type typeconstructor: trackcommand is $trackcommand"
            set receivers [list]
            foreach receiver [$track getElementsByTagName "receiver"] {
                set tag [$receiver getElementsByTagName "code"]
                if {[llength $tag] != 1} {
                    ::log::logError [_ "Receiver missing its code. skipped!"]
                    continue
                }
                set tag [lindex $tag 0]
                set code [$tag data]
                if {[catch {TrackCodes validate $code} err]} {
                    ::log::logError $err
                    continue
                }
                set tag [$receiver getElementsByTagName "eventid"]
                if {[llength $tag] != 1} {
                    ::log::logError [_ "Receiver missing its eventid, skipped!"]
                    continue
                }
                set tag [lindex $tag 0]
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend receivers $code $ev
            }
            lappend trackcommand -receivers $receivers
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
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typecomponent   tracks;# Track list
    typevariable    trackcount 0;# Track count
    
    typevariable status {};# Status line
    typevariable conffilename {};# Configuration File Name
    
    #** Menu.
    typevariable _menu {
        "[_m {Menu|&File}]" {file:menu} {file} 0 {
            {command "[_m {Menu|File|&Save and Exit}]" {file:saveexit} "[_ {Save and exit}]" {Ctrl s} -command "[mytypemethod _saveexit]"}
            {command "[_m {Menu|File|&Exit}]" {file:exit} "[_ {Exit}]" {Ctrl q} -command "[mytypemethod _exit]"}
        } "[_m {Menu|&Edit}]" {edit} {edit} 0 {
            {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut}}
            {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy}}
            {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear}}
        }
    }
    
    # Default (empty) XML Configuration.
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_TrackCircuits/>}
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
        
        set tracks [ScrollTabNotebook $frame.tracks]
        pack $tracks -expand yes -fill both
        foreach track [$cdi getElementsByTagName "track"] {
            $type _create_and_populate_track $track
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
        $type _create_and_populate_track $track
    }
    typemethod _create_and_populate_track {track} {
        #** Create a tab for a track and populate it.
        #
        # @param track The track XML element.
        
        incr trackcount
        set fr track$trackcount
        set f [$track attribute frame]
        if {$f eq {}} {
            set attrs [$track cget -attributes]
            lappend attrs frame $fr
            $track configure -attributes $attrs
        } else {
            set attrs [$track cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $track configure -attributes $attrs
        }
        set trkframe [ttk::frame $tracks.$fr]
        $tracks add $trkframe -text [_ "Track %d" $trackcount] -sticky news
        set description_ [LabelEntry $trkframe.description \
                          -label [_m "Label|Description"]]
        pack $description_ -fill x -expand yes
        set description [$track getElementsByTagName "description"]
        if {[llength $description] == 1} {
            $description_ configure -text [$description data]
        }
        set enabled_ [LabelComboBox $trkframe.enabled \
                      -label [_m "Label|Track Service"] \
                      -values {Disabled Enabled} \
                      -editable no]
        pack $enabled_ -fill x -expand yes
        set enabled [$track getElementsByTagName "enabled"]
        if {[llength $enabled] == 0} {
            $enabled_ set Disabled
        } else {
            $enabled_ set Enabled
        }
        set transmitters [ScrollTabNotebook $trkframe.transmitters]
        pack $transmitters -expand yes -fill both
        foreach transmitter [$track getElementsByTagName "transmitter"] {
            $type _create_and_populate_transmitter $track $transmitters $transmitter
        }
        set addtransmitter [ttk::button $trkframe.addtransmitter \
                            -text [_m "Label|Add another transmitter"] \
                            -command [mytypemethod _addblanktransmitter $track $transmitters]]
        pack $addtransmitter -fill x
        set transmitbaseevent_ [LabelEntry $trkframe.transmitbaseevent \
                                -label [_m "Label|Transmit Group Base Link"] \
                                ]
        pack $transmitbaseevent_ -fill x -expand yes
        set transmitbaseevent [$track getElementsByTagName "transmitbaseevent"]
        if {[llength $transmitbaseevent] == 1} {
            $transmitbaseevent_ configure -text [$transmitbaseevent data]
        }

        set receivebaseevent_ [LabelEntry $trkframe.receivebaseevent \
                                -label [_m "Label|Receive Group Base Link"] \
                                ]
        pack $receivebaseevent_ -fill x -expand yes
        set receivebaseevent [$track getElementsByTagName "receivebaseevent"]
        if {[llength $receivebaseevent] == 1} {
            $receivebaseevent_ configure -text [$receivebaseevent data]
        }

        set code1startevent_ [LabelEntry $trkframe.code1startevent \
                                -label [_m "Label|Upon reception of 'Code 1 Start', this event will be sent"] \
                                ]
        pack $code1startevent_ -fill x -expand yes
        set code1startevent [$track getElementsByTagName "code1startevent"]
        if {[llength $code1startevent] == 1} {
            $code1startevent_ configure -text [$code1startevent data]
        }
        set receivers [ScrollTabNotebook $trkframe.receivers]
        pack $receivers -expand yes -fill both
        foreach receiver [$track getElementsByTagName "receiver"] {
            $type _create_and_populate_receiver $track $receivers $receiver
        }
        set addreceiver [ttk::button $trkframe.addreceiver \
                            -text [_m "Label|Add another receiver"] \
                            -command [mytypemethod _addblankreceiver $track $receivers]]
        pack $addreceiver -fill x

    }
    typemethod _addblanktransmitter {track transmitters} {
        #** Create a blank transmitter.
        #
        # @param track The track frame.
        # @param transmitters The transmitters container.
        
        set transmitter [SimpleDOMElement %AUTO% -tag "transmitter"]
        $track addchild $transmitter
        set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
        $eventid setdata "00.00.00.00.00.00.00.00"
        $transmitter addchild $eventid
        set code [SimpleDOMElement %AUTO% -tag "code"]
        $code setdata "[TrackCodes CodeLabel None]"
        $transmitter addchild $code
        $type _create_and_populate_transmitter $track $transmitters $transmitter
    }
    typemethod _create_and_populate_transmitter {track transmitters transmitter} {
        #** Create and populate a transmitter.
        #
        # @param track The track frame.
        # @param transmitters The transmitters container.
        # @param transmitter The transmitter container.
        
        set tag [$transmitter getElementsByTagName "code"]
        if {[llength $tag] != 1} {
            tk_messageBox -type ok -icon warning -message [_ "Transmitter missing its code. skipped!"]
            return
        }
        set tag [lindex $tag 0]
        set code [$tag data]
        if {[catch {TrackCodes validate $code} err]} {
            tk_messageBox -type ok -icon warning -message $err
            return
        }
        set tag [$transmitter getElementsByTagName "eventid"]
        if {[llength $tag] != 1} {
            tk_messageBox -type ok -icon warning -message [_ "Transmitter missing its eventid, skipped!"]
            return
        }
        set tag [lindex $tag 0]
        set evstring [$tag data]
        set transcount 0
        incr transcount
        set fr trans$transcount
        while {[winfo exists $transmitters.$fr]} {
            incr transcount
            set fr trans$transcount
        }
        set f [$transmitter attribute frame]
        if {$f eq {}} {
            set attrs [$transmitter cget -attributes]
            lappend attrs frame $fr
            $transmitter configure -attributes $attrs
        } else {
            set attrs [$transmitter cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $transmitter configure -attributes $attrs
        }
        set xmitframe [ttk::frame $transmitters.$fr]
        $transmitters add $xmitframe -text [_ "Command %d" $transcount] -sticky news
        set eventid_ [LabelEntry $xmitframe.eventid \
                      -label [_m "Label|When this event occurs"] \
                      -text $evstring]
        pack $eventid_ -fill x -expand yes
        set code_labs [list]
        for {set c 0} {$c < 11} {incr  c} {
            lappend code_labs [TrackCodes CodeLabel [TrackCodes CodeFromValue $c]]
        }
        set code_ [LabelComboBox $xmitframe.code \
                   -label [_m "Label|the following Track Code will be sent."] \
                   -values $code_labs -editable no]
        pack $code_ -fill x -expand yes
        $code_ set [lindex $code_labs [TrackCodes CodeValue $code]]
        set del [ttk::button $xmitframe.delete \
                 -text [_m "Label|Delete Transmitter"] \
                 -command [mytypemethod _deletexmit $transmitters $track $transmitter]]
        pack $del -fill x
    }
    typemethod _deletexmit {transmitters track transmitter} {
        #** Delete a transmitter.
        #
        # @param transmitters The Transmitters container.
        # @param track The track frame.
        # @param transmitter The transmitter container.
        
        set fr [$transmitter attribute frame]
        $track removeChild $transmitter
        $transmitters forget $transmitters.$fr
    }

    typemethod _addblankreceiver {track receivers} {
        #** Create a blank receiver.
        #
        # @param track The track frame.
        # @param receivers The receivers container.
        
        set receiver [SimpleDOMElement %AUTO% -tag "receiver"]
        $track addchild $receiver
        set code [SimpleDOMElement %AUTO% -tag "code"]
        $code setdata "[TrackCodes CodeLabel None]"
        $receiver addchild $code
        set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
        $eventid setdata "00.00.00.00.00.00.00.00"
        $receiver addchild $eventid
        $type _create_and_populate_receiver $track $receivers $receiver
    }
    typemethod _create_and_populate_receiver {track receivers receiver} {
        #** Create and populate a receiver.
        #
        # @param track The track frame.
        # @param receivers The receivers container.
        # @param receiver The receiver container.
        
        set tag [$receiver getElementsByTagName "code"]
        if {[llength $tag] != 1} {
            tk_messageBox -type ok -icon warning -message [_ "Receiver missing its code. skipped!"]
            return
        }
        set tag [lindex $tag 0]
        set code [$tag data]
        if {[catch {TrackCodes validate $code} err]} {
            tk_messageBox -type ok -icon warning -message $err
            return
        }
        set tag [$receiver getElementsByTagName "eventid"]
        if {[llength $tag] != 1} {
            tk_messageBox -type ok -icon warning -message [_ "Receiver missing its eventid, skipped!"]
            return
        }
        set tag [lindex $tag 0]
        set evstring [$tag data]
        set transcount 0
        incr transcount
        set fr recv$transcount
        while {[winfo exists $receivers.$fr]} {
            incr transcount
            set fr recv$transcount
        }
        set f [$receiver attribute frame]
        if {$f eq {}} {
            set attrs [$receiver cget -attributes]
            lappend attrs frame $fr
            $receiver configure -attributes $attrs
        } else {
            set attrs [$receiver cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $receiver configure -attributes $attrs
        }
        set recvframe [ttk::frame $receivers.$fr]
        $receivers add $recvframe -text [_ "Action %d" $transcount] -sticky news
        set code_labs [list]
        for {set c 0} {$c < 11} {incr  c} {
            lappend code_labs [TrackCodes CodeLabel [TrackCodes CodeFromValue $c]]
        }
        set code_ [LabelComboBox $recvframe.code \
                   -label [_m "Label|Upon reception of this Track Code"] \
                   -values $code_labs -editable no]
        pack $code_ -fill x -expand yes
        $code_ set [lindex $code_labs [TrackCodes CodeValue $code]]
        set eventid_ [LabelEntry $recvframe.eventid \
                      -label [_m "Label|this event will be sent"] \
                      -text $evstring]
        pack $eventid_ -fill x -expand yes
        set del [ttk::button $recvframe.delete \
                 -text [_m "Label|Delete Receiver"] \
                 -command [mytypemethod _deleterecv $receivers $track $receiver]]
        pack $del -fill x
    }
    typemethod _deleterecv {receivers track receiver} {
        #** Delete a receiver.
        #
        # @param receivers The receivers container.
        # @param track The track frame.
        # @param receiver The receiver container.
        
        set fr [$receiver attribute frame]
        $track removeChild $receiver
        $receivers forget $receivers.$fr
    }

    typemethod _saveexit {} {
        #** Save and exit.  Bound to the Save & Exit file menu item.
        # Saves the contents of the GUI as an XML file.
        
        set cdis [$configuration getElementsByTagName OpenLCB_TrackCircuits -depth 1]
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
        foreach track [$cdi getElementsByTagName "track"] {
            $type _copy_from_gui_to_XML $track
        }
        
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
        }
        ::exit
    }
    typemethod _copy_from_gui_to_XML {track} {
        #** Copy from the GUI to the track XML
        # 
        # @param track Track XML element.
        
        set fr [$track attribute frame]
        set frbase $tracks.$fr
        set description_ [$frbase.description get]
        if {$description_ eq ""} {
            set description [$track getElementsByTagName "description"]
            if {[llength $description] == 1} {
                $track removeChild $description
            }
        } else {
            set description [$track getElementsByTagName "description"]
            if {[llength $description] < 1} {
                set description [SimpleDOMElement %AUTO% -tag "description"]
                $track addchild $description
            }
            $description setdata $description_
        }
        set enabled_ [$frbase.enabled get]
        switch $enabled_ {
            Disabled {
                set enabled [$track getElementsByTagName "enabled"]
                if {[llength $enabled] > 0} {
                    $track removeChild $enabled
                }
            }
            Enabled {
                set enabled [$track getElementsByTagName "enabled"]
                if {[llength $enabled] < 1} {
                    set enabled [SimpleDOMElement %AUTO% -tag "enabled"]
                    $track addchild $enabled
                }
            }
        }
        set transmitters $frbase.transmitters
        foreach transmitter [$track getElementsByTagName "transmitter"] {
            set codetag [$transmitter getElementsByTagName "code"]
            set eventidtag [$transmitter getElementsByTagName "eventid"]
            set fr [$transmitter attribute frame]
            set xmitframe $transmitters.$fr
            $eventidtag setdata "[$xmitframe.eventid get]"
            set cvals [$xmitframe.code cget -values]
            set cval  [lsearch -exact $cvals [$xmitframe.code get]]
            $codetag setdata [TrackCodes CodeFromValue $cval]
        }
        
        set transmitbaseevent_ [$frbase.transmitbaseevent get]
        if {$transmitbaseevent_ eq "00.00.00.00.00.00.00.00" ||
            $transmitbaseevent_ eq ""} {
            set transmitbaseevent [$track getElementsByTagName "transmitbaseevent"]
            if {[llength $transmitbaseevent] == 1} {
                $track removeChild $transmitbaseevent
            }
        } else {
            set transmitbaseevent [$track getElementsByTagName "transmitbaseevent"]
            if {[llength $transmitbaseevent] < 1} {
                set transmitbaseevent [SimpleDOMElement %AUTO% -tag "transmitbaseevent"]
                $track addchild $transmitbaseevent
            }
            $transmitbaseevent setdata $transmitbaseevent_
        }
        
        set receivebaseevent_ [$frbase.receivebaseevent get]
        if {$receivebaseevent_ eq "00.00.00.00.00.00.00.00" ||
            $receivebaseevent_ eq ""} {
            set receivebaseevent [$track getElementsByTagName "receivebaseevent"]
            if {[llength $receivebaseevent] == 1} {
                $track removeChild $receivebaseevent
            }
        } else {
            set receivebaseevent [$track getElementsByTagName "receivebaseevent"]
            if {[llength $receivebaseevent] < 1} {
                set receivebaseevent [SimpleDOMElement %AUTO% -tag "receivebaseevent"]
                $track addchild $receivebaseevent
            }
            $receivebaseevent setdata $receivebaseevent_
        }
        
        set code1startevent_ [$frbase.code1startevent get]
        if {$code1startevent_ eq "00.00.00.00.00.00.00.00" ||
            $code1startevent_ eq ""} {
            set code1startevent [$track getElementsByTagName "code1startevent"]
            if {[llength $code1startevent] == 1} {
                $track removeChild $code1startevent
            }
        } else {
            set code1startevent [$track getElementsByTagName "code1startevent"]
            if {[llength $code1startevent] < 1} {
                set code1startevent [SimpleDOMElement %AUTO% -tag "code1startevent"]
                $track addchild $code1startevent
            }
            $code1startevent setdata $code1startevent_
        }
        
        set receivers $frbase.receivers
        foreach receiver [$track getElementsByTagName "receiver"] {
            set codetag [$receiver getElementsByTagName "code"]
            set eventidtag [$receiver getElementsByTagName "eventid"]
            set fr [$receiver attribute frame]
            set recvframe $receivers.$fr
            $eventidtag setdata "[$recvframe.eventid get]"
            set cvals [$recvframe.code cget -values]
            set cval  [lsearch -exact $cvals [$recvframe.code get]]
            $codetag setdata [TrackCodes CodeFromValue $cval]
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
    
}


vwait forever
