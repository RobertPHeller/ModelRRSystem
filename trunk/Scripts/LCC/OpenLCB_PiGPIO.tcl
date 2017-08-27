#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Aug 7 10:36:33 2016
#  Last Modified : <170826.2041>
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


## @page OpenLCB_PiGPIO OpenLCB PiGPIO node
# @brief OpenLCB PiGPIO node
#
# @section PiGPIOSYNOPSIS SYNOPSIS
#
# OpenLCB_PiGPIO [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section PiGPIODESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for the GPIO 
# pins on a Raspberry Pi.  
#
# @section PiGPIOPARAMETERS PARAMETERS
#
# none
#
# @section PiGPIOOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_PiGPIO.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is pigpioconf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section PiGPIOCONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section PiGPIOAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_PiGPIO]

package require Tclwiringpi;#  require the Tclwiringpi package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::enum PinModes -values {disabled in out high low}
snit::type GPIOPinNo {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
    
    typevariable BCMPins -array {
        0 17
        1 18
        2 27
        3 22
        4 23
        5 24
        6 25
        7 4
        21 5
        22 6
        23 13
        24 19
        25 26
        26 12
        27 16
        28 20
        29 21
    }
    typevariable GPIOPins -array {
        17 0
        18 1
        27 2
        22 3
        23 4
        24 5
        25 6
        4 7
        5 21
        6 22
        13 23
        19 24
        26 25
        12 26
        16 27
        20 28
        21 29
    }
    typemethod validate {pinno} {
        if {[info exists BCMPins($pinno)]} {
            return $pinno
        } else {
            error [_ "Not a GPIO pin number: %s" $pinno]
        }
    }
    typemethod AllPins {} {
        return [lsort -integer [array names BCMPins]]
    }
    typemethod BCMPinNo {gpiopinno} {
        if {[info exists BCMPins($gpiopinno)]} {
            return $BCMPins($gpiopinno)
        } else {
            error [_ "Not a GPIO pin number: %s" $gpiopinno]
        }
    }
    typemethod GPIOPinNo {bcmpinno} {
        if {[info exists GPIOPins($bcmpinno)]} {
            return $GPIOPins($bcmpinno)
        } else {
            error [_ "Not a BCM pin number: %s" $bcmpinno]
        }
    }
}


