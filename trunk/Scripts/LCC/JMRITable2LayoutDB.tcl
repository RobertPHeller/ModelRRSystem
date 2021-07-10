#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Jul 9 14:25:59 2021
#  Last Modified : <210710.1255>
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

## @page JMRITable2LayoutDB JMRI Tables to LayoutDB converter
# @brief Converts a JMRI Table file to a LayoutDB file
#
# @section JMRITable2LayoutDBSYNOPSIS SYNOPSIS
#
# JMRITable2LayoutDB jmrixml layoutdbxml
#
# @section JMRITable2LayoutDBDESCRIPTION DESCRIPTION
#
# Convert a JMRI Table XML file to a LayoutControlDB xml file.
#
# @section JMRITable2LayoutDBPARAMETERS PARAMETERS
#
# @arg jmrixml The JMRI XML file to convert.
# @arg layoutdbxml The LayoutControlDB xml file to output
# @par
#
# @section JMRITable2LayoutDBOPTIONS OPTIONS
#
# None.
#
# @section JMRITable2LayoutDBAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#


set argv0 [file join  [file dirname [info nameofexecutable]] JMRITable2LayoutDB]

package require snit
package require LayoutControlDB
package require ParseXML
package require gettext
package require LCC

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::type JMRITable2LayoutDB {
    typevariable XMLPREFIXPATTERN {^[[:space:]]*<\?xml.*\?>}
    typevariable SENSORPATTERN {^[[:alnum:]]+S([[:xdigit:].]+);([[:xdigit:].]+)$}
    typevariable TURNOUTPATTERN {^[[:alnum:]]+T([[:xdigit:].]+);([[:xdigit:].]+)$}
    typevariable REPORTERPATTERN {^[[:alnum:]]+R([[:xdigit:].]+);([[:xdigit:].]+)$}
    typevariable LIGHTPATTERN {^[[:alnum:]]+L([[:xdigit:].]+);([[:xdigit:].]+)$}
    typevariable _XML
    typevariable _layoutConfig
    typevariable _sensors
    typevariable _reporters
    typevariable _lights
    typevariable _turnouts
    typevariable _blocks
    typevariable _layoutdb
    typeconstructor {
        if {[llength $::argv] < 2} {
            puts stderr [_ "Missing arguments: infile outfile"]
            exit 99
        }
        set filename [lindex $::argv 0]
        if {[catch {open $filename r} fp]} {
            puts stderr [_ "Could not open file: %s because %s" $filename $fp]
            exit 99
        }
        set rawxml [read $fp]
        close $fp
        set rawxml [regsub -all $XMLPREFIXPATTERN $rawxml {}]
        set _XML [ParseXML %%AUTO%% $rawxml]
        set _layoutConfig [$_XML getElementsByTagName layout-config -depth 1]
        if {$_layoutConfig eq {}} {
            puts stderr [_ "Not a JMRI Table XML file: %s" $filename]
            exit 99
        }
        set _sensors [$_layoutConfig getElementsByTagName sensors -depth 1]
        set _reporters [$_layoutConfig getElementsByTagName reporters -depth 1]
        set _lights [$_layoutConfig getElementsByTagName lights -depth 1]
        set _turnouts [$_layoutConfig getElementsByTagName turnouts -depth 1]
        set _blocks [$_layoutConfig getElementsByTagName blocks -depth 1]
        set _layoutdb [::lcc::LayoutControlDB newdb]
        set bcount 0
        foreach block [$_blocks getElementsByTagName block -depth 1] {
            _processBlock $block
            incr bcount
        }
        puts [format "%3d Blocks" $bcount]
        set tcount 0
        foreach turnout [$_turnouts getElementsByTagName turnout -depth 1] {
            _processTurnout $turnout
            incr tcount
        }
        puts [format "%3d Turnouts" $tcount]
        set scount 0
        foreach sensor [$_sensors getElementsByTagName sensor -depth 1] {
            _processSensor $sensor
            incr scount
        }
        puts [format "%3d Sensors" $scount]
        set rcount 0
        foreach reporter [$_reporters getElementsByTagName reporter -depth 1] {
            _processReporter $reporter
            incr rcount
        }
        puts [format "%3d Reporters" $rcount]
        set lcount 0
        foreach light [$_lights getElementsByTagName light -depth 1] {
            _processLight $light
            incr lcount
        }
        puts [format "%3d Lights" $lcount]
        $_layoutdb savedb [lindex $::argv 1]
    }
    proc _processBlock {block} {
        set un [$block getElementsByTagName userName -depth 1]
        if {[llength $un] != 1} {return}
        set name [$un data]
        set newblock [$_layoutdb newBlock $name]
        set os [$block getElementsByTagName occupancysensor -depth 1]
        if {[llength $os] == 1} {
            set BOD_Name [$os data]
            set sensor [_getSensor $BOD_Name]
            if {$sensor ne {}} {
                set sn [$sensor getElementsByTagName systemName -depth 1]
                if {[llength $sn] == 1} {
                    if {[regexp $SENSORPATTERN [$sn data] => occ clr] > 0} {
                        [$newblock getElementsByTagName occupied] setdata $occ
                        [$newblock getElementsByTagName clear] setdata $clr
                    }
                }
                $_sensors removeChild $sensor
            }
        }
    }
    proc _processTurnout {turnout} {
        set un [$turnout getElementsByTagName userName -depth 1]
        if {[llength $un] != 1} {return}
        set name [$un data]
        set newturnout [$_layoutdb newTurnout $name]
        if {[$turnout attribute feedback] eq "ONESENSOR"} {
            set points [$turnout attribute sensor1]
            if {$points ne {}} {
                set pointsense [_getSensor $points]
                if {$pointsense ne {}} {
                    set sn [$pointsense getElementsByTagName systemName -depth 1]
                    if {[llength $sn] == 1} {
                        if {[regexp $SENSORPATTERN [$sn data] => norm rev] > 0} {
                            set pointstag [$newturnout getElementsByTagName points -depth 1]
                            [$pointstag getElementsByTagName normal] setdata $norm
                            [$pointstag getElementsByTagName reverse] setdata $rev
                        }
                    }
                    $_sensors removeChild $pointsense
                }
            }
        }
        set sn [$turnout getElementsByTagName systemName -depth 1]
        if {[regexp $TURNOUTPATTERN [$sn data] => norm rev] > 0} {
            set motortag [$newturnout getElementsByTagName motor -depth 1]
            [$motortag getElementsByTagName normal] setdata $norm
            [$motortag getElementsByTagName reverse] setdata $rev
        }
    }
    proc _processSensor {sensor} {
        set un [$sensor getElementsByTagName userName -depth 1]
        if {[llength $un] != 1} {return}
        set name [$un data]
        set sn [$sensor getElementsByTagName systemName -depth 1]
        if {[llength $sn] == 1} {
            if {[regexp $SENSORPATTERN [$sn data] => on off] > 0} {
                set newsensor [$_layoutdb newSensor $name -onevent $on -offevent $off]
            } else {
                set newsensor [$_layoutdb newSensor $name]
            }
        } else {
            set newsensor [$_layoutdb newSensor $name]
        }
    }
    proc _processReporter {reporter} {
        set un [$reporter getElementsByTagName userName -depth 1]
        if {[llength $un] != 1} {return}
        set name [$un data]
        set sn [$reporter getElementsByTagName systemName -depth 1]
        if {[llength $sn] == 1} {
            if {[regexp $REPORTERPATTERN [$sn data] => on off] > 0} {
                set newcontrol [$_layoutdb newControl $name -onevent $on -offevent $off]
            } else {
                set newcontrol [$_layoutdb newControl $name]
            }
        } else {
            set newcontrol [$_layoutdb newControl $name]
        }
        $newcontrol setAttribute type reporter
    }
    proc _processLight {light} {
        set un [$light getElementsByTagName userName -depth 1]
        if {[llength $un] != 1} {return}
        set name [$un data]
        set sn [$light getElementsByTagName systemName -depth 1]
        if {[llength $sn] == 1} {
            if {[regexp $LIGHTPATTERN [$sn data] => on off] > 0} {
                set newcontrol [$_layoutdb newControl $name -onevent $on -offevent $off]
            } else {
                set newcontrol [$_layoutdb newControl $name]
            }
        } else {
            set newcontrol [$_layoutdb newControl $name]
        }
        $newcontrol setAttribute type light
    }
    proc _getSensor {userName} {
        foreach sensor [$_sensors getElementsByTagName sensor -depth 1] {
            set un [$sensor getElementsByTagName userName -depth 1]
            if {[llength $un] != 1} {continue}
            set name [$un data]
            if {$name eq $userName} {
                return $sensor
            }
        }
    }
}


    
