#* 
#* ------------------------------------------------------------------
#* Role PlayingDB V2.0 by Deepwoods Software
#* ------------------------------------------------------------------
#* HelpIndexBuild.tcl - Help Index Builder
#* Created by Robert Heller on Tue Apr 20 00:56:13 1999
#* ------------------------------------------------------------------
#* Modification History: 
#* $Log$
#* Revision 1.1  2005/11/04 19:06:33  heller
#* Nov 4, 2005 Lockdown
#*
#* Revision 1.1  2000/11/09 21:41:12  heller
#* Pre-release 2.1 up to speed
#*
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Role Playing DB -- A database package that creates and maintains
#* 		       a database of RPG characters, monsters, treasures,
#* 		       spells, and playing environments.
#* 
#*     Copyright (C) 1995,1998,1999  Robert Heller D/B/A Deepwoods Software
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

global HLinePattern
set HLinePattern {^([0-9]+)[ 	](.*)$}

global argc argv
global SourceDir
set SourceDir {}

if {[string equal [lindex $argv 0] "-sourcedir"]} {
  set SourceDir "[lindex $argv 1]"
  set argv [lrange $argv 2 end]
  incr argc -2
}

if {$argc < 2} {
  error "Missing args!"
}

if {[catch [list open [lindex $argv 0] w] indexfp]} {
  error "open: [lindex $argv 0]: $indexfp"
}

for {set i 1} {$i < $argc} {incr i} {
  set file [lindex $argv $i]
#  puts stderr "*** file = $file, [file join $SourceDir $file]"
  if {[catch {open "$file" r} hfp] &&
      [catch {open [file join "$SourceDir" "$file"] r} hfp]} {
    puts stderr "Warning: open $file: $hfp"
    puts stderr "Skiping: $file"
    continue
  }
  set prefixList {}
  set pos [tell $hfp]
  while {[gets $hfp line] >= 0} {
    global HLinePattern
    if {[regexp "$HLinePattern" "$line" whole level heading] > 0} {
      if {$level < [llength $prefixList]} {
	if {$level == 0} {
	  set prefixList {}
        } else {
	  set prefixList [lrange $prefixList 0 [expr $level -1]]
	}
      }
      lappend prefixList "$heading"
      puts $indexfp [list [join $prefixList {>}] [list $file $pos]]
    }
    set pos [tell $hfp]
  }
  close $hfp
}



