#* 
#* ------------------------------------------------------------------
#* ExtraTixWidgets.tcl - Extra Tix Widgets
#* Created by Robert Heller on Fri Oct 28 11:55:02 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
#* Modification History: Nov 4, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 
#* 
#* $Id$
#*
package require Tix

tixWidgetClass tixLabelValue {
    -classname TixLabelValue
    -superclass tixLabelWidget
    -method {
    }
    -flag {
	-value
    }
    -static {
    }
    -configspec {
	{-value value Value {}}
    }
    -default {
	{.borderWidth 			0}
	{*label.anchor			e}
	{*label.borderWidth		0}
    }
}

proc tixLabelValue:ConstructFramedWidget {w frame} {
    upvar #0 $w data

    tixChainMethod $w ConstructFramedWidget $frame

    set data(w:value)  [label $frame.value -borderwidth 2 -relief sunken -bg white]
    pack $data(w:value) -side left -expand yes -fill both

}

#----------------------------------------------------------------------
#                           CONFIG OPTIONS
#----------------------------------------------------------------------
proc tixLabelValue:config-value {w value} {
    upvar #0 $w data

    $data(w:value) configure -text "$value"
}



package provide ExtraTixWidgets 1.0
