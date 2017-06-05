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
#  Last Modified : <170605.1132>
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
# OpenLCB_PiSPIMax7221 [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
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
    typevariable  speed 100000;#      The SPI Speed (200Khz).
    
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
        set conffile [from argv -configuration "pispimax722conf.xml"]
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
        wiringPiSPIDataRW $spi [list $OP_DISPLAYTEST 0]
        wiringPiSPIDataRW $spi [list $OP_DECODEMODE  0]
        wiringPiSPIDataRW $spi [list $OP_SHUTDOWN    1]
        
        foreach signal [$configuration getElementsByTagName "signal"] {
            set signalcommand [list $type create %AUTO%]
            set signo [$signal getElementsByTagName "number"]
            if {[llength $signo] != 1} {
                ::log::logError [_ "Missing or multiple signal numbers"]
                exit 94
            }
            set thesigno [$signo data]
            Signal validate $thesigno
            
            lappend signalcommand -signalnum $thesigno
            set description [$signal getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend signalcommand -description [[lindex $description 0] data]
            }
            set aspectlist [list]
            foreach aspect [$signal getElementsByTagName "aspect"] {
                set evele [$aspect getElementsByTagName "eventid"]
                if {[llength $evele] != 1} {
                    error [_ "Missing or multiple aspect events"]
                }
                set ev [lcc::EventID create %AUTO% -eventidstring [[lindex $evele 0] data]]
                set aspectbitsele  [$aspect getElementsByTagName "bits"]
                if {[llength $aspectbitsele] != 1} {
                    error [_ "Missing or multiple aspect bits"]
                }
                set aspectbits [[lindex $aspectbitsele 0] data]
                Binary8 validate $aspectbits
                lappend aspectlist [list $ev $aspectbits]
                lappend eventsconsumed $ev
            }
            AspectList validate $aspectlist
            lappend signalcommand -aspectlist $aspectlist
            set signal [eval $signalcommand]
            lappend signallist $signal
        }
        if {[llength $signallist] == 0} {
            ::log::logError [_ "No signals specified!"]
            exit 93
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
    
    
    #*** Configuration GUI
    
    typecomponent main;# Main Frame.
    typecomponent scroll;# Scrolled Window.
    typecomponent editframe;# Scrollable Frame
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typevariable    spichannel 0;# The SPI channel
    typecomponent   signalnotebook;# Pin list
    typevariable    signalcount 0;# pin count
    typevariable    aspectcounts -array {}
    
    
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
        set spiele [SimpleDOMElement %AUTO% -tag "spichannel"]
        $cdi addchild $spiele
        $spiele setdata 0
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
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"]
        $aspect addchild $aspectbits
        $aspectbits setdata B00100001;# green over red
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00010001;# yellow over red 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001001;# red over red 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001010;# red over yellow 
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        set aspectev [SimpleDOMElement %AUTO% -tag "eventid"]
        $aspect addchild $aspectev
        $aspectev setdata [format {05.01.01.01.22.00.00.%02x} $eid]
        incr eid
        set aspectbits [SimpleDOMElement %AUTO% -tag "bits"] 
        $aspect addchild $aspectbits
        $aspectbits setdata B00001100;# red over green 
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
            $type _create_and_populate_signal $signal
        }
        set addsignal [ttk::button $frame.addsignal \
                    -text [_m "Label|Add another signal"] \
                    -command [mytypemethod _addblanksignal]]
        pack $addsignal -fill x
    }
    typevariable warnings
    typemethod _saveexit {} {
        #** Save and exit.  Bound to the Save & Exit file menu item.
        # Saves the contents of the GUI as an XML file.
        
        set warnings 0
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
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
        set spiele [$cdi getElementsByTagName "spichannel"]
        if {[llength $spiele] < 1} {
            set spiele [SimpleDOMElement %AUTO% -tag "spichannel"]
            $cdi addchild $spiele
        }
        $spiele setdata $spichannel
        
        foreach signal [$cdi getElementsByTagName "signal"] {
            $type _copy_signal_from_gui_to_XML $signal
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
    typemethod _copy_signal_from_gui_to_XML {signal} {
        #** Copy from the GUI to the Signal XML
        # 
        # @param signal Signal XML element.
        
        set fr [$signal attribute frame]
        set frbase $signalnotebook.$fr
        set signalno [$signal getElementsByTagName "number"]
        if {[llength $signalno] < 1} {
            set signalno [SimpleDOMElement %AUTO% -tag "number"]
            $signal addchild $signalno
        }
        $signalno setdata [$frbase.signalno get]
        set description_ [$frbase.description get]
        if {$description_ eq ""} {
            set description [$signal getElementsByTagName "description"]
            if {[llength $description] == 1} {
                $signal removeChild $description
            }
        } else {
            set description [$signal getElementsByTagName "description"]
            if {[llength $description] < 1} {
                set description [SimpleDOMElement %AUTO% -tag "description"]
                $signal addchild $description
            }
            $description setdata $description_
        }
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _copy_aspect_from_gui_to_XML $signal $aspect
        }
    }
    typemethod _copy_aspect_from_gui_to_XML {signal aspect} {
        #** Copy from the GUI to the Signal's aspect XML
        #
        # @param signal Signal XML element.
        # @param aspect Aspect XML element.
        
        set fr [$signal attribute frame]
        set frbase $signalnotebook.$fr
        set afr [$aspect attribute frame]
        set afrbase $frbase.aspectNB.$afr
        set evstring [$afrbase.eventidLE get]
        set aspbits  [$afrbase.aspbitsLE get]
        if {[catch {Binary8 validate $aspbits}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Illformed Aspect bits: %s!" $aspbits]
            incr warnings
            set aspectbitsele [$aspect getElementsByTagName "bits"]
            if {[llength $aspectbitsele] > 0} {
                $aspect removeChild $aspectbitsele
            }
        } else {
            set aspectbitsele [$aspect getElementsByTagName "bits"]
            if {[llength $aspectbitsele] < 1} {
                set aspectbitsele [SimpleDOMElement %AUTO% -tag "bits"]
                $aspect addchild $aspectbitsele
            }
            $aspectbitsele setdata $aspbits
        }
        if {[catch {lcc::eventidstring validate $evstring}]} {
            tk_messageBox -type ok -icon warning \
                  -message [_ "Event ID for aspect %s is not a valid event id string: %s!" $aspbits $evstring]
            incr warnings
            set eventidele [$aspect getElementsByTagName "eventid"]
            if {[llength $eventidele] > 0} {
                $aspect removeChild $eventidele
            }
        } else {
            set eventidele [$aspect getElementsByTagName "eventid"]
            if {[llength $eventidele] < 1} {
                set eventidele [SimpleDOMElement %AUTO% -tag "eventid"]
                $aspect addchild $eventidele
            }
            $eventidele setdata $evstring
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
    typemethod _create_and_populate_signal {signal} {
        #** Create a tab for a  signal and populate it.
        #
        # @param signal The signal XML element.
        
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
        set signalframe [ttk::frame \
                      $signalnotebook.$fr]
        $signalnotebook add $signalframe \
              -text [_ "Signal %d" $signalcount] -sticky news
        set signalno_ [LabelSpinBox $signalframe.signalno \
                    -label [_m "Label|Signal Number"] \
                    -range {1 8 1}]
        $signalno_ set 1
        pack $signalno_ -fill x -expand yes
        set signalno [$signal getElementsByTagName "number"]
        if {[llength $signalno] == 1} {
            $signalno_ set [$signalno data]
        }
        set description_ [LabelEntry $signalframe.description \
                          -label [_m "Label|Description"]]
        pack $description_ -fill x -expand yes
        set description [$signal getElementsByTagName "description"]
        if {[llength $description] == 1} {
            $description_ configure -text [$description data]
        }
        # aspects...  
        set aspectNB [ScrollTabNotebook $signalframe.aspectNB]
        pack $aspectNB -fill both -expand yes
        if {![info exists aspectcounts($fr)]} {
            set aspectcounts($fr) 0
        }
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _create_and_populate_signal_aspect $signal $aspect
        }
        set addaspect [ttk::button $signalframe.addaspect \
                       -text [_m "Label|Add another aspect"] \
                       -command [mytypemethod _addaspect $signal]]
        pack $addaspect -fill x
        set delsignal [ttk::button $signalframe.deletesignal \
                       -text [_m "Label|Delete signal"] \
                       -command [mytypemethod _deleteSignal $signal]]
        pack $delsignal -fill x
    }
    typemethod _create_and_populate_signal_aspect {signal aspect} {
        #** Create and populate a signal aspect instance.
        #
        # @param signal Signal XML element.
        # @param aspect Aspect XML element.
        
        #puts stderr "$type _create_and_populate_signal_aspect $signal $aspect"
        set fr [$signal attribute frame]
        set frbase $signalnotebook.$fr
        incr aspectcounts($fr)
        set afr aspect$aspectcounts($fr)
        set af [$aspect attribute frame]
        #puts stderr "$type _create_and_populate_signal_aspect: fr = $fr, frbase = $frbase, afr = $afr, af = $af"        
        if {$af eq {}} {
            set attrs [$aspect cget -attributes]
            lappend attrs frame $afr
            $aspect configure -attributes $attrs
        } else {
            set attrs [$aspect cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $afr]
            $aspect configure -attributes $attrs
        }
        set aspectframe [ttk::frame \
                         $frbase.aspectNB.$afr]
        #puts stderr "$type _create_and_populate_signal_aspect: aspectframe = $aspectframe"
        $frbase.aspectNB add $aspectframe \
              -text [_ "Aspect %d" $aspectcounts($fr)] -sticky news
        set afrbase $aspectframe
        #puts stderr "$type _create_and_populate_signal_aspect: afrbase = $afrbase"
        set eventidLE [LabelEntry $afrbase.eventidLE \
                   -label [_m "Label|Event ID"]]
        pack $eventidLE -fill x -expand yes
        set eventidele [$aspect getElementsByTagName "eventid"]
        if {[llength $eventidele] < 1} {
            $eventidLE configure -text "00.00.00.00.00.00.00.00"
        } else {
            $eventidLE configure -text [[lindex $eventidele 0] data]
        }
        set aspbitsLE [LabelEntry $afrbase.aspbitsLE \
                       -label [_m "Label|Aspect Bits"]]
        pack $aspbitsLE -fill x -expand yes
        set aspectbitsele [$aspect getElementsByTagName "bits"]
        if {[llength $aspectbitsele] < 1} {
            $aspbitsLE configure -text [Binary8 convertto 0]
        } else {
            $aspbitsLE configure -text [[lindex $aspectbitsele 0] data]
        }
        set delaspect [ttk::button $afrbase.deleteaspect \
                       -text [_m "Label|Delete aspect"] \
                       -command [mytypemethod _deleteAspect $signal $aspect]]
        pack $delaspect -fill x
    }
    typemethod _addblanksignal {} {
        #** Create a new blank signal.
        
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
        set cdi [lindex $cdis 0]
        set signal [SimpleDOMElement %AUTO% -tag "signal"]
        $cdi addchild $signal
        $type _create_and_populate_signal $signal
    }
    typemethod _deleteSignal {signal} {
        #** Delete a signal
        #
        # @param signal The signal's XML element.
        
        set fr [$signal attribute frame]
        set cdis [$configuration getElementsByTagName OpenLCB_PiSPIMax7221 -depth 1]
        set cdi [lindex $cdis 0]
        $type _deleteallaspects $signal
        $cdi removeChild $signal
        $signalnotebook forget $signalnotebook.$fr
        destroy $signalnotebook.$fr
    }
    typemethod _deleteallaspects {signal} {
        #** Delete all aspects of a signal
        #
        # @param signal The signal whose aspects are to be removed.
        
        foreach aspect [$signal getElementsByTagName "aspect"] {
            $type _deleteAspect $signal $aspect
        }
    }
    typemethod _addaspect {signal} {
        #** Add an aspect to a signal.
        #
        # @param signal The signal's XML element.
        
        set aspect [SimpleDOMElement %AUTO% -tag "aspect"]
        $signal addchild $aspect
        $type _create_and_populate_signal_aspect $signal $aspect
    }
    typemethod _deleteAspect {signal aspect} {
        #** Delete a signal's aspect
        #
        # @param signal The signal's XML element.
        # @param aspect The aspects's XML element.
        
        #puts stderr "*** type _deleteAspect $signal $aspect"
        set fr [$signal attribute frame]
        #puts stderr "*** type _deleteAspect: fr = $fr"
        set frbase $signalnotebook.$fr
        #puts stderr "*** type _deleteAspect: frbase = $frbase"
        set afr [$aspect attribute frame]
        #puts stderr "*** type _deleteAspect: afr = $afr"
        set afrbase $frbase.aspectNB.$afr
        #puts stderr "*** type _deleteAspect: afrbase = $afrbase"
        $frbase.aspectNB forget $afrbase
        $signal removeChild $aspect
        destroy $afrbase
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
        $self test
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

