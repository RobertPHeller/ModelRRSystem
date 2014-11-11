#* 
#* ------------------------------------------------------------------
#* FCFIndustries.tcl - Industry functions
#* Created by Robert Heller on Mon Oct 31 20:14:04 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:38  heller
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

# $Id$

package require gettext
package require Tk

SplashWorkMessage [_ "Loading Industry code"] 30

package require FCFSelectAnIndustryDialog

proc ResetIndustryStatistics {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  TheSystem ResetIndustryStats
}

proc SelectAnIndustry {{titlestring {}}} {

  if {[string equal "$titlestring" {}]} {
    set title [_ "Select an Industry"]
  } else {
    set title [_ "Select a Industry for %s." $titlestring]
  }

  set industry [SelectAnIndustryDialog draw -title "$title"]
#  puts "*** SelectAnIndustry: industry = $industry"
  return $industry
}


package provide FCFIndustries 1.0
