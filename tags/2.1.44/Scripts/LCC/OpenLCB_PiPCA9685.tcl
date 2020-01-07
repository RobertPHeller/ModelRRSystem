#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue May 1 08:36:11 2018
#  Last Modified : <180501.1347>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
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


## @page OpenLCB_PiPCA9685 OpenLCB PiPCA9685 node
# @brief OpenLCB PiPCA9685 node
#
# @section PiPCA9685SYNOPSIS SYNOPSIS
#
# OpenLCB_PiPCA9685 [-configure] [-sampleconfiguration] [-debug] [-configuration confgile]
#
# @section PiPCA9685DESCRIPTION DESCRIPTION
#
# This program is a daemon that implements an OpenLCB node for the PWM pins
# provided by a PCA9685 I2C PWM port expander on a Raspberry Pi.
#
# @section PiPCA9685PARAMETERS PARAMETERS
#
# None
#
# @section PiPCA9685OPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCB_PiPCA9685.log
# @arg -configure Enter an interactive GUI configuration tool.  This tool
# creates or edits an XML configuration file.
# @arg -sampleconfiguration Creates a @b sample configuration file that can 
# then be hand edited (with a handy text editor like emacs or vim).
# @arg -configuration confgile Sets the name of the configuration (XML) file. 
# The default is pipca9685conf.xml.
# @arg -debug Turns on debug logging.
# @par
#
# @section PiPCA9685CONFIGURATION CONFIGURATION
#
# The configuration file for this program is an XML formatted file. Please 
# refer to the @ref openlcbdaemons "OpenLCB Daemons (Hubs and Virtual nodes)" chapter of the User 
# Manual for the details on the schema for this XML formatted file.  Also
# note that this program contains a built-in editor for its own configuration 
# file. 
#
#
# @section PiPCA9685AUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB_PiPCA9685]

package require PCA9685;#  require the PCA9685 package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require OpenLCB_Common;# Common config code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler
package require log;#      require the logging package.

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::type Function {
   pragma  -hastypeinfo false -hastypedestroy false -hasinstances false
   
   typemethod validate {value} {
       if {[llength $value] == 3} {
           lcc::EventID validate [lindex $value 0]
           PWMValue validate [lindex $value 1]
           PWMValue validate [lindex $value 2]
       } else {
           error [_ "Not a valid channel function: %s" $value]
       }
   }
}

snit::listtype FunctionList -minlen 0 -type Function

