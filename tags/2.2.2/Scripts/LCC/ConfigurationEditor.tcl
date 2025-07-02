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
#  Last Modified : <250110.1407>
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
package require pdf4tcl
package require struct::matrix
package require csv
package require LayoutControlDB
package require LayoutControlDBDialogs
package require Dialog

namespace eval lcc {
    ## 
    # @section ConfigurationEditor Package provided
    #
    # ConfigurationEditor 1.0
    
    snit::widgetadaptor ReadallProgress {
        delegate option -parent to hull
        
        component spaceLE
        component itemsE
        variable itemsRead
        component progress
        
        delegate option -totalitems to progress as -maximum
        option -space -type snit::integer -default 0
        
        constructor {args} {
            installhull using Dialog -bitmap questhead -default dismis \
                  -modal none -transient yes \
                  -side bottom -title [_ "Reading Configuration"] \
                  -parent [from args -parent]
            $hull add dismis -text [_m "Button|Dismiss"] \
                  -state disabled -command [mymethod _Dismis]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Dismis]
            set frame [$hull getframe]
            install spaceLE using LabelEntry $frame.spaceLE \
                  -label [_m "Label|Space:"] \
                  -text  {} -state readonly
            pack $spaceLE -fill x
            install itemsE using ttk::entry $frame.itemsE \
                  -textvariable [myvar itemsRead] \
                  -state readonly
            pack $itemsE -expand yes -fill x
            install progress using ttk::progressbar $frame.progress \
                  -orient horizontal -mode determinate -length 256
            pack $progress -expand yes -fill x
            $self configurelist $args
        }
        method draw {args} {
            #puts stderr "*** $self draw $args"
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            $hull itemconfigure dismis -state disabled
            $spaceLE configure -text [format "0x%02X" [$self cget -space]]
            update idle
            return [$hull draw]
        }
        method withdraw {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
        method _Dismis {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
        method Update {itemsread} {
            #puts stderr "*** $self Update $itemsread"
            set itemsRead [_ "%d items read of %d" $itemsread \
                           [$progress cget -maximum]]
            $progress configure -value $itemsread
            update idle
        }
        method Done {} {
            #puts stderr "*** $self Done"
            $hull itemconfigure dismis -state normal
            update idle
        }
    }
        
    snit::type EventUseTable {
        pragma -hastypeinfo    no
        pragma -hastypedestroy no
        pragma -hasinstances   no
        
        typevariable _table -array {}
        
        typemethod AddEventUse {eventid widget} {
            #puts stderr "*** $type AddEventUse $eventid $widget"
            if {[info exists _table($eventid)]} {
                foreach _widget $_table($eventid) {
                    if {$widget eq $_widget} {
                        return
                    }
                }
            }
            lappend _table($eventid) $widget
        }
        typemethod DeleteEventUse {eventid widget} {
            #puts stderr "*** $type DeleteEventUse $eventid $widget"
            if {[info exists _table($eventid)]} {
                set uses $_table($eventid)
                set index -1
                foreach _widget $uses {
                    incr index
                    if {$widget eq $_widget} {
                        set _table($eventid) [lreplace $uses $index $index]
                        return
                    }
                }
            }
        }
        typemethod GetEventUsesRaw {eventid} {
            #puts stderr "*** $type GetEventUsesRaw $eventid"
            if {[info exists _table($eventid)]} {
                return $_table($eventid)
            } else {
                return {}
            }
        }
        proc tails_ {wlist} {
            set result [list]
            foreach w $wlist {
                lappend result [lindex [split $w {.}] end]
            }
            return $result
        }
        typemethod GetEventUsesFormatted {eventid} {
            set result [list]
            if {[info exists _table($eventid)]} {
                foreach widget $_table($eventid) {
                    set eventframe [winfo parent $widget]
                    puts stderr "*** $type GetEventUsesFormatted: eventframe children are [tails_ [winfo children $eventframe]]"
                    if {[winfo exists $eventframe.descr]} {
                        set eventLabel [$eventframe.descr cget -text]
                    } else {
                        set eventLabel [$eventframe cget -text]
                    }
                    #puts stderr "*** $type GetEventUsesFormatted: eventLabel is '$eventLabel'"
                    set p [winfo parent $eventframe]
                    set foundName no
                    set name {}
                    while {!$foundName && [winfo parent $p] ne {}} {
                        if {[winfo class $p] eq {TFrame}} {
                            foreach c [winfo children $p] {
                                if {[string first string [winfo name $c]] == 0} {
                                    set name [$c.value get]
                                    set foundName yes
                                    break
                                }
                            }
                        }
                        set p [winfo parent $p]
                    }
                    set nodename {}
                    set nid [[winfo toplevel $widget] cget -nid]
                    #puts stderr "*** $type GetEventUsesFormatted: foundName is $foundName, name is '$name'"
                    set segments [winfo toplevel $widget].main.frame.scroll.editframe.uframe.segments
                    set nodenameFound no
                    foreach c [winfo children $segments] {
                        if {[winfo exists $c.readall]} {
                            set cmd [$c.readall cget -command]
                            #puts stderr "*** $type GetEventUsesFormatted: cmd is \{$cmd\}"
                            if {[lindex $cmd end] == 251} {
                                if {[winfo exists $c.groups]} {
                                    foreach c [winfo children $c.groups] {
                                        #_walkChildren $c
                                        foreach gc [winfo children $c] {
                                            #_walkChildren $gc
                                            if {[winfo class $gc] eq {TLabelframe}} {
                                                set label [$gc cget -text]
                                                #puts stderr "*** $type GetEventUsesFormatted: label is {$label}"
                                                if {[string match -nocase *name $label]} {
                                                    set nodename [$gc.value get]
                                                    set nodenameFound yes
                                                    break
                                                }
                                            }
                                        }
                                        if {$nodenameFound} {break}
                                    }
                                }
                            }
                        }
                        if {$nodenameFound} {break}
                        
                    }
                    lappend result \
                          [format {%s: %s of %s (%s)} $name $eventLabel  $nodename $nid]
                }
            }
            return $result
        }
        proc _walkChildren {w} {
            puts stderr "*** _walkChildren: children of $w:"
            foreach c [winfo children $w] {
                puts stderr "*** _walkChildren: $c is a [winfo class $c]"
                if {[winfo class $c] eq {TEntry}} {
                    puts stderr "*** _walkChildren: $c contains [$c get]"
                }
                if {[winfo class $c] eq {TLabelframe}} {
                    puts stderr "*** _walkChildren: $c's label is [$c cget -text]"
                }
                #_walkChildren $c
            }
        }
    }   
    snit::widget EventSearch {
        typevariable AllSearchAbleEvents -array {}
        typevariable AllEventSearchWidgets [list]
        proc _search {pattern} {
            return [array names AllSearchAbleEvents -glob "*$pattern*"]
        }
        option -eventwidget -readonly yes -type snit::window
        component searchEntry
        variable _searchval {}
        variable _searchText {}
        component searchResults
        component searchResultsList
        constructor {args} {
            set b [ttk::button $win.search -text [_m "Label|Search"] \
                   -command [mymethod _toggleSearchEntry]]
            pack $b -side left
            install searchEntry using ttk::entry $win.searchEntry \
                  -textvariable [myvar _searchval]
            bind $searchEntry <Key> [mymethod _doSearch]
            $self configurelist $args
            $self _recomputeSearchText
            lappend AllEventSearchWidgets $win
            install searchResults using toplevel $win.searchResults
            wm withdraw $searchResults
            wm overrideredirect $searchResults yes
            set searchResultsSW [ScrolledWindow \
                                 $searchResults.scroll \
                                 -scrollbar vertical -auto vertical]
            pack $searchResultsSW -expand yes -fill both
            install searchResultsList using listbox \
                  [$searchResultsSW getframe].searchResultsList \
                  -selectmode single
            $searchResultsSW setwidget $searchResultsList
            bind $searchResultsList <<ListboxSelect>> [mymethod _listSelected]
        }
        method _recomputeSearchText {} {
            catch {unset AllSearchAbleEvents($_searchText)}
            set ew $options(-eventwidget)
            set eventframe [winfo parent $ew]
            if {[winfo exists $eventframe.descr]} {
                set _searchText "[$eventframe.descr cget -text]"
            }
            if {![catch {$eventframe cget -text} name]} {
                set _searchText "$name.$_searchText"
            }
            set gframe [winfo parent $eventframe]
            set _searchText [_walkUpTree $gframe $_searchText]
            set AllSearchAbleEvents($_searchText) $ew
        }
        typemethod RecomputeAllSearchTexts {} {
            foreach sw $AllEventSearchWidgets {
                $sw _recomputeSearchText
            }
        }
        proc _walkUpTree {gframe searchText} {
            #puts stderr "*** _walkUpTree $gframe \"$searchText\""
            if {[regexp {\.replication([[:digit:]]+)$} $gframe => i] > 0} {
                set replframe $gframe
                set replnotebook [winfo parent $replframe]
                set tabname [$replnotebook tab $replframe -text]
                set searchText "$tabname.$searchText"
                set groupframe [winfo parent $replnotebook]
            } else {
                set groupframe $gframe
            }
            set parent [winfo parent $groupframe]
            while {$gframe ne $parent} {
                #puts stderr "*** _walkUpTree: gframe is $gframe"
                foreach f [winfo children $gframe] {
                    if {[regexp {\.string[[:digit:]]+$} $f] > 0} {
                        #puts stderr "*** _walkUpTree: f = $f"
                        catch {
                            #catch {$f cget -text} name
                            #puts stderr "*** _walkUpTree: name is $name"
                            set text [$f.value get]
                            if {$text ne ""} {set searchText "($text).$searchText"}
                        } message
                        #puts stderr "*** _walkUpTree: message is $message"
                        break
                    }
                }
                set gframe [winfo parent $gframe]
                    
            }
            if {[winfo class $parent] eq "TNotebook"} {
                set notebook $parent
                set tabname [$notebook tab $groupframe -text]
                set searchText "$tabname.$searchText"
                set parent [winfo parent $notebook]
            }
            if {[winfo toplevel $parent] eq $parent} {
                return $searchText
            } else {
                return [_walkUpTree $parent $searchText]
            }
        }
        method _doSearch {} {
            wm withdraw $searchResults
            set results [_search $_searchval]
            #puts stderr "*** $self _doSearch \{$results\}"
            set w 0
            $searchResultsList delete 0 end
            foreach r $results {
                $searchResultsList insert end $r
                set wr [string length $r]
                if {$wr > $w} {set w $wr}
            }
            $searchResultsList configure -width $w
            update idle
            set width [winfo reqwidth $searchResults]
            set X [winfo rootx $searchEntry]
            set Y [expr {[winfo rooty $searchEntry] + [winfo reqheight $searchEntry]}]
            set maxX [expr {[winfo screenwidth $searchResults] - $width}]
            if {$X > $maxX} {set X $maxX}
            set height [winfo reqheight $searchResults]
            set maxY [expr {[winfo screenheight $searchResults] - $height}]
            if {$Y > $maxY} {
                set height [expr {[winfo screenheight $searchResults] - $Y}]
            }
            wm geometry  $searchResults [format {=%dx%d+%d+%d} $width $height $X $Y]
            wm deiconify $searchResults
            focus $searchEntry
        }
        method _listSelected {} {
            set itemIndex [$searchResultsList curselection]
            wm withdraw $searchResults
            if {$itemIndex eq {}} {return}
            set item [$searchResultsList get $itemIndex]
            set otherwidget $AllSearchAbleEvents($item)
            set otherevent [$otherwidget get]
            set widget $options(-eventwidget)
            $widget delete 0 end
            $widget insert end $otherevent
        }
        method _toggleSearchEntry {} {
            if {$searchEntry in [pack slaves $win]} {
                pack forget $searchEntry
                wm withdraw $searchResults
            } else {
                pack $searchEntry -side left -expand yes -fill x
            }
        }
    }
            
            
            
            
    snit::widget ConfigurationEditor {
        ## @brief Generate OpenLCB Memory Configuration Window.
        # Create a toplevel to configure a node's Memory using that
        # node's (parsed) CDI.  This GUI uses tabbed notebook
        # widgets for segments and replicated groups to reduce the amount
        # of scrolling (and because a ginormous scrollable frame dies with
        # a X11 Pixmap allocation error).
        #
        # @param Options:
        # @arg -cdi The unparsed CDI xml. Required and there is no default.
        # @arg -nid The Node ID of the node to be configured.  Required 
        #             and there is no default.
        # @arg -transport The transport object.  Needs to implement 
        # @c SendDatagram, @c DatagramReceivedOK, and @c DatagramRejected
        # methods and have an @c -datagramhandler option.
        # @arg -displayonly A flag indicating that the CDI is just to be
        # displayed.  The default is false.
        # @arg -offlineedit A flag indicating that the this is an offline 
        # editor. The default is false.
        # @arg -loadfile The backup config filename to load from. Only checked
        # if -offlineedit is true.  Default is an empty string.
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
        variable widgetMap_ -array {}
        component buttons
        ## Button box
        
        
        component readallProgressDialog
        component newTurnout
        component newBlock
        component newSensor
        component newControl
        component layoutcontrolsLF
        component   layoutcontrolsNB
        component     addturnoutW
        component     addblockW
        component     addsignalW
        component     addsensorW
        component     addcontrolW
        
        typecomponent event_also_used
        delegate typemethod AddEventUse to event_also_used
        delegate typemethod DeleteEventUse to event_also_used
        delegate typemethod GetEventUsesRaw to event_also_used
        delegate typemethod GetEventUsesFormatted to event_also_used
        
        option -cdi -readonly yes
        option -layoutdb -default {} -configuremethod _updateLayoutDB
        method _updateLayoutDB {o v} {
            if {$addturnoutW ne ""} {$addturnoutW configure -db $v}
            if {$addblockW ne ""} {$addblockW configure -db $v}
            if {$addsignalW ne ""} {$addsignalW configure -db $v}
            if {$addsensorW ne ""} {$addsensorW configure -db $v}
            if {$addcontrolW ne ""} {$addcontrolW configure -db $v}
            #puts stderr "*** $self _updateLayoutDB $o $v"
            set options($o) $v
        }
        option -nid -readonly yes -type lcc::nid -default "05:01:01:01:22:00"
        option -transport -readonly yes -default {}
        option -displayonly -readonly yes -type snit::boolean -default false
        option -offlineedit -readonly yes -type snit::boolean -default false
        option -loadfile -readonly yes -default {}
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
        variable statusline
        ## Status variable.
        
        typecomponent editContextMenu
        
        typevariable _menu {
            "[_m {Menu|&File}]" {file:menu} {file} 0 {
                {command "[_m {Menu|File|&Close}]" {file:close} "[_ {Close the editor}]" {Ctrl c} -command "[mymethod _close]"}
            } "[_m {Menu|&Edit}]" {edit} {edit} 0 {
                {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut} -state disabled}
                {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy} -state disabled}
                {command "[_m {Menu|Edit|&Paste}]" {edit:paste} "[_ {Paste selection from the paste buffer}]" {Ctrl c} -command {StdMenuBar EditPaste}}
                {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear} -state disabled}
                {command "[_m {Menu|Edit|&Delete}]" {edit:delete edit:havesel} "[_ {Delete selection}]" {Ctrl d}  -command {StdMenuBar EditClear} -state disabled}
                {separator}
                {command "[_m {Menu|Edit|Select All}]" {edit:selectall} "[_ {Select everything}]" {} -command {StdMenuBar EditSelectAll}}
                {command "[_m {Menu|Edit|De-select All}]" {edit:deselectall edit:havesel} "[_ {Select nothing}]" {} -command {StdMenuBar EditSelectNone} -state disabled}
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
        variable parsedCDI {}
        destructor {
            $parsedCDI destroy
        }
        constructor {args} {
            ## @publicsection @brief Constructor: create the configuration editor.
            # Construct a memory configuration window to edit the configuration
            # memory of an OpenLCB node.  The window is created from the 
            # toplevel up.
            #
            # @param name Widget path.
            # @param ... Options:
            # @arg -cdi The unparsed CDI xml. Required and there is no default.
            # @arg -nid The Node ID of the node to be configured.  Required 
            #             and there is no default.
            # @arg -transport The transport object.  Needs to implement 
            # @c SendDatagram, @c DatagramReceivedOK, and @c DatagramRejected
            # methods and have an @c -datagramhandler option.
            # @arg -displayonly A flag indicating that the CDI is just to be
            # displayed.  The default is false.
            # @arg -offlineedit A flag indicating that the this is an offline 
            # editor. The default is false.
            # @arg -loadfile The backup config filename to load from. Only checked
            # if -offlineedit is true.  Default is an empty string.
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
            set options(-offlineedit) [from args -offlineedit]
            if {!$options(-displayonly) && !$options(-offlineedit)} {
                if {[lsearch $args -nid] < 0} {
                    error [_ "The -nid option is required!"]
                }
                if {[lsearch $args -transport] < 0} {
                    error [_ "The -transport option is required!"]
                }
            }
            set options(-cdi) [from args -cdi]
            if {[catch {ParseXML %AUTO% $options(-cdi)} parsedCDI]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not parse the CDI (1) because %s" $parsedCDI]
                return
            }
            set cdis [$parsedCDI getElementsByTagName cdi -depth 1]
            if {[llength $cdis] != 1} {
                error [_ "There is no CDI container in %s" $parsedCDI]
            }
            set cdi [lindex $cdis 0]
            $self putdebug "*** $type create $self: win = $win, about to wm protocol $win WM_DELETE_WINDOW ..."
            wm protocol $win WM_DELETE_WINDOW [mymethod _close]
            install main using MainFrame $win.main -menu [subst $_menu] \
                  -textvariable [myvar statusline]
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
            [$main getmenu edit] configure -postcommand [mymethod edit_checksel]
            if {$options(-offlineedit)} {
                [$main getmenu file] insert 0 command -command [mymethod _saveas] -label [_m "Menu|File|Save As..."]
            }
            $self putdebug "*** $type create $self: configured -postcommand to edit menu"
            $self putdebug "*** $type create $self: initialized Layout Control DB"
            $self _processXMLnode $cdi [$editframe getframe] -1 address
            $self putdebug "*** $type create $self: processed CDI"
            install buttons using ButtonBox $f.buttons \
                  -buttonalignment left -orient horizontal
            pack $buttons -fill x
            $buttons add ttk::button save \
                  -text [_m "Label|Save Changed"] \
                  -command [mymethod _saveChanged]
            $buttons add ttk::button reread \
                  -text [_m "Label|Reread All"] \
                  -command [mymethod _rereadAll]
            $buttons add ttk::button backup \
                  -text [_m "Label|Backup..."] \
                  -command [mymethod _backup]
            $buttons add ttk::button restore \
                  -text [_m "Label|Restore..."] \
                  -command [mymethod _restore]
            $buttons add ttk::button reboot \
                  -text [_m "Label|Reboot and close"] \
                  -command [mymethod _rebootAndClose]
            $buttons add ttk::button showhideLC \
                  -text [_m "Label|Hide Layout Controls"] \
                  -command [mymethod _showhideLC]
            if {$options(-offlineedit)} {
                $buttons itemconfigure save -state disabled
                $buttons itemconfigure reread -state disabled
                $buttons itemconfigure backup -state disabled
                $buttons itemconfigure restore -state disabled
                $buttons itemconfigure reboot -state disabled
            }
            $self _layoutControlsCreation $f
            install readallProgressDialog using \
                  lcc::ReadallProgress $win.readallProgressDialog \
                  -parent $win
            install newTurnout using \
                  lcc::NewTurnoutDialog $win.newTurnout -parent $win -nameonly yes
            install newBlock using \
                  lcc::NewBlockDialog $win.newBlock -parent $win -nameonly yes
            install newSensor using \
                  lcc::NewSensorDialog $win.newSensor -parent $win -nameonly yes
            install newControl using \
                  lcc::NewControlDialog $win.newControl -parent $win -nameonly yes
            $self putdebug "*** $type create $self: _readall names: [array names _readall]"
            if {!$options(-displayonly) && !$options(-offlineedit)} {
                foreach s [array names _readall] {
                    $self _readall $s
                }
                EventSearch RecomputeAllSearchTexts
                $self putdebug "*** $type create $self: _readall completed"
            }
            if {$options(-offlineedit) && $options(-loadfile) ne ""} {
                $self _loadfile $options(-loadfile)
                EventSearch RecomputeAllSearchTexts
            } elseif {$options(-offlineedit) && $options(-loadfile) eq ""} {
                $self _initblank
                EventSearch RecomputeAllSearchTexts
            }
            
        }
        method _loadfile {filename} {
            if {[catch {open $filename r} fp]} {
                tk_messageBox -default ok \
                      -detail $fp \
                      -icon error \
                      -message [_ "Could not open %s" $filename] \
                      -parent [winfo toplevel $win] \
                      -title "Open file error" \
                      -type ok
                return
            }
            wm title $win [_ "CDI Configuration Tool for config file %s" $filename]
            set _segmentnumber 0
            $self _loadNode \
                  [lindex [$parsedCDI getElementsByTagName cdi -depth 1] 0] \
                  $fp 
            close $fp
        }
        method _loadNode {n fp {prefix {}}} {
            
            #puts "*** $self _loadNode [$n cget -tag] $fp $prefix"
            switch [$n cget -tag] {
                cdi {
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        $self _loadNode $seg $fp $prefix
                    }
                }
                identification -
                acdi {
                }
                segment {
                    incr _segmentnumber
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name [format "seg%d" $_segmentnumber]
                    }
                    set prefix $name
                    #$self putdebug "*** $self _loadNode (segment) [llength [$n children]] tag children"
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        if {[$self _loadNode $c $fp $prefix] < 0} {return -1}
                    }
                    return 1
                }
                group {
                    set replication [$n attribute replication]
                    if {$replication eq {}} {set replication 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set repnamefmt [format ".%s(%%d)" $name]
                    if {$replication > 1} {
                        for {set i 0} {$i < $replication} {incr i} {
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name repname description hints} $tag] >= 0} {continue}
                                if {[$self _loadNode $c $fp "${prefix}[format $repnamefmt $i]"] < 0} {return -1}
                            }
                        }
                    } else {
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name repname description hints} $tag] >= 0} {continue}
                            if {[$self _loadNode $c $fp "${prefix}.$name"] < 0} {return -1}
                        }
                    }
                    return 1
                }
                int {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {[gets $fp line] < 0} {
                        tk_messageBox -icon error \
                              -message [_ "Short file!"]
                        return -1
                    }
                    lassign [split $line =] path value
                    if {$path ne [format {%s.%s} $prefix $name]} {
                        tk_messageBox -icon error \
                              -message [_ "Sync error at %s, expected %s.%s" $path $prefix $name]
                        return -1
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    #$self putdebug "*** $self _loadNode: class of $frame.value is [winfo class $frame.value]"
                    switch [winfo class $frame.value] {
                        TCombobox {
                            upvar #0 $frame.value_VM valuemap
                            foreach v [array names valuemap] {
                                if {$valuemap($v) == $value} {
                                    $frame.value set $v
                                }
                            }
                        }
                        TSpinbox {
                            $frame.value set $value
                        }
                    }
                    return 1
                }
                string {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {[gets $fp line] < 0} {
                        tk_messageBox -icon error \
                              -message [_ "Short file!"]
                        return -1
                    }
                    lassign [split $line =] path value
                    if {$path ne [format {%s.%s} $prefix $name]} {
                        tk_messageBox -icon error \
                              -message [_ "Sync error at %s, expected %s.%s" $path $prefix $name]
                        return -1
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    $frame.value delete 0 end
                    $frame.value insert end $value
                    return 1
                }
                eventid {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {[gets $fp line] < 0} {
                        tk_messageBox -icon error \
                              -message [_ "Short file!"]
                        return -1
                    }
                    $self putdebug "*** $self _loadNode (eventid): line is '$line'"
                    lassign [split $line =] path value
                    if {$path ne [format {%s.%s} $prefix $name]} {
                        tk_messageBox -icon error \
                              -message [_ "Sync error at %s, expected %s.%s" $path $prefix $name]
                        return -1
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    $self putdebug "*** _loadNode (eventid branch): name = '$name'"
                    $self putdebug "*** _loadNode (eventid branch): n = $n, frame = $frame"
                    $self putdebug "*** $self _loadNode (eventid): class of $frame.value is [winfo class $frame.value]"
                    switch [winfo class $frame.value] {
                        TCombobox {
                            upvar #0 $frame.value_VM valuemap
                            foreach v [array names valuemap] {
                                if {$valuemap($v) == $value} {
                                    $frame.value set $v
                                }
                            }
                        }
                        TEntry {
                            $type DeleteEventUse [$frame.value get] $frame.value
                            $frame.value delete 0 end
                            $frame.value insert end $value
                            $type AddEventUse $value $frame.value
                        }
                    }
                    return 1
                }
                action {
                }
                blob {
                }
            }
        }
        method _saveas {} {
            set defaultfilename $options(-loadfile)
            set filename [tk_getSaveFile -defaultextension .txt \
                          -filetypes {{{Config Files} {.txt} TEXT}
                          {{All Files} *     TEXT}
                      } -parent [winfo toplevel $win] \
                            -title "Config file to save" \
                            -initialfile $defaultfilename]
            if {$filename eq ""} {return}
            if {[catch {open $filename w} fp]} {
                tk_messageBox -default ok \
                      -detail $fp \
                      -icon error \
                      -message [_ "Could not open %s" $filename] \
                      -parent [winfo toplevel $win] \
                      -title "Open file error" \
                      -type ok
                return
            }
            set _segmentnumber 0
            $self _saveNode \
                  [lindex [$parsedCDI getElementsByTagName cdi -depth 1] 0] \
                  $fp 
            close $fp
            wm title $win [_ "CDI Configuration Tool for config file %s" $filename]
            set options(-loadfile) $filename
        }
        method _saveNode {n fp {prefix {}}} {
            #puts "*** $self _saveNode [$n cget -tag] $fp $prefix"
            switch [$n cget -tag] {
                cdi {
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        $self _saveNode $seg $fp
                    }
                }
                identification -
                acdi {
                }
                segment {
                    incr _segmentnumber
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name [format "seg%d" $_segmentnumber]
                    }
                    set prefix $name
                    #$self putdebug "*** $self _saveNode (segment) [llength [$n children]] tag children"
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        if {[$self _saveNode $c $fp $prefix] < 0} {return -1}
                    }
                    return 1
                }
                group {
                    set replication [$n attribute replication]
                    if {$replication eq {}} {set replication 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set repnamefmt [format ".%s(%%d)" $name]
                    if {$replication > 1} {
                        for {set i 0} {$i < $replication} {incr i} {
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                                if {[$self _saveNode $c $fp "${prefix}[format $repnamefmt $i]"] < 0} {return -1}
                            }
                        }
                    } else {
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            if {[$self _saveNode $c $fp "${prefix}.$name"] < 0} {return -1}
                        }
                    }
                    return 1
                }
                int {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    switch [winfo class $frame.value] {
                        TCombobox {
                            upvar #0 $frame.value_VM valuemap
                            set value $valuemap([$frame.value get])
                        }
                        TSpinbox {
                            set value [$frame.value get]
                        }
                    }
                    puts $fp [format {%s.%s=%d} $prefix $name $value]
                    return 1
                }
                string {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    set value [$frame.value get]
                    puts $fp [format {%s.%s=%s} $prefix $name $value]
                    return 1
                }
                eventid {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    $self putdebug "*** $self _saveNode (eventid): path is '$prefix.$name'"
                    $self putdebug "*** $self _saveNode (eventid): frame is $frame"
                    $self putdebug "*** $self _saveNode (eventid): class of $frame.value is [winfo class $frame.value]"
                    switch [winfo class $frame.value] {
                        TCombobox {
                            upvar #0 $frame.value_VM valuemap
                            set value $valuemap([$frame.value get])
                            $evid destroy
                        }
                        TEntry {
                            set value [$frame.value get]
                        }
                    }
                    puts $fp [format {%s.%s=%s} $prefix $name $value]
                    return 1
                }
                action {
                }
                blob {
                }
            }
        }
        method _initblank {} {
            set eventidlist [list]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $options(-nid)] 1 end] {
                lappend eventidlist [scan $oct %02x]
            }
            lappend eventidlist 0 0
            set baseeventid [lcc::EventID create %AUTO% -eventidlist $eventidlist]
            set _segmentnumber 0
            #parray widgetMap_
            $self _initblankNode \
                  [lindex [$parsedCDI getElementsByTagName cdi -depth 1] 0] \
                  baseeventid
        }
        proc _tags {nodes} {
            set result [list]
            foreach n $nodes {
                lappend result [$n cget -tag]
            }
            return $result
        }
        method _initblankNode {n nexteventid_var {prefix {}}} {
            
            upvar $nexteventid_var nexteventid
            
            #$self putdebug "*** $self _initblankNode [$n cget -tag] $prefix"
            switch [$n cget -tag] {
                cdi {
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        $self _initblankNode $seg nexteventid $prefix
                    }
                }
                identification -
                acdi {
                }
                segment {
                    incr _segmentnumber
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name [format "seg%d" $_segmentnumber]
                    }
                    set prefix $name
                    set groupnotebook {}
                    set windex -1
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        if {[$self _initblankNode $c nexteventid $prefix] < 0} {return -1}
                    }
                    return 1
                }
                group {
                    set replication [$n attribute replication]
                    if {$replication eq {}} {set replication 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set repnamefmt [format ".%s(%%d)" $name]
                    if {$replication > 1} {
                        for {set i 0} {$i < $replication} {incr i} {
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                                if {[$self _initblankNode $c nexteventid "${prefix}[format $repnamefmt $i]"] < 0} {return -1}
                            }
                        }
                    } else {
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            if {[$self _initblankNode $c nexteventid "${prefix}.$name"] < 0} {return -1}
                        }
                    }
                    return 1
                }
                int {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set default [$n getElementsByTagName default -depth 1]
                    if {[llength $default] == 1} {
                        set value [[lindex $default 0] data]
                    } else {
                        set value 0
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    #$self putdebug "*** $self _initblankNode: class of $frame.value is [winfo class $frame.value]"
                    switch [winfo class $frame.value] {
                        TCombobox {
                            upvar #0 $frame.value_VM valuemap
                            foreach v [array names valuemap] {
                                if {$valuemap($v) == $value} {
                                    $frame.value set $v
                                }
                            }
                        }
                        TSpinbox {
                            $frame.value set $value
                        }
                    }
                    return 1
                }
                string {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set default [$n getElementsByTagName default -depth 1]
                    if {[llength $default] == 1} {
                        set value [[lindex $default 0] data]
                    } else {
                        set value {}
                    }
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    $frame.value delete 0 end
                    $frame.value insert end $value
                    return 1
                }
                eventid {
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set value [$nexteventid cget -eventidstring]
                    set neweventid [$nexteventid addtoevent 1]
                    $nexteventid destroy
                    set nexteventid $neweventid
                    #$self putdebug "*** $self _initblankNode (eventid): class of $frame.value is [winfo class $frame.value]"
                    set frame $widgetMap_([format {%s.%s} $prefix $name])
                    $self putdebug "*** $self _initblankNode (eventid): frame is $frame"
                    $self putdebug "*** $self _initblankNode (eventid): class of $frame.value is [winfo class $frame.value]"
                    switch [winfo class $frame.value] {
                        TCombobox {
                            upvar #0 $frame.value_VM valuemap
                            foreach v [array names valuemap] {
                                if {$valuemap($v) == $value} {
                                    $frame.value set $v
                                }
                            }
                        }
                        TEntry {
                            $type DeleteEventUse [$frame.value get] $frame.value
                            $frame.value delete 0 end
                            $frame.value insert end $value
                            $type AddEventUse $value $frame.value
                        }
                    }
                    return 1
                }
                action {
                }
                blob {
                }
            }
                
                
        }
            
        method _showhideLC {} {
            if {[catch {pack info $layoutcontrolsLF}]} {
                pack $layoutcontrolsLF -fill x
                $buttons itemconfigure showhideLC \
                      -text [_m "Label|Hide Layout Controls"]
            } else {
                pack forget $layoutcontrolsLF
                $buttons itemconfigure showhideLC \
                      -text [_m "Label|Show Layout Controls"]
            }
        }
        method _rereadAll {} {
            if {!$options(-displayonly) && !$options(-offlineedit)} {
                foreach s [array names _readall] {
                    $self _readall $s
                }
                EventSearch RecomputeAllSearchTexts
            }
        }
        method _traverseSegments {} {
            foreach seg [winfo children [$editframe getframe].segments] {
                _traverseSegment $seg
            }
        }
        proc _putValue {w} {
            set name [$w cget -text]
            if {[catch {$w.value get} value]} {
                puts "Group: $name"
                foreach f [winfo children $w] {
                    puts [format "%s (%s)" $f [winfo class $f]]
                    switch [winfo class $f] {
                        ScrollTabNotebook {
                            foreach r [$f tabs] {
                                _traverseReplication $r
                            }
                        }
                        TNotebook {
                            foreach g [winfo children $f] {
                                _traverseTGroup $g
                            }
                        }
                        TLabelframe {
                            _putValue $f
                        }
                    }
                }
            } else {
                set widget $w.value
                switch [winfo class $widget] {
                    TCombobox {
                        upvar #0 ${widget}_VM valuemap
                        set value $valuemap([$widget get])
                    }
                    default {
                        set value [$widget get]
                    }
                }
                puts [format "%s = %s" $name $value]
            }
        }
        proc _traverseSegment {seg} {
            set segtitle [[winfo parent $seg] tab $seg -text]
            puts "Segment: $segtitle"
            foreach c [winfo children $seg] {
                puts [format "%s (%s)" $c [winfo class $c]]
                switch [winfo class $c] {
                    TNotebook {
                        foreach g [winfo children $c] {
                            _traverseTGroup $g
                        }
                    }
                    TLabelframe {
                        _putValue $c
                    }
                }
            }
        }
        proc _traverseReplication {replication} {
            set replTitle [[winfo parent $replication] tab $replication -text]
            puts "Replication: $replTitle"
            foreach c [winfo children $replication] {
                puts [format "%s (%s)" $c [winfo class $c]]
                switch [winfo class $c] {
                    ScrollTabNotebook {
                        foreach r [$c tabs] {
                            _traverseReplication $r
                        }
                    }
                    TNotebook {
                        foreach g [winfo children $c] {
                            _traverseTGroup $g
                        }
                    }
                    TLabelframe {
                        _putValue $c
                    }
                }
            }
        }                    
        proc _traverseTGroup {tgroup} {
            set grouptitle [[winfo parent $tgroup] tab $tgroup -text]
            puts "Group: $grouptitle"
            foreach c [winfo children $tgroup] {
                puts [format "%s (%s)" $c [winfo class $c]]
                switch [winfo class $c] {
                    ScrollTabNotebook {
                        foreach r [$c tabs] {
                            _traverseReplication $r
                        }
                    }
                    TNotebook {
                        foreach g [winfo children $c] {
                            _traverseTGroup $g
                        }
                    }
                    TLabelframe {
                        _putValue $c
                    }
                }
            }
        }
        method _saveSegments {} {
            foreach seg [winfo children [$editframe getframe].segments] {
                _saveSegment $seg
            }
        }
        proc _saveValue {w} {
            if {[catch {$w.value get} value]} {
                foreach f [winfo children $w] {
                    switch [winfo class $f] {
                        ScrollTabNotebook {
                            foreach r [$f tabs] {
                                _saveReplication $r
                            }
                        }
                        TNotebook {
                            foreach g [winfo children $f] {
                                _saveTGroup $g
                            }
                        }
                        TLabelframe {
                            _saveValue $f
                        }
                    }
                }
            } else {
                if {[regexp {Mod$} [$w.value cget -style]] > 0} {
                    $w.readwrite.write invoke
                }
            }
        }
        proc _saveSegment {seg} {
            foreach c [winfo children $seg] {
                switch [winfo class $c] {
                    ScrollTabNotebook {
                        foreach r [$c tabs] {
                            _saveReplication $r
                        }
                    }
                    TNotebook {
                        foreach g [winfo children $c] {
                            _saveTGroup $g
                        }
                    }
                    TLabelframe {
                        _saveValue $c
                    }
                }
            }
        }
        proc _saveReplication {replication} {
            foreach c [winfo children $replication] {
                switch [winfo class $c] {
                    ScrollTabNotebook {
                        foreach r [$c tabs] {
                            _saveReplication $r
                        }
                    }
                    TNotebook {
                        foreach g [winfo children $c] {
                            _saveTGroup $g
                        }
                    }
                    TLabelframe {
                        _saveValue $c
                    }
                }
            }
        }
        proc _saveTGroup {tgroup} {
            foreach c [winfo children $tgroup] {
                switch [winfo class $c] {
                    ScrollTabNotebook {
                        foreach r [$c tabs] {
                            _saveReplication $r
                        }
                    }
                    TNotebook {
                        foreach g [winfo children $c] {
                            _saveTGroup $g
                        }
                    }
                    TLabelframe {
                        _saveValue $c
                    }
                }
            }
        }
        method _saveChanged {} {
            $self _saveSegments
        }
        method _backupNode {n fp space address_var {prefix {}}} {
            $self putdebug "*** _backupNode $n $fp $space $address_var $prefix"
            upvar $address_var address
            switch [$n cget -tag] {
                cdi {
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        $self _backupNode $seg $fp $space address $prefix
                    }
                }
                identification -
                acdi {
                }
                segment {
                    incr _segmentnumber
                    set space [$n attribute space]
                    set origin [$n attribute origin]
                    if {$origin eq {}} {set origin 0}
                    set address $origin
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name [format "seg%d" $_segmentnumber]
                    }
                    set prefix $name
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        $self _backupNode $c $fp $space address $prefix
                    }
                }
                group {
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
                    set repnamefmt [format ".%s(%%d)" $name]
                    incr address $offset
                    if {$replication > 1} {
                        for {set i 0} {$i < $replication} {incr i} {
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                                $self _backupNode $c $fp $space address "${prefix}[format $repnamefmt $i]"
                            }
                        }
                    } else {
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            $self _backupNode $c $fp $space address "${prefix}.$name"
                        }
                    }
                }
                int {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset 
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    set status 0x58
                    set retries 10
                    while {$status != 0x50 && $retries > 0} {
                        set data [$self _readmemory $space $address $size status]
                        if {$status == 0x50} {
                            set value 0
                            foreach b $data {
                                set value [expr {($value << 8) | $b}]
                            }
                            puts $fp [format {%s.%s=%d} $prefix $name $value]
                            break
                        } elseif {$status == 0x58} {
                            # Failure
                            set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                            set errormessage {}
                            foreach c [lrange $data 2 end] {
                                if {$c == 0} {break}
                                append errormessage [format %c $c]
                            }
                            incr retries -1
                        }
                    }
                    if {$status != 0x50} {
                        tk_messageBox -icon warning \
                              -message [_ {OpenLCB read error (%02x): %s} $errorcode $errormessage] \
                              -type ok
                    }
                    incr address $size
                }
                string {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset 
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
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
                    puts $fp [format {%s.%s=%s} $prefix $name $resultstring]
                    incr address $size
                }
                eventid {
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
                    set status 0x58
                    set retries 10
                    while {$status != 0x50 && $retries > 0} {
                        set data [$self _readmemory $space $address $size status]
                        if {$status == 0x50} {
                            set evid [lcc::EventID %AUTO% -eventidlist $data]
                            set value [$evid cget -eventidstring]
                            puts $fp [format {%s.%s=%s} $prefix $name $value]
                            $evid destroy
                            break
                        } elseif {$status == 0x58} {
                            # Failure
                            set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                            set errormessage {}
                            foreach c [lrange $data 2 end] {
                                if {$c == 0} {break}
                                append errormessage [format %c $c]
                            }
                            incr retries -1
                        }
                    }
                    if {$status != 0x50} {
                        tk_messageBox -icon warning \
                              -message [_ {OpenLCB read error (%02x): %s} $errorcode $errormessage] \
                              -type ok
                    }
                    incr address $size
                }
                action {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    incr address $size
                }
                blob {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    incr address $size
                }
                
            }
        }
        method _backup {{filename {}}} {
            set _segmentnumber 0
            if {$filename eq ""} {
                set filename [tk_getSaveFile -confirmoverwrite yes \
                              -defaultextension .txt \
                              -filetypes { {{Text Files}       {.txt} TEXT} {{All Files}        *             } } \
                              -initialdir $::env(HOME) \
                              -initialfile "config.[regsub -all {:} [$self cget -nid] {.}].txt" \
                              -parent [winfo toplevel $win] \
                              -title "Save backup to:"]
            }
            if {$filename eq ""} {return}
            if {[catch {open $filename w} fp]} {
                tk_messageBox -default ok \
                      -detail $fp \
                      -icon error \
                      -message [_ "Could not open %s" $filename] \
                      -parent [winfo toplevel $win] \
                      -title "Open file error" \
                      -type ok
                return
            }
            $self _backupNode \
                  [lindex [[$self cget -cdi] getElementsByTagName \
                           cdi -depth 1]] \
                  $fp -1 address
            close $fp
        }
        method _restoreNode {n fp space address_var {prefix {}}} {
            $self putdebug "*** _restoreNode $n $fp $space $address_var $prefix"
            upvar $address_var address
            switch [$n cget -tag] {
                cdi {
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        if {[$self _restoreNode $seg $fp $space address $prefix] < 0} {return -1}
                    }
                }
                identification -
                acdi {
                }
                segment {
                    incr _segmentnumber
                    set space [$n attribute space]
                    set origin [$n attribute origin]
                    if {$origin eq {}} {set origin 0}
                    set address $origin
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name [format "seg%d" $_segmentnumber]
                    }
                    set prefix $name
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        if {[$self _restoreNode $c $fp $space address $prefix] < 0} {return -1}
                    }
                }
                group {
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
                    set repnamefmt [format ".%s(%%d)" $name]
                    incr address $offset
                    if {$replication > 1} {
                        for {set i 0} {$i < $replication} {incr i} {
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                                if {[$self _restoreNode $c $fp $space address "${prefix}[format $repnamefmt $i]"] < 0} {return -1}
                            }
                        }
                    } else {
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            if {[$self _restoreNode $c $fp $space address "${prefix}.$name"] < 0} {return -1}
                        }
                    }
                }
                int {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset 
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {[gets $fp line] < 0} {
                        tk_messageBox -icon error \
                              -message [_ "Short file!"]
                        return -1
                    }
                    lassign [split $line =] path value
                    if {$path ne [format {%s.%s} $prefix $name]} {
                        tk_messageBox -icon error \
                              -message [_ "Sync error at %s, expected %s.%s" $path $prefix $name]
                        return -1
                    }
                    set data [list]
                    for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                        lappend data [expr {($value >> $shift) & 0xFF}]
                    }
                    set thisaddress $address
                    incr address $size
                    #return 0
                    set retdata [$self _writememory $space $thisaddress $data]
                    if {[llength $retdata] <= 1} {
                        if {$retdata eq {} || $retdata == 0} {
                            ## OK
                            return 0
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
                    return -1
                }
                string {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset 
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    if {[gets $fp line] < 0} {
                        tk_messageBox -icon error \
                              -message [_ "Short file!"]
                        return -1
                    }
                    lassign [split $line =] path value
                    if {$path ne [format {%s.%s} $prefix $name]} {
                        tk_messageBox -icon error \
                              -message [_ "Sync error at %s, expected %s.%s" $path $prefix $name]
                        return -1
                    }
                    set thisaddress $address
                    incr address $size
                    #return 0
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
                        set a [expr {$thisaddress + $off}]
                        set retdata [$self _writememory $space $a [lrange $fulldata $off [expr {($off + $remain) - 1}]]]
                        if {[llength $retdata] <= 1} {
                            if {$retdata eq {} || $retdata == 0} {
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
                eventid {
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
                    if {[gets $fp line] < 0} {
                        tk_messageBox -icon error \
                              -message [_ "Short file!"]
                        return -1
                    }
                    lassign [split $line =] path value
                    if {$path ne [format {%s.%s} $prefix $name]} {
                        tk_messageBox -icon error \
                              -message [_ "Sync error at %s, expected %s.%s" $path $prefix $name]
                        return -1
                    }
                    set evid [lcc::EventID %AUTO% -eventidstring $value]
                    set data [$evid cget -eventidlist]
                    $evid destroy
                    set thisaddress $address
                    incr address $size
                    #return 0
                    set retdata [$self _writememory $space $thisaddress $data]
                    if {[llength $retdata] <= 1} {
                        if {$retdata eq {} || $retdata == 0} {
                            ## OK
                            return 0
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
                    return -1
                }
                action {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    incr address $size
                }
                blob {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    incr address $size
                }
            }
            return 0
        }
        method _restore {{filename {}}} {
            if {$filename eq ""} {
                set filename [tk_getOpenFile \
                              -defaultextension .txt \
                              -filetypes { {{Text Files}       {.txt} TEXT} {{All Files}        *             } } \
                              -initialdir $::env(HOME) \
                              -initialfile "config.[regsub -all {:} [$self cget -nid] {.}].txt" \
                              -parent [winfo toplevel $win] \
                              -title "Restore backup from:"]
            }
            if {$filename eq ""} {return}
            if {[catch {open $filename r} fp]} {
                tk_messageBox -default ok \
                      -detail $fp \
                      -icon error \
                      -message [_ "Could not open %s" $filename] \
                      -parent [winfo toplevel $win] \
                      -title "Open file error" \
                      -type ok
                return
            }
            set _segmentnumber 0
            $self _restoreNode  \
                  [lindex [[$self cget -cdi] getElementsByTagName \
                           cdi -depth 1]] \
                  $fp -1 address
            close $fp
        }
        method _rebootAndClose {} {
            if {[tk_messageBox -default no -icon question \
                 -message [_m "Are you sure?"] -parent $win \
                 -title [_m "Confirm reboot"] -type yesno]} {
                [$self cget -transport] SendDatagram [$self cget -nid] [list 0x20 0xA9]
                $self _close
             }
        }
        method _layoutControlsCreation {frame} {
            install layoutcontrolsLF using ttk::labelframe \
                  $frame.layoutcontrolsLF -labelanchor nw \
                  -text [_m "Label|Layout Controls"]
            pack $layoutcontrolsLF -fill x
            install layoutcontrolsNB using ScrollTabNotebook \
                  $layoutcontrolsLF.layoutcontrolsNB 
            pack $layoutcontrolsNB -fill both -expand yes
            install addturnoutW using ::lcc::NewTurnoutWidget \
                  $layoutcontrolsNB.addturnoutW \
                  -db [$self cget -layoutdb] -copypaste yes
            $layoutcontrolsNB add $addturnoutW -text [_m "Label|Turnout"] -sticky news
            install addblockW using ::lcc::NewBlockWidget \
                  $layoutcontrolsNB.addblockW \
                  -db [$self cget -layoutdb] -copypaste yes
            $layoutcontrolsNB add $addblockW -text [_m "Label|Block"] -sticky news
            install addsensorW using ::lcc::NewSensorWidget \
                  $layoutcontrolsNB.addsensorW \
                  -db [$self cget -layoutdb] -copypaste yes
            $layoutcontrolsNB add $addsensorW -text [_m "Label|Sensor"] -sticky news
            install addcontrolW using ::lcc::NewControlWidget \
                  $layoutcontrolsNB.addcontrolW \
                  -db [$self cget -layoutdb] -copypaste yes
            $layoutcontrolsNB add $addcontrolW -text [_m "Label|Control"] -sticky news
        }
        method edit_checksel {} {
            if {[catch {selection get}]} {
                $main setmenustate edit:havesel disabled
            } else {
                $main setmenustate edit:havesel normal
            }
        }
        typevariable idheaders -array {}
        ## @privatesection Locale versions of the identification headers.
        
        typeconstructor {
            set idheaders(manufacturer) [_m "Label|Manufacturer"]
            set idheaders(model) [_m "Label|Model"]
            set idheaders(hardwareVersion) [_m "Label|Hardware Version"]
            set idheaders(softwareVersion) [_m "Label|Software Version"]
            set editContextMenu [StdEditContextMenu .editContextMenu]
            $editContextMenu bind Entry
            $editContextMenu bind TEntry
            $editContextMenu bind Text
            $editContextMenu bind ROText
            $editContextMenu bind Spinbox
            set event_also_used ::lcc::EventUseTable
            ttk::style layout TButtonHot [ttk::style layout TButton]
            foreach {opt value} [ttk::style configure TButton] {
                ttk::style configure TButtonHot $opt $value
            }
            ttk::style configure TButtonHot -background orange
            ttk::style layout TEntryMod [ttk::style layout TEntry]
            foreach {opt value} [ttk::style configure TEntry] {
                ttk::style configure TEntryMod $opt $value
            }
            ttk::style configure TEntryMod -fieldbackground orange
            ttk::style layout TComboboxMod [ttk::style layout TCombobox]
            foreach {opt value} [ttk::style configure TCombobox] {
                ttk::style configure TComboboxMod $opt $value
            }
            ttk::style configure TComboboxMod -fieldbackground orange
            ttk::style layout TSpinboxMod [ttk::style layout TSpinbox]
            foreach {opt value} [ttk::style configure TSpinbox] {
                ttk::style configure TSpinboxMod $opt $value
            }
            ttk::style configure TSpinboxMod -fieldbackground orange
            ttk::style layout TFrameMod [ttk::style layout TFrame]
            foreach {opt value} [ttk::style configure TFrame] {
                ttk::style configure TFrameMod $opt $value
            }
            ttk::style configure TFrameMod -background orange
            ttk::style layout TCheckbuttonMod [ttk::style layout TCheckbutton]
            foreach {opt value} [ttk::style configure TCheckbutton] {
                ttk::style configure TCheckbuttonMod $opt $value
            }
            ttk::style configure TCheckbuttonMod -background orange
            ttk::style map TCheckbuttonMod  -indicatorcolor \
                  [ttk::style map TCheckbutton -indicatorcolor]
            ttk::style map TCheckbuttonMod  -indicatorrelief \
                  [ttk::style map TCheckbutton -indicatorrelief]
                  
            ttk::style layout Horizontal.TScaleMod [ttk::style layout Horizontal.TScale]
            foreach {opt value} [ttk::style configure TScale] {
                ttk::style configure TScaleMod $opt $value
            }
            ttk::style configure TScaleMod -background orange
            
        }
        typevariable _stack [list]
        proc push {x} {set _stack [linsert $_stack 0 $x]}
        proc pop {} {
            set top [lindex $_stack 0]
            set _stack [lrange $_stack 1 end]
            return $top
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
        variable _mkbuttons no
        ## Flag for Make Sensor / Make Turnout etc. buttons
        proc _makemod {w args} {
            set curstyle [$w cget -style]
            if {[regexp {Mod$} $curstyle] > 0} {return}
            $w configure -style ${curstyle}Mod
        }
        proc _makemod_rb {w rb args} {
            set curstyle [$w cget -style]
            if {[regexp {Mod$} $curstyle] > 0} {return}
            $w configure -style ${curstyle}Mod
            set var [$rb cget -variable]
            set val [$rb cget -value]
            set $var $val
        }
        proc _makemod_cb {w} {
            set var [$w cget -variable]
            upvar #0 $var v
            puts stderr "*** _makemod_cb: $var is $v"
            set curstyle [$w cget -style]
            puts stderr "*** _makemod_cb: curstyle = $curstyle"
            if {[regexp {Mod$} $curstyle] > 0} {return}
            $w configure -style ${curstyle}Mod
            return $v
        }
        proc checkformaphints {hints pc rb_var cb_var} {
            upvar $rb_var rb
            set rb no
            upvar $cb_var cb
            set cb no
            if {[llength $hints] == 1} {
                set hints [lindex $hints 0]
                set rbtag [$hints getElementsByTagName radiobutton -depth 1]
                if {[llength $rbtag] == 1} {set rb yes}
                set cbtag [$hints getElementsByTagName checkbox -depth 1]
                if {[llength $cbtag] == 1 && $pc == 2} {set cb yes}
                if {$rb || $cb} {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        proc checkforsliderhints {hints tickSpace_var immediate_var} {
            upvar $tickSpace_var tickSpace
            set tickSpace 0
            upvar $immediate_var immediate
            set immediate no
            if {[llength $hints] == 1} {
                set hints [lindex $hints 0]
                set slider [$hints getElementsByTagName slider -depth 1]
                if {[llength $slider] == 1} {
                    set slider [lindex $slider 0]
                    set tickSpace_ [$slider attribute tickSpace]
                    if {$tickSpace_ ne {}} {set tickSpace $tickSpace_}
                    set immediate_ [$slider attribute immediate]
                    if {$immediate_ ne {}} {set immediate $immediate_}
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        method _processXMLnode {n frame space address_var {prefix {}}} {
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
            
            update idle
            $self putdebug "*** $self _processXMLnode $n $frame $space $address_var $prefix"
            upvar $address_var address
            $self putdebug "*** $self _processXMLnode: tag is [$n cget -tag] at address [format %08x $address]"
            switch [$n cget -tag] {
                cdi {
                    set id [$n getElementsByTagName identification -depth 1]
                    if {[llength $id] == 1} {
                        $self _processXMLnode [lindex $id 0] $frame $space address $prefix
                    }
                    set segnotebook [ttk::notebook $frame.segments]
                    pack $segnotebook -fill both
                    foreach seg [$n getElementsByTagName segment -depth 1] {
                        $self _processXMLnode $seg $segnotebook $space address $prefix
                    }
                }
                identification {
                    set idf [ttk::labelframe $frame.identification \
                             -labelanchor nw \
                             -text [_m "Label|Identification"]]
                    pack $idf -fill x 
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
                    push $_intnumber
                    set _intnumber 0
                    push $_stringnumber
                    set _stringnumber 0
                    push $_eventidnumber
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
                    set prefix $name
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
                                pack $groupnotebook -fill both
                            }
                            $self _processXMLnode $c $groupnotebook $space address $prefix
                        } else {
                            $self _processXMLnode $c $segmentframe $space address $prefix
                        }
                    }
                    set readall [ttk::button $segmentframe.readall \
                                 -text [_m "Label|Read All"] \
                                 -command [mymethod _readall $space]]
                    pack $readall -fill x -anchor center
                    if {$options(-displayonly) || $options(-offlineedit)} {
                        $readall configure -state disabled
                    }
                    ## Print/Export the entire segment?
                    if {!$options(-displayonly) && !$options(-offlineedit)} {
                        set printexport [ttk::button $segmentframe.printexport \
                                         -text [_m "Label|Print or Export Segment"] \
                                         -command [mymethod _printexport $n $segmentframe [format "Segment: 0x%02x" $space]]]
                        pack $printexport -fill x -anchor center
                    }
                    set _eventidnumber [pop]
                    set _stringnumber  [pop]
                    set _intnumber     [pop]
                }
                group {
                    incr _groupnumber
                    push $_intnumber
                    set _intnumber 0
                    push $_stringnumber
                    set _stringnumber 0
                    push $_eventidnumber
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
                        pack $groupframe -fill x
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
                    incr address $offset
                    set keyrepnamefmt [format ".%s(%%d)" $name]
                    set hints [$n getElementsByTagName hints -depth 1]
                    push $options(-displayonly)
                    if {[llength $hints] == 1} {
                        set hints [lindex $hints 0]
                        if {[llength [$hints getElementsByTagName readonly -depth 1]] > 0} {
                            set options(-displayonly) yes
                        }
                    }
                    if {$replication > 1} {
                        #set replnotebook [ttk::notebook $groupframe.replnotebook]
                        set replnotebook [ScrollTabNotebook $groupframe.replnotebook]
                        pack $replnotebook -fill both
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
                            set savedgn $_groupnumber
                            set _groupnumber 0
                            push $_intnumber
                            set _intnumber 0
                            push $_stringnumber
                            set _stringnumber 0
                            push $_eventidnumber
                            set _eventidnumber 0
                            set _mkbuttons no
                            foreach c [$n children] {
                                set tag [$c cget -tag]
                                if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                                $self _processXMLnode $c $replframe $space address "${prefix}[format $keyrepnamefmt [expr {$i-1}]]"
                            }
                            if {$_stringnumber == 1 &&
                                $_eventidnumber == 2 &&
                                !$_mkbuttons} {
                                set f [ttk::frame $replframe.makeframe]
                                pack $f -expand yes -fill x
                                pack [ttk::button $f.mkturn \
                                      -text [_m "Label|Make Turnout"] \
                                      -command [mymethod mkNewTurnout $replframe]] \
                                      -side right
                                pack [ttk::button $f.mkblock \
                                      -text [_m "Label|Make Block"] \
                                      -command [mymethod mkNewBlock $replframe]] \
                                      -side right
                                pack [ttk::button $f.mksense \
                                      -text [_m "Label|Make Sensor"] \
                                      -command [mymethod mkNewSensor $replframe]] \
                                      -side right
                                pack [ttk::button $f.mkcontrol \
                                      -text [_m "Label|Make Control"] \
                                      -command [mymethod mkNewControl $replframe]] \
                                      -side right
                                set _mkbuttons yes
                            }
                            set _groupnumber $savedgn
                            ## Print/Export this replication?
                            set text [format [format [_m "Label|Print or Export %s"] $repnamefmt] $i]
                            if {!$options(-displayonly) && !$options(-offlineedit)} {
                                set printexport [ttk::button $replframe.printexport \
                                                 -text $text \
                                                 -command [mymethod _printexport $n $replframe [format $repnamefmt $i]]]
                                pack $printexport -fill x -anchor center
                            }
                            set _eventidnumber [pop]
                            set _stringnumber  [pop]
                            set _intnumber     [pop]
                        }
                    } else {
                        set savedgn $_groupnumber
                        set _groupnumber 0
                        set _mkbuttons no
                        $self putdebug "*** _processXMLnode (group branch, non replicated): groupframe = $groupframe"
                        $n setAttribute gframe [string range $groupframe [expr {[string length $frame]+1}] end]
                        $self putdebug "*** _processXMLnode (group branch, non replicated): attrs of $n are [$n cget -attributes]"
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            $self _processXMLnode $c $groupframe $space address "${prefix}.$name"
                        }
                        if {$_stringnumber == 1 &&
                            $_eventidnumber == 2 &&
                            !$_mkbuttons} {
                            set f [ttk::frame $groupframe.makeframe]
                            pack $f -expand yes -fill x
                            pack [ttk::button $f.mkturn \
                                  -text [_m "Label|Make Turnout"] \
                                  -command [mymethod mkNewTurnout $groupframe]] \
                                  -side right
                            pack [ttk::button $f.mkblock \
                                  -text [_m "Label|Make Block"] \
                                  -command [mymethod mkNewBlock $groupframe]] \
                                  -side right
                            pack [ttk::button $f.mksense \
                                  -text [_m "Label|Make Sensor"] \
                                  -command [mymethod mkNewSensor $groupframe]] \
                                  -side right
                            pack [ttk::button $f.mkcontrol \
                                  -text [_m "Label|Make Control"] \
                                  -command [mymethod mkNewControl $groupframe]] \
                                 -side right
                            set _mkbuttons yes
                        }
                        set _groupnumber $savedgn
                    }
                    ## Print/Export this group?
                    set text [format [_m "Label|Print or Export Group %s"] $name]
                    if {!$options(-displayonly) && !$options(-offlineedit)} {
                        set printexport [ttk::button $groupframe.printexport \
                                         -text $text \
                                         -command [mymethod _printexport $n $groupframe [_ "Group %s" $name]]]
                        pack $printexport -fill x -anchor center
                    }
                    set options(-displayonly) [pop]
                    set _eventidnumber [pop]
                    set _stringnumber  [pop]
                    set _intnumber     [pop]
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
                    $self putdebug "*** _processXMLnode (int branch): frame is $frame, _intnumber is $_intnumber"
                    $self putdebug "*** _processXMLnode (int branch): name is '$name'"
                    if {$name ne {}} {
                        set intframe [ttk::labelframe \
                                      $frame.int$_intnumber \
                                      -labelanchor nw -text $name]
                    } else {
                        set intframe [ttk::frame \
                                      $frame.int$_intnumber]
                    }
                    $n setAttribute vframe int$_intnumber
                    pack $intframe -fill x;# -expand yes
                    set widgetMap_([format {%s.%s} $prefix $name]) $intframe
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
                    set hints [$n getElementsByTagName hints -depth 1]
                    $self putdebug "*** $self _processXMLnode (int branch): map = $map (length is [llength $map])"
                    if {[llength $map] == 1} {
                        set map [lindex $map 0]
                        set propcount [llength [$map getElementsByTagName relation -depth 1]]
                        if {[checkformaphints $hints $propcount rb cb]} {
                            # <radiobutton> and <checkbox> 
                            if {$rb} {
                                # <radiobutton>: ttk::radiobutton 
                                ttk::frame $widget -style TFrame
                                upvar #0 ${widget}_value rbvalue
                                set rbindx 0
                                foreach rel [$map getElementsByTagName relation -depth 1] {
                                    set prop [[lindex [$rel getElementsByTagName property -depth 1] 0] data]
                                    set value [[lindex [$rel getElementsByTagName value -depth 1] 0] data]
                                    incr rbindx
                                    pack [ttk::radiobutton $widget.rb$rbindx \
                                          -text $value \
                                          -variable ${widget}_value \
                                          -command [myproc _makemod_rb $widget $widget.rb$rbindx] \
                                          -value $prop] -side left
                                    set rbvalue $default
                                }
                                set readermethod _intRBRead
                                set writermethod _intRBWrite
                            } elseif {$cb} {
                                # <checkbox>: ttk::checkbutton
                                lassign [$map getElementsByTagName relation -depth 1] offrel onrel
                                set poff [[lindex [$offrel getElementsByTagName property -depth 1] 0] data]
                                set voff [[lindex [$offrel getElementsByTagName value -depth 1] 0] data]
                                set pon [[lindex [$onrel getElementsByTagName property -depth 1] 0] data]
                                set von [[lindex [$onrel getElementsByTagName value -depth 1] 0] data]
                                upvar #0 ${widget}_value cbvalue
                                upvar #0 ${widget}_text  cbtext
                                set cbtext $von
                                set cbvalue $poff
                                ttk::checkbutton $widget \
                                      -textvariable ${widget}_text \
                                      -variable ${widget}_value \
                                      -command [myproc _makemod_cb $widget] \
                                      -offvalue $poff -onvalue $pon \
                                      -style TCheckbutton
                                set readermethod _intCBRead
                                set writermethod _intCBWrite
                            }
                        } else {
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
                            ttk::combobox $widget -values $values -state readonly -style TCombobox
                            bind $widget <<ComboboxSelected>> "+[myproc _makemod $widget]"
                            $widget set $default_value
                            set readermethod _intComboRead
                            set writermethod _intComboWrite
                        }
                    } elseif {[checkforsliderhints $hints tickSpace immediate]} {
                        # <slider>: ttk::scale widget
                        ttk::scale $widget -from $min -to $max \
                              -orient horizontal -value $default \
                              -command [myproc _makemod $widget] \
                              -style TScale
                        set readermethod _intScaleRead
                        set writermethod _intScaleWrite
                    } else {
                        ttk::spinbox $widget -from $min -to $max -increment 1 -style TSpinbox
                        $widget set $default
                        bind $widget <<Increment>> "+[myproc _makemod $widget]"
                        bind $widget <<Decrement>> "+[myproc _makemod $widget]"
                        bind $widget <Key> "+[myproc _makemod $widget]"
                        bind $widget <<Paste>> "+[myproc _makemod $widget]"
                        set readermethod _intSpinRead
                        set writermethod _intSpinWrite
                    }
                    pack $widget -fill x
                    set readwrite [ButtonBox $intframe.readwrite \
                                   -buttonalignment left \
                                   -orient horizontal]
                    pack $readwrite -expand yes -fill x
                    set rb [$readwrite add ttk::button read -text [_m "Label|Read"] \
                            -command [mymethod $readermethod $widget $space $address $size]]
                    lappend _readall($space) $rb
                    $readwrite add ttk::button write -text [_m "Label|Write"] \
                          -command [mymethod $writermethod $widget $space $address $size $min $max]
                    if {$options(-displayonly)} {
                        $readwrite configure -state disabled
                    } elseif {$options(-offlineedit)} {
                        $readwrite itemconfigure read -state disabled
                        $readwrite itemconfigure write -state disabled
                    } else {
                        $rb invoke
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
                    $self putdebug "*** _processXMLnode (string branch): frame is $frame, _stringnumber is $_stringnumber"
                    $self putdebug "*** _processXMLnode (string branch): name is '$name'"
                    if {$name ne {}} {
                        set stringframe [ttk::labelframe \
                                         $frame.string$_stringnumber \
                                         -labelanchor nw -text $name]
                    } else {
                        set stringframe [ttk::frame \
                                         $frame.string$_stringnumber]
                    }
                    $n setAttribute vframe string$_stringnumber
                    $self putdebug "*** _processXMLnode (string branch) key is '[format {%s.%s} $prefix $name]'"
                    set widgetMap_([format {%s.%s} $prefix $name]) $stringframe    
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
                        ttk::combobox $widget -values $values -state readonly -style TCombobox
                        $widget set [lindex $values 0]
                        bind $widget <<ComboboxSelected>> "+[myproc _makemod $widget]"
                        set readermethod _stringComboRead
                        set writermethod _stringComboWrite
                    } else {
                        ttk::entry $widget -style TEntry
                        bind $widget <Key> "+[myproc _makemod $widget]"
                        bind $widget <<Paste>> "+[myproc _makemod $widget]"
                        set readermethod _stringEntryRead
                        set writermethod _stringEntryWrite
                    }
                    pack $widget -fill x
                    set readwrite [ButtonBox $stringframe.readwrite \
                                   -buttonalignment left \
                                   -orient horizontal]
                    pack $readwrite -expand yes -fill x
                    set rb [$readwrite add ttk::button read -text [_m "Label|Read"] \
                            -command [mymethod $readermethod $widget $space $address $size]]
                    $readwrite add ttk::button copy -text [_m "Label|Copy"] \
                          -command [mymethod _copytext $widget $readwrite.copy]
                    $readwrite add ttk::button paste  -text [_m "Label|Paste"] \
                          -command [mymethod _pastetext $widget $readwrite.paste]
                    lappend _readall($space) $rb
                    $readwrite add ttk::button write -text [_m "Label|Write"] \
                          -command [mymethod $writermethod $widget $space $address $size]
                    if {$options(-displayonly)} {
                        $readwrite configure -state disabled
                    } elseif {$options(-offlineedit)} {
                        $readwrite itemconfigure read -state disabled
                        $readwrite itemconfigure write -state disabled
                    } else {
                        $rb invoke
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
                    $n setAttribute vframe eventid$_eventidnumber
                    $self putdebug "*** _processXMLnode (eventid branch): name = '$name'"
                    $self putdebug "*** _processXMLnode (eventid branch): n = $n, eventidframe = $eventidframe"
                    set widgetMap_([format {%s.%s} $prefix $name]) $eventidframe
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
                        ttk::combobox $widget -values $values -state readonly -style TCombobox
                        bind $widget <<ComboboxSelected>> "+[myproc _makemod $widget]"
                        $widget set [lindex $values 0]
                        set readermethod _eventidComboRead
                        set writermethod _eventidComboWrite
                    } else {
                        ttk::entry $widget -style TEntry
                        bind $widget <Key> "+[myproc _makemod $widget]"
                        bind $widget <<Paste>> "+[myproc _makemod $widget]"
                        $widget insert end {00.00.00.00.00.00.00.00}
                        set readermethod _eventidEntryRead
                        set writermethod _eventidEntryWrite
                        bind $widget <3> "[mymethod _eventContext %W %X %Y]"
                    }
                    pack $widget -fill x
                    set readwrite [ButtonBox $eventidframe.readwrite \
                                   -buttonalignment left \
                                   -orient horizontal]
                    pack $readwrite -expand yes -fill x
                    set rb [$readwrite add ttk::button read -text [_m "Label|Read"] \
                            -command [mymethod $readermethod $widget $space $address $size]]
                    set usemessage [message $eventidframe.usage \
                                    -aspect 1500]
                    pack $usemessage -expand yes -fill x
                    lappend _readall($space) $rb
                    $readwrite add ttk::button write -text [_m "Label|Write"] \
                          -command [mymethod $writermethod $widget $space $address $size]
                    $readwrite add ttk::button showuse -text [_m "Label|Show Uses"] \
                          -command [mymethod _showeventuse $widget $usemessage]
                    $readwrite add ttk::button copy -text [_m "Label|Copy"] \
                          -command [mymethod _copyevent $widget $readwrite.copy]
                    $readwrite add ttk::button paste  -text [_m "Label|Paste"] \
                          -command [mymethod _pasteevent $widget $readwrite.paste]
                    $readwrite add ::lcc::EventSearch search \
                          -eventwidget $widget
                    if {$options(-displayonly)} {
                        $readwrite configure -state disabled
                    } elseif {$options(-offlineedit)} {
                        $readwrite  itemconfigure read -state disabled
                        $readwrite  itemconfigure write -state disabled
                    } else {
                        $rb invoke
                    }
                    incr address $size
                }
                action {
                    incr _intnumber
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    set name [$n getElementsByTagName name -depth 1]
                    if {[llength $name] == 1} {
                        set name [[lindex $name 0] data]
                    } else {
                        set name {}
                    }
                    $self putdebug "*** _processXMLnode (action branch): frame is $frame, _intnumber is $_intnumber"
                    $self putdebug "*** _processXMLnode (action branch): name is '$name'"
                    if {$name ne {}} {
                        set intframe [ttk::labelframe \
                                      $frame.int$_intnumber \
                                      -labelanchor nw -text $name]
                    } else {
                        set intframe [ttk::frame \
                                      $frame.int$_intnumber]
                    }
                    $n setAttribute vframe int$_intnumber
                    pack $intframe -fill x;# -expand yes
                    set widgetMap_([format {%s.%s} $prefix $name]) $intframe
                    set descr [$n getElementsByTagName description -depth 1]
                    if {[llength $descr] == 1} {
                        set description [[lindex $descr 0] data]
                        set lab [ttk::label $intframe.descr \
                                 -text $description]
                        pack $lab -fill x
                    }
                    set widget $intframe.value
                    set btext [$n getElementsByTagName buttonText -depth 1]
                    if {[llength $btext] == 1} {
                        set buttonText [[lindex $btext 0] data]
                    } else {
                        tk_messageBox -icon warning -message "Button Text missing for Action item!" -type ok
                        set buttonText "No Button Text"
                    }
                    set dtext [$n getElementsByTagName dialogText -depth 1]
                    if {[llength $dtext] == 1} {
                        set dialogText [[lindex $dtext 0] data]
                    } else {
                        set dialogText ""
                    }
                    set vwrite [$n getElementsByTagName value -depth 1]
                    if {[llength $vwrite ] == 1} {
                        set valWrite [[lindex $vwrite 0] data]
                    } else {
                        tk_messageBox -icon warning -message "Button value missing, assuming 0!" -type ok
                        set valWrite 0
                    }
                    ttk::button $widget \
                          -command [mymethod _actionWrite $widget $space \
                                    $address $size $valWrite $dialogText] \
                          -text $buttonText
                    pack $widget -fill x
                    if {$options(-displayonly) || $options(-offlineedit)} {
                        $widget configure -state disabled
                    }
                    incr address $size
                }
                blob {
                    set offset [$n attribute offset]
                    if {$offset eq {}} {set offset 0}
                    incr address $offset
                    set size [$n attribute size]
                    if {$size eq {}} {set size 1}
                    incr address $size
                }
            }
            #update idle
        }
        method _showeventuse {widget message} {
            set m ""
            foreach u [$type GetEventUsesFormatted [$widget get]] {
                append m "$u\n"
            }
            $message configure -text $m
        }
        typevariable _lastCopyButton {}
        method _copyevent {widget button} {
            if {$_lastCopyButton ne {}} {
                $_lastCopyButton configure -style TButton
                set _lastCopyButton {}
            }
            $button configure -style TButtonHot
            set _lastCopyButton $button
            $widget selection range 0 end
        }
        method _copytext {widget button} {
            if {$_lastCopyButton ne {}} {
                $_lastCopyButton configure -style TButton
                set _lastCopyButton {}
            }
            $button configure -style TButtonHot
            set _lastCopyButton $button
            $widget selection range 0 end
        }
        method _pasteevent {widget button} {
            if {[catch {selection get} select]} {return}
            if {$select eq ""} {return}
            if {[catch {lcc::eventidstring validate $select}]} {return}
            $button configure -style TButtonHot
            $type DeleteEventUse [$widget get] $widget
            $widget delete 0 end
            $widget insert end $select
            $type AddEventUse $select $widget
            set curstyle [$widget cget -style]
            if {[regexp {Mod$} $curstyle] < 1} {
                $widget configure -style ${curstyle}Mod
            }
        }
        method _pastetext {widget button} {
            if {[catch {selection get} select]} {return}
            if {$select eq ""} {return}
            $button configure -style TButtonHot
            $widget delete 0 end
            $widget insert end $select
            set curstyle [$widget cget -style]
            if {[regexp {Mod$} $curstyle] < 1} {
                $widget configure -style ${curstyle}Mod
            }
        }
        method _eventContext1 {dismiscmd entry item taglist} {
            uplevel #0 $dismiscmd
            set tag $item
            foreach t $taglist {
                set tag [$tag getElementsByTagName $t -depth 1]
            }
            set oldeventID [$entry get]
            if {[$tag data] eq {} && "$oldeventID" ne {}} {
                $tag setdata $oldeventID
            } else {
                $entry delete 0 end
                $entry insert end [$tag data]
            }
        }
        proc checkrow {w gcolVar growVar lastrow} {
            upvar $gcolVar gcol
            upvar $growVar grow
            set screenbottom [winfo screenheight $w]
            update idle
            set h [winfo reqheight $w]
            #$self putdebug "*** checkrow: gcol=$gcol, grow=$grow, h=$h"
            if {($gcol == 0 && ($h + 50) > $screenbottom) || 
                ($gcol > 0 && $grow >= $lastrow)} {
                incr gcol
                set grow -1
                grid columnconfigure $w $gcol -weight 0
            }
        }
        method _eventContext {entry rootx rooty} {
            #$self putdebug "*** $self _eventContext $entry $rootx $rooty"
            set layoutcontroldb [$self cget -layoutdb]
            #$self putdebug "*** $self _eventContext: layoutcontroldb is $layoutcontroldb"
            if {$layoutcontroldb eq {}} {return}
            set l [$layoutcontroldb getElementsByTagName layout]
            #$self putdebug "*** $self _eventContext: l is $l"
            set items [$l children]
            toplevel $win.em
            wm overrideredirect $win.em 1
            set idx 0
            set gcol 0
            set grow -1
            set lastrow 0
            grid columnconfigure $win.em $gcol -weight 0
            foreach i $items {
                $self putdebug "*** $self _eventContextAny: gcol = $gcol, grow = $grow"
                set n [$i getElementsByTagName name -depth 1]
                $self putdebug "*** $self _eventContextAny: \[\$n data] = [$n data]"
                set tag [$i cget -tag]
                $self putdebug "*** $self _eventContextAny: tag = $tag"
                switch $tag {
                    block {
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Occupied}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {occupied}]] -column $gcol \
                              -row $grow -sticky news
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Clear}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {clear}]] -column $gcol \
                              -row $grow -sticky news
                    }
                    turnout {
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Motor}]:[_m {Button|Normal}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {motor normal}]] -column $gcol \
                              -row $grow -sticky news
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Motor}]:[_m {Button|Reversed}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {motor reverse}]] -column $gcol \
                              -row $grow -sticky news
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Points}]:[_m {Button|Normal}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {points normal}]] -column $gcol \
                              -row $grow -sticky news
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Points}]:[_m {Button|Reverse}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {points reverse}]] -column $gcol \
                              -row $grow -sticky news
                    }
                    signal {
                        foreach a [$i getElementsByTagName aspect -depth 1] {
                            set na [$a getElementsByTagName name -depth 1]
                            incr idx
                            checkrow $win.em gcol grow $lastrow
                            incr grow
                            if {$lastrow < $grow} {set lastrow $grow}
                            grid [button $win.em.b$idx -text "[$n data]:[$na data]" \
                                  -command [mymethod _eventContext1 [list destroy $win.em] \
                                            $entry $a {eventid}]] -column $gcol \
                                  -row $grow -sticky news
                        }
                    }
                    sensor {
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|On}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {on}]] -column $gcol \
                              -row $grow -sticky news
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Off}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {off}]] -column $gcol \
                              -row $grow -sticky news
                    }
                    control {
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|On}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {on}]] -column $gcol \
                              -row $grow -sticky news
                        incr idx
                        checkrow $win.em gcol grow $lastrow
                        incr grow
                        if {$lastrow < $grow} {set lastrow $grow}
                        grid [button $win.em.b$idx -text "[$n data]:[_m {Button|Off}]" \
                              -command [mymethod _eventContext1 [list destroy $win.em] \
                                        $entry $i {off}]] -column $gcol \
                              -row $grow -sticky news
                    }
                }
            }
            grid [button $win.em.dismis -text [_m {Button|Dismis}] \
                  -command [list destroy $win.em]] -column 0 \
                  -row [expr {$lastrow + 1}] \
                  -columnspan [expr {$gcol + 1}] -sticky news
            update idle
            set h [winfo reqheight $win.em]
            set w [winfo reqwidth  $win.em]
            set screenbottom [winfo screenheight $win.em]
            set screenright  [winfo screenwidth  $win.em]
            if {($rootx + $w) > $screenright} {set rootx [expr {$screenright - $w}]}
            if {($rooty + $h) > $screenbottom} {set rooty [expr {$screenbottom - $h}]}
            if {$rootx < 0} {set rootx 0}
            if {$rooty < 0} {set rooty 0}
            wm geometry $win.em +$rootx+$rooty
            return -code break
        }
        method mkNewTurnout {fr} {
            set layoutcontroldb [$self cget -layoutdb]
            #$self putdebug "*** $self mkNewTurnout: layoutcontroldb is $layoutcontroldb"
            if {$layoutcontroldb eq {}} {return}
            set l [$layoutcontroldb getElementsByTagName layout]
            set new [$newTurnout draw -db $layoutcontroldb]
            if {$new eq {}} {return}
            set ee1 $fr.eventid1.value
            set ee2 $fr.eventid2.value
            set which [tk_dialog $win.which "Motor or Points?" "Motor or Points?" questhead {} Motor Points]
            switch $which {
                0 {
                    set tag [$new getElementsByTagName motor -depth 1]
                }
                1 {
                    set tag [$new getElementsByTagName points -depth 1]
                }
            }
            [$tag getElementsByTagName normal -depth 1] setdata [$ee1 get]
            [$tag getElementsByTagName reverse -depth 1] setdata [$ee2 get]
        }
        method mkNewBlock {fr} {
            set layoutcontroldb [$self cget -layoutdb]
            #$self putdebug "*** $self mkNewBlock: layoutcontroldb is $layoutcontroldb"
            if {$layoutcontroldb eq {}} {return}
            set l [$layoutcontroldb getElementsByTagName layout]
            set new [$newBlock draw -db $layoutcontroldb]
            if {$new eq {}} {return}
            set ee1 $fr.eventid1.value
            set ee2 $fr.eventid2.value
            [$new getElementsByTagName clear -depth 1] setdata [$ee1 get]
            [$new getElementsByTagName occupied -depth 1] setdata [$ee2 get]
        }
        method mkNewSensor {fr} {
            set layoutcontroldb [$self cget -layoutdb]
            #$self putdebug "*** $self mkNewSensor: layoutcontroldb is $layoutcontroldb"
            if {$layoutcontroldb eq {}} {return}
            set l [$layoutcontroldb getElementsByTagName layout]
            set new [$newSensor draw -db $layoutcontroldb]
            if {$new eq {}} {return}
            set ee1 $fr.eventid1.value
            set ee2 $fr.eventid2.value
            [$new getElementsByTagName off -depth 1] setdata [$ee1 get]
            [$new getElementsByTagName on -depth 1] setdata [$ee2 get]
        }
        method mkNewControl {fr} {
            set layoutcontroldb [$self cget -layoutdb]
            #$self putdebug "*** $self mkNewControl: layoutcontroldb is $layoutcontroldb"
            if {$layoutcontroldb eq {}} {return}
            set l [$layoutcontroldb getElementsByTagName layout]
            set new [$newControl draw -db $layoutcontroldb]
            if {$new eq {}} {return}
            set ee1 $fr.eventid1.value
            set ee2 $fr.eventid2.value
            [$new getElementsByTagName off -depth 1] setdata [$ee1 get]
            [$new getElementsByTagName on -depth 1] setdata [$ee2 get]
        }
        typevariable printexportfiletypes {
            {{PDF (printable) Files} {.pdf}     }
            {{XML             Files} {.xml}     }
            {{CSV (for Excel) Files} {.csv}     }
            {{Text            Files} {.txt} TEXT}
            {{All             Files} *          }
        }
        ## Print and Export file types.
        method _printexport {node frame name} {
            ## Print or export a segment or group.
            #
            # The current contents of the specified segment or group GUI frame
            # are exported to a data file for use in another program or printed.
            #
            # @param node The XML node in the CDI for the segment or group to 
            #             export or print.
            # @param frame The GUI frame containing the values to be exported
            #             or printed.
            # @param name The name of the segment or group to be exported or
            #             printed.
            
            $self putdebug "$self _printexport $node $frame $name"
            set outfile [tk_getSaveFile \
                         -defaultextension .txt \
                         -filetypes $printexportfiletypes \
                         -initialdir [pwd] \
                         -initialfile export.txt \
                         -parent [winfo toplevel $win] \
                         -title [_ {Select a file to export %s to} $name]]
            if {$outfile eq {}} {return}
            set extension [file extension $outfile]
            if {$extension eq {}} {set extension ".txt"}
            if {[lsearch {.pdf .xml .csv .txt} $extension] < 0} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Unknown file type: %s" $extension]
                return
            }
            $self _printexport[regsub {^\.} $extension {_}] $node $frame $name $outfile
        }
        method _printexport_pdf {node frame name outfile} {
            ## Export a segment or group to a printable PDF file
            #
            # @param node The XML node in the CDI for the segment or group to 
            #             export or print.
            # @param frame The GUI frame containing the values to be exported
            #             or printed.
            # @param name The name of the segment or group to be exported or
            #             printed.
            # @param outfile The file to export to.
            
            set pdfobj [::pdf4tcl::new %AUTO% -file $outfile \
                        -paper letter -orient false -margin .25i]
            $pdfobj startPage
            $pdfobj setFont 24 Courier
            set topy [lindex [$pdfobj getDrawableArea] 1]
            $pdfobj setTextPosition 0 $topy
            set header [_ "Export of %s" $name]
            $pdfobj text $header
            $pdfobj newLine 2
            set cury [expr {$topy - 48}]
            $pdfobj setFont 12 Courier
            set curpage 1
            _printexport_pdf_frame $node "" $pdfobj $frame cury curpage $header
            $pdfobj destroy
        }
        proc _printexport_pdf_frame {n indent pdfobj frame curyVar curpageVar pageheader} {
            ## Export a node frame to a PDF file.
            #
            # @param n The node.
            # @param indent The indentation string.
            # @param pdfobj The PDF file object.
            # @param frame The GUI frame.
            # @param curyVar The name of the variable containing the current y
            #                location.
            # @param curpageVar The name of the variable containing the current
            #                page number.
            # @param pageheader The running page header text.
            
            upvar $curyVar cury
            upvar $curpageVar curpage
            #$self putdebug "*** _printexport_pdf_frame $n \{$indent\} $pdfobj $frame $curyVar \{$pageheader\}"
            set gn 0
            switch [$n cget -tag] {
                segment {
                    if {$cury < 24} {
                        incr curpage
                        set cury [_printexport_pdf_newpage $pdfobj $pageheader $curpage]
                    }
                    set space [$n attribute space]
                    $pdfobj text [format {%sSegment[0x%02x]:} $indent $space]
                    $pdfobj newLine 1
                    set cury [expr {$cury - 12}]
                    if {[winfo exists $frame.descr]} {
                        $pdfobj text [format {%s  (%s)} $indent \
                                      [$frame.descr cget -text]]
                        $pdfobj newLine 1
                        set cury [expr {$cury - 12}]
                    }
                    set groupnotebook {}
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        switch $tag {
                            group {
                                if {$groupnotebook eq {}} {
                                    set groupnotebook $frame.groups
                                }
                                incr gn
                                set cframe $frame.[$c attribute gframe]
                                if {![winfo exists $cframe]} {
                                    set cframe $groupnotebook.group$gn
                                }
                                _printexport_pdf_frame $c "${indent}  " $pdfobj $cframe cury curpage $pageheader
                            }
                            int {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_pdf_vframe $c ${indent} $pdfobj $cframe cury curpage $pageheader
                            }
                            string {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_pdf_vframe $c ${indent} $pdfobj $cframe cury curpage $pageheader
                            }
                            eventid {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_pdf_vframe $c ${indent} $pdfobj $cframe cury curpage $pageheader
                            }
                            action {
                            }
                            blob {
                            }
                            
                        }
                    }
                }
                group {
                    if {$cury < 24} {
                        incr curpage
                        set cury [_printexport_pdf_newpage $pdfobj $pageheader $curpage]
                    }
                    if {[winfo class $frame] eq "TLabelframe"} {
                        $pdfobj text "$indent[$frame cget -text]:"
                        $pdfobj newLine 1
                        set cury [expr {$cury - 12}]
                    }
                    if {[winfo exists $frame.descr]} {
                        $pdfobj text "$indent[$frame.descr cget -text]:"
                        $pdfobj newLine 1
                        set cury [expr {$cury - 12}]
                    }
                    if {[winfo exists $frame.replnotebook]} {
                        ## whole set of replications
                        foreach tabframe [$frame.replnotebook tabs] {
                            if {$cury < 12} {
                                incr curpage
                                set cury [_printexport_pdf_newpage $pdfobj $pageheader $curpage]
                            }
                            $pdfobj text "$indent[$frame.replnotebook tab $tabframe -text]:"
                            $pdfobj newLine 1
                            set cury [expr {$cury - 12}]
                            _printexport_pdf_frame $n "${indent}  " $pdfobj $tabframe cury curpage $pageheader
                        }
                    } else {
                        #$self putdebug "*** _printexport_pdf_frame: frame = $frame, \[winfo children $frame\] = [winfo children $frame]"
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            
                            switch $tag {
                                group {
                                    incr gn
                                    set cframe $frame.[$c attribute gframe]
                                    if {![winfo exists $cframe]} {
                                        set cframe $frame.group$gn
                                    }
                                    _printexport_pdf_frame $c "${indent}  " $pdfobj $cframe cury curpage $pageheader
                                }
                                int {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_pdf_vframe $c ${indent} $pdfobj $cframe cury curpage $pageheader
                                }
                                string {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_pdf_vframe $c ${indent} $pdfobj $cframe cury curpage $pageheader
                                }
                                eventid {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_pdf_vframe $c ${indent} $pdfobj $cframe cury curpage $pageheader
                                }
                                action {
                                }
                                blob {
                                }
                            }
                        }
                    }
                }
            }
        }
        proc _printexport_pdf_vframe {n indent pdfobj frame curyVar curpageVar pageheader} {
            ## Export a node scaler value frame to a PDF file.
            #
            # @param n The node.
            # @param indent The indentation string.
            # @param pdfobj The PDF file object.
            # @param frame The GUI frame.
            # @param curyVar The name of the variable containing the current y
            #                location.
            # @param curpageVar The name of the variable containing the current
            #                page number.
            # @param pageheader The running page header text.
            
            #$self putdebug "*** _printexport_pdf_vframe $n \{$indent\} $pdfobj $frame $curyVar $curpageVar \{$pageheader\}"
            #$self putdebug "*** _printexport_pdf_vframe: frame is a [winfo class $frame]"
            upvar $curyVar cury
            upvar $curpageVar curpage
            if {$cury < 24} {
                incr curpage
                set cury [_printexport_pdf_newpage $pdfobj $pageheader $curpage]
            }
            
            if {[winfo class $frame] eq "TLabelframe"} {
                $pdfobj text "$indent[$frame cget -text]:"
                $pdfobj newLine 1
                set cury [expr {$cury - 12}]
            }
            if {[winfo exists $frame.descr]} {
                $pdfobj text "$indent[$frame.descr cget -text]: [$frame.value get]"
                $pdfobj newLine 1
                set cury [expr {$cury - 12}]
            } else {
                $pdfobj text "$indent[$frame.value get]"
                $pdfobj newLine 1
                set cury [expr {$cury - 12}]
            }
        }
        proc _printexport_pdf_newpage {pdfobj pageheader pageno} {
            ## Print a new PDF page.
            #
            # @param pdfobj The PDF file object
            # @param pageheader The running page header text.
            # @param pageno The new page's number.
            # @return The fresh current y value.
            
            # $self putdebug "*** _printexport_pdf_newpage $pdfobj \{$pageheader\} $pageno"
            $pdfobj startPage
            set topy [lindex [$pdfobj getDrawableArea] 1]
            $pdfobj setTextPosition 0 $topy
            $pdfobj text [_ {%s  Page %d} $pageheader $pageno]
            $pdfobj newLine 2
            set cury [expr {$topy - 24}]
            return $cury
        }
        method _printexport_xml {node frame name outfile} {
            ## Export a segment or group to an XML file
            #
            # @param node The XML node in the CDI for the segment or group to 
            #             export or print.
            # @param frame The GUI frame containing the values to be exported
            #             or printed.
            # @param name The name of the segment or group to be exported or
            #             printed.
            # @param outfile The file to export to.
            
            if {[catch {open $outfile w} outfp]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not open %s: %s" $outfile $outfp]
                return
            }
            set resultnode [SimpleDOMElement %AUTO% -tag export \
                            -attributes [list name $name]]
            $resultnode addchild [_printexport_xml_frame $node $frame]
            $resultnode display $outfp
            close $outfp
        }
        proc _printexport_xml_frame {n frame} {
            ## Export a node frame as an XML tree.
            #
            # @param n The XML node in the CDI.
            # @param frame The GUI frame for the node in the CDI.
            # @return An XML tree of the contents of the GUI frame.
            
            $self putdebug "*** _printexport_xml_frame $n \{$indent\} $outfp $frame"
            set gn 0
            switch [$n cget -tag] {
                segment {
                    set resultnode [SimpleDOMElement %AUTO% -tag segment \
                                    -attributes [$n cget -attributes] \
                                    -opts       [$n cget -opts]]
                    if {[winfo exists $frame.descr]} {
                        set descrnode [SimpleDOMElement %AUTO% -tag description]
                        $resultnode addchild $descrnode
                        $descrnode setdata [$frame.descr cget -text]
                    }
                    set groupnotebook {}
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        switch $tag {
                            group {
                                if {$groupnotebook eq {}} {
                                    set groupnotebook $frame.groups
                                }
                                incr gn
                                set cframe $frame.[$c attribute gframe]
                                if {![winfo exists $cframe]} {
                                    set cframe $groupnotebook.group$gn
                                }
                                $resultnode addchild [_printexport_xml_frame $c $cframe]
                            }
                            int {
                                set cframe $frame.[$c attribute vframe]
                                $resultnode addchild [_printexport_xml_vframe $c $cframe]
                            }
                            string {
                                set cframe $frame.[$c attribute vframe]
                                $resultnode addchild [_printexport_xml_vframe $c $cframe]
                            }
                            eventid {
                                set cframe $frame.string$sn
                                $resultnode addchild [_printexport_xml_vframe $c $cframe]
                            }
                            action {
                            }
                            blob {
                            }
                        }
                    }
                    return $resultnode
                }
                group {
                    set resultnode [SimpleDOMElement %AUTO% -tag group \
                                    -attributes [$n cget -attributes] \
                                    -opts       [$n cget -opts]]
                    if {[winfo class $frame] eq "TLabelframe"} {
                        set nametext [$frame cget -text]
                        set namenode [SimpleDOMElement %AUTO% -tag name]
                        $namenode setdata $nametext
                        $resultnode addchild $namenode
                    }
                    if {[winfo exists $frame.descr]} {
                        set descrtext [$frame.descr cget -text]
                        set descrnode [SimpleDOMElement %AUTO% -tag description]
                        $descrnode setdata $descrtext
                        $resultnode addchild $descrnode
                    }
                    if {[winfo exists $frame.replnotebook]} {
                        foreach tabframe [$frame.replnotebook tabs] {
                            set replnode [SimpleDOMElement %AUTO% -tag replication -attributes [list name [$frame.replnotebook tab $tabframe -text]]]
                            $resultnode addchild $replnode
                            $replnode addchild [_printexport_xml_frame $n $tabframe]
                        }
                    } else {
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            switch $tag {
                                group {
                                    incr gn
                                    set cframe $frame.[$c attribute gframe]
                                    if {![winfo exists $cframe]} {
                                        set cframe $frame.group$gn
                                    }
                                    $resultnode addchild [_printexport_xml_frame $c $cframe]
                                }
                                int {
                                    set cframe $frame.[$c attribute vframe]
                                    $resultnode addchild [_printexport_xml_vframe $c $cframe]
                                }
                                string {
                                    set cframe $frame.[$c attribute vframe]
                                    $resultnode addchild [_printexport_xml_vframe $c $cframe]
                                }
                                eventid {
                                    set cframe $frame.[$c attribute vframe]
                                    $resultnode addchild [_printexport_xml_vframe $c $cframe]
                                }
                                action {
                                }
                                blob {
                                }
                            }
                        }
                    }
                    return $resultnode
                }
            }
        }
        proc _printexport_xml_vframe {n frame} {
            ## Export a scaler node's value frame as an XML tree.
            #
            # @param n The XML node in the CDI.
            # @param frame The GUI frame for the node in the CDI.
            # @return An XML tree of the contents of the GUI frame.
            
            set resultnode [SimpleDOMElement %AUTO% -tag [$n cget -tag] \
                            -attributes [$n cget -attributes] \
                            -opts       [$n cget -opts]]
            if {[winfo class $frame] eq "TLabelframe"} {
                set nametext [$frame cget -text]
                set namenode [SimpleDOMElement %AUTO% -tag name]
                $namenode setdata $nametext
                $resultnode addchild $namenode
            }
            if {[winfo exists $frame.descr]} {
                set descrtext [$frame.descr cget -text]
                set descrnode [SimpleDOMElement %AUTO% -tag description]
                $descrnode setdata $descrtext
                $resultnode addchild $descrnode
            }
            set value [$frame.value get]
            set valuenode [SimpleDOMElement %AUTO% -tag value]
            $valuenode setdata $value
            $resultnode addchild $valuenode
            return $resultnode
        }
                        
        method _printexport_csv {node frame name outfile} {
            ## Export a segment or group to a CSV file (can be imported into 
            #   Excel).
            #
            # @param node The XML node in the CDI for the segment or group to 
            #             export or print.
            # @param frame The GUI frame containing the values to be exported
            #             or printed.
            # @param name The name of the segment or group to be exported or
            #             printed.
            # @param outfile The file to export to.
            
            if {[catch {open $outfile w} outfp]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not open %s: %s" $outfile $outfp]
                return
            }
            set matrix [::struct::matrix]
            $matrix add columns 2;# Initially assume 2 columns (name,value)
            $matrix add row [list $name]
            _printexport_csv_frame $node $matrix $frame
            ::csv::writematrix $matrix $outfp
            close $outfp
            $matrix destroy
        }
        proc _printexport_csv_frame {n matrix frame} {
            ## Add a node's GUI frame values to a matrix (to be exported as a 
            # CSV file).
            #
            # @param n The node in the CDI XML tree.
            # @param matrix The matrix to populate.
            # @param frame The GUI frame to extract values from.
            
            set gn 0
            switch [$n cget -tag] {
                segment {
                    set space [$n attribute space]
                    $matrix add row [list space $space]
                    if {[winfo exists $frame.descr]} {
                        $matrix add row [list [$frame.descr cget -text]]
                    }
                    set groupnotebook {}
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        switch $tag {
                            group {
                                if {$groupnotebook eq {}} {
                                    set groupnotebook $frame.groups
                                }
                                incr gn
                                set cframe $frame.[$c attribute gframe]
                                if {![winfo exists $cframe]} {
                                    set cframe $groupnotebook.group$gn
                                }
                                _printexport_csv_frame $c $matrix $cframe
                            }
                            int {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_csv_vframe $c $matrix $cframe
                            }
                            string {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_csv_vframe $c $matrix $cframe
                            }
                            eventid {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_csv_vframe $c $matrix $cframe
                            }
                            action {
                            }
                            blob {
                            }
                            
                        }
                    }
                }
                group {
                    if {[winfo class $frame] eq "TLabelframe"} {
                        $matrix add row [list [$frame cget -text]]
                    }
                    if {[winfo exists $frame.descr]} {
                        $matrix add row [list [$frame.descr cget -text]]
                    }
                    if {[winfo exists $frame.replnotebook]} {
                        ## whole set of replications
                        set tabs [$frame.replnotebook tabs]
                        ## Todo: Check for nested replnotebooks!
                        if {[llength $tabs] <= 4} {
                            _printexport_csv_framesAcross $n $frame.replnotebook $tabs $matrix
                        } else {
                            foreach tabframe $tabs {
                                $matrix add row [list [$frame.replnotebook tab $tabframe -text]]
                                _printexport_csv_frame $n $matrix $tabframe
                            }
                        }
                    } else {
                        #$self putdebug "*** _printexport_csv_frame: frame = $frame, \[winfo children $frame\] = [winfo children $frame]"
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            
                            switch $tag {
                                group {
                                    incr gn
                                    set cframe $frame.[$c attribute gframe]
                                    if {![winfo exists $cframe]} {
                                        set cframe $frame.group$gn
                                    }
                                    _printexport_csv_frame $c $matrix $cframe
                                }
                                int {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_csv_vframe $c $matrix $cframe
                                }
                                string {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_csv_vframe $c $matrix $cframe
                                }
                                eventid {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_csv_vframe $c $matrix $cframe
                                }
                                action {
                                }
                                blob {
                                }
                            }
                        }
                    }
                }
            }
        }
        proc _printexport_csv_vframe {n matrix frame} {
            ## Add a scaler node's GUI value frame values to a matrix (to be 
            # exported as a CSV file).
            #
            # @param n The node in the CDI XML tree.
            # @param matrix The matrix to populate
            # @param frame The GUI frame to extract values from.
            
            
            if {[winfo class $frame] eq "TLabelframe"} {
                $matrix add row [list [$frame cget -text]]
            }
            if {[winfo exists $frame.descr]} {
                $matrix add row [list [$frame.descr cget -text] [$frame.value get]]
            } else {
                $matrix add row [list [$frame.value get]]
            }
        }
        proc _printexport_csv_framesAcross {n tabnb tabs matrix} {
            ## Add a replicated group to a matrix as a single row.
            #
            # @param n The node in the CDI XML tree.
            # @param tabnb Tabbed notebook containing the replicated group.
            # @param tabs The tabs in the tabbed notebook (the replications).
            # @param matrix The matrix to populate.
            
            #$self putdebug "*** _printexport_csv_framesAcross $n $tabnb $tabs $matrix"
            set row [list]
            set cols [$matrix columns]
            foreach tabframe $tabs {
                lappend row [$tabnb tab $tabframe -text]
                _printexport_csv_frameAcross $n row $tabframe
            }
            set morecols [expr {[llength $row] - $cols}]
            if {$morecols > 0} {$matrix add columns $morecols}
            $matrix add row $row
        }
        proc _printexport_csv_frameAcross {n rowVar frame} {
            ## Add a group to a matrix as elements to a single row.
            #
            # @param n The node in the CDI XML tree.
            # @param rowVar The name of the variable containing the row to add 
            #               to.
            # @param frame The GUI frame.
            
            #$self putdebug "*** _printexport_csv_frameAcross $n $rowVar $frame"
            upvar $rowVar row
            #$self putdebug "*** _printexport_csv_frameAcross: row is $row"
            set gn 0
            switch [$n cget -tag] {
                group {
                    if {[winfo class $frame] eq "TLabelframe"} {
                        lappend row [$frame cget -text]
                    }
                    if {[winfo exists $frame.descr]} {
                        lappend row [$frame.descr cget -text]
                    }
                    if {[winfo exists $frame.replnotebook]} {
                        error [_ "Yikes!!, a replication in a short replication -- can't handle that!"]
                        return 
                    }
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                        switch $tag {
                            group {
                                incr gn
                                set cframe $frame.[$c attribute gframe]
                                if {![winfo exists $cframe]} {
                                    set cframe $frame.group$gn
                                }
                                _printexport_csv_frameAcross $c row $cframe
                            }
                            int {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_csv_vframeAcross $c row $cframe
                            }
                            string {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_csv_vframeAcross $c row $cframe
                            }
                            eventid {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_csv_vframeAcross $c row $cframe
                            }
                            action {
                            }
                            blob {
                            }
                        }
                        #$self putdebug "*** _printexport_csv_frameAcross (after child): row is $row"
                    }
                }
            }
        }
        proc _printexport_csv_vframeAcross {n rowVar frame} {
            ## Add a scaler node's value frame to a matrix as elements to a 
            #  single row.
            #
            # @param n The node in the CDI XML tree.
            # @param rowVar The name of the variable containing the row to add
            #               to.
            # @param frame The GUI frame.
            
            #$self putdebug "*** _printexport_csv_vframeAcross $n $rowVar $frame"
            upvar $rowVar row
            #$self putdebug "*** _printexport_csv_vframeAcross: row is $row"
            if {[winfo class $frame] eq "TLabelframe"} {
                lappend row [$frame cget -text]
            }
            if {[winfo exists $frame.descr]} {
                lappend row [$frame.descr cget -text] [$frame.value get]
            } else {
                lappend row [$frame.value get]
            }
            #$self putdebug "*** _printexport_csv_vframeAcross (after value added): row is $row"
        }
        
        method _printexport_txt {node frame name outfile} {
            ## Export a segment or group to a text file
            #
            # @param node The XML node in the CDI for the segment or group to 
            #             export or print.
            # @param frame The GUI frame containing the values to be exported
            #             or printed.
            # @param name The name of the segment or group to be exported or
            #             printed.
            # @param outfile The file to export to.
            
            $self putdebug "*** $self _printexport_txt $node $frame $name $outfile"
            if {[catch {open $outfile w} outfp]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not open %s: %s" $outfile $outfp]
                return
            }
            puts $outfp [_ "Export of %s" $name]
            _printexport_txt_frame $node "" $outfp $frame
            close $outfp
        }
        proc widget_children_tails {w} {
            set result [list]
            foreach c [winfo children $w] {
                lappend result [string range $c [expr {[string length $w]+1}] end]
            }
            return $result
        }
        proc _printexport_txt_frame {n indent outfp frame} {
            ## Export a segment or group frame to a text file.
            #
            # @param n The node.
            # @param indent The indentation string.
            # @param outfp The output file channel.
            # @param frame The GUI frame.
            
            #$self putdebug "*** _printexport_txt_frame $n \{$indent\} $outfp $frame"
            set gn 0
            switch [$n cget -tag] {
                segment {
                    set space [$n attribute space]
                    puts $outfp [format {%sSegment[0x%02x]:} $indent $space]
                    if {[winfo exists $frame.descr]} {
                        puts $outfp [format {%s  (%s)} $indent \
                                     [$frame.descr cget -text]]
                    }
                    set groupnotebook {}
                    foreach c [$n children] {
                        set tag [$c cget -tag]
                        if {[lsearch {name description} $tag] >= 0} {continue}
                        switch $tag {
                            group {
                                if {$groupnotebook eq {}} {
                                    set groupnotebook $frame.groups
                                }
                                incr gn
                                set cframe $frame.[$c attribute gframe]
                                if {![winfo exists $cframe]} {
                                    set cframe $groupnotebook.group$gn
                                }
                                _printexport_txt_frame $c "${indent}  " $outfp $cframe
                            }
                            int {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_txt_vframe $c ${indent} $outfp $cframe
                            }
                            string {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_txt_vframe $c ${indent} $outfp $cframe
                            }
                            eventid {
                                set cframe $frame.[$c attribute vframe]
                                _printexport_txt_vframe $c ${indent} $outfp $cframe
                            }
                            action {
                            }
                            blob {
                            }
                        }
                    }
                }
                group {
                    if {[winfo class $frame] eq "TLabelframe"} {
                        puts $outfp "$indent[$frame cget -text]:"
                    }
                    if {[winfo exists $frame.descr]} {
                        puts $outfp "$indent[$frame.descr cget -text]:"
                    }
                    if {[winfo exists $frame.replnotebook]} {
                        ## whole set of replications
                        foreach tabframe [$frame.replnotebook tabs] {
                            puts $outfp "$indent[$frame.replnotebook tab $tabframe -text]:"
                            _printexport_txt_frame $n "${indent}  " $outfp $tabframe
                        }
                    } else {
                        #$self putdebug "*** _printexport_txt_frame: frame = $frame"
                        #$self putdebug "*** _printexport_txt_frame: children of $frame: [widget_children_tails $frame]"
                        #$self putdebug "*** _printexport_txt_frame: children of $n: [$n children]"
                        #$self putdebug "*** _printexport_txt_frame: attributes of $n: [$n cget -attributes]"
                        foreach c [$n children] {
                            set tag [$c cget -tag]
                            if {[lsearch {name description repname hints} $tag] >= 0} {continue}
                            #puts stderr "*** _printexport_txt_frame: tag = $tag, c = $c, attributes of $c are [$c cget -attributes]"
                            switch $tag {
                                group {
                                    incr gn
                                    set cframe $frame.[$c attribute gframe]
                                    if {![winfo exists $cframe]} {
                                        set cframe $frame.group$gn
                                    }
                                    #puts stderr "*** _printexport_txt_frame: gn is $gn, gframe attribute of $n is [$n attribute gframe], cframe is $cframe"
                                    _printexport_txt_frame $c "${indent}  " $outfp $cframe
                                }
                                int {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_txt_vframe $c ${indent} $outfp $cframe
                                }
                                string {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_txt_vframe $c ${indent} $outfp $cframe
                                }
                                eventid {
                                    set cframe $frame.[$c attribute vframe]
                                    _printexport_txt_vframe $c ${indent} $outfp $cframe
                                }
                                action {
                                }
                                blob {
                                }
                            }
                        }
                    }
                }
                
            }
        }
        proc _printexport_txt_vframe {n indent outfp frame} {
            ## Export a node scaler value frame to a text file.
            #
            # @param n The node.
            # @param indent The indentation string.
            # @param outfp The output channel.
            # @param frame The GUI frame.
            
            #puts stderr "*** _printexport_txt_vframe $n \{$indent\} $outfp $frame"
            #puts stderr "*** _printexport_txt_vframe: frame is a [winfo class $frame]"
            if {[winfo class $frame] eq "TLabelframe"} {
                puts $outfp "$indent[$frame cget -text]:"
            }
            if {[winfo exists $frame.descr]} {
                puts $outfp "$indent[$frame.descr cget -text]: [$frame.value get]"
            } else {
                puts $outfp "$indent[$frame.value get]"
            }
        }
        method _close {} {
            ## @brief Close the window. 
            # The window is destroyed
            destroy $win
        }
        variable olddatagramhandler {}
        ## Variable holding the old Datagram handler.
        variable datagrambuffer {}
        ## Datagram buffer.
        variable _datagramrejecterror 0
        ## Datagram reject error flag.
        variable writeReplyCheck no
        ## Datagram write trply check flag.
        method _datagramhandler {command sourcenid args} {
            ## Datagram handler.
            #
            # @param command Type of Datagram handling.
            # @param sourcenid Source NID of the datagram.
            # @param ... The datagram data stream.
            
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
            ## Read memory from a space.
            #
            # @param space The space to read from.
            # @param address The start address to read.
            # @param length Number of bytes to read.
            # @param status_var The name of a variable to receive the status 
            # code.
            # @returns The data read (if successful).
            
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
            if {[llength $datagrambuffer] > 1} {
                set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
                set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
                set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
                set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
                if {$respaddr != $address} {
                    ## wrong address...
                }
            } else {
                puts stderr "*** $self _readmemory: short read? datagrambuffer is $datagrambuffer"
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
            ## Write to configuration memory.
            #
            # @param space The space to write to.
            # @param address The address to write to.
            # @param databuffer The data to write.
            # @return The write status.
            
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
            if {[llength $datagrambuffer] > 1} {
                set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
                set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
                set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
                set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
                if {$respaddr != $address} {
                    ## wrong address...
                }
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
            ## Read an integer value and map it to a ComboBox widget.
            #
            # @param widget A ttk::combobox widget to update.  This is also 
            #        used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            
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
            ## Write an integer value maped from a ComboBox widget.
            #
            # @param widget A ttk::combobox widget to get the value from.  
            #        This is also used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            # @param min The minimum allowed value of the integer.
            # @param max The maximum allowed value of the integer.
            
            upvar #0 ${widget}_VM valuemap
            set value $valuemap([$widget get])
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
        method _intRBRead {widget space address size} {
            ## Read an integer value and stash it in a Radiobutton group
            #
            # @param widget A ttk::frame widget containing ttk::radiobuttons.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            
            upvar #0 ${widget}_value rbvalue
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK 
                set value 0
                foreach b $data {
                    set value [expr {($value << 8) | $b}]
                }
                set rbvalue $value
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
        method _intRBWrite {widget space address size min max} {
            ## Write an integer value maped from a Radiobutton group.
            #
            # @param widget A ttk::combobox widget to get the value from.  
            #        This is also used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            # @param min The minimum allowed value of the integer.
            # @param max The maximum allowed value of the integer.
            
            upvar #0 ${widget}_value rbvalue
            set value rbvalue
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
        method _intCBRead {widget space address size} {
            ## Read an integer value and stash it in a Checkbutton widget.
            #
            # @param widget A ttk::checkbutton widget.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            
            set var [$widget cget -variable]
            upvar #0 $var v
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK 
                set value 0
                foreach b $data {
                    set value [expr {($value << 8) | $b}]
                }
                set v $value
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
        method _intCBWrite {widget space address size min max} {
            ## Write an integer value maped from a Checkbutton widget
            #
            # @param widget A ttk::combobox widget to get the value from.  
            #        This is also used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            # @param min The minimum allowed value of the integer.
            # @param max The maximum allowed value of the integer.
            
            set var [$widget cget -variable]
            upvar #0 $var value
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
        method _intScaleRead {widget space address size} {
            ## Read an integer value and stash it in a Scale widget.
            #
            # @param widget A ttk::scale widget.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK 
                set value 0
                foreach b $data {
                    set value [expr {($value << 8) | $b}]
                }
                $widget configure -value $value
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
        method _intScaleWrite {widget space address size min max} {
            ## Write an integer value maped from a Scale widget
            #
            # @param widget A ttk::combobox widget to get the value from.  
            #        This is also used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            # @param min The minimum allowed value of the integer.
            # @param max The maximum allowed value of the integer.
            
            set value [$widget cget -value]
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
            ## Read an integer value and stash it in a SpinBox widget.
            #
            # @param widget A spinbox widget to update.
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            
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
            ## Write an integer value maped from a SpinBox widget.
            #
            # @param widget A spinbox widget to get the value from.  
            # @param space The space to read from.
            # @param address The address of the integer.
            # @param size The size of the integer.
            # @param min The minimum allowed value of the integer.
            # @param max The maximum allowed value of the integer.
            
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
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
        method _actionWrite {widget space address size value dislogText} {
            ## Write an integer value from an Action button.
            #
            # @param widget A ttk::button widget
            # @param space The space to write to.
            # @param address The address of the integer.
            # @param size The size of the integer.
            # @param value The value to write
            # @param dislogText The dialog text to display after writing
            
            set data [list]
            for {set shift [expr {($size - 1) * 8}]} {$shift >= 0} {incr shift -8} {
                lappend data [expr {($value >> $shift) & 0xFF}]
            }
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
            if {$dialogText ne ""} {
                tk_messageBox -icon info -message $dialogText -type ok
            }
        }
        method _stringComboRead {widget space address size} {
            ## Read a string value and map it to a ComboBox widget.
            #
            # @param widget A ttk::combobox widget to update.  This is also 
            #        used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the string.
            # @param size The size of the string.
            
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
            ## Write a string value maped from a ComboBox widget.
            #
            # @param widget A ttk::combobox widget to get the value from.  
            #        This is also used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the string.
            # @param size The size of the string.
            
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
                if {[llength $retdata] <= 1} {
                    if {$retdata eq {} || $retdata == 0} {
                        ## OK
                        $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
            ## Read a string value and stash it in an Entry widget.
            #
            # @param widget A ttk::entry widget to update.
            # @param space The space to read from.
            # @param address The address of the string.
            # @param size The size of the string.
            
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
            ## Write a string value from an Entry widget.
            #
            # @param widget A ttk::entry widget to get the value from.  
            # @param space The space to read from.
            # @param address The address of the string.
            # @param size The size of the string.
            
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
                if {[llength $retdata] <= 1} {
                    if {$retdata eq {} || $retdata == 0} {
                        ## OK
                        $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
            ## Read an event id value and map it to a ComboBox widget.
            #
            # @param widget A ttk::combobox widget to update.  This is also 
            #        used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the event id.
            # @param size The size of the event id (should always be 8).
            
            upvar #0 ${widget}_VM valuemap
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK
                if {[llength $data] > $size} {
                    set data [lrange $data 0 [expr {$size - 1}]]
                }
                set evid [lcc::EventID %AUTO% -eventidlist $data]
                set value [$evid cget -eventidstring]
                $evid destroy
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
            ## Write an event id value maped from a ComboBox widget.
            #
            # @param widget A ttk::combobox widget to get the value from.  
            #        This is also used to map to the value map.
            # @param space The space to read from.
            # @param address The address of the event id.
            # @param size The size of the event id (should always be 8).
            
            upvar #0 ${widget}_VM valuemap
            set evid [lcc::EventID %AUTO% -eventidstring $valuemap([$widget get])]
            set data [$evid cget -eventidlist]
            $evid destroy
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
            ## Read an event id value and stash it in an Entry widget as an 
            #  event id string.
            #
            # @param widget A ttk::entry widget to update.
            # @param space The space to read from.
            # @param address The address of the event id.
            # @param size The size of the event id (should always be 8).
            
            set data [$self _readmemory $space $address $size status]
            if {$status == 0x50} {
                # OK
                if {[llength $data] > $size} {
                    set data [lrange $data 0 [expr {$size - 1}]]
                }
                set evid [lcc::EventID %AUTO% -eventidlist $data]
                set value [$evid cget -eventidstring]
                $evid destroy
                $type DeleteEventUse [$widget get] $widget
                $widget delete 0 end
                $widget insert end $value
                $type AddEventUse $value $widget
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
            ## Write an event id value from an Entry widget.
            #
            # @param widget A ttk::entry widget to get the value from.  
            # @param space The space to read from.
            # @param address The address of the event id.
            # @param size The size of the event id (should always be 8).
            
            set evid [lcc::EventID %AUTO% -eventidstring [$widget get]]
            set data [$evid cget -eventidlist]
            $evid destroy
            set retdata [$self _writememory $space $address $data]
            if {[llength $retdata] <= 1} {
                if {$retdata eq {} || $retdata == 0} {
                    ## OK
                    $widget configure -style [regsub {Mod$} [$widget cget -style] {}]
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
            ## Read all parameters stored in a specified space.
            #
            # Reads each parameter one at a time by invoking the parameter's 
            # @c Read button.
            #
            # @param space The parameter space to read from.
            
            if {![catch {set _readall($space)} rbs]} {
                $readallProgressDialog withdraw
                $readallProgressDialog draw -parent $win \
                      -totalitems [llength $rbs] -space $space
                set count 0
                $readallProgressDialog Update $count
                foreach rb $rbs {
                    $rb invoke
                    incr count
                    #puts stderr "*** $self _readall: count = $count"
                    if {($count % 50) == 0} {
                        $readallProgressDialog Update $count
                    }
                }
                $readallProgressDialog Update $count
                $readallProgressDialog Done
            }
        }
    }
}

package provide ConfigurationEditor 1.0



