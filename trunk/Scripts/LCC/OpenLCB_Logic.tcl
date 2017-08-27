#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Aug 25 14:52:47 2016
#  Last Modified : <170826.2057>
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


## @page OpenLCB_Logic OpenLCB Logic node
# @brief OpenLCB Logic node
#
# @section LogicSYNOPSIS SYNOPSIS
#
# OpenLCB_Logic [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section LogicDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for one or 
# more Logic Element (much like the logic elements coded in the RR
# Cirkits Tower-LCC nodes).  
#
# Each logic element has two variable inputs, variable 1 and variable 2, which 
# can be set to true or false using LCC events.  There are seven (7) boolean 
# operators: @b and, @b or, @b xor, @b and @b change, @b or @b change, 
# @b variable @b 1 @b then @b variable @b 2, and @b constant @b true.  Logic 
# elements can be either single, or part of a group.  There are two group 
# types, mast and ladder.  A mast group is always evaluated from top to bottom 
# and terminates at the first true result which produces an action.  A ladder 
# group is evaluated from the triggered logic to the bottom and all true 
# results result in actions.  Actions consist of up to four events being 
# produced, either right away or after a delay.  The actions can be 
# retriggerable or not.
#
# @section LogicPARAMETERS PARAMETERS
#
# none
#
# @section LogicOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_Logic.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is logicconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section LogicCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section LogicAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_Logic]

package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::type Logic {
    #** Logic type.

    pragma -hastypeinfo no -hastypedestroy no -hasinstances no
    
    typevariable logiclabels -array {}
    
    typeconstructor {
        #** Type constructor: initialize variables.
        
        set logiclabels(and)   [_m "Label|V1 and V2"]
        set logiclabels(or)    [_m "Label|V1 or V2"]
        set logiclabels(xor)   [_m "Label|V1 xor V2"]
        set logiclabels(andch) [_m "Label|V1 and V2 change"]
        set logiclabels(orch)  [_m "Label|V1 or V2 change"]
        set logiclabels(then)  [_m "Label|V1 then V2"]
        set logiclabels(true)  [_m "Label|true"]
    }
    typemethod validate {object} {
        if {[lsearch [array names logiclabels] $object] < 0} {
            error [_ "Not a Logic: %s" $object]
        }
        return $object
    }
    typemethod AllLogicLabels {} {
        set labs [list]
        foreach l {and or xor andch orch then true} {
            lappend labs [$type LogicLabel $l]
        }
        return $labs
    }
    
    typemethod LogicLabel {object} {
        #** Return a Logic's label (used for UI purposes, etc.).
        #
        # @param object The object to return a label for.
        # @return The Logic's user friendly label. 
        #
        
        $type validate $object
        return $logiclabels($object)
    }
    typemethod LogicFromLabel {label} {
        foreach l [array names logiclabels] {
            if {"$label" eq "$logiclabels($l)"} {
                return $l
            }
        }
        return and
    }
}

snit::type GroupType {
    #** Group type.
    
    pragma -hastypeinfo no -hastypedestroy no -hasinstances no
    
    typevariable grouplabels -array {}
    
    typeconstructor {
        #** Type constructor: initialize variables.  
        
        set grouplabels(mast)   [_m "Label|Mast Group"]
        set grouplabels(ladder) [_m "Label|Ladder Group"]
        set grouplabels(single) [_m "Label|Single or Last"]
    }
    typemethod validate {object} {
        if {[lsearch [array names grouplabels] $object] < 0} {
            error [_ "Not a GroupType: %s" $object]
        }
        return $object
    }
    typemethod AllGroupTypeLabels {} {
        set labs [list]
        foreach g {single mast ladder} {
            lappend labs [$type GroupTypeLabel $g]
        }
        return $labs
    }
    
    typemethod GroupTypeLabel {object} {
        #** Return a GroupType's label (used for UI purposes, etc.).
        #
        # @param object The object to return a label for.
        # @return The GroupType's user friendly label. 
        #
        
        $type validate $object
        return $grouplabels($object)
    }
    typemethod GroupTypeFromLabel {label} {
        foreach g [array names grouplabels] {
            if {"$label" eq "$grouplabels($g)"} {
                return $g
            }
        }
        return single
    }
}

