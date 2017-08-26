#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Aug 17 07:55:13 2016
#  Last Modified : <170825.1047>
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


## @page OpenLCB_Acela OpenLCB Acela Node
# @brief OpenLCB Acela node
#
# @section AcelaSYNOPSIS SYNOPSIS 
#
# OpenLCB_Acela [-configure] [-sampleconfiguration] [-debug] [-configuration configfile]
#
# @section AcelaDESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for an
# Acela network.
#
# @section AcelaPARAMETERS PARAMETERS
#
# none
#
# @section AcelaOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_Acela.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration configfile Sets the name of the configuration (XML) file. 
# The default is acelaconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section AcelaCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" 
# chapter of the User Manual for the details on the schema for this XML 
# formatted file.  Also note that this program contains a built-in editor for 
# its own configuration file. 
#
#
# @section AcelaAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_Acela]

package require CTIAcela;# require the CTIAcela package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::enum AcelaIOClases -values {Control Signal Sensor}

snit::type Acela_Control {
    #** Implements one Acela Control address.
    #
    # Options:  (All are readonly, constructor time only.)
    # @arg -acela The Acela network interface object.
    # @arg -openlcb The OpenLCB_Acela instance.
    # @arg -address The Acela network address.
    # @arg -pulsewidth The pulseon or pulseoff width.
    # @arg -blinkperiod The blink period.
    # @arg -activate The activate eventid.
    # @arg -deactivate The deactivate eventid.
    # @arg -pulseon The pulseon eventid.
    # @arg -pulseoff The pulseoff eventid.
    # @arg -blink The blink eventid.
    # @arg -revblink The revblink eventid.
    
    option -acela -type ::ctiacela::CTIAcela -readonly yes
    option -openlcb -type ::OpenLCB_Acela -readonly yes
    option -address -type ::ctiacela::addresstype -default 0
    option -pulsewidth -type ::ctiacela::ubyte -default 0
    option -blinkperiod -type ::ctiacela::ubyte -default 0
    option -activate -type ::lcc::EventID_or_null -default {}
    option -deactivate -type ::lcc::EventID_or_null -default {}
    option -pulseon -type ::lcc::EventID_or_null -default {}
    option -pulseoff -type ::lcc::EventID_or_null -default {}
    option -blink -type ::lcc::EventID_or_null -default {}
    option -revblink -type ::lcc::EventID_or_null -default {}
    constructor {args} {
        ::log::log debug "*** $type create $self $args"
        $self configurelist $args
    }
    method consumerP {} {return yes}
    method producerP {} {return no}
    method consumedEvents {} {
        set events [list]
        foreach evopt {-activate -deactivate -pulseon -pulseoff -blink 
            -revblink} {
            set ev [$self cget $evopt]
            if {$ev ne {}} {lappend events $ev}
        }
        return $events
    }
    method producedEvents {} {return [list]}
    method pollsensor {} {}
    method readsensor {event} {return [list {} unknown]}
    method consumeEvent {event} {
        ::log::log debug "*** $self consumeEvent $event"
        foreach evopt {activate deactivate pulseon pulseoff blink
            revblink} {
            set ev [$self cget -$evopt]
            if {$ev eq {}} {continue}
            if {[$ev match $event]} {
                switch $evopt {
                    activate {
                        [$self cget -acela] Activate [$self cget -address]
                    }
                    deactivate  {
                        [$self cget -acela] Deactivate [$self cget -address]
                    }
                    pulseon {
                        [$self cget -acela] PulseOn [$self cget -address] [$self cget -pulsewidth]
                    }
                    pulseoff {
                        [$self cget -acela] PulseOff [$self cget -address] [$self cget -pulsewidth]
                    }
                    blink {
                        [$self cget -acela] Blink [$self cget -address] [$self cget -blinkperiod]
                    }
                    revblink {
                        [$self cget -acela] ReverseBlink [$self cget -address] [$self cget -blinkperiod]
                    }
                }
            }
        }
    }
}

snit::enum SignalCommands -values {Signal2 Signal3 Signal4}
snit::listtype AspectArgumentList -minlen 2 -maxlen 4 \
      -type ::ctiacela::lampcontroltype
