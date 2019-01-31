#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Jan 30 10:06:50 2019
#  Last Modified : <190130.1148>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2019  Robert Heller D/B/A Deepwoods Software
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

snit::type LayoutControlDB {
    component db -inherit yes 
    typevariable emptyLayout {<?xml version='1.0'?><layout/>}
    typemethod newdb {{name %%AUTO%%}} {
        return [$type create $name $emptyLayout]
    }
    typemethod olddb {filename {name %%AUTO%%}} {
        if {[catch {open $filename r} fp]} {
            error "$type olddb: could not open $filename: $fp"
        }
        set xml [read $fp]
        close $fp
        return [$type create $name $xml]
    }
    method savedb {filename} {
        if {[file exists $filename]} {
            catch {file rename -force $filename ${filename}.bak}
        }
        if {[catch {open $filename w} fp]} {
            error "$type olddb: could not open $filename: $fp"
        }
        puts $fp {<?xml version='1.0'?>}
        $db displayTree $fp
        close $fp
    }
    constructor {xml args} {
        install db using ParseXML %%AUTO%% $xml
        #$self configurelist $args
    }
    method newTurnout {{name CP1} args} {
        set layout [$self getElementsByTagName layout]
        set newturnout [[$layout info type] create %%AUTO%% -tag turnout]
        $layout addchild $newturnout
        set nametag [[$layout info type] create %%AUTO%% -tag name]
        $newturnout addchild $nametag
        $nametag setdata $name
        set motortag [[$layout info type] create %%AUTO%% -tag motor]
        $newturnout addchild $motortag
        set norm [[$layout info type] create %%AUTO%% -tag normal]
        $norm setdata [from args -normalmotorevent]
        $motortag addchild $norm
        set rev [[$layout info type] create %%AUTO%% -tag reverse]
        $rev setdata [from args -reversemotorevent]
        $motortag addchild $rev
        set pointstag [[$layout info type] create %%AUTO%% -tag points]
        $newturnout addchild $pointstag
        set norm [[$layout info type] create %%AUTO%% -tag normal]
        $norm setdata [from args -normalpointsevent]
        $pointstag addchild $norm
        set rev [[$layout info type] create %%AUTO%% -tag reverse]
        $rev setdata [from args -reversepointsevent]
        $pointstag addchild $rev
    }
    method newBlock {{name BK1} args} {
        set layout [$self getElementsByTagName layout]
        set newblock [[$layout info type] create %%AUTO%% -tag block]
        $layout addchild $newblock
        set nametag [[$layout info type] create %%AUTO%% -tag name]
        $newblock addchild $nametag
        $nametag setdata $name
        set occ [[$layout info type] create %%AUTO%% -tag occupied]
        $occ setdata [from args -occupiedevent]
        $newblock addchild $occ
        set clr [[$layout info type] create %%AUTO%% -tag clear]
        $clr setdata [from args -clearevent]
        $newblock addchild $clr
    }
    method newSignal {{name SIG1}} {
        set layout [$self getElementsByTagName layout]
        set newsignal [[$layout info type] create %%AUTO%% -tag signal]
        $layout addchild $newsignal
        set nametag [[$layout info type] create %%AUTO%% -tag name]
        $newsignal addchild $nametag
        $nametag setdata $name
    }
    method addAspect {signalname args} {
        set l [$self getElementsByTagName layout]
        foreach s [$l getElementsByTagName signal] {
            set nt [$s getElementsByTagName name -depth 1]
            if {[$nt data] eq $signalname} {
                addaspectHelper $s [from args -aspect {Aspect1}] \
                      [from args -eventid {}] \
                      [from args -look {dark}]
                break
            }
        }
    }
    proc addaspectHelper {s aspect eventid look} {
        set aspecttag [[$s info type] create %%AUTO%% -tag aspect]
        $s addchild $aspecttag
        set nametag [[$s info type] create %%AUTO%% -tag name]
        $aspecttag addchild $nametag
        $nametag setdata $aspect
        set eventtag [[$s info type] create %%AUTO%% -tag event]
        $aspecttag addchild $eventtag
        $eventtag setdata $eventid
        set looktag [[$s info type] create %%AUTO%% -tag look]
        $aspecttag addchild $looktag
        $looktag setdata $look
    }
    method newSensor {{name SENSE1} args} {
        set layout [$self getElementsByTagName layout]
        set newsensor [[$layout info type] create %%AUTO%% -tag sensor]
        $layout addchild $newsensor
        set nametag [[$layout info type] create %%AUTO%% -tag name]
        $newsensor addchild $nametag
        $nametag setdata $name
        set on [[$layout info type] create %%AUTO%% -tag on]
        $on setdata [from args -onevent]
        $newsensor addchild $on
        set off [[$layout info type] create %%AUTO%% -tag off]
        $off setdata [from args -offevent]
        $newsensor addchild $off
    }
    method newControl {{name CONTROL1} args} {
        set layout [$self getElementsByTagName layout]
        set newcontrol [[$layout info type] create %%AUTO%% -tag control]
        $layout addchild $newcontrol
        set nametag [[$layout info type] create %%AUTO%% -tag name]
        $newcontrol addchild $nametag
        $nametag setdata $name
        set on [[$layout info type] create %%AUTO%% -tag on]
        $on setdata [from args -onevent]
        $newcontrol addchild $on
        set off [[$layout info type] create %%AUTO%% -tag off]
        $off setdata [from args -offevent]
        $newcontrol addchild $off
    }
    
    method getTurnout {name} {
        set l [$self getElementsByTagName layout]
        foreach t [$l getElementsByTagName turnout] {
            set nt [$t getElementsByTagName name -depth 1]
            if {[$nt data] eq $name} {
                return $t
            }
        }
        return {}
    }
    method getBlock {name} {
        set l [$self getElementsByTagName layout]
        foreach b [$l getElementsByTagName block] {
            set nt [$t getElementsByTagName name]
            if {[$nt data] eq $name} {
                return $b
            }
        }
        return {}
    }
    method getSignal {name} {
        set l [$self getElementsByTagName layout]
        foreach s [$l getElementsByTagName signal] {
            set nt [$t getElementsByTagName name -depth 1]
            if {[$nt data] eq $name} {
                return $s
            }
        }
        return {}
    }
    method getSensor {name} {
        set l [$self getElementsByTagName layout]
        foreach s [$l getElementsByTagName sensor] {
            set nt [$t getElementsByTagName name -depth 1]
            if {[$nt data] eq $name} {
                return $s
            }
        }
        return {}
    }
    method getControl {name} {
        set l [$self getElementsByTagName layout]
        foreach c [$l getElementsByTagName control] {
            set nt [$t getElementsByTagName name -depth 1]
            if {[$nt data] eq $name} {
                return $c
            }
        }
        return {}
    }
    
}


####

#set test [LayoutControlDB newdb]

#$test newTurnout
#$test newBlock
#$test newSignal
#$test addaspect SIG1 -aspect stop -look red
#$test savedb test.xml

package provide LayoutControlDB 1.0
