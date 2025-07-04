#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Aug 20 09:20:52 2016
#  Last Modified : <250215.2138>
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


package require snit
package require LCC
package require LCCNodeTree
package require LCCTrafficMonitor
package require EventDialogs
package require CTCPanel 2.0

snit::type Dispatcher_Block {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -occupiedeventid -type lcc::EventID_or_null -default {}
    option -notoccupiedeventid -type lcc::EventID_or_null -default {}
    variable occupied no

    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -occupiedcommand [mymethod occupiedp]
    }
    method occupiedp {} {return $occupied}
    method consumerP {} {return yes}
    method producerP {} {return no}
    method consumedEvents {} {
        set events [list]
        foreach eopt {occupiedeventid notoccupiedeventid} {
            set ev [$self cget -$eopt]
            if {$ev eq {}} {continue}
            lappend events $ev
        }
        return $events
    }
    method producedEvents {} {return [list]}
    method consumeEvent {event} {
        set ev [$self cget -occupiedeventid]
        if {$ev ne {} && [$ev match $event]} {
            set occupied yes
        }
        set ev [$self cget -notoccupiedeventid]
        if {$ev ne {} && [$ev match $event]} {
            set occupied no
        }
        MainWindow ctcpanel invoke "$options(-name)"
    }
}

snit::type Dispatcher_Switch {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -occupiedeventid -type lcc::EventID_or_null -default {}
    option -notoccupiedeventid -type lcc::EventID_or_null -default {}
    variable occupied no
    option -statenormaleventid -type lcc::EventID_or_null -default {}
    option -statereverseeventid -type lcc::EventID_or_null -default {}
    variable state unknown
    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -occupiedcommand [mymethod occupiedp] \
              -statecommand    [mymethod getstate]
    }
    method occupiedp {} {return $occupied}
    method getstate  {} {return $state}
    method consumerP {} {return yes}
    method producerP {} {return no}
    method consumedEvents {} {
        set events [list]
        foreach eopt {occupiedeventid notoccupiedeventid statenormaleventid 
                      statereverseeventid} {
            set ev [$self cget -$eopt]
            if {$ev eq {}} {continue}
            lappend events $ev
        }
        return $events
    }
    method producedEvents {} {return [list]}
    method consumeEvent {event} {
        set ev [$self cget -occupiedeventid]
        if {$ev ne {} && [$ev match $event]} {
            set occupied yes
        }
        set ev [$self cget -notoccupiedeventid]
        if {$ev ne {} && [$ev match $event]} {
            set occupied no
        }
        set ev [$self cget -statenormaleventid]
        if {$ev ne {} && [$ev match $event]} {
            set state normal
        }
        set ev [$self cget -statereverseeventid]
        if {$ev ne {} && [$ev match $event]} {
            set state reverse
        }
        MainWindow ctcpanel invoke "$options(-name)"
    }
}

snit::enum CTC_AspectColors -values {dark red yellow green white blue}

snit::listtype CTC_AspectList -type CTC_AspectColors
    
snit::type CTC_EventAspectList {
    pragma  -hastypeinfo no -hastypedestroy no -hasinstances no
    typemethod validate {object} {
        if {([llength $object] & 1) != 0} {
            if {([llength $object] & 1) != 0} {
                error [_ "Not an CTC_EventAspectList: %s (odd list length)" $object]
            } else {
                foreach {e al} $object {
                    if {[catch {lcc::EventID validate $e}]} {
                        error [_ "Not an CTC_EventAspectList: %s (badevent: %s)" $object $e]
                    }
                }
                if {[catch {CTC_AspectList validate $al}]} {
                    error [_ "Not an CTC_EventAspectList: %s (bad AspectArgumentList: %s)" $object $al]
                }
            }
        }
        return $object
    }
}



snit::type Dispatcher_Signal {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -eventidaspectlist -type CTC_EventAspectList -default {}
    constructor {args} {
        $self configurelist $args
    }
    method consumerP {} {return yes}
    method producerP {} {return no}    
    method consumedEvents {} {
        set events [list]
        foreach {ev aspl} [$self cget -eventidaspectlist] {
            lappend events $ev
        }
        return $events
    }
    method producedEvents {} {return [list]}
    method consumeEvent {event} {
        foreach {ev aspl} [$self cget -eventidaspectlist] {
            if {[$ev match $event]} {
                MainWindow ctcpanel setv "$options(-name)" "$aspl"
            }
        }
    }
}


