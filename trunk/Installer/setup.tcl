set ::CDDir [file dirname [info nameofexecutable]]
#puts stderr "*** ::CDDir = $::CDDir"

set argv0 [file join  [file dirname [info nameofexecutable]] setup]


#	davidw - it took me a while to figure this out, so I thought I'd share 
#	it. Here is a hint how to add things to the windows start menu:
#
#       set groupname SomeCompany
#       set progname  MyProgram
#	set programs_menu [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders} Programs]
#	set menu_dir [file join $programs_menu $groupname]
#	file mkdir $menu_dir
#	file link [file join $menu_dir $progname] $realfilename


package require Diskfree
package require Tk
package require tile
package require snit
package require Version
package require LabelFrames
package require PagesManager
package require ROText
package require MainFrame
package require ScrollWindow
package require ScrollableFrame
#package require HTMLHelp 2.0
if {[string equal $::tcl_platform(platform) windows]} {
  package require vfs::zip
  package require registry
} elseif {[string equal $::tcl_platform(os) Darwin]} {
  package require vfs::zip
}
global ImageDir 
set ImageDir [file join [file dirname [file dirname [info script]]] \
			Images]

#console show

wm withdraw .

#option add *background #2e6150 
#option add *foreground #ffffff

option add *background #2fbff5

proc StateNotValue {w value} {
  upvar $value v
  if {$v} {
    $w configure -state disabled
  } else {
    $w configure -state normal
  }
}

proc SetROTags {twidget} {
  set bts [bindtags $twidget]
  set ti  [lsearch  $bts {Text}]
  if {$ti >= 0} {
    set bts [lreplace $bts $ti $ti HelpText]
  } else {
    set bts [linsert $bts 1 HelpText]
  }
  bindtags $twidget $bts
}

proc CheckFreeSpace {} {
  set sn 0
  if {$::InstallArchives::installDevel} {
    incr sn $::DevelArchiveSize
  }
  if {$::InstallArchives::installBinary} {
    incr sn $::BinaryArchiveSize
  } 
  if {$::InstallArchives::installDocs} {
    incr sn $::DocsArchiveSize
  }
  if {$::InstallArchives::installExamples} {
    incr sn $::ExamplesArchiveSize
  }
  set device "$::DestDisk::destdir"
  while {![file exists $device]} {set device [file dirname $device]}
  set spaceavail [SpaceAvailable [file nativename "$device"]]
  if {$spaceavail > $sn} {return true}
  tk_messageBox -type ok -icon info -parent . -title "Not Enough Space" \
	-message \
"There is not enough space on $::DestDisk::destdir, it only has \n\
[HumanReadableNumber $spaceavail], but [HumanReadableNumber $sn] is needed."
  return false
}

proc CheckFreeSpace2 {} {
  namespace eval AdditionalArchives {
    variable archiveSizes
    variable destdirs
    variable checkedArchives
    foreach a [array names checkedArchives] {
      if {$checkedArchives($a)} {
	set device "$destdirs($a)"
	while {![file exists $device]} {set device [file dirname $device]}
	if {![info exists devspace($device)]} {
	  set devspace($device) [::SpaceAvailable [file nativename "$device"]]
	  set devneeded($device) $archiveSizes($a)
	} else {
	  incr devneeded($device) $archiveSizes($a)
	}
	if {$devneeded($device) > $devspace($device)} {
	  tk_messageBox -type ok -icon info -parent . -title "Not Enough Space" \
		-message \
"There is not enough space on $device for the archives. It has \n\
[HumanReadableNumber $devspace($device)], but \n\
[HumanReadableNumber $devneeded($device)] is needed."
	  return false
	}
      }
    }
  }
  return true
}

namespace eval AdditionalArchives {}

proc AdditionalArchives::CheckAndPopulate {} {
  variable archiveList
  variable archiveSizes
  variable destdirs
  variable selectedArchives
  variable archiveInstallerProcs
  variable pframe
  variable populated

  if {$populated} {return 1}
  set count 0
  set archiveIndex 1
  foreach a [lsort -dictionary [array names archiveList]] {
    if {![file exists [file join $::CDDir $a]]} {continue}
    foreach {descr type flags} $archiveList($a) {break}
#    puts stderr "*** AdditionalArchives::CheckAndPopulate: flags = $flags"
    if {[string equal "$flags" UNIX-only]} {
      if {![string equal $::tcl_platform(platform) unix]} {continue}
#      puts stderr "*** AdditionalArchives::CheckAndPopulate: Including UNIX-only archive $a for platform $::tcl_platform(platform)"
    }
    if {[string equal "$flags" Windows-only]} {
      if {![string equal $::tcl_platform(platform) windows]} {continue}
#      puts stderr "*** AdditionalArchives::CheckAndPopulate: Including Windows-only archive $a for platform $::tcl_platform(platform)"
    }
    switch -exact -- $type {
      unzip {
	::GetSizeAndInstallerProc_UNZIP [file join $::CDDir $a] ::AdditionalArchives::archiveSizes($a) ::AdditionalArchives::archiveInstallerProcs($a)
      }
      copy {
	set archiveSizes($a) [file size [file join $::CDDir $a]]
	set archiveInstallerProcs($a) File_Copy
      }
      tar-xzvf {
	set archiveSizes($a) 0
	set fd [open |[list sh -c "zcat [file join $::CDDir $a]|wc -c"] r]
	fileevent $fd readable [list gets $fd  ::AdditionalArchives::archiveSizes($a)]
	tkwait variable ::AdditionalArchives::archiveSizes($a)
	close $fd
	set archiveInstallerProcs($a) UnixInstallTarxzvf
      }
      tar-xjvf {
	set archiveSizes($a) 0
	set fd [open |[list sh -c "bzcat [file join $::CDDir $a]|wc -c"] r]
	fileevent $fd readable [list gets $fd  ::AdditionalArchives::archiveSizes($a)]
	tkwait variable ::AdditionalArchives::archiveSizes($a)
	close $fd
	set archiveInstallerProcs($a) UnixInstallTarxjvf
      }
    }
    incr count
    set checkedArchives($a) no
    set destdirs($a) "$::env(HOME)"
    set archiveTF [ttk::labelframe $pframe.archiveTF$archiveIndex -text "$a" \
                   -labelanchor nw]
    incr archiveIndex
    pack $archiveTF -expand yes -fill x
    set archiveTFframe $archiveTF
    pack [ttk::label $archiveTFframe.descr -text "$descr"] -expand yes -fill x -anchor w
    pack [LabelEntry $archiveTFframe.size \
			-label "Size:" -labelwidth 15 \
			-text "[HumanReadableNumber $archiveSizes($a)]" \
			-editable no] -expand yes -fill x
    pack [FileEntry $archiveTFframe.dest \
			-label "Destination:" -labelwidth 15 \
			-textvariable ::AdditionalArchives::destdirs($a) \
			-filedialog directory] \
	-expand yes -fill x
    pack [ttk::checkbutton $archiveTFframe.installP -text "Install? " \
			-onvalue yes -offvalue no \
			-variable ::AdditionalArchives::checkedArchives($a)] \
	-fill x -anchor w
  }
  return $count
}

