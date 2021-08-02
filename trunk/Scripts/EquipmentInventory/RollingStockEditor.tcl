#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Aug 2 11:05:53 2021
#  Last Modified : <210802.1438>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2021  Robert Heller D/B/A Deepwoods Software
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


package require snit
package require gettext

package require Tk
package require tile

snit::widgetadaptor RollingStockEditor {
    delegate option * to hull except {-class -style -columns -displaycolumns 
        -show}
    delegate method * to hull except {bbox cget configure delete
        detach exists index insert instate move next parent 
        prev set state tag}
    typevariable Columns -array {
        reportingMarks {-anchor w -minwidth 100 -stretch no -width 100}
        number         {-anchor w -minwidth 100 -stretch no -width 100}
        type           {-anchor w -minwidth 100 -stretch no -width 100}
        scale          {-anchor w -minwidth 50  -stretch no -width 50}
        description    {-anchor w -stretch yes}
    }
    typevariable Headings -array {
        reportingMarks {-text "Marks"       -anchor w}
        number         {-text "Number"      -anchor w}
        type           {-text "Type"        -anchor w}
        scale          {-text "Scale"       -anchor w}
        description    {-text "Description" -anchor w}
    }
    constructor {args} {
        installhull using ttk::treeview -columns {reportingMarks number type 
            description length clearance weightClass emptyWeight loadedWeight 
            imageFile value purchaseCost manufacturerName 
            manufacturerPartNumber scale} \
              -displaycolumns {reportingMarks number type scale description} \
              -selectmode browse -show {headings}
        $self configurelist $args
        foreach c [array names Columns] {
            eval [list $hull column $c] $Columns($c)
        }
        foreach h [array names Headings] {
            eval [list $hull heading $h] $Headings($h)
        }
        $self Refresh
        $hull tag bind item <ButtonPress-3> [mymethod itemContextMenu_ %x %y %X %Y]
        $hull tag bind item <KeyPress-Delete> [mymethod itemDeleteC_ %x %y]
        $hull tag bind item <KeyPress-e> [mymethod itemEditC_ %x %y]
        $hull tag bind item <KeyPress-E> [mymethod itemEditC_ %x %y]
    }
    method Refresh {} {
        $hull delete [$hull children {}]
        foreach i [RollingStock SortedIndexes] {
            $self insert_ [RollingStock Index $i]
        }
    }
    method insert_ {record {where end}} {
        RollingStock validate $record
        if {[$hull exists $record]} {return}
        $hull insert {} $where -id $record -values [$record RecordAsList] \
              -tag item
    }
    method add {record} {
        set pos 0
        foreach c [$hull children] {
            if {[$c CompareTo $record] < 0} {
                set pos [$hull index $c]
            } else {
                break
            }
        }
        $self insert_ $record $pos
    }
    method update {record} {
        if {[$hull exists $record]} {
            $hull item $record -values [$record RecordAsList]
        } else {
            $self add $record
        }
    }
    method delete {record} {
        RollingStock validate $record
        if {![$hull exists $record]} {return}
        $hull delete $record
        $record destroy
    }
    typevariable menu_ 0
    method itemContextMenu_ {x y X Y} {
        set item [$hull identify item $x $y]
        puts stderr "*** $self itemContextMenu_ ($x,$y): $item"
        if {$item eq ""} {return}
        incr menu_
        set m [menu $win.cmenu${menu_} -tearoff no]
        $m add command -label [_m "Menu|Edit"] -command [mymethod itemEdit_ $item]
        $m add command -label [_m "Menu|Delete"] -command [mymethod itemDelete_ $item]
        $m add command -label [_m "Menu|Dismis"] -command "$m unpost;destroy $m"
        $m post $X $Y
    }
    method itemDeleteC_ {x y} {
        set item [$hull identify item $x $y]
        puts stderr "*** $self itemDeleteC_ ($x,$y): $item"
        if {$item eq ""} {return}
        $self itemDelete_ $item
    }
    method itemDelete_ {item} {
        puts stderr "*** $self itemDelete_ \{$item\}"
        $self delete $item
    }
    method itemEditC_ {x y} {
        set item [$hull identify item $x $y]
        puts stderr "*** $self itemEditC_ ($x,$y): $item"
        if {$item eq ""} {return}
        $self itemEdit_ $item
    }
    method itemEdit_ {item} {
        puts stderr "*** $self itemEdit_ \{$item\}"
    }
}

package provide RollingStockEditor 1.0
