#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Aug 17 10:46:46 2017
#  Last Modified : <181011.1406>
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


package require snit
package require ParseXML

snit::type XmlConfiguration {
    option -configcallback -default {} -readonly yes
    option -guicallback -default {} -readonly yes
    option -copyfromcallback -default {} -readonly yes
    option -eventidgenerator -default {}
    variable xml
    method getrawxml {} {return $xml}
    constructor {confXML args} {
        if {[catch {ParseXML create %AUTO% $confXML} xml]} {
            error [_ "Could not parse configuration %s:" $xml]
            return
        }
        $self configurelist $args
    }
    method processConfig {itemconf result} {
        set configuration [lindex [$xml getElementsByTagName "configure"] 0]
        foreach n [$configuration children] {
            set result [$self _process1Config $n $itemconf $result]
        }
        return $result
    }
    method _process1Config {n itemconf result} {
        #puts stderr "*** $self _process1Config $n $itemconf $result"
        set option [$n attribute option]
        set tagname [$n attribute tagname]
        set confs [$itemconf getElementsByTagName $tagname]
        if {[llength $confs] == 0} {
            return $result
        }
        switch [$n cget -tag] {
            int {
                set min [$n attribute min]
                set max [$n attribute max]
                if {[llength $confs] > 0} {
                    set confs [lindex $confs 0]
                    set val [$confs data]
                    if {![string is integer -strict $val]} {
                        puts stderr [_ "Not an integer (%s): %s" $tagname $val]
                        return $result
                    }
                    if {$min ne {} && $val < $min ||
                        $max ne {} && $val > $max} {
                        puts stderr [_ "Out of range (%s - %d..%d): %d" 
                                     $tagname $min $max $$val]
                        return $result
                    }
                    if {$option ne {}} {
                        lappend result $option $val
                    } else {
                        lappend result $val
                    }
                    return $result
                }
            }
            string {
                if {[llength $confs] >= 1} {
                    set confs [lindex $confs 0]
                    set val [$confs data]
                    if {$option ne {}} {
                        lappend result $option $val
                    } else {
                        lappend result $val
                    }
                    return $result
                }
            }
            eventid {
                if {[llength $confs] >= 1} {
                    set confs [lindex $confs 0]
                    if {[catch {lcc::EventID create %AUTO% -eventidstring [$confs data]} val]} {
                        puts stderr [_ "Not an EventID (%s): %s" $tagname [$confs data]]
                        return $result
                    }
                    if {$option ne {}} {
                        lappend result $option $val
                    } else {
                        lappend result $val
                    }
                    return $result
                }
            }
            enum {
                set enums [$n attribute enums]
                if {[llength $confs] >= 1} {
                    set confs [lindex $confs 0]
                    set val [$confs data]
                    if {[lsearch -exact $enums $val] < 0} {
                        puts stderr [_ "Not an allowed value (%s: %s) %s" \
                                     $tagname $enums $val]
                        return $result
                    }
                    if {$option ne {}} {
                        lappend result $option $val
                    } else {
                        lappend result $val
                    }
                    return $result
                }
            }
            boolean {
                set novalmode [$n attribute novalmode]
                if {$novalmode eq {}} {set novalmode false}
                if {$novalmode} {
                    if {[llength $confs] >= 1} {
                        set val true
                    } else {
                        set val false
                    }
                } else {
                    if {[llength $confs] >= 1} {
                        set confs [lindex $confs 0]
                        set val [$confs data]
                        if {![string is boolean -strict $val]} {
                            puts stderr [_ "Not a boolean (%s): %s" $tagname $val]
                            return $result
                        }
                    }
                }
                if {$option ne {}} {
                    lappend result $option $val
                } else {
                    lappend result $val
                }
                return $result
            }
            bytebits {
                if {[llength $confs] > 0} {
                    set confs [lindex $confs 0]
                    set val [$confs data]
                    if {[regexp {^B[01]{8}$} $val] < 1} {
                        puts stderr [_ "Not a binary byte (%s): %s" $tagname $val]
                        return $result
                    }
                    if {$option ne {}} {
                        lappend result $option $val
                    } else {
                        lappend result $val
                    }
                    return $result
                }
            }
            list {
                set mincount [$n attribute mincount]
                if {$mincount eq {}} {set mincount 1}
                set maxcount [$n attribute maxcount]
                if {$maxcount eq {}} {set maxcount 1}
                if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
                set eletype [$n attribute eletype]
                if {[llength $confs] >= 1} {
                    set val [[lindex $confs 0] data]
                    if {[llength $val] < $mincount} {
                        puts stderr [_ "List too short: %s, needs to be at least %d elements long" \
                                     $val $mincount]
                        return $result
                    } elseif {[llength $val] > $maxcount} {
                        puts stderr [_ "List too long: %s, needs to be no more than %d elements long" \
                                     $val $maxcount]
                        return $result
                    } else {
                        # just the right length
                        if {$option ne {}} {
                            lappend result $option $val
                        } else {
                            lappend result $val
                        }
                        return $result
                    }
                }
            }
            group {
                set mincount [$n attribute mincount]
                if {$mincount eq {}} {set mincount 1}
                set maxcount [$n attribute maxcount]
                if {$maxcount eq {}} {set maxcount 1}
                if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
                if {[llength $confs] < $mincount} {
                    puts stderr [_ "Group too short: %d, needs to be at list %d elements long" \
                                 [llength $confs] $mincount]
                    return $result
                } elseif {[llength $confs] > $maxcount} {
                    puts stderr [_ "Group too long: %d, needs to be no more than %d elements long" \
                                 [llength $confs] $maxcount]
                    return $result
                } else {
                    set val [list]
                    foreach c $confs {
                        set r [list]
                        foreach gn [$n children] {
                            set r [$self _process1Config $gn $c $r]
                        }
                        if {[llength [$n children]] == 1} {
                            lappend val [lindex $r 0]
                        } else {
                            lappend val $r
                        }
                    }
                    #puts stderr "*** $self _process1Config: val is $val"
                    if {$option ne {}} {
                        lappend result $option $val
                    } else {
                        lappend result $val
                    }
                    return $result
                }
            }
            custom {
                set callback [$self cget -configcallback]
                if {$callback ne {}} {
                    return [uplevel #0 [list $callback $n $confs $result]]
                }
            }
            default {
            }
        }
        return $result
    }
    variable guicount 0
    method createGUINoNoteBook {parentWidget itemconf} {
        incr guicount
        set fr config${guicount}
        set f [$itemconf attribute frame]
        if {$f eq {}} {
            set attrs [$itemconf cget -attributes]
            lappend attrs frame $fr
            $itemconf configure -attributes $attrs
        } else {
            set attrs [$itemconf cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $itemconf configure -attributes $attrs
        }
        set frame [ttk::frame $parentWidget.$fr]
        set configuration [lindex [$xml getElementsByTagName "configure"] 0]
        foreach n [$configuration children] {
            #puts stderr "*** $self createGUI: n is $n"
            $self _create1GUI $frame $n $itemconf
        }
        return $frame
    }
    method createGUI {parentWidget key parentconf itemconf dellabel \
              addtoparent delfromparent} {
        #puts stderr "*** $self createGUI $parentWidget $key $parentconf $itemconf \"$dellabel\" \"$addtoparent\" \"$delfromparent\""
        incr guicount
        set fr ${key}${guicount}
        set f [$itemconf attribute frame]
        if {$f eq {}} {
            set attrs [$itemconf cget -attributes]
            lappend attrs frame $fr
            $itemconf configure -attributes $attrs
        } else {
            set attrs [$itemconf cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $fr]
            $itemconf configure -attributes $attrs
        }
        set frame [ttk::frame $parentWidget.$fr]
        set configuration [lindex [$xml getElementsByTagName "configure"] 0]
        #puts stderr "*** $self createGUI: configuration is $configuration"
        foreach n [$configuration children] {
            #puts stderr "*** $self createGUI: n is $n"
            $self _create1GUI $frame $n $itemconf
        }
        set delgui [ttk::button $frame.deletegui \
                       -text $dellabel \
                       -command [mymethod _deleteGui $parentconf \
                                 $parentWidget $itemconf \
                                 $delfromparent]]
        #puts stderr "*** $self createGUI: delgui is $delgui"
        pack $delgui -expand yes -fill both                       
        uplevel #0 $addtoparent $parentWidget $frame $guicount
        return $frame
    }
    method _deleteGui {parentconf parentWidget itemconf delfromparent} {
        set fr [$itemconf attribute frame]
        set frame $parentWidget.$fr
        $parentconf removeChild $itemconf
        uplevel #0 $delfromparent $frame
        destroy $frame
    }
    method _create1GUI {frame n itemconf} {
        set tagname [$n attribute tagname]
        set confs [$itemconf getElementsByTagName $tagname]
        set default [$n attribute default]
        switch [$n cget -tag] {
            int {
                set min [$n attribute min]
                if {$min eq {}} {set min [expr {0x7fffffff * -1}]}
                set max [$n attribute max]
                if {$max eq {}} {set max [expr {0x7fffffff * 1}]}
                if {[llength $confs] == 1} {
                    set initval [[lindex $confs 0] data]
                } elseif {$default ne {}} {
                    set initval $default
                } else {
                    set initval 0
                }
                set spin [LabelSpinBox $frame.$tagname -label [$n data] \
                          -range [list $min $max 1]]
                pack $spin -fill x -expand yes
                $spin set $initval
            }
            string {
                if {[llength $confs] == 1} {
                    set initval [[lindex $confs 0] data]
                } else {
                    set initval $default
                }
                set entry [LabelEntry $frame.$tagname -label [$n data]]
                pack $entry -fill x -expand yes
                $entry configure -text $initval
            }
            eventid {
                set roundup [$n attribute roundup]
                if {$roundup eq {}} {set roundup 1}
                set evgen [$self cget -eventidgenerator]
                if {[llength $confs] == 1} {
                    set initval [[lindex $confs 0] data]
                } elseif {$evgen ne {}} {
                    set initval [uplevel #0 [list $evgen nextid -roundup $roundup]]
                }
                set entry [LabelEntry $frame.$tagname -label [$n data]]
                pack $entry -fill x -expand yes
                $entry configure -text $initval
            }
            enum {
                set enums [$n attribute enums]
                if {[llength $confs] == 1} {
                    set initval [[lindex $confs 0] data]
                } elseif {[lsearch -exact $enums $default] >= 0} {
                    set initval $default
                } else {
                    set initval [lindex $enums 0]
                }
                set combobox [LabelComboBox $frame.$tagname \
                              -label [$n data] -values $enums -editable no]
                pack $combobox -fill x -expand yes
                $combobox set $initval
            }
            boolean {
                set novalmode [$n attribute novalmode]
                if {$novalmode eq {}} {set novalmode false}
                if {$novalmode} {
                    if {[llength $confs] >= 1} {
                        set initval true
                    } else {
                        set initval false
                    }
                } else {
                    if {[llength $confs] == 1} {
                        set initval [[lindex $confs 0] data]
                    } elseif {$default ne {}} {
                        set initval $default
                    } else {
                        set initval no
                    }
                }
                set enums [$n attribute enums]
                if {$enums eq {}} {
                    set enums [list [_m "Answer|Yes"] [_m "Answer|No"]]
                }
                set combobox [LabelComboBox $frame.$tagname \
                              -label [$n data] \
                              -values  $enums \
                              -editable no]
                pack $combobox -fill x -expand yes
                if {$initval} {
                    $combobox set [lindex $enums 0]
                } else {
                    $combobox set [lindex $enums 1]
                }
            }
            bytebits {
                if {[llength $confs] > 0} {
                    set initval [[lindex $confs 0] data]
                } elseif {$default ne {}} {
                    set initval $default
                } else {
                    set initval B00000000
                }
                set entry [LabelEntry $frame.$tagname -label [$n data]]
                pack $entry -fill x -expand yes
                $entry configure -text $initval
            }
            list {
                if {[llength $confs] == 1} {
                    set initval [[lindex $confs 0] data]
                } else {
                    set initval $default
                }
                set entry [LabelEntry $frame.$tagname -label [$n data]]
                pack $entry -fill x -expand yes
                $entry configure -text $initval
            }
            group {
                set mincount [$n attribute mincount]
                if {$mincount eq {}} {set mincount 1}
                set maxcount [$n attribute maxcount]
                if {$maxcount eq {}} {set maxcount 1}
                if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
                set repname [$n attribute repname]
                set groupnotebook [ScrollTabNotebook $frame.$tagname]
                pack $groupnotebook -expand yes -fill x
                set gcount 0
                while {[llength $confs] < $mincount} {
                    set tconf [SimpleDOMElement %AUTO% -tag $tagname]
                    $itemconf addchild $tconf
                    set confs [$itemconf getElementsByTagName $tagname]
                }
                foreach c $confs {
                    incr gcount
                    set gfr gframe$gcount
                    set gf [$c attribute frame]
                    if {$gf eq {}} {
                        set attrs [$c cget -attributes]
                        lappend attrs frame $gfr
                        $c configure -attributes $attrs
                    } else {
                        set attrs [$c cget -attributes]
                        set findx [lsearch -exact $attrs frame]
                        incr findx
                        set attrs [lreplace $attrs $findx $findx $gfr]
                        $c configure -attributes $attrs
                    }
                    set gframe [ttk::frame $groupnotebook.$gfr]
                    if {$mincount != 1 && $maxcount != 1} {
                        $groupnotebook add $gframe \
                              -text [format "%s %d" $repname $gcount] -sticky news
                    } else {
                        $groupnotebook add $gframe \
                              -text [format "%s" $repname] -sticky news
                    }
                    foreach n1 [$n children] {
                        $self _create1GUI $gframe $n1 $c
                    }
                    if {$mincount != $maxcount} {
                        set delgui [ttk::button $gframe.deletegui \
                                    -text [_m "Label|Delete %s" $repname] \
                                    -command [mymethod _deleteGui $itemconf \
                                              $groupnotebook $c \
                                              [mymethod _deleteGroupGUI $frame.add$repname $groupnotebook $n $itemconf]]]
                        pack $delgui -fill x -expand yes
                    }
                }
                # Add group replication...
                #puts stderr "*** $self _create1GUI (group branch): frame = $frame, repname = $repname"
                if {$mincount != $maxcount} {
                    set addgui [ttk::button $frame.add$repname \
                                -text [_m "Label|Add %s" $repname] \
                                -command [mymethod _addGui $n $itemconf \
                                          $groupnotebook]]
                    if {$gcount < $maxcount} {
                        pack $addgui -fill x -expand yes
                    }
                }
            }
            custom {
                set callback [$self cget -guicallback]
                if {$callback ne {}} {
                    uplevel #0 [list $callback $frame $n $confs]
                }
            }
            default {
            }
        }
    }
    method _addGui {n itemconf groupnotebook} {
        set tagname [$n attribute tagname]
        set mincount [$n attribute mincount]
        if {$mincount eq {}} {set mincount 1}
        set maxcount [$n attribute maxcount]
        if {$maxcount eq {}} {set maxcount 1}
        if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
        set repname [$n attribute repname]
        set gcount [llength [$itemconf getElementsByTagName $tagname]]
        set c [SimpleDOMElement %AUTO% -tag $tagname]
        $itemconf addchild $c
        incr gcount
        set gfr gframe$gcount
        set gf [$c attribute frame]
        if {$gf eq {}} {
            set attrs [$c cget -attributes]
            lappend attrs frame $gfr
            $c configure -attributes $attrs
        } else {
            set attrs [$c cget -attributes]
            set findx [lsearch -exact $attrs frame]
            incr findx
            set attrs [lreplace $attrs $findx $findx $gfr]
            $c configure -attributes $attrs
        }
        set gframe [ttk::frame $groupnotebook.$gfr]
        $groupnotebook add $gframe \
              -text [format "%s %d" $repname $gcount] -sticky news
        foreach n1 [$n children] {
            $self _create1GUI $gframe $n1 $c
        }
        set frame [winfo parent $groupnotebook]
        set delgui [ttk::button $gframe.deletegui \
                    -text [_m "Label|Delete %s" $repname] \
                    -command [mymethod _deleteGui $itemconf \
                              $groupnotebook $c \
                              [mymethod _deleteGroupGUI $frame.add$repname $groupnotebook $n $itemconf]]]
                    pack $delgui -fill x -expand yes
        if {$gcount >= $maxcount} {
            pack forget $frame.add$repname
        }
    }
    method _deleteGroupGUI {addbutton groupnotebook n itemconf frame} {
        set tagname [$n attribute tagname]
        set gcount  [llength [$itemconf getElementsByTagName $tagname]]
        set maxcount [$n attribute maxcount]
        if {$maxcount eq {}} {set maxcount 1}
        if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
        $groupnotebook forget $frame
        if {$gcount < $maxcount} {
            pack $addbutton -fill x -expand yes
        }
    }
    method copyFromGUI {parentWidget itemconf warningsVar} {
        upvar $warningsVar warnings
        set fr [$itemconf attribute frame]
        set frame $parentWidget.$fr
        set configuration [lindex [$xml getElementsByTagName "configure"] 0]
        foreach n [$configuration children] {
            $self _copyFrom1GUI $frame $n $itemconf warnings
        }
    }
    method _copyFrom1GUI {frame n itemconf warningsVar} {
        upvar $warningsVar warnings
        set tagname [$n attribute tagname]
        set confs [$itemconf getElementsByTagName $tagname]
        switch [$n cget -tag] {
            int {
                set val [$frame.$tagname get]
                if {[llength $confs] == 0} {
                    set newele [SimpleDOMElement %AUTO% -tag $tagname]
                    $itemconf addchild $newele
                    $newele setdata $val
                } elseif {[llength $confs] == 1} {
                    set ele [lindex $confs 0]
                    $ele setdata $val
                } else {
                    # multiple ints...
                }
            }
            string {
                set val [$frame.$tagname get]
                if {[llength $confs] == 0} {
                    set newele [SimpleDOMElement %AUTO% -tag $tagname]
                    $itemconf addchild $newele
                    $newele setdata $val
                } elseif {[llength $confs] == 1} {
                    set ele [lindex $confs 0]
                    $ele setdata $val
                } else {
                    # multiple strings...
                }
            }
            eventid {
                set val [$frame.$tagname get]
                if {$val ne "" && [catch {lcc::eventidstring validate $val}]} {
                    tk_messageBox -type ok -icon warning \
                          -message [_ "Bad Event ID for %s: %s" [$n data] $val]
                    incr warnings
                    set val {}
                }
                if {$val eq ""} {
                    if {[llength $confs] == 1} {
                        $itemconf removeChild [lindex $confs 0]
                    }
                } else {
                    if {[llength $confs] == 0} {
                        set newele [SimpleDOMElement %AUTO% -tag $tagname]
                        $itemconf addchild $newele
                        $newele setdata $val
                    } elseif {[llength $confs] == 1} {
                        set ele [lindex $confs 0]
                        $ele setdata $val
                    }
                }
            }
            enum {
                set val [$frame.$tagname get]
                if {[llength $confs] == 0} {
                    set newele [SimpleDOMElement %AUTO% -tag $tagname]
                    $itemconf addchild $newele
                    $newele setdata $val
                } elseif {[llength $confs] == 1} {
                    set ele [lindex $confs 0]
                    $ele setdata $val
                }
            }
            boolean {
                set novalmode [$n attribute novalmode]
                if {$novalmode eq {}} {set novalmode false}
                set enums [$frame.$tagname cget -values]
                set val false
                if {[$frame.$tagname get] eq [lindex $enums 0]} {
                    set val true
                }
                if {$novalmode} {
                    if {$val} {
                        if {[llength $confs] == 0} {
                            set newele [SimpleDOMElement %AUTO% -tag $tagname]
                            $itemconf addchild $newele
                        }
                    } else {
                        if {[llength $confs] > 0} {
                            foreach c $confs {
                                $itemconf removeChild $c
                            }
                        }
                    }
                } else {
                    if {[llength $confs] == 0} {
                        set newele [SimpleDOMElement %AUTO% -tag $tagname]
                        $itemconf addchild $newele
                        
                        $newele setdata $val
                    } elseif {[llength $confs] == 1} {
                        set ele [lindex $confs 0]
                        $ele setdata $val
                    }
                }
            }
            bytebits {
                set val [$frame.$tagname get]
                if {$val ne "" && [regexp {^B[01]{8}$} $val] < 1} {
                    tk_messageBox -type ok -icon warning \
                          -message [_ "Bad bytebits for %s: %s" [$n data] $val]
                    incr warnings
                    set val ""
                }
                if {$val eq ""} {
                    if {[llength $confs] == 1} {
                        $itemconf removeChild [lindex $confs 0]
                    }
                } else {
                    if {[llength $confs] == 0} {
                        set newele [SimpleDOMElement %AUTO% -tag $tagname]
                        $itemconf addchild $newele
                        $newele setdata $val
                    } elseif {[llength $confs] == 1} {
                        set ele [lindex $confs 0]
                        $ele setdata $val
                    }
                }
            }
            list {
                set val [$frame.$tagname get]
                if {[llength $confs] == 0} {
                    set newele [SimpleDOMElement %AUTO% -tag $tagname]
                    $itemconf addchild $newele
                    $newele setdata $val
                } elseif {[llength $confs] == 1} {
                    set ele [lindex $confs 0]
                    $ele setdata $val
                } else {
                    # multiple lists...
                }
            }
            group {
                set groupnotebook $frame.$tagname
                foreach c $confs {
                    set gf [$c attribute frame]
                    set gframe $groupnotebook.$gf
                    foreach n1 [$n children] {
                        $self _copyFrom1GUI $gframe $n1 $c warnings
                    }
                }
            }
            custom {
                set callback [$self cget -copyfromcallback]
                if {$callback ne {}} {
                    set w [uplevel #0 [list $callback $frame $n $confs]]
                    incr warnings $w
                }
                
            }
            default {
            }
        }
    }
    method SampleConfiguration {parentconf} {
        set configuration [lindex [$xml getElementsByTagName "configure"] 0]
        foreach n [$configuration children] {
            $self _SampleConfiguration $n $parentconf
        }
    }
    method _SampleConfiguration {n cdi} {
        set tagname [$n attribute tagname]
        set default [$n attribute default]
        switch [$n cget -tag] {
            int {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                set min [$n attribute min]
                if {$min eq {}} {set min [expr {0x7fffffff * -1}]}
                set max [$n attribute max]
                if {$max eq {}} {set max [expr {0x7fffffff * 1}]}
                set range [expr {$max - $min}]
                set initval [expr {$min + int(rand()*$range)}]
                $newtag setdata $initval
            }
            string {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                $newtag setdata "Sample String"
            }
            eventid {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                $newtag setdata [[$self cget -eventidgenerator] nextid]
            }
            enum {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                set enums [$n attribute enums]
                set ie [expr {int(rand()*[llendth $enums])}]
                $newtag setdata [lindex $enums $ie]
            }
            boolean {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                set val [expr {(int(rand()*2))?"true":"false"}]
                $newtag setdata $val
            }
            bytebits {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                set ival [expr {int(rand()*256)}]
                set val "B"
                for {set i 7} {$i >= 0} {incr i -1} {
                    append val [expr {(($ival >> $i) & 1)?"1":"0"}]
                }
                $newtag setdata $val
            }
            list {
                set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                $cdi addchild $newtag
                set mincount [$n attribute mincount]
                if {$mincount eq {}} {set mincount 1}
                set maxcount [$n attribute maxcount]
                if {$maxcount eq {}} {set maxcount 1}
                if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
                set eletype [$n attribute eletype]
                set range [expr {$maxcount - $mincount}]
                set len [expr {$mincount + int(rand()*$range)}]
                set l [list]
                for {set i 0} {$i < $len} {incr i} {
                    lappend l "element"
                }
                $newtag setdata $l
            }
            group {
                set mincount [$n attribute mincount]
                if {$mincount eq {}} {set mincount 1}
                set maxcount [$n attribute maxcount]
                if {$maxcount eq {}} {set maxcount 1}
                if {$maxcount eq "unlimited"} {set maxcount 0x7fffffff}
                set range [expr {$maxcount - $mincount}]
                set len [expr {$mincount + int(rand()*$range)}]
                for {set i 0} {$i < $len} {incr i} {
                    set newtag [SimpleDOMElement %AUTO% -tag $tagname] 
                    $cdi addchild $newtag
                    foreach c [$n children] {
                        $self _SampleConfiguration $c $newtag
                    }
                }
            }
            custom {
            }
            default {
            }
        }
    }
}

namespace eval OpenLCB_Common {}

snit::macro OpenLCB_Common::transportProcs {{getprocs yes} {guiprocs yes}} {
    typevariable    transconstructorname {};# transport constructor
    typevariable    transopts {};# transport options
    
    if {$getprocs} {
        proc getTransport {transcons transportConstructorVar transportOptsVar} {
            upvar $transportConstructorVar transportConstructor
            upvar $transportOptsVar transportOpts
            
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
                ::log::log debug "getTransport: no options."
            }
            
            set transportConstructors [info commands ::lcc::[$constructor data]]
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
            if {$transportConstructor eq {}} {
                ::log::logError [_ "No valid transport constructor found!"]
                exit 96
            }
        }
    }
    if {$guiprocs} {
        proc SampleTransport {cdi} {
            set transcons [SimpleDOMElement %AUTO% -tag "transport"]
            $cdi addchild $transcons
            set constructor [SimpleDOMElement %AUTO% -tag "constructor"]
            $transcons addchild $constructor
            $constructor setdata "CANGridConnectOverTcp"
            set transportopts [SimpleDOMElement %AUTO% -tag "options"]
            $transcons addchild $transportopts
            $transportopts setdata {-port 12021 -nid 05:01:01:01:22:00 -host localhost}
        }
        proc TransportGUI {frame cdi} {
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
                               -command [myproc _seltransc]]
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
                             -command [myproc _seltransopt]]
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
        }
        proc CopyTransFromGUI {cdi} {
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
        }
    }
    if {$getprocs} {
        proc _seltransc {} {
            #** Select a transport constructor.
            
            set result [lcc::OpenLCBNode selectTransportConstructor]
            if {$result ne {}} {
                if {$result ne $transconstructorname} {set transopts {}}
                set transconstructorname [namespace tail $result]
            }
        }
        proc _seltransopt {} {
            #** Select transport constructor options.
            
            if {$transconstructorname ne ""} {
                set transportConstructors [info commands ::lcc::$transconstructorname]
                puts stderr "*** _seltransopt: transportConstructors is $transportConstructors"
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
    }
}

snit::macro OpenLCB_Common::identificationProcs {{getprocs yes} {guiprocs yes}} {
    typevariable    id_name {};# node name
    typevariable    id_description {};# node description
    
    if {$getprocs} {
        proc getIdentification {ident nodenameVar nodedescriptorVar} {
            upvar $nodenameVar nodename
            upvar $nodedescriptorVar nodedescriptor
            
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
        }
    }
    if {$guiprocs} {
        proc SampleItentification {cdi} {
            set ident [SimpleDOMElement %AUTO% -tag "identification"]
            $cdi addchild $ident
            set nameele [SimpleDOMElement %AUTO% -tag "name"]
            $ident addchild $nameele
            $nameele setdata "Sample Name"
            set descrele [SimpleDOMElement %AUTO% -tag "description"]
            $ident addchild $descrele
            $descrele setdata "Sample Description"
        }
        proc IdentificationGUI {frame cdi} {
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
        }
        proc CopyIdentFromGUI {cdi} {
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
        }
    }
}

package provide OpenLCB_Common 1.0
