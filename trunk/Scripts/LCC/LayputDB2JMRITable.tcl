#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 10 07:13:36 2021
#  Last Modified : <210710.0953>
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


## @page LayputDB2JMRITable LayoutDB to JMRI Tables converter
# @brief Converts a LayoutDB file to a JMRI Table file
#
# @section LayputDB2JMRITableSYNOPSIS SYNOPSIS
# @section LayputDB2JMRITableDESCRIPTION DESCRIPTION
# @section LayputDB2JMRITablePARAMETERS PARAMETERS
# @section LayputDB2JMRITableOPTIONS OPTIONS
# @section LayputDB2JMRITableAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] JMRITable2LayputDB]

package require snit
package require LayoutControlDB
package require ParseXML
package require gettext
package require LCC

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]

snit::type LayputDB2JMRITable {
    typevariable EmptyTableXML {<?xml version="1.0" encoding="UTF-8"?>
        <layout-config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://jmri.org/xml/schema/layout-4-19-2.xsd">
        <jmriversion>
        <major>4</major>
        <minor>22</minor>
        <test>0</test>
        <modifier />
        </jmriversion>
        <sensors class="jmri.jmrix.openlcb.configurexml.OlcbSensorManagerXml" />
        <turnouts class="jmri.jmrix.openlcb.configurexml.OlcbTurnoutManagerXml">
        <operations automate="false">
        <operation name="NoFeedback" class="jmri.configurexml.turnoutoperations.NoFeedbackTurnoutOperationXml" interval="300" maxtries="2" />
        <operation name="Raw" class="jmri.configurexml.turnoutoperations.RawTurnoutOperationXml" interval="300" maxtries="1" />
        <operation name="Sensor" class="jmri.configurexml.turnoutoperations.SensorTurnoutOperationXml" interval="300" maxtries="3" />
        </operations>
        <defaultclosedspeed>Normal</defaultclosedspeed>
        <defaultthrownspeed>Restricted</defaultthrownspeed>
        </turnouts>
        <lights class="jmri.jmrix.openlcb.configurexml.OlcbLightManagerXml" />
        <reporters class="jmri.jmrix.internal.configurexml.InternalReporterManagerXml" />
        <signalmasts class="jmri.managers.configurexml.DefaultSignalMastManagerXml" />
        <blocks class="jmri.configurexml.BlockManagerXml">
        <defaultspeed>Normal</defaultspeed>
        </blocks>
        <signalmastlogics class="jmri.managers.configurexml.DefaultSignalMastLogicManagerXml">
        <logicDelay>500</logicDelay>
        </signalmastlogics>
        <filehistory />
        </layout-config>}
    typevariable JMRIPREAMBLE {<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="/xml/XSLT/panelfile-4-19-2.xsl" type="text/xsl"?>}
    typevariable _jmriTable
    typevariable _layout_config
    typevariable _filehistory
    typevariable _sensors
    typevariable _turnouts
    typevariable _lights
    typevariable _reporters
    typevariable _blocks
    typevariable _layoutDB
    typeconstructor {
        if {[llength $::argv] < 2} {
            puts stderr [_ "Missing arguments: infile outfile"]
            exit 99
        }
        set _jmriTable [ParseXML %%AUTO%% $EmptyTableXML]
        set _layout_config [$_jmriTable getElementsByTagName layout-config -depth 1]
        $_layout_config setAttribute xmlns:xsi "http://www.w3.org/2001/XMLSchema-instance"
        set _filehistory [$_layout_config getElementsByTagName filehistory -depth 1]
        set _sensors [$_layout_config getElementsByTagName sensors -depth 1]
        set _turnouts [$_layout_config getElementsByTagName turnouts -depth 1]
        set _lights [$_layout_config getElementsByTagName lights -depth 1]
        set _reporters [$_layout_config getElementsByTagName reporters -depth 1]
        set _blocks [$_layout_config getElementsByTagName blocks -depth 1]
        set op [[$_filehistory info type] create %%AUTO%% -tag operation]
        $_filehistory addchild $op
        set tp [[$op info type] create %%AUTO%% -tag type]
        $op addchild $tp
        $tp setdata app
        set date [[$op info type] create %%AUTO%% -tag date]
        $op addchild $date
        $date setdata [clock format [clock seconds] -format "%+"]
        set fn  [[$op info type] create %%AUTO%% -tag filename]
        $op addchild $fn
        $fn setdata {LayputDB2JMRITable program}
        set _layoutDB [::lcc::LayoutControlDB olddb [lindex $::argv 0]]
        set layout [$_layoutDB getElementsByTagName layout -depth 1]
        foreach turnout [$layout getElementsByTagName turnout -depth 1] {
            _createJMRIturnout $turnout
        }
        foreach block [$layout getElementsByTagName block -depth 1] {
            _createJMRIblock $block
        }
        foreach sensor [$layout getElementsByTagName sensor  -depth 1] {
            _createJMRIsensor $sensor
        }
        set outfile [lindex $::argv 1]
        if {[catch {open $outfile w} fp]} {
            puts stderr [_ "Could not open file: %s because %s" $filename $fp]
            exit 99
        }
        puts $fp $JMRIPREAMBLE
        set op [[$_filehistory info type] create %%AUTO%% -tag operation]
        $_filehistory addchild $op
        set tp [[$op info type] create %%AUTO%% -tag type]
        $op addchild $tp
        $tp setdata Store
        set date [[$op info type] create %%AUTO%% -tag date]
        $op addchild $date
        $date setdata [clock format [clock seconds] -format "%+"]
        set fn  [[$op info type] create %%AUTO%% -tag filename]
        $op addchild $fn
        $fn setdata $outfile
        $_jmriTable displayTree $fp
        close $fp
    }
    proc _createJMRIturnout {turnout} {
        puts stderr "*** _createJMRIturnout $turnout"
        set name [[$turnout getElementsByTagName name -depth 1] data]
        set points [$turnout getElementsByTagName points -depth 1]
        set norm [[$points getElementsByTagName normal  -depth 1] data]
        set rev  [[$points getElementsByTagName reverse -depth 1] data]
        set pointsSense ${name}_points
        _makeJMRISensor $pointsSense $norm $rev
        set motor [$turnout getElementsByTagName motor -depth 1]
        set norm [[$motor getElementsByTagName normal  -depth 1] data]
        set rev  [[$motor getElementsByTagName reverse -depth 1] data]
        set jmri_turnout [[$_turnouts info type] create %AUTO% -tag turnout]
        $jmri_turnout setAttribute feedback ONESENSOR
        $jmri_turnout setAttribute sensor1  $pointsSense
        $jmri_turnout setAttribute inverted false
        $jmri_turnout setAttribute automate Off
        $_turnouts addchild $jmri_turnout
        set sn [[$jmri_turnout info type] create %AUTO% -tag systemName]
        $sn setdata [format {MT%s;%s} $norm $rev]
        $jmri_turnout addchild $sn
        set un [[$jmri_turnout info type] create %AUTO% -tag userName]
        $un setdata $name
        $jmri_turnout addchild $un
    }
    proc _makeJMRISensor {name on off} {
        puts stderr "*** _makeJMRISensor $name $on $off"
        set jmri_sensor [[$_sensors info type] create %AUTO% -tag sensor]
        $_sensors addchild $jmri_sensor
        set sn [[$jmri_sensor info type] create %AUTO% -tag systemName]
        $sn setdata [format {MS%s;%s} $on $off]
        $jmri_sensor addchild $sn
        set un [[$jmri_sensor info type] create %AUTO% -tag userName]
        $un setdata $name
        $jmri_sensor addchild $un
    }
    typevariable _blockCount 0
    proc _createJMRIblock {block} {
        puts stderr "*** _createJMRIblock $block"
        set name [[$block getElementsByTagName name -depth 1] data]
        set occ  [[$block getElementsByTagName occupied -depth 1] data]
        set clr  [[$block getElementsByTagName clear    -depth 1] data]
        set blockDetector ${name}_detect
        _makeJMRISensor $blockDetector $occ $clr
        set jmri_block [[$_blocks info type] create %AUTO% -tag block]
        $jmri_block setAttribute systemName [format "IB:AUTO:%04d" [incr _blockCount]]
        $jmri_block setAttribute length 0.0
        $jmri_block setAttribute curve 0
        $_blocks addchild $jmri_block
        set sn [[$jmri_block info type] create %AUTO% -tag systemName]
        $sn setdata [$jmri_block attribute systemName]
        $jmri_block addchild $sn
        set un [[$jmri_block info type] create %AUTO% -tag userName]
        $un setdata $name
        $jmri_block addchild $un
        set perm [[$jmri_block info type] create %AUTO% -tag permissive]
        $perm setdata no
        $jmri_block addchild $perm
        set occsense [[$jmri_block info type] create %AUTO% -tag occupancysensor]
        $occsense setdata $blockDetector
        $jmri_block addchild $occsense
    }
    proc _createJMRIsensor {sensor} {
        puts stderr "*** _createJMRIsensor $sensor"
        set name [[$sensor getElementsByTagName name -depth 1] data]
        set on   [[$sensor getElementsByTagName on   -depth 1] data]
        set off  [[$sensor getElementsByTagName off  -depth 1] data]
        _makeJMRISensor $name $on $off
    }
}

