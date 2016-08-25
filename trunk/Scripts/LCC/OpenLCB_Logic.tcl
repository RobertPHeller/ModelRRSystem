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
#  Last Modified : <160825.1653>
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
# OpenLCB_Logic [-configure] [-debug] [-configuration confgile]
#
# @section LogicDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for one or 
# more Logic Element (much like the logic elements coded in the RR
# Cirkits Tower-LCC nodes).  
#
# @section LogicPARAMETERS PARAMETERS
#
# none
#
# @section LogicOPTIONS OPTIONS
#
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is logicconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section CONFIGURATION CONFIGURATION
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
    typemethod LogicLabel {object} {
        #** Return a Logic's label (used for UI purposes, etc.).
        #
        # @param object The object to return a label for.
        # @return The Logic's user friendly label. 
        #
        
        $type validate $object
        return $logiclabels($object)
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
    typemethod GroupTypeLabel {object} {
        #** Return a GroupType's label (used for UI purposes, etc.).
        #
        # @param object The object to return a label for.
        # @return The GroupType's user friendly label. 
        #
        
        $type validate $object
        return $grouplabels($object)
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
    
    option -grouptype -type GroupType -readonly yes -default single
    option -logic     -type Logic     -readonly yes -default and
    
    variable lasteval false
    variable triggeredstate false
    
    option -previous  -type OpenLCB_Logic_or_null -default {}
    option -next      -type OpenLCB_Logic_or_null -default {}
    
    option -delay     -type {snit::integer -min 0} -readonly yes -default 0
    option -retrigerable -type snit::boolean -readonly yes -default false
    
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
    
    option -description -readonly yes -default {}
    
    constructor {args} {
        #** Construct one logic element
        #
        # @param ... Options:
        # @arg -description Description (name) of the track.
        # @arg -v1oneventid V1 on eventid
        # @arg -v1offeventid V1 off eventid
        # @arg -v2oneventid V2 on eventid
        # @arg -v2offeventid V2 off eventid
        # @arg -grouptype Group type
        # @arg -logic Logic function
        # @arg -previous Previous in group
        # @arg -next Next in group
        # @arg -delay Delay
        # @arg -retrigerable Regrigerable?
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
    method processevent {event} {
        foreach eopt {v1oneventid v1offeventid v2oneventid v2offeventid} {
            set ev [$self cget -$eopt]
            if {$ev eq {}} {continue}
            if {[$ev match $event]} {
                switch $eopt {
                    v1oneventid {
                        set v1 true
                    }
                    v1offeventid {
                        set v1 false
                    }
                    v2oneventid {
                        set v2 true
                    }
                    v2offeventid {
                        set v2 false
                    }
                }
                set triggeredstate false
                switch [$self cget -logic] {
                    and {
                        if {$v1 && $v2} {
                            set triggeredstate true
                            set lastval true
                        } else {
                            set lastval false
                        }
                    }
                    or {
                        if {$v1 || $v2} {
                            set triggeredstate true
                            set lastval true
                        } else {
                            set lastval false
                        }
                    }
                    xor {
                        if {($v1 || $v2) && !($v1 && $v2)} {
                            set triggeredstate true
                            set lastval true
                        } else {
                             set lastval false
                        }
                    }
                    andch {
                        if {($v1 && $v2) && !$lastval} {
                            set triggeredstate true
                            set lastval true
                        } else {
                            set lastval false
                        }
                    }
                    orch {
                        if {($v1 || $v2) && !$lastval} {
                            set triggeredstate true
                            set lastval true
                        } else {
                            set lastval false
                        }
                    }
                    then {
                        if {($v1 && $v2) && eopt eq "v2oneventid"} {
                            set triggeredstate true
                            set lastval true
                        } else {
                            set lastval false
                        }
                    }
                    true {
                        set triggeredstate true
                        set lastval true
                    }
                }
            }
        }
        switch [$self cget -grouptype] {
            single {
                if {$triggeredstate} {
                    $self processActions
                }
            }
            mast {
                if {[$self cget -previous] ne {}} {
                    [$self cget -previous] processPreviousMast
                } else {
                    $self processMast
                }
            }
            ladder {
                $self processLadder
            }
        }
    }
    method processPreviousMast {} {
        if {[$self cget -previous] ne {}} {
            [$self cget -previous] processPreviousMast
        } else {
            $self processMast
        }
    }
    method processMast {} {
        if {$triggeredstate} {
            $self processActions
        } elseif {[$self cget -next] ne {}} {
            [$self cget -next] processMast
        }
    }
    method processLadder {} {
        if {$triggeredstate} {
            $self processActions
        }
        if {[$self cget -next] ne {}} {
            [$self cget -next] processLadder
        }
    }
    method processActions {} {
        set thedelay [$self cget -delay]
        set retrig   [$self cget -retrigerable]
        foreach a {1 2 3 4} {
            set eventid  [$self cget -action${a}eventid]
            if {$eventid eq {}} {continue}
            set delayedP [$self cget -action${a}action1delay]
            set did      [set action${a}did]
            if {$thedelay > 0 && $delayedP} {
                if {$retrig && $did ne {}} {
                    after cancel $did
                } else {
                    continue
                }
                set action${a}did [after $thedelay [mytypemethod sendevent $eventid]]
            } else {
                $type sendevent $eventid
            }
        }
    }
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  alllogics [list];#  All logics
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  eventsproduced {};# Events produced.
    
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
        set conffile [from argv -configuration "logicsconf.xml"]
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
        ::log::log debug "*** $type typeconstructor: transport = $transport"
        
        set previous {}
        set previousGroup single
        foreach logic [$configuration getElementsByTagName "logic"] {
            set logiccommand [list $type create %AUTO%]
            ::log::log debug "*** $type typeconstructor: logiccommand is $logiccommand"
            set description [$logic getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend logiccommand -description [[lindex $description 0] data]
            }
            set grouptype [$logic getElementsByTagName "grouptype"]
            if {[llength $grouptype] < 1} {
                set group single
            } else {
                set group [[lindex $grouptype 0] data]
            }
            lappend logiccommand -grouptype $group
            set v1onevent [$logic getElementsByTagName "v1onevent"]
            if {[llength $v1onevent] > 0} {
                lappend logiccommand -v1onevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $v1onevent 0] data]"]
            }
            set v1offevent [$logic getElementsByTagName "v1offevent"]
            if {[llength $v1offevent] > 0} {
                lappend logiccommand -v1offevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $v1offevent 0] data]"]
            }
            set logicfunction [$logic getElementsByTagName "logicfunction"]
            if {[llength $logicfunction] > 0} {
                lappend logiccommand -logic [[lindex $logicfunction 0] data]
            }
            set v2onevent [$logic getElementsByTagName "v2onevent"]
            if {[llength $v2onevent] > 0} {
                lappend logiccommand -v2onevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $v2onevent 0] data]"]
            }
            set v2offevent [$logic getElementsByTagName "v2offevent"]
            if {[llength $v2offevent] > 0} {
                lappend logiccommand -v1offevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $v2offevent 0] data]"]
            }
            set delay [$logic getElementsByTagName "delay"]
            if {[llength $delay] > 0} {
                lappend logiccommand -delay [[lindex $delay 0] data]
            }
            set retriggerable [$logic getElementsByTagName "retriggerable"]
            if {[llength $retriggerable] > 0} {
                lappend logiccommand -retriggerable [[lindex $retriggerable 0] data]
            }
            set action1delay [$logic getElementsByTagName "action1delay"]
            if {[llength $action1delay] > 0} {
                lappend logiccommand -action1delay [[lindex $action1delay 0] data]
            }
            set action1event [$logic getElementsByTagName "action1event"]
            if {[llength $action1event] > 0} {
                lappend logiccommand -v1offevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $action1event 0] data]"]
            }
            set action2delay [$logic getElementsByTagName "action2delay"]
            if {[llength $action2delay] > 0} {
                lappend logiccommand -action2delay [[lindex $action2delay 0] data]
            }
            set action2event [$logic getElementsByTagName "action2event"]
            if {[llength $action2event] > 0} {
                lappend logiccommand -v1offevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $action2event 0] data]"]
            }
            set action3delay [$logic getElementsByTagName "action3delay"]
            if {[llength $action3delay] > 0} {
                lappend logiccommand -action3delay [[lindex $action3delay 0] data]
            }
            set action3event [$logic getElementsByTagName "action3event"]
            if {[llength $action3event] > 0} {
                lappend logiccommand -v1offevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $action3event 0] data]"]
            }
            set action4delay [$logic getElementsByTagName "action4delay"]
            if {[llength $action4delay] > 0} {
                lappend logiccommand -action4delay [[lindex $action4delay 0] data]
            }
            set action4event [$logic getElementsByTagName "action4event"]
            if {[llength $action4event] > 0} {
                lappend logiccommand -v1offevent [lcc::EventID create %AUTO% -eventidstring "[[lindex $action4event 0] data]"]
            }
            
            ::log::log debug "*** $type typeconstructor: logiccommand is $logiccommand"
            set logic [eval $logiccommand]
            ::log::log debug "*** $type typeconstructor: logic is $logic"
            if {$previousGroup ne "single"} {
                $logic configure -previous $previous
                $previous configure -next $logic
            }
            if {$group ne "single"} {
                set previous $logic
                set previousGroup $group
            }
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
    typemethod validate {object} {
        if {[catch {$object info type} otype]} {
            error [_ "Not an OpenLCB_Logic: %s!", $object]
        } elseif {$otype ne $type} {
            error [_ "Not an OpenLCB_Logic: %s!", $object]
        } else {
            return $object
        }
    }
        
    

    
}
                
            
    
                
            
vwait forever
