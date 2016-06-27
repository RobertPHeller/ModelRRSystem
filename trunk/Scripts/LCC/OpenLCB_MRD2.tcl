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
#  Last Modified : <160627.1554>
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

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCBTcpHub]

package require Azatrax;#  require the Azatrax package
package require snit;#     require the SNIT OO framework
package require LCC;#      require the OpenLCB code
package require ParseXML;# require the XML parsing code (for the conf file)
package require gettext;#  require the localized message handler

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]


snit::type OpenLCB_MRD2 {
    typecomponent transport; #        Transport layer
    typecomponent configuration;#     Parsed  XML configuration
    typevariable  devicelist {};#     Device list
    typevariable  consumers {};#      Devices that consume events
    typevariable  eventsconsumed {};# Events consumed.
    typevariable  producers {};#      Devices that produce events
    typevariable  eventsproduced {};# Events produced.
    
    typeconstructor {
        global argv
        global argc
        global argv0
        
        puts stderr "*** $type typeconstructor: argv = $argv"
        set configureator no
        set configureIdx [lsearch -exact $argv -configure]
        if {$configureIdx >= 0} {
            set configureator yes
            set argv [lreplace $argv $configureIdx $configureIdx]
        }
        set debugnotvis 1
        set debugIdx [lsearch -exact $argv -debug]
        if {$debugIdx >= 0} {
            set debugnotvis 0
            set argv [lreplace $argv $debugIdx $debugIdx]
        }
        set conffile [from argv -configuration "mrd2conf.xml"]
        puts stderr "*** $type typeconstructor: configureator = $configureator, debugnotvis = $debugnotvis, conffile = $conffile"
        if {$configureator} {
            $type ConfiguratorGUI $conffile
            return
        }
        
        if {[catch {open $conffile r} conffp]} {
            error [_ "Could not open %s because: %s" $conffile $conffp]
            exit 99
        }
        set confXML [read $conffp]
        close $conffp
        if {[catch {ParseXML create %AUTO% $confXML} configuration]} {
            error [_ "Could not parse configuration file %s: %s" $conffile $configuration]
            exit 98
        }
        set transcons [$configuration getElementsByTagName "transport"]
        puts stderr "*** $type typeconstructor: transcons:"
        $transcons display stderr "    "
        set constructor [$transcons getElementsByTagName "constructor"]
        if {$constructor eq {}} {
            error [_ "Transport constructor missing!"]
            exit 97
        }
        puts stderr "*** $type typeconstructor: constructor:"
        $constructor display stderr "    "
        set options [$transcons getElementsByTagName "options"]
        set transportOpts {}
        if {$options ne {}} {
            puts stderr "*** $type typeconstructor:  options:"
            $options display stderr "    "
            set transportOpts [$options data]
        } else {
            puts stderr "*** $type typeconstructor: no options."
        }
        
        set transportConstructors [info commands ::lcc::[$constructor data]]
        if {[llength $transportConstructors] > 0} {
            set transportConstructor [lindex $transportConstructors 0]
        }
        if {$transportConstructor eq {}} {
            error [_ "No valid transport constructor found!"]
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
                          -softwaremodel "OpenLCB MRD2" \
                          -softwareversion "1.0" \
                          -nodename $nodename \
                          -nodedescription $nodedescriptor \
                          -additionalprotocols {EventExchange} \
                          ] \
                          $transportOpts} transport]} {
            error [_ "Could not open OpenLCBNode: %s" $transport]
            exit 95
        }
        foreach device [$configuration getElementsByTagName "device"] {
            set devicecommand [list $type create %AUTO%]
            set consume no
            set produce no
            set serial [$device getElementsByTagName "serial"]
            if {[llength $serial] != 1} {
                error [_ "Missing or multiple serial numbers"]
                exit 94
            }
            lappend devicecommand -sensorserial [$serial data]
            set description [$device getElementsByTagName "description"]
            if {[llength $description] > 0} {
                lappend devicecommand -description [[lindex $description 0] data]
            }
            foreach k {sense1on sense1off sense2on sense2off latch1on 
                       latch1off latch2on latch2off} {
                set tag [$device getElementsByTagName $k]
                if {[llength $tag] == 0} {continue}
                set tag [lindex $tag 0]
                set produce yes
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend devicecommand -$k $ev
                lappend eventsproduced $ev
            }
            foreach k {setchan1 setchan2} {
                set tag [$device getElementsByTagName $k]
                if {[llength $tag] == 0} {continue}
                set tag [lindex $tag 0]
                set consume yes
                set ev [lcc::EventID create %AUTO% -eventidstring [$tag data]]
                lappend devicecommand -$k $ev
                lappend eventsconsumed $ev
            }
            if {!$consume && !$produce} {
                puts stderr [_ "Useless device (S# %s) (neither consumes or produces events)" [$serial data]]
                continue
            }
            set dev [eval $devicecommand]
            if {$consume} {lappend consumers $dev}
            if {$produce} {lappend producers $dev}
            lappend devicelist $dev
        }
        if {[llength $devicelist] == 0} {
            error [_ "No devices specified!"]
            exit 93
        }
        after 500 [mytypemethod _poll]
    }
    typemethod _poll {} {
        foreach p $producers {
            $p Poll
        }
        after 500 [mytypemethod _poll]
    }
    typemethod _eventHandler {command eventid {validity {}}} {
        #* Event handler -- when a PCER message is received
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
            }
            identifyproducer {
            }
            identifyevents {
            }
            report {
                foreach c $consumers {
                    #puts stderr "*** $type _eventHandler: device is [$c cget -sensorserial]"
                    #puts stderr "*** $type _eventHandler: event is [$eventid cget -eventidstring]"
                    $c consumeEvent $eventid
                    
                }
            }
        }
    }
    typemethod _messageHandler {message} {
        switch [format {0x%04X} [$message cget -mti]] {
            0x0490 -
            0x0498 {
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
    
    typecomponent main;# Main Frame.
    typecomponent scroll;# Scrolled Window.
    typecomponent editframe;# Scrollable Frame
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    typecomponent   devices;# Device list
    typevariable    devicecount 0;# device count
    
    typevariable status {};# Status line
    typevariable conffilename {};# Configuration File Name
    
    typevariable _menu {
        "[_m {Menu|&File}]" {file:menu} {file} 0 {
            {command "[_m {Menu|File|&Save and Exit}]" {file:saveexit} "[_ {Save and exit}]" {Ctrl s} -command "[mytypemethod _saveexit]"}
            {command "[_m {Menu|File|&Exit}]" {file:exit} "[_ {Exit}]" {Ctrl q} -command "[mytypemethod _exit]"}
        } "[_m {Menu|&Edit}]" {edit} {edit} 0 {
            {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut}}
            {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy}}
            {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear}}
        }
    }
    
    typevariable default_confXML {<xml version="1.0" encoding="ISO-8859-1"?><OpenLCB_MRD2/></xml>}
    typemethod ConfiguratorGUI {conffile} {
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
                           -text "Select" -command [mytypemethod _seltransc]]
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
                           -text "Select" -command [mytypemethod _seltransopt]]
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
        set devices [ScrollTabNotebook $frame.devices]
        pack $devices -expand yes -fill both
        foreach device [$cdi getElementsByTagName "device"] {
            $type _create_and_populate_device $device
        }
        set adddevice [ttk::button $frame.adddevice \
                       -text [_m "Label|Add another device"] \
                       -command [mytypemethod _addblankdevice]]
        pack $adddevice -fill x
    }
    typemethod _saveexit {} {
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
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
            $transcons addchild $constructor
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
        foreach device [$cdi getElementsByTagName "device"] {
            $type _copy_from_gui_to_XML $device
        }
        
        if {![catch {open $conffilename w} conffp]} {
            $configuration displayTree $conffp
        }
        ::exit
    }
    typemethod _copy_from_gui_to_XML {device} {
        set fr [$device attribute frame]
        set frbase $devices.$fr
        set serial [$device getElementsByTagName "serial"]
        if {[llength $serial] < 1} {
            set serial [SimpleDOMElement %AUTO% -tag "serial"]
            $device addchild $serial
        }
        $serial setdata [$frbase.serial get]
        set description_ [$frbase.description get]
        if {$description_ eq ""} {
            set description [$device getElementsByTagName "description"]
            if {[llength $description] == 1} {
                $device removechild $description
            }
        } else {
            set description [$device getElementsByTagName "description"]
            if {[llength $description] < 1} {
                set description [SimpleDOMElement %AUTO% -tag "description"]
                $device addchild $description
            }
            $description setdata $description_
        }
        set sense1on_ [$frbase.sense1on get]
        if {$sense1on_ eq ""} {
            set sense1on [$device getElementsByTagName "sense1on"]
            if {[llength $sense1on] == 1} {
                $device removechild $sense1on
            }
        } else {
            set sense1on [$device getElementsByTagName "sense1on"]
            if {[llength $sense1on] < 1} {
                set sense1on [SimpleDOMElement %AUTO% -tag "sense1on"]
                $device addchild $sense1on
            }
            $sense1on setdata $sense1on_
        }
        
        set sense1off_ [$frbase.sense1off get]
        if {$sense1off_ eq ""} {
            set sense1off [$device getElementsByTagName "sense1off"]
            if {[llength $sense1off] == 1} {
                $device removechild $sense1off
            }
        } else {
            set sense1off [$device getElementsByTagName "sense1off"]
            if {[llength $sense1off] < 1} {
                set sense1off [SimpleDOMElement %AUTO% -tag "sense1off"]
                $device addchild $sense1off
            }
            $sense1off setdata $sense1off_
        }
        
        set sense2on_ [$frbase.sense2on get]
        if {$sense2on_ eq ""} {
            set sense2on [$device getElementsByTagName "sense2on"]
            if {[llength $sense2on] == 1} {
                $device removechild $sense2on
            }
        } else {
            set sense2on [$device getElementsByTagName "sense2on"]
            if {[llength $sense2on] < 1} {
                set sense2on [SimpleDOMElement %AUTO% -tag "sense2on"]
                $device addchild $sense2on
            }
            $sense2on setdata $sense2on_
        }
        
        set sense2off_ [$frbase.sense2off get]
        if {$sense2off_ eq ""} {
            set sense2off [$device getElementsByTagName "sense2off"]
            if {[llength $sense2off] == 1} {
                $device removechild $sense2off
            }
        } else {
            set sense2off [$device getElementsByTagName "sense2off"]
            if {[llength $sense2off] < 1} {
                set sense2off [SimpleDOMElement %AUTO% -tag "sense2off"]
                $device addchild $sense2off
            }
            $sense2off setdata $sense2off_
        }
        
        set latch1on_ [$frbase.latch1on get]
        if {$latch1on_ eq ""} {
            set latch1on [$device getElementsByTagName "latch1on"]
            if {[llength $latch1on] == 1} {
                $device removechild $latch1on
            }
        } else {
            set latch1on [$device getElementsByTagName "latch1on"]
            if {[llength $latch1on] < 1} {
                set latch1on [SimpleDOMElement %AUTO% -tag "latch1on"]
                $device addchild $latch1on
            }
            $latch1on setdata $latch1on_
        }
        
        set latch1off_ [$frbase.latch1off get]
        if {$latch1off_ eq ""} {
            set latch1off [$device getElementsByTagName "latch1off"]
            if {[llength $latch1off] == 1} {
                $device removechild $latch1off
            }
        } else {
            set latch1off [$device getElementsByTagName "latch1off"]
            if {[llength $latch1off] < 1} {
                set latch1off [SimpleDOMElement %AUTO% -tag "latch1off"]
                $device addchild $latch1off
            }
            $latch1off setdata $latch1off_
        }
        
        set latch2on_ [$frbase.latch2on get]
        if {$latch2on_ eq ""} {
            set latch2on [$device getElementsByTagName "latch2on"]
            if {[llength $latch2on] == 1} {
                $device removechild $latch2on
            }
        } else {
            set latch2on [$device getElementsByTagName "latch2on"]
            if {[llength $latch2on] < 1} {
                set latch2on [SimpleDOMElement %AUTO% -tag "latch2on"]
                $device addchild $latch2on
            }
            $latch2on setdata $latch2on_
        }
        
        set latch2off_ [$frbase.latch2off get]
        if {$latch2off_ eq ""} {
            set latch2off [$device getElementsByTagName "latch2off"]
            if {[llength $latch2off] == 1} {
                $device removechild $latch2off
            }
        } else {
            set latch2off [$device getElementsByTagName "latch2off"]
            if {[llength $latch2off] < 1} {
                set latch2off [SimpleDOMElement %AUTO% -tag "latch2off"]
                $device addchild $latch2off
            }
            $latch2off setdata $latch2off_
        }
        
        set setchan1_ [$frbase.setchan1 get]
        if {$setchan1_ eq ""} {
            set setchan1 [$device getElementsByTagName "setchan1"]
            if {[llength $setchan1] == 1} {
                $device removechild $setchan1
            }
        } else {
            set setchan1 [$device getElementsByTagName "setchan1"]
            if {[llength $setchan1] < 1} {
                set setchan1 [SimpleDOMElement %AUTO% -tag "setchan1"]
                $device addchild $setchan1
            }
            $setchan1 setdata $setchan1_
        }
        
        set setchan2_ [$frbase.setchan2 get]
        if {$setchan2_ eq ""} {
            set setchan2 [$device getElementsByTagName "setchan2"]
            if {[llength $setchan2] == 1} {
                $device removechild $setchan2
            }
        } else {
            set setchan2 [$device getElementsByTagName "setchan2"]
            if {[llength $setchan2] < 1} {
                set setchan2 [SimpleDOMElement %AUTO% -tag "setchan2"]
                $device addchild $setchan2
            }
            $setchan2 setdata $setchan2_
        }
        
    }
    typemethod _exit {} {
        ::exit
    }
    typemethod _seltransc {} {
        set result [lcc::OpenLCBNode selectTransportConstructor]
        if {$result ne {}} {
            if {$result ne $transconstructorname} {set transopts {}}
            set transconstructorname [namespace tail $result]
        }
    }
    typemethod _seltransopt {} {
        if {$transconstructorname ne ""} {
            set transportConstructors [info commands ::lcc::$transconstructorname]
            #puts stderr "*** $type typeconstructor: transportConstructors is $transportConstructors"
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
    typemethod _create_and_populate_device {device} {
        incr devicecount
        set fr device$devicecount
        set f [$device attribute frame]
        if {$f eq {}} {
            set attrs [$device cget -attributes]
            lappend attrs frame $fr
            $device configure -attributes $attrs
        } else {
            set attrs [$device cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $device configure -attributes $attrs
        }
        set devframe [ttk::frame \
                      $devices.$fr]
        $devices add $devframe \
              -text [_ "Device %s" $devicecount] -sticky news
        set serial_ [LabelEntry $devframe.serial \
                     -label [_m "Label|Serial Number"]]
        pack $serial_ -fill x -expand yes
        set serial [$device getElementsByTagName "serial"]
        if {[llength $serial] == 1} {
            $serial_ configure -text [$serial data]
        }
        set description_ [LabelEntry $devframe.description \
                          -label [_m "Label|Description"]]
        pack $description_ -fill x -expand yes
        set description [$device getElementsByTagName "description"]
        if {[llength $description] == 1} {
            $description_ configure -text [$description data]
        }
        set sense1on_ [LabelEntry $devframe.sense1on \
                       -label [_m "Label|Sense 1 On"]]
        pack $sense1on_ -fill x -expand yes
        set sense1on [$device getElementsByTagName "sense1on"]
        if {[llength $sense1on] == 1} {
            $sense1on_ configure -text [$sense1on data]
        }
        set sense1off_ [LabelEntry $devframe.sense1off \
                        -label [_m "Label|Sense 1 Off"]]
        pack $sense1off_ -fill x -expand yes
        set sense1off [$device getElementsByTagName "sense1off"]
        if {[llength $sense1off] == 1} {
            $sense1off_ configure -text [$sense1off data]
        }
        set sense2on_ [LabelEntry $devframe.sense2on \
                       -label [_m "Label|Sense 2 On"]]
        pack $sense2on_ -fill x -expand yes
        set sense2on [$device getElementsByTagName "sense2on"]
        if {[llength $sense2on] == 1} {
            $sense2on_ configure -text [$sense2on data]
        }
        set sense2off_ [LabelEntry $devframe.sense2off \
                        -label [_m "Label|Sense 2 Off"]]
        pack $sense2off_ -fill x -expand yes
        set sense2off [$device getElementsByTagName "sense2off"]
        if {[llength $sense2off] == 1} {
            $sense2off_ configure -text [$sense2off data]
        }
        set latch1on_ [LabelEntry $devframe.latch1on \
                       -label [_m "Label|Latch 1 On"]]
        pack $latch1on_ -fill x -expand yes
        set latch1on [$device getElementsByTagName "latch1on"]
        if {[llength $latch1on] == 1} {
            $latch1on_ configure -text [$latch1on data]
        }
        set latch1off_ [LabelEntry $devframe.latch1off \
                        -label [_m "Label|Latch 1 Off"]]
        pack $latch1off_ -fill x -expand yes
        set latch1off [$device getElementsByTagName "latch1off"]
        if {[llength $latch1off] == 1} {
            $latch1off_ configure -text [$latch1off data]
        }
        set latch2on_ [LabelEntry $devframe.latch2on \
                       -label [_m "Label|Latch 2 On"]]
        pack $latch2on_ -fill x -expand yes
        set latch2on [$device getElementsByTagName "latch2on"]
        if {[llength $latch2on] == 1} {
            $latch2on_ configure -text [$latch2on data]
        }
        set latch2off_ [LabelEntry $devframe.latch2off \
                        -label [_m "Label|Latch 2 Off"]]
        pack $latch2off_ -fill x -expand yes
        set latch2off [$device getElementsByTagName "latch2off"]
        if {[llength $latch2off] == 1} {
            $latch2off_ configure -text [$latch2off data]
        }
        set setchan1_ [LabelEntry $devframe.setchan1 \
                       -label [_m "Label|Setchan 1"]]
        pack $setchan1_ -fill x -expand yes
        set setchan1 [$device getElementsByTagName "setchan1"]
        if {[llength $setchan1] == 1} {
            $setchan1_ configure -text [$setchan1 data]
        }
        set setchan2_ [LabelEntry $devframe.setchan2 \
                       -label [_m "Label|Setchan 2"]]
        pack $setchan2_ -fill x -expand yes
        set setchan2 [$device getElementsByTagName "setchan2"]
        if {[llength $setchan2] == 1} {
            $setchan2_ configure -text [$setchan2 data]
        }
        set deldevice [ttk::button $devframe.deletedev \
                       -text [_m "Label|Delete Device"] \
                       -command [mytypemethod _deleteDevice $device]]
        pack $deldevice -fill x
    }
    typemethod _addblankdevice {} {
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
        set cdi [lindex $cdis 0]
        set device [SimpleDOMElement %AUTO% -tag "device"]
        $cdi addchild $device
        $type _create_and_populate_device $device
    }
    typemethod _deleteDevice {device} {
        set fr [$device attribute frame]
        set cdis [$configuration getElementsByTagName OpenLCB_MRD2 -depth 1]
        set cdi [lindex $cdis 0]
        $cdi removeChild $device
        $devices forget $devices.$fr
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
        set options(-sensorserial) [from args -sensorserial]
        if {$options(-sensorserial) eq {}} {
            error [_ "The -sensorserial option is required!"]
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
    method Poll {} {
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
            $transport ProduceEvent $event
        }
    }
    method consumeEvent {event} {
        #puts stderr "*** $self consumeEvent $event"
        $sensor GetStateData
        #puts stderr "*** $self consumeEvent: HasRelays: [$sensor HasRelays]"
        if {![$sensor HasRelays]} {return false}
        #puts stderr "*** $self consumeEvent: setchan1 event is [$self cget -setchan1]"
        if {[$event match [$self cget -setchan1]]} {
            #puts stderr "*** $self consumeEvent: setchan1 event matches!"
            $sensor SetChan1
            return true
        }
        #puts stderr "*** $self consumeEvent: setchan2 event is [$self cget -setchan2]"
        if {[$event match [$self cget -setchan2]]} {
            #puts stderr "*** $self consumeEvent: setchan2 event matches!"
            $sensor SetChan2
            return true
        }
        return false
    }
}

vwait forever
