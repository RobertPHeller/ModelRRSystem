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
#  Last Modified : <170511.1256>
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
    method evalFunction {} {
        set result false
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
                if {($v1 && $v2) && eopt eq "v2oneventid"} {
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
        ::log::log debug "*** $self processevent [$event cget -eventidstring]"
        set triggeredstate false
        set ematch false
        set trig false
        foreach eopt {v1oneventid v1offeventid v2oneventid v2offeventid} {
            ::log::log debug "*** $self processevent: eopt is $eopt"
            set ev [$self cget -$eopt]
            if {$ev eq {}} {continue}
            ::log::log debug "*** $self processevent: ev is [$ev cget -eventidstring]"
            if {[$ev match $event]} {
                ::log::log debug "*** $self processevent: [$ev cget -eventidstring] matches [$event cget -eventidstring]"
                switch $eopt {
                    v1oneventid {
                        if {!$v1} {set trig true}
                        set v1 true
                    }
                    v1offeventid {
                        if {$v1} {set trig true}
                        set v1 false
                    }
                    v2oneventid {
                        if {!$v2} {set trig true}
                        set v2 true
                    }
                    v2offeventid {
                        if {$v2} {set trig true}
                        set v2 false
                    }
                }
                set ematch true
                ::log::log debug "*** $self processevent (event match): v1 = $v1, v2 = $v2"
                ::log::log debug "*** $self processevent (event match): -logic is [$self cget -logic]"
                ::log::log debug "*** $self processevent (event match): trig = $trig"
            }
        }
        ::log::log debug "*** $self processevent: ematch is $ematch"
        if {!$ematch} {return}
        ::log::log debug "*** $self processevent: trig is $trig"
        if {!$trig} {return}
        ::log::log debug "*** $self processevent: -grouptype is [$self cget -grouptype]"
        switch [$self cget -grouptype] {
            single {
                if {[$self evalFunction]} {$self processActions}
            }
            mast {
                $self processPreviousMast
            }
            ladder {
                $self processLadder
            }
        }
    }
    method processPreviousMast {} {
        ::log::log debug "*** $self processPreviousMast"
        ::log::log debug "*** $self processPreviousMast: -previous is [$self cget -previous]"
        if {[$self cget -previous] ne {}} {
            [$self cget -previous] processPreviousMast
        } else {
            $self processMast
        }
    }
    method processMast {} {
        ::log::log debug "*** $self processMast"
        ::log::log debug "*** $self processMast: -next is [$self cget -next]"
        if {[$self evalFunction]} {
            $self processActions
        } elseif {[$self cget -next] ne {}} {
            [$self cget -next] processMast
        }
    }
    method processLadder {} {
        ::log::log debug "*** $self processLadder"
        if {[$self evalFunction]} {
            $self processActions
        }
        ::log::log debug "*** $self processLadder: -next is [$self cget -next]"
        if {[$self cget -next] ne {}} {
            [$self cget -next] processLadder
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
        $transport SendVerifyNodeID
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
                lappend logiccommand -v1oneventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $v1onevent 0] data]"]
            }
            set v1offevent [$logic getElementsByTagName "v1offevent"]
            if {[llength $v1offevent] > 0} {
                lappend logiccommand -v1offeventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $v1offevent 0] data]"]
            }
            set logicfunction [$logic getElementsByTagName "logicfunction"]
            if {[llength $logicfunction] > 0} {
                lappend logiccommand -logic [[lindex $logicfunction 0] data]
            }
            set v2onevent [$logic getElementsByTagName "v2onevent"]
            if {[llength $v2onevent] > 0} {
                lappend logiccommand -v2oneventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $v2onevent 0] data]"]
            }
            set v2offevent [$logic getElementsByTagName "v2offevent"]
            if {[llength $v2offevent] > 0} {
                lappend logiccommand -v2offeventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $v2offevent 0] data]"]
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
                lappend logiccommand -action1eventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $action1event 0] data]"]
            }
            set action2delay [$logic getElementsByTagName "action2delay"]
            if {[llength $action2delay] > 0} {
                lappend logiccommand -action2delay [[lindex $action2delay 0] data]
            }
            set action2event [$logic getElementsByTagName "action2event"]
            if {[llength $action2event] > 0} {
                lappend logiccommand -action2eventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $action2event 0] data]"]
            }
            set action3delay [$logic getElementsByTagName "action3delay"]
            if {[llength $action3delay] > 0} {
                lappend logiccommand -action3delay [[lindex $action3delay 0] data]
            }
            set action3event [$logic getElementsByTagName "action3event"]
            if {[llength $action3event] > 0} {
                lappend logiccommand -action3eventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $action3event 0] data]"]
            }
            set action4delay [$logic getElementsByTagName "action4delay"]
            if {[llength $action4delay] > 0} {
                lappend logiccommand -action4delay [[lindex $action4delay 0] data]
            }
            set action4event [$logic getElementsByTagName "action4event"]
            if {[llength $action4event] > 0} {
                lappend logiccommand -action4eventid [lcc::EventID create %AUTO% -eventidstring "[[lindex $action4event 0] data]"]
            }
            
            ::log::log debug "*** $type typeconstructor: logiccommand is $logiccommand"
            set logic [eval $logiccommand]
            ::log::log debug "*** $type typeconstructor: logic is $logic"
            if {$previousGroup ne "single"} {
                $logic configure -previous $previous
                $previous configure -next $logic
                $logic configure -grouptype $previousGroup
            }
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
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typecomponent   logics;# logic list
    typevariable    logiccount 0;# logic count
    
    typevariable status {};# Status line
    typevariable conffilename {};# Configuration File Name
    
    #** Menu.
    typevariable _menu {
        "[_m {Menu|&File}]" {file:menu} {file} 0 {
            {command "[_m {Menu|File|&Save and Exit}]" {file:saveexit} "[_ {Save and exit}]" {Ctrl s} -command "[mytypemethod _saveexit]"}
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
            $tagele setdata [format {05.01.01.01.22.00.00.%02x} $eid]
            incr eid
        }
        set logicfunction [SimpleDOMElement %AUTO% -tag "logicfunction"]
        $logic addchild $logicfunction
        $logicfunction setdata and
        foreach eventtag {v2onevent v2offevent} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $logic addchild $tagele
            $tagele setdata [format {05.01.01.01.22.00.00.%02x} $eid]
            incr eid
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
            $event setdata [format {05.01.01.01.22.00.00.%02x} $eid]
            incr eid
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
        
        set logics [ScrollTabNotebook $frame.tracks]
        pack $logics -expand yes -fill both
        foreach logic [$cdi getElementsByTagName "logic"] {
            $type _create_and_populate_logic $logic
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
        $type _create_and_populate_logic $logic
    }
    typemethod _create_and_populate_logic {logic} {
        #** Create a tab for a logic and populate it.
        #
        # @param logic The logic XML element.
        
        #puts stderr "*** $type _create_and_populate_logic $logic"
        incr logiccount
        set fr logic$logiccount
        set f [$logic attribute frame]
        if {$f eq {}} {
            set attrs [$logic cget -attributes]
            lappend attrs frame $fr
            $logic configure -attributes $attrs
        } else {
            set attrs [$logic cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $logic configure -attributes $attrs
        }
        #puts stderr "*** $type _create_and_populate_logic: fr = $fr"
        set lcxframe [ttk::frame $logics.$fr]
        $logics add $lcxframe -text [_ "Logic %d" $logiccount] -sticky news
        set description_ [LabelEntry $lcxframe.description \
                          -label [_m "Label|Description"]]
        pack $description_ -fill x -expand yes
        set description [$logic getElementsByTagName "description"]
        if {[llength $description] == 1} {
            $description_ configure -text [$description data]
        }
        #puts stderr "*** $type _create_and_populate_logic: description_ = $description_"
        set grouptype_ [LabelComboBox $lcxframe.grouptype \
                        -label [_m "Label|Group Type"] \
                        -values [GroupType AllGroupTypeLabels] \
                        -editable no]
        pack $grouptype_ -fill x -expand yes
        set grouptype [$logic getElementsByTagName "grouptype"]
        if {[llength $grouptype] < 1} {
            set group single
        } else {
            set group [[lindex $grouptype 0] data]
        }
        $grouptype_ set [GroupType GroupTypeLabel $group]
        #puts stderr "*** $type _create_and_populate_logic: grouptype_ = $grouptype_"
        set v1onevent_ [LabelEntry $lcxframe.v1onevent \
                        -label [_m "Label|Set variable #1 true."] ]
        pack $v1onevent_ -fill x -expand yes
        set v1onevent [$logic getElementsByTagName "v1onevent"]
        if {[llength $v1onevent] > 0} {
            $v1onevent_ configure -text "[[lindex $v1onevent 0] data]"
        } else {
            $v1onevent_ configure -text "00.00.00.00.00.00.00.00"
        }
        set v1offevent_ [LabelEntry $lcxframe.v1offevent \
                        -label [_m "Label|Set variable #1 false."] ]
        pack $v1offevent_ -fill x -expand yes
        set v1offevent [$logic getElementsByTagName "v1offevent"]
        if {[llength $v1offevent] > 0} {
            $v1offevent_ configure -text "[[lindex $v1offevent 0] data]"
        } else {
            $v1offevent_ configure -text "00.00.00.00.00.00.00.00"
        }
        set logicfunction_ [LabelComboBox $lcxframe.logicfunction \
                        -label [_m "Label|Logic Function"] \
                        -values [Logic AllLogicLabels] \
                        -editable no]
        pack $logicfunction_ -fill x -expand yes
        set logicfunction [$logic getElementsByTagName "logicfunction"]
        if {[llength $logicfunction] < 1} {
            set logicfun and
        } else {
            set logicfun [[lindex $logicfunction 0] data]
        }
        #puts stderr "*** $type _create_and_populate_logic: logicfun = $logicfun"
        $logicfunction_ set [Logic LogicLabel $logicfun]
        
        set v2onevent_ [LabelEntry $lcxframe.v2onevent \
                        -label [_m "Label|Set variable #2 true."] ]
        pack $v2onevent_ -fill x -expand yes
        set v2onevent [$logic getElementsByTagName "v2onevent"]
        if {[llength $v2onevent] > 0} {
            $v2onevent_ configure -text "[[lindex $v2onevent 0] data]"
        } else {
            $v2onevent_ configure -text "00.00.00.00.00.00.00.00"
        }
        set v2offevent_ [LabelEntry $lcxframe.v2offevent \
                        -label [_m "Label|Set variable #2 false."] ]
        pack $v2offevent_ -fill x -expand yes
        set v2offevent [$logic getElementsByTagName "v2offevent"]
        if {[llength $v2offevent] > 0} {
            $v2offevent_ configure -text "[[lindex $v2offevent 0] data]"
        } else {
            $v2offevent_ configure -text "00.00.00.00.00.00.00.00"
        }
        
        set delay_ [LabelSpinBox $lcxframe.delay \
                    -label [_m "Label|Delay Period, miliseconds"] \
                    -range {0 86400000 1}]
        pack $delay_ -fill x -expand yes
        set delay [$logic getElementsByTagName "delay"]
        if {[llength $delay] > 0} {
            $delay_ set [[lindex $delay 0] data]
        } else {
            $delay_ set 0
        }
        set retriggerable_ [LabelComboBox $lcxframe.retriggerable \
                            -label [_m "Label|Retriggerable?"] \
                            -values [list [_m "Answer|No"] [_m "Answer|Yes"]] \
                            -editable no]
        pack $retriggerable_ -fill x -expand yes
        set retriggerable [$logic getElementsByTagName "retriggerable"]
        if {[llength $retriggerable] > 0} {
            if {[[lindex $retriggerable 0] data]} {
                $retriggerable_ set [_m "Answer|Yes"]
            } else {
                $retriggerable_ set [_m "Answer|No"]
            }
        } else {
            $retriggerable_ set [_m "Answer|No"]
        }
        #puts stderr "*** $type _create_and_populate_logic: retriggerable_ = $retriggerable_"
        set actions [ScrollTabNotebook $lcxframe.actions]
        pack $actions -expand yes -fill both
        foreach a {1 2 3 4} {
            #puts stderr "*** $type _create_and_populate_logic: a = $a"
            set aframe [ttk::frame [format {%s.action%d} $actions $a]]
            #puts stderr "*** $type _create_and_populate_logic: aframe = $aframe"
            $actions add $aframe -text [_ "Action %d" $a] -sticky news
            set action_delay_ [LabelComboBox $aframe.delay \
                               -label [_m "Label|Delay?"] \
                               -values [list [_m "Answer|No"] [_m "Answer|Yes"]] \
                               -editable no]
            pack $action_delay_ -fill x -expand yes
            set action_delay [$logic getElementsByTagName [format "action%ddelay" $a]]
            #puts stderr "*** $type _create_and_populate_logic: action_delay = $action_delay"
            if {[llength $action_delay] > 0} {
                if {[[lindex $action_delay 0] data]} {
                    $action_delay_ set [_m "Answer|Yes"]
                } else {
                    $action_delay_ set [_m "Answer|No"]
                }
            } else {
                $action_delay_ set [_m "Answer|No"]
            }
            #puts stderr "*** $type _create_and_populate_logic: action_delay_ = $action_delay_"
            set action_event_ [LabelEntry $aframe.event \
                               -label [_m "Label|Send Event:"]]
            pack $action_event_ -fill x -expand yes
            set action_event [$logic getElementsByTagName [format "action%devent" $a]]
            if {[llength $action_event] > 0} {
                $action_event_ configure -text "[[lindex $action_event 0] data]"
            } else {
                $action_event_ configure -text "00.00.00.00.00.00.00.00"
            }
            #puts stderr "*** $type _create_and_populate_logic: action_event_ = $action_event_"
        }
        set dellogic [ttk::button $lcxframe.dellogic \
                      -text [_m "Label|Delete Logic"] \
                      -command [mytypemethod _deleteLogic $logic]]
        pack $dellogic -fill x
    }
    typemethod _deleteLogic {logic} {
        set fr [$logic attribute frame]
        set cdis [$configuration getElementsByTagName OpenLCB_Logic -depth 1]
        set cdi [lindex $cdis 0]
        $cdi removeChild $logic
        $logics forget $logics.$fr
        destroy $logics.$fr
    }
    typevariable warnings
    typemethod _saveexit {} {
        #** Save and exit.  Bound to the Save & Exit file menu item.
        # Saves the contents of the GUI as an XML file.
        
        set warnings 0
        set cdis [$configuration getElementsByTagName OpenLCB_Logic -depth 1]
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
        foreach logic [$cdi getElementsByTagName "logic"] {
            $type _copy_from_gui_to_XML $logic
        }
        if {$warnings > 0} {
            tk_messageBox -type ok -icon info \
                  -message [_ "There were %d warnings.  Please correct and try again." $warnings]
            return
        }
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
        }
        ::exit
    }
    typemethod _copy_from_gui_to_XML {logic} {
        #** Copy from the GUI to the logic XML
        # 
        # @param logic Logic XML element.
        
        set fr [$logic attribute frame]
        set frbase $logics.$fr
        set description_ [$frbase.description get]
        if {$description_ eq ""} {
            set description [$logic getElementsByTagName "description"]
            if {[llength $description] == 1} {
                $logic removeChild $description
            }
        } else {
            set description [$logic getElementsByTagName "description"]
            if {[llength $description] < 1} {
                set description [SimpleDOMElement %AUTO% -tag "description"]
                $logic addchild $description
            }
            $description setdata $description_
        }
        set groupval [GroupType GroupTypeFromLabel "[$frbase.grouptype get]"]
        set grouptype [$logic getElementsByTagName "grouptype"]
        if {[llength $grouptype] < 1} {
            set grouptype [SimpleDOMElement %AUTO% -tag "grouptype"]
            $logic addchild $grouptype
        }
        $grouptype setdata $groupval
        set v1onevent_ "[$frbase.v1onevent get]"
        set v1onevent [$logic getElementsByTagName "v1onevent"]
        if {$v1onevent_ ne "" && [catch {lcc::eventidstring validate $v1onevent_}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Event ID for v1 on event is not a valid event id string: %s!" $v1onevent_]
            set $v1onevent_ ""
            incr warnings
        }
        if {$v1onevent_ eq "" || $v1onevent_ eq "00.00.00.00.00.00.00.00"} {
            if {[llength $v1onevent] == 1} {
                $logic removeChild $v1onevent
            }
        } else {
            if {[llength $v1onevent] < 1} {
                set v1onevent [SimpleDOMElement %AUTO% -tag "v1onevent"]
                $logic addchild $v1onevent
            }
            $v1onevent setdata $v1onevent_
        }
        set v1offevent_ "[$frbase.v1offevent get]"
        set v1offevent [$logic getElementsByTagName "v1offevent"]
        if {$v1offevent_ ne "" && [catch {lcc::eventidstring validate $v1offevent_}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Event ID for v1 off event is not a valid event id string: %s!" $v1offevent_]
            set $v1offevent_ ""
            incr warnings
        }
        if {$v1offevent_ eq "" || $v1offevent_ eq "00.00.00.00.00.00.00.00"} {
            if {[llength $v1offevent] == 1} {
                $logic removeChild $v1offevent
            }
        } else {
            if {[llength $v1offevent] < 1} {
                set v1offevent [SimpleDOMElement %AUTO% -tag "v1offevent"]
                $logic addchild $v1offevent
            }
            $v1offevent setdata $v1offevent_
        }
        set logicfunval [Logic LogicFromLabel "[$frbase.logicfunction get]"]
        set logicfunction [$logic getElementsByTagName "logicfunction"]
        if {[llength $logicfunction] < 1} {
            set logicfunction [SimpleDOMElement %AUTO% -tag "logicfunction"]
            $logic addchild $logicfunction
        }
        $logicfunction setdata $logicfunval
        set v2onevent_ "[$frbase.v2onevent get]"
        set v2onevent [$logic getElementsByTagName "v2onevent"]
        if {$v2onevent_ ne "" && [catch {lcc::eventidstring validate $v2onevent_}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Event ID for v2 on event is not a valid event id string: %s!" $v2onevent_]
            set $v2onevent_ ""
            incr warnings
        }
        if {$v2onevent_ eq "" || $v2onevent_ eq "00.00.00.00.00.00.00.00"} {
            if {[llength $v2onevent] == 1} {
                $logic removeChild $v2onevent
            }
        } else {
            if {[llength $v2onevent] < 1} {
                set v2onevent [SimpleDOMElement %AUTO% -tag "v2onevent"]
                $logic addchild $v2onevent
            }
            $v2onevent setdata $v2onevent_
        }
        set v2offevent_ "[$frbase.v2offevent get]"
        set v2offevent [$logic getElementsByTagName "v2offevent"]
        if {$v2offevent_ ne "" && [catch {lcc::eventidstring validate $v2offevent_}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Event ID for v2 off event is not a valid event id string: %s!" $v2offevent_]
            set $v2offevent_ ""
            incr warnings
        }
        if {$v2offevent_ eq "" || $v2offevent_ eq "00.00.00.00.00.00.00.00"} {
            if {[llength $v2offevent] == 1} {
                $logic removeChild $v2offevent
            }
        } else {
            if {[llength $v2offevent] < 1} {
                set v2offevent [SimpleDOMElement %AUTO% -tag "v2offevent"]
                $logic addchild $v2offevent
            }
            $v2offevent setdata $v2offevent_
        }
        set delay_ "[$frbase.delay get]"
        set delay [$logic getElementsByTagName "delay"]
        if {[llength $delay] < 1} {
            set delay [SimpleDOMElement %AUTO% -tag "delay"]
            $logic addchild $delay
        }
        $delay setdata $delay_
        set retriggerable_ false
        if {"[$frbase.retriggerable get]" eq [_m "Answer|Yes"]} {
            set retriggerable_ true
        }
        set retriggerable [$logic getElementsByTagName "retriggerable"]
        if {[llength $retriggerable] < 1} {
            set retriggerable [SimpleDOMElement %AUTO% -tag "retriggerable"]
            $logic addchild $retriggerable
        }
        $retriggerable setdata $retriggerable_
        foreach a {1 2 3 4} {
            set aframe [format {%s.action%d} $frbase.actions $a]
            set action_event_ "[$aframe.event get]"
            set action_event [$logic getElementsByTagName [format "action%devent" $a]]
            if {$action_event_ ne "" && [catch {lcc::eventidstring validate $action_event_}]} {
                tk_messageBox -type ok -icon warning \
                      -message [_ "Event ID for action %d on event is not a valid event id string: %s!" $a $action_event_]
                set $action_event_ ""
                incr warnings
            }
            if {$action_event_ eq "" || $action_event_ eq "00.00.00.00.00.00.00.00"} {
                if {[llength $action_event] > 0} {
                    $logic removeChild $action_event
                }
                set action_delay [$logic getElementsByTagName [format "action%ddelay" $a]]
                if {[llength $action_delay] > 0} {
                    $logic removeChild $action_delay
                }
                continue
            } else {
                if {[llength $action_event] < 1} {
                    set action_event [SimpleDOMElement %AUTO% -tag [format "action%devent" $a]]
                    $logic addchild $action_event
                }
                $action_event setdata $action_event_
            }
            set action_delay_ false
            if {"[$aframe.delay get]" eq [_m "Answer|Yes"]} {
                set action_delay_ true
            }
            set action_delay [$logic getElementsByTagName [format "action%ddelay" $a]]
            if {[llength $action_delay] < 1} {
                set action_delay [SimpleDOMElement %AUTO% -tag [format "action%ddelay" $a]]
                $logic addchild $action_delay
            }
            $action_delay setdata $action_delay_
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