proc GetSizeAndInstallerProc_UNZIP {fullpath sizeVar installerVar} {
  upvar $sizeVar size
  upvar $installerVar installer
  switch -exact -- $::tcl_platform(platform) {
    unix {
      set installer UnixInstallUnZip
      set size 0
      set fd [open "|unzip -l $fullpath" r]
      set ::buffer {}
      fileevent $fd readable [list GetFirstWordLastLine $fd $sizeVar ::buffer]
      tkwait variable $sizeVar
      close $fd
    }
    windows {
      vfs::zip::Mount "$fullpath" tempmount
      set size [DiskUsage tempmount]
      vfs::unmount tempmount
      set installer WindowsInstallVFSZIP
    }
    default {
    }
  }
}

proc DiskUsage {path} {
  set sum 0
  foreach f [glob -nocomplain [file join $path *]] {
    switch [file type $f] {
      file {incr sum [file size $f]}
      directory {incr sum [DiskUsage $f]}
    }
  }
  return $sum
}

proc File_Copy {source destdir logtext} {
  catch {file mkdir $destdir}
  file copy -force $source $destdir
  $logtext insert end "file copy $source $destdir\n"
  $logtext see end
}

proc UnixInstallUnZip {sourcezip destpath logtext} {
  catch {file mkdir $destpath}
  set fd [open |[list unzip -o -a "$sourcezip" -d "$destpath"] r]
  set ::LogDone 0
  fileevent $fd readable [list PipeToLog $fd $logtext]
  tkwait variable ::LogDone
  catch {close $fd}
}

proc GetFirstWordLastLine {fd sizevar bufferVar} {
  upvar $bufferVar buffer
  upvar $sizevar size
  if {[gets $fd newbuffer] < 0} {
    set size [lindex [split [string trim "$buffer"]] 0]
  } else {
    set buffer "$newbuffer"
  }
}
    
proc HumanReadableNumber {n} {
  if {$n < 1024} {
    return "[format {%6d} [expr {int($n)}]]"
  } elseif {$n < 1048576} {
    return "[format {%5.1fK} [expr {double($n) / 1024.0}]]"
  } else {
    return "[format {%5.1fM} [expr {double($n) / 1048576.0}]]"
  }
}

proc FindArchivesAndComputeSizes {} {
  switch -exact -- $::tcl_platform(platform) {
      unix {
          if {$::tcl_platform(os) eq "Darwin"} {
               FindArchivesAndComputeSizes_MacOSX
           } else {
               FindArchivesAndComputeSizes_UNIX
           }
       }
       windows {FindArchivesAndComputeSizes_WINDOWS}
       default {
           tk_messageBox -type ok -parent . -title "Unsupported Platform" \
                 -icon error \
                 -message "The platform, $::tcl_platform(platform), is not supported!"
           exit
       }
   }
}

