#* 
#* ------------------------------------------------------------------
#* FCFCreOrders.tcl - Write orders file
#* Created by Robert Heller on Sat Nov 17 15:02:23 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
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
package require tile
package require LabelFrames
package require ScrollWindow
package require ScrollableFrame

namespace eval FCFCreOrders {
  variable OrdersPage
  variable OrdersPageFR
  variable OrdersListFR
  variable OrdersListIndex 0
}

proc FCFCreOrders::FCFCreOrders {notebook} {
  variable OrdersPage [ttk::frame $notebook.orders]
  $notebook insert end $OrdersPage -text [_m "Tab|Orders File"]
  set OrdersPageSW [ScrolledWindow $OrdersPage.sw \
				-auto vertical -scrollbar vertical]
  pack $OrdersPageSW -expand yes -fill both
  variable OrdersPageFR  [ScrollableFrame $OrdersPageSW.fr \
						-constrainedwidth yes]
  pack $OrdersPageFR -expand yes -fill both
  $OrdersPageSW setwidget $OrdersPageFR
  set frame [$OrdersPageFR getframe]

  variable OrdersListFR [frame $frame.ordersListFR]
  pack $OrdersListFR -expand yes -fill both
  variable OrdersListIndex 0
  grid [ttk::label $OrdersListFR.trainHead -text [_m "Label|Train"]] \
	-row 0 -column 0 -sticky nw
  grid columnconfigure $OrdersListFR 0 -weight 1
  grid [ttk::label $OrdersListFR.commaAHead -text {,}] \
        -row 0 -column 1 -sticky nw
  grid [ttk::label $OrdersListFR.orderHead -text [_m "Label|Order"]] \
	-row 0 -column 2 -sticky nw
  grid columnconfigure $OrdersListFR 2 -weight 10
  grid [ttk::label $OrdersListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 3 -sticky nw
  pack [ttk::button $frame.addOrder -text [_m "Button|Add Order"] \
					-command FCFCreOrders::AddOrder] \
	-anchor w
}

proc FCFCreOrders::AddOrder {} {
  variable OrdersListFR
  variable OrdersListIndex

  set lastrow [lindex [grid size $OrdersListFR] 1]
  grid [ttk::entry $OrdersListFR.train$OrdersListIndex -width 6] \
	-row $lastrow -column 0 -sticky new
  grid [ttk::label $OrdersListFR.commaA$OrdersListIndex -text {,}] \
        -row $lastrow -column 1 -sticky nw
  grid [ttk::entry $OrdersListFR.order$OrdersListIndex] \
	-row $lastrow -column 2 -sticky new
  grid [ttk::button $OrdersListFR.delete$OrdersListIndex -text [_m "Button|Delete"]\
			-command "FCFCreOrders::DeleteOrder $OrdersListIndex"] \
	-row $lastrow -column 3 -sticky nw
  incr OrdersListIndex  
}

proc FCFCreOrders::DeleteOrder {index} {
  variable OrdersListFR
  variable OrdersListIndex

  if {![winfo exists $OrdersListFR.train$index]} {return}
  foreach f {train commaA order delete} {
    grid forget $OrdersListFR.$f$index
    destroy $OrdersListFR.$f$index
  }
}

proc FCFCreOrders::ResetForm {} {
  variable OrdersListFR
  variable OrdersListIndex

  for {set i 0} {$i < $OrdersListIndex} {incr i} {DeleteOrder $i}
  set OrdersListIndex 0
}

proc FCFCreOrders::ValidateOrdersFile {} {
  return true
}

proc FCFCreOrders::WriteOrders {directory filename} {
  variable OrdersListFR
  variable OrdersListIndex
  
  if {![file exists "$directory"] || ![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message [_ "%s does not exist or is not a not a folder!" $directory]
    return false
  }
  set oFileName [file join "$directory" "$filename"]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
    return false
  }
  for {set i 0} {$i < $OrdersListIndex} {incr i} {
    if {![winfo exists $OrdersListFR.train$i]} {continue}
    puts -nonewline $ofp "[$OrdersListFR.train$i cget -text],"
    puts            $ofp "\"[$OrdersListFR.order$i cget -text]\""
  }
  close $ofp
  return true
}

package provide FCFCreOrders 1.0