snit::type OpenLCB_PiPCA9685 {
    #** This class implements a OpenLCB interface to a PCA9685 I2C 16-channel 
    # PWM controller connected to the I2C bus on a Raspberry Pi.
    #
    # Each instance manages one PWM channel.  The typemethods implement the 
    # overall OpenLCB node.
    #
    # Instance options:
    # @arg -channel The channel number (0 to 15)
    # @arg -description The description of the channel, such as what is 
    # connected to it.
    # @arg -functionlist The list of functions for the channel.  This is a
    # list of lists.  Each sublist contains three elements: an event ID, an on
    # value and an off value.
    # @par
    #
    # @section AUTHOR
    # Robert Heller \<heller\@deepsoft.com\>
    #
    
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  channellist {};#    Channel list
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  defaultI2CAddr 0x40;#  Default I2C address
    typevariable  I2CAddr 0x40;#         I2C address 
    typecomponent xmlchannelconfig;# Common Channel config object
    typecomponent pwmcontroller;# The pwm controller
    typevariable pwmfrequency 200;# PWM Freq.
    typevariable defaultpwmfrequency 200;# Default PWM Freq.
    
    typecomponent editContextMenu
    
    OpenLCB_Common::transportProcs
    OpenLCB_Common::identificationProcs
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Process command line.  Runs the GUI configuration tool or connects to
        # the OpenLCB network and manages PWM Channels, consuming events.
        
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
        set conffile [from argv -configuration "pipca9685conf.xml"]
        #puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        set xmlchannelconfig [XmlConfiguration create %AUTO% {
                           <configure>
                           <string option="-description" tagname="description">Description</string>
                           <int option="-channel" tagname="channelnumber" min="0" max="15">Channel Number</int>
                           <group option="-functionlist" mincount="0" 
                                  maxcount="unlimited" tagname="function" 
                                  repname="Function">
                             <eventid tagname="eventid">Event</eventid>
                             <int tagname="on" min="0" max="4096">PWM On</int>
                             <int tagname="off" min="0" max="4096">PWM Off</int>
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
                          -softwaremodel "OpenLCB Pipca9685" \
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
        set pwmfreqwele [$configuration getElementsByTagName "pwmfrequency"]
        if {[llength $pwmfreqwele] > 0} {
            set pwmfreqwele [lindex $pwmfreqwele 0]
            set pwmfrequency [$pwmfreqwele data]
        } else {
            set pwmfrequency $defaultpwmfrequency
        }
        
        set i2caddrele [$configuration getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] > 0} {
            set i2caddrele [lindex $i2caddrele 0]
            set I2CAddr [$i2caddrele data]
        }
        
        # Connect to the pca9685:
        set pwmcontroller [PCA9685 create %AUTO% -address $I2CAddr]
        $pwmcontroller set_pwm_freq $pwmfrequency
        
        foreach channel [$configuration getElementsByTagName "channel"] {
            set chancommand [$xmlchannelconfig processConfig $channel [list $type create %AUTO%]]
            set chan [eval $chancommand]
            if {[llength [$chan eventsconsumed]] == 0} {
                ::log::log warning [_ "Useless channel %d consumes no events" [$chan cget -channel]]
            } else {
                lappend channellist $chan
            }
        }
        if {[llength $channellist] == 0} {
            ::log::logError [_ "No enabled channels specified!"]
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
                if {$validity eq "valid"} {
                    foreach c $channellist {
                        ::log::log debug "*** $type _eventHandler: channel is [$c cget -channel]"
                        ::log::log debug "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                        $c consumeEvent $eventid
                    }
                }
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
            }
            identifyevents {
                foreach ev $eventsconsumed {
                    $transport ConsumerIdentified $ev unknown
                }
            }
            report {
                foreach c $channellist {
                    ::log::log debug "*** $type _eventHandler: channel is [$c cget -channel]"
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
    typevariable    pwmfreqvalue 200;# PWM Freq.
    typevariable    pca9685address 0x40;# The address of the PCA9685
    typecomponent   channels;# Channel list
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
    typevariable default_confXML {<?xml version='1.0'?><OpenLCB_PiPCA9685/>}
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiPCA9685 -depth 1]
        set cdi [lindex $cdis 0]
        SampleTransport $cdi
        SampleItentification $cdi
        set pwmfreqele [SimpleDOMElement %AUTO% -tag "pwmfrequency"]
        $cdi addchild $pwmfreqele
        $pwmfreqele setdata $defaultpwmfrequency
        set i2caddrele [SimpleDOMElement %AUTO% -tag "i2caddress"]
        $cdi addchild $i2caddrele
        $i2caddrele setdata [expr {int($defaultI2CAddr)}]
        set generateEventID [GenerateEventID create %AUTO% \
                             -baseeventid [lcc::EventID create %AUTO% \
                                           -eventidstring "05.01.01.01.22.00.00.00"]]
        set channel [SimpleDOMElement %AUTO% -tag "channel"]
        $cdi addchild $channel
        set descrele [SimpleDOMElement %AUTO% -tag "description"]
        $channel addchild $descrele
        $descrele setdata "Sample PWM Channel"
        set chno [SimpleDOMElement %AUTO% -tag "channelnumber"]
        $channel addchild $chno
        $chno setdata 0
        set fnele [SimpleDOMElement %AUTO% -tag "function"]
        $channel addchild $fnele
        set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
        $fnele addchild $eventid
        $eventid setdata [$generateEventID nextid]
        set onele [SimpleDOMElement %AUTO% -tag "on"]
        $fnele addchild $onele
        $onele setdata 2048
        set offele [SimpleDOMElement %AUTO% -tag "off"]
        $fnele addchild $offele
        $offele setdata 2048
        set fnele [SimpleDOMElement %AUTO% -tag "function"]
        $channel addchild $fnele
        set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
        $fnele addchild $eventid
        $eventid setdata [$generateEventID nextid]
        set onele [SimpleDOMElement %AUTO% -tag "on"]
        $fnele addchild $onele
        $onele setdata 4096
        set offele [SimpleDOMElement %AUTO% -tag "off"]
        $fnele addchild $offele
        $offele setdata 0
        set fnele [SimpleDOMElement %AUTO% -tag "function"]
        $channel addchild $fnele
        set eventid [SimpleDOMElement %AUTO% -tag "eventid"]
        $fnele addchild $eventid
        $eventid setdata [$generateEventID nextid]
        set onele [SimpleDOMElement %AUTO% -tag "on"]
        $fnele addchild $onele
        $onele setdata 0
        set offele [SimpleDOMElement %AUTO% -tag "off"]
        $fnele addchild $offele
        $offele setdata 4096
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiPCA9685 -depth 1]
        if {[llength $cdis] != 1} {
            error [_ "There is no OpenLCB_PiPCA9685 container in %s" $confXML]
            exit 90
        }
        set cdi [lindex $cdis 0]
        wm protocol . WM_DELETE_WINDOW [mytypemethod _saveexit]
        wm title    . [_ "OpenLCB_PiPCA9685 Configuration Editor (%s)" $conffile]
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
        $xmlchannelconfig configure -eventidgenerator $generateEventID
        IdentificationGUI $frame $cdi
        
        set pwmfrequencyLE [LabelSpinBox $frame.pwmfrequencyLE \
                            -label [_m "Label|PWM Frequency"] \
                            -textvariable [mytypevar pwmfreqvalue] \
                            -range {24 1526 5}]
        pack $pwmfrequencyLE -fill x -expand yes
        set pwmfreqwele [$cdi getElementsByTagName "pwmfrequency"]
        if {[llength $pwmfreqwele] > 0} {
            set pwmfreqwele [lindex $pwmfreqwele 0]
            set pwmfreqvalue [$pwmfreqwele data]
        }
        set i2caddressLE [LabelSpinBox $frame.i2caddressLE \
                            -label [_m "Label|I2C Address"] \
                            -textvariable [mytypevar pca9685address] \
                            -range {0x40 0xA3 1}]
        pack $i2caddressLE -fill x -expand yes
        set i2caddrele [$cdi getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] > 0} {
            set i2caddrele [lindex $i2caddrele 0]
            set pca9685address [$i2caddrele data]
        }
        set channels [ScrollTabNotebook $frame.channels]
        pack $channels -expand yes -fill both
        foreach channel [$cdi getElementsByTagName "channel"] {
            set chanframe [$xmlchannelconfig createGUI $channels channel $cdi \
                          $channel [_m "Label|Delete Channel"] \
                          [mytypemethod _addframe] [mytypemethod _delframe]]
        }
        set addchannel [ttk::button $frame.addchannel \
                    -text [_m "Label|Add another channel"] \
                    -command [mytypemethod _addblankchannel]]
        pack $addchannel -fill x
    }
    typemethod _addframe {parent frame count} {
        $channels add $frame -text [_ "Channel %d" $count] -sticky news
    }
    typemethod _delframe {frame} {
        $channels forget $frame
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
        set cdis [$configuration getElementsByTagName OpenLCB_PiPCA9685 -depth 1]
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
        set pwmfreqwele [$cdi getElementsByTagName "pwmfrequency"]
        if {[llength $pwmfreqwele] < 1} {
            set pwmfreqwele [SimpleDOMElement %AUTO% -tag "pwmfrequency"]
            $cdi addchild $pwmfreqwele
        }
        $pwmfreqwele setdata $pwmfreqvalue
        set i2caddrele [$configuration getElementsByTagName "i2caddress"]
        if {[llength $i2caddrele] < 1} {
            set i2caddrele [SimpleDOMElement %AUTO% -tag "i2caddress"]
            $cdi addchild $i2caddrele
        }
        $i2caddrele setdata $pca9685address
        
        foreach channel [$cdi getElementsByTagName "channel"] {
            $xmlchannelconfig copyFromGUI $channels $channel warnings
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
    typemethod _addblankchannel {} {
        #** Create a new blank channel.
        
        set cdis [$configuration getElementsByTagName OpenLCB_PiPCA9685 -depth 1]
        set cdi [lindex $cdis 0]
        set channel [SimpleDOMElement %AUTO% -tag "channel"]
        $cdi addchild $channel
        set channelframe [$xmlchannelconfig createGUI $channels channel $cdi \
                      $channel [_m "Label|Delete Channel"] \
                      [mytypemethod _addframe] [mytypemethod _delframe]]
    }
        
    #*** Channel instances
    option -channel -readonly yes -type PWMChannel -default 0
    option -description -readonly yes -default {}
    option -functionlist -readonly yes -type FunctionList -default {}
    
    constructor {args} {
        # Construct an instance for a PWM Channel
        #
        # @param ... Options:
        # @arg -channel The channel number
        # @arg -description Description of the channel.
        # @arg -functionlist The function list.
        # @par
        
        $self configurelist $args
        foreach e_pp [$self cget -functionlist] {
            lassign $e_pp e on off
            lappend eventsconsumed $e
        }
    }
    method consumeEvent {event} {
        foreach e_pp [$self cget -functionlist] {
            lassign $e_pp e on off
            if {[$event match $e]} {
                $pwmcontroller [$self cget -channel] $on $off
                return true
            }
        }
        return false
    }
    method eventsconsumed {} {
        set events [list]
        foreach e_pp [$self cget -functionlist] {
            lassign $e_pp e on off
            lappend events $e
        }
        return $events
    }
}


vwait forever