proc FindArchivesAndComputeSizes_WINDOWS {} {
  # (only 32-bit support at present)
#  puts stderr "*** FindArchivesAndComputeSizes_WINDOWS: ::CDDir = $::CDDir"
  set ::BinaryArchive [file join $::CDDir \
                       MRRSystem-${::MRRSystem::VERSION}-Win32BinOnly.zip]
  #set ::SysBinaryArchive [file join $::CDDir \
  #                        i686-w64-mingw32-4.6-DLLS.zip]
  #set ::SysBinaryArchiveDest "C:/windows/system/"
  set ::InstallArchives::hasSysBinaryArchive no
  set ::BinaryArchiveInstallProc WindowsInstallVFSZIP
  set ::DevelArchive [file join $::CDDir \
	MRRSystem-${::MRRSystem::VERSION}-Win32BinDevel.zip]
  set ::DevelArchiveInstallProc WindowsInstallVFSZIP
  set ::DocsArchive [file join $::CDDir \
	MRRSystem-${::MRRSystem::VERSION}-Win32BinDoc.zip]
  set ::DocsArchiveInstallProc WindowsInstallVFSZIP
  set ::ExamplesArchive [file join $::CDDir \
                         MRRSystem-${::MRRSystem::VERSION}-Win32BinExamples.zip]
  set ::ExamplesArchiveInstallProc WindowsInstallVFSZIP
  
  #  puts stderr "*** FindArchivesAndComputeSizes_WINDOWS: ::BinaryArchive = $::BinaryArchive"
#  puts stderr "*** FindArchivesAndComputeSizes_WINDOWS: ::DevelArchive = $::DevelArchive"
#  puts stderr "*** FindArchivesAndComputeSizes_WINDOWS: ::DocsArchive = $::DocsArchive"
  if {![file exists $::BinaryArchive] ||
      ![file exists $::DevelArchive] ||
      ![file exists $::DocsArchive] ||
      ![file exists $::ExamplesArchive]} {
    tk_messageBox -type ok -parent . -title "Unsupported O/S" \
		  -icon error \
		  -message "The archives for $::tcl_platform(os) are missing!"
    exit
  }
  set ::LittleDocFiles {}
  foreach f {COPYING README ReadmeW32.txt ChangeLog} {
    set f1 [file join $::CDDir $f]
    if {[file exists "$f1"]} {lappend ::LittleDocFiles "$f1"}
  }
  if {[catch {
    set ::Startup::binary [file tail $::BinaryArchive]
    vfs::zip::Mount "$::BinaryArchive" tempmount
    set ::BinaryArchiveSize [DiskUsage tempmount]
    vfs::unmount tempmount
    set ::Startup::binarySize "[HumanReadableNumber $::BinaryArchiveSize]"
    set ::Startup::progress 25
    set ::Startup::devel [file tail $::DevelArchive]
    vfs::zip::Mount "$::DevelArchive" tempmount
    set ::DevelArchiveSize [DiskUsage tempmount]
    vfs::unmount tempmount
    set ::Startup::develSize "[HumanReadableNumber $::DevelArchiveSize]"
    set ::Startup::progress 50
    set ::Startup::docs [file tail $::DocsArchive]
    vfs::zip::Mount "$::DocsArchive" tempmount
    set ::DocsArchiveSize [DiskUsage tempmount]
    vfs::unmount tempmount
    set ::Startup::docsSize "[HumanReadableNumber $::DocsArchiveSize]"
    set ::Startup::progress 75
    set ::Startup::examples [file tail $::ExamplesArchive]
    vfs::zip::Mount "$::ExamplesArchive" tempmount
    set ::ExamplesArchiveSize [DiskUsage tempmount]
    vfs::unmount tempmount
    set ::Startup::examplesSize "[HumanReadableNumber $::ExamplesArchiveSize]"
    set ::Startup::progress 100
    
  } error]} {
    puts stderr "Error getting archive sizes: $error"
    tk_messageBox -type ok -parent . -title "Error getting archive sizes" \
		  -icon error -message "$error"
    update
    exit
  }
}

proc FindArchivesAndComputeSizes_MacOSX {} {
    set plat $::tcl_platform(os)
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::CDDir = $::CDDir"
    set ::BinaryArchive [file join $::CDDir \
                         MRRSystem-$::MRRSystem::VERSION-${plat}BinOnly.zip]
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::BinaryArchive = $::BinaryArchive"
    if {![file exists $::BinaryArchive]} {
        set tdir [file dirname [file dirname $::CDDir]]
        puts stderr "*** FindArchivesAndComputeSizes_MacOSX: tdir = $tdir"
        set tdirnameext [file extension [file tail $tdir]]
        puts stderr "*** FindArchivesAndComputeSizes_MacOSX: tdirnameext  = $tdirnameext"
        if {$tdirnameext ne ".app"} {
            tk_messageBox -type ok -parent . -title "Unsupported O/S" \
		  -icon error \
		  -message "The archives for $::tcl_platform(os) are missing!"
            exit
        }
        set payloaddir [file join $tdir Payload]
        puts stderr "*** FindArchivesAndComputeSizes_MacOSX: payloaddir = $payloaddir"
        set ::BinaryArchive [file join $payloaddir \
                             MRRSystem-$::MRRSystem::VERSION-${plat}BinOnly.zip]
        puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::BinaryArchive = $::BinaryArchive"
        if {[file exists $::BinaryArchive]} {
            set ::CDDir $payloaddir
        } else {
            set ::CDDir [file dirname $tdir]
        }
    }
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX (2): ::CDDir = $::CDDir"
    set ::BinaryArchive [file join $::CDDir \
                         MRRSystem-$::MRRSystem::VERSION-${plat}BinOnly.zip]
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::BinaryArchive = $::BinaryArchive"
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::BinaryArchive: [file exists $::BinaryArchive]"
    set ::BinaryArchiveInstallProc WindowsInstallVFSZIP
    set ::DevelArchive [file join $::CDDir \
                        MRRSystem-$::MRRSystem::VERSION-${plat}BinDevel.zip]
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::DevelArchive = $::DevelArchive"
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::DevelArchive: [file exists $::DevelArchive]"
    set ::DevelArchiveInstallProc WindowsInstallVFSZIP
    set ::DocsArchive [file join $::CDDir \
                       MRRSystem-$::MRRSystem::VERSION-${plat}BinDoc.zip]
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::DocsArchive = $::DocsArchive"
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::DocsArchive: [file exists $::DocsArchive]"
    set ::DocsArchiveInstallProc WindowsInstallVFSZIP
    set ::ExamplesArchive [file join $::CDDir \
                           MRRSystem-$::MRRSystem::VERSION-${plat}BinExamples.zip]
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::ExamplesArchive = $::ExamplesArchive"
    puts stderr "*** FindArchivesAndComputeSizes_MacOSX: ::ExamplesArchive: [file exists $::ExamplesArchive]"
    set ::ExamplesArchiveInstallProc WindowsInstallVFSZIP
    if {![file exists $::BinaryArchive] ||
        ![file exists $::DevelArchive] ||
        ![file exists $::DocsArchive] ||
        ![file exists $::ExamplesArchive]} {
        tk_messageBox -type ok -parent . -title "Unsupported O/S" \
              -icon error \
              -message "The archives for $::tcl_platform(os) are missing!"
        exit
    }
    set ::LittleDocFiles {}
    foreach f {COPYING README ChangeLog} {
        set f1 [file join $::CDDir $f]
        if {[file exists "$f1"]} {lappend ::LittleDocFiles "$f1"}
    }
    if {[catch {
         set ::Startup::binary [file tail $::BinaryArchive]
         vfs::zip::Mount "$::BinaryArchive" tempmount
         set ::BinaryArchiveSize [DiskUsage tempmount]
         vfs::unmount tempmount
         set ::Startup::binarySize "[HumanReadableNumber $::BinaryArchiveSize]"
         set ::Startup::progress 25
         set ::Startup::devel [file tail $::DevelArchive]
         vfs::zip::Mount "$::DevelArchive" tempmount
         set ::DevelArchiveSize [DiskUsage tempmount]
         vfs::unmount tempmount
         set ::Startup::develSize "[HumanReadableNumber $::DevelArchiveSize]"
         set ::Startup::progress 50
         set ::Startup::docs [file tail $::DocsArchive]
         vfs::zip::Mount "$::DocsArchive" tempmount
         set ::DocsArchiveSize [DiskUsage tempmount]
         vfs::unmount tempmount
         set ::Startup::docsSize "[HumanReadableNumber $::DocsArchiveSize]"
         set ::Startup::progress 75
         set ::Startup::examples [file tail $::ExamplesArchive]
         vfs::zip::Mount "$::ExamplesArchive" tempmount
         set ::ExamplesArchiveSize [DiskUsage tempmount]
         vfs::unmount tempmount
         set ::Startup::examplesSize "[HumanReadableNumber $::ExamplesArchiveSize]"
         set ::Startup::progress 100
     } error]} {
         puts stderr "Error getting archive sizes: $error"
         tk_messageBox -type ok -parent . -title "Error getting archive sizes" \
               -icon error -message "$error"
         update
         exit
    }
}