snit::type EventAspectList {
    pragma  -hastypeinfo no -hastypedestroy no -hasinstances no
    typemethod validate {object} {
        foreach e_al $object {
            foreach {e al} $e_al {break}
            if {[catch {lcc::EventID validate $e}]} {
                error [_ "Not an EventAspectList: %s (badevent: %s)" $object $e]
            }
            if {[catch {AspectArgumentList validate $al}]} {
                error [_ "Not an EventAspectList: %s (bad AspectArgumentList: %s)" $object $al]
            }
        }
        return $object
    }
}

                
snit::type Acela_Signal {
    #** Implements one Acela Signal address.
    #
    # Options:  (All are readonly, constructor time only.)
    # @arg -acela The Acela network interface object.
    # @arg -openlcb The OpenLCB_Acela instance.
    # @arg -address The Acela network address.
    # @arg -signalcommand The signal command (one of {Signal2 Signal3 Signal4})
    # @arg -eventaspectlist The event aspect pair list.

    option -acela -type ::ctiacela::CTIAcela -readonly yes
    option -openlcb -type ::OpenLCB_Acela -readonly yes
    option -address -type ::ctiacela::addresstype -default 0
    option -signalcommand -type SignalCommands -default Signal2
    option -eventaspectlist -type EventAspectList -default {}
    
    constructor {args} {
        ::log::log debug "*** $type create $self $args"
        $self configurelist $args
    }
    method consumerP {} {return yes}
    method producerP {} {return no}
    method consumedEvents {} {
        set events [list]
        foreach ev_al [$self cget -eventaspectlist] {
            foreach {ev al} $ev_al {break}
            if {$ev ne {}} {lappend events $ev}
        }
        return $events
    }
    method producedEvents {} {return [list]}
    method pollsensor {} {}
    method readsensor {event} {return [list {} unknown]}
    method consumeEvent {event} {
        ::log::log debug "*** $self consumeEvent $event"
        set sigcmd [$self cget -signalcommand]
        foreach ev_al [$self cget -eventaspectlist] {
            foreach {ev al} $ev_al {break}
            if {$ev eq {}} {continue}
            if {[$ev match $event]} {
                ::log::log debug "*** $self consumeEvent: event matches"
                if {$sigcmd eq "Signal4"} {
                    while {[llength $al] < 4} {
                        lappend al off
                    }
                } elseif {$sigcmd eq "Signal3"} {
                    while {[llength $al] < 3} {
                        lappend al off
                    }
                    set al [lrange $al 0 2]
                } else {
                    set al [lrange $al 0 2]
                }
                set command [list [$self cget -acela] $sigcmd [$self cget -address]]
                foreach a $al {lappend command $a}
                ::log::log debug "*** $self consumeEvent: command is $command"
                uplevel #0 "$command"
            }
        }
    }
}

snit::type Acela_Sensor {
    #** Implements one Acela Sensor address.
    #
    # Options:  (All are readonly, constructor time only.)
    # @arg -acela The Acela network interface object.
    # @arg -openlcb The OpenLCB_Acela instance.
    # @arg -address The Acela network address.
    # @arg -filterthresh The filter threshold.
    # @arg -filterselect The filter selection.
    # @arg -polarity The sensor polarity.
    # @arg -onevent The eventid to send when the sensor comes on.
    # @arg -offevent The eventid to send when the sensor goes off.

    option -acela -type ::ctiacela::CTIAcela -readonly yes
    option -openlcb -type ::OpenLCB_Acela -readonly yes
    option -address -type ::ctiacela::addresstype -default 0
    option -filterthresh -type ::ctiacela::filterthreshtype -default 0
    option -filterselect -type ::ctiacela::selecttype -default noise
    option -polarity -type ::ctiacela::polaritytype -default normal
    option -onevent -type ::lcc::EventID_or_null -default {}
    option -offevent -type ::lcc::EventID_or_null -default {}
    variable oldstate 0
    
    constructor {args} {
        ::log::log debug "*** $type create $self $args"
        $self configurelist $args
        [$self cget -acela] ConfigureSensor [$self cget -address] [$self cget -filterthresh] [$self cget -filterselect] [$self cget -polarity]
        set oldstate [[$self cget -acela] Read [$self cget -address]]
    }
    method consumerP {} {return no}
    method producerP {} {return yes}
    method consumedEvents {} {return [list]}
    method producedEvents {} {
        set events [list]
        foreach evopt {-onevent -offevent} {
            set ev [$self cget $evopt]
            if {$ev ne {}} {lappend events $ev}
        }
        return $events
    }
    method readsensor {event} {
        set state [[$self cget -acela] Read [$self cget -address]]
        set ev0 [$self cget -offevent]
        if {$ev0 ne {}} {
            if {$event eq "*" || [$event match $ev0]} {
                if {$state == 0} {
                    return [list $ev0 valid]
                } else {
                    return [list $ev0 invalid]
                }
            }
        }
        set ev1 [$self cget -onevent]
        if {$ev1 ne {}} {
            if {$event eq "*" || [$event match $ev1]} {
                if {$state == 1} {
                    return [list $ev1 valid]
                } else {
                    return [list $ev1 invalid]
                }
            }
        }
        return [list {} unknown]
    }
    method pollsensor {} {
        ::log::log debug "*** $self pollsensor"
        set state [[$self cget -acela] Read [$self cget -address]]
        ::log::log debug "*** $self pollsensor: state = $state (oldstate = $oldstate)"
        if {$state == $oldstate} {return}
        set oldstate $state
        if {$state == 0} {
            set ev [$self cget -offevent]
        } else {
            set ev [$self cget -onevent]
        }
        ::log::log debug "*** $self pollsensor: ev = $ev"
        if {$ev ne {}} {
            set cmd [$self cget -openlcb]
            if {$cmd ne {}} {
                lappend cmd sendMyEvent $ev
                ::log::log debug "*** $self pollsensor: cmd = $cmd"
                uplevel #0 $cmd
            }
        }
    }
    method consumeEvent {event} {}
}