snit::type Dispatcher_CodeButton {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -eventid -type lcc::EventID_or_null -default {}
    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -command [mymethod code]
    }
    method consumerP {} {return no}
    method producerP {} {return yes}    
    method consumedEvents {} {return [list]}
    method producedEvents {} {
        set events [list]
        set ev [$self cget -eventid]
        if {$ev ne ""} {lappend events $ev}
        return $events
    }
    method code {} {
        set cp [MainWindow ctcpanel itemcget [$self cget -name] -controlpoint]
        set ev [$self cget -eventid]
        if {$ev ne ""} {
            [$self cget -openlcb] sendMyEvent $ev
        }
        foreach swp [MainWindow ctcpanel objectlist $cp SwitchPlates] {
            MainWindow ctcpanel invoke $swp
        }
        foreach sgp [MainWindow ctcpanel objectlist $cp SignalPlates] {
            MainWindow ctcpanel invoke $sgp
        }
        foreach tog [MainWindow ctcpanel objectlist $cp Toggles] {
            MainWindow ctcpanel invoke $tog
        }
        foreach push [MainWindow ctcpanel objectlist $cp PushButtons] {
            MainWindow ctcpanel invoke $push
        }
    }
}

snit::type Dispatcher_Lamp {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -oneventid  -type lcc::EventID_or_null -default {}
    option -offeventid -type lcc::EventID_or_null -default {}
    constructor {args} {
        $self configurelist $args
    }
    method consumerP {} {return yes}
    method producerP {} {return no}
    method consumedEvents {} {
        set events [list]
        foreach eopt {oneventid offeventid} {
            set ev [$self cget -$eopt]
            if {$ev ne ""} {lappend events $ev}
        }
        return $events
    }
    method producedEvents {} {return [list]}
    method consumeEvent {event} {
        set ev [$self cget -oneventid]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel setv "$options(-name)" on
        }
        set ev [$self cget -offeventid]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel setv "$options(-name)" off
        }
    }
}

snit::type Dispatcher_ToggleSwitch {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -lefteventid   -type lcc::EventID_or_null -default {}
    option -righteventid  -type lcc::EventID_or_null -default {}
    option -centereventid -type lcc::EventID_or_null -default {}
    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -leftcommand [mymethod sendevent -lefteventid] \
              -rightcommand [mymethod sendevent -righteventid] \
              -centercommand [mymethod sendevent -centereventid]
    }
    method sendevent {eopt} {
        set ev [$self cget $eopt]
        if {$ev ne ""} {
            [$self cget -openlcb] sendMyEvent $ev
        }
    }
    method consumerP {} {return no}
    method producerP {} {return yes}
    method consumedEvents {} {return [list]}
    method producedEvents {} {
        set events [list]
        foreach eopt {lefteventid righteventid centereventid} {
            set ev [$self cget -$eopt]
            if {$ev ne ""} {lappend events $ev}
        }
        return $events
    }
    method consumeEvent {event} {}
}

snit::type Dispatcher_PushButton {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -eventid -type lcc::EventID_or_null -default {}
    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -command [mymethod sendevent -eventid]
    }
    method sendevent {eopt} {
        set ev [$self cget $eopt]
        if {$ev ne ""} {
            [$self cget -openlcb] sendMyEvent $ev
        }
    }
    method consumerP {} {return no}
    method producerP {} {return yes}
    method consumedEvents {} {return [list]}
    method producedEvents {} {
        set events [list]
        set ev [$self cget -eventid]
        if {$ev ne ""} {lappend events $ev}
        return $events
    }
    method consumeEvent {event} {}
}

