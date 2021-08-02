#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Aug 1 21:43:47 2021
#  Last Modified : <210802.1600>
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


package require csv
package require snit
package require gettext



snit::type RollingStock {
    variable reportingMarks_
    method ReportingMarks {} {return $reportingMarks_}
    variable number_
    method Number {} {return $number_}
    variable type_
    method Type {} {return $type_}
    method SetType {newtype} {
        set type_ $newtype
    }
    variable description_
    method Description {} {return $description_}
    method SetDescription {newdescription} {
        set description_ $newdescription
    }
    variable length_
    method Length {} {return $length_}
    method SetLength {newlength} {
        set length_ $newlength
    }
    variable clearance_
    method Clearance {} {return $clearance_}
    method SetClearance {newclearance} {
        set clearance_ $newclearance
    }
    variable weightClass_
    method WeightClass {} {return $weightClass_}
    method SetWeightClass {newweightClass} {
        set weightClass_ $newweightClass
    }
    variable emptyWeight_
    method EmptyWeight {} {return $emptyWeight_}
    method SetEmptyWeight {newemptyWeight} {
        set emptyWeight_ $newemptyWeight
    }
    variable loadedWeight_
    method LoadedWeight {} {return $loadedWeight_}
    method SetLoadedWeight {newloadedWeight} {
        set loadedWeight_ $newloadedWeight
    }
    variable imageFile_
    method ImageFile {} {return $imageFile_}
    method SetImageFile {newimageFile} {
        set imageFile_ $newimageFile
    }
    variable value_
    method Value {} {return $value_}
    method SetValue {newvalue} {
        set value_ $newvalue
    }
    variable purchaseCost_
    method PurchaseCost {} {return $purchaseCost_}
    method SetPurchaseCost {newpurchaseCost} {
        set purchaseCost_ $newpurchaseCost
    }
    variable manufacturerName_
    method ManufacturerName {} {return $manufacturerName_}
    method SetManufacturerName {newmanufacturerName} {
        set manufacturerName_ $newmanufacturerName
    }
    variable manufacturerPartNumber_
    method ManufacturerPartNumber {} {return $manufacturerPartNumber_}
    method SetManufacturerPartNumber {newmanufacturerPartNumber} {
        set manufacturerPartNumber_ $newmanufacturerPartNumber
    }
    variable scale_
    method Scale {} {return $scale_}
    method SetScale {newscale} {
        set scale_ $newscale
    }
    typevariable AllRollingStock [list]
    constructor {record args} {
        lassign $record reportingMarks_ number_ type_ description_ length_ \
              clearance_ weightClass_ emptyWeight_ loadedWeight_ imageFile_ \
              value_ purchaseCost_ manufacturerName_ manufacturerPartNumber_ \
              scale_
        lappend AllRollingStock $self
    }
    destructor {
        set index [lsearch -exact $AllRollingStock $self]
        if {$index >= 0} {
            set AllRollingStock [lreplace $AllRollingStock $index $index]
        }
    }
    method RecordAsList {} {
        return [list $reportingMarks_ $number_ $type_ $description_ $length_ \
                $clearance_ $weightClass_ $emptyWeight_ $loadedWeight_ \
                $imageFile_ $value_ $purchaseCost_ $manufacturerName_ \
                $manufacturerPartNumber_ $scale_]
    }
    typemethod validate {object} {
        if {[catch {$object info type} thetype]} {
            error [_ "Not a %s: %s" $type $object]
        } elseif {$type ne $thetype} {
            error [_ "Not a %s: %s" $type $object]
        }
    }
    proc compare_ {a b} {
        RollingStock validate $a
        RollingStock validate $b
        switch [string compare -nocase [$a ReportingMarks] [$b ReportingMarks]] {
            -1 {return -1}
            1  {return 1}
            0  {return [expr {[$a Number] - [$b Number]}]}
        }
    }
    method CompareTo {other} {
        return [compare_ $self $other]
    }
    typemethod SortedIndexes {} {
        return [lsort -command [myproc compare_] -indices $AllRollingStock]
    }
    typemethod Index {i} {
        return [lindex $AllRollingStock $i]
    }
    typevariable Headers {"Reporting Marks" "Number" "Type" "Description" \
              "Length" "Clearance" "Weight Class" "Empty Weight" \
              "Loaded Weight" "Image File" "Value" "Purchase Cost" \
              "Manufacturer Name" "Manufacturer Part Number" "Scale"}
    typemethod ReadFile {filename} {
        if {[catch {open $filename r} fp]} {
            error [_ "Could not open %s because %s" $filename $fp]
        }
        set headers [::csv::split [gets $fp]]
        if {[llength $headers] != [llength $Headers]} {
            error [_ "Not a RollingStock file %s (header mismatch)" $filename]
        }
        foreach h $headers H $Headers {
            if {$h ne $H} {
                error [_ "Not a RollingStock file %s (header mismatch: \"%s\" not \"%s\")" $filename $h $H]
            }
        }
        while {[gets $fp line] >= 0} {
            $type create %AUTO% [::csv::split $line]
        }
        close $fp
    }
    typemethod WriteFile {filename} {
        if {[catch {open $filename w} fp]} {
            error [_ "Could not open %s because %s" $filename $fp]
        }
        puts $fp [::csv::join $Headers]
        foreach item $AllRollingStock {
            puts $fp [::csv::join [$item RecordAsList]]
        }
        close $fp
    }
    typemethod DeleteAll {} {
        foreach item $AllRollingStock {
            $item destroy
        }
    }
}



package provide RollingStock 1.0

