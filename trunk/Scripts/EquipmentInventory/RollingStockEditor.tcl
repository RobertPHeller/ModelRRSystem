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
#  Last Modified : <210802.1714>
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

package require Tk
package require tile
package require Dialog
package require LabelFrames
package require ButtonBox

snit::widgetadaptor RollingStockEntryEditor {
    component reportingMarksLE
    variable reportingMarks_ {}
    component numberLE
    variable number_ 0
    component typeLECB
    variable type_ {}
    typevariable  types_ [list]
    component descriptionLE
    variable description_ {}
    component lengthLSB
    variable length_ 1
    component clearanceLE
    variable clearance_ {}
    component weightClassLE
    variable weightClass_ {}
    component emptyWeightLSB
    variable emptyWeight_ 1
    component loadedWeightLSB
    variable loadedWeight_ 1
    component imageFileFE
    variable imageFile_ {}
    component valueLSB
    variable value_ 0.00
    component purchaseCostLSB
    variable purchaseCost_ 0.00
    component manufacturerNameLECB
    variable manufacturerName_ {}
    typevariable manufacturerNames_ [list]
    component manufacturerPartNumberLE
    variable manufacturerPartNumber_ {}
    component scaleLCB
    variable scale_ H0
    typevariable scales_ [list Z N TT H0 0 1 G]
    option -record -default {}
    delegate option -parent to haul
    delegate option -modal  to hull
    option -edit -type snit::boolean -default no
    typevariable gensym_ 0
    typevariable availableDialogs_ [list]
    constructor {args} {
        installhull using Dialog -bitmap questhead -default add \
              -cancel cancel -transient yes \
              -side bottom -title [_ "Add or edit rolling stock"] \
              -parent [from args -parent]
        $hull add add    -text [_m "Label|Add"]    -command [mymethod _Add]
        $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install reportingMarksLE using LabelEntry $win.reportingMarksLE \
              -textvariable [myvar reportingMarks_]
        pack $reportingMarksLE -fill x
        install numberLE using LabelEntry $win.numberLE \
              -textvariable [myvar number_]
        pack $numberLE -fill x
        install typeLECB using LabelComboBox $win.typeLECB \
              -textvariable [myvar type_] -values $types_
        pack $typeLECB -fill x
        install descriptionLE using LabelEntry $win.descriptionLE \
              -textvariable [myvar description_]
        pack $descriptionLE -fill x
        install lengthLSB using LabelSpinBox $win.lengthLSB \
              -textvariable [myvar length_] -range {1 400 1}
        pack $lengthLSB -fill x
        install clearanceLE using LabelEntry $win.clearanceLE \
              -textvariable [myvar clearance_]
        pack $clearanceLE -fill x
        install weightClassLE using LabelEntry $win.weightClassLE \
              -textvariable [myvar weightClass_]
        pack $weightClassLE -fill x
        install emptyWeightLSB using LabelSpinBox $win.emptyWeightLSB \
              -textvariable [myvar emptyWeight_] -range {1 400 1}
        pack $emptyWeightLSB -fill x
        install loadedWeightLSB using LabelSpinBox $win.loadedWeightLSB \
              -textvariable [myvar loadedWeight_] -range {1 400 1}
        pack $loadedWeightLSB -fill x
        install imageFileFE using FileEntry $win.imageFileFE \
              -textvariable [myvar imageFile_]
        pack $imageFileFE -fill x
        install valueLSB using LabelSpinBox $win.valueLSB \
              -textvariable [myvar value_] -range {.01 300.00 .10}
        pack $valueLSB -fill x
        install purchaseCostLSB using LabelSpinBox $win.purchaseCostLSB \
              -textvariable [myvar purchaseCost_] -range {.01 300.00 .10}
        pack $purchaseCostLSB -fill x
        install manufacturerNameLECB using LabelComboBox $win.manufacturerNameLECB \
              -textvariable [myvar manufacturerName_] \
              -values $manufacturerNames_
        pack $manufacturerNameLECB -fill x
        install manufacturerPartNumberLE using LabelEntry $win.manufacturerPartNumberLE \
              -textvariable [myvar manufacturerPartNumber_]
        pack $manufacturerPartNumberLE -fill x
        install scaleLCB using LabelComboBox $win.scaleLCB \
              -textvariable [myvar scale_] -editable no \
              -values $scales_
        pack $scaleLCB -fill x
        $self configurelist $args
        lappend $win availableDialogs_
    }
    typemethod DialogFactory {args} {
        if {[llength $availableDialogs_] == 0} {
            incr gensym_
            eval [list $type create .rollingStockEntryEditor${gensym_}] $args
        }
        set result [lindex $availableDialogs_ 0]
        set availableDialogs_ [lrange $availableDialogs_ 1 end]
        return $result
    }
    method draw {args} {
        $self configurelist $args
        $typeLECB configure -values $types_
        $manufacturerNameLECB configure -values $manufacturerNames_
        if {[$self cget -edit]} {
            set record [$self cget -record]
            RollingStock validate $record
            lassign $record reportingMarks_ number_ type_ description_ \
                  length_ clearance_ weightClass_ emptyWeight_ loadedWeight_ \
                  imageFile_ value_ purchaseCost_ manufacturerName_ \
                  manufacturerPartNumber_ scale_
            $reportingMarksLE configure -editable no
            $numberLE configure -editable no
            $hull itemconfigure add -text [_m "Button|Update"]
            $hull configure -title [_ "Edit Rolling Stock Item"]
        } else {
            $reportingMarksLE configure -editable yes
            $numberLE configure -editable yes
            $hull itemconfigure add -text [_m "Button|Add"]
            $hull configure -title [_ "Add Rolling Stock Item"]
        }
        $hull draw
    }
    method _add {} {
        if {[$self cget -edit]} {
            set result [$self cget -record]
            $result SetType $type_
            $result SetDescription $description_
            $result SetLength $length_
            $result SetClearence $clearance_
            $result SetWeightClass $weightClass_ 
            $result SetEmptyWeight_ $emptyWeight_ 
            $result SetLoadedWeight $loadedWeight_ 
            $result SetImageFile_ $imageFile_ 
            $result SetValue $value_ 
            $result SetPurchaseCost $purchaseCost_ 
            $result SetManufacturerName $manufacturerName_ 
            $result SetManufacturerPartNumber $manufacturerPartNumber_ 
            $result SetScale $scale_
        } else {
            set result [RollingStock create %AUTO% [list $reportingMarks_ \
                                                    $number_ $type_ \
                                                    $description_ \
                                                    $length_ $clearance_ \
                                                    $weightClass_ \
                                                    $emptyWeight_ \
                                                    $loadedWeight_ \
                                                    $imageFile_ $value_ \
                                                    $purchaseCost_ \
                                                    $manufacturerName_ \
                                                    $manufacturerPartNumber_ \
                                                    $scale_]]
        $hull withdraw
        lappend availableDialogs_ $win
        if {[lsearch -exact $types_ $type_] < 0} {
            lappend types_ $type_
        }
        if {[lsearch -exact $manufacturerNames_ $manufacturerName_] < 0} {
            lappend manufacturerNames_ $manufacturerName_
        }
        return [$hull enddialog $result]
    }
    method _Cancel {} {
        $hull withdraw
        lappend availableDialogs_ $win
        return [$hull enddialog {}]
    }
}

        
package provide RollingStockEditor 1.0
