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
#  Last Modified : <170824.1511>
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

## @page OpenLCB_MRD2 OpenLCB MRD2 Node
# @brief OpenLCB MRD2 node
#
# @section MRD2SYNOPSIS SYNOPSIS
#
# OpenLCB_MRD2 [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section MRD2DESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for one or 
# more Azatrax MRD2 devices.  
#
# @section MRD2PARAMETERS PARAMETERS
#
# none
#
# @section MRD2OPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_MRD2.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is mrd2conf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section MRD2CONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" 
# chapter of the User Manual for the details on the schema for this XML 
# formatted file.  Also note that this program contains a built-in editor for 
# its own configuration file. 
#
#
# @section MRD2AUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_MRD2]

package require Azatrax;#  require the Azatrax package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]


snit::type OpenLCB_MRD2 {
    #** This class implements a OpenLCB interface to one or more 
    # Azatrax MRD2 devices.
    #
    # Each instance manages one device.  The typemethods implement the overall
    # OpenLCB node.
    #
    # Instance options:
    # @arg -sense1on Event ID to send when Sense 1 is activated.
    # @arg -sense1off Event ID to send when Sense 1 is deactivated.
    # @arg -sense2on Event ID to send when Sense 2 is activated.
    # @arg -sense2off Event ID to send when Sense 2 is deactivated.
    # @arg -latch1on Event ID to send when Latch 1 is activated.
    # @arg -latch1off Event ID to send when Latch 1 is deactivated.
    # @arg -latch2on Event ID to send when Latch 2 is activated.
    # @arg -latch2off Event ID to send when Latch 2 is deactivated.
    # @arg -setchan1 Event ID to trigger channel 1.
    # @arg -setchan2 Event ID to trigger channel 2.
    # @arg -sensorserial Serial number of the device to connect to.
    # @arg -description Description of the device.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  devicelist {};#     Device list
    typevariable  consumers {};#      Devices that consume events
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Devices that produce events
    typevariable  eventsproduced {};# Events produced.
    typevariable  defaultpollinterval 500;# Default poll interval
    typevariable  pollinterval 500;#  Poll interval
    typecomponent xmldeviceconfig;# Common device config object
    typecomponent eventgenerator;# Event Generator
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages MRD2 devices, consuming or producing
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
        set conffile [from argv -configuration "mrd2conf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmldeviceconfig [XmlConfiguration create %AUTO% {
                             <configure>
                               <string option="-description" tagname="description">Description</string>
                               <string option="-sensorserial" tagname="serial">Serial Number</string>
                               <eventid option="-sense1on" tagname="sense1on">Sense 1 On</eventid>
                               <eventid option="-sense1off" tagname="sense1off">Sense 1 Off</eventid>
                               <eventid option="-sense2on" tagname="sense2on">Sense 2 On</eventid>
                               <eventid option="-sense2off" tagname="sense2off">Sense 2 Off</eventid>
                               <eventid option="-latch1on" tagname="latch1on">Latch 1 On</eventid>
                               <eventid option="-latch1off" tagname="latch1off">Latch 1 Off</eventid>
                               <eventid option="-latch2on" tagname="latch2on">Latch 2 On</eventid>
                               <eventid option="-latch2off" tagname="latch2off">Latch 2 Off</eventid>
                               <eventid option="-setchan1" tagname="setchan1">Set Channel 1</eventid>
                               <eventid option="-setchan2" tagname="setchan2">Set Channel 2</eventid>
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
                          -softwaremodel "OpenLCB MRD2" \
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
        
        foreach device [$configuration getElementsByTagName "device"] {
            set devicecommand [$xmldeviceconfig processConfig $device [list $type create %AUTO%]]
            ::log::log debug "*** $type typeconstructor: devicecommand = $devicecommand"
            set dev [eval $devicecommand]
            if {[$dev canConsume]} {lappend consumers $dev}
            if {[$dev canProduce]} {lappend producers $dev}
            lappend devicelist $dev
        }
        if {[llength $devicelist] == 0} {
            ::log::logError [_ "No devices specified!"]
            exit 93
        }
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
                        ::log::log debug "*** $type _eventHandler: device is [$c cget -sensorserial]"
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
                    foreach evstate [$p Read $eventid] {
                        foreach {ev state} $evstate {break}
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
                foreach p $producers {
                    foreach evstate [$p Read *] {
                        foreach {ev state} $evstate {break}
                        $transport ProducerIdentified $ev $state
                    }
                }
            }
            report {
                foreach c $consumers {
                    ::log::log debug "*** $type _eventHandler: device is [$c cget -sensorserial]"
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
    typecomponent editContextMenu
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typevariable    pollinginterval 500;# polling interval.
    typecomponent   devices;# Device list
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
            {command "[_m {Menu|Help|EventExchange node for Azatrax MRD2 boards}]" {help:help} {} {} -command {HTMLHelp help "EventExchange node for Azatrax MRD2 boards"}}
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_MRD2/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
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
        set pollele [SimpleDOMElement %AUTO% -tag "pollinterval"]
        $cdi addchild $pollele
        $pollele setdata 500
        set device [SimpleDOMElement %AUTO% -tag "device"]
        $cdi addchild $device
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $device addchild $descrele
        $descrele setdata "Sample Device"
        set serial [SimpleDOMElement %AUTO% -tag "serial"]
        $device addchild $serial
        $serial setdata "01000001"
        foreach eventtag {sense1on sense1off sense2on sense2off latch1on 
            latch1off latch2on latch2off setchan1 setchan2} {
            set tagele [SimpleDOMElement %AUTO% -tag $eventtag]
            $device addchild $tagele
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
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_MRD2 container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_MRD2 Configuration Editor (%s)" $conffile]
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
        $xmldeviceconfig configure -eventidgenerator $generateEventID
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
        
        set devices [ScrollTabNotebook $frame.devices]
        pack $devices -expand yes -fill both
        foreach device [$cdi getElementsByTagName "device"] {
            set devframe [$xmldeviceconfig createGUI $devices device $cdi \
                          $device [_m "Label|Delete Device"] \
                          [mytypemethod _addframe] [mytypemethod _delframe]]
        }
        set adddevice [ttk::button $frame.adddevice \
                       -text [_m "Label|Add another device"] \
                       -command [mytypemethod _addblankdevice]]
        pack $adddevice -fill x
    }
    typemethod _addframe {parent frame count} {
        $devices add $frame -text [_ "Device %d" $count] -sticky news
    }
    typemethod _delframe {frame} {
        $devices forget $frame
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
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
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
        set pollele [$cdi getElementsByTagName "pollinterval"]
        if {[llength $pollele] < 1} {
            set pollele [SimpleDOMElement %AUTO% -tag "pollinterval"]
            $cdi addchild $pollele
        }
        $pollele setdata $pollinginterval
        
        foreach device [$cdi getElementsByTagName "device"] {
            $xmldeviceconfig copyFromGUI $devices $device warnings
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
                    set nidindex [lsearch -exact $transopts -nid]
                    if {$nidindex >= 0} {
                        incr nidindex
                        set nid [lindex $nidindex $transopts]
                    } else {
                        set nid "05:01:01:01:22:00"
                    }
                    set evlist [list]
                    foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $nid] 1 end] {
                        lappend evlist [scan $oct %02x]
                    }
                    lappend evlist 0 0
                    set generateEventID [GenerateEventID create %AUTO% \
                                         -baseeventid [lcc:EventID create %AUTO% -eventidlist $evlist]]
                    
                }
            }
        }
    }
    typemethod _addblankdevice {} {
        #** Create a new blank device.
        
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
        set cdi [lindex $cdis 0]
        set device [SimpleDOMElement %AUTO% -tag "device"]
        $cdi addchild $device
        set devframe [$xmldeviceconfig createGUI $devices device $cdi $device \
                      [_m "Label|Delete Device"] \
                      [mytypemethod _addframe] [mytypemethod _delframe]]
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
        # Construct an instance for a MRD2 device.
        #
        # @param ... Options:
        # @arg -sense1on Event ID to send when Sense 1 is activated.
        # @arg -sense1off Event ID to send when Sense 1 is deactivated.
        # @arg -sense2on Event ID to send when Sense 2 is activated.
        # @arg -sense2off Event ID to send when Sense 2 is deactivated.
        # @arg -latch1on Event ID to send when Latch 1 is activated.
        # @arg -latch1off Event ID to send when Latch 1 is deactivated.
        # @arg -latch2on Event ID to send when Latch 2 is activated.
        # @arg -latch2off Event ID to send when Latch 2 is deactivated.
        # @arg -setchan1 Event ID to trigger channel 1.
        # @arg -setchan2 Event ID to trigger channel 2.
        # @arg -sensorserial Serial number of the device to connect to.
        # @arg -description Description of the device.
        # @par
        # 
        
        set options(-sensorserial) [from args -sensorserial]
        if {$options(-sensorserial) eq {}} {
            ::log::logError [_ "The -sensorserial option is required!"]
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
    method Read {eventid} {
        set events [list]
        $sensor GetStateData
        set sense1 [$sensor Sense_1]
        set sense1on [$self cget -sense1on]
        set sense1off [$self cget -sense1off]
        if {$sense1on ne {} && ($eventid eq "*" || [$eventid match $sense1on])} {
            if {$sense1} {
                append events [list $sense1on valid]
            } else {
                append events [list $sense1on invalid]
            }
        }
        if {$sense1off ne {} && ($eventid eq "*" || [$eventid match $sense1off])} {
            if {$sense1} {
                append events [list $sense1off invalid]
            } else {
                append events [list $sense1off valid]
            }
        }
        set sense2 [$sensor Sense_2]
        set sense2on [$self cget -sense2on]
        set sense2off [$self cget -sense2off]
        if {$sense2on ne {} && ($eventid eq "*" || [$eventid match $sense2on])} {
            if {$sense2} {
                append events [list $sense2on valid]
            } else {
                append events [list $sense2on invalid]
            }
        }
        if {$sense2off ne {} && ($eventid eq "*" || [$eventid match $sense2off])} {
            if {$sense2} {
                append events [list $sense2off invalid]
            } else {
                append events [list $sense2off valid]
            }
        }
        set latch1 [$sensor Latch_1]
        set latch1on [$self cget -latch1on]
        set latch1off [$self cget -latch1off]
        if {$latch1on ne {} && ($eventid eq "*" || [$eventid match $latch1on])} {
            if {$latch1} {
                append events [list $latch1on valid]
            } else {
                append events [list $latch1on invalid]
            }
        }
        if {$latch1off ne {} && ($eventid eq "*" || [$eventid match $latch1off])} {
            if {$latch1} {
                append events [list $latch1off invalid]
            } else {
                append events [list $latch1off valid]
            }
        }
        set latch2 [$sensor Latch_2]
        set latch2on [$self cget -latch2on]
        set latch2off [$self cget -latch2off]
        if {$latch2on ne {} && ($eventid eq "*" || [$eventid match $latch2on])} {
            if {$latch2} {
                append events [list $latch2on valid]
            } else {
                append events [list $latch2on invalid]
            }
        }
        if {$latch2off ne {} && ($eventid eq "*" || [$eventid match $latch2off])} {
            if {$latch2} {
                append events [list $latch2off invalid]
            } else {
                append events [list $latch2off valid]
            }
        }
        return $events
    }
        
    method Poll {} {
        #** Poll the device.
        
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
            $type sendEvent $event
        }
    }
    method consumeEvent {event} {
        #** Handle an incoming event.
        #
        # @param event The event to handle.
        
        ::log::log debug "*** $self consumeEvent $event"
        $sensor GetStateData
        ::log::log debug "*** $self consumeEvent: HasRelays: [$sensor HasRelays]"
        if {![$sensor HasRelays]} {return false}
        ::log::log debug "*** $self consumeEvent: setchan1 event is [$self cget -setchan1]"
        if {[$event match [$self cget -setchan1]]} {
            ::log::log debug "*** $self consumeEvent: setchan1 event matches!"
            $sensor SetChan1
            return true
        }
        ::log::log debug "*** $self consumeEvent: setchan2 event is [$self cget -setchan2]"
        if {[$event match [$self cget -setchan2]]} {
            ::log::log debug "*** $self consumeEvent: setchan2 event matches!"
            $sensor SetChan2
            return true
        }
        return false
    }
    method canConsume {} {
        if {[$self cget -setchan1] ne {} || [$self cget -setchan2] ne {}} {
            return yes
        } else {
            return no
        }
    }
    method canProduce {} {
        foreach evopt {sense1on sense1off sense2on sense2off latch1on latch1off latch2on latch2off} {
            if {[$self cget -$ev] ne {}} {return yes}
        }
        return no
    }
    
}

vwait forever