proc FindArchivesAndComputeSizes_UNIX {} {
  set bits {}
  if {$::tcl_platform(os) eq "Linux"} {
      # Assume 32-bit (i386/i486/i586/i686) and 64-bit (x86_64) Intel/AMD machines
      # Add in armv7l (Raspberry Pi)
    switch -glob $::tcl_platform(machine) {
      x86_64 {set bits 64}
      i?86   {set bits 32}
      armv7l {set bits Armv7l32}
    }
    set plat Linux$bits
  } else {;## Change for other multi-arch UNIX platforms (Darwin -- MacOSX)
    set plat $::tcl_platform(os)
  }
  set ::BinaryArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${plat}BinOnly.tar.bz2]
  set ::BinaryArchiveInstallProc UnixInstallTarxjvf
  set ::DocsArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${plat}BinDoc.tar.bz2]
  set ::DocsArchiveInstallProc UnixInstallTarxjvf
  set ::DevelArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${plat}BinDevel.tar.bz2]
  set ::DevelArchiveInstallProc UnixInstallTarxjvf
  set ::ExamplesArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${plat}BinExamples.tar.bz2]
  set ::ExamplesArchiveInstallProc UnixInstallTarxjvf
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::BinaryArchive = $::BinaryArchive"
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::DocsArchive   = $::DocsArchive"
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::DevelArchive  = $::DevelArchive"
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::ExamplesArchive = $::ExamplesArchive"
  if {![file exists $::DevelArchive] ||
      ![file exists $::BinaryArchive] ||
      ![file exists $::DocsArchive] ||
      ![file exists $::ExamplesArchive]} {
    tk_messageBox -type ok -parent . -title "Unsupported O/S" \
		  -icon error \
		  -message "The archives for $::tcl_platform(os) are missing!"
    exit
  }
  set ::LittleDocFiles {}
  foreach f {COPYING README Readme.Centos ChangeLog} {
    set f1 [file join $::CDDir $f]
    if {[file exists "$f1"]} {lappend ::LittleDocFiles "$f1"}
  }
  if {[catch {
    set ::Startup::binary [file tail $::BinaryArchive]
    set ::BinaryArchiveSize 0
    set fd [open |[list sh -c "bzcat $::BinaryArchive|wc -c"] r]
    fileevent $fd readable [list gets $fd ::BinaryArchiveSize]
    tkwait variable ::BinaryArchiveSize
    set ::Startup::binarySize "[HumanReadableNumber $::BinaryArchiveSize]"
    catch {close $fd}
    set ::Startup::progress 25
    set ::Startup::devel [file tail $::DevelArchive]
    set ::DevelArchiveSize 0
    set fd [open |[list sh -c "bzcat $::DevelArchive|wc -c"] r]
    fileevent $fd readable [list gets $fd ::DevelArchiveSize]
    tkwait variable ::DevelArchiveSize
    set ::Startup::develSize "[HumanReadableNumber $::DevelArchiveSize]"
    catch {close $fd}
    set ::Startup::progress 50
    set ::Startup::docs [file tail $::DocsArchive]
    set ::DocsArchiveSize 0
    set fd [open |[list sh -c "bzcat $::DocsArchive|wc -c"] r]
    fileevent $fd readable [list gets $fd ::DocsArchiveSize]
    tkwait variable ::DocsArchiveSize
    set ::Startup::docsSize "[HumanReadableNumber $::DocsArchiveSize]"
    catch {close $fd}
    set ::Startup::progress 75
    set ::Startup::examples [file tail $::ExamplesArchive]
    set ::ExamplesArchiveSize 0
    set fd [open |[list sh -c "bzcat $::ExamplesArchive|wc -c"] r]
    fileevent $fd readable [list gets $fd ::ExamplesArchiveSize]
    tkwait variable ::ExamplesArchiveSize
    catch {close $fd}
    set ::Startup::examplesSize "[HumanReadableNumber $::ExamplesArchiveSize]"
    set ::Startup::progress 100
  } error]} {
    puts stderr "Error getting archive sizes: $error"
    tk_messageBox -type ok -parent . -title "Error getting archive sizes" \
		  -icon error -message "$error"
    update
    exit
  }
}

