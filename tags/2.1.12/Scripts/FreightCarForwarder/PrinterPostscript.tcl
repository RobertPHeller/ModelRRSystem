#* 
#* ------------------------------------------------------------------
#* PrinterPostscript.tcl - Printercodes for a Postscript printer.
#* Created by Robert Heller on Mon Aug  5 18:17:36 1996
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2004/05/30 19:00:25  heller
#* Modification History: Added in Tcl port of Freight Car Forwarder.
#* Modification History:
#* Modification History: Revision 1.1  1996/08/06 02:17:33  heller
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
#
# $Id$
#
global PrinterTypes
set PrinterTypes(Postscript) {Postscript Printer}
global PrinterPostscriptPages
set PrinterPostscriptPages 0
global PrinterPostscriptLines
set PrinterPostscriptLines 0
global PrinterPostscriptPartLine
set PrinterPostscriptPartLine 0


proc putPrinterInitPostscript {} {
  global PrinterPostscriptPages
  set PrinterPostscriptPages 0
  global PrinterPostscriptLines
  set PrinterPostscriptLines 0

  global Printer
  puts $Printer {%!PS-Adobe-2.0
%%Creator:  $Id$
%%Pages: (atend)
%%EndComments
%%BeginProlog
/FCFDict 20 dict def
/FCFDictLocals 10 dict def
FCFDict begin
/inch {72 mul} def
/TopOfPage 10.75 inch def
/LineHeight 12 def
/LeftMargin .25 inch def
/FontName /Courier def
/NormalMatrix [10 0 0 10 0 0] def
/DoubleWMatrix [20 0 0 10 0 0] def
/NarrowMatrix [6 0 0 10 0 0] def
/putPrinterNormal
  { FCFDictLocals begin
    FontName findfont NormalMatrix makefont setfont
    /SpaceWidth ( ) stringwidth pop def
  end } def
/putPrinterNarrow
  { FCFDictLocals begin
    FontName findfont NarrowMatrix makefont setfont
    /SpaceWidth ( ) stringwidth pop def
  end } def
/putPrinterDouble
  { FCFDictLocals begin
    FontName findfont DoubleWMatrix makefont setfont
    /SpaceWidth ( ) stringwidth pop def
  end } def
/putPrinterTab
  { FCFDictLocals begin
    dup CurrentColumn sub dup 0 le 
    {pop pop} 
    {SpaceWidth mul xpos add /xpos exch def /CurrentColumn exch def} ifelse
  end } def
/putPrinterString
  { FCFDictLocals begin
    xpos ypos moveto
    dup stringwidth pop dup 
	SpaceWidth div CurrentColumn add /CurrentColumn exch def 
	xpos add /xpos exch def
    show
  end } def
/newpage
  { FCFDictLocals begin
    showpage
    /xpos LeftMargin def
    /ypos TopOfPage def
    /CurrentColumn 1 def
  end } def
/newline
  { FCFDictLocals begin
    /xpos LeftMargin def
    /ypos ypos LineHeight sub def
    /CurrentColumn 1 def
  end } def
/putPrinterLine
  { putPrinterString
    newline
  } def
FCFDictLocals begin
  /xpos LeftMargin def
  /ypos TopOfPage def
  /CurrentColumn 1 def 
  FontName findfont NormalMatrix makefont setfont
  /SpaceWidth ( ) stringwidth pop def
end
%%EndProlog}
}

proc putPrinterTrailerPostscript {} {
  global Printer
  global PrinterPostscriptPages
  global PrinterPostscriptPartLine
  global PrinterPostscriptLines
  if {$PrinterPostscriptPartLine} {
    putPrinterLinePostscript {}
  }
  if {$PrinterPostscriptLines > 0} {
    putPrinterNewPagePostscript
  }   

  puts $Printer "\n%%Trailer\nend\n%%Pages: $PrinterPostscriptPages\n%%EOF"
}

proc putPrinterDoublePostscript {} {
  global Printer
  puts $Printer {putPrinterDouble}
}

proc putPrinterLinePostscript {string} {
  global Printer
  if {"$string" != {}} {
    puts $Printer "([putPrinterPostscriptQuoteString $string]) putPrinterLine"
  } else {
    puts $Printer {newline}
  }
  global PrinterPostscriptPartLine
  set PrinterPostscriptPartLine 0
  global PrinterPostscriptLines
  incr PrinterPostscriptLines
  if {$PrinterPostscriptLines >= 63} {
    putPrinterNewPagePostscript
  }
}

proc putPrinterNarrowPostscript {} {
  global Printer
  puts $Printer {putPrinterNarrow}
}

proc putPrinterNewPagePostscript {} {
  global Printer
  puts $Printer {newpage}
  global PrinterPostscriptLines
  set PrinterPostscriptLines 0
  global PrinterPostscriptPages
  incr PrinterPostscriptPages
}

proc putPrinterNormalPostscript {} {
  global Printer
  puts $Printer {putPrinterNormal}
}

proc putPrinterStringPostscript {string} {
  global Printer
  puts $Printer "([putPrinterPostscriptQuoteString $string]) putPrinterString"
  global PrinterPostscriptPartLine
  set PrinterPostscriptPartLine 1
}

proc putPrinterTabPostscript {column} {
  global Printer
  puts $Printer "$column putPrinterTab"
}

proc putPrinterPostscriptQuoteString {string} {
#"[\\\\(\\)\\%]"
  regsub -all {[\\\(\)%]} "$string" {\\&} newstring
  return "$newstring" 
}
