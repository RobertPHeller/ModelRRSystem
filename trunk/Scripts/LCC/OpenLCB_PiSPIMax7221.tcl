#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun May 14 09:33:18 2017
#  Last Modified : <170826.2049>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
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


## @page OpenLCB_PiSPIMax7221 OpenLCB PiSPIMax7221 node
# @brief OpenLCB PiSPIMax7221 node
#
# @section PiSPIMax7221SYNOPSIS SYNOPSIS
#
# OpenLCB_PiSPIMax7221 [-configure] [-sampleconfiguration] [-debug] [-test all|m-n] [-configuration confgile]
#
# @section PiSPIMax7221DESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for the a Max7221 
# based signal driver.  
#
# @section PiSPIMax7221PARAMETERS PARAMETERS
#
# None
#
# @section PiSPIMax7221OPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_PiSPIMax7221.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is PiSPIMax7221conf.xml.
# @arg -debug Turns on debug logging.
# @arg -test all|n-m Test all or signals n though m.  Run continously until 
# killed.
# @par
#
# @section PiSPIMax7221CONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section PiSPIMax7221AUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_PiSPIMax7221]

package require Tclwiringpi;#  require the Tclwiringpi package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common config code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::type Binary8 {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
        
    typemethod validate {value} {
        if {[regexp {^B[01]{8}$} $value] < 1} {
            error [_ "Not a Binary8 value: %s" $value]
        } else {
            return $value
        }
    }
    typemethod valueof {value} {
        if {[regexp {^B([01]{8})$} $value => bits] < 1} {
            error [_ "Not a Binary8 value: %s" $value]
        } else {
            set result 0
            foreach b [split $bits ""] {
                set result [expr {($result << 1) + $b}]
            }
            return $result
        }
    }
    typemethod convertto {byte} {
        set result B
        for {set i 7} {$i >= 0} {incr i -1} {
            append result [expr {($byte >> $i) & 1}]
        }
        return $result
    }
}
    
snit::integer SPIPort -min 0 -max 1
snit::integer Signal  -min 1 -max 8
snit::type Aspect {
    pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
        
    typemethod validate {value} {
        if {[llength $value] == 2} {
            lcc::EventID validate [lindex $value 0]
            Binary8 validate [lindex $value 1]
        } else {
            error [_ "Not a valid aspect: %s" $value]
        }
    }
}    
snit::listtype AspectList -minlen 1 -type Aspect

