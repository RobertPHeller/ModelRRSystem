#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Aug 1 17:21:35 2021
#  Last Modified : <210802.0843>
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
package require vfs::zip
package require vfs::mk4
package require ZipArchive
package require gettext
package require RollingStock

set argv0 [file join [file dirname [info nameofexecutable]] [file rootname [file tail [info script]]]]
package require Version
namespace export _*
global ImageDir 
set ImageDir [file join [file dirname [file dirname [info script]]] \
              EILib]
global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
                                                    [info script]]]] Help]
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname\
                                                         [file dirname \
                                                          [info script]]]] \
                                                         Messages]]

snit::type EquipmentInventory {
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no
    
    
}
