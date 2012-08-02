#* 
#* ------------------------------------------------------------------
#* TTMenuSupport.tcl - Menu support code
#* Created by Robert Heller on Sat Dec 31 11:11:49 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2006/03/06 18:46:21  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:25  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2006/01/03 15:30:22  heller
#* Modification History: Lockdown
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

catch {SplashWorkMessage {Loading Menu Support} 22}

proc UnPostMenu {menu} {
#  global errorInfo
#  puts stderr "*** UnPostMenu: errorInfo = $errorInfo"
  catch {
    upvar #0 $menu data
    $menu unpost
    focus $data(oldfocus)      
  }
}

proc PostMenuOnPointer {menu w} {
  set X [winfo pointerx $w]
  set Y [winfo pointery $w]

#  global errorInfo
#  puts stderr "*** PostMenuOnWidget: errorInfo = $errorInfo"
  $menu activate none
  $menu post $X $Y
  upvar #0 $menu data
  set data(oldfocus) [focus]
  focus $menu
}



package provide TTMenuSupport 1.0
