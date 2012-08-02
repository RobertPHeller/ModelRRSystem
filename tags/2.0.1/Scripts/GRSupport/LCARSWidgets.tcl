#* 
#* ------------------------------------------------------------------
#* LCARSWidgets.tcl - LCARS Widgets
#* Created by Robert Heller on Fri Sep 13 22:06:42 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/09/14 03:02:49  heller
#* Modification History: Split up GR Support into several files. Include LCARS Corner Bitmaps
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
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

# $Id$

package require grsupport 1.0

set ScriptDir [file dirname [info script]]

global CornersHFatVNarrow
array set CornersHFatVNarrow [list \
   LL [list @[file join $ScriptDir LLHFatVNarrow.xbm] 132 101 sw] \
   LR [list @[file join $ScriptDir LRHFatVNarrow.xbm] 131 100 se] \
   UL [list @[file join $ScriptDir ULHFatVNarrow.xbm] 131 100 nw] \
   UR [list @[file join $ScriptDir URHFatVNarrow.xbm] 132 101 ne] \
]

global CornersHNarrowVFat
array set CornersHNarrowVFat [list \
   LL [list @[file join $ScriptDir LLHNarrowVFat.xbm] 132 101 sw] \
   LR [list @[file join $ScriptDir LRHNarrowVFat.xbm] 131 100 se] \
   UL [list @[file join $ScriptDir ULHNarrowVFat.xbm] 131 100 nw] \
   UR [list @[file join $ScriptDir URHNarrowVFat.xbm] 132 101 ne] \
]

package provide LCARSWidgets 1.0