snit::type OpenLCB_Logic_or_null {
    
    pragma -hastypeinfo no -hastypedestroy no -hasinstances no
    
    typemethod validate {object} {
        if {$object eq {}} {
            return $object
        } else {
            return [OpenLCB_Logic validate $object]
        }
    }
}


snit::type OpenLCB_Logic {
    
    option -v1oneventid -type lcc::EventID_or_null -readonly yes -default {}
    option -v1offeventid -type lcc::EventID_or_null -readonly yes -default {}
    variable v1 false
    option -v2oneventid -type lcc::EventID_or_null -readonly yes -default {}
    option -v2offeventid -type lcc::EventID_or_null -readonly yes -default {}
    variable v2 false
    
    option -grouptype -type GroupType -default single
    option -logic     -type Logic     -readonly yes -default and
    
    variable lasteval false
    variable triggeredstate false
    
    option -previous  -type OpenLCB_Logic_or_null -default {}
    option -next      -type OpenLCB_Logic_or_null -default {}
    
    option -delay     -type {snit::integer -min 0} -readonly yes -default 0
    option -retriggerable -type snit::boolean -readonly yes -default false
    
    option -action1eventid -type lcc::EventID_or_null -readonly yes -default {}
    option -action2eventid -type lcc::EventID_or_null -readonly yes -default {}
    option -action3eventid -type lcc::EventID_or_null -readonly yes -default {}
    option -action4eventid -type lcc::EventID_or_null -readonly yes -default {}
    
    option -action1delay   -type snit::boolean -readonly yes -default false
    option -action2delay   -type snit::boolean -readonly yes -default false
    option -action3delay   -type snit::boolean -readonly yes -default false
    option -action4delay   -type snit::boolean -readonly yes -default false
    
    variable action1did {}
    variable action2did {}
    variable action3did {}
    variable action4did {}
    
    variable lastval false
    option -description -readonly yes -default {}
    
    constructor {args} {
        #** Construct one logic element
        #
        # @param ... Options:
        # @arg -description Description (name) of the logic.
        # @arg -v1oneventid V1 on eventid
        # @arg -v1offeventid V1 off eventid
        # @arg -v2oneventid V2 on eventid
        # @arg -v2offeventid V2 off eventid
        # @arg -grouptype Group type
        # @arg -logic Logic function
        # @arg -previous Previous in group
        # @arg -next Next in group
        # @arg -delay Delay
        # @arg -retriggerable Regrigerable?
        # @arg -action1eventid Action 1 eventid
        # @arg -action2eventid Action 2 eventid
        # @arg -action3eventid Action 3 eventid
        # @arg -action4eventid Action 4 eventid
        # @arg -action1delay Action 1 delay?
        # @arg -action2delay Action 2 delay?
        # @arg -action3delay Action 3 delay?
        # @arg -action4delay Action 4 delay?
        # @par
        
        $self configurelist $args
    }
    method myconsumedevents {} {
        set events [list]
        foreach eopt {-v1oneventid -v1offeventid -v2oneventid -v2offeventid} {
            set ev [$self cget $eopt]
            if {$ev eq {}} {continue}
            lappend events $ev
        }
        return $events
    }
    method myproducedevents {} {
        set events [list]
        foreach eopt {-action1eventid -action2eventid -action3eventid -action4eventid} {
            set ev [$self cget $eopt]
            if {$ev eq {}} {continue}
            lappend events $ev
        }
        return $events
    }
    method evalFunction {event} {
        ::log::log debug "*** $self ([$self cget -description]) ([$self cget -description]) evalFunction [$event cget -eventidstring]"
        set result false
        set eopt {}
        foreach evopt {v1oneventid v1offeventid v2oneventid v2offeventid} {
            set ev [$self cget -$evopt]
            if {$ev eq {}} {continue}
            if {[$ev match $event]} {
                set eopt $evopt
                break
            }
        }
        switch [$self cget -logic] {
            and {
                if {$v1 && $v2} {
                    set result true
                    set lastval true
                } else {
                    set lastval false
                }
            }
            or {
                if {$v1 || $v2} {
                    set result true
                    set lastval true
                } else {
                    set lastval false
                }
            }
            xor {
                if {($v1 || $v2) && !($v1 && $v2)} {
                    set result true
                    set lastval true
                } else {
                    set lastval false
                }
            }
            andch {
                if {($v1 && $v2) && !$lastval} {
                    set result true
                    set lastval true
                } else {
                    set lastval false
                }
            }
            orch {
                if {($v1 || $v2) && !$lastval} {
                    set result true
                    set lastval true
                } else {
                    set lastval false
                }
            }
            then {
                if {($v1 && $v2) && $eopt eq "v2oneventid"} {
                    set result true
                    set lastval true
                } else {
                    set lastval false
                }
            }
            true {
                set result true
                set lastval true
            }
        }
        return $result
    }
    method processevent {event} {
        ::log::log debug "*** $self ([$self cget -description]) processevent [$event cget -eventidstring]"
        set triggeredstate false
        set ematch false
        foreach eopt {v1oneventid v1offeventid v2oneventid v2offeventid} {
            ::log::log debug "*** $self ([$self cget -description]) processevent: eopt is $eopt"
            set ev [$self cget -$eopt]
            if {$ev eq {}} {continue}
            ::log::log debug "*** $self ([$self cget -description]) processevent: ev is [$ev cget -eventidstring]"
            if {[$ev match $event]} {
                ::log::log debug "*** $self ([$self cget -description]) processevent: [$ev cget -eventidstring] matches [$event cget -eventidstring]"
                switch $eopt {
                    v1oneventid {
                        if {!$v1} {set triggeredstate true}
                        set v1 true
                    }
                    v1offeventid {
                        if {$v1} {set triggeredstate true}
                        set v1 false
                    }
                    v2oneventid {
                        if {!$v2} {set triggeredstate true}
                        set v2 true
                    }
                    v2offeventid {
                        if {$v2} {set triggeredstate true}
                        set v2 false
                    }
                }
                set ematch true
                ::log::log debug "*** $self ([$self cget -description]) processevent (event match): v1 = $v1, v2 = $v2"
                ::log::log debug "*** $self ([$self cget -description]) processevent (event match): -logic is [$self cget -logic]"
                ::log::log debug "*** $self ([$self cget -description]) processevent (event match): triggeredstate = $triggeredstate"
            }
        }
        ::log::log debug "*** $self ([$self cget -description]) processevent: ematch is $ematch"
        if {!$ematch} {return}
        ::log::log debug "*** $self ([$self cget -description]) processevent: -grouptype is [$self cget -grouptype]"
        switch [$self cget -grouptype] {
            single {
                if {[$self evalFunction $event]} {$self processActions}
            }
            mast {
                $self processPreviousMast $event
            }
            ladder {
                $self processLadder $event
            }
        }
    }
    method processPreviousMast {event} {
        ::log::log debug "*** $self ([$self cget -description]) processPreviousMast $event"
        ::log::log debug "*** $self ([$self cget -description]) processPreviousMast: -previous is [$self cget -previous]"
        if {[$self cget -previous] ne {}} {
            [$self cget -previous] processPreviousMast $event
        } else {
            $self processMast $event
        }
    }
    method processMast {event} {
        ::log::log debug "*** $self ([$self cget -description]) ([$self cget -description]) processMast $event"
        ::log::log debug "*** $self ([$self cget -description]) processMast: -next is [$self cget -next]"
        if {[$self evalFunction $event]} {
            $self processActions
        } elseif {[$self cget -next] ne {}} {
            [$self cget -next] processMast $event
        }
    }
    method processLadder {event} {
        ::log::log debug "*** $self ([$self cget -description]) processLadder $event"
        if {[$self evalFunction $event]} {
            $self processActions
        }
        ::log::log debug "*** $self ([$self cget -description]) processLadder: -next is [$self cget -next]"
        if {[$self cget -next] ne {}} {
            [$self cget -next] processLadder $event
        }
    }
    method processActions {} {
        set thedelay [$self cget -delay]
        set retrig   [$self cget -retriggerable]
        foreach a {1 2 3 4} {
            set eventid  [$self cget -action${a}eventid]
            if {$eventid eq {}} {continue}
            set delayedP [$self cget -action${a}delay]
            set did      [set action${a}did]
            if {$thedelay > 0 && $delayedP} {
                if {$retrig && $did ne {}} {
                    after cancel $did
                } elseif {$did ne {}} {
                    continue
                }
                set action${a}did [after $thedelay [mymethod senddelayedevent $eventid $a]]
            } else {
                $type sendevent $eventid
            }
        }
    }
    method senddelayedevent {eventid a} {
        set action${a}did {}
        $type sendevent $eventid
    }
    
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  alllogics [list];#  All logics
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  eventsproduced {};# Events produced.
    typecomponent editContextMenu
    typecomponent xmllogicconfig;# Common logic config object
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages logic elements.
        
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
        set conffile [from argv -configuration "logicsconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmllogicconfig [XmlConfiguration create %AUTO% {
                            <configure>
                            <string tagname="description" option="-description">Description</string>
                            <eventid tagname="v1oneventid" option="-v1oneventid">Set variable #1 true.</eventid>
                            <eventid tagname="v1offeventid" option="-v1offeventid">Set variable #1 false.</eventid>
                            <eventid tagname="v2oneventid" option="-v2oneventid">Set variable #2 true.</eventid>
                            <eventid tagname="v2offeventid" option="-v2offeventid">Set variable #2 false.</eventid>
                            <enum tagname="grouptype" option="-grouptype" enums="mast ladder single" default="single">Group Type</enum>
                            <enum tagname="logicfunction" option="-logic" enums="and or xor andch orch then true" default="and">Logic Function</enum>
                            <int tagname="delay" option="-delay" min="0">Delay Period, miliseconds</int>
                            <boolean tagname="retriggerable" option="-retriggerable">Retriggerable?</boolean>
                            <boolean tagname="action1delay" option="-action1delay">Action 1 Delay?</boolean>
                            <eventid tagname="action1eventid" option="-action1eventid">Action 1 Send Event:</eventid>
                            <boolean tagname="action2delay" option="-action2delay">Action 2 Delay?</boolean>
                            <eventid tagname="action2eventid" option="-action2eventid">Action 2 Send Event:</eventid>
                            <boolean tagname="action3delay" option="-action3delay">Action 3 Delay?</boolean>
                            <eventid tagname="action3eventid" option="-action3eventid">Action 3 Send Event:</eventid>
                            <boolean tagname="action4delay" option="-action4delay">Action 4 Delay?</boolean>
                            <eventid tagname="action4eventid" option="-action4eventid">Action 4 Send Event:</eventid>
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
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB Logic Elements" \
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
        
        set previous {}
        set previousGroup single
        foreach logic [$configuration getElementsByTagName "logic"] {
            set logiccommand [$xmllogicconfig processConfig $logic [list $type create %AUTO%]]
            ::log::log debug "*** $type typeconstructor: logiccommand is $logiccommand"
            set logic [eval $logiccommand]
            ::log::log debug "*** $type typeconstructor: logic is $logic"
            if {$previousGroup ne "single"} {
                $logic configure -previous $previous
                $previous configure -next $logic
                $logic configure -grouptype $previousGroup
            }
            set group [$logic cget -grouptype]
            if {$group ne "single"} {
                set previous $logic
            }
            set previousGroup $group
            foreach pev [$logic myproducedevents] {
                lappend eventsproduced $pev
            }
            ::log::log debug "*** $type typeconstructor: eventsproduced is $eventsproduced"
            foreach cev [$logic myconsumedevents] {
                lappend eventsconsumed $cev
            }
            ::log::log debug "*** $type typeconstructor: eventsconsumed is $eventsconsumed"
            lappend alllogics $logic
            ::log::log debug "*** $type typeconstructor: alllogics is $alllogics"
        }
        if {[llength $alllogics] == 0} {
            ::log::logError [_ "No logics specified!"]
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
        #** Send an event.  First the event is passed to each logic circuit to 
        # see if it is of local interest.  Then it is sent out on the network.
        #
        # @param event The event to send.
        
        $transport ProduceEvent $event
        foreach logic $alllogics {
            $logic processevent $event
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
                    foreach l $alllogics {
                        $l processevent $eventid
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
                foreach l $alllogics {
                    ::log::log debug "*** $type _eventHandler: logic is [$l cget -description]"
                    ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $l processevent $eventid
                    
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
    typemethod validate {object} {
        if {[catch {$object info type} otype]} {
            error [_ "Not an OpenLCB_Logic: %s!", $object]
        } elseif {$otype ne $type} {
            error [_ "Not an OpenLCB_Logic: %s!", $object]
        } else {
            return $object
        }
    }
        
    #*** Configuration GUI
    
    typecomponent main;# Main Frame.
    typecomponent scroll;# Scrolled Window.
    typecomponent editframe;# Scrollable Frame
    typecomponent   generateEventID
    typecomponent   logics;# logic list
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
            {command "[_m {Menu|Help|EventExchange node for logic blocks}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for logic blocks"}}
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_Logic/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_Logic -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set logic [SimpleDOMElement %AUTO% -tag "logic"]
        $cdi addchild $logic
        set description [SimpleDOMElement %AUTO% -tag "description"]
        $logic addchild $description
        $description setdata "Sample Logic"
        set grouptype [SimpleDOMElement %AUTO% -tag "grouptype"]
        $logic addchild $grouptype
        $grouptype setdata single
        foreach eventtag {v1onevent v1offevent} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $logic addchild $tagele
            $tagele setdata [$generateEventID nextid]
        }
        set logicfunction [SimpleDOMElement %AUTO% -tag "logicfunction"]
        $logic addchild $logicfunction
        $logicfunction setdata and
        foreach eventtag {v2onevent v2offevent} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $logic addchild $tagele
            $tagele setdata [$generateEventID nextid]
        }
        set delay [SimpleDOMElement %AUTO% -tag "delay"]
        $logic addchild $delay
        $delay setdata 0
        set retriggerable [SimpleDOMElement %AUTO% -tag "retriggerable"]
        $logic addchild $retriggerable
        $retriggerable setdata false
        foreach a {1 2 3 4} {
            set event [SimpleDOMElement %AUTO% -tag [format {action%devent} $a]]
            $logic addchild $event
            $event setdata [$generateEventID nextid]
            set delay [SimpleDOMElement %AUTO% -tag [format {action%ddelay} $a]]
            $logic addchild $delay
            $delay setdata false
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
        set cdis [$configuration getElementsByTagName OpenLCB_Logic -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_Logic in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_Logic Configuration Editor (%s)" $conffile]
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
        $xmllogicconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
        set logics [ScrollTabNotebook $frame.tracks]
        pack $logics -expand yes -fill both
        foreach logic [$cdi getElementsByTagName "logic"] {
            set logicframe [$xmllogicconfig createGUI $logics logic \
                            $cdi $logic [_m "Label|Delete Logic"] \
                            [mytypemethod _addframe] \
                            [mytypemethod _delframe]]
        }
        set addlogic [ttk::button $frame.addlogic \
                      -text [_m "Label|Add another logic"] \
                      -command [mytypemethod _addblanklogic]]
        pack $addlogic -fill x
    }

    typemethod _addblanklogic {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Logic -depth 1]
        set cdi [lindex $cdis 0]
        set logic [SimpleDOMElement %AUTO% -tag "logic"]
        $cdi addchild $logic
        set logicframe [$xmllogicconfig createGUI $logics logic \
                        $cdi $logic [_m "Label|Delete Logic"] \
                        [mytypemethod _addframe] \
                        [mytypemethod _delframe]]
    }
    typemethod _delframe {frame} {
        $logics forget $frame
    }
    typemethod _addframe {parent frame count} {
        $parent add $frame -text [_m "LABEL|Logic %d" $count] -sticky news
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
        set cdis [$configuration getElementsByTagName OpenLCB_Logic -depth 1]
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
        foreach logic [$cdi getElementsByTagName "logic"] {
            $xmllogicconfig copyFromGUI $logics $logic warnings
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