snit::type OpenLCB_PiSPIMax7221 {
    #** This class implements a OpenLCB interface to signals implemented 
    # using a SPI connected MAX7221 on a Raspberry Pi.
    #
    # Each instance manages one signal.  The typemethods implement the overall
    # OpenLCB node.
    #
    # Instance options:
    # @arg -signalnum The Signal number
    # @arg -aspectlist The Aspects for this signal.
    # @arg -description Description of the pin.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  signallist {};#     Signal list
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  defaultspi 0;#      The default SPI channel.
    typevariable  spi 0;#             The SPI channel.
    typevariable  speed 2500000;#     The SPI Speed (2.5Mhz).
    typecomponent xmlsignalconfig;# Common Signal config object
    
    # the opcodes for the MAX7221 and MAX7219
    typevariable OP_NOOP   0
    typevariable OP_DIGIT0 1
    typevariable OP_DIGIT1 2
    typevariable OP_DIGIT2 3
    typevariable OP_DIGIT3 4
    typevariable OP_DIGIT4 5
    typevariable OP_DIGIT5 6
    typevariable OP_DIGIT6 7
    typevariable OP_DIGIT7 8
    typevariable OP_DECODEMODE  9
    typevariable OP_INTENSITY   10
    typevariable OP_SCANLIMIT   11
    typevariable OP_SHUTDOWN    12
    typevariable OP_DISPLAYTEST 15
    

    typecomponent editContextMenu
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages GPIO pins, consuming or producing
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
        set test [from argv -test {}]
        set conffile [from argv -configuration "pispimax722conf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmlsignalconfig [XmlConfiguration create %AUTO% {
                             <configure>
                             <string option="-description" tagname="description">Description</string>
                             <int option="-signalnum" tagname="number" min="1" max="8" default="1">Signal Number</int>
                             <group option="-aspectlist" tagname="aspect" repname="Aspect" mincount="0" maxcount="unlimited">
                             <eventid tagname="eventid">Event ID</eventid>
                             <bytebits tagname="bits">Aspect Bits</bytebits>
                             </group>
                             </configure>}]
        if {$configureator} {
            $type ConfiguratorGUI $conffile
            return
        }
        if {$sampleconfiguration} {
            $type SampleConfiguration $conffile
            return
        }
        if {$test ne {}} {
            $type TestSignals $conffile $test
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
        getIdentification [$configuration getElementsByTagName "identification"] nodename nodedescriptor
        if {[catch {eval [list lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor \
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB PiSPIMax7221" \
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
        set spiele [$configuration getElementsByTagName "spichannel"]
        if {[llength $spiele] > 0} {
            set spiele [lindex $spiele 0]
            set spi [$spiele data]
            SPIPort validate $spi
        }
        
        # Connect to the MAX7221.
        wiringPiSPISetup $spi $speed
        wiringPiSPIDataRW $spi [list $OP_DISPLAYTEST 1]
        after 10000
        wiringPiSPIDataRW $spi [list $OP_DISPLAYTEST 0]
        wiringPiSPIDataRW $spi [list $OP_DECODEMODE  0]
        wiringPiSPIDataRW $spi [list $OP_SHUTDOWN    1]
        
        foreach signal [$configuration getElementsByTagName "signal"] {
            set signalcommand [$xmlsignalconfig processConfig $signal [list $type create %AUTO%]]
            set signal [eval $signalcommand]
            lappend signallist $signal
        }
        if {[llength $signallist] == 0} {
            ::log::logError [_ "No signals specified!"]
            exit 93
        }
        if {[llength $eventsconsumed] == 0} {
            ::log::logError [_ "No Events Consumed!"]
            exit 92
        }
        foreach ev $eventsconsumed {
            $transport ConsumerIdentified $ev unknown
        }
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
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
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
            }
            report {
                foreach s $signallist {
                    ::log::log debug "*** $type _eventHandler: signal is [$s cget -signalnum]"
                    ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $s consumeEvent $eventid
                    
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
    
    #*** Test function
    
    typemethod TestSignals {conffile test} {
        ::log::lvChannelForall stderr
        ::log::lvSuppress info 0
        ::log::lvSuppress notice 0
        ::log::lvSuppress debug 0
        ::log::lvCmdForall [mytypemethod LogPuts]
        
        ::log::logMsg [_ "%s starting (testing)" $type]

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
            set spiele [$configuration getElementsByTagName "spichannel"]
        if {[llength $spiele] > 0} {
            set spiele [lindex $spiele 0]
            set spi [$spiele data]
            SPIPort validate $spi
        }
        
        # Connect to the MAX7221.
        wiringPiSPISetup $spi $speed
        wiringPiSPIDataRW $spi [list $OP_DISPLAYTEST 0]
        wiringPiSPIDataRW $spi [list $OP_DECODEMODE  0]
        wiringPiSPIDataRW $spi [list $OP_SHUTDOWN    1]
        
        if {$test eq "all"} {set test 1-8}
        if {[scan $test {%d-%d} first last] != 2} {
            ::log::logError [_ "Bad test format: %s" $test]
            exit 97
        }
        set signallist [list]
        for {set sig $first} {$sig <= $last} {incr sig} {
            lappend signallist [$type create %AUTO% -signalnum $sig \
                                -aspectlist [list [list \
                                                   [lcc::EventID create %AUTO% \
                                                    -eventidstring 11.22.33.44.55.66.77.88] \
                                                   B00000000]]]
        }
        
        while 1 {
            foreach s $signallist {
                $s test
            }
        }
    }
    
    #*** Configuration GUI
    
    typecomponent main;# Main Frame.
    typecomponent scroll;# Scrolled Window.
    typecomponent editframe;# Scrollable Frame
    typevariable    spichannel 0;# The SPI channel
    typecomponent   signalnotebook;# Pin list
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_PiSPIMax7221/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set spiele [SimpleDOMElement %AUTO% -tag "spichannel"]
        $cdi addchild $spiele
        $spiele setdata 0
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $signal addchild $descrele
        $descrele setdata "Sample Signal"
        set signalno [SimpleDOMElement %AUTO% -tag "number"]
        $signal addchild $signalno
        $signalno setdata 1
        set eid 0
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID nextid]
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"]
        $aspect addchild $aspectbits
        $aspectbits setdata B00100001;# green over red
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID nextid]
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00010001;# yellow over red 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID nextid]
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001001;# red over red 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID nextid]
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001010;# red over yellow 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [$generateEventID nextid]
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001100;# red over green 
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_PiSPIMax7221 container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_PiSPIMax7221 Configuration Editor (%s)" $conffile]
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
        $xmlsignalconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
        set spichannelLE [LabelComboBox $frame.spichannelLE \
                            -label [_m "Label|SPI Channel"] \
                            -textvariable [mytypevar spichannel] \
                            -values {0 1}]
        pack $spichannelLE -fill x -expand yes
        set spiele [$cdi getElementsByTagName "spichannel"]
        if {[llength $spiele] > 0} {
            set spiele [lindex $spiele 0]
            set spichannel [$spiele data]
        }

        set signalnotebook [ScrollTabNotebook $frame.signals]
        pack $signalnotebook -expand yes -fill both
        foreach signal [$cdi getElementsByTagName "signal"] {
            set signalframe [$xmlsignalconfig createGUI $signalnotebook \
                             signal $cdi $signal [_m "Label|Delete Signal"] \
                             [mytypemethod _addframe] [mytypemethod _delframe]]
        }
        set addsignal [ttk::button $frame.addsignal \
                    -text [_m "Label|Add another signal"] \
                    -command [mytypemethod _addblanksignal]]
        pack $addsignal -fill x
    }
    typemethod _addframe {parent frame count} {
        $signalnotebook add $frame -text [_ "Signal %d" $count] -sticky news
    }
    typemethod _delframe {frame} {
        $signalnotebook forget $frame
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
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
        set spiele [$cdi getElementsByTagName "spichannel"]
        if {[llength $spiele] < 1} {
            set spiele [SimpleDOMElement %AUTO% -tag "spichannel"]
            $cdi addchild $spiele
        }
        $spiele setdata $spichannel
        
        foreach signal [$cdi getElementsByTagName "signal"] {
            $xmlsignalconfig copyFromGUI $signalnotebook $signal warnings
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
    typemethod _addblanksignal {} {
        #** Create a new blank signal.
        
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
        set cdi [lindex $cdis 0]
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        set signalframe [$xmlsignalconfig createGUI $signalnotebook \
                         signal $cdi $signal [_m "Label|Delete Signal"] \
                         [mytypemethod _addframe] [mytypemethod _delframe]]
    }
    
    
    
    #*** Signal instances
    option -signalnum -readonly yes -type Signal -default 1
    option -description -readonly yes -default {}
    option -aspectlist -readonly yes -type AspectList \
          -default {{11.22.33.44.55.66.77.88 B00000000}}
    constructor {args} {
        # Construct an instance for a signal
        #
        # @param ... Options:
        # @arg -signalnum The Signal number
        # @arg -aspectlist The Aspects for this signal.
        # @arg -description Description of the pin.
        # @par
        
        $self configurelist $args
        foreach e_b [$self cget -aspectlist] {
            lassign $e_b e b
            lappend eventsconsumed $e
        }
    }
    method consumeEvent {event} {
        #** Handle an incoming event.
        #
        # @param event The event to handle.
        
        ::log::log debug "*** $self consumeEvent $event"
        foreach aspevbits [$self cget -aspectlist] {
            foreach {aspev bits} $aspevbits {break}
            if {[$event match $aspev]} {
                wiringPiSPIDataRW $spi [list [Binary8 valueof $bits] [$self cget -signalnum] ]
                return true
            }
        }
        return false
    }
    method test {} {
        for {set ibit 0} {$ibit < 8} {incr ibit} {
            ::log::log debug "*** $self test: ibit = $ibit"
            wiringPiSPIDataRW $spi [list [$self cget -signalnum] [expr {0x01 << $ibit}]]
            after 1000
        }
        wiringPiSPIDataRW $spi [list [$self cget -signalnum] 0]
        ::log::log debug "*** $self test: complete"
    }
    
}

vwait forever

