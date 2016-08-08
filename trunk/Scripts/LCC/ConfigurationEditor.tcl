#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Feb 22 09:45:31 2016
#  Last Modified : <160808.0939>
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

package require Tk
package require tile
package require snit
package require ParseXML
package require LabelFrames
package require ScrollableFrame
package require ScrollWindow
package require MainFrame
package require snitStdMenuBar
package require ButtonBox
package require ScrollTabNotebook
package require LCC

namespace eval lcc {
    ## 
    # @section ConfigurationEditor Package provided
    #
    # ConfigurationEditor 1.0
    
    snit::widget ConfigurationEditor {
        ## @brief Generate OpenLCB Memory Configuration Window.
        # Create a toplevel to configure a node's Memory using that
        # node's (parsed) CDI.  This GUI uses tabbed notebook
        # widgets for segments and replicated groups to reduce the amount
        # of scrolling (and because a ginormous scrollable frame dies with
        # a X11 Pixmap allocation error).
        #
        # @param Options:
        # @arg -cdi The parsed CDI xml. Required and there is no default.
        # @arg -nid The Node ID of the node to be configured.  Required 
        #             and there is no default.
        # @arg -transport The transport object.  Needs to implement 
        # @c SendDatagram, @c DatagramReceivedOK, and @c DatagramRejected
        # methods and have an @c -datagramhandler option.
        # @arg -displayonly A flag indicating that the CDI is just to be
        # displayed.  The default is false.
        # @arg -debugprint A function to handle debug output.
        # @arg -class Delegated to the toplevel.
        # @arg -menu  Delegated to the toplevel
        # @arg -height Delegated to the ScrollableFrame
        # @arg -areaheight Delegated to the ScrollableFrame
        # @arg -width Delegated to the ScrollableFrame
        # @arg -areawidth Delegated to the ScrollableFrame
        
        
        
        widgetclass ConfigurationEditor
        hulltype tk::toplevel 
        
        delegate option -class to hull
        delegate option -menu to hull
        component main
        ## @privatesection Main Frame.
        component scroll
        ## Scrolled Window.
        component editframe
        ## Scrollable Frame
        
        option -cdi -readonly yes
        option -nid -readonly yes -type lcc::nid -default "05:01:01:01:22:00"
        option -transport -readonly yes -default {}
        option -displayonly -readonly yes -type snit::boolean -default false
        option -debugprint -readonly yes -default {}
        #option -height -type {snit::pixels -min 100}
        delegate option -height to editframe
        delegate option -areaheight to editframe
        #option -width  -type {snit::pixels -min 100}
        delegate option -width to editframe
        delegate option -areawidth to editframe
        
        
        variable cdi
        ## CDI XML Object.
        variable _ioComplete
        ## I/O Completion Flag.
        variable status
        ## Status variable.
        
        typevariable _menu {
            "[_m {Menu|&File}]" {file:menu} {file} 0 {
                {command [_m "Menu|File|&Close"] {file:close} "[_ {Close the editor}]" {Ctrl c} -command "[mymethod _close]"}
            } "[_m {Menu|&Edit}]" {edit} {edit} 0 {
                {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut}}
                {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy}}
                {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear}}
            }
        }
        ## Generic menu.
        
        method putdebug {message} {
            ## Print message using debug output, if any.
            #
            # @param message The message to print.
            
            set debugout [$self cget -debugprint]
            if {$debugout ne ""} {
                uplevel #0 [list $debugout "$message"]
            }
        }
        
        constructor {args} {
            ## @publicsection @brief Constructor: create the configuration editor.
            # Construct a memory configuration window to edit the configuration
            # memory of an OpenLCB node.  The window is created from the 
            # toplevel up.
            #
            # @param name Widget path.
            # @param ... Options:
            # @arg -cdi The parsed CDI xml. Required and there is no default.
            # @arg -nid The Node ID of the node to be configured.  Required 
            #             and there is no default.
            # @arg -transport The transport object.  Needs to implement 
            # @c SendDatagram, @c DatagramReceivedOK, and @c DatagramRejected
            # methods and have an @c -datagramhandler option.
            # @arg -displayonly A flag indicating that the CDI is just to be
            # displayed.  The default is false.
            # @arg -debugprint A function to handle debug output.
            # @arg -class Delegated to the toplevel.
            # @arg -menu  Delegated to the toplevel
            # @arg -height Delegated to the ScrollableFrame
            # @arg -areaheight Delegated to the ScrollableFrame
            # @arg -width Delegated to the ScrollableFrame
            # @arg -areawidth Delegated to the ScrollableFrame
            # @par
            
            if {[lsearch $args -cdi] < 0} {
                error [_ "The -cdi option is required!"]
            }
            set options(-displayonly) [from args -displayonly]
            if {!$options(-displayonly)} {
                if {[lsearch $args -nid] < 0} {
                    error [_ "The -nid option is required!"]
                }
                if {[lsearch $args -transport] < 0} {
                    error [_ "The -transport option is required!"]
                }
            }
            set options(-cdi) [from args -cdi]
            ParseXML validate $options(-cdi)
            set cdis [$options(-cdi) getElementsByTagName cdi -depth 1]
            if {[llength $cdis] != 1} {
                error [_ "There is no CDI container in %s" $options(-cdi)]
            }
            set cdi [lindex $cdis]
            $self putdebug "*** $type create $self: win = $win, about to wm protocol $win WM_DELETE_WINDOW ..."
            wm protocol $win WM_DELETE_WINDOW [mymethod _close]
            install main using MainFrame $win.main -menu [subst $_menu] \
                  -textvariable [myvar status]
            pack $main -expand yes -fill both
            set f [$main getframe]
            install scroll using ScrolledWindow $f.scroll -scrollbar vertical \
                  -auto vertical
            pack $scroll -expand yes -fill both
            install editframe using ScrollableFrame \
                  [$scroll getframe].editframe -constrainedwidth yes
            $scroll setwidget $editframe
            $self configurelist $args
            $self putdebug "*** $type create $self: win = $win, about to wm title $win ..."
            wm title $win [_ "CDI Configuration Tool for Node ID %s" [$self cget -nid]]
            set address 0
            $self _processXMLnode $cdi [$editframe getframe] -1 address
#            $self _processXMLnode $cdi [$main getframe] -1 address
        }
        typevariable idheaders -array {}
        ## @privatesection Locale versions of the identification headers.
        
        typeconstructor {
            set idheaders(manufacturer) [_m "Label|Manufacturer"]
            set idheaders(model) [_m "Label|Model"]
            set idheaders(hardwareVersion) [_m "Label|Hardware Version"]
            set idheaders(softwareVersion) [_m "Label|Software Version"]
        }
        variable _readall -array {}
        ## Holds all of the Read buttons for each segment.  This allows for
        # Reading all of the variables in a segment.
        variable _segmentnumber 0
        ## Segement number, used to insure unique widget names.
        variable _groupnumber 0
        ## Group number, used to insure unique widget names.
        variable _intnumber 0
        ## Integer number, used to insure unique widget names.
        variable _stringnumber 0
        ## String number, used to insure unique widget names.
        variable _eventidnumber 0
        ## Eventid number, used to insure unique widget names.
        method _processXMLnode {n frame space address_var} {
            ## @brief Process one node in the XML tree.
            # Process a single node in the XML tree.  Will recurse to process
            # Children nodes.
            # 
            # Ttk::labelframes are used for variables with names. Ttk::notebooks, except 
            # segments and groups.  A ttk::labelframe is also used for the
            # information block.
            #
            # @param n The node.
            # @param frame The parent frame.
            # @param space The current space.
            # @param address_var The name of the address variable.
            
            $self putdebug "*** $self _processXMLnode $n $frame $space $address_var"
            upvar $address_var address
            $self putdebug "*** $self _processXMLnode: tag is [$n cget -tag] at address [format %08x $address]"
            switch [$n cget -tag] {
                cdi {
                    set id [$n getElementsByTagName identification -depth 1]
                    if {[llength $id] == 1} {
                        $self _processXMLnode [lindex $id 0] $frame $space address
                    }
                    set segnotebook [ttk::notebook $frame.segments]
                    pack $segnotebook -fill both -expand yes
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        $self _processXMLnode $seg $segnotebook $space address
                    }
                }
                identification {
                    set idf [ttk::labelframe $frame.identification \
                             -labelanchor nw \
                             -text [_m "Label|Identification"]]
                    pack $idf -fill x;#-expand yes 
                    foreach ic [$n children] {
                        set t [$ic cget -tag]
                        if {[info exists idheaders($t)]} {
                            set le [LabelEntry $idf.$t \
                                    -label $idheaders($t) \
                                    -text  [$ic data] \
                                    -editable no]
                            pack $le -expand yes -fill x
                        } elseif {$t eq {map}} {
                            set name [$ic getElementsByTagName name -depth 1]
                            if {[llength $name] == 1} {
                                set name [[lindex $name 0] data]
                            } else {
                                set name {}
                            }
                            set idfmap [ttk::labelframe $idf.map \
                                        -labelanchor nw
                                        -text $name]
                            pack $idfmap -expand yes -fill x
                            set descr [$ic getElementsByTagName description -depth 1]
                            if {[llength $descr] == 1} {
                                set description [[lindex $descr 0] data]
                                set lab [ttk::label $idfmap.descr \
                                         -text $description]
                                pack $lab -fill x
                            }
                            set irel 0
                            foreach rel [$ic getElementsByTagName relation -depth 1] {
                                set prop [[lindex [$rel getElementsByTagName property -depth 1] 0] data]
                                set val  [[lindex [$rel getElementsByTagName value -depth 1] 0] data]
                                incr irel
                                set le [LabelEntry $idfmap.prop$irel \
                                        -label $prop -text $val -editable no]
                                pack $le -expand yes -fill x
                            }
                        }
                    }
                }
                acdi {
                }
                segment {
                    $self putdebug "$self _processXMLnode (segment branch): n is: "
                    #$n display stderr {        }
                    incr _segmentnumber
                    set _groupnumber 0
                    set _intnumber 0
                    set _stringnumber 0
                    set _eventidnumber 0
                    set space [$n attribute space]
                    set origin [$n attribute origin]
                    if {$origin eq {}} {set origin 0}
                    set address $origin
                    set name [$n getElementsByTagName name -depth 1]
                    $self putdebug "$self _processXMLnode (segment branch): name is $name (length is [llength $name])\n"
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    #set segmentscrollframe [ScrolledWindow \
                    #                        $frame.segment$_segmentnumber \
                    #                        -scrollbar both -auto both]
                    #$frame add $segmentscrollframe -text $name -sticky news
                    #set segSF [ScrollableFrame [$segmentscrollframe getframe].segSF]
                    #$segmentscrollframe setwidget $segSF
                    #set segmentframe [$segSF getframe]
                    set segmentframe [ttk::frame $frame.segment$_segmentnumber]
                    $frame add $segmentframe -text $name -sticky news
                    set descr [$n getElementsByTagName description -depth 1]
                    if {[llength $descr] == 1} {
                        set description [[lindex $descr 0] data]
                        set lab [ttk::label $segmentframe.descr \
                                 -text $description]
                        pack $lab -expand yes -fill x
                    }
                    set groupnotebook {}
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        if {[$c cget -tag] eq "group"} {
                            if {$groupnotebook eq {}} {
                                set groupnotebook [ttk::notebook $segmentframe.groups]
                                pack $groupnotebook -expand yes -fill both
                            }
                            $self _processXMLnode $c $groupnotebook $space address
                        } else {
                            $self _processXMLnode $c $segmentframe $space address
                        }
                    }
                    set readall [ttk::button $segmentframe.readall \
                                 -text [_m "Label|Read All"] \
                                 -command [mymethod _readall $space]]
                    pack $readall -fill x -anchor center
                    if {$options(-displayonly)} {
                        $readall configure -state disabled
                    }
                }
                group {
                    incr _groupnumber
                    set _intnumber 0
                    set _stringnumber 0
                    set _eventidnumber 0
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    set replication [$n attribute replication]
                    if {$replication eq {}} {set replication 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    $self putdebug "$self _processXMLnode (group branch): name is $name (length is [llength $name]), address = [format %08x $address], offset is [format %04x $offset]\n"
                    if {[winfo class $frame] eq "TNotebook"} {
                        #set groupscrollframe [ScrolledWindow \
                        #                      $frame.group$_groupnumber \
                        #                      -scrollbar both -auto both]
                        #$frame add $groupscrollframe -text $name -sticky news
                        #set grpSF [ScrollableFrame [$groupscrollframe getframe].grpSF]
                        #$groupscrollframe setwidget $grpSF
                        #set groupframe [$grpSF getframe]
                        set groupframe [ttk::frame $frame.group$_groupnumber]
                        $frame add $groupframe -text $name -sticky news
                    } else {
                        if {$name ne {}} {
                            set groupframe [ttk::labelframe \
                                            $frame.group$_groupnumber \
                                            -labelanchor nw -text $name]
                        } else {
                            set groupframe [ttk::frame \
                                            $frame.group$_groupnumber]
                        }
                        pack $groupframe -fill x;# -expand yes
                    }
                    set descr [$n getElementsByTagName description -depth 1]
                    if {[llength $descr] == 1} {
                        set description [[lindex $descr 0] data]
                        set lab [ttk::label $groupframe.descr \
                                 -text $description]
                        pack $lab -fill x
                    }
                    set repname [$n getElementsByTagName repname -depth 1]
                    if {[llength $repname] == 1} {
                        set repnamefmt "[[lindex $repname 0] data] %d"
                    } else {
                        set repnamefmt {%d}
                    }
                    if {$replication > 1} {
                        #set replnotebook [ttk::notebook $groupframe.replnotebook]
                        set replnotebook [ScrollTabNotebook $groupframe.replnotebook]
                        pack $replnotebook  -expand yes -fill both
                        for {set i 1} {$i <= $replication} {incr i} {
                            #set replscrollframe [ScrolledWindow \
                            #                     $replnotebook.replication$i \
                            #                     -scrollbar both -auto both]
                            #$replnotebook add $replscrollframe \
                            #      -text [format $repnamefmt $i] -sticky news
                            #set replSF [ScrollableFrame \
                            #            [$replscrollframe getframe].replSF]
                            #$replscrollframe setwidget $replSF
                            #set replframe [$replSF getframe]
                            set replframe [ttk::frame \
                                           $replnotebook.replication$i]
                            $replnotebook add $replframe \
                                  -text [format $repnamefmt $i] -sticky news
                            set _intnumber 0
                            set _stringnumber 0
                            set _eventidnumber 0
                            incr address $offset
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name description repname} $tag] >= 0} {continue}
                                $self _processXMLnode $c $replframe $space address
                            }
                        }
                    } else {
                        incr address $offset
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname} $tag] >= 0} {continue}
                            $self _processXMLnode $c $groupframe $space address
                        }
                    }
                }
                int {
                    incr _intnumber
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    set defmin [expr {0 - (1 << (($size * 8) - 1))}]
                    set defmax [expr {wide(1 << (($size * 8) - 1)) - 1}]
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {$name ne {}} {
                        set intframe [ttk::labelframe \
                                      $frame.int$_intnumber \
                                      -labelanchor nw -text $name]
                    } else {
                        set intframe [ttk::frame \
                                      $frame.int$_intnumber]
                    }
                    pack $intframe -fill x;# -expand yes
                    set descr [$n getElementsByTagName description -depth 1]
                    if {[llength $descr] == 1} {
                        set description [[lindex $descr 0] data]
                        set lab [ttk::label $intframe.descr \
                                 -text $description]
                        pack $lab -fill x
                    }
                    set min [$n getElementsByTagName min -depth 1]
                    if {[llength $min] == 1} {
                        set min [[lindex $min 0] data]
                    } else {
                        set min $defmin
                    }
                    set max [$n getElementsByTagName max -depth 1]
                    if {[llength $max] == 1} {
                        set max [[lindex $max 0] data]
                    } else {
                        set max $defmax
                    }
                    set default [$n getElementsByTagName default -depth 1]
                    if {[llength $default] == 1} {
                        set default [[lindex $default 0] data]
                    } else {
                        set default 0
                    }
                    set widget $intframe.value
                    set map [$n getElementsByTagName map -depth 1]
                    $self putdebug "*** $self _processXMLnode (int branch): map = $map (length is [llength $map])"
                    if {[llength $map] == 1} {
                        set map [lindex $map 0]
                        upvar #0 ${widget}_VM valuemap
                        set values [list]
                        foreach rel [$map getElementsByTagName relation -depth 1] {
                            set prop [[lindex [$rel getElementsByTagName property -depth 1] 0] data]
                            set value [[lindex [$rel getElementsByTagName value -depth 1] 0] data]
                            set valuemap($value) $prop
                            if {$prop == $default} {
                                set default_value $value
                            }
                            lappend values $value
                        }
                        if {![info exists default_value]} {set default_value [lindex $values 0]}
                        $self putdebug "*** $self _processXMLnode (int branch): values = $values, default_value = $default_value"
                        ttk::combobox $widget -values $values -state readonly
                        $widget set $default_value
                        set readermethod _intComboRead
                        set writermethod _intComboWrite
                    } else {
                        spinbox $widget -from $min -to $max -increment 1
                        $widget set $default
                        set readermethod _intSpinRead
                        set writermethod _intSpinWrite
                    }
                    pack $widget -fill x
                    set readwrite [ButtonBox $intframe.readwrite \
                                   -orient horizontal]
                    pack $readwrite -expand yes -fill x
                    set rb [$readwrite add ttk::button read -text [_m "Label|Read"] \
                            -command [mymethod $readermethod $widget $space $address $size]]
                    lappend _readall($space) $rb
                    $readwrite add ttk::button write -text [_m "Label|Write"] \
                          -command [mymethod $writermethod $widget $space $address $size $min $max]
                    if {$options(-displayonly)} {
                        $readwrite configure -state disabled
                    }
                    incr address $size
                }
                string {
                    incr _stringnumber
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {$name ne {}} {
                        set stringframe [ttk::labelframe \
                                         $frame.string$_stringnumber \
                                         -labelanchor nw -text $name]
                    } else {
                        set stringframe [ttk::frame \
                                         $frame.string$_stringnumber]
                    }
                    pack $stringframe -fill x;# -expand yes
                    set descr [$n getElementsByTagName description -depth 1]
                    if {[llength $descr] == 1} {
                        set description [[lindex $descr 0] data]
                        set lab [ttk::label $stringframe.descr \
                                 -text $description]
                        pack $lab -fill x
                    }
                    set map [$n getElementsByTagName map -depth 1]
                    set widget $stringframe.value
                    if {[llength $map] == 1} {
                        set map [lindex $map 0]
                        upvar #0 ${widget}_VM valuemap
                        set values [list]
                        foreach rel [$map getElementsByTagName relation -depth 1] {
                            set prop [[lindex [$rel getElementsByTagName property -depth 1] 0] data]
                            set value [[lindex [$rel getElementsByTagName value -depth 1] 0] data]
                            set valuemap($value) $prop
                            lappend values $values
                        }
                        ttk::combobox $widget -values $values -state readonly
                        $widget set [lindex $values 0]
                        set readermethod _stringComboRead
                        set writermethod _stringComboWrite
                    } else {
                        ttk::entry $widget 
                        set readermethod _stringEntryRead
                        set writermethod _stringEntryWrite
                    }
                    pack $widget -fill x
                    set readwrite [ButtonBox $stringframe.readwrite \
                                   -orient horizontal]
                    pack $readwrite -expand yes -fill x
                    set rb [$readwrite add ttk::button read -text [_m "Label|Read"] \
                            -command [mymethod $readermethod $widget $space $address $size]]
                    lappend _readall($space) $rb
                    $readwrite add ttk::button write -text [_m "Label|Write"] \
                          -command [mymethod $writermethod $widget $space $address $size]
                    if {$options(-displayonly)} {
                        $readwrite configure -state disabled
                    }
                    incr address $size
                }
                eventid {
                    incr _eventidnumber
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size 8
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {$name ne {}} {
                        set eventidframe [ttk::labelframe \
                                          $frame.eventid$_eventidnumber \
                                          -labelanchor nw -text $name]
                    } else {
                        set eventidframe [ttk::frame \
                                          $frame.eventid$_eventidnumber]
                    }
                    pack $eventidframe -fill x;# -expand yes
                    set descr [$n getElementsByTagName description -depth 1]
                    if {[llength $descr] == 1} {
                        set description [[lindex $descr 0] data]
                        set lab [ttk::label $eventidframe.descr \
                                 -text $description]
                        pack $lab -fill x
                    }
                    set map [$n getElementsByTagName map -depth 1]
                    set widget $eventidframe.value
                    if {[llength $map] == 1} {
                        set map [lindex $map 0]
                        upvar #0 ${widget}_VM valuemap
                        set values [list]
                        foreach rel [$map getElementsByTagName relation -depth 1] {
                            set prop [[lindex [$rel getElementsByTagName property -depth 1] 0] data]
                            set value [[lindex [$rel getElementsByTagName value -depth 1] 0] data]
                            set valuemap($value) $prop
                            lappend values $value
                        }
                        ttk::combobox $widget -values $values -state readonly
                        $widget set [lindex $values 0]
                        set readermethod _eventidComboRead
                        set writermethod _eventidComboWrite
                    } else {
                        ttk::entry $widget
                        $widget insert end {00.00.00.00.00.00.00.00}
                        set readermethod _eventidEntryRead
                        set writermethod _eventidEntryWrite
                    }
                    pack $widget -fill x
                    set readwrite [ButtonBox $eventidframe.readwrite \
                                   -orient horizontal]
                    pack $readwrite -expand yes -fill x
                    set rb [$readwrite add ttk::button read -text [_m "Label|Read"] \
                            -command [mymethod $readermethod $widget $space $address $size]]
                    lappend _readall($space) $rb
                    $readwrite add ttk::button write -text [_m "Label|Write"] \
                          -command [mymethod $writermethod $widget $space $address $size]
                    if {$options(-displayonly)} {
                        $readwrite configure -state disabled
                    }
                    incr address $size
                }
            }
            #update idle
        }
        method _close {} {
            ## @brief Close the window. 
            # The window is withdrawn.
            wm withdraw $win
        }
        variable olddatagramhandler {}
        variable datagrambuffer {}
        variable _datagramrejecterror 0
        variable writeReplyCheck no
        method _datagramhandler {command sourcenid args} {
            set data $args
            switch $command {
                datagramcontent {
                    if {$sourcenid ne [$self cget -nid]} {
                        if {$olddatagramhandler eq {}} {
                            [$self cget -transport] DatagramRejected $sourcenid 0x1000
                        } else {
                            uplevel #0 $olddatagramhandler $command $sourcenid $data
                        }
                    }
                    [$self cget -transport] DatagramReceivedOK $sourcenid
                    set datagrambuffer $data
                    incr _ioComplete
                }
                datagramreceivedok {
                    if {$sourcenid ne [$self cget -nid]} {
                        if {$olddatagramhandler ne {}} {
                            uplevel #0 $olddatagramhandler $command $sourcenid $data
                        }
                    } else {
                        if {!$writeReplyCheck} {return}
                        if {[llength $data] == 1} {
                            set flags [lindex $data 0]
                        } else {
                            set flags 0
                        }
                        if {($flags & 0x80) == 0} {
                            incr _ioComplete;# no WriteReply pending -- write is presumed to be OK
                        }
                    }
                }
                datagramrejected {
                    if {$sourcenid ne [$self cget -nid]} {
                        if {$olddatagramhandler ne {}} {
                            uplevel #0 $olddatagramhandler $command $sourcenid $data
                        }
                    } else {
                        # datagram rejected
                        set _datagramrejecterror [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                        incr _ioComplete -1 ;# no further messages expected
                    }
                }
            }
        }
        method _readmemory {space address length status_var} {
            lcc::byte validate $space
            lcc::sixteenbits validate $address
            lcc::length validate $length
            upvar $status_var status
            
            set data [list 0x20]
            set spacein6 no
            if {$space == 0xFD} {
                lappend data 0x41
            } elseif {$space == 0xFE} {
                lappend data 0x42
            } elseif {$space == 0xFF} {
                lappend data 0x43
            } else {
                lappend data 0x40
                set spacein6 yes
            }
            lappend data [expr {($address & 0xFF000000) >> 24}]
            lappend data [expr {($address & 0x00FF0000) >> 16}]
            lappend data [expr {($address & 0x0000FF00) >>  8}]
            lappend data [expr {($address & 0x000000FF) >>  0}]
            if {$spacein6} {lappend data $space}
            lappend data $length
            set _ioComplete 0
            set writeReplyCheck no
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] SendDatagram [$self cget -nid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            if {$_ioComplete < 0} {
                ## datagram rejected message received
                # code in_datagramrejecterror
                return {}
            }
            set status [lindex $datagrambuffer 1]
            set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
            set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
            if {$respaddr != $address} {
                ## wrong address...
            }
            if {$status == 0x50 || $status == 0x58} {
                set respspace [lindex $datagrambuffer 6]
                set dataoffset 7
            } else {
                set dataoffset 6
                if {$status == 0x51 || $status == 0x59} {
                    set respspace 0xFD
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x52  || $status == 0x5A} {
                    set respspace 0xFE
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x53  || $status == 0x5B} {
                    set respspace 0xFF
                    set status [expr {$status & 0xF8}]
                }
            }
            if {$respspace != $space} {
                ## wrong space ...
            }
            set data [lrange $datagrambuffer $dataoffset end]
            if {$status == 0x50} {
                if {[llength $data] > $length} {
                    set data [lrange $data 0 [expr {$length - 1}]]
                }
                return $data
            } else {
                return 
            }
        }
        method _writememory {space address databuffer} {
            lcc::byte validate $space
            lcc::sixteenbits validate $address
            lcc::databuf validate $databuffer

            set data [list 0x20]
            set spacein6 no
            if {$space == 0xFD} {
                lappend data 0x01
            } elseif {$space == 0xFE} {
                lappend data 0x02
            } elseif {$space == 0xFF} {
                lappend data 0x03
            } else {
                lappend data 0x00
                set spacein6 yes
            }
            lappend data [expr {($address & 0xFF000000) >> 24}]
            lappend data [expr {($address & 0x00FF0000) >> 16}]
            lappend data [expr {($address & 0x0000FF00) >>  8}]
            lappend data [expr {($address & 0x000000FF) >>  0}]
            if {$spacein6} {lappend data $space}
            foreach b $databuffer {lappend data $b}
            set datagrambuffer {}
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] SendDatagram [$self cget -nid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            if {$_ioComplete < 0} {
                ## datagram rejected message received
                # code in _datagramrejecterror
                return $_datagramrejecterror
            } elseif {$datagrambuffer eq {}} {
                ## No write reply -- assume the write succeeded
                return 0
            }
            set status [lindex $datagrambuffer 1]
            set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
            set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
            if {$respaddr != $address} {
                ## wrong address...
            }
            if {$status == 0x10 || $status == 0x18} {
                set respspace [lindex $datagrambuffer 6]
                set dataoffset 7
            } else {
                set dataoffset 6
                if {$status == 0x11 || $status == 0x19} {
                    set respspace 0xFD
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x12  || $status == 0x1A} {
                    set respspace 0xFE
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x13  || $status == 0x1B} {
                    set respspace 0xFF
                    set status [expr {$status & 0xF8}]
                }
            }
            if {$respspace != $space} {
                ## wrong space ...
            }
            return [lrange $datagrambuffer $dataoffset end]
        }
        method _intComboRead {widget space address size} {
            upvar #0 ${widget}_VM valuemap
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK
                set value 0
                foreach b $data {
                    set value [expr {($value << 8) | $b}]
                }
                foreach v [array names valuemap] {
                    if {$valuemap($v) == $value} {
                        $widget set $v
                        return
                    }
                }
            } elseif {$status == 0x58} {
                # Failure
                set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
            }
        }
        method _intComboWrite {widget space address size min max} {
            upvar #0 ${widget}_VM valuemap
            set value $valuemap([$widget get])
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] == 1} {
                if {$retdata == 0} {
                    ## OK
                    return
                } else {
                    set errorcode $retdata
                    set errormessage {}
                }
            } else {
                set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
            }
            tk_messageBox -type ok -icon error \
                  -message [_ "There was an error: %d (%s)" \
                            $errorcode $errormessage]
        }
        method _intSpinRead {widget space address size} {
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK
                if {[llength $data] > $size} {
                    set data [lrange $data 0 [expr {$size - 1}]]
                }
                set value 0
                foreach b $data {
                    set value [expr {($value << 8) | $b}]
                }
                $widget set $value
            } elseif {$status == 0x58} {
                # Failure
                set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
                
            }
        }
        method _intSpinWrite {widget space address size min max} {
            set value [$widget get]
            if {$value < $min || $value > $max} {
                ## out of range.
                return
            }
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] == 1} {
                if {$retdata == 0} {
                    ## OK
                    return
                } else {
                    set errorcode $retdata
                    set errormessage {}
                }
            } else {
                set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
            }
            tk_messageBox -type ok -icon error \
                  -message [_ "There was an error: %d (%s)" \
                            $errorcode $errormessage]
        }
        method _stringComboRead {widget space address size} {
            upvar #0 ${widget}_VM valuemap
            set resultstring {}
            for {set off 0} {$off < $size} {incr off 64} {
                set remain [expr {$size - $off}]
                if {$remain > 64} {set remain 64}
                set a [expr {$address + $off}]
                set data [$self _readmemory $space $a $remain status]
                if {$status == 0x50} {
                    # OK
                    if {[llength $data] > $remain} {
                        set data [lrange $data 0 [expr {$remain - 1}]]
                    }
                    foreach b $data {
                        if {$b == 0} {break}
                        append resultstring [format %c $b]
                    }
                } elseif {$status == 0x58} {
                    # Failure
                    set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                    set errormessage {}
                    foreach c [lrange $data 2 end] {
                        if {$c == 0} {break}
                        append errormessage [format %c $c]
                    }
                    break
                }
            }
            foreach v [array names valuemap] {
                if {$valuemap($v) eq $resultstring} {
                    $widget set $v
                }
            }
        }
        method _stringComboWrite {widget space address size} {
            upvar #0 ${widget}_VM valuemap
            set value $valuemap([$widget get])
            set fulldata [list]
            foreach c [split $value {}] {
                lappend fulldata [scan $c %c]
            }
            lappend fulldata 0
            while {[llength $fulldata] < $size} {
                lappend fulldata 0
            }
            if {[llength $fulldata] > $size} {
                set fulldata [lrange $fulldata 0 [expr {$size - 2}]]
                lappend fulldata 0
            }
            for {set off 0} {$off < $size} {incr off 64} {
                set remain [expr {$size - $off}]
                if {$remain > 64} {set remain 64}
                set a [expr {$address + $off}]
                set retdata [$self _writememory $space $a [lrange $fulldata $off [expr {($off + $remain) - 1}]]]
                if {[llength $retdata] == 1} {
                    if {$retdata == 0} {
                        ## OK
                        continue
                    } else {
                        set errorcode $retdata
                        set errormessage {}
                    }
                } else {
                    set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                    set errormessage {}
                    foreach c [lrange $data 2 end] {
                        if {$c == 0} {break}
                        append errormessage [format %c $c]
                    }
                }
                tk_messageBox -type ok -icon error \
                      -message [_ "There was an error: %d (%s)" \
                                $errorcode $errormessage]
            }
        }
        method _stringEntryRead {widget space address size} {
            set resultstring {}
            for {set off 0} {$off < $size} {incr off 64} {
                set remain [expr {$size - $off}]
                if {$remain > 64} {set remain 64}
                set a [expr {$address + $off}]
                set data [$self _readmemory $space $a $remain status]
                if {$status == 0x50} {
                    # OK
                    if {[llength $data] > $remain} {
                        set data [lrange $data 0 [expr {$remain - 1}]]
                    }
                    foreach b $data {
                        if {$b == 0} {break}
                        append resultstring [format %c $b]
                    }
                } elseif {$status == 0x58} {
                    # Failure
                    set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                    set errormessage {}
                    foreach c [lrange $data 2 end] {
                        if {$c == 0} {break}
                        append errormessage [format %c $c]
                    }
                    break
                }
            }
            $widget delete 0 end
            $widget insert end $resultstring
        }
        method _stringEntryWrite {widget space address size} {
            set value [$widget get]
            set fulldata [list]
            foreach c [split $value {}] {
                lappend fulldata [scan $c %c]
            }
            lappend fulldata 0
            while {[llength $fulldata] < $size} {
                lappend fulldata 0
            }
            if {[llength $fulldata] > $size} {
                set fulldata [lrange $fulldata 0 [expr {$size - 2}]]
                lappend fulldata 0
            }
            for {set off 0} {$off < $size} {incr off 64} {
                set remain [expr {$size - $off}]
                if {$remain > 64} {set remain 64}
                set a [expr {$address + $off}]
                set retdata [$self _writememory $space $a [lrange $fulldata $off [expr {($off + $remain) - 1}]]]
                if {[llength $retdata] == 1} {
                    if {$retdata == 0} {
                        ## OK
                        continue
                    } else {
                        set errorcode $retdata
                        set errormessage {}
                    }
                } else {
                    set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                    set errormessage {}
                    foreach c [lrange $data 2 end] {
                        if {$c == 0} {break}
                        append errormessage [format %c $c]
                    }
                }
                tk_messageBox -type ok -icon error \
                      -message [_ "There was an error: %d (%s)" \
                                $errorcode $errormessage]
            }
        }
        method _eventidComboRead {widget space address size} {
            upvar #0 ${widget}_VM valuemap
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK
                if {[llength $data] > $size} {
                    set data [lrange $data 0 [expr {$size - 1}]]
                }
                set evid [lcc::EventID %AUTO% -eventidlist $data]
                set value [$evid cget -eventidstring]
                foreach v [array names valuemap] {
                    if {$valuemap($v) == $value} {
                        $widget set $v
                        return
                    }
                }
            } elseif {$status == 0x58} {
                # Failure
                set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
                
            }
        }
        method _eventidComboWrite {widget space address size} {
            upvar #0 ${widget}_VM valuemap
            set evid [lcc::EventID %AUTO% -eventidstring $valuemap([$widget get])]
            set data [$evid cget -eventidlist]
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] == 1} {
                if {$retdata == 0} {
                    ## OK
                    return
                } else {
                    set errorcode $retdata
                    set errormessage {}
                }
            } else {
                set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
            }
            tk_messageBox -type ok -icon error \
                  -message [_ "There was an error: %d (%s)" \
                            $errorcode $errormessage]
        }
        method _eventidEntryRead {widget space address size} {
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK
                if {[llength $data] > $size} {
                    set data [lrange $data 0 [expr {$size - 1}]]
                }
                set evid [lcc::EventID %AUTO% -eventidlist $data]
                set value [$evid cget -eventidstring]
                $widget delete 0 end
                $widget insert end $value
            } elseif {$status == 0x58} {
                # Failure
                set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
                
            }
        }
        method _eventidEntryWrite {widget space address size} {
            set evid [lcc::EventID %AUTO% -eventidstring [$widget get]]
            set data [$evid cget -eventidlist]
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] == 1} {
                if {$retdata == 0} {
                    ## OK
                    return
                } else {
                    set errorcode $retdata
                    set errormessage {}
                }
            } else {
                set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
            }
            tk_messageBox -type ok -icon error \
                  -message [_ "There was an error: %d (%s)" \
                            $errorcode $errormessage]
        }
        method _readall {space} {
            if {![catch {set _readall($space)} rbs]} {
                foreach rb $rbs {
                    $rb invoke
                }
            }
        }
    }
}

package provide ConfigurationEditor 1.0

