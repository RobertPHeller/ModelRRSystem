#* 
#* ------------------------------------------------------------------
#* ReadConfiguration.tcl - Read Configuration files.
#* Created by Robert Heller on Sat Mar 12 10:03:59 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/03/20 14:12:19  heller
#* Modification History: March 20 Lock down
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

#@Chapter:ReadConfiguration.tcl -- Read Configuration Files.
#@Label:ReadConfiguration.tcl
#$Id$

namespace eval ReadConfiguration {
# The Read Configuration File code is contained in this namespace.
# [index] ReadConfiguration!namespace|(

  namespace export ReadConfiguration
# Exported Configuration reading function. See ?proc:ReadConfiguration? 
# for this procedure's documentation.
# [index] ReadConfiguration!namespace|)

  namespace export WriteConfiguration
# Exported Configuration reading function. See ?proc:WriteConfiguration? 
# for this procedure's documentation.
# [index] WriteConfiguration!namespace|)
}

proc ReadConfiguration::ReadConfiguration {filename configurationArrayName} {
# [label] proc:ReadConfiguration
# This procedure reads in the configuration file named by the filename into
# the array named by configurationArrayName.
# <in> filename -- The name of the configuration file.
# <in> configurationArrayName -- The name of the array to hold the configuration.
# [index] ReadConfiguration::ReadConfiguration!procedure

  upvar $configurationArrayName configurationArray

  if {[catch [list open "$filename" r] fp]} {
    return [list -1 "Could not open $filename: $fp"]
  }
  set buffer {}
  set lineno 0
  set nl {}
  while {[gets $fp line] >= 0} {
    incr lineno
    if {[regexp {^#} "$line"] > 0} {
      set lineNoComment {}
    } elseif {[regexp {^(.*[^\\]+)#.*$} "$line" -> lineNoComment] < 1} {
      set lineNoComment "$line"
    }
    set lineNoComment [string trim "$lineNoComment"]
    append buffer "$nl$lineNoComment"
    set nl { }
    if {[info complete "$buffer"]} {
      set conflist "$buffer"
      set buffer {}
      set nl {}
      if {[llength "$conflist"] < 1} {
	continue
      } elseif {[llength "$conflist"] < 2} {
	lappend configurationArray(_Anonoymous_) "$conflist"
      } else {
	set name [lindex $conflist 0]
	set keyvalues [lindex $conflist 1]
	if {[llength $keyvalues] > 1 && [IsEven [llength $keyvalues]]} {
	  foreach {k v} $keyvalues {
	    set configurationArray($name:$k) $v
	  }
	} else {
	  set configurationArray($name) $keyvalues
	}
      }
    }
  }
  close $fp
  return [list 0 {}]
}

proc ReadConfiguration::IsEven {i} {
  return [expr ($i & 1) == 0]
}

proc ReadConfiguration::WriteConfiguration {filename configurationArrayName} {
# [label] proc:WriteConfiguration
# This procedure writes the configuration contianed in configurationArrayName
# to the file named by the filename.
# <in> filename -- The name of the configuration file.
# <in> configurationArrayName -- The name of the array holding the configuration.
# [index] ReadConfiguration::WriteConfiguration!procedure

  upvar $configurationArrayName configurationArray

  if {[catch [list open "$filename" w] fp]} {
    return [list -1 "Could not open $filename: $fp"]
  }

  set elements [lsort -dictionary [array names configurationArray]]

  foreach element $elements {
    if {[string equal "$element" _Anonoymous_]} {
      foreach v $configurationArray($element) {
	puts $fp "$v"
      }
      continue
    }
    set nk [split "$element" :]
    if {[llength $nk] == 2} {
      set v $configurationArray($element)
      puts $fp [list [lindex $nk 0] [list [lindex $nk 1] $v]]
    } else {
      set v $configurationArray($element)
      puts $fp [list $element $v]
    }
  }
  close $fp
  return [list 0 {}]
}

package provide ReadConfiguration 1.0

