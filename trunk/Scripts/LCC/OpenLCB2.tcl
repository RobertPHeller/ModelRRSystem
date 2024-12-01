#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Nov 29 10:23:41 2024
#  Last Modified : <241201.1457>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
## @copyright
#    Copyright (C) 2024  Robert Heller D/B/A Deepwoods Software
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
# @file OpenLCB2.tcl
# @author Robert Heller
# @date Fri Nov 29 10:23:41 2024
# 
#
#*****************************************************************************


## @defgroup OpenLCB2 OpenLCB2
# @brief OpenLCB2 main program (for configuration and manual operations).
#
# @section SYNOPSIS
#
# OpenLCB2 [X11 Resource Options] -- [Other options]
#
# @section DESCRIPTION
#
# This program is a GUI program for configuring OpenLCB nodes and for manual
# (testing) operations.
#
# @section PARAMETERS
#
# none
#
# @section OPTIONS
#
# @subsection x11resource X11 Resource Options
#
# @arg -colormap: Colormap for main window
# @arg -display:  Display to use
# @arg -geometry: Initial geometry for window
# @arg -name:     Name to use for application
# @arg -sync:     Use synchronous mode for display server
# @arg -visual:   Visual for main window
# @arg -use:      Id of window in which to embed application
# @par
#
# @subsection other Other options
#
# @arg -transportname The name of the transport constructor.  A shell wildcard
#                     is allowed (but needs to be quoted or escaped).
# @arg -listconstructors Print a list of available constructors and exit.
# @arg -help Print a short help message and exit.
# @arg -debug Turn on debug output.
# @par
#
# Additional options, specific to the transport constructor can also be 
# specified.
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB]

package require gettext
package require Tk
package require tile
package require snit
package require MainWindow
package require ScrollWindow
package require ROText
package require snitStdMenuBar
package require HTMLHelp 2.0
package require LabelFrames
package require LCC
package require ParseXML
package require ConfigurationEditor
package require EventDialogs
package require ConfigDialogs
package require LCCNodeTable
package require LayoutControlDB
package require Dialog
package require ScrollTabNotebook
package require LayoutControlDBDialogs
package require LayoutControlDB
package require LayoutControlDBTable

global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
#puts stderr "*** HelpDir = $HelpDir"
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
#puts stderr "*** msgfiles = $msgfiles"

