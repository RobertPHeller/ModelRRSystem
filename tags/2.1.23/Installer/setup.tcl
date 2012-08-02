set ::CDDir [file dirname [info nameofexecutable]]
#puts stderr "*** ::CDDir = $::CDDir"

set argv0 [file join  [file dirname [info nameofexecutable]] setup]

#console show

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
package require BWidget
package require Version
package require BWFileEntry
#package require HTMLHelp
if {[string equal $::tcl_platform(platform) windows]} {
  package require vfs::zip
  package require registry
}
global ImageDir 
set ImageDir [file join [file dirname [file dirname [info script]]] \
			Images]

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
    set archiveTF [TitleFrame $pframe.archiveTF$archiveIndex -text "$a" \
							     -side left]
    incr archiveIndex
    pack $archiveTF -expand yes -fill x
    set archiveTFframe [$archiveTF getframe]
    pack [Label $archiveTFframe.descr -text "$descr"] -expand yes -fill x -anchor w
    pack [LabelEntry $archiveTFframe.size \
			-label "Size:" -labelwidth 15 \
			-text "[HumanReadableNumber $archiveSizes($a)]" \
			-editable no] -expand yes -fill x
    pack [FileEntry $archiveTFframe.dest \
			-label "Destination:" -labelwidth 15 \
			-textvariable ::AdditionalArchives::destdirs($a) \
			-filedialog directory] \
	-expand yes -fill x
    pack [checkbutton $archiveTFframe.installP -text "Install? " \
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
  file copy $source $destdir
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
    unix {FindArchivesAndComputeSizes_UNIX}
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
  set ::BinaryArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-Win32BinOnly.zip]
  set ::BinaryArchiveInstallProc WindowsInstallVFSZIP
  set ::DevelArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-Win32BinDevel.zip]
  set ::DevelArchiveInstallProc WindowsInstallVFSZIP
  set ::DocsArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-Win32BinDoc.zip]
  set ::DocsArchiveInstallProc WindowsInstallVFSZIP
  if {![file exists $::BinaryArchive] ||
      ![file exists $::DevelArchive] ||
      ![file exists $::DocsArchive]} {
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
    set ::Startup::progress 33
    set ::Startup::devel [file tail $::DevelArchive]
    vfs::zip::Mount "$::DevelArchive" tempmount
    set ::DevelArchiveSize [DiskUsage tempmount]
    vfs::unmount tempmount
    set ::Startup::develSize "[HumanReadableNumber $::DevelArchiveSize]"
    set ::Startup::progress 67
    set ::Startup::docs [file tail $::DocsArchive]
    vfs::zip::Mount "$::DocsArchive" tempmount
    set ::DocsArchiveSize [DiskUsage tempmount]
    vfs::unmount tempmount
    set ::Startup::docsSize "[HumanReadableNumber $::DocsArchiveSize]"
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
  set ::BinaryArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${::tcl_platform(os)}BinOnly.tar.bz2]
  set ::BinaryArchiveInstallProc UnixInstallTarxjvf
  set ::DocsArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${::tcl_platform(os)}BinDoc.tar.bz2]
  set ::DocsArchiveInstallProc UnixInstallTarxjvf
  set ::DevelArchive [file join $::CDDir \
	MRRSystem-$::MRRSystem::VERSION-${::tcl_platform(os)}BinDevel.tar.bz2]
  set ::DevelArchiveInstallProc UnixInstallTarxjvf
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::BinaryArchive = $::BinaryArchive"
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::DocsArchive   = $::DocsArchive"
  puts stderr "*** FindArchivesAndComputeSizes_UNIX: ::DevelArchive  = $::DevelArchive"
  if {![file exists $::DevelArchive] ||
      ![file exists $::BinaryArchive] ||
      ![file exists $::DocsArchive]} {
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
    set ::Startup::progress 33
    set ::Startup::devel [file tail $::DevelArchive]
    set ::DevelArchiveSize 0
    set fd [open |[list sh -c "bzcat $::DevelArchive|wc -c"] r]
    fileevent $fd readable [list gets $fd ::DevelArchiveSize]
    tkwait variable ::DevelArchiveSize
    set ::Startup::develSize "[HumanReadableNumber $::DevelArchiveSize]"
    catch {close $fd}
    set ::Startup::progress 67
    set ::Startup::docs [file tail $::DocsArchive]
    set ::DocsArchiveSize 0
    set fd [open |[list sh -c "bzcat $::DocsArchive|wc -c"] r]
    fileevent $fd readable [list gets $fd ::DocsArchiveSize]
    tkwait variable ::DocsArchiveSize
    set ::Startup::docsSize "[HumanReadableNumber $::DocsArchiveSize]"
    catch {close $fd}
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
  catch {file mkdir $destpath}
  set fd [open |[list tar xzvf "$tarpath" -C "$destpath"] r]
  set ::LogDone 0
  fileevent $fd readable [list PipeToLog $fd $logtext]
  tkwait variable ::LogDone
  catch {close $fd}
}

