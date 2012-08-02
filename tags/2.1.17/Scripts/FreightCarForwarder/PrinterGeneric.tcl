#* 
#* ------------------------------------------------------------------
#* PrinterGeneric.tcl - Generic printer code.  Can be used as a template for a new printer type.
#* Created by Robert Heller on Mon Aug  5 18:10:36 1996
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2004/05/30 19:00:25  heller
#* Modification History: Added in Tcl port of Freight Car Forwarder.
#* Modification History:
#* Modification History: Revision 1.1  1996/08/05 22:12:26  heller
#* Modification History: Initial revision
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
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
# 
global PrinterTypes
set PrinterTypes(Generic) {Generic Printer}
global PrinterGenericColumn
set PrinterGenericColumn 0


proc putPrinterDoubleGeneric {} {}
proc putPrinterLineGeneric {string} {
  global Printer
  puts $Printer "$string"
  global PrinterGenericColumn
  set PrinterGenericColumn 0
}

proc putPrinterNarrowGeneric {} {}
proc putPrinterNewPageGeneric {} {
  global Printer
  puts -nonewline $Printer "[format %c 12]"
}
proc putPrinterNormalGeneric {} {}
proc putPrinterStringGeneric {string} {
  global Printer
  puts -nonewline $Printer "$string"
  global PrinterGenericColumn
  incr PrinterGenericColumn [string length "$string"]
}

proc putPrinterTabGeneric {column} {
  global Printer
  global PrinterGenericColumn
  while {$PrinterGenericColumn < $column} {
    puts -nonewline $Printer { }
    incr PrinterGenericColumn
  }
}

proc putPrinterInitGeneric {} {
  global PrinterGenericColumn
  set PrinterGenericColumn 0
}
proc putPrinterTrailerGeneric {} {}

