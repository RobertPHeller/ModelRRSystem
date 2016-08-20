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
#  Last Modified : <160820.1018>
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
package require CTCPanel 2.0

snit::type Dispatcher_Block {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_Switch {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_Signal {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_CodeButton {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_Lamp {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_ToggleSwitch {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_SwitchPlate {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::type Dispatcher_SignalPlate {
    option -openlcb -type ::OpenLCB_Dispatcher -readonly yes
}

snit::enum ElementClasses -values {Block Switch Signal CodeButton Lamp 
                                   ToggleSwitch SwitchPlate SignalPlate}

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
    typevariable  consumers {};#      Element instances that consume events
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Element instances that produce events
    typevariable  eventsproduced {};# Events produced.
    
    typemethod ConnectToOpenLCB {args} {
        set transportConstructors [info commands ::lcc::[from args -transport]]
        if {[llength $transportConstructors] > 0} {
            set transportConstructor [lindex $transportConstructors 0]
        }
        if {$transportConstructor eq {}} {
            error [_ "No valid transport constructor found!"]
            exit 96
        }
        set name [from args -name]
        set descriptor [from args -descriptor]
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB Acela" \
                          -softwareversion "1.0" \
                          -nodename $nodename \
                          -nodedescription $nodedescriptor \
                          -additionalprotocols {EventExchange} \
                          ] \
                          $args} transport]} {
            error [_ "Could not open OpenLCBNode: %s" $transport]
            exit 95
        }
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
        
        ::log::log debug "*** $type _eventHandler $command $eventid $validity"
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
                ::log::log debug "*** $type _eventHandler: consumers is $consumers"
                foreach c $consumers {
                    ::log::log debug "*** $type _eventHandler: c is $c"
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
        #** Construct a Acela I/O instance
        #
        # @param ... Options:
        # @arg -eleclasstype The I/O class.  Readonly, no default.
        # @par Additional options from the I/O class.
        
        set options(-eleclasstype) [from args -eleclasstype]
        set options(-description) [from args -description]
        set classconstructor Dispatcher_$options(-eleclasstype)
        install elehandler using $classconstructor %AUTO% -openlcb $self
        $self configurelist $args
    }
    method sendMyEvent {eventid} {
        $type sendEvent $eventid
    }
}