snit::type OpenLCB_PiGPIO {
    #** This class implements a OpenLCB interface to the GPIO pins of a 
    # Raspberry Pi.
    #
    # Each instance manages one pin.  The typemethods implement the overall
    # OpenLCB node.
    #
    # Instance options:
    # @arg -pinnumber The pin number
    # @arg -pinmode   The pin's mode
    # @arg -pinin0    Event ID to send when the pin's input value goes to 0.
    # @arg -pinin1    Event ID to send when the pin's input value goes to 1.
    # @arg -pinout0   Event ID to trigger setting the pin's output to 0.
    # @arg -pinout1   Event ID to trigger setting the pin's output to 1.
    # @arg -description Description of the pin.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  pinlist {};#        Pin list
    typevariable  consumers {};#      Pins that consume events (outputs)
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Pins that produce events (inputs)
    typevariable  eventsproduced {};# Events produced.
    typevariable  defaultpollinterval 500;# Default poll interval
    typevariable  pollinterval 500;#  Poll interval
    typevariable  GPIOCMD;#           gpio command
    typecomponent editContextMenu
    typecomponent xmlgpioconfig;# Common GPIO config object
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages GPIO pins, consuming or producing
        # events.
        
        set GPIOCMD [auto_execok "gpio"]
        
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
        set conffile [from argv -configuration "pigpioconf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmlgpioconfig [XmlConfiguration create %AUTO% {
                           <configure>
                           <string option="-description" tagname="description">Description</string>
                           <enum option="-pinnumber" tagname="number" enums="0 1 2 3 4 5 6 7 21 22 23 24 25 26 27 28 29">GPIO Pin Number</enum>
                           <enum option="-pinmode" tagname="mode" enums="disabled in out high low">Pin Mode</enum>
                           <eventid option="-pinin0" tagname="pinin0">Pin Low In Event</eventid>
                           <eventid option="-pinin1" tagname="pinin1">Pin High In Event</eventid>
                           <eventid option="-pinout0" tagname="pinout0">Pin Low Out Event</eventid>
                           <eventid option="-pinout1" tagname="pinout1">Pin High Out Event</eventid>
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
                          -softwaremodel "OpenLCB PiGPIO" \
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
        set pollele [$configuration getElementsByTagName "pollinterval"]
        if {[llength $pollele] > 0} {
            set pollele [lindex $pollele 0]
            set pollinterval [$pollele data]
        }
        
        exec $GPIOCMD unexportall;# flush all existing exported pins
        
        foreach pin [$configuration getElementsByTagName "pin"] {
            set pincommand [$xmlgpioconfig processConfig $pin [list $type create %AUTO%]]
            set consume no
            set produce no
            set pin [eval $pincommand]
            switch [$pin cget -pinmode] {
                in {
                    set produce yes
                }
                out -
                high -
                low {
                    set consume yes
                }
            }
            if {$consume} {lappend consumers $pin}
            if {$produce} {lappend producers $pin}
            if {!$consume && !$produce} {
                ::log::log warning [_ "Useless pin (%d) (neither consumes or produces events)" $thepin]
            } else {
                lappend pinlist $pin
            }
        }
        if {[llength $pinlist] == 0} {
            ::log::logError [_ "No enabled pins specified!"]
            exit 93
        }
        wiringPiSetupSys
        foreach p $producers {$p initpinval}
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
        foreach ev $eventsproduced {
            $transport ProducerIdentified $ev unknown
        }
        
        after $pollinterval [mytypemethod _poll]
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod _poll {} {
        #** Polling function.  Polls all of the sensors.
        
        foreach p $producers {
            $p Poll
        }
        after $pollinterval [mytypemethod _poll]
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
                        ::log::log debug "*** $type _eventHandler: pin is [$c cget -pinnumber]"
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
                    foreach evpair [$p readsensor $eventid] {
                        foreach {ev state} $evpair {break}
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
                foreach p $producers {
                    foreach evpair [$p readsensor *] {
                        foreach {ev state} $evpair {break}
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            report {
                foreach c $consumers {
                    ::log::log debug "*** $type _eventHandler: pin is [$c cget -pinnumber]"
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
    typevariable    pollinginterval 500;# polling interval.
    typecomponent   pins;# Pin list
    typecomponent   generateEventID
    
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
            {command "[_m {Menu|Help|EventExchange node for Raspberry Pi GPIO pins}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for Raspberry Pi GPIO pins"}}
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_PiGPIO/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiGPIO -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set pollele [SimpleDOMElement %AUTO% -tag "pollinterval"]
        $cdi addchild $pollele
        $pollele setdata 500
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set pin [SimpleDOMElement %AUTO% -tag "pin"]
        $cdi addchild $pin
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $pin addchild $descrele
        $descrele setdata "Sample Input Pin"
        set pinno [SimpleDOMElement %AUTO% -tag "number"]
        $pin addchild $pinno
        $pinno setdata 0
        set pinmode [SimpleDOMElement %AUTO% -tag "mode"]
        $pin addchild $pinmode
        $pinmode setdata in
        foreach eventtag {pinin0 pinin1} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $pin addchild $tagele
            $tagele setdata [$generateEventID nextid]
        }
        set pin [SimpleDOMElement %AUTO% -tag "pin"]
        $cdi addchild $pin
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $pin addchild $descrele
        $descrele setdata "Sample Output Pin"
        set pinno [SimpleDOMElement %AUTO% -tag "number"]
        $pin addchild $pinno
        $pinno setdata 1
        set pinmode [SimpleDOMElement %AUTO% -tag "mode"]
        $pin addchild $pinmode
        $pinmode setdata out
        foreach eventtag {pinout0 pinout1} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $pin addchild $tagele
            $tagele setdata [$generateEventID nextid]
        }
        set attrs [$cdi cget -attributes]
        lappend attrs lastevid [$generateEventID currentid]
        $cdi configure -attributes $attrs
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiGPIO -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_PiGPIO container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_PiGPIO Configuration Editor (%s)" $conffile]
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
        $xmlgpioconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
        set pollintervalLE [LabelSpinBox $frame.pollintervalLE \
                            -label [_m "Label|Poll Interfal"] \
                            -textvariable [mytypevar pollinginterval] \
                            -range {100 5000 10}]
        pack $pollintervalLE -fill x -expand yes
        set pollele [$cdi getElementsByTagName "pollinterval"]
        if {[llength $pollele] > 0} {
            set pollele [lindex $pollele 0]
            set pollinginterval [$pollele data]
        }
        set pins [ScrollTabNotebook $frame.pins]
        pack $pins -expand yes -fill both
        foreach pin [$cdi getElementsByTagName "pin"] {
            set pinframe [$xmlgpioconfig createGUI $pins pin $cdi \
                          $pin [_m "Label|Delete Pin"] \
                          [mytypemethod _addframe] [mytypemethod _delframe]]
        }
        set addpin [ttk::button $frame.addpin \
                    -text [_m "Label|Add another pin"] \
                    -command [mytypemethod _addblankpin]]
        pack $addpin -fill x
    }
    typemethod _addframe {parent frame count} {
        $pins add $frame -text [_ "Pin %d" $count] -sticky news
    }
    typemethod _delframe {frame} {
        $pins forget $frame
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiGPIO -depth 1]
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
        set pollele [$cdi getElementsByTagName "pollinterval"]
        if {[llength $pollele] < 1} {
            set pollele [SimpleDOMElement %AUTO% -tag "pollinterval"]
            $cdi addchild $pollele
        }
        $pollele setdata $pollinginterval
        
        foreach pin [$cdi getElementsByTagName "pin"] {
            $xmlgpioconfig copyFromGUI $pins $pin warnings
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
    typemethod _addblankpin {} {
        #** Create a new blank pin.
        
        set cdis [$configuration getElementsByTagName OpenLCB_PiGPIO -depth 1]
        set cdi [lindex $cdis 0]
        set pin [SimpleDOMElement %AUTO% -tag "pin"]
        $cdi addchild $pin
        set pinframe [$xmlgpioconfig createGUI $pins pin $cdi $pin \
                      [_m "Label|Delete Pin"] \
                      [mytypemethod _addframe] [mytypemethod _delframe]]
    }
    
    
    
    #*** Pin instances
    variable oldPin 0;# The saved value of the pin (input mode only)
    option -pinnumber -readonly yes -type GPIOPinNo -default 0
    option -pinmode -readonly yes -type PinModes -default disabled
    option -pinin0 -type lcc::EventID_or_null -readonly yes -default {}
    option -pinin1 -type lcc::EventID_or_null -readonly yes -default {}
    option -pinout0 -type lcc::EventID_or_null -readonly yes -default {}
    option -pinout1 -type lcc::EventID_or_null -readonly yes -default {}
    option -description -readonly yes -default {}
    constructor {args} {
        # Construct an instance for a GPIO pin
        #
        # @param ... Options:
        # @arg -pinnumber The pin number
        # @arg -pinmode   The pin's mode
        # @arg -pinin0    Event ID to send when the pin's input value goes to 0.
        # @arg -pinin1    Event ID to send when the pin's input value goes to 1.
        # @arg -pinout0   Event ID to trigger setting the pin's output to 0.
        # @arg -pinout1   Event ID to trigger setting the pin's output to 1.
        # @arg -description Description of the pin.
        # @par
        
        $self configurelist $args
        set bcmpinno [GPIOPinNo BCMPinNo [$self cget -pinnumber]]
        if {[$self cget -pinmode] eq "disabled"} {
            exec "$GPIOCMD" unexport $bcmpinno
        } else {
            exec "$GPIOCMD" export $bcmpinno [$self cget -pinmode]
        }
    }
    method initpinval {} {
        set oldPin [digitalRead [GPIOPinNo BCMPinNo [$self cget -pinnumber]]]
    }
    method readsensor {event} {
        if {[$self cget -pinmode] ne "in"} {return [list {} unknown]}
        set events [list]
        set state [digitalRead [GPIOPinNo BCMPinNo [$self cget -pinnumber]]]
        set ev0 [$self cget -pinin0]
        if {$ev0 ne {}} {
            if {$event eq "*" || [$event match $ev0]} {
                if {$state == 0} {
                    lappend events [list $ev0 valid]
                } else {
                    lappend events [list $ev0 invalid]
                }
            }
        }
        set ev1 [$self cget -pinin1]
        if {$ev1 ne {}} {
            if {$event eq "*" || [$event match $ev1]} {
                if {$state == 1} {
                    lappend events [list $ev1 valid]
                } else {
                    lappend events [list $ev1 invalid]
                }
            }
        }
        return $events
    }
    method Poll {} {
        #** Poll the pin
        
        if {[$self cget -pinmode] ne "in"} {return}
        set v [digitalRead [GPIOPinNo BCMPinNo [$self cget -pinnumber]]]
        if {$v != $oldPin} {
            set oldPin $v
            set event [$self cget -pinin$oldPin]
            if {$event ne {}} {
                $type sendEvent $event
            }
        }
    }
    method consumeEvent {event} {
        #** Handle an incoming event.
        #
        # @param event The event to handle.
        
        ::log::log debug "*** $self consumeEvent $event"
        if {[$event match [$self cget -pinout0]]} {
            digitalWrite [GPIOPinNo BCMPinNo [$self cget -pinnumber]] 0
            return true
        } elseif {[$event match [$self cget -pinout1]]} {
            digitalWrite [GPIOPinNo BCMPinNo [$self cget -pinnumber]] 1
            return true
        }
        return false
    }
}

vwait forever
