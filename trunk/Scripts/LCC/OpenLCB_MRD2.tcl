#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Jun 26 11:43:33 2016
#  Last Modified : <160626.2114>
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

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCBTcpHub]

package require Azatrax;#  require the Azatrax package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]


snit::type OpenLCB_MRD2 {
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  devicelist {};#     Device list
    typevariable  consumers {};#      Devices that consume events
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Devices that produce events
    typevariable  eventsproduced {};# Events produced.
    
    typeconstructor {
        global argv
        global argc
        global argv0
        
        set conffile [from argv -configuration "mrd2conf.xml"]
        if {[catch {open $conffile r} conffp]} {
            error [_ "Could not open %s because: %s" $conffile $conffp]
            exit 99
        }
        set confXML [read $conffp]
        close $conffp
        if {[catch {ParseXML create %AUTO% $confXML} configuration]} {
            error [_ "Could not parse configuration file %s: %s" $conffile $configuration]
            exit 98
        }
        set transcons [$configuration getElementsByTagName "transport"]
        puts stderr "*** $type typeconstructor: transcons:"
        $transcons display stderr "    "
        set constructor [$transcons getElementsByTagName "constructor"]
        if {$constructor eq {}} {
            error [_ "Transport constructor missing!"]
            exit 97
        }
        puts stderr "*** $type typeconstructor: constructor:"
        $constructor display stderr "    "
        set options [$transcons getElementsByTagName "options"]
        set transportOpts {}
        if {$options ne {}} {
            puts stderr "*** $type typeconstructor:  options:"
            $options display stderr "    "
            set transportOpts [$options data]
        } else {
            puts stderr "*** $type typeconstructor: no options."
        }
        
        set transportConstructors [info commands ::lcc::[$constructor data]]
        if {[llength $transportConstructors] > 0} {
            set transportConstructor [lindex $transportConstructors 0]
        }
        if {$transportConstructor eq {}} {
            error [_ "No valid transport constructor found!"]
            exit 96
        }
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler]] \
                          $transportOpts} transport]} {
            error [_ "Could not open OpenLCBNode: %s" $transport]
            exit 95
        }
        foreach device [$configuration getElementsByTagName "device"] {
            set devicecommand [list $type create %AUTO%]
            set consume no
            set produce no
            set serial [$device getElementsByTagName "serial"]
            if {[llength $serial] != 1} {
                error [_ "Missing or multiple serial numbers"]
                exit 94
            }
            lappend devicecommand -sensorserial [$serial data]
            set description [$device getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend devicecommand -description [[lindex $description 0] data]
            }
            foreach k {sense1on sense1off sense2on sense2off latch1on 
                       latch1off latch2on latch2off} {
                set tag [$device getElementsByTagName $k]
                if {[llength $tag] == 0} {continue}
                set tag [lindex $tag 0]
                set produce yes
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend devicecommand -$k $ev
                lappend eventsproduced $ev
            }
            foreach k {setchan1 setchan2} {
                set tag [$device getElementsByTagName $k]
                if {[llength $tag] == 0} {continue}
                set tag [lindex $tag 0]
                set consume yes
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend devicecommand -$k $ev
                lappend eventsconsumed $ev
            }
            if {!$consume && !$produce} {
                puts stderr [_ "Useless device (S# %s) (neither consumes or produces events)" [$serial data]]
                continue
            }
            set dev [eval $devicecommand]
            if {$consume} {lappend consumers $dev}
            if {$produce} {lappend producers $dev}
            lappend devicelist $dev
        }
        if {[llength $devicelist] == 0} {
            error [_ "No devices specified!"]
            exit 93
        }
        after 500 [mytypemethod _poll]
    }
    typemethod _poll {} {
        foreach p $producers {
            $p Poll
        }
        after 500 [mytypemethod _poll]
    }
    typemethod _eventHandler {command eventid {validity {}}} {
        #* Event handler -- when a PCER message is received
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
            }
            identifyproducer {
            }
            identifyevents {
            }
            report {
                foreach c $consumers {
                    #puts stderr "*** $type _eventHandler: device is [$c cget -sensorserial]"
                    #puts stderr "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $c consumeEvent $eventid
                    
                }
            }
        }
    }
    typemethod _messageHandler {message} {
        switch [format {0x%04X} [$message cget -mti]] {
            0x0490 -
            0x0498 {
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
    component sensor;# The MRD2 device
    variable  old_s1 0;# The saved value of Sense 1
    variable  old_s2 0;# The saved value of Sense 2
    variable  old_l1 0;# The saved value of Latch 1
    variable  old_l2 0;# The saved value of Latch 2
    option    -sense1on -type lcc::EventID_or_null -readonly yes -default {}
    option    -sense1off -type lcc::EventID_or_null -readonly yes -default {}
    option    -sense2on -type lcc::EventID_or_null -readonly yes -default {}
    option    -sense2off -type lcc::EventID_or_null -readonly yes -default {}
    option    -latch1on -type lcc::EventID_or_null -readonly yes -default {}
    option    -latch1off -type lcc::EventID_or_null -readonly yes -default {}
    option    -latch2on -type lcc::EventID_or_null -readonly yes -default {}
    option    -latch2off -type lcc::EventID_or_null -readonly yes -default {}
    option    -setchan1 -type lcc::EventID_or_null -readonly yes -default {}
    option    -setchan2 -type lcc::EventID_or_null -readonly yes -default {}
    option    -sensorserial -readonly yes -default {}
    option    -description -readonly yes -default {}
    constructor {args} {
        set options(-sensorserial) [from args -sensorserial]
        if {$options(-sensorserial) eq {}} {
            error [_ "The -sensorserial option is required!"]
        }
        install sensor using Azatrax_OpenDevice $options(-sensorserial) \
              $::Azatrax_idMRDProduct
        $sensor GetStateData
        set old_s1 [$sensor Sense_1]
        set old_s2 [$sensor Sense_2]
        set old_l1 [$sensor Latch_1]
        set old_l2 [$sensor Latch_2]
        $self configurelist $args
    }
    method Poll {} {
        set events [list]
        $sensor GetStateData
        if {$old_s1 != [$sensor Sense_1]} {
            set old_s1 [$sensor Sense_1]
            if {$old_s1} {
                lappend events [$self cget -sense1on]
            } else {
                lappend events [$self cget -sense1off]
            }
        }
        if {$old_s2 != [$sensor Sense_2]} {
            set old_s2 [$sensor Sense_2]
            if {$old_s2} {
                lappend events [$self cget -sense2on]
            } else {
                lappend events [$self cget -sense2off]
            }
        }
        if {$old_l1 != [$sensor Latch_1]} {
            set old_l1 [$sensor Latch_1]
            if {$old_l1} {
                lappend events [$self cget -latch1on]
            } else {
                lappend events [$self cget -latch1off]
            }
        }
        if {$old_l2 != [$sensor Latch_2]} {
            set old_l2 [$sensor Latch_2]
            if {$old_l2} {
                lappend events [$self cget -latch2on]
            } else {
                lappend events [$self cget -latch2off]
            }
        }
        foreach event $events {
            if {$event eq {}} {continue}
            $transport ProduceEvent $event
        }
    }
    method consumeEvent {event} {
        #puts stderr "*** $self consumeEvent $event"
        $sensor GetStateData
        #puts stderr "*** $self consumeEvent: HasRelays: [$sensor HasRelays]"
        if {![$sensor HasRelays]} {return false}
        #puts stderr "*** $self consumeEvent: setchan1 event is [$self cget -setchan1]"
        if {[$event match [$self cget -setchan1]]} {
            #puts stderr "*** $self consumeEvent: setchan1 event matches!"
            $sensor SetChan1
            return true
        }
        #puts stderr "*** $self consumeEvent: setchan2 event is [$self cget -setchan2]"
        if {[$event match [$self cget -setchan2]]} {
            #puts stderr "*** $self consumeEvent: setchan2 event matches!"
            $sensor SetChan2
            return true
        }
        return false
    }
}

vwait forever
