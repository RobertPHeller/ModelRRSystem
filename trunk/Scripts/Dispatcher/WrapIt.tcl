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

namespace eval WrapIt {
  variable TclKit {}
  variable HasTested no
  variable PackageBaseDir {}
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
  proc CheckPackageBaseDir {} {
    variable PackageBaseDir
    #puts stderr "*** WrapIt::CheckPackageBaseDir (at start): PackageBaseDir = '$PackageBaseDir'"
    if {$PackageBaseDir ne {}} {return}
    set bindir [file dirname [info nameofexecutable]]
    #puts stderr "*** WrapIt::CheckPackageBaseDir: bindir = $bindir"
    set instdir [file dirname $bindir]
    #puts stderr "*** WrapIt::CheckPackageBaseDir: instdir = $instdir"
    if {[file isdirectory [file join $instdir XPressNet]] &&
	[file isdirectory [file join $instdir RailDriverSupport]] &&
	[file isdirectory [file join $instdir NCE]]} {
      # Running from Build dir
      set PackageBaseDir $instdir
    } elseif {[file isdirectory [file join $instdir share]] &&
	      [file isdirectory [file join $instdir share MRRSystem]]} {
      # Running from Install dir
      set PackageBaseDir [file join $instdir share MRRSystem]
    }
    #puts stderr "*** WrapIt::CheckPackageBaseDir (after if): PackageBaseDir = '$PackageBaseDir'"
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
                        [glob -nocomplain [file join $Lib Img*]] \
                        [glob -nocomplain [file join $Lib snit*]] \
                        ]
  #  puts stderr "*** WrapIt::CopyLibDirs = $CopyLibDirs"
  variable CMriLibDir [glob -nocomplain [file join $CodeLibrary CMri]]
  #  puts stderr "*** WrapIt::CMriLibDir = $CMriLibDir"
  variable AzatraxLibDir [glob -nocomplain [file join $CodeLibrary Azatrax]]
  #  puts stderr "*** WrapIt::AzatraxLibDir = $AzatraxLibDir"
  variable ControlSupportDir [glob -nocomplain [file join $CodeLibrary ControlSupport]]
  #  puts stderr "*** WrapIt::ControlSupportDir = $ControlSupportDir"
  variable CTIAcelaLibDir [glob -nocomplain [file join $CodeLibrary CTIAcela]]
  #  puts stderr "*** WrapIt::CTIAcelaLibDir = $CTIAcelaSupportDir"
  variable WiringPiLibDir [glob -nocomplain [file join $CodeLibrary WiringPi]]
  #  puts stderr "*** WrapIt::WiringPiLibDir = $WiringPiLibDir"
  variable TclSocketCANLibDir [glob -nocomplain [file join $Lib TclSocketCAN]]
  #  puts stderr "*** WrapIt::TclSocketCANLibDir = $TclSocketCANLibDir"
  variable OpenLCBLibDir [glob -nocomplain [file join $CodeLibrary LCC]]
  #  puts stderr "*** WrapIt::OpenLCBLibDir = $OpenLCBLibDir"
  variable XMLLibDir [glob -nocomplain [file join $Lib Tclxml*]]
  #  puts stderr "*** WrapIt::XMLLibDir = $XMLLibDir"
  variable URILibDir [glob -nocomplain [file join $Lib uri]]
  #  puts stderr "*** WrapIt::URILibDir = $URILibDir"
  variable PDF4tcl05Dir [glob -nocomplain [file join $Lib pdf4tcl05]]
  #  puts stderr "*** WrapIt::PDF4tcl05Dir = $PDF4tcl05Dir"
  variable STRUCTLibDir [glob -nocomplain [file join $Lib struct]]
  #  puts stderr "*** WrapIt::STRUCTLibDir = $STRUCTLibDir"
  variable CSVLibDir [glob -nocomplain [file join $Lib csv]]
  #  puts stderr "*** WrapIt::CSVLibDir = $CSVLibDir"
  variable CopyCommonLibFiles [list \
    [file join $Lib Common snitStdMenuBar.tcl] \
    [file join $Lib Common mainwindow.tcl] \
    [file join $Lib Common snitmainframe.tcl] \
    [file join $Lib Common DynamicHelp.tcl] \
    [file join $Lib Common snitbuttonbox.tcl] \
    [file join $Lib Common snitHTMLHelp.tcl] \
    [file join $Lib Common IconsAndImages.tcl] \
    [file join $Lib Common snitscrollw.tcl] \
    [file join $Lib Common snitscrollableframe.tcl] \
    [file join $Lib Common CTCPanel2.tcl] \
    [file join $Lib Common grsupport2.tcl] \
    [file join $Lib Common snitLFs.tcl] \
    [file join $Lib Common gettext.tcl] \
    [file join $Lib Common Version.tcl] \
    [file join $Lib Common ParseXML.tcl] \
    [file join $Lib Common snitScrollNotebook.tcl] \
    [file join $Lib Common snitdialog.tcl] \
    [file join $Lib Common snitrotext.tcl] \
    [file join $Lib Common unknown.xpm] \
    [file join $Lib Common openfold.png] \
    [file join $Lib Common palette.png] \
    [file join $Lib Common questhead.xbm] \
    [file join $Lib Common gray50.xbm] \
  ]
  #  puts stderr "*** WrapIt::CopyCommonLibFiles = $CopyCommonLibFiles"
  proc mkFileStart {filename} {
      set end [file size $filename]
      if {$end < 27} {
          fail "file too small, cannot be a datafile"
      }
      
      set fd [open $filename]
      fconfigure $fd -translation binary
      seek $fd -16 end
      binary scan [read $fd 16] IIII a b c d
      close $fd
      
      #puts [format %x-%d-%x-%d $a $b $c $d]
      
      if {($c >> 24) != -128} {
          error "this is not a Metakit datafile"
      }
      
      # avoid negative sign / overflow issues
      if {[format %x [expr {$a & 0xffffffff}]] eq "80000000"} {
          set start [expr {$end - 16 - $b}]
      } else {
          # if the file is in commit-progress state, we need to do more
          error "this code needs to be finished..."
      }
      
      return $start
  }

