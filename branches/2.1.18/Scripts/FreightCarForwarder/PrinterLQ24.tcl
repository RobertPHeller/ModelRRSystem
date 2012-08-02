#* 
#* ------------------------------------------------------------------
#* PrinterLQ24.tcl - Printer code for LQ24 (Epson 24-pin) compatible printers.
#* Created by Robert Heller on Mon Aug  5 18:11:59 1996
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
set PrinterTypes(LQ24) {Epson 24pin Printer}
global PrinterLQ24Column
set PrinterLQ24Column 0


proc putPrinterDoubleLQ24 {} {
  global Printer
  puts -nonewline $Printer "[format %c 14]"    
}
proc putPrinterLineLQ24 {string} {
  global Printer
  puts $Printer "$string"
  global PrinterLQ24Column
  set PrinterLQ24Column 0
}

proc putPrinterNarrowLQ24 {} {
  global Printer
  puts -nonewline $Printer "[format %c 15]"
}
proc putPrinterNewPageLQ24 {} {
  global Printer
  puts -nonewline $Printer "[format %c 12]"
}
proc putPrinterNormalLQ24 {} {
  global Printer
  puts -nonewline $Printer "[format %c 18]"
}
proc putPrinterStringLQ24 {string} {
  global Printer
  puts -nonewline $Printer "$string"
  global PrinterLQ24Column
  incr PrinterLQ24Column [string length "$string"]
}

proc putPrinterTabLQ24 {column} {
  global Printer
  global PrinterLQ24Column
  while {$PrinterLQ24Column < $column} {
    puts -nonewline $Printer { }
    incr PrinterLQ24Column
  }
}

proc putPrinterInitLQ24 {} {
  global Printer
  global PrinterLQ24Column
  set PrinterLQ24Column 0
  puts -nonewline $Printer "[format %c%c 20 18]"
}

proc putPrinterTrailerLQ24 {} {
  global Printer
  puts $Printer "[format %c 18]"
}