proc UnixInstallTarxjvf {tarpath destpath logtext} {
  catch {file mkdir $destpath}
  set fd [open |[list tar xjvf "$tarpath" -C "$destpath"] r]
  set ::LogDone 0
  fileevent $fd readable [list PipeToLog $fd $logtext]
  tkwait variable ::LogDone
  catch {close $fd}
}
 
proc PipeToLog {fd logtext} {
  if {[gets $fd line] >= 0} {
    $logtext insert end "$line\n"
    $logtext see end
    update
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
	file copy $f $destDir
	$logtext insert end "[file join $destDir [file tail $f]]\n"
	$logtext see end
        update
      }
      directory {
	set newdir [file join $destDir [file tail $f]]
	file mkdir $newdir
        $logtext insert end "$newdir\n"
	$logtext see end
	update
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
  pack $::Main  -expand yes -fill both
  image create photo DeepwoodsBanner -format gif \
				     -file [file join $::ImageDir \
						      DeepwoodsBanner.gif]
  set header [$::Main getframe].header]
  pack [frame $header]  -fill x
  pack [Label $header.banner -image DeepwoodsBanner -borderwidth 0]
  pack [Label $header.headtext -font {Times -32 bold} \
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
	}
	pack [TitleFrame $page.progressFrame -text "Finding Archives..." \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both
	set progress [ProgressBar \
				[$page.progressFrame getframe].progress \
				-type normal -maximum 100 \
				-variable Startup::progress]
        pack $progress -fill x
	set binaryLF [LabelFrame \
			[$page.progressFrame getframe].binaryLF \
				-text "Binary Archive:" -width 16]
	pack $binaryLF -expand yes -fill x
	pack [Entry [$binaryLF getframe].name -editable no \
					      -textvariable ::Startup::binary] \
		-side left -expand yes -fill x
	pack [Entry [$binaryLF getframe].size -editable no -width 6 \
					      -textvariable ::Startup::binarySize] \
		-side left
	set develLF [LabelFrame \
			[$page.progressFrame getframe].develLF \
				-text "Devel Archive:" -width 16]
	pack $develLF -expand yes -fill x
	pack [Entry [$develLF getframe].name -editable no \
					      -textvariable ::Startup::devel] \
		-side left -expand yes -fill x
	pack [Entry [$develLF getframe].size -editable no -width 6\
					      -textvariable ::Startup::develSize] \
		-side left
	set docsLF [LabelFrame \
			[$page.progressFrame getframe].docsLF \
				-text "Docs Archive:" -width 16]
	pack $docsLF -expand yes -fill x
	pack [Entry [$docsLF getframe].name -editable no \
					      -textvariable ::Startup::docs] \
		-side left -expand yes -fill x
	pack [Entry [$docsLF getframe].size -editable no -width 6\
					      -textvariable ::Startup::docsSize] \
		-side left
	pack [Button $page.next -text "Next ==>" -command {set ::State Copyright}\
				-state disabled] \
		-side bottom -anchor e
      }
      Copyright {
	namespace eval Copyright {
		variable copyrightText {}
	}
	pack [TitleFrame $page.progressFrame -text "Copyright" \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both
	set pframe [$page.progressFrame getframe]
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set ::Copyright::copyrightText [text [$sw getframe].copyrightText -wrap char \
							-height 8 -width 40]
	SetROTags $::Copyright::copyrightText
	pack $::Copyright::copyrightText -expand yes -fill both
	$sw setwidget $::Copyright::copyrightText
	pack [Button $page.next -text "Next ==>" \
				-command {set ::State Readme}] \
		-side bottom -anchor e
	
      }
      Readme {
	namespace eval Readme {
		variable readmeText {}
	}
	pack [TitleFrame $page.progressFrame -text "Copyright" \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both
	set pframe [$page.progressFrame getframe]
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set ::Readme::readmeText [text [$sw getframe].readmeText -wrap char \
							-height 8 -width 40]
	SetROTags $::Readme::readmeText
	pack $::Readme::readmeText -expand yes -fill both
	$sw setwidget $::Readme::readmeText
	pack [Button $page.next -text "Next ==>" \
				-command {set ::State InstallArchives}] \
		-side bottom -anchor e
	
      }
      InstallArchives {
        namespace eval InstallArchives {
		variable installDevel no
		variable installBinary yes
		variable installDocs yes
	}
	pack [TitleFrame $page.progressFrame -text "Selecting Archives to install..." \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both
	set pframe [$page.progressFrame getframe]
	set binaryLF [LabelFrame \
			$pframe.binaryLF \
			-text "Binary Archive:" -width 16]
	pack $binaryLF -expand yes -fill x
	pack [checkbutton [$binaryLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installBinary] \
		-side left -expand yes -fill x
	set develLF [LabelFrame \
			$pframe.develLF \
			-text "Devel Archive:" -width 16]
	pack $develLF -expand yes -fill x
	pack [checkbutton [$develLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installDevel] \
		-side left -expand yes -fill x
	set docLF [LabelFrame \
			$pframe.docLF \
			-text "Docs Archive:" -width 16]
	pack $docLF -expand yes -fill x
	pack [checkbutton [$docLF getframe].check \
				-text "Install?" \
				-offvalue no -onvalue yes \
				-variable ::InstallArchives::installDocs] \
		-side left -expand yes -fill x
	pack [Button $page.next -text "Next ==>" -command {set ::State DestDisk}\
				-state normal] \
		-side bottom -anchor e
      }
      DestDisk {
	pack [TitleFrame $page.progressFrame -text "Selecting Destination directory..." \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both

	set pframe [$page.progressFrame getframe]
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
						-command CheckFreeSpace \
						-filedialog directory] \
		-expand yes -fill x
	pack [frame $page.np -borderwidth 0] -side bottom -fill x -expand yes
	pack [Button $page.np.prev -text "<== Back" -command {set ::State InstallArchives}\
				-state normal] \
		-side left
	pack [Button $page.np.next -text "Next ==>" -command {if {[CheckFreeSpace]} {set ::State Installing}}\
				-state normal] \
		-side right
      }
      Installing {
	pack [TitleFrame $page.progressFrame -text "Installing..." \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both
	set pframe [$page.progressFrame getframe]
	namespace eval Installing {
		variable progress 0
		variable logstatus {}
		variable logtext {}
	}
	set progress [ProgressBar $pframe.progress -type normal -maximum 100 \
				-variable ::Installing::progress]
	pack $progress -fill x
	pack [Label $pframe.logstatus -textvariable ::Installing::logstatus] \
		-expand yes -fill x -anchor w
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set Installing::logtext [text [$sw getframe].logtext -wrap char \
							-height 8 -width 40]
	SetROTags $Installing::logtext
	pack $Installing::logtext -expand yes -fill both
	$sw setwidget $Installing::logtext
	pack [Button $page.next -text "Next ==>" \
				-command {set ::State AdditionalArchives} \
				-state disabled] \
		-side bottom -anchor e
      }
      AdditionalArchives {
	pack [TitleFrame $page.progressFrame -text "Selecting additional Archives to install..." \
					     -font {Helvetica -24 bold}] \
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
	set pframe [$page.progressFrame getframe]
	set sw  [ScrolledWindow  $pframe.sw -scrollbar vertical -auto vertical]
	pack $sw -expand yes -fill both
        set scf [ScrollableFrame [$sw getframe].scf -constrainedwidth yes -height 150]
	pack $scf -expand yes -fill both
	$sw setwidget $scf	
        set AdditionalArchives::pframe [$scf getframe]
	pack [Button $page.next -text "Next ==>" -command {if {[CheckFreeSpace2]} {set ::State Installing2}}\
				-state normal] \
		-side bottom -anchor e
      }
      Installing2 {
	pack [TitleFrame $page.progressFrame -text "Installing additional Archives..." \
					     -font {Helvetica -24 bold}] \
			-expand yes -fill both
	set pframe [$page.progressFrame getframe]
	namespace eval Installing2 {
		variable progress 0
		variable logstatus {}
		variable logtext {}
	}
	set progress [ProgressBar $pframe.progress -type normal -maximum 100 \
				-variable ::Installing2::progress]
	pack $progress -fill x
	pack [Label $pframe.logstatus -textvariable ::Installing2::logstatus] \
		-expand yes -fill x -anchor w
	set sw [ScrolledWindow $pframe.scroll -auto vertical -scrollbar vertical]
	pack $sw -expand yes -fill both
	set Installing2::logtext [text [$sw getframe].logtext -wrap char \
							-height 8 -width 40]
	SetROTags $Installing2::logtext
	pack $Installing2::logtext -expand yes -fill both
	$sw setwidget $Installing2::logtext
	pack [Button $page.next -text "Next ==>" -command {set ::State Done}\
				-state disabled] \
		-side bottom -anchor e
      }
      Done {
	pack [Label $page.message -font {Times -32 bold} \
				  -text {Install Complete!}] \
		-anchor c -expand yes -fill x
	pack [Button $page.exit -text "Exit ==>" -command {exit}] \
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
	set sn [expr {double($sn)}]
	if {$::InstallArchives::installBinary} {
	  incr acount
	  set Installing::logstatus "Installing ($acount): [file tail $::BinaryArchive]"
	  $::BinaryArchiveInstallProc $::BinaryArchive "$::DestDisk::destdir" $::Installing::logtext
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
        foreach f $::LittleDocFiles {
	  File_Copy $f [file join "$::DestDisk::destdir" share MRRSystem Doc] $::Installing::logtext
	}
	if {$::tcl_platform(platform) eq "windows"} {
	  set programs_menu [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders} Programs]
	  set menu_dir [file join $programs_menu {Model Railroad System}]
	  file mkdir $menu_dir
	  foreach bin [glob -nocomplain [file join "$::DestDisk::destdir" bin *.exe] {
	    set destfile [file join $menu_dir [file tail $bin]]
	    if {[file exists $destfile]} {file delete $destfile}
	    file link $destfile $bin
	  }
	}
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