  proc WrapIt {filename writeprogfun {needcmri no} {needazatrax no} {needctiacela no} {needopenlcb no} {additionalPackages {}}} {
    variable TclKit
    variable PackageBaseDir
    set compress 1
    set ropts -readonly
    #puts stderr "*** WrapIt: TclKit is $TclKit"
    file copy $TclKit $filename
    if {![catch { package require Mk4tcl }]} {
        vfs::mk4::Mount $filename $filename
    } elseif {![catch { package require vlerq }]} {
        package require vfs::m2m 1.8
        set outsize [file size $filename]
        #puts stderr "*** Wrapit: outsize = $outsize"
        if {![catch { mkFileStart $filename } mkpos]} {
            #puts stderr "*** Wrapit: mkpos = $mkpos"
            set fd [open $filename]
            fconfigure $fd -translation binary
            set outhead [read $fd $mkpos]
            set origvfs [read $fd]
            close $fd
            set fd [open $filename w]
            fconfigure $fd -translation binary
            puts -nonewline $fd $outhead
            close $fd
        }
        
        vfs::m2m::Mount $filename $filename
        
        if {[info exists origvfs]} {
            set fd [open $filename.tmp w]
            fconfigure $fd -translation binary
            puts -nonewline $fd $origvfs
            close $fd
            
            package require vfs::mkcl
            vfs::mkcl::Mount $filename.tmp $filename.tmp
            array set opts {
                -prune      0
                -verbose    0
                -show       0
                -ignore     ""
                -mtime      0
                -compress   0
                -auto       0
                -noerror    1
                -text       0
            }
            sync::rsync opts $filename.tmp $filename
            
            vfs::unmount $filename.tmp
            file delete $filename.tmp
        }
            
    } else {
        tk_messageBox \
              -type ok -icon error \
              -message [_ "Cannot find required packages (Mk4tcl or Vlerq)"]
        return
    }
    set module [file rootname [file tail $filename]]
    set fp [open [file join $filename main.tcl] w]
    puts $fp "
  package require starkit
  starkit::startup
  package require app-$module
"
    close $fp
    variable CopyLibDirs
    #puts stderr "*** WrapIt::WrapIt: CopyLibDirs = $CopyLibDirs"
    foreach ld $CopyLibDirs {
      #puts stderr "*** WrapIt::WrapIt: ld = $ld"
      #puts stderr "*** WrapIt::WrapIt: file copy $ld [file join $filename lib [file tail $ld]]"
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
    variable XMLLibDir
    file copy $XMLLibDir [file join $filename lib [file tail $XMLLibDir]]
    variable URILibDir
    file copy $URILibDir [file join $filename lib [file tail $URILibDir]]
    variable PDF4tcl05Dir
    file copy $PDF4tcl05Dir [file join $filename lib [file tail $PDF4tcl05Dir]]
    variable STRUCTLibDir
    file copy $STRUCTLibDir [file join $filename lib [file tail $STRUCTLibDir]]
    variable CSVLibDir
    file copy $CSVLibDir [file join $filename lib [file tail $CSVLibDir]]
    if {$needcmri} {
      variable CMriLibDir
      variable ControlSupportDir  
      file copy $CMriLibDir [file join $filename lib [file tail $CMriLibDir]]
      file copy $ControlSupportDir [file join $filename lib [file tail $ControlSupportDir]]
    }
    if {$needazatrax} {
      variable AzatraxLibDir
      file copy $AzatraxLibDir [file join $filename lib [file tail $AzatraxLibDir]]
    }
    if {$needctiacela} {
        variable CTIAcelaLibDir
        file copy $CTIAcelaLibDir [file join $filename lib [file tail $CTIAcelaLibDir]]
    }
    variable WiringPiLibDir
    if {$WiringPiLibDir ne ""} {
        file copy $WiringPiLibDir [file join $filename lib [file tail $WiringPiLibDir]]
    }
    if {$needopenlcb} {
        variable OpenLCBLibDir
        file copy $OpenLCBLibDir [file join $filename lib [file tail $OpenLCBLibDir]]
        variable TclSocketCANLibDir
        if {$TclSocketCANLibDir ne ""} {
            file copy $TclSocketCANLibDir [file join $filename lib [file tail $TclSocketCANLibDir]]
        }
    }
    foreach ap $additionalPackages {
      file mkdir [file join $filename lib $ap]
      foreach f [glob -nocomplain [file join $PackageBaseDir $ap *.tcl]] {
        file copy $f [file join $filename lib $ap]
      }
    }
    set lib [file join $filename lib]
    file mkdir [file join $lib app-$module]
    set fp [open [file join $lib app-$module $module.tcl] w]
    eval $writeprogfun $fp $module yes $lib
    close $fp
    set fp [open [file join $lib app-$module pkgIndex.tcl] w]
    puts $fp "package ifneeded app-$module 1.0 \[list source \[file join \$dir $module.tcl\]\]"
    close $fp
    vfs::unmount $filename
  }
}

namespace eval sync {
    # Synchronize two directory trees, VFS-aware
    #
    # Copyright (c) 1999 Matt Newman, Jean-Claude Wippler and Equi4 Software.
    