proc UnixInstallTarxzvf {tarpath destpath logtext} {
  puts stderr "*** UnixInstallTarxzvf $tarpath $destpath $logtext"  
  catch {file mkdir $destpath}
  set fd [open |[list tar xzv --no-same-owner -f "$tarpath" -C "$destpath"] r]
  set ::LogDone 0
  fileevent $fd readable [list PipeToLog $fd $logtext]
  tkwait variable ::LogDone
  catch {close $fd}
}

proc UnixInstallTarxjvf {tarpath destpath logtext} {
  puts stderr "*** UnixInstallTarxjvf $tarpath $destpath $logtext"  
  catch {file mkdir $destpath}
  set fd [open |[list tar xjv --no-same-owner -f "$tarpath" -C "$destpath"] r]
  set ::LogDone 0
  fileevent $fd readable [list PipeToLog $fd $logtext]
  tkwait variable ::LogDone
  catch {close $fd}
}
 
proc PipeToLog {fd logtext} {
  if {[gets $fd line] >= 0} {
    $logtext insert end "$line\n"
    $logtext see end
    update idle
  } else {
    catch {close $fd}
    incr ::LogDone
  }
}

proc WindowsInstallVFSZIP {zipfile destpath logtext} {
  catch {file mkdir $destpath}
  vfs::zip::Mount "$zipfile" tempmount
  Deep_File_Copy tempmount $destpath $logtext
  vfs::unmount tempmount
}

proc Deep_File_Copy {sourceDir destDir logtext} {
  foreach f [glob -nocomplain [file join $sourceDir *]] {
    switch [file type $f] {
      file {
          catch {
              file copy $f $destDir
              set perms [file attributes $f -permissions]
              file attributes [file join $destDir [file tail $f]] \
                    -permisions $perms
          }
          
          $logtext insert end "[file join $destDir [file tail $f]]\n"
          $logtext see end
          update idle
      }
      directory {
          set newdir [file join $destDir [file tail $f]]
          file mkdir $newdir
          $logtext insert end "$newdir\n"
          $logtext see end
          update idle
          Deep_File_Copy $f $newdir $logtext
      }
    }
  }
} 

