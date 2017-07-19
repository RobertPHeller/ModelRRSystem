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
#  Last Modified : <170719.1623>
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
        if {([llength $object] & 1) != 0} {
            error [_ "Not an EventAspectList: %s (odd list length)" $object]
        } else {
            foreach {e al} $object {
                if {[catch {lcc::EventID validate $e}]} {
                    error [_ "Not an EventAspectList: %s (badevent: %s)" $object $e]
                }
                if {[catch {AspectArgumentList validate $al}]} {
                    error [_ "Not an EventAspectList: %s (bad AspectArgumentList: %s)" $object $al]
                }
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
        foreach {ev al} [$self cget -eventaspectlist] {
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
        foreach {ev al} [$self cget -eventaspectlist] {
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
            set command [list $type create Control%AUTO% -ioclasstype Control]
            set addr [$control getElementsByTagName "address"]
            if {[llength $addr] != 1} {
                ::log::logError [_ "A control's address is missing, skipping!"]
                continue
            }
            if {[catch {::ctiacela::addresstype validate [$addr data]}]} {
                ::log::logError [_ "A control's address is bad: %s" [$addr data]]
                continue
            }
            lappend command -address [$addr data]
            foreach tag {description pulsewidth blinkperiod} {
                set tagele [$control getElementsByTagName $tag]
                if {[llength $tagele] > 0} {
                    set tagele [llindex $tagele 0]
                    lappend command -$tag [$tagele data]
                }
            }
            foreach tag {activate deactivate pulseon pulseoff blink revblink} {
                set tagele [$control getElementsByTagName $tag]
                if {[llength $tagele] > 0} {
                    set tagele [llindex $tagele 0]
                    lappend command -$tag [lcc::EventID create %AUTO% \
                                           -eventidstring [$tagele data]]
                }
            }
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
            set command [list $type create Signal%AUTO% -ioclasstype Signal]
            set addr [$signal getElementsByTagName "address"]
            if {[llength $addr] != 1} {
                ::log::logError [_ "A signal's address is missing, skipping!"]
                continue
            }
            if {[catch {::ctiacela::addresstype validate [$addr data]}]} {
                ::log::logError [_ "A signal's address is bad: %s" [$addr data]]
                continue
            }
            lappend command -address [$addr data]
            set descr [$signal getElementsByTagName "description"]
            if {[llength $descr] > 0} {
                lappend command -description "[[lindex $descr 0] data]"
            }
            set sigcmd [$signal getElementsByTagName "signalcommand"]
            if {[llength $sigcmd] != 1} {
                ::log::logError [_ "A signal's command type is missing, skipping!"]
                continue
            }
            set signalcmd [$sigcmd data]
            if {[catch {::SignalCommands validate $signalcmd}]} {
                ::log::logError [_ "Bad signal command type: %s, skipping!" $signalcmd]
                continue
            }
            lappend command -signalcommand $signalcmd
            set eventaspectlist [list]
            foreach aspect [$signal getElementsByTagName "aspect"] {
                set evtag [$aspect getElementsByTagName "eventid"]
                if {[llength $evtag] != 1} {
                    ::log::logError [_ "A signal's aspect event is missing, skipping!"]
                    continue
                }
                set event [$evtag data]
                set altag [$aspect getElementsByTagName "arglist"]
                if {[llength $altag] != 1} {
                    ::log::logError [_ "A signal's aspect arglist is missing, skipping!"]
                    continue
                }
                lappend eventaspectlist [lcc::EventID %AUTO% -eventidstring $event] "[$altag data]"
            }
            if {[llength $eventaspectlist] < 2} {
                ::log::logError [_ "A signal has no aspects, skipping!"]
                continue
            }
            if {[catch {EventAspectList validate $eventaspectlist} why]} {
                ::log::logError [_ "A signal's event aspect list (%s) is illformed (%s), skipping!" $eventaspectlist $why]
                continue
            }
            set hassignals yes
            lappend command -eventaspectlist "$eventaspectlist"
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
            set command [list $type create Sensor%AUTO% -ioclasstype Sensor]
            set addr [$sensor getElementsByTagName "address"]
            if {[llength $addr] != 1} {
                ::log::logError [_ "A sensor's address is missing, skipping!"]
                continue
            }
            if {[catch {::ctiacela::addresstype validate [$addr data]}]} {
                ::log::logError [_ "A sensor's address is bad: %s" [$addr data]]
                continue
            }
            lappend command -address [$addr data]
            foreach tag {description filterthresh filterselect polarity} {
                set tagele [$sensor getElementsByTagName $tag]
                if {[llength $tagele] > 0} {
                    set tagele [lindex $tagele 0]
                    lappend command -$tag [$tagele data]
                }
            }
            foreach tag {onevent offevent} {
                set tagele [$sensor getElementsByTagName $tag]
                if {[llength $tagele] > 0} {
                    set tagele [lindex $tagele 0]
                    lappend command -$tag [lcc::EventID create %AUTO% \
                                           -eventidstring [$tagele data]]
                }
            }
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
    typecomponent   controls
    typevariable    controlcount 0
    typecomponent   signals
    typevariable    signalcount 0
    typevariable    blinkrate
    typevariable    yellowhue
    typevariable    brightness
    typecomponent   sensors
    typevariable    sensorcount 0
    
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
        set eid 0
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
            $tagele setdata [format {05.01.01.01.22.00.00.%02x} $eid]
            incr eid
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
        $eventidtag setdata [format {05.01.01.01.22.00.00.%02x} $eid]
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
            $tagele setdata [format {05.01.01.01.22.00.00.%02x} $eid]
            incr eid
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
        foreach control [$cdi getElementsByTagName "control"] {
            $type _create_and_populate_control $control
        }
        set addcontrol [ttk::button $frame.addcontrol \
                       -text [_m "Label|Add another control"] \
                       -command [mytypemethod _addblankcontrol]]
        pack $addcontrol -fill x
        set signals [ScrollTabNotebook $frame.signals]
        pack $signals -expand yes -fill both
        foreach signal [$cdi getElementsByTagName "signal"] {
            $type _create_and_populate_signal $signal
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
            $type _create_and_populate_sensor $sensor
        }
        set addsensor [ttk::button $frame.addsensor \
                       -text [_m "Label|Add another sensor"] \
                       -command [mytypemethod _addblanksensor]]
        pack $addsensor -fill x
        
    }
    typemethod _create_and_populate_control {control} {
        incr controlcount
        set fr control$controlcount
        set f [$control attribute frame]
        if {$f eq {}} {
            set attrs [$control cget -attributes]
            lappend attrs frame $fr
            $control configure -attributes $attrs
        } else {
            set attrs [$control cget -attributes]
            set findx [lsearch -exact $attrs frame] 
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $control configure -attributes $attrs
        }
        set ctrlframe [ttk::frame $controls.$fr]
        $controls add $ctrlframe \
              -text [_ "Control %d" $controlcount] -sticky news
        set address_ [LabelSpinBox $ctrlframe.addressSB \
                      -label [_m "Label|Address"] \
                      -range {0 65535 1}]
        pack $address_ -fill x -expand yes
        set address [$control getElementsByTagName "address"]
        if {[llength $address] == 1} {
            $address_ set [$address data]
        } else {
            $address_ set 0
        }
        foreach tag {description pulsewidth blinkperiod activate deactivate 
                     pulseon pulseoff blink revblink} \
              lab [list [_m "Label|Description"] [_m "Label|Pulse Width"] \
                   [_m "Label|Blink Period"] [_m "Label|Activate EventID"] \
                   [_m "Label|Deactivate EventID"] \
                   [_m "Label|Pulse On EventID"] \
                   [_m "Label|Pulse Off EventID"] [_m "Label|Blink EventID"] \
                   [_m "Label|Reverse Blink  EventID"]] \
              wcons {LabelEntry LabelSpinBox LabelSpinBox LabelEntry 
                     LabelEntry LabelEntry LabelEntry LabelEntry LabelEntry} \
              default {{} 0 0 {} {} {} {} {} {}} {
             set widget [$wcons $ctrlframe.$tag -label $lab]
             if {$wcons eq "LabelSpinBox"} {
                 $widget configure -range {0 255 1}
             }
             $widget configure -text $default
             pack $widget -fill x -expand yes
             set tagele [$control getElementsByTagName $tag]
             if {[llength $tagele] > 0} {
                 $widget configure -text [[lindex $tagele 0] data]
             }
         }
         set delcontrol [ttk::button $ctrlframe.delcontrol \
                         -text [_m "Label|Delete Control"] \
                         -command [mytypemethod _deleteControl $control]]
         pack $delcontrol -fill x
            
    }
    typemethod _addblankcontrol {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set control [SimpleDOMElement %AUTO% -tag "control"]
        $cdi addchild $control
        $type _create_and_populate_control $control
    }
    typemethod _deleteControl {control} {
        set fr [$control attribute frame]
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        $cdi removeChild $control
        $controls forget $controls.$fr
        destroy $controls.$fr
    }
    typemethod _create_and_populate_signal {signal} {
        incr signalcount
        set fr signal$signalcount
        set f [$signal attribute frame]
        if {$f eq {}} {
            set attrs [$signal cget -attributes]
            lappend attrs frame $fr
            $signal configure -attributes $attrs
        } else {
            set attrs [$signal cget -attributes]
            set findx [lsearch -exact $attrs frame] 
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $signal configure -attributes $attrs
        }
        set sigframe [ttk::frame $signals.$fr]
        $signals add $sigframe \
              -text [_ "Signal %d" $signalcount] -sticky news
        set address_ [LabelSpinBox $sigframe.addressSB \
                      -label [_m "Label|Address"] \
                      -range {0 65535 1}]
        pack $address_ -fill x -expand yes
        set address [$signal getElementsByTagName "address"]
        if {[llength $address] == 1} {
            $address_ set [$address data]
        } else {
            $address_ set 0
        }
        set description_ [LabelEntry $sigframe.description \
                          -label [_m "Label|Description"]]
        pack $description_ -fill x -expand yes
        set description [$signal getElementsByTagName "description"]
        if {[llength $description] > 0} {
            $description_ configure -text [[lindex $description 0] data]
        }
        set signalcommand_ [LabelComboBox $sigframe.signalcommand \
                            -label [_m "Label|Signal Command"] \
                            -values [SignalCommands cget -values] \
                            -editable no]
        pack $signalcommand_ -fill x -expand yes
        set signalcommand [$signal getElementsByTagName "signalcommand"]
        if {[llength $signalcommand] > 0} {
            $signalcommand_ set [[lindex $signalcommand 0] data]
        } else {
            $signalcommand_ set [lindex [SignalCommands cget -values] 0]
        }
        set eventaspectlist_ [ScrollTabNotebook $sigframe.eventaspectlist]
        pack $eventaspectlist_ -fill both -expand yes
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _create_and_populate_signal_aspect $signal $eventaspectlist_ $aspect
        }
        set addaspect [ttk::button $sigframe.addaspect \
                       -text [_m "Label|Add another aspect"] \
                       -command [mytypemethod _addblankaspect $signal $eventaspectlist_]]
        pack $addaspect -fill x
    }
    typemethod _create_and_populate_signal_aspect {signal aspectlist aspect} {
        
        set tag [$aspect getElementsByTagName "eventid"]
        if {[llength $tag] != 1} {
            tk_messageBox -type ok -icon warning -message [_ "Aspect missing its EventID. skipped!"]
            return
        }
        set tag [lindex $tag 0]
        set evstring [$tag data]
        set tag [$aspect getElementsByTagName "arglist"]
        if {[llength $tag] != 1} {
            tk_messageBox -type ok -icon warning -message [_ "Aspect missing its arglist, skipped!"]
            return
        }
        set tag [lindex $tag 0]
        set arglist [$tag data]
        #puts stderr "*** $type _create_and_populate_signal_aspect: arglist = \{$arglist\}"
        if {[catch {AspectArgumentList validate $arglist} why]} {
            tk_messageBox -type ok -icon warning -message [_ "Invalid aspect ArgumentList: %s (%s), aspect skipped!" $arglist $why]
            return
        }
        set aspectcount 0
        incr aspectcount
        set fr aspect$aspectcount
        while {[winfo exists $aspectlist.$fr]} {
            incr aspectcount
            set fr aspect$aspectcount
        }
        set f [$aspect attribute frame]
        if {$f eq {}} {
            set attrs [$aspect cget -attributes]
            lappend attrs frame $fr
            $aspect configure -attributes $attrs
        } else {
            set attrs [$aspect cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $aspect configure -attributes $attrs
        }
        set aspectframe [ttk::frame $aspectlist.$fr]
        $aspectlist add $aspectframe -text [_ "Aspect %d" $aspectcount] -sticky news
        set eventid_ [LabelEntry $aspectframe.eventid \
                      -label [_m "Label|When this event occurs"] \
                      -text $evstring]
        pack $eventid_ -fill x -expand yes
        set argl_ [LabelEntry $aspectframe.arglist \
                   -label [_m "Label|the following lamp arguments will be sent."] \
                   -text $arglist]
        pack $argl_ -fill x -expand yes
        set del [ttk::button $aspectframe.delete \
                 -text [_m "Label|Delete Aspect"] \
                 -command [mytypemethod _deleteAspect $aspectlist $signal $aspect]]
        pack $del -fill x
    }
    typemethod _deleteAspect {aspectlist signal aspect} {
        set fr [$aspect attribute frame]
        $signal removeChild $aspect
        $aspectlist forget $aspectlist.$fr
        destroy $aspectlist.$fr
    }
    typemethod _addblankaspect {signal aspectlist} {
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
        $eventid setdata "00.00.00.00.00.00.00.00"
        $aspect addchild $eventid
        set arglist [SimpleDOMElement %AUTO% -tag "arglist"]
        $arglist setdata [list off off off off]
        $aspect addchild $arglist
        #$aspect display stderr
        $type _create_and_populate_signal_aspect $signal $aspectlist $aspect
    }
    typemethod _addblanksignal {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        $type _create_and_populate_signal $signal
    }
    typemethod _create_and_populate_sensor {sensor} {
        incr sensorcount
        set fr sensor$sensorcount
        set f [$sensor attribute frame]
        if {$f eq {}} {
            set attrs [$sensor cget -attributes]
            lappend attrs frame $fr
            $sensor configure -attributes $attrs
        } else {
            set attrs [$sensor cget -attributes]
            set findx [lsearch -exact $attrs frame] 
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $sensor configure -attributes $attrs
        }
        set sensframe [ttk::frame $sensors.$fr]
        $sensors add $sensframe \
              -text [_ "Sensor %d" $sensorcount] -sticky news
        set address_ [LabelSpinBox $sensframe.addressSB \
                      -label [_m "Label|Address"] \
                      -range {0 65535 1}]
        pack $address_ -fill x -expand yes
        set address [$sensor getElementsByTagName "address"]
        if {[llength $address] == 1} {
            $address_ set [$address data]
        } else {
            $address_ set 0
        }
        foreach tag {description filterthresh filterselect polarity onevent 
                     offevent} \
              lab [list [_m "Label|Description"] [_m "Label|Filter Threshold"] \
                   [_m "Label|Filter Select"] [_m "Label|Polarity"] \
                   [_m "Label|On EventID"] \
                   [_m "Label|Off EventID"]] \
              wcons {LabelEntry LabelSpinBox LabelComboBox LabelComboBox 
                     LabelEntry LabelEntry} \
              default {{} 0 noise normal {} {}} {
             set widget [$wcons $sensframe.$tag -label $lab]
             switch $tag {
                 filterthresh {
                     $widget configure -range {0 31 1}
                     $widget set 0
                 }
                 filterselect {
                     $widget configure \
                           -values [::ctiacela::selecttype cget -values] \
                           -editable no
                     $widget set [lindex [$widget configure -values] 0]
                 }
                 polarity {
                     $widget configure \
                           -values [::ctiacela::polaritytype cget -values] \
                           -editable no
                     $widget set [lindex [$widget configure -values] 0]
                 }
             }
             $widget configure -text $default
             pack $widget -fill x -expand yes
             set tagele [$sensor getElementsByTagName $tag]
             if {[llength $tagele] > 0} {
                 #puts stderr "*** $type _create_and_populate_sensor: tag = $tag"
                 #puts stderr "*** $type _create_and_populate_sensor: tag data is [[lindex $tagele 0] data]"
                 $widget configure -text [[lindex $tagele 0] data]
             }
         }
         set delsensor [ttk::button $sensframe.delsensor \
                         -text [_m "Label|Delete sensor"] \
                         -command [mytypemethod _deleteSensor $sensor]]
         pack $delsensor -fill x
    }
    typemethod _addblanksensor {} {
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        set sensor [SimpleDOMElement %AUTO% -tag "sensor"]
        $cdi addchild $sensor
        $type _create_and_populate_sensor $sensor
    }
    typemethod _deleteSensor {sensor} {
        set fr [$sensor attribute frame]
        set cdis [$configuration getElementsByTagName OpenLCB_Acela -depth 1]
        set cdi [lindex $cdis 0]
        $cdi removeChild $sensor
        $sensors forget $sensors.$fr
        destory $sensors.$fr
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
            $type _copy_control_from_gui_to_XML $control
        }
        foreach signal [$cdi getElementsByTagName "signal"] {
            $type _copy_signal_from_gui_to_XML $signal
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
            $type _copy_sensor_from_gui_to_XML $sensor
        }
        if {$warnings > 0} {
            tk_messageBox -type ok -icon info \
                  -message [_ "There were %d warnings.  Please correct and try again." $warnings]
            return no
        }
        if {![catch {open $conffilename w} conffp]} {
            puts $conffp {<?xml version='1.0'?>}
            $configuration displayTree $conffp
        }
        return yes
    }
    typemethod _copy_control_from_gui_to_XML {control} {
        set fr [$control attribute frame]
        set frbase $controls.$fr
        set address [$control getElementsByTagName "address"]
        if {[llength $address] < 1} {
            set address [SimpleDOMElement %AUTO% -tag "address"]
            $control addchild $address
        }
        $address setdata [$frbase.addressSB get]
        foreach tag {description pulsewidth blinkperiod activate deactivate 
            pulseon pulseoff blink revblink} {
            set tagval [$frbase.$tag get]
            if {[lsearch {activate deactivate pulseon pulseoff blink revblink} $tag] >=0} {
                if {$tagval ne "" && [catch {lcc::eventidstring validate $tagval}]} {
                    tk_messageBox -type ok -icon warning \
                          -message [_ "Event ID for %s is not a valid event id string: %s!" $tag $tagval]
                    set tagval {}
                    incr warnings
                }
            }
            if {$tagval eq ""} {
                set tagele [$control getElementsByTagName $tag]
                if {[llength $tagele] == 1} {
                    $control removeChild $tagele
                }
            } else {
                set tagele [$control getElementsByTagName $tag]
                if {[llength $tagele] < 1} {
                    set tagele [SimpleDOMElement %AUTO% -tag $tag]
                    $control addchild $tagele
                }
                $tagele setdata $tagval
            }
        }
    }
    typemethod _copy_signal_from_gui_to_XML {signal} {
        set fr [$signal attribute frame]
        set frbase $signals.$fr
        set address [$signal getElementsByTagName "address"]
        if {[llength $address] < 1} {
            set address [SimpleDOMElement %AUTO% -tag "address"]
            $signal addchild $address
        }
        $address setdata [$frbase.addressSB get]
        foreach tag {description signalcommand} {
            set tagval [$frbase.$tag get]
            if {$tagval eq ""} {
                set tagele [$signal getElementsByTagName $tag]
                if {[llength $tagele] == 1} {
                    $signal removeChild $tagele
                }
            } else {
                set tagele [$signal getElementsByTagName $tag]
                if {[llength $tagele] < 1} {
                    set tagele [SimpleDOMElement %AUTO% -tag $tag]
                    $signal addchild $tagele
                }
                $tagele setdata $tagval
            }
        }
        set aspectlist $frbase.eventaspectlist
        foreach aspect [$signal getElementsByTagName "aspect"] {
            set eventidtag [$aspect getElementsByTagName "eventid"]
            set arglisttag [$aspect getElementsByTagName "arglist"]
            set fr [$aspect attribute frame]
            set aspectframe $aspectlist.$fr
            set eventid "[$aspectframe.eventid get]"
            if {[catch {lcc::eventidstring validate $eventid}]} {
                tk_messageBox -type ok -icon warning -message [_ "Aspect EventID malformed: %s" $eventid]
                incr warnings
            } else {
                $eventidtag setdata "$eventid"
            }
            set arglist "[$aspectframe.arglist get]"
            if {[catch {AspectArgumentList validate $arglist}]} {
                tk_messageBox -type ok -icon warning -message [_ "Aspect aspect lamp arglist malformed: %s" $arglist]
                incr warnings
            } else {
                $arglisttag setdata "$arglist"
            }
        }
    }
    typemethod _copy_sensor_from_gui_to_XML {sensor} {
        set fr [$sensor attribute frame]
        set frbase $sensors.$fr
        set address [$sensor getElementsByTagName "address"]
        if {[llength $address] < 1} {
            set address [SimpleDOMElement %AUTO% -tag "address"]
            $sensor addchild $address
        }
        $address setdata [$frbase.addressSB get]
        foreach tag {description filterthresh filterselect polarity onevent 
                     offevent} {
            set tagval [$frbase.$tag get]
            if {[lsearch {onevent offevent} $tag] >=0} {
                if {$tagval ne "" && [catch {lcc::eventidstring validate $tagval}]} {
                    tk_messageBox -type ok -icon warning \
                          -message [_ "Event ID for %s is not a valid event id string: %s!" $tag $tagval]
                    incr warnings
                    set tagval {}
                }
            }
            if {$tagval eq ""} {
                set tagele [$sensor getElementsByTagName $tag]
                if {[llength $tagele] == 1} {
                    $sensor removeChild $tagele
                }
            } else {
                set tagele [$sensor getElementsByTagName $tag]
                if {[llength $tagele] < 1} {
                    set tagele [SimpleDOMElement %AUTO% -tag $tag]
                    $sensor addchild $tagele
                }
                $tagele setdata $tagval
            }
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