snit::type Dispatcher_SwitchPlate {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -normaleventid   -type lcc::EventID_or_null -default {}
    option -reverseeventid  -type lcc::EventID_or_null -default {}
    option -normalindonev   -type lcc::EventID_or_null -default {}
    option -normalindoffev  -type lcc::EventID_or_null -default {}
    option -centerindonev   -type lcc::EventID_or_null -default {}
    option -centerindoffev  -type lcc::EventID_or_null -default {}
    option -reverseindonev  -type lcc::EventID_or_null -default {}
    option -reverseindoffev -type lcc::EventID_or_null -default {}
    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -normalcommand [mymethod sendevent -normaleventid] \
              -reversecommand [mymethod sendevent -reverseeventid]
    }
    method sendevent {eopt} {
        set ev [$self cget $eopt]
        if {$ev ne ""} {
            [$self cget -openlcb] sendMyEvent $ev
        }
    }
    method consumerP {} {return yes}
    method producerP {} {return yes}
    method consumedEvents {} {
        set events [list]
        foreach eopt {normalindonev normalindoffev centerindonev 
                      centerindoffev reverseindonev reverseindoffev} {
            set ev [$self cget -$eopt]
            if {$ev ne ""} {lappend events $ev}
        }
    }
    method producedEvents {} {
        set events [list]
        foreach eopt {normaleventid reverseeventid} {
            set ev [$self cget -$eopt]
            if {$ev ne ""} {lappend events $ev}
        }
        return $events
    }
    method consumeEvent {event} {
        set ev [$self cget -normalindonev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" N on
        }
        set ev [$self cget -normalindoffev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" N off
        }
        set ev [$self cget -centerindonev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" C on
        }
        set ev [$self cget -centerindoffev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" C off
        }
        set ev [$self cget -reverseindonev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" R on
        }
        set ev [$self cget -reverseindoffev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" R off
        }
    }
}

snit::type Dispatcher_SignalPlate {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -lefteventid     -type lcc::EventID_or_null -default {}
    option -centereventid   -type lcc::EventID_or_null -default {}
    option -righteventid    -type lcc::EventID_or_null -default {}
    option -leftindonev     -type lcc::EventID_or_null -default {}
    option -leftindoffev    -type lcc::EventID_or_null -default {}
    option -centerindonev   -type lcc::EventID_or_null -default {}
    option -centerindoffev  -type lcc::EventID_or_null -default {}
    option -rightindonev  -type lcc::EventID_or_null -default {}
    option -rightindoffev -type lcc::EventID_or_null -default {}
    
    constructor {args} {
        $self configurelist $args
        MainWindow ctcpanel itemconfigure "$options(-name)" \
              -leftcommand [mymethod sendevent -lefteventid] \
              -centercommand [mymethod sendevent -centereventid] \
              -rightcommand [mymethod sendevent -righteventid]
    }
    method sendevent {eopt} {
        set ev [$self cget $eopt]
        if {$ev ne ""} {
            [$self cget -openlcb] sendMyEvent $ev
        }
    }
    method consumerP {} {return yes}
    method producerP {} {return yes}
    method consumedEvents {} {
        set events [list]
        foreach eopt {leftindonev leftindoffev centerindonev 
                      centerindoffev rightindonev rightindoffev} {
            set ev [$self cget -$eopt]
            if {$ev ne ""} {lappend events $ev}
        }
    }
    method producedEvents {} {
        set events [list]
        foreach eopt {lefteventid righteventid centereventid} {
            set ev [$self cget -$eopt]
            if {$ev ne ""} {lappend events $ev}
        }
        return $events
    }
    method consumeEvent {event} {
        set ev [$self cget -leftindonev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" L on
        }
        set ev [$self cget -leftindoffev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" L off
        }
        set ev [$self cget -centerindonev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" C on
        }
        set ev [$self cget -centerindoffev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" C off
        }
        set ev [$self cget -rightindonev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" R on
        }
        set ev [$self cget -rightindoffev]
        if {$ev ne "" && [$ev match $event]} {
            MainWindow ctcpanel seti "$options(-name)" R off
        }
    }
}

snit::type Dispatcher_UserCodeModule {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
    option -name    -default {}
    option -usermoduleconstructor -readonly yes
    component usermodule -inherit yes
    constructor {args} {
        set options(-openlcb) [from args -openlcb]
        set options(-name) [from args -name]
        set options(-usermoduleconstructor) [from args -usermoduleconstructor]
        install usermodule using $options(-usermoduleconstructor) %AUTO% \
              -openlcb $options(-openlcb) \
              -name $options(-name) \
              {*}$args
    }
}


