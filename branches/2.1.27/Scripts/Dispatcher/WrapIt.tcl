#* 
#* ------------------------------------------------------------------
#* WrapIt.tcl - Code to wrap a dispatcher file into a starpack.
#* Created by Robert Heller on Thu Jan 27 17:57:03 2011
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 2011  Robert Heller D/B/A Deepwoods Software
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

package require Mk4tcl

namespace eval WrapIt {
  variable TclKit {}
  variable HasTested no
  proc islink {file} {
    set result no
    catch {
	file lstat $file stat
	if {$stat(type) eq "link"} {set result yes}
    }
    return $result
  }
  proc SetTclkit {kit} {
    variable TclKit
    variable HasTested
    if {$kit ne {}} {
      set tclkit $kit
      while {[file exists $tclkit] && [islink $tclkit]} {
	set tclkit [file readlink $tclkit]
      }
      if {[file exists $tclkit] && [file readable $tclkit]} {
	set TclKit $tclkit
      }
      set HasTested yes
    }
  }
  proc CanWrapP {} {
    variable TclKit
    variable HasTested
    if {$HasTested} {return [expr {$TclKit ne ""}]}
    set bindir [file dirname [info nameofexecutable]]
    set tclkit [file join $bindir tclkit[file extension [info nameofexecutable]]]
    while {[file exists $tclkit] && [islink $tclkit]} {
      set tclkit [file readlink $tclkit]
    }
#    puts stderr "*** WrapIt::CanWrapP: bindir = $bindir, tclkit = $tclkit"
    if {[file exists $tclkit] && [file readable $tclkit]} {
      set TclKit $tclkit
    }
    set HasTested yes
    return [expr {$TclKit ne ""}]
  }
  variable Lib [file join [file dirname [file dirname [file dirname [info script]]]] lib]
#  puts stderr "*** WrapIt::Lib = $Lib"
  variable CodeLibrary [file join [file dirname [file dirname [file dirname [info script]]]] CodeLibrary]
#  puts stderr "*** WrapIt::CodeLibrary = $CodeLibrary"
  variable CopyLibDirs [list \
    [glob -nocomplain [file join $Lib bwidget*]] \
    [glob -nocomplain [file join $Lib snit*]] \
  ]
#  puts stderr "*** WrapIt::CopyLibDirs = $CopyLibDirs"
  variable CMriLibDir [glob -nocomplain [file join $CodeLibrary CMri]]
#  puts stderr "*** WrapIt::CMriLibDir = $CMriLibDir"
  variable CopyCommonLibFiles [list \
    [file join $Lib Common BWStdMenuBar.tcl] \
    [file join $Lib Common mainwindow.tcl] \
    [file join $Lib Common CTCPanel2.tcl] \
    [file join $Lib Common grsupport2.tcl] \
    [file join $Lib Common panedw.tcl] \
  ]
#  puts stderr "*** WrapIt::CopyCommonLibFiles = $CopyCommonLibFiles"
  proc WrapIt {filename writeprogfun needcmri} {
    variable TclKit
    set compress 1
    set ropts -readonly
    file copy $TclKit $filename
    vfs::mk4::Mount $filename $filename
    set module [file rootname [file tail $filename]]
    set fp [open [file join $filename main.tcl] w]
    puts $fp "
  package require starkit
  starkit::startup
  package require app-$module
"
    close $fp
    variable CopyLibDirs
    foreach ld $CopyLibDirs {
#      puts stderr "*** WrapIt::WrapIt: ld = $ld"
#      puts stderr "*** WrapIt::WrapIt: file copy $ld [file join $filename lib [file tail $ld]]"
      file copy $ld [file join $filename lib [file tail $ld]]
    }
    variable CopyCommonLibFiles
    file mkdir [file join $filename lib Common]
    set pkgIndex [file join $filename lib Common pkgIndex.tcl]
    set pkgSrcFp [open [file join [info nameofexecutable] lib Common pkgIndex.tcl] r]
    set pkgSrc [read $pkgSrcFp]
    close $pkgSrcFp
    set pkgFp [open $pkgIndex w]
    foreach lf $CopyCommonLibFiles {
      file copy $lf [file join $filename lib Common]
      regexp -line "^(package ifneeded .*\\\$dir [file tail $lf].*)\$" $pkgSrc => pkgLine
#      puts stderr "*** WrapIt::WrapIt: pkgLine = $pkgLine"
      puts $pkgFp "$pkgLine"
    }
    close $pkgFp
    if {$needcmri} {
      variable CMriLibDir
      file copy $CMriLibDir [file join $filename lib [file tail $CMriLibDir]]
    }
    set lib [file join $filename lib]
    file mkdir [file join $lib app-$module]
    set fp [open [file join $lib app-$module $module.tcl] w]
    eval $writeprogfun $fp $module yes
    close $fp
    set fp [open [file join $lib app-$module pkgIndex.tcl] w]
    puts $fp "package ifneeded app-$module 1.0 \[list source \[file join \$dir $module.tcl\]\]"
    close $fp
    vfs::unmount $filename
  }
}

package provide WrapIt 1.0
    