proc MainWindow {} {
  set ::Main [MainFrame .main -menu {
				        "&File" {} {} 0 {
					{command "E&xit" {} 
						 "Exit the application" {} 
						 -command CleanupAndExit}}} \
                                           ]
  wm protocol . WM_DELETE_WINDOW CleanupAndExit
  pack $::Main  -expand yes -fill both
  image create photo DeepwoodsBanner -format gif \
				     -file [file join $::ImageDir \
						      DeepwoodsBanner.gif]
  set header [$::Main getframe].header]
  pack [ttk::frame $header]  -fill x
  pack [ttk::label $header.banner -image DeepwoodsBanner -borderwidth 0]
  pack [ttk::label $header.headtext -font {Times -32 bold} \
				-text "Model Railroad System Installer"] \
	-anchor c -expand yes -fill x
  set ::Pages [PagesManager [$::Main getframe].pages]
 
  pack $::Pages -expand yes -fill both
  foreach p {Copyright Readme Startup InstallArchives DestDisk Installing 
		AdditionalArchives Installing2 Done} {
    set page [$::Pages add $p]
    switch -exact -- $p {
      Startup {
	namespace eval Startup {
		variable progress 0
		variable devel {}
		variable develSize "[HumanReadableNumber 0]"
		variable binary {}
		variable binarySize "[HumanReadableNumber 0]"
		variable docs {}
		variable docsSize "[HumanReadableNumber 0]"
		variable examples {}
		variable examplesSize "[HumanReadableNumber 0]"
	}
	pack [ttk::labelframe $page.progressFrame -labelanchor nw -text "Finding Archives..." \
					     ] \
			-expand yes -fill both
	set progress [ttk::progressbar \
				$page.progressFrame.progress \
				-orient horizontal -maximum 100 \
				-variable Startup::progress]
        pack $progress -fill x
	set binaryLF [LabelFrame \
			$page.progressFrame.binaryLF \
				-text "Binary Archive:" -width 20]
	pack $binaryLF -expand yes -fill x
	pack [ttk::entry [$binaryLF getframe].name -state readonly \
					      -textvariable ::Startup::binary] \
		-side left -expand yes -fill x
	pack [ttk::entry [$binaryLF getframe].size -state readonly -width 6 \
					      -textvariable ::Startup::binarySize] \
		-side left
	set develLF [LabelFrame \
			$page.progressFrame.develLF \
				-text "Devel Archive:" -width 20]
	pack $develLF -expand yes -fill x
	pack [ttk::entry [$develLF getframe].name -state readonly \
					      -textvariable ::Startup::devel] \
		-side left -expand yes -fill x
	pack [ttk::entry [$develLF getframe].size -state readonly -width 6\
					      -textvariable ::Startup::develSize] \
		-side left
	set docsLF [LabelFrame \
			$page.progressFrame.docsLF \
				-text "Docs Archive:" -width 20]
	pack $docsLF -expand yes -fill x
	pack [ttk::entry [$docsLF getframe].name -state readonly \
					      -textvariable ::Startup::docs] \
		-side left -expand yes -fill x
	pack [ttk::entry [$docsLF getframe].size -state readonly -width 6\
					      -textvariable ::Startup::docsSize] \
		-side left
	set examplesLF [LabelFrame \
			$page.progressFrame.examplesLF \
				-text "Examples Archive:" -width 20]
	pack $examplesLF -expand yes -fill x
	pack [ttk::entry [$examplesLF getframe].name -state readonly \
					      -textvariable ::Startup::examples] \
		-side left -expand yes -fill x
	pack [ttk::entry [$examplesLF getframe].size -state readonly -width 6\
					      -textvariable ::Startup::examplesSize] \
		-side left
	pack [ttk::button $page.next -text "Next ==>" -command {set ::State Copyright}\
				-state disabled] \
		-side bottom -anchor e
      }
      Copyright {
	namespace eval Copyright {
		variable copyrightText {}
	}
	pack [ttk::labelframe $page.progressFrame -text "Copyright" \
				-labelanchor nw] \
			-expand yes -fill both
	set pframe $page.progressFrame
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set ::Copyright::copyrightText [ROText [$sw getframe].copyrightText -wrap char \
							-height 8 -width 40]
	pack $::Copyright::copyrightText -expand yes -fill both
	$sw setwidget $::Copyright::copyrightText
	pack [ttk::button $page.next -text "Next ==>" \
				-command {set ::State Readme}] \
		-side bottom -anchor e
	
      }
      Readme {
	namespace eval Readme {
		variable readmeText {}
	}
	pack [ttk::labelframe $page.progressFrame -text "Copyright" \
				-labelanchor nw] \
			-expand yes -fill both
	set pframe $page.progressFrame
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set ::Readme::readmeText [ROText [$sw getframe].readmeText -wrap char \
							-height 8 -width 40]
	pack $::Readme::readmeText -expand yes -fill both
	$sw setwidget $::Readme::readmeText
	pack [ttk::button $page.next -text "Next ==>" \
				-command {set ::State InstallArchives}] \
		-side bottom -anchor e
	
      }
      InstallArchives {
        namespace eval InstallArchives {
		variable installDevel no
		variable installBinary yes
		variable installDocs yes
                variable installExamples no
                variable hasSysBinaryArchive no
	}
	pack [ttk::labelframe $page.progressFrame -text "Selecting Archives to install..." \
				-labelanchor nw] \
			-expand yes -fill both
	set pframe $page.progressFrame
	set binaryLF [LabelFrame \
			$pframe.binaryLF \
			-text "Binary Archive:" -width 20]
	pack $binaryLF -expand yes -fill x
	pack [ttk::checkbutton [$binaryLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installBinary] \
		-side left -expand yes -fill x
	set develLF [LabelFrame \
			$pframe.develLF \
			-text "Devel Archive:" -width 20]
	pack $develLF -expand yes -fill x
	pack [ttk::checkbutton [$develLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installDevel] \
		-side left -expand yes -fill x
	set docLF [LabelFrame \
			$pframe.docLF \
			-text "Docs Archive:" -width 20]
	pack $docLF -expand yes -fill x
	pack [ttk::checkbutton [$docLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installDocs] \
		-side left -expand yes -fill x
	set examplesLF [LabelFrame \
			$pframe.examplesLF \
			-text "Examples Archive:" -width 20]
	pack $examplesLF -expand yes -fill x
	pack [ttk::checkbutton [$examplesLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installExamples] \
		-side left -expand yes -fill x
	pack [ttk::button $page.next -text "Next ==>" -command {set ::State DestDisk}\
				-state normal] \
		-side bottom -anchor e
      }
      DestDisk {
	pack [ttk::labelframe $page.progressFrame -text "Selecting Destination directory..." \
				-labelanchor nw] \
			-expand yes -fill both

	set pframe $page.progressFrame
	namespace eval DestDisk {
		variable spaceneeded {}
		variable destdir {}
		switch -exact -- $::tcl_platform(platform) {
		  unix {set destdir {/usr/local}}
		  windows {set destdir "C:/mrrsystem-$::MRRSystem::VERSION"}
		  default {set destdir {/usr/local}}
		}
	}
	pack [LabelEntry $pframe.spaceNeededLE -label "Space Needed:" \
						-labelwidth 20 \
						-editable no \
						-textvariable ::DestDisk::spaceneeded] \
		-expand yes -fill x
	pack [FileEntry $pframe.destdirLE -label "Destination Folder:" \
						-labelwidth 20 \
						-textvariable ::DestDisk::destdir \
						-filedialog directory] \
              -expand yes -fill x
        $pframe.destdirLE bind <Return> CheckFreeSpace
	pack [ttk::frame $page.np -borderwidth 0] -side bottom -fill x -expand yes
	pack [ttk::button $page.np.prev -text "<== Back" -command {set ::State InstallArchives}\
				-state normal] \
		-side left
	pack [ttk::button $page.np.next -text "Next ==>" -command {if {[CheckFreeSpace]} {set ::State Installing}}\
				-state normal] \
		-side right
      }
      Installing {
	pack [ttk::labelframe $page.progressFrame -text "Installing..." \
				-labelanchor nw] \
			-expand yes -fill both
	set pframe $page.progressFrame
	namespace eval Installing {
		variable progress 0
		variable logstatus {}
		variable logtext {}
	}
	set progress [ttk::progressbar $pframe.progress -orient horizontal -maximum 100 \
				-variable ::Installing::progress]
	pack $progress -fill x
	pack [ttk::label $pframe.logstatus -textvariable ::Installing::logstatus] \
		-expand yes -fill x -anchor w
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set Installing::logtext [ROText [$sw getframe].logtext -wrap char \
							-height 8 -width 40]
	pack $Installing::logtext -expand yes -fill both
	$sw setwidget $Installing::logtext
	pack [ttk::button $page.next -text "Next ==>" \
				-command {set ::State AdditionalArchives} \
				-state disabled] \
		-side bottom -anchor e
      }
      AdditionalArchives {
	pack [ttk::labelframe $page.progressFrame -text "Selecting additional Archives to install..." \
				-labelanchor nw] \
			-expand yes -fill both
	namespace eval AdditionalArchives {
		variable archiveList
		array set archiveList [list \
			MRRSystem-$::MRRSystem::VERSION.tar.gz {{MRR System source code} tar-xzvf UNIX-only} \
			MRRSystem-$::MRRSystem::VERSION.zip {{MRR System source code} unzip Windows-only} \
			LHandBS.zip {{Library Junction and Bench Station FCF2 sample data} unzip} \
			ChesapeakeSystem.zip {{Chesapeake System FCF2 sample data} unzip} \
			LJandBS.pdf {{Library Junction and Bench Station sample time table} copy} \
			tubjunction-1.0.tar.gz {{Tub Junction Sample CMR/I code} tar-xzvf UNIX-only} \
			]
		variable archiveSizes
		array set archiveSizes {}
		variable destdirs
		array set destdirs {}
		variable archiveInstallerProcs
		array set archiveInstallerProcs {}
		variable checkedArchives
		array set checkedArchives {}
		variable pframe {}
		variable populated no
	}
	set pframe $page.progressFrame
	set sw  [ScrolledWindow  $pframe.sw -scrollbar vertical -auto vertical]
	pack $sw -expand yes -fill both
        set scf [ScrollableFrame [$sw getframe].scf -constrainedwidth yes -height 150]
	pack $scf -expand yes -fill both
	$sw setwidget $scf	
        set AdditionalArchives::pframe [$scf getframe]
	pack [ttk::button $page.next -text "Next ==>" -command {if {[CheckFreeSpace2]} {set ::State Installing2}}\
				-state normal] \
		-side bottom -anchor e
      }
      Installing2 {
	pack [ttk::labelframe $page.progressFrame -text "Installing additional Archives..." \
				-labelanchor nw] \
			-expand yes -fill both
	set pframe $page.progressFrame
	namespace eval Installing2 {
		variable progress 0
		variable logstatus {}
		variable logtext {}
	}
	set progress [ttk::progressbar $pframe.progress -orient horizontal -maximum 100 \
				-variable ::Installing2::progress]
	pack $progress -fill x
	pack [ttk::label $pframe.logstatus -textvariable ::Installing2::logstatus] \
		-expand yes -fill x -anchor w
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set Installing2::logtext [ROText [$sw getframe].logtext -wrap char \
							-height 8 -width 40]
	pack $Installing2::logtext -expand yes -fill both
	$sw setwidget $Installing2::logtext
	pack [ttk::button $page.next -text "Next ==>" -command {set ::State Done}\
				-state disabled] \
		-side bottom -anchor e
      }
      Done {
	pack [ttk::label $page.message -font {Times -32 bold} \
				  -text {Install Complete!}] \
		-anchor c -expand yes -fill x
	pack [ttk::button $page.exit -text "Exit ==>" -command {exit}] \
		-side bottom -anchor e
      }
    }
  }
}

proc CleanupAndExit {} {
  switch -exact -- $::State {
    default {exit}
  }
}

    

MainWindow
::tk::PlaceWindow .
set ::State "Startup"
$::Pages raise $::State
while {![string equal $::State {Done}]} {
  switch -exact -- $::State {
    Startup {
      if {![string equal [[$::Pages getframe $::State].next cget -state] {normal}]} {
        FindArchivesAndComputeSizes
        [$::Pages getframe $::State].next configure -state normal
      }
    }
    Copyright {
      set copyright [lsearch -inline -glob  $::LittleDocFiles "*COPYING"]
      if {[string length "$copyright"] > 0} {
	set fp [open $copyright r]
	$::Copyright::copyrightText insert end "[read $fp]"
	close $fp
      }
    }
    Readme {
      set readme [lsearch -inline -glob  $::LittleDocFiles "*README"]
      if {[string length "$readme"] > 0} {
	set fp [open $readme r]
	$::Readme::readmeText insert end "[read $fp]"
	close $fp
      }
      set readme [lsearch -inline -glob  $::LittleDocFiles "*Readme*"]
      if {[string length "$readme"] > 0} {
	set fp [open $readme r]
	$::Readme::readmeText insert end "[read $fp]"
	close $fp
      }
      set readme [lsearch -inline -glob  $::LittleDocFiles "*ChangeLog"]
      if {[string length "$readme"] > 0} {
	set fp [open $readme r]
	$::Readme::readmeText insert end "[read $fp]"
	close $fp
      }
    }
    InstallArchives {
      if {[string length $::DestDisk::spaceneeded] > 0} {
	set ::DestDisk::spaceneeded {}
      }
    }
    DestDisk {
      if {[string length $::DestDisk::spaceneeded] == 0} {
	set sn 0
	if {$::InstallArchives::installDevel} {
	  incr sn $::DevelArchiveSize
	}
	if {$::InstallArchives::installBinary} {
	  incr sn $::BinaryArchiveSize
	} 
	if {$::InstallArchives::installDocs} {
	  incr sn $::DocsArchiveSize
        }
        if {$::InstallArchives::installExamples} {
          incr sn $::ExamplesArchiveSize
        }
	set ::DestDisk::spaceneeded "[HumanReadableNumber $sn]"
	if {$sn == 0} {
	  set ::State AdditionalArchives
	  $::Pages raise $::State
	  update
	  continue
	}
      }
    }
    Installing {
      if {![string equal [[$::Pages getframe $::State].next cget -state] {normal}]} {
	set sn 0
	set inst 0
	set acount 0
	if {$::InstallArchives::installDevel} {
	  incr sn $::DevelArchiveSize
	}
	if {$::InstallArchives::installBinary} {
	  incr sn $::BinaryArchiveSize
	}
	if {$::InstallArchives::installDocs} {
	  incr sn $::DocsArchiveSize
	}
	if {$::InstallArchives::installExamples} {
	  incr sn $::ExamplesArchiveSize
	}
	set sn [expr {double($sn)}]
	if {$::InstallArchives::installBinary} {
	  incr acount
	  set Installing::logstatus "Installing ($acount): [file tail $::BinaryArchive]"
	  $::BinaryArchiveInstallProc $::BinaryArchive "$::DestDisk::destdir" $::Installing::logtext
          if {$::InstallArchives::hasSysBinaryArchive} {
              $::BinaryArchiveInstallProc $::SysBinaryArchive "$::SysBinaryArchiveDest" $::Installing::logtext
          }
	  incr inst $::BinaryArchiveSize
	  set ::Installing::progress [expr {int((double($inst) / $sn)*100)}]
	  update
	}
	if {$::InstallArchives::installDevel} {
	  incr acount
	  set Installing::logstatus "Installing ($acount): [file tail $::DevelArchive]"
	  $::DevelArchiveInstallProc $::DevelArchive "$::DestDisk::destdir" $::Installing::logtext
	  incr inst $::DevelArchiveSize
	  set ::Installing::progress [expr {int((double($inst) / $sn)*100)}]
	  update
	}
	if {$::InstallArchives::installDocs} {
	  incr acount
	  set Installing::logstatus "Installing ($acount): [file tail $::DocsArchive]"
	  $::DocsArchiveInstallProc $::DocsArchive "$::DestDisk::destdir" $::Installing::logtext
	  incr inst $::DocsArchiveSize
	  set ::Installing::progress [expr {int((double($inst) / $sn)*100)}]
	  update
	}
	if {$::InstallArchives::installExamples} {
	  incr acount
	  set Installing::logstatus "Installing ($acount): [file tail $::ExamplesArchive]"
	  $::ExamplesArchiveInstallProc $::ExamplesArchive "$::DestDisk::destdir" $::Installing::logtext
	  incr inst $::ExamplesArchiveSize
	  set ::Installing::progress [expr {int((double($inst) / $sn)*100)}]
	  update
	}
        foreach f $::LittleDocFiles {
	  File_Copy $f [file join "$::DestDisk::destdir" share MRRSystem Doc] $::Installing::logtext
	}
#	Does not work under Wine.  Might work under real MS-Windows (untested)
	catch {
	if {$::tcl_platform(platform) eq "windows"} {
	  set programs_menu [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders} Programs]
	  set menu_dir [file join $programs_menu {Model Railroad System}]
	  file mkdir $menu_dir
	  foreach bin [glob -nocomplain [file join "$::DestDisk::destdir" bin *.exe]] {
	    set destfile [file join $menu_dir [file tail $bin]]
	    if {[file exists $destfile]} {file delete $destfile}
	    file link $destfile $bin
	  }
	} }
	[$::Pages getframe $::State].next configure -state normal
      }
    }
    AdditionalArchives {
      if {[AdditionalArchives::CheckAndPopulate] == 0} {
	set ::State Done
	$::Pages raise $::State
	update
	continue
      }
    }
    Installing2 {
      if {![string equal [[$::Pages getframe $::State].next cget -state] {normal}]} {
	namespace eval AdditionalArchives {
	  variable archiveList
	  variable archiveSizes
	  variable destdirs
	  variable checkedArchives
	  variable archiveInstallerProcs
	  set selectedArchives {}
	  foreach a [lsort -dictionary [array names checkedArchives]] {
	    if {$checkedArchives($a)} {lappend selectedArchives $a}
	  }
	  set sn 0
	  foreach a $selectedArchives {
	    incr sn $archiveSizes($a)
	  }
	  set inst 0
	  set acount 0
	  foreach a $selectedArchives {
	    incr acount
	    set ::Installing2::logstatus "Installing ($acount): $a"
	    $archiveInstallerProcs($a) [file join $::CDDir $a] $destdirs($a) $::Installing2::logtext
	    incr inst $archiveSizes($a)
	    set ::Installing2::progress [expr {int((double($inst) / $sn)*100)}]
	    update
	  }
	  if {$acount == 0} {
	    set ::State Done
	    $::Pages raise $::State
	    update
	    continue
	  }
	}
        [$::Pages getframe $::State].next configure -state normal
      }
    }
    default {
      if {![string equal [[$::Pages getframe $::State].next cget -state] {normal}]} {
      }
    }
  }
#  puts stderr "*** Main loop (before tkwait variable ::State): ::State = $::State"
  tkwait variable ::State
  $::Pages raise $::State
  update
#  puts stderr "*** Main loop (after  tkwait variable ::State): ::State = $::State"
}