snit::type OpenLCB2 {
    #*************************************************************************
    # OpenLCB Main program -- provide node configuration and event monitoring.
    #
    # Displays available nodes in a tree list form, allowing for node 
    # configuration, event monitoring, and event generation for test purposes.
    #
    #*************************************************************************
    
    pragma -hastypeinfo false
    pragma -hastypedestroy false
    pragma -hasinstances false
    
    typecomponent mainWindow;# Main window
    typecomponent   nodetable;# Tree table of nodes
    typecomponent transport; # Transport layer
    typecomponent eventlog;  # Event log toplevel
    
    typevariable nodetable_cols {name nodeid manufacturer model software configure};# Columns
    typevariable mynid {};   # My Node ID
    
    typevariable _debug no;# Debug flag
    
    typecomponent layoutcontroldb
    typecomponent newTurnoutDialog
    typecomponent newBlockDialog
    typecomponent newSignalDialog
    typecomponent newSensorDialog
    typecomponent newControlDialog
    typecomponent layoutControlView
    typecomponent layoutControlTable
    typecomponent layoutControlsLF
    typecomponent   layoutcontrolsNB
    typecomponent     editturnoutW
    typecomponent     editblockW
    typecomponent     editsensorW
    typecomponent     editcontrolW
    typecomponent     editsignalW
    typemethod _buildDialogs {} {
        putdebug "*** $type _buildDialogs"
        set newTurnoutDialog [::lcc::NewTurnoutDialog .main.newTurnoutDialog -parent .main -modal none]
        putdebug "*** $type _buildDialogs: newTurnoutDialog is $newTurnoutDialog"
        set newBlockDialog   [::lcc::NewBlockDialog   .main.newBlockDialog -parent .main -modal none]
        set newSignalDialog  [::lcc::NewSignalDialog  .main.newSignalDialog -parent .main -modal none]
        set newSensorDialog  [::lcc::NewSensorDialog  .main.newSensorDialog -parent .main -modal none]
        set newControlDialog [::lcc::NewControlDialog .main.newControlDialog -parent .main -modal none]
        
    }
    typemethod _newTurnout {} {
        putdebug "*** $type _newTurnout: newTurnoutDialog is $newTurnoutDialog"
        $newTurnoutDialog draw -db $layoutcontroldb
    }
    typemethod _newBlock {} {
        $newBlockDialog   draw -db $layoutcontroldb
    }
    typemethod _newSignal {} {
        $newSignalDialog  draw -db $layoutcontroldb
    }
    typemethod _newSensor {} {
        $newSensorDialog  draw -db $layoutcontroldb
    }
    typemethod _newControl {} {
        $newControlDialog draw -db $layoutcontroldb
    }
        
    typemethod _loadLCDB {} {
        set filename [tk_getOpenFile -defaultextension .xml \
                      -filetypes {{{XML Files} {.xml} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "XML File to open"]
        if {"$filename" ne {}} {
            set layoutcontroldb [::lcc::LayoutControlDB olddb $filename]
            if {$layoutControlView ne {}} {
                $layoutControlTable configure -db $layoutcontroldb
                $layoutControlTable Refresh
            }
            $nodetable configure -layoutdb $layoutcontroldb
            foreach cdiform [array names CDIs_FormTLs] {
                set tl $CDIs_FormTLs($cdiform)
                if {[winfo exists $tl] && ![$tl cget -displayonly]} {
                    $tl configure -layoutdb $layoutcontroldb
                }
            }
        }
    }
        
    typemethod _saveLCDB {} {
        set filename [tk_getSaveFile -defaultextension .xml \
                      -filetypes {{{XML Files} {.xml} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "XML File to open"]
        if {"$filename" ne {}} {
            $layoutcontroldb savedb "$filename"
        }
    }

    proc putdebug {message} {
        if {$_debug} {
            puts stderr $message
        }
    }
    proc hexdump { header data} {
        if {$_debug} {
            puts -nonewline stderr $header
            foreach byte $data {
                puts -nonewline stderr [format " %02X" $byte]
            }
            puts stderr {}
        }
    }

    typemethod usage {} {
        #* Print a usage message.
        
        puts stdout [_ "Usage: %s \[X11 Resource Options\] -- \[Other options\]" $::argv0]
        puts stdout {}
        puts stdout [_ "X11 Resource Options:"]
        puts stdout [_ " -colormap: Colormap for main window"]
        puts stdout [_ "-display:  Display to use"]
        puts stdout [_ "-geometry: Initial geometry for window"]
        puts stdout [_ "-name:     Name to use for application"]
        puts stdout [_ "-sync:     Use synchronous mode for display server"]
        puts stdout [_ "-visual:   Visual for main window"]
        puts stdout [_ "-use:      Id of window in which to embed application"]
        puts stdout {}
        puts stdout [_ "Other options:"]
        puts stdout [_ "-transportname: The name of the transport constructor."]
        puts stdout [_ "-listconstructors: Print a list of available constructors and exit."]
        puts stdout [_ "-help: Print this help message and exit."]
        puts stdout [_ "-debug: Enable debug output."]
        puts stdout [_ "Additional options for the transport constructor can also be specified."]
    }
    proc hidpiP {w} {
        set scwidth [winfo screenwidth $w]
        set scmmwidth [winfo screenmmwidth $w]
        set scinchwidth [expr {$scmmwidth / 25.4}]
        set scdpiw [expr {$scwidth / $scinchwidth}]
        set scheight [winfo screenheight $w]
        set scmmheight [winfo screenmmheight $w]
        set scinchheight [expr {$scmmheight / 25.4}]
        set scdpih [expr {$scheight / $scinchheight}]
        return [expr {($scdpiw > 100) || ($scdpih > 100)}]
    }
    typeconstructor {
        #* Type constructor -- create all of the one time computed stuff.
        #* This includes processing the CLI, building the main window and 
        #* opening a connection to the OpenLCB bus(s).
        
        # Process the command line options.
        # Does the user want a list of available transport constructors?
        set layoutControlView {}
        set listconstructorsP [lsearch $::argv -listconstructors]
        if {$listconstructorsP >= 0} {
            wm withdraw .
            set transportConstructorList [lcc::OpenLCBNode \
                                          transportConstructors]
            puts stdout [_ "Constructors available:"]
            foreach {descr name} $transportConstructorList {
                puts stdout [format "%s: %s" [namespace tail $name] $descr]
            }
            $type usage
            exit
        }
        
        # Does the user want help?  
        set helpP [lsearch $::argv -help]
        if {$helpP >= 0} {
            wm withdraw .
            $type usage
            exit
        }
        set debugIdx [lsearch $::argv -debug]
        if {$debugIdx >= 0} {
            set _debug yes
            set ::argv [lreplace $::argv $debugIdx $debugIdx]
        }
        LCCNodeTable setdebug $_debug
        
        putdebug "*** $type typeconstructor: ::argv is $::argv"
        # Try to get transport constructor from the CLI.
        set transportConstructorName [from ::argv -transportname ""]
        putdebug "*** $type typeconstructor: transportConstructorName is $transportConstructorName"
        # Assume there isn't one specified on the command line.
        set transportConstructor {}
        if {$transportConstructorName ne ""} {
            # The user speficied something.  Get the actual name, if any.
            set transportConstructors [info commands ::lcc::$transportConstructorName]
            putdebug "*** $type typeconstructor: transportConstructors is $transportConstructors"
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
        }
        # Was something found?  If not, pop up a dialog box to get an answer.
        if {$transportConstructor eq {}} {
            update idle
            set transportConstructor [lcc::OpenLCBNode \
                                      selectTransportConstructor \
                                      -parent .]
        }
        # Canceled? Give up.
        if {$transportConstructor eq {}} {
            exit
        }
        # Deal with constructor required opts.  Try the command line, fall 
        # back to a dialog box.
        set reqOpts [$transportConstructor requiredOpts]
        set transportOpts [list]    
        foreach {o d} $reqOpts {
            if {[lsearch $::argv $o] >= 0} {
                lappend transportOpts $o [from ::argv $o $d]
            }
        }
        if {[llength $reqOpts] > [llength $transportOpts]} {
            update idle
            set transportOpts [$transportConstructor \
                                     drawOptionsDialog \
                                     -parent . \
                                     {*}$transportOpts]
        }
        # Open the transport.
        if {[catch {lcc::OpenLCBNode %AUTO% \
                          -transport $transportConstructor\
                          -eventhandler [mytypemethod _eventHandler] \
                          -generalmessagehandler [mytypemethod _messageHandler] \
                          -softwaremodel "OpenLCB GUI" \
                          -softwareversion "1.0" \
                          -additionalprotocols {Datagram EventExchange} \
                           {*}$transportOpts} transport]} {
            tk_messageBox -type ok -icon error \
                      -message [_ "Failed to open transport because: %s" $transport]
            exit 99
        }
        # Build main GUI window.
        set mainWindow [mainwindow .main -scrolling yes \
                        -height 480 -width 640]
        pack $mainWindow -expand yes -fill both
        # Update menus: bind to Exit item, add Send Event, flesh out the Help
        # menu.
        $mainWindow menu entryconfigure file "Exit" -command [mytypemethod _carefulExit]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Send Event"] \
              -command [mytypemethod _SendEvent]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Load Layout Control DB"] \
              -dynamichelp "[_ {Load a Layout Control DB File}]" \
              -accelerator Ctrl+L \
              -underline 0 \
              -command "[mytypemethod _loadLCDB]"
        bind [winfo toplevel $mainWindow] <Control-Key-L> [mytypemethod _loadLCDB]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Save Layout Control DB"] \
              -dynamichelp "[_ {Save a Layout Control DB File}]" \
              -accelerator Ctrl+S \
              -underline 0 \
              -command "[mytypemethod _saveLCDB]"
        bind [winfo toplevel $mainWindow] <Control-Key-S> [mytypemethod _saveLCDB]
        $mainWindow menu add edit separator
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Turnout"] \
              -dynamichelp "[_ {Create new turnout}]" \
              -command "[mytypemethod _newTurnout]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Block"] \
              -dynamichelp "[_ {Create new block}]" \
              -command "[mytypemethod _newBlock]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Signal"] \
              -dynamichelp "[_ {Create new signal}]" \
              -command "[mytypemethod _newSignal]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Sensor"] \
              -dynamichelp "[_ {Create new sensor}]" \
              -command "[mytypemethod _newSensor]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Control"] \
              -dynamichelp "[_ {Create new control}]" \
              -command "[mytypemethod _newControl]"
        $mainWindow menu entryconfigure help "On Help..." -command {HTMLHelp help Help}
        $mainWindow menu delete help "On Keys..."
        $mainWindow menu delete help "Index..."
        $mainWindow menu delete help "Tutorial..."
        $mainWindow menu entryconfigure help "On Version" -command {HTMLHelp help Version}
        $mainWindow menu entryconfigure help "Warranty" -command {HTMLHelp help Warranty}
        $mainWindow menu entryconfigure help "Copying" -command {HTMLHelp help Copying}
        $mainWindow menu add help command \
              -label [_m "Menu|Help|Reference Manual"] \
              -command {HTMLHelp help "OpenLCB Reference"}
        $mainWindow menu add view command \
              -label [_m "Menu|View|Display CDI from XML file"] \
              -command [mytypemethod _ViewCDI]
        $mainWindow menu add view command \
             -label [_m "Menu|View|Display Layout Control DB"] \
             -command [mytypemethod _ViewLayoutControlDB]
        # Hook in help files.
        HTMLHelp setDefaults "$::HelpDir" "index.html#toc"
        
        set layoutcontroldb [::lcc::LayoutControlDB newdb]
        # Lazy eval for event log.
        set sendlog {}
        # Create node table widget.
        # ($mainWindow setstatus text, $mainWindow setprogress pval)
        set nodetable [LCCNodeTable [$mainWindow scrollwindow getframe].nodetable \
                      -transport $transport \
                      -layoutdb $layoutcontroldb]
        # Bind scrollbars.
        $mainWindow scrollwindow setwidget $nodetable
        ## Refresh button => $nodetable Refresh
        $mainWindow toolbar add topbuttons
        $mainWindow toolbar addbutton topbuttons refresh -text [_m "Label|Refresh"] -command [list $nodetable Refresh]
        $mainWindow toolbar show topbuttons
        putdebug "*** $type typeconstructor: transport = $transport"
        # Get our Node ID.
        set mynid [$transport cget -nid]
        putdebug "*** $type typeconstructor: mynid = $mynid"
        $type _buildDialogs
        # Pop the main window on the screen.
        $mainWindow showit
        update idle
        putdebug "*** $type typeconstructor: done."
    }
    typemethod _logMessageHandler {message} {
        putdebug "*** $type _logMessageHandler [$message toString]"
    }
    typemethod _eventHandler {command eventid {validity {}}} {
        #* Event handler -- when a PCER message is received, pop up an
        #* event received pop up.
        
        putdebug "*** $type _eventHandler $command $eventid $validity"
        if {$command eq "report"} {
            if {![winfo exists $eventlog]} {
                set eventlog [lcc::EventLog .eventlog%AUTO% \
                              -transport $transport]
            }
            $eventlog eventReceived $eventid
            $eventlog open
        }
        #putdebug "*** $type _eventHandler: MTIDetails: [lcc::MTIDetail ObjectCount]"
        #putdebug "*** $type _eventHandler: CanMessages: [lcc::CanMessage ObjectCount]"
        #putdebug "*** $type _eventHandler: GridConnectMessages: [lcc::GridConnectMessage ObjectCount]"
        #putdebug "*** $type _eventHandler: GridConnectReplys: [lcc::GridConnectReply ObjectCount]"
        #putdebug "*** $type _eventHandler: CanAliass: [lcc::CanAlias ObjectCount]"
        #putdebug "*** $type _eventHandler: CanTransports: [lcc::CanTransport ObjectCount]"
        #putdebug "*** $type _eventHandler: OpenLCBMessages: [lcc::OpenLCBMessage ObjectCount]"
        #putdebug "*** $type _eventHandler: CANGridConnects: [lcc::CANGridConnect ObjectCount]"
        #putdebug "*** $type _eventHandler: CANGridConnectOverUSBSerials: [lcc::CANGridConnectOverUSBSerial ObjectCount]"
        #putdebug "*** $type _eventHandler: OpenLCBOverTcps: [lcc::OpenLCBOverTcp ObjectCount]"
        #putdebug "*** $type _eventHandler: CANGridConnectOverTcps: [lcc::CANGridConnectOverTcp ObjectCount]"
        #putdebug "*** $type _eventHandler: CANGridConnectOverCANSockets: [lcc::CANGridConnectOverCANSocket ObjectCount]"
        #putdebug "*** $type _eventHandler: OpenLCBNodes: [lcc::OpenLCBNode ObjectCount]"
        #putdebug "*** $type _eventHandler: EventIDs: [lcc::EventID ObjectCount]"
    }
    proc matchNIDinBody {message nid} {
        set data [$message cget -data]
        if {$data eq {}} {
            return true
        }
        set nidlist [list]
        foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $nid] 1 end] {
            lappend nidlist [scan $oct %02x]
        }
        foreach d $data n $nidlist {
            if {$d != $n} {return false}
        }
        return true
    }
    typemethod _messageHandler {message} {
        #* Message handler -- handle incoming messages.
        #* Certain messages are processed:
        #*
        #* Verify Node ID   -- Send our Verified Node ID.
        #* Protocol Support Inquiry -- Send our Supported Protocols.
        #* Simple Node Information Request -- Send our Simple Node Info.
        #* Other messages are handled by the nodetable.
        
        #putdebug [format {*** $type _messageHandler: mti is 0x%04X} [$message cget -mti]]
        switch [format {0x%04X} [$message cget -mti]] {
            0x0490 {
                #* Verify Node ID (global)
                if {[matchNIDinBody $message $mynid]} {
                    $transport SendMyNodeVerifcation
                }
            }
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
                #putdebug "*** $type _messageHandler: -sourcenid is  [$message cget -sourcenid]"
                #$message cget -sourcenid
                $transport SendMySimpleNodeInfo [$message cget -sourcenid]
            }
            default {
            }
        }
        $nodetable messageHandler $message
        #putdebug "*** $type _messageHandler: MTIDetails: [lcc::MTIDetail ObjectCount]"
        #putdebug "*** $type _messageHandler: CanMessages: [lcc::CanMessage ObjectCount]"
        #putdebug "*** $type _messageHandler: GridConnectMessages: [lcc::GridConnectMessage ObjectCount]"
        #putdebug "*** $type _messageHandler: GridConnectReplys: [lcc::GridConnectReply ObjectCount]"
        #putdebug "*** $type _messageHandler: CanAliass: [lcc::CanAlias ObjectCount]"
        #putdebug "*** $type _messageHandler: CanTransports: [lcc::CanTransport ObjectCount]"
        #putdebug "*** $type _messageHandler: OpenLCBMessages: [lcc::OpenLCBMessage ObjectCount]"
        #putdebug "*** $type _messageHandler: CANGridConnects: [lcc::CANGridConnect ObjectCount]"
        #putdebug "*** $type _messageHandler: CANGridConnectOverUSBSerials: [lcc::CANGridConnectOverUSBSerial ObjectCount]"
        #putdebug "*** $type _messageHandler: OpenLCBOverTcps: [lcc::OpenLCBOverTcp ObjectCount]"
        #putdebug "*** $type _messageHandler: CANGridConnectOverTcps: [lcc::CANGridConnectOverTcp ObjectCount]"
        #putdebug "*** $type _messageHandler: CANGridConnectOverCANSockets: [lcc::CANGridConnectOverCANSocket ObjectCount]"
        #putdebug "*** $type _messageHandler: OpenLCBNodes: [lcc::OpenLCBNode ObjectCount]"
    }
    typemethod _insertSimpleNodeInfo {nid infopayload} {
        #* Insert the SimpleNodeInfo for nid into the tree view.

        putdebug "*** $type _insertSimpleNodeInfo $nid $infopayload"
        $nodetable insert $nid end -id ${nid}_simplenodeinfo \
              -text {Simple Node Info} \
              -open no
        set strings1 [lindex $infopayload 0]
        if {$strings1 == 1} {set strings1 4}
        set i 1
        set names1 {manufact model hvers svers}
        set formats1 [list \
                      "Manfacturer: %s" \
                      "Model: %s" \
                      "Hardware Version: %s" \
                      "Software Version: %s"]
        for {set istring 0} {$istring < $strings1} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                putdebug "*** $type _insertSimpleNodeInfo: strings1: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                $nodetable insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names1 $istring] \
                      -text [_ [lindex $formats1 $istring] $s] \
                      -open no
            }
            incr i
        }
        if {$i >= [llength $infopayload]} {return}
        set strings2 [lindex $infopayload $i]
        if {$strings2 == 1} {set strings2 2}
        # If version 1, then 2 strings (???), other wise version == number of strings
        incr i
        set names2 {name descr}
        set formats2 [list "Name: %s" "Description: %s"]
        for {set istring 0} {$istring < $strings2} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                putdebug "*** $type _insertSimpleNodeInfo: strings2: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                $nodetable insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names2 $istring] \
                      -text [_ [lindex $formats2 $istring] $s] \
                      -open no
            }
            incr i
        }
        putdebug "*** $type _insertSimpleNodeInfo: done"
    }
    typemethod _insertSupportedProtocols {nid report} {
        #* Insert Supported Protocols if node into tree view.
        
        if {[llength $report] < 3} {lappend report 0 0 0}
        if {[llength $report] > 3} {set report [lrange $report 0 2]}
        set protocols [lcc::OpenLCBProtocols GetProtocolNames $report]
        putdebug "*** $type _insertSupportedProtocols $nid $report"
        
        putdebug "*** $type _insertSupportedProtocols: protocols are $protocols"
        if {[llength $protocols] > 0} {
            $nodetable insert $nid end -id ${nid}_protocols \
                 -text {Protocols Supported} \
                 -open no
            foreach p $protocols {
                putdebug [list *** $type _insertSupportedProtocols: p = $p]
                $nodetable insert ${nid}_protocols end \
                      -id ${nid}_protocols_$p \
                      -text [lcc::OpenLCBProtocols ProtocolLabelString $p] \
                      -open no \
                      -tag protocol_$p
            }
        }
    }
    typemethod _SendEvent {} {
        #* Generate a PCER message.

        if {![winfo exists $eventlog]} {
            set eventlog [lcc::EventLog .eventlog%AUTO% \
                          -transport $transport]
        }
        $eventlog open
    }
    
    typevariable _datagramdata;# Datagram data buffer. 
    typevariable _currentnid;  # Node ID of the node we currently expect 
                               # datagrams from.
    
    typevariable _iocomplete;  # I/O completion flag.
    typemethod _datagramHandler {command sourcenid args} {
        #* Datagram handler.

        set data $args
        switch $command {
            datagramreceivedok {
                return
            }
            datagramrejected {
                if {$sourcenid ne $_currentnid} {return}
                set _datagramdata $data
                incr _iocomplete -1
            }
            datagramcontent {
                if {$sourcenid ne $_currentnid} {
                    $transport DatagramRejected $sourcenid 0x1000
                } else {
                    set _datagramdata $data
                    $transport DatagramReceivedOK $sourcenid
                    incr _iocomplete
                }
            }
        }
    }
    #* CDI text for nodes (indexed by Node IDs).
    typevariable CDIs_text -array {}
    #* CDI parsed XML trees (indexed by Node IDs).
    typevariable CDIs_xml  -array {}
    #* CDI Forms (indexed by Node IDs).
    typevariable CDIs_FormTLs -array {}
    typemethod _ReadCDI {x y} {
        #* Read in a CDI for the node at x,y
        
        putdebug "*** $type _ReadCDI $x $y"
        set id [$nodetable identify row $x $y]
        putdebug "*** $type _ReadCDI: id = $id"
        set nid [regsub {_protocols_CDI} $id {}]
        putdebug "*** $type _ReadCDI: nid = $nid"
        putdebug "*** $type _ReadCDI: \[info exists CDIs_text($nid)\] => [info exists CDIs_text($nid)]"
        if {![info exists CDIs_text($nid)] ||
            $CDIs_text($nid) eq ""} {
            putdebug "*** $type _ReadCDI: Going to read CDI for $nid"
            $transport configure -datagramhandler [mytypemethod _datagramHandler]
            set data [list 0x20 0x84 0x0FF]
            set _iocomplete 0
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [mytypevar _iocomplete]
            $transport configure -datagramhandler {}
            unset _currentnid
            set present [expr {[lindex $_datagramdata 1] == 0x87}]
            if {!$present} {return}
            set lowest 0x00000000
            set highest [expr {[lindex $_datagramdata 3] << 24}]
            set highest [expr {$highest | ([lindex $_datagramdata 4] << 16)}]
            set highest [expr {$highest | ([lindex $_datagramdata 5] << 8)}]
            set highest [expr {$highest | [lindex $_datagramdata 6]}]
            set flags [lindex $_datagramdata 7]
            if {($flags & 0x02) != 0} {
                set lowest [expr {[lindex $_datagramdata 8] << 24}]
                set lowest [expr {$lowest | ([lindex $_datagramdata 9] << 16)}]
                set lowest [expr {$lowest | ([lindex $_datagramdata 10] << 8)}]
                set lowest [expr {$lowest | [lindex $_datagramdata 11]}]
            }
            putdebug [format {*** %s _ReadCDI: lowest = %08X} $type $lowest]
            putdebug [format {*** %s _ReadCDI: highest = %08X} $type $highest]
            set start $lowest
            set end   [expr {$highest + 64}]
            set CDIs_text($nid) {}
            set EOS_Seen no
            putdebug "*** $type _ReadCDI: About to fire up progress dialog"
            for {set address $start} {$address < $end && !$EOS_Seen} {incr address $size} {
                set size [expr {$end - $address}]
                if {$size > 64} {set size 64}
                set data [list 0x20 0x43 \
                          [expr {($address & 0xFF000000) >> 24}] \
                          [expr {($address & 0xFF0000) >> 16}] \
                          [expr {($address & 0xFF00) >> 8}] \
                          [expr {$address & 0xFF}] \
                          $size]
                $transport configure -datagramhandler [mytypemethod _datagramHandler]
                set _iocomplete 0
                set _currentnid $nid
                $transport SendDatagram $nid $data
                vwait [mytypevar _iocomplete]
                $transport configure -datagramhandler {}
                unset _currentnid
                putdebug [format {*** %s _ReadCDI: address = %08X} $type $address]
                hexdump [format "*** %s _ReadCDI: datagram received: " $type] $_datagramdata
                set status [lindex $_datagramdata 1]
                if {$status == 0x53} {
                    set respaddress [expr {[lindex $_datagramdata 2] << 24}]
                    set respaddress [expr {$respaddress | ([lindex $_datagramdata 3] << 16)}]
                    set respaddress [expr {$respaddress | ([lindex $_datagramdata 4] << 8)}]
                    set respaddress [expr {$respaddress | [lindex $_datagramdata 5]}]
                    if {$respaddress == $address} {
                        set bytes [lrange $_datagramdata 6 end]
                        set count 0
                        foreach b $bytes {
                            if {$b == 0} {
                                set EOS_Seen yes
                                break
                            }
                            append CDIs_text($nid) [format {%c} $b]
                            incr count
                            if {$count >= $size} {break}
                        }
                    } else {
                        # ??? (bad return address)
                    }
                } else {
                    # error...
                    set error [expr {[lindex $_datagramdata 2] << 8}]
                    set error [expr {$error | [lindex $_datagramdata 3]}]
                    $logmessages insert end "[format {Read Reply error %04X} $error]"
                    set message { }
                    foreach b [lrange $_datagramdata 4 end] {
                        append message [format %c $b]
                    }
                    $logmessages insert end "$message\n"
                }
            }
            set CDIs_xml($nid) [ParseXML %AUTO% $CDIs_text($nid)]
            putdebug "*** $type _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) -nid $nid \
                   -layoutdb $layoutcontroldb \
                   -transport $transport \
                   -debugprint [myproc putdebug]]
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } elseif {![info exists CDIs_xml($nid)] ||
            $CDIs_xml($nid) eq {}} {
            
            set CDIs_xml($nid) [ParseXML %AUTO% \
                                          $CDIs_text($nid)]
            putdebug "*** $type _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) \
                   -nid $nid \
                   -transport $transport \
                   -layoutdb $layoutcontroldb \
                   -debugprint [myproc putdebug]]
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } elseif {![info exists CDIs_FormTLs($nid)] ||
                  $CDIs_FormTLs($nid) eq {} ||
                  ![winfo exists $CDIs_FormTLs($nid)]} {
            putdebug "*** $type _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) \
                   -nid $nid \
                   -transport $transport \
                   -layoutdb $layoutcontroldb \
                   -debugprint [myproc putdebug]]
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } else {
            putdebug "*** $type _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
            wm deiconify $CDIs_FormTLs($nid)
        }
    }
    typemethod _ViewCDI {} {
        set cdifile [tk_getOpenFile -defaultextension .xml \
                     -filetypes { {{XML Files} {.xml} }
                                  {{Text Files} {.txt} }
                                  {{All Files} * } } \
                     -initialdir [pwd] \
                     -initialfile cdi.xml \
                     -parent . \
                     -title "Select a CDI XML file to display"]
        if {$cdifile eq {}} {return}
        if {[catch {open $cdifile r} infp]} {
            tk_messageBox -type ok -icon error \
                  -message [_ "Could not open %s because %s" $cdifile $infp]
            return
        }
        set CDIs_text($cdifile) [read $infp]
        close $infp
        set CDIs_xml($cdifile) [ParseXML %AUTO% $CDIs_text($cdifile)]
        if {[info exists CDIs_FormTLs($cdifile)] && 
            [winfo exists $CDIs_FormTLs($cdifile)]} {
            destroy $CDIs_FormTLs($cdifile)
        }
        set CDIs_FormTLs($cdifile) \
              [lcc::ConfigurationEditor \
               .cdi[regsub -all {.} [file tail $cdifile] {}]%AUTO% \
               -cdi $CDIs_xml($cdifile) \
               -displayonly true \
               -debugprint [myproc putdebug]]
    }
    typemethod _editLayoutControlItem {what name args} {
        #puts stderr "*** _editLayoutControlItem $what $name $args"
        switch $what {
            block {
                $editblockW Load $name -db $layoutcontroldb
                $layoutcontrolsNB select $editblockW
            }
            turnout {
                $editturnoutW Load $name -db $layoutcontroldb
                $layoutcontrolsNB select $editturnoutW
            }
            sensor {
                $editsensorW Load $name -db $layoutcontroldb
                $layoutcontrolsNB select $editsensorW
            }
            control {
                $editcontrolW Load $name -db $layoutcontroldb
                $layoutcontrolsNB select $editcontrolW
            }
        }
    }
    typemethod _ViewLayoutControlDB {} {
        if {$layoutControlView eq {}} {
            set layoutControlView [toplevel .layoutControlView]
            wm withdraw  .layoutControlView
            wm transient .layoutControlView .
            wm title     .layoutControlView [_ "Layout Control Database"]
            wm protocol  .layoutControlView WM_DELETE_WINDOW \
                  [list wm withdraw  .layoutControlView]
            set scrollw [ScrolledWindow .layoutControlView.scrollw]
            pack $scrollw -expand yes -fill both
            set layoutControlTable [::lcc::LayoutControlDBTable \
                                    [$scrollw getframe].layoutControlTable \
                                    -itemeditor [mytypemethod _editLayoutControlItem]]
            $scrollw setwidget $layoutControlTable
            set layoutControlsLF [ttk::labelframe \
                                  .layoutControlView.layoutControlsLF \
                                  -text [_m "Label|Layout Controls"]]
            pack $layoutControlsLF -fill x
            set layoutcontrolsNB [ScrollTabNotebook \
                                  $layoutControlsLF.layoutcontrolsNB]
            pack $layoutcontrolsNB -fill both -expand yes
            set editturnoutW [::lcc::NewTurnoutWidget \
                              $layoutcontrolsNB.editturnoutW \
                              -edit true]
            $layoutcontrolsNB add $editturnoutW -text [_m "Label|Turnout"]
            set editblockW [::lcc::NewBlockWidget \
                              $layoutcontrolsNB.editblockW \
                              -edit true]
            $layoutcontrolsNB add $editblockW -text [_m "Label|Block"]
            set editsensorW [::lcc::NewSensorWidget \
                              $layoutcontrolsNB.editsensorW \
                              -edit true]
            $layoutcontrolsNB add $editsensorW -text [_m "Label|Sensor"]
            set editcontrolW [::lcc::NewControlWidget \
                              $layoutcontrolsNB.editcontrolW \
                              -edit true]
            $layoutcontrolsNB add $editcontrolW -text [_m "Label|Control"]
            #set editturnoutW [::lcc::NewTurnoutWidget \
            #                  $layoutcontrolsNB.editturnoutW \
            #                  -edit true]
            #$layoutcontrolsNB add $editturnoutW -text [_m "Label|Turnout"]
            set buttons [ButtonBox .layoutControlView.buttons \
                         -orient horizontal]
            pack $buttons -fill x
            $buttons add ttk::button refresh \
                  -text [_m "Label|Refresh"] \
                  -command [mytypemethod _reloadLayoutControlTable]
            $buttons add ttk::button close \
                  -text [_m "Label|Close Window"] \
                  -command [list wm withdraw  .layoutControlView]
            
        }
        $layoutControlTable configure -db $layoutcontroldb
        $layoutControlTable Refresh
        wm deiconify $layoutControlView
    }
    typemethod _reloadLayoutControlTable {} {
        wm withdraw  $layoutControlView
        $layoutControlTable Refresh
        wm deiconify $layoutControlView
    }
    typemethod _MemoryConfig {x y} {
        #* Configure the memory for the node at x,y

        putdebug "*** $type _MemoryConfig $x $y"
        set id [$nodetable identify row $x $y]
        putdebug "*** $type _MemoryConfig: id = $id"
        set nid [regsub {_protocols_MemoryConfig} $id {}]
        putdebug "*** $type _MemoryConfig: nid = $nid"
        set count 10
        $transport configure -datagramhandler [mytypemethod _datagramHandler]
        set _iocomplete 0
        while {$count > 0 && $_iocomplete <= 0} {
            set _iocomplete 0
            set data [list 0x20 0x80]
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [mytypevar _iocomplete]
            if {$_iocomplete < 0} {
                incr count -1
            }
        }
        unset _currentnid
        $transport configure -datagramhandler {}
        if {$_iocomplete < 0} {
            tk_messageBox -icon warning \
                  -message [_ "Could not get configuration options for %s!" $nid] \
                  -type ok
            return
        }
        set available [expr {([lindex $_datagramdata 2] << 8) | [lindex $_datagramdata 3]}]
        set writelens [lindex $_datagramdata 4]
        set highest [lindex $_datagramdata 5]
        set lowest 0xFD
        set name ""
        if {[llength  $_datagramdata] >= 7} {
            set lowest [lindex $_datagramdata 6]
            foreach b [lrange $_datagramdata 7 end] {
                if {$b == 0} {break}
                append name [format %c $b]
            }
        }
        lcc::ConfigOptions .configopts[regsub {:} $nid {}]%AUTO% \
              -nid $nid \
              -available $available \
              -writelengths $writelens \
              -highest $highest \
              -lowest $lowest \
              -name "$name" \
              -debugprint [myproc putdebug]
        lcc::ConfigMemory .configmem[regsub {:} $nid {}]%AUTO% \
              -destnid $nid \
              -transport $transport \
              -debugprint [myproc putdebug]
    }
    
    typemethod _carefulExit {} {
        #* Exit method.

        exit
    }
    proc countNUL {list} {
        #* Procedure to count the NUL bytes in list.
        
        set count 0
        set start 0
        while {[set i [lsearch -start $start $list 0]] >= 0} {
            incr count
            set start [expr {$i + 1}]
        }
        return $count
    }
}

