#!/usr/bin/tclsh
#* 
#* ------------------------------------------------------------------
#* SwigInternalsBook.tcl - Post process Swig documentation generation.
#* Created by Robert Heller on Tue Nov 15 12:27:44 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/20 09:46:33  heller
#* Modification History: Nov. 20, 2005 Lockdown
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
#!/usr/bin/tclsh
#* 
#* ------------------------------------------------------------------
#* SwigInternalsBook.tcl - Post process Swig documentation generation
#* Created by Robert Heller on Tue Nov 15 12:28:11 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/20 09:46:33  heller
#* Modification History: Nov. 20, 2005 Lockdown
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
#'\Label' => '\label'
#'\Ref' => '\ref'
#^'  / ' => '    '
#^'  * ' => '    '
#
#@param word  => \item[word], first inserts:
#\makebox[1in][l]{\textbf{Parameters:}}\begin{minipage}[t]{5in}\begin{description}
#After last: \end{description}\end{minipage}

proc FixDocxxLaTeX {line} {
  regsub -all {\\Label} "$line" {\label} line
  regsub -all {\\Ref}   "$line" {\ref} line
  regsub -all {[[:space:]]*/ }   "$line" { } line
  regsub -all {[[:space:]]*/$}   "$line" {} line
  regsub -all {[[:space:]]*\* }  "$line" { } line
  regsub -all {[[:space:]]*\*$}  "$line" {} line
  regsub -all {#([^#]*)#} "$line" {\verb=\1=} line
  return "$line"
}

proc FixAtParam {line stateVar} {
  upvar $stateVar state

  if {[regexp {^(.*)@param[[:space:]]*([a-zA-Z0-9_]*)[[:space:]]*(.*)$} \
		"$line" => prefix word restofline] > 0} {
    if {$state != 1} {
      puts {}
      puts {\makebox[1in][l]{\textbf{Parameters:}}\begin{minipage}[t]{5in}\begin{description}}
      set state 1
    }
    regsub -all {_} "$word" {\_} word
    puts "$prefix\\item\[$word\] $restofline"
  } elseif {$state == 1 && [regexp {^\\\\} "$line"] > 0} {
    puts {\end{description}\end{minipage}}
    puts "$line"
    set state 0
  } else {
    puts "$line"
  }
}

while {[gets stdin line] >= 0} {
  if {[string equal {\begin{document}} "$line"]} {break}
}

set state 0

while {[gets stdin line] >= 0} {
  if {[string equal {\end{document}} "$line"]} {break}
  set line [FixDocxxLaTeX "$line"]
  set line [string trim "$line"]
  if {[string equal {} "$line"]} {continue}
  FixAtParam "$line" state 
}

while {[gets stdin line] >= 0} {
}