    #
    # Recursively sync two directory structures
    #
    proc rsync {arr src dest} {
        #tclLog "rsync $src $dest"
        upvar 1 $arr opts
        
        if {$opts(-auto)} {
            # Auto-mounter
            vfs::auto $src -readonly
            vfs::auto $dest
        }
        
        if {![file exists $src]} {
            return -code error "source \"$src\" does not exist"
        }
        if {[file isfile $src]} {
            #tclLog "copying file $src to $dest"
            return [rcopy opts $src $dest]
        }
        if {![file isdirectory $dest]} {
            #tclLog "copying non-file $src to $dest"
            return [rcopy opts $src $dest]
        }
        set contents {}
        eval lappend contents [glob -nocomplain -dir $src *]
        eval lappend contents [glob -nocomplain -dir $src .*]
        
        set count 0		;# How many changes were needed
        foreach file $contents {
            #tclLog "Examining $file"
            set tail [file tail $file]
            if {$tail == "." || $tail == ".."} {
                continue
            }
            set target [file join $dest $tail]
            
            set seen($tail) 1
            
            if {[info exists opts(ignore,$file)] || \
                      [info exists opts(ignore,$tail)]} {
                if {$opts(-verbose)} {
                    tclLog "skipping $file (ignored)"
                }
                continue
            }
            if {[file isdirectory $file]} {
                incr count [rsync opts $file $target]
                continue
            }
            if {[file exists $target]} {
                #tclLog "target $target exists"
                # Verify
                file stat $file sb
                file stat $target nsb
                #tclLog "$file size=$sb(size)/$nsb(size), mtime=$sb(mtime)/$nsb(mtime)"
                if {$sb(size) == $nsb(size)} {
                    # Copying across filesystems can yield a slight variance
                    # in mtime's (typ 1 sec)
                    if { ($sb(mtime) - $nsb(mtime)) < $opts(-mtime) } {
                        # Good
                        continue
                    }
                }
                #tclLog "size=$sb(size)/$nsb(size), mtime=$sb(mtime)/$nsb(mtime)"
            }
            incr count [rcopy opts $file $target]
        }
        #
        # Handle stray files
        #
        if {$opts(-prune) == 0} {
            return $count
        }
        set contents {}
        eval lappend contents [glob -nocomplain -dir $dest *]
        eval lappend contents [glob -nocomplain -dir $dest .*]
        foreach file $contents {
            set tail [file tail $file]
            if {$tail == "." || $tail == ".."} {
                continue
            }
            if {[info exists seen($tail)]} {
                continue
            }
            rdelete opts $file
            incr count
        }
        return $count
    }
    proc _rsync {arr args} {
        upvar 1 $arr opts
        #tclLog "_rsync $args ([array get opts])"
        
        if {$opts(-show)} {
            # Just show me, don't do it.
            tclLog $args
            return
        }
        if {$opts(-verbose)} {
            tclLog $args
        }
        if {[catch {eval $args} err]} {
            if {$opts(-noerror)} {
                tclLog "Warning: $err"
            } else {
                return -code error -errorinfo ${::errorInfo} $err 
            }
        }
    }
    
