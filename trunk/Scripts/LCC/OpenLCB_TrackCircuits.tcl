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
#  Last Modified : <160810.1548>
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
        
        if {[lsearch [array names codevalues] $object] < 0} {
            error [_ "Not a %s: %s" $type $object]
        }
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
        if {[info exists valuemap($index)]} {
            return $valuemap($index)
        } else {
            return {}
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
    
    option -eventid lcc::EventID_or_null -readonly yes -default {}
    option -code TrackCodes -readonly yes -default {None}
    
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
    
    option -code TrackCodes -readonly yes -default {None}
    option -eventid lcc::EventID_or_null -readonly yes -default {}
    
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
    # @arg -transmiters A list of transmitter code events.
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
    option -transmiters -readonly yes -default {} -type CodeEventList
    option -transmitbaseevent -readonly yes -default {} -type lcc::EventID_or_null
    option -receivebaseevent -readonly yes -default {} -type lcc::EventID_or_null
    option -code1startevent -readonly yes -default {} -type lcc::EventID_or_null
    option -receivers -readonly yes -default {} -type CodeEventList
    
    constructor {args} {
        $self configurelist $args
        foreach {c e} [$self cget -transmiters] {
            lappend transmitters [Transmitter create %AUTO% -eventid $e -code $c]
        }
        foreach {c e} [$self cget -receivers] {
            lappend receivers [Receiver create %AUTO% -code $c -eventid $e]
        }
    }
    method myproducedevents {} {
        if {![$self cget -enabled]} {return {}}
        set havec1 no
        set producedevents [list]
        foreach t $transmitters {
            set code [$t cget -code]
            if {$code eq "None"} {continue}
            set codeevent [TrackCodes EventFromCode $code [$self cget -transmitbaseevent]]
            lappend producedevents $codeevent
        }
        foreach r $receivers {
            set code [$r cget -code]
            set e    [$r cget -eventid]
            lappend producedevents $e
            if {!$havec1 && [TrackCodes CodeNeedsStart $c]} {
                lappend producedevents [$self cget -code1startevent]
            }
        }
        return $producedevents
    }
    method myconsumedevents {} {
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
            set e [TrackCodes EventFromCode $code [$self cget -receivebaseevent]]
            lappend consumedevents $e
        }
        return $consumedevents
    }
    method processevent {event} {
        if {![$self cget -enabled]} {return}
        foreach t $transmitters {
            set code [$t processevent $event]
            if {$code eq "None"} {continue}
            set codeevent [TrackCodes EventFromCode $code [$self cget -transmitbaseevent]]
            $type sendevent $codeevent
            $codeevent destroy

        }
        set code [TrackCodes CodeFromEvent [$self cget -receivebaseevent] $event]
        if {$code ne {}} {
            foreach r $receivers {
                set event [$r processcode $code]
                if {$event ne {}} {
                    if {[TrackCodes CodeNeedsStart $code]} {
                        set e [$self cget -code1startevent]
                        if {$e ne {}} {
                            $type sendevent $e
                        }
                    }
                    $type sendevent $event
                }
            }
        }
    }
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable alltracks [list];#   All tracks
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  eventsproduced {};# Events produced.
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages MRD2 devices, consuming or producing
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
        set configureator no
        set configureIdx [lsearch -exact $argv -configure]
        if {$configureIdx >= 0} {
            set configureator yes
            set argv [lreplace $argv $configureIdx $configureIdx]
        }
        set conffile [from argv -configuration "tracksconf.xml"]
        ::log::log debug "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        if {$configureator} {
            $type ConfiguratorGUI $conffile
            return
        }
        
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
        
        foreach track [$configuration getElementsByTagName "track"] {
            set trackcommand [list $type create %AUTO%]
            set description [$track getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend trackcommand -description [[lindex $description 0] data]
            }
            set enabled [$track getElementsByTagName "enabled"]
            if {[llength $enabled] > 0} {
                lappend trackcommand -enabled true
            } else {
                lappend trackcommand -enabled false
            }
            set transmitters [list]
            foreach transmitter [$track getElementsByTagName "transmitter"] {
                set tag [$transmitter getElementsByTagName "code"]
                if {[llength $tag] != 1} {
                    ::log::logError [_ "Transmitter missing its code. skipped!"]
                    continue
                }
                set tag [lindex $tag 0]
                set code [$tag data]
                if {[catch [TrackCodes validate $code] err]} {
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
            set tag [$track getElementsByTagName "transmitbaseevent"]
            if {[llength $tag] > 0} {
                set tag [lindex $tag 0]
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend trackcommand -transmitbaseevent $ev
            }
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
            set receivers [list]
            foreach receiver [$track getElementsByTagName "receiver"] {
                set tag [$receiver getElementsByTagName "code"]
                if {[llength $tag] != 1} {
                    ::log::logError [_ "Receiver missing its code. skipped!"]
                    continue
                }
                set tag [lindex $tag 0]
                set code [$tag data]
                if {[catch [TrackCodes validate $code] err]} {
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
            set track [eval $trackcommand]
            foreach pev [$track myproducedevents] {
                lappend eventsproduced $pev
            }
            foreach cev [$track myconsumedevents] {
                lappend eventsconsumed $cev
            }
            lappend alltracks $track
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
        foreach track $alltracks {
            $track processevent $event
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
    
    
    
        
}


vwait forever
