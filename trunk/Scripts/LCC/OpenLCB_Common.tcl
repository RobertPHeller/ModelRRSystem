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
#  Last Modified : <170826.0937>
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
                        puts stderr [_ "List too short: %s, needs to be at list %d elements long" \
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
                        lappend val $r
                    }
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
                    $groupnotebook add $gframe \
                          -text [format "%s %d" $repname $gcount] -sticky news
                    foreach n1 [$n children] {
                        $self _create1GUI $gframe $n1 $c
                    }
                    set delgui [ttk::button $gframe.deletegui \
                                -text [_m "Label|Delete %s" $repname] \
                                -command [mymethod _deleteGui $itemconf \
                                          $groupnotebook $c \
                                          [mymethod _deleteGroupGUI $frame.add$repname $groupnotebook $n $itemconf]]]
                    pack $delgui -fill x -expand yes
                }
                # Add group replication...
                #puts stderr "*** $self _create1GUI (group branch): frame = $frame, repname = $repname"
                set addgui [ttk::button $frame.add$repname \
                            -text [_m "Label|Add %s" $repname] \
                            -command [mymethod _addGui $n $itemconf \
                                      $groupnotebook]]
                if {$gcount < $maxcount} {
                    pack $addgui -fill x -expand yes
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
}
        
package provide OpenLCB_Common 1.0
