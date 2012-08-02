#* 
#* ------------------------------------------------------------------
#* Role PlayingDB V2.0 by Deepwoods Software
#* ------------------------------------------------------------------
#* IndexHH.tcl - index.hh builder
#* Created by Robert Heller on Tue Apr 20 00:56:39 1999
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

global argc argv
if {$argc < 2} {
  error "Missing args!"
}

set HelpIndex [lindex $argv 0]
set IndexHH   [lindex $argv 1]

if {[catch [list open $HelpIndex r] indxFp]} {
  error "open: $HelpIndex: $indxFp"
}

set indexList {}

while {[gets $indxFp line] >= 0} {
  set key [lindex $line 0]
  set klist [split $key {>}]
  set indexItem [lindex $klist end]
  lappend indexList "$indexItem"
}

close $indxFp

if {[catch [list open $IndexHH w] ihhFp]} {
  error "open: $IndexHH: $ihhFp"
}

puts $ihhFp "0 Index"

foreach k [lsort $indexList] {
  puts $ihhFp "<$k>"
}

close $ihhFp


if {[catch [list open $HelpIndex a] indxFp]} {
  error "open: $HelpIndex: $indxFp"
}

puts $indxFp [list Index [list $IndexHH 0]]
close $indxFp