    # This procedure is better than just 'file copy' on Windows,
    # MacOS, where the source files probably have native eol's,
    # but the destination should have Tcl/unix native '\n' eols.
    # We therefore need to handle text vs non-text files differently.
    proc file_copy {src dest {textmode 0}} {
        set mtime [file mtime $src]
        if {!$textmode} {
            file copy $src $dest
        } else {
            switch -- [file extension $src] {
                ".tcl" -
                ".txt" -
                ".msg" -
                ".test" -
                ".itk" {
                }
                default {
                    if {[file tail $src] != "tclIndex"} {
                        # Other files are copied as binary
                        #return [file copy $src $dest]
                        file copy $src $dest
                        file mtime $dest $mtime
                        return
                    }
                }
            }
            # These are all text files; make sure we get
            # the translation right.  Automatic eol 
            # translation should work fine.
            set fin [open $src r]
            set fout [open $dest w]
            fcopy $fin $fout
            close $fin
            close $fout
        }
        file mtime $dest $mtime
    }
    
    proc rcopy {arr path dest} {
        #tclLog "rcopy: $arr $path $dest"
        upvar 1 $arr opts
        # Recursive "file copy"
        
        set tail [file tail $dest]
        if {[info exists opts(ignore,$path)] || \
                  [info exists opts(ignore,$tail)]} {
            if {$opts(-verbose)} {
                tclLog "skipping $path (ignored)"
            }
            return 0
        }
        variable rsync_globs
        foreach expr $rsync_globs {
            if {[string match $expr $path]} {
                if {$opts(-verbose)} {
                    tclLog "skipping $path (matched $expr) (ignored)"
                }
                return 0
            }
        }
        if {![file isdirectory $path]} {
            if {[file exists $dest]} {
                _rsync opts file delete $dest
            }
            _rsync opts file_copy $path $dest $opts(-text)
            return 1
        }
        set count 0
        if {![file exists $dest]} {
            _rsync opts file mkdir $dest
            set count 1
        }
        set contents {}
        eval lappend contents [glob -nocomplain -dir $path *]
        eval lappend contents [glob -nocomplain -dir $path .*]
        #tclLog "copying entire directory $path, containing $contents"
        foreach file $contents {
            set tail [file tail $file]
            if {$tail == "." || $tail == ".."} {
                continue
            }
            set target [file join $dest $tail]
            incr count [rcopy opts $file $target]
        }
        return $count
    }
    proc rdelete {arr path} {
        upvar 1 $arr opts 
        # Recursive "file delete"
        if {![file isdirectory $path]} {
            _rsync opts file delete $path
            return
        }
        set contents {}
        eval lappend contents [glob -nocomplain -dir $path *]
        eval lappend contents [glob -nocomplain -dir $path .*]
        foreach file $contents {
            set tail [file tail $file]
            if {$tail == "." || $tail == ".."} {
                continue
            }
            rdelete opts $file
        }
        _rsync opts file delete $path
    }
    proc rignore {arr args} {
        upvar 1 $arr opts 
        
        foreach file $args {
            set opts(ignore,$file) 1
        }
    }
    proc rpreserve {arr args} {
        upvar 1 $arr opts 
        
        foreach file $args {
            catch {unset opts(ignore,$file)}
        }
    }
    proc rignore_globs {args} {
        variable rsync_globs
        set rsync_globs $args
    }
    rignore_globs {}
}

package provide WrapIt 1.0
    
