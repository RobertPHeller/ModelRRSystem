#* 
#* ------------------------------------------------------------------
#* grsupport.tcl - 
#* Created by Robert Heller on Sun Jul 28 09:58:50 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.9  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.8  2004/04/14 23:08:02  heller
#* Modification History: Various minor updates.
#* Modification History:
#* Modification History: Revision 1.7  2002/09/14 03:02:49  heller
#* Modification History: Split up GR Support into several files. Include LCARS Corner Bitmaps
#* Modification History:
#* Modification History: Revision 1.6  2002/08/29 21:22:22  heller
#* Modification History: Update to use the full space available for the slider
#* Modification History:
#* Modification History: Revision 1.5  2002/08/29 01:03:22  heller
#* Modification History: Add OvalSlider
#* Modification History:
#* Modification History: Revision 1.4  2002/08/21 02:13:29  heller
#* Modification History: Added Oval Scale
#* Modification History:
#* Modification History: Revision 1.2  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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

#@Chapter: grsupport.tcl -- Old (depreciated) Graphics Support code.
# $Id$

proc canvasItemParseConfigSpec {w specs flags argList} {
# canvasItemParseConfigSpec --
#
#	Parses a list of "-option value" pairs. If all options and
#	values are legal, the values are stored in
#	$data($option). Otherwise an error message is returned. When
#	an error happens, the data() array may have been partially
#	modified, but all the modified members of the data(0 array are
#	guaranteed to have valid values. This is different than
#	Tk_ConfigureWidget() which does not modify the value of a
#	widget record if any error occurs.
#
# Arguments:
#
# <in> w = widget record to modify. Must be the pathname of a widget.
#
# <in> specs = {
#    {-commandlineswitch resourceName ResourceClass defaultValue verifier}
#    {....}
# }
#
# <in> flags = currently unused.
#
# <in> argList = The list of  "-option value" pairs.
#

    upvar #0 $w data

    # 1: Put the specs in associative arrays for faster access
    #
    foreach spec $specs {
	if {[llength $spec] < 2} {
	    error "\"spec\" should contain 3 or 2 elements"
	}
	set cmdsw [lindex $spec 0]
	set cmd($cmdsw) ""
	set def($cmdsw)     [lindex $spec 1]
	set verproc($cmdsw) [lindex $spec 2]
    }

    if {[expr [llength $argList] %2] != 0} {
	foreach {cmdsw value} $argList {
	    if ![info exists cmd($cmdsw)] {
	        error "unknown option \"$cmdsw\", must be [tclListValidFlags cmd]"
	    }
	}
	error "value for \"[lindex $argList end]\" missing"
    }

    # 2: set the default values (if not already set)
    #
    foreach cmdsw [array names cmd] {
	if {![info exists data($cmdsw)]} {
	  set data($cmdsw) $def($cmdsw)
	}
    }

    # 3: parse the argument list
    #
    foreach {cmdsw value} $argList {
	if ![info exists cmd($cmdsw)] {
	    error "unknown option \"$cmdsw\", must be [tclListValidFlags cmd]"
	}
	if {[string length "$verproc($cmdsw)"] > 0} {
	  if {[catch [list $verproc($cmdsw) $value] error]} {
	    global errorInfo
	    error "$w: bad value for $cmdsw: $value: $error" $errorInfo
	  }
	}
	set data($cmdsw) $value
    }

    # Done!
}

proc VerifyDouble {x} {
# Validation routine for doubles.
# <in> x Value to check

  expr double($x)
}

proc VerifyOrientationHV {x} {
# Validation routine for orientation (horizontal or vertical).
# <in> x Value to check

  if {[lsearch -exact {horizontal vertical} "$x"] < 0} {
    error "Bad orientation, should be one of horizontal or vertical"
  }
}

proc VerifyBool {x} {
# Validation routine for booleans.
# <in> x Value to check

  if {$x} {} {}
}

proc VerifyColor {x} {
# Validation routine for colors.
# <in> x Value to check

  winfo rgb . "$x"
}

package provide grsupport 1.0