snit::type OpenLCB_Acela {
    #** This class implements a OpenLCB interface to an Acela network.
    #
    # Each instance manages one address (input or output). The typemethods 
    # implement the overall OpenLCB node and holds the Acela network interface.
    #
    # Instance options:
    # @arg -ioclasstype The I/O Class type.
    # @arg -description The description of the I/O element.
    # @par
    # Any additional options provided by the The I/O Class type.
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  iolist {};#         List of I/O instances
    typevariable  consumers {};#      I/O instances that consume events (Controls and Signals)
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      I/O instances that produce events (Sensors)
    typevariable  eventsproduced {};# Events produced.
    typecomponent acelanet;#          The acela network instance.
    typecomponent editContextMenu
    typecomponent xmlcontrolconfig;# Common control config object
    typecomponent xmlsensorconfig;# Common sensor config object
    typecomponent xmlsignalconfig;# Common signal config object
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages a CTI Acels network, consuming or producing
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
        set conffile [from argv -configuration "acelaconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmlcontrolconfig [XmlConfiguration create %AUTO% {
                             <configure>
                             <string option="-description" tagname="description">Description</string>
                             <int option="-address" tagname="address" min="0" max="65535">Address</int>
                             <int option="-pulsewidth" tagname="pulsewidth" min="0" max="255">Pulse Width</int>
                             <int option="-blinkperiod" tagname="blinkperiod" min="0" max="255">Blink Period</int>
                             <eventid option="-activate" tagname="activate">Activate EventID</eventid>
                             <eventid option="-deactivate" tagname="deactivate">Deactivate EventID</eventid>
                             <eventid option="-pulseon" tagname="pulseon">Pulse On EventID</eventid>
                             <eventid option="-pulseoff" tagname="pulseoff">Pulse Off EventID</eventid>
                             <eventid option="-blink" tagname="blink">Blink EventID</eventid>
                             <eventid option="-revblink" tagname="revblink">Reverse Blink EventID</eventid>
                             </configure>}]
        set xmlsensorconfig [XmlConfiguration create %AUTO% {
                             <configure>
                             <string option="-description" tagname="description">Description</string>
                             <int option="-address" tagname="address" min="0" max="65535">Address</int>
                             <int option="-filterthresh" tagname="filterthresh" min="0" max="255">Filter Threshold</int>
                             <enum option="-filterselect" tagname="filterselect" enums="noise bounce gap dirty" default="noise">Filter Select</enum>
                             <enum option="-polarity" tagname="polarity" enums="normal invert" noise="normal">Filter Select</enum>
                             </configure>}]
        set xmlsignalconfig [XmlConfiguration create %AUTO% {
                             <configure>
                             <string option="-description" tagname="description">Description</string>
                             <int option="-address" tagname="address" min="0" max="65535">Address</int>
                             <enum option="-signalcommand" tagname="signalcommand" enums="Signal2 Signal3 Signal4" default="Signal2">Signal Command</enum>
                             <group repname="Aspect" 
                             option="-eventaspectlist" 
                             tagname="aspect" mincount="0" 
                             maxcount="unlimited">
                             <eventid tagname="eventid">When this event Occurs</eventid>
                             <list tagname="arglist" mincount="2" maxcount="4" >the following lamp arguments will be sent</list>
                             </group>
                             </configure>} \
                               -configcallback [mytypemethod _signalaspectconfig] \
                               -guicallback [mytypemethod _signalaspectguicallback] \
                               -copyfromcallback [mytypemethod _signalaspectcopyfromcallback]]
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
                          $transportOpts} transport]} {
            ::log::logError [_ "Could not open OpenLCBNode: %s" $transport]
            exit 95
        }
        $transport SendVerifyNodeID
        set acelaport [$configuration getElementsByTagName "acelaport"]
        if {[llength $acelaport] != 1} {
            ::log::logError [_ "Acela port missing!"]
            exit 90
        }
        if {[catch {ctiacela::CTIAcela create %AUTO% [$acelaport data] \
                                       -srqhandler [mytypemethod srqhandler]} acelanet]} {
            ::log::logError [_ "Error connecting the the Acela Network: %s" $acelanet]
            exit 89
        }
        $acelanet ResetNetwork
        $acelanet NetworkOnline
        foreach control [$configuration getElementsByTagName "control"] {
            set command [$xmlcontrolconfig processConfig $control [list $type create Control%AUTO% -ioclasstype Control]]
            ::log::log debug "*** (control) command = '$command'"
            set io [eval $command]
            lappend iolist $io
            foreach e [$io consumedEvents] {
                lappend eventsconsumed $e
            }
            lappend consumers $io
        }
        set hassignals no
        foreach signal  [$configuration getElementsByTagName "signal"] {
            set command [$xmlsignalconfig processConfig $signal [list $type create Signal%AUTO% -ioclasstype Signal]]
            set hassignals yes
            ::log::log debug "*** (signal) command = '$command'"
            set io [eval $command]
            lappend iolist $io
            foreach e [$io consumedEvents] {
                lappend eventsconsumed $e
            }
            lappend consumers $io
        }
        if {$hassignals} {
            set command [list $acelanet SignalSettings]
            set haveSignalSettings no
            set tagele [$configuration getElementsByTagName "blinkrate"]
            if {[llength $tagele] > 0} {
                lappend command [[lindex $tagele 0] data]
                set haveSignalSettings yes
            } else {
                lappend command 10
            }
            set tagele [$configuration getElementsByTagName "yellowhue"]
            if {[llength $tagele] > 0} {
                lappend command [[lindex $tagele 0] data]
                set haveSignalSettings yes
            } else {
                lappend command 170
            }
            if {$haveSignalSettings} {eval $command}
            set tagele [$configuration getElementsByTagName "brightness"]
            if {[llength $tagele] > 0} {
                $acelanet SignalBrightness [[lindex $tagele 0] data]
            }
        }
        foreach sensor  [$configuration getElementsByTagName "sensor"] {
            set command [$xmlsensorconfig processConfig $sensor [list $type create Sensor%AUTO% -ioclasstype Sensor]]
            ::log::log debug "*** (sensor) command = '$command'"
            set io [eval $command]
            lappend iolist $io
            foreach e [$io producedEvents] {
                lappend eventsproduced $e
            }
            lappend producers $io
        }
        if {[llength $iolist] == 0} {
            ::log::logError [_ "No I/O addresses specified!"]
            exit 93
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
    typemethod srqhandler {} {
        ::log::log debug "*** $type srqhandler"
        foreach p $producers {
            $p pollsensor
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
                if {$validity eq "valid"} {
                    foreach c $consumers {
                        ::log::log debug "*** $type _eventHandler: c is $c"
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
                    foreach {ev state} [$p readsensor $eventid] {break}
                    if {$state ne "unknown"} {
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
                foreach p $producers {
                    foreach {ev state} [$p readsensor *] {break}
                    if {$state ne "unknown"} {
                        $transport ProducerIdentified $ev $state
                    }
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
    
        #*** Configuration GUI
    
    typecomponent main;# Main Frame.
    typecomponent scroll;# Scrolled Window.
    typecomponent editframe;# Scrollable Frame
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typevariable    acelaport {};# acelaport.
    typecomponent   generateEventID
    typecomponent   controls
    typecomponent   signals
    typevariable    blinkrate
    typevariable    yellowhue
    typevariable    brightness
    typecomponent   sensors

    
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
            {command "[_m {Menu|Help|EventExchange node for a CTI Acela network}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for a CTI Acela network"}}
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_Acela/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set transcons [SimpleDOMElement %AUTO% -tag "transport"]
        $cdi addchild $transcons
        set constructor [SimpleDOMElement %AUTO% -tag "constructor"]
        $transcons addchild $constructor
        $constructor setdata "CANGridConnectOverTcp"
        set transportopts [SimpleDOMElement %AUTO% -tag "options"]
        $transcons addchild $transportopts
        $transportopts setdata {-port 12021 -nid 05:01:01:01:22:00 -host localhost}
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set ident [SimpleDOMElement %AUTO% -tag "identification"]
        $cdi addchild $ident
        set nameele [SimpleDOMElement %AUTO% -tag "name"]
        $ident addchild $nameele
        $nameele setdata "Sample Name"
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $ident addchild $descrele
        $descrele setdata "Sample Description"
        set acelaport_ [SimpleDOMElement %AUTO% -tag "acelaport"]
        $cdi addchild $acelaport_
        switch $::tcl_platform(os) {
            Linux {$acelaport_ setdata "/dev/ttyACM0"}
            Darwin {$acelaport_ setdata "/dev/cu.acela"}
            default {$acelaport_ setdata "COM1:"}
        }
        set blinkrate_ [SimpleDOMElement %AUTO% -tag "blinkrate"]
        $cdi addchild $blinkrate_
        $blinkrate_ setdata 10
        set yellowhue_ [SimpleDOMElement %AUTO% -tag "yellowhue"]
        $cdi addchild $yellowhue_
        $yellowhue_ setdata 170
        set brightness_ [SimpleDOMElement %AUTO% -tag "brightness"]
        $cdi addchild $brightness_
        $brightness_ setdata 255
        set control [SimpleDOMElement %AUTO% -tag "control"]
        $cdi addchild $control
        set address [SimpleDOMElement %AUTO% -tag "address"]
        $control addchild $address
        $address setdata 0
        set description [SimpleDOMElement %AUTO% -tag "description"]
        $control addchild $description
        $description setdata "Sample Control"
        set pulsewidth [SimpleDOMElement %AUTO% -tag "pulsewidth"]
        $control addchild $pulsewidth
        $pulsewidth setdata 0
        set blinkperiod [SimpleDOMElement %AUTO% -tag "blinkperiod"]
        $control addchild $blinkperiod
        $blinkperiod setdata 0
        foreach eventtag {activate deactivate pulseon pulseoff blink revblink} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $control addchild $tagele
            $tagele setdata [$generateEventID nextid]
        }
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        set address [SimpleDOMElement %AUTO% -tag "address"]
        $signal addchild $address
        $address setdata 1
        set description [SimpleDOMElement %AUTO% -tag "description"]
        $signal addchild $description
        $description setdata "Sample Signal"
        set signalcommand [SimpleDOMElement %AUTO% -tag "signalcommand"]
        $signal addchild $signalcommand
        $signalcommand setdata Signal2
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set eventidtag [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $eventidtag
        $eventidtag setdata [$generateEventID nextid]
        incr eid
        set arglisttag [SimpleDOMElement %AUTO% -tag "arglist"]
        $aspect addchild $arglisttag
        $arglisttag setdata {off off off}
        set sensor [SimpleDOMElement %AUTO% -tag "sensor"]
        $cdi addchild $sensor
        set address [SimpleDOMElement %AUTO% -tag "address"]
        $sensor addchild $address
        $address setdata 3
        set description [SimpleDOMElement %AUTO% -tag "description"]
        $sensor addchild $description
        $description setdata "Sample Sensor"
        set filterthresh [SimpleDOMElement %AUTO% -tag "filterthresh"]
        $sensor addchild $filterthresh
        $filterthresh setdata 0
        set filterselect [SimpleDOMElement %AUTO% -tag "filterselect"]
        $sensor addchild $filterselect
        $filterselect setdata noise
        set polarity [SimpleDOMElement %AUTO% -tag "polarity"]
        $sensor addchild $polarity
        $polarity setdata normal
        foreach eventtag {onevent offevent} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $sensor addchild $tagele
            $tagele setdata [$generateEventID nextid]
        }
        set attrs [$cdi cget -attributes]
        lappend attrs lastevid [$generateEventID currentid]
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
        
        #puts stderr "*** $type ConfiguratorGUI \"$conffile\""
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
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_Acela container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_Acela Configuration Editor (%s)" $conffile]
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
        $xmlcontrolconfig configure -eventidgenerator $generateEventID
        $xmlsensorconfig  configure -eventidgenerator $generateEventID
        $xmlsignalconfig  configure -eventidgenerator $generateEventID
        #puts stderr "*** $type ConfiguratorGUI: generateEventID is $generateEventID"
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
        
        set acelaportLE [LabelEntry $frame.acelaportLE \
                         -label [_m "Label|Acela Network Port"] \
                         -textvariable [mytypevar acelaport]]
        pack $acelaportLE -fill x -expand yes
        set acelaport_ [$cdi getElementsByTagName "acelaport"]
        if {[llength $acelaport_] > 0} {
            set acelaport_ [lindex $acelaport_ 0]
            set acelaport [$acelaport_ data]
        }
        set controls [ScrollTabNotebook $frame.controls]
        pack $controls -expand yes -fill both
        #puts stderr "*** $type ConfiguratorGUI: controls is $controls"
        foreach control [$cdi getElementsByTagName "control"] {
            set controlframe [$xmlcontrolconfig createGUI $controls control \
                              $cdi $control [_m "Label|Delete Control"] \
                              [mytypemethod _addframe "Control %d"] \
                              [mytypemethod _delframe $controls]]
            #puts stderr "*** $type ConfiguratorGUI: controlframe is $controlframe"
        }
        set addcontrol [ttk::button $frame.addcontrol \
                       -text [_m "Label|Add another control"] \
                       -command [mytypemethod _addblankcontrol]]
        pack $addcontrol -fill x
        set signals [ScrollTabNotebook $frame.signals]
        pack $signals -expand yes -fill both
        foreach signal [$cdi getElementsByTagName "signal"] {
            set signalframe [$xmlsignalconfig createGUI $signals signal \
                             $cdi $signal [_m "Label|Delete Signal"] \
                             [mytypemethod _addframe "Signal %d"] \
                             [mytypemethod _delframe $signals]]
        }
        set addsignal [ttk::button $frame.addsignal \
                       -text [_m "Label|Add another signal"] \
                       -command [mytypemethod _addblanksignal]]
        pack $addsignal -fill x
        
        set blinkrateLE [LabelSpinBox $frame.blinkrateLE \
                         -label [_m "Label|Signal Blink Rate"] \
                         -textvariable [mytypevar blinkrate] \
                         -range {0 255 1}]
        pack $blinkrateLE -fill x -expand yes
        set blinkrate 10
        set tagele [$configuration getElementsByTagName "blinkrate"]
        if {[llength $tagele] > 0} {
            set blinkrate [[lindex $tagele 0] data]
        }
        set yellowhueLE [LabelSpinBox $frame.yellowhueLE \
                         -label [_m "Label|Signal Yellow Hue"] \
                         -textvariable [mytypevar yellowhue] \
                         -range {0 255 1}]
        pack $yellowhueLE -fill x -expand yes
        set yellowhue 170
        set tagele [$configuration getElementsByTagName "yellowhue"]
        if {[llength $tagele] > 0} {
            set yellowhue [[lindex $tagele 0] data]
        }
        set brightnessLE [LabelSpinBox $frame.brightnessLE \
                          -label [_m "Label|Signal Brightness"] \
                          -textvariable [mytypevar brightness] \
                          -range {0 255 1}]
        pack $brightnessLE -fill x -expand yes
        set brightness 255
        set tagele [$configuration getElementsByTagName "brightness"]
        if {[llength $tagele] > 0} {
            set brightness [[lindex $tagele 0] data]
        }
        set sensors [ScrollTabNotebook $frame.sensors]
        pack $sensors -expand yes -fill both
        foreach sensor [$cdi getElementsByTagName "sensor"] {
            set sensorframe [$xmlsensorconfig createGUI $sensors sensor \
                             $cdi $sensor [_m "Label|Delete Sensor"] \
                             [mytypemethod _addframe "Sensor %d"] \
                             [mytypemethod _delframe $sensors ]]
        }
        set addsensor [ttk::button $frame.addsensor \
                       -text [_m "Label|Add another sensor"] \
                       -command [mytypemethod _addblanksensor]]
        pack $addsensor -fill x
        
    }
    typemethod _addframe {label parent frame count} {
        $parent add $frame -text [format $label $count] -sticky news
    }
    typemethod _addblankcontrol {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set control [SimpleDOMElement %AUTO% -tag "control"]
        $cdi addchild $control
        set controlframe [$xmlcontrolconfig createGUI $controls control \
                          $cdi $control [_m "Label|Delete Control"] \
                          [mytypemethod _addframe "Control %d"] \
                          [mytypemethod _delframe $controls]]
    }
    typemethod _delframe {parentWidget frame} {
        $parentWidget forget $frame
    }
    typemethod _addblanksignal {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        set signalframe [$xmlsignalconfig createGUI $signals signal \
                         $cdi $signal [_m "Label|Delete Signal"] \
                         [mytypemethod _addframe "Signal %d"] \
                         [mytypemethod _delframe $signals]]
    }
    typemethod _addblanksensor {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set sensor [SimpleDOMElement %AUTO% -tag "sensor"]
        $cdi addchild $sensor
        set sensorframe [$xmlsensorconfig createGUI $sensors sensor \
                         $cdi $sensor [_m "Label|Delete Sensor"] \
                         [mytypemethod _addframe "Sensor %d"] \
                         [mytypemethod _delframe $sensors ]]
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
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
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
        set acelaport_ [$cdi getElementsByTagName "acelaport"]
        if {[llength $acelaport_] < 1} {
            set acelaport_ [SimpleDOMElement %AUTO% -tag "acelaport"]
            $cdi addchild $acelaport_
        }
        $acelaport_ setdata $acelaport
        foreach control [$cdi getElementsByTagName "control"] {
            $xmlcontrolconfig copyFromGUI $controls $control warnings
        }
        foreach signal [$cdi getElementsByTagName "signal"] {
            $xmlsignalconfig copyFromGUI $signals $signal warnings
        }
        set blinkrate_ [$cdi getElementsByTagName "blinkrate"]
        if {[llength $blinkrate_] < 1} {
            set blinkrate_ [SimpleDOMElement %AUTO% -tag "blinkrate"]
            $cdi addchild $blinkrate_
        }
        $blinkrate_ setdata $blinkrate
        set yellowhue_ [$cdi getElementsByTagName "yellowhue"]
        if {[llength $yellowhue_] < 1} {
            set yellowhue_ [SimpleDOMElement %AUTO% -tag "yellowhue"]
            $cdi addchild $yellowhue_
        }
        $yellowhue_ setdata $yellowhue
        set brightness_ [$cdi getElementsByTagName "brightness"]
        if {[llength $brightness_] < 1} {
            set brightness_ [SimpleDOMElement %AUTO% -tag "brightness"]
            $cdi addchild $brightness_
        }
        $brightness_ setdata $brightness
        
        foreach sensor  [$cdi getElementsByTagName "sensor"] {
            $xmlsensorconfig copyFromGUI $sensors $sensor warnings
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
    
    
    typemethod validate {object} {
        if {[catch {$object info type} otype]} {
            error [_ "Not an OpenLCB_Acela: %s" $object]
        } elseif {$otype ne $type} {
            error [_ "Not an OpenLCB_Acela: %s" $object]
        } else {
            return $object
        }
    }
        
    
    component iohandler -inherit yes;# I/O handler object.
    option -ioclasstype -type AcelaIOClases -readonly yes
    option -description -readonly yes -default {}
    
    constructor {args} {
        #** Construct a Acela I/O instance
        #
        # @param ... Options:
        # @arg -ioclasstype The I/O class.  Readonly, no default.
        # @par Additional options from the I/O class.
        
        ::log::log debug "*** $type create $self $args"
        set options(-ioclasstype) [from args -ioclasstype]
        set options(-description) [from args -description]
        set classconstructor Acela_$options(-ioclasstype)
        install iohandler using $classconstructor %AUTO% -openlcb $self -acela $acelanet
        $self configurelist $args
    }
    method sendMyEvent {eventid} {
        $type sendEvent $eventid
    }
}

vwait forever