snit::enum ElementClasses -values {Block Switch Signal CodeButton Lamp 
    ToggleSwitch SwitchPlate SignalPlate 
    PushButton UserCodeModule}

snit::type OpenLCB_Dispatcher {
    ## OpenLCB Interface code for Dispatcher panels
    #
    # The typemethods implement the interface to the OpenLCB network, and the
    # instances implement the interface to Dispatcher panel elements. The
    # instances use a helper type to implement a specific Dispatcher panel 
    # element type.
    # 
    #
    
    typecomponent transport; #        Transport layer
    typevariable  elelist {};#        List of elements
    typemethod GetElementByName {name} {
        foreach e $elelist {
            if {[$e cget -name] eq $name} {
                return $e
            }
        }
        return {}
    }
    typemethod GetElementByType {eleclasstype} {
        ElementClasses validate $eleclasstype
        set result [list]
        foreach e $elelist {
            if {[$e cget -eleclasstype] eq $eleclasstype} {
                lappend result $e
            }
        }
        return $result
    }
    typevariable  consumers {};#      Element instances that consume events
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Element instances that produce events
    typevariable  eventsproduced {};# Events produced.
    typevariable  eventlogging no;#   Event logging
    typecomponent eventlog;#          Event log window
    typecomponent nodetreetop;#       Node Tree toplevel
    typecomponent nodetreemain;#      Node Tree Main window
    typecomponent nodetree;#          Node Tree
    
    typeconstructor {
        set eventlog {}
        set nodetree {}
        set nodetreemain {}
        set nodetreetop {}
    }

    typemethod PopulateOpenLCBMenu {} {
        MainWindow main menu add openlcb checkbutton \
              -label [_m {Menu|OpenLCB|Event Logging}] \
              -variable [mytypevar eventlogging] \
              -onvalue yes -offvalue no
        MainWindow main menu add openlcb command \
              -label [_m {Menu|OpenLCB|Open Eventlog}] \
              -command [mytypemethod _OpenEventlog]
        MainWindow main menu add openlcb command \
              -label [_m {Menu|OpenLCB|Open Node Tree}] \
              -command [mytypemethod _OpenNodeTree]
        MainWindow main menu add openlcb command \
              -label [_m {Menu|OpenLCB|Open LCC Traffic Monitor}] \
              -command [mytypemethod _OpenTrafficMonitor]
    }
    
    typemethod _OpenTrafficMonitor {} {
        LCCTrafficMonitor Open .trafficMonitor -transport $transport
    }
        
    typemethod _OpenEventlog {} {
        if {![winfo exists $eventlog]} {
            set eventlog [lcc::EventLog .eventlog%AUTO% \
                          -transport $transport \
                          -localeventhandler [mytypemethod _localeventhandler]]
        }
        $eventlog open
    }
    typemethod _OpenNodeTree {} {
        if {![winfo exists $nodetree]} {
            catch {.nodetreetop destroy}
            set nodetreetop [toplevel .nodetreetop]
            set nodetreemain [mainwindow $nodetreetop.main -scrolling yes \
                              -height 480 -width 640 \
                              -menu [subst {
                                     "[_m {Menu|&File}]" {file:menu} {file} 0 {
                                         {command "[_m {Menu|File|&Close}]" 
                                             {file:close} 
                                             "[_ {Close the Node Tree}]" 
                                             {Ctrl c} 
                                             -command "[mytypemethod _closeNodeTree]"}}}]]
            pack $nodetreemain -expand yes -fill both
            wm protocol $nodetreetop WM_DELETE_WINDOW \
                  [mytypemethod _closeNodeTree]
            set nodetree [LCCNodeTree [$nodetreemain scrollwindow getframe].nodetree \
                          -transport $transport]
            $nodetreemain scrollwindow setwidget $nodetree
            $nodetreemain toolbar add topbuttons
            $nodetreemain toolbar addbutton topbuttons refresh -text [_m "Label|Refresh"] -command [list $nodetree Refresh]
            $nodetreemain toolbar show topbuttons
            
        }
        $nodetreemain showit
    }
    typemethod _closeNodeTree {} {
        if {[winfo exists $nodetree]} {
            wm withdraw $nodetreetop
        }
    }
    typemethod ConnectToOpenLCB {args} {
        #puts stderr "*** $type ConnectToOpenLCB $args"
        set transportConstructors [info commands ::lcc::[from args -transport]]
        if {[llength $transportConstructors] > 0} {
            set transportConstructor [lindex $transportConstructors 0]
        }
        if {$transportConstructor eq {}} {
            error [_ "No valid transport constructor found!"]
            exit 96
        }
        set name [from args -name]
        set description [from args -description]
        if {[catch {lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "Dispatcher Panel" \
                          -softwareversion "1.0" \
                          -nodename $name \
                          -nodedescription $description \
                          -additionalprotocols {EventExchange} \
                          {*}$args} transport]} {
            error [_ "Could not open OpenLCBNode: %s" $transport]
            exit 95
        }
        $transport SendVerifyNodeID
        $transport IdentifyEvents
        #puts stderr "*** $type ConnectToOpenLCB: transport = $transport"
    }
    typemethod SendMyEvents {} {
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
        foreach ev $eventsproduced {
            $transport ProducerIdentified $ev unknown
        }
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
        
        #puts stderr "*** $type _eventHandler $command $eventid $validity"
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
                        #puts stderr "*** $type _eventHandler: c is $c"
                        #puts stderr "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                        $c consumeEvent $eventid
                        
                    }
                    if {$eventlogging} {
                        if {![winfo exists $eventlog]} {
                            set eventlog [lcc::EventLog .eventlog%AUTO% \
                                          -transport $transport]
                        }
                        $eventlog eventReceived $eventid
                        $eventlog open
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
                #puts stderr "*** $type _eventHandler: consumers is $consumers"
                foreach c $consumers {
                    #puts stderr "*** $type _eventHandler: c is $c"
                    #puts stderr "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $c consumeEvent $eventid
                    
                }
                if {$eventlogging} {
                    if {![winfo exists $eventlog]} {
                        set eventlog [lcc::EventLog .eventlog%AUTO% \
                                      -transport $transport]
                    }
                    $eventlog eventReceived $eventid
                    $eventlog open
                }
            }
        }
    }
    typemethod _localeventhandler {eventid} {
        #* Local Event handler.  Handle local Events from the event log dialog.
        #
        # @param eventid The eventid.
        
        foreach c $consumers {
            #puts stderr "*** $type _localeventhandler: c is $c"
            #puts stderr "*** $type _localeventhandler: event is [$eventid cget -eventidstring]"
            $c consumeEvent $eventid
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
        if {[winfo exists $nodetree]} {
            $nodetree messageHandler $message
        }
    }
    
    typemethod validate {object} {
        if {[catch {$object info type} otype]} {
            error [_ "Not an OpenLCB_Dispatcher: %s" $object]
        } elseif {$otype ne $type} {
            error [_ "Not an OpenLCB_Dispatcher: %s" $object]
        } else {
            return $object
        }
    }
    
    component elehandler -inherit yes;# Element handler object.
    option -eleclasstype -type ElementClasses -readonly yes
    option -description -readonly yes -default {}
    
    constructor {args} {
        #** Construct a LCC Node element instance
        #
        # @param ... Options:
        # @arg -eleclasstype The I/O class.  Readonly, no default.
        # @par Additional options from the I/O class.
        
        #puts stderr "*** $type create $self $args"
        set options(-eleclasstype) [from args -eleclasstype]
        #puts stderr "*** $type create $self: options(-eleclasstype) = $options(-eleclasstype)"
        set options(-description) [from args -description]
        #puts stderr "*** $type create $self: options(-description) is '$options(-description)'"
        set classconstructor Dispatcher_$options(-eleclasstype)
        install elehandler using $classconstructor %AUTO% -openlcb $self \
              {*}$args
        lappend elelist $self
        if {[$self consumerP]} {
            lappend consumers $self
            foreach ev [$self consumedEvents] {
                lappend eventsconsumed $ev
            }
        }
        if {[$self producerP]} {
            lappend producers $self
            foreach ev [$self producedEvents] {
                lappend eventsproduced $ev
            }
        }
        
    }
    method sendMyEvent {eventid} {
        $type sendEvent $eventid
    }
}

