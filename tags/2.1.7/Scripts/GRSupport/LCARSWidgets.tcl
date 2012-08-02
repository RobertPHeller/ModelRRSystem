#* 
#* ------------------------------------------------------------------
#* LCARSWidgets.tcl - LCARS Widgets
#* Created by Robert Heller on Fri Sep 13 22:06:42 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2005/11/04 19:06:38  heller
#* Modification History: Nov 4, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2002/09/14 03:02:49  heller
#* Modification History: Split up GR Support into several files. Include LCARS Corner Bitmaps
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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

package require grsupport 1.0

set ScriptDir [file dirname [info script]]

namespace eval ::LCARS {}
namespace eval ::LCARS::dialog {

variable CornersHFatVNarrow
array set CornersHFatVNarrow [list \
   LL [list @[file join $ScriptDir LLHFatVNarrow.xbm] 132 101 sw] \
   LR [list @[file join $ScriptDir LRHFatVNarrow.xbm] 131 100 se] \
   UL [list @[file join $ScriptDir ULHFatVNarrow.xbm] 131 100 nw] \
   UR [list @[file join $ScriptDir URHFatVNarrow.xbm] 132 101 ne] \
]

array set CornersHFatVNarrowSmall [list \
   LL [list @[file join $ScriptDir LLHFatVNarrowSmall.xbm] 33 25 sw] \
   LR [list @[file join $ScriptDir LRHFatVNarrowSmall.xbm] 33 25 se] \
   UL [list @[file join $ScriptDir ULHFatVNarrowSmall.xbm] 33 25 nw] \
   UR [list @[file join $ScriptDir URHFatVNarrowSmall.xbm] 33 25 ne] \
]

variable CornersHNarrowVFat
array set CornersHNarrowVFat [list \
   LL [list @[file join $ScriptDir LLHNarrowVFat.xbm] 132 101 sw] \
   LR [list @[file join $ScriptDir LRHNarrowVFat.xbm] 131 100 se] \
   UL [list @[file join $ScriptDir ULHNarrowVFat.xbm] 131 100 nw] \
   UR [list @[file join $ScriptDir URHNarrowVFat.xbm] 132 101 ne] \
]

variable CornersHNarrowVFat
array set CornersHNarrowVFatSmall [list \
   LL [list @[file join $ScriptDir LLHNarrowVFatSmall.xbm] 25 33 sw] \
   LR [list @[file join $ScriptDir LRHNarrowVFatSmall.xbm] 25 33 se] \
   UL [list @[file join $ScriptDir ULHNarrowVFatSmall.xbm] 25 33 nw] \
   UR [list @[file join $ScriptDir URHNarrowVFatSmall.xbm] 25 33 ne] \
]

}

namespace eval ::LCARS::dialog::file {}

namespace eval ::tk::dialog {}
namespace eval ::tk::dialog::file {}


proc ::tk::dialog::file::tkFDialog {type args} {
  return [eval [concat ::LCARS::dialog::file::tkFDialog $type $args]]
}

proc ::LCARS::dialog::file::tkFDialog {type args} {
  puts stderr "*** ::LCARS::dialog::file::tkFDialog $type $args"
  global tkPriv
  set dataName __tk_filedialog
  upvar ::LCARS::dialog::file::$dataName data

  ::LCARS::dialog::file::Config $dataName $type $args

  if {[string equal $data(-parent) .]} {
    set w .$dataName
  } else {
    set w $data(-parent).$dataName
  }

  if {![winfo exists $w]} {
    ::LCARS::dialog::file::Create $w TkFDialog
    } elseif {[string compare [winfo class $w] TkFDialog]} {
	destroy $w
	::LCARS::dialog::file::Create $w TkFDialog
    } else {
	set data(dirMenuBtn) $w.f1.menu
	set data(dirMenu) $w.f1.menu.menu
	set data(upBtn) $w.f1.up
	set data(icons) $w.icons
	set data(ent) $w.f2.ent
	set data(typeMenuLab) $w.f3.lab
	set data(typeMenuBtn) $w.f3.menu
	set data(typeMenu) $data(typeMenuBtn).m
	set data(okBtn) $w.f2.ok
	set data(cancelBtn) $w.f3.cancel
    }
    wm transient $w $data(-parent)

    # Add traces on the selectPath variable
    #

    trace variable data(selectPath) w "::LCARS::dialog::file::SetPath $w"
    $data(dirMenuBtn) configure \
	    -textvariable ::LCARS::dialog::file::${dataName}(selectPath)

    # Initialize the file types menu
    #
    if {[llength $data(-filetypes)]} {
	$data(typeMenu) delete 0 end
	foreach type $data(-filetypes) {
	    set title  [lindex $type 0]
	    set filter [lindex $type 1]
	    $data(typeMenu) add command -label $title \
		-command [list ::LCARS::dialog::file::SetFilter $w $type]
	}
	::LCARS::dialog::file::SetFilter $w [lindex $data(-filetypes) 0]
	$data(typeMenuBtn) config -state normal
	$data(typeMenuLab) config -state normal
    } else {
	set data(filter) "*"
	$data(typeMenuBtn) config -state disabled -takefocus 0
	$data(typeMenuLab) config -state disabled
    }
    ::LCARS::dialog::file::UpdateWhenIdle $w

    # Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.

    ::tk::PlaceWindow $w widget $data(-parent)
    wm title $w $data(-title)

    # Set a grab and claim the focus too.

    ::tk::SetFocusGrab $w $data(ent)
    $data(ent) delete 0 end
    $data(ent) insert 0 $data(selectFile)
    $data(ent) selection range 0 end
    $data(ent) icursor end

    # Wait for the user to respond, then restore the focus and
    # return the index of the selected button.  Restore the focus
    # before deleting the window, since otherwise the window manager
    # may take the focus away so we can't redirect it.  Finally,
    # restore any grab that was in effect.

    tkwait variable tkPriv(selectFilePath)

    ::tk::RestoreFocusGrab $w $data(ent) withdraw

    # Cleanup traces on selectPath variable
    #

    foreach trace [trace vinfo data(selectPath)] {
	trace vdelete data(selectPath) [lindex $trace 0] [lindex $trace 1]
    }
    $data(dirMenuBtn) configure -textvariable {}

    return $tkPriv(selectFilePath)
}

# ::LCARS::dialog::file::Config --
#
#	Configures the TK filedialog according to the argument list
#
proc ::LCARS::dialog::file::Config {dataName type argList} {
    upvar ::LCARS::dialog::file::$dataName data

    set data(type) $type

    # 0: Delete all variable that were set on data(selectPath) the
    # last time the file dialog is used. The traces may cause troubles
    # if the dialog is now used with a different -parent option.

    foreach trace [trace vinfo data(selectPath)] {
	trace vdelete data(selectPath) [lindex $trace 0] [lindex $trace 1]
    }

    # 1: the configuration specs
    #
    set specs {
	{-defaultextension "" "" ""}
	{-filetypes "" "" ""}
	{-initialdir "" "" ""}
	{-initialfile "" "" ""}
	{-parent "" "" "."}
	{-title "" "" ""}
    }

    # 2: default values depending on the type of the dialog
    #
    if {![info exists data(selectPath)]} {
	# first time the dialog has been popped up
	set data(selectPath) [pwd]
	set data(selectFile) ""
    }

    # 3: parse the arguments
    #
    tclParseConfigSpec ::LCARS::dialog::file::$dataName $specs "" $argList

    if {$data(-title) == ""} {
	if {[string equal $type "open"]} {
	    set data(-title) "Open"
	} else {
	    set data(-title) "Save As"
	}
    }

    # 4: set the default directory and selection according to the -initial
    #    settings
    #
    if {$data(-initialdir) != ""} {
	# Ensure that initialdir is an absolute path name.
	if {[file isdirectory $data(-initialdir)]} {
	    set old [pwd]
	    cd $data(-initialdir)
	    set data(selectPath) [pwd]
	    cd $old
	} else {
	    set data(selectPath) [pwd]
	}
    }
    set data(selectFile) $data(-initialfile)

    # 5. Parse the -filetypes option
    #
    set data(-filetypes) [tkFDGetFileTypes $data(-filetypes)]

    if {![winfo exists $data(-parent)]} {
	error "bad window path name \"$data(-parent)\""
    }
}

proc ::LCARS::dialog::file::Create {w class} {
    set dataName [lindex [split $w .] end]
    upvar ::LCARS::dialog::file::$dataName data
    global tk_library tkPriv

    toplevel $w -class $class
    wm overrideredirect $w 1
    canvas $w.pane -width 600 -height 300 -background black -borderwidth 0
    pack $w.pane
    foreach ele [array names ::LCARS::dialog::CornersHFatVNarrowSmall] {
      foreach {bm wid hei an} $::LCARS::dialog::CornersHFatVNarrowSmall($ele) {
	switch $ele {
	  LL {set x 0
	      set y [$w.pane cget -height]
	      set bxLL1 [expr $x + $wid]
	      set byLL1 [expr $y - 18]
	      set bxLL2 [expr $x + 5]
	      set byLL2 [expr $y - $hei]
	      set uLLx [expr $x + 8]
	      set uLLy $byLL2
	  }
	  LR {set x [$w.pane cget -width]
	      set y [$w.pane cget -height]
	      set bxLR1 [expr $x - $wid]
	      set byLR1 [expr $y - 0]
	      set bxLR2 [expr $x - 5]
	      set byLR2 [expr $y - $hei]
	      set uLRx [expr $x - 8]
	      set uLRy $byLR2
	  }
	  UL {set x 0
	      set y 0
	      set bxUL1 [expr $x + $wid]
	      set byUL1 [expr $y + 0]
	      set bxUL2 [expr $x + 0]
	      set byUL2 [expr $y + $hei]
	      set uULx [expr $x + 8]
	      set uULy $byUL2
	  }
	  UR {set x [$w.pane cget -width]
	      set y 0
	      set bxUR1 [expr $x - $wid]
	      set byUR1 [expr 0 + 18]
	      set bxUR2 [expr $x - 0]
	      set byUR2 [expr 0 + $hei]
	      set uURx [expr $x - 8]
	      set uURy $byUR1
	  }
	}
	$w.pane create bitmap $x $y -anchor $an -bitmap $bm -foreground blue
      }
    }

    $w.pane create rect $bxUL1 $byUL1 $bxUR1 $byUR1 -outline {} -fill blue
    $w.pane create rect $bxLL1 $byLL1 $bxLR1 $byLR1 -outline {} -fill blue
    $w.pane create rect $bxUL2 $byUL2 $bxLL2 $byLL2 -outline {} -fill blue
    $w.pane create rect $bxUR2 $byUR2 $bxLR2 $byLR2 -outline {} -fill blue




    # f1: the frame with the directory option menu
    #
    set f1 [frame $w.f1 -width [expr $uURx - $uULx]]
    OvalRoundCornerRectangle $w.pane f1 -x $uULx -y $uULy \
				         -width [expr $uURx - $uULx] \
					 -height 40 \
					 -color grey
    OvalLabel $w.pane f1.lab -x [expr $uULx + 5] -y [expr $uULy + 1] \
    	-text "Directory:" -under 0 -color green -undercolor yellow \
	-font [list {Trek TNG Monitors} -28 bold]
    label $f1.lab -text "Directory:" -under 0
    set data(LCARSdirMenuBtn) f1.menu
#    set data(LCARSdirMenu) [OvalOptionMenu $w.pane f1.menu [format %s(LCARSselectPath) ::LCARS::dialog::file::$dataName] ""]
    set data(dirMenuBtn) $f1.menu
    set data(dirMenu) [tk_optionMenu $f1.menu [format %s(selectPath) ::LCARS::dialog::file::$dataName] ""]
    set data(upBtn) [button $f1.up]
    if {![info exists tkPriv(updirImage)]} {
	set tkPriv(updirImage) [image create bitmap -data {
#define updir_width 28
#define updir_height 16
static char updir_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x80, 0x1f, 0x00, 0x00, 0x40, 0x20, 0x00, 0x00,
   0x20, 0x40, 0x00, 0x00, 0xf0, 0xff, 0xff, 0x01, 0x10, 0x00, 0x00, 0x01,
   0x10, 0x02, 0x00, 0x01, 0x10, 0x07, 0x00, 0x01, 0x90, 0x0f, 0x00, 0x01,
   0x10, 0x02, 0x00, 0x01, 0x10, 0x02, 0x00, 0x01, 0x10, 0x02, 0x00, 0x01,
   0x10, 0xfe, 0x07, 0x01, 0x10, 0x00, 0x00, 0x01, 0x10, 0x00, 0x00, 0x01,
   0xf0, 0xff, 0xff, 0x01};}]
    }
    $data(upBtn) config -image $tkPriv(updirImage)

    $f1.menu config -takefocus 1 -highlightthickness 2
 
    pack $data(upBtn) -side right -padx 4 -fill both
    pack $f1.lab -side left -padx 4 -fill both
    pack $f1.menu -expand yes -fill both -padx 4

    # data(icons): the IconList that list the files and directories.
    #
    if { [string equal $class TkFDialog] } {
	set fNameCaption "File name:"
	set fNameUnder 5
	set iconListCommand [list ::LCARS::dialog::file::OkCmd $w]
    } else {
	set fNameCaption "Selection:"
	set fNameUnder 0
	set iconListCommand [list ::LCARS::dialog::file::chooseDir::DblClick $w]
    }
    set data(icons) [tkIconList $w.icons \
	-browsecmd [list ::LCARS::dialog::file::ListBrowse $w] \
	-command   $iconListCommand]

    # f2: the frame with the OK button and the "file name" field
    #
    set f2 [frame $w.f2 -bd 0]
    label $f2.lab -text $fNameCaption -anchor e -width 14 \
	    -under $fNameUnder -pady 0
    set data(ent) [entry $f2.ent]

    # The font to use for the icons. The default Canvas font on Unix
    # is just deviant.
    global $w.icons
    set $w.icons(font) [$data(ent) cget -font]

    # f3: the frame with the cancel button and the file types field
    #
    set f3 [frame $w.f3 -bd 0]

    # Make the file types bits only if this is a File Dialog
    if { [string equal $class TkFDialog] } {
	# The "File of types:" label needs to be grayed-out when
	# -filetypes are not specified. The label widget does not support
	# grayed-out text on monochrome displays. Therefore, we have to
	# use a button widget to emulate a label widget (by setting its
	# bindtags)
	
	set data(typeMenuLab) [button $f3.lab -text "Files of type:" \
		-anchor e -width 14 -under 9 \
		-bd [$f2.lab cget -bd] \
		-highlightthickness [$f2.lab cget -highlightthickness] \
		-relief [$f2.lab cget -relief] \
		-padx [$f2.lab cget -padx] \
		-pady [$f2.lab cget -pady]]
	bindtags $data(typeMenuLab) [list $data(typeMenuLab) Label \
		[winfo toplevel $data(typeMenuLab)] all]
	
	set data(typeMenuBtn) [menubutton $f3.menu -indicatoron 1 \
		-menu $f3.menu.m]
	set data(typeMenu) [menu $data(typeMenuBtn).m -tearoff 0]
	$data(typeMenuBtn) config -takefocus 1 -highlightthickness 2 \
		-relief raised -bd 2 -anchor w
    }

    # the okBtn is created after the typeMenu so that the keyboard traversal
    # is in the right order
    set data(okBtn)     [button $f2.ok     -text OK     -under 0 -width 6 \
	-default active -pady 3]
    set data(cancelBtn) [button $f3.cancel -text Cancel -under 0 -width 6\
	-default normal -pady 3]

    # pack the widgets in f2 and f3
    #
    pack $data(okBtn) -side right -padx 4 -anchor e
    pack $f2.lab -side left -padx 4
    pack $f2.ent -expand yes -fill x -padx 2 -pady 0
    
    pack $data(cancelBtn) -side right -padx 4 -anchor w
    if { [string equal $class TkFDialog] } {
	pack $data(typeMenuLab) -side left -padx 4
	pack $data(typeMenuBtn) -expand yes -fill x -side right
    }

    # Pack all the frames together. We are done with widget construction.
    #
    pack $f1 -side top -fill x -pady 4
    pack $f3 -side bottom -fill x
    pack $f2 -side bottom -fill x
    pack $data(icons) -expand yes -fill both -padx 4 -pady 1

    # Set up the event handlers that are common to Directory and File Dialogs
    #

    wm protocol $w WM_DELETE_WINDOW [list ::LCARS::dialog::file::CancelCmd $w]
    $data(upBtn)     config -command [list ::LCARS::dialog::file::UpDirCmd $w]
    $data(cancelBtn) config -command [list ::LCARS::dialog::file::CancelCmd $w]
    bind $w <KeyPress-Escape> [list tkButtonInvoke $data(cancelBtn)]
    bind $w <Alt-c> [list tkButtonInvoke $data(cancelBtn)]
    bind $w <Alt-d> [list focus $data(dirMenuBtn)]

    # Set up event handlers specific to File or Directory Dialogs
    #

    if { [string equal $class TkFDialog] } {
	bind $data(ent) <Return> [list ::LCARS::dialog::file::ActivateEnt $w]
	$data(okBtn)     config -command [list ::LCARS::dialog::file::OkCmd $w]
	bind $w <Alt-t> [format {
	    if {[string equal [%s cget -state] "normal"]} {
		focus %s
	    }
	} $data(typeMenuBtn) $data(typeMenuBtn)]
	bind $w <Alt-n> [list focus $data(ent)]
	bind $w <Alt-o> [list ::LCARS::dialog::file::InvokeBtn $w Open]
	bind $w <Alt-s> [list ::LCARS::dialog::file::InvokeBtn $w Save]
    } else {
	set okCmd [list ::LCARS::dialog::file::chooseDir::OkCmd $w]
	bind $data(ent) <Return> $okCmd
	$data(okBtn) config -command $okCmd
	bind $w <Alt-s> [list focus $data(ent)]
	bind $w <Alt-o> [list tkButtonInvoke $data(okBtn)]
    }

    # Build the focus group for all the entries
    #
    tkFocusGroup_Create $w
    tkFocusGroup_BindIn $w  $data(ent) [list ::LCARS::dialog::file::EntFocusIn $w]
    tkFocusGroup_BindOut $w $data(ent) [list ::LCARS::dialog::file::EntFocusOut $w]
}


# ::LCARS::dialog::file::UpdateWhenIdle --
#
#	Creates an idle event handler which updates the dialog in idle
#	time. This is important because loading the directory may take a long
#	time and we don't want to load the same directory for multiple times
#	due to multiple concurrent events.
#
proc ::LCARS::dialog::file::UpdateWhenIdle {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    if {[info exists data(updateId)]} {
	return
    } else {
	set data(updateId) [after idle [list ::LCARS::dialog::file::Update $w]]
    }
}

# ::LCARS::dialog::file::Update --
#
#	Loads the files and directories into the IconList widget. Also
#	sets up the directory option menu for quick access to parent
#	directories.
#
proc ::LCARS::dialog::file::Update {w} {

    # This proc may be called within an idle handler. Make sure that the
    # window has not been destroyed before this proc is called
    if {![winfo exists $w]} {
	return
    }
    set class [winfo class $w]
    if { [string compare $class TkFDialog] && \
	    [string compare $class TkChooseDir] } {
	return
    }

    set dataName [winfo name $w]
    upvar ::LCARS::dialog::file::$dataName data
    global tk_library tkPriv
    catch {unset data(updateId)}

    if {![info exists tkPriv(folderImage)]} {
	set tkPriv(folderImage) [image create photo -data {
R0lGODlhEAAMAKEAAAD//wAAAPD/gAAAACH5BAEAAAAALAAAAAAQAAwAAAIghINhyycvVFsB
QtmS3rjaH1Hg141WaT5ouprt2HHcUgAAOw==}]
	set tkPriv(fileImage)   [image create photo -data {
R0lGODlhDAAMAKEAALLA3AAAAP//8wAAACH5BAEAAAAALAAAAAAMAAwAAAIgRI4Ha+IfWHsO
rSASvJTGhnhcV3EJlo3kh53ltF5nAhQAOw==}]
    }
    set folder $tkPriv(folderImage)
    set file   $tkPriv(fileImage)

    set appPWD [pwd]
    if {[catch {
	cd $data(selectPath)
    }]} {
	# We cannot change directory to $data(selectPath). $data(selectPath)
	# should have been checked before ::LCARS::dialog::file::Update is called, so
	# we normally won't come to here. Anyways, give an error and abort
	# action.
	tk_messageBox -type ok -parent $w -message \
	    "Cannot change to the directory \"$data(selectPath)\".\nPermission denied."\
	    -icon warning
	cd $appPWD
	return
    }

    # Turn on the busy cursor. BUG?? We haven't disabled X events, though,
    # so the user may still click and cause havoc ...
    #
    set entCursor [$data(ent) cget -cursor]
    set dlgCursor [$w         cget -cursor]
    $data(ent) config -cursor watch
    $w         config -cursor watch
    update idletasks
    
    tkIconList_DeleteAll $data(icons)

    # Make the dir list
    #
    foreach f [lsort -dictionary [glob -nocomplain .* *]] {
	if {[string equal $f .]} {
	    continue
	}
	if {[string equal $f ..]} {
	    continue
	}
	if {[file isdir ./$f]} {
	    if {![info exists hasDoneDir($f)]} {
		tkIconList_Add $data(icons) $folder $f
		set hasDoneDir($f) 1
	    }
	}
    }
    if { [string equal $class TkFDialog] } {
	# Make the file list if this is a File Dialog
	#
	if {[string equal $data(filter) *]} {
	    set files [lsort -dictionary \
		    [glob -nocomplain .* *]]
	} else {
	    set files [lsort -dictionary \
		    [eval glob -nocomplain $data(filter)]]
	}
	
	foreach f $files {
	    if {![file isdir ./$f]} {
		if {![info exists hasDoneFile($f)]} {
		    tkIconList_Add $data(icons) $file $f
		    set hasDoneFile($f) 1
		}
	    }
	}
    }

    tkIconList_Arrange $data(icons)

    # Update the Directory: option menu
    #
    set list ""
    set dir ""
    foreach subdir [file split $data(selectPath)] {
	set dir [file join $dir $subdir]
	lappend list $dir
    }

    $data(dirMenu) delete 0 end
    set var [format %s(selectPath) ::LCARS::dialog::file::$dataName]
    foreach path $list {
	$data(dirMenu) add command -label $path -command [list set $var $path]
    }

    # Restore the PWD to the application's PWD
    #
    cd $appPWD

    if { [string equal $class TkFDialog] } {
	# Restore the Open/Save Button if this is a File Dialog
	#
	if {[string equal $data(type) open]} {
	    $data(okBtn) config -text "Open"
	} else {
	    $data(okBtn) config -text "Save"
	}
    }

    # turn off the busy cursor.
    #
    $data(ent) config -cursor $entCursor
    $w         config -cursor $dlgCursor
}

# ::LCARS::dialog::file::SetPathSilently --
#
# 	Sets data(selectPath) without invoking the trace procedure
#
proc ::LCARS::dialog::file::SetPathSilently {w path} {
    upvar ::LCARS::dialog::file::[winfo name $w] data
    
    trace vdelete  data(selectPath) w [list ::LCARS::dialog::file::SetPath $w]
    set data(selectPath) $path
    trace variable data(selectPath) w [list ::LCARS::dialog::file::SetPath $w]
}


# This proc gets called whenever data(selectPath) is set
#
proc ::LCARS::dialog::file::SetPath {w name1 name2 op} {
    if {[winfo exists $w]} {
	upvar ::LCARS::dialog::file::[winfo name $w] data
	::LCARS::dialog::file::UpdateWhenIdle $w
	# On directory dialogs, we keep the entry in sync with the currentdir.
	if { [string equal [winfo class $w] TkChooseDir] } {
	    $data(ent) delete 0 end
	    $data(ent) insert end $data(selectPath)
	}
    }
}

# This proc gets called whenever data(filter) is set
#
proc ::LCARS::dialog::file::SetFilter {w type} {
    upvar ::LCARS::dialog::file::[winfo name $w] data
    upvar \#0 $data(icons) icons

    set data(filter) [lindex $type 1]
    $data(typeMenuBtn) config -text [lindex $type 0] -indicatoron 1

    $icons(sbar) set 0.0 0.0
    
    ::LCARS::dialog::file::UpdateWhenIdle $w
}

# tk::dialog::file::ResolveFile --
#
#	Interpret the user's text input in a file selection dialog.
#	Performs:
#
#	(1) ~ substitution
#	(2) resolve all instances of . and ..
#	(3) check for non-existent files/directories
#	(4) check for chdir permissions
#
# Arguments:
#	context:  the current directory you are in
#	text:	  the text entered by the user
#	defaultext: the default extension to add to files with no extension
#
# Return vaue:
#	[list $flag $directory $file]
#
#	 flag = OK	: valid input
#	      = PATTERN	: valid directory/pattern
#	      = PATH	: the directory does not exist
#	      = FILE	: the directory exists by the file doesn't
#			  exist
#	      = CHDIR	: Cannot change to the directory
#	      = ERROR	: Invalid entry
#
#	 directory      : valid only if flag = OK or PATTERN or FILE
#	 file           : valid only if flag = OK or PATTERN
#
#	directory may not be the same as context, because text may contain
#	a subdirectory name
#
proc ::LCARS::dialog::file::ResolveFile {context text defaultext} {

    set appPWD [pwd]

    set path [::LCARS::dialog::file::JoinFile $context $text]

    # If the file has no extension, append the default.  Be careful not
    # to do this for directories, otherwise typing a dirname in the box
    # will give back "dirname.extension" instead of trying to change dir.
    if {![file isdirectory $path] && [string equal [file ext $path] ""]} {
	set path "$path$defaultext"
    }


    if {[catch {file exists $path}]} {
	# This "if" block can be safely removed if the following code
	# stop generating errors.
	#
	#	file exists ~nonsuchuser
	#
	return [list ERROR $path ""]
    }

    if {[file exists $path]} {
	if {[file isdirectory $path]} {
	    if {[catch {cd $path}]} {
		return [list CHDIR $path ""]
	    }
	    set directory [pwd]
	    set file ""
	    set flag OK
	    cd $appPWD
	} else {
	    if {[catch {cd [file dirname $path]}]} {
		return [list CHDIR [file dirname $path] ""]
	    }
	    set directory [pwd]
	    set file [file tail $path]
	    set flag OK
	    cd $appPWD
	}
    } else {
	set dirname [file dirname $path]
	if {[file exists $dirname]} {
	    if {[catch {cd $dirname}]} {
		return [list CHDIR $dirname ""]
	    }
	    set directory [pwd]
	    set file [file tail $path]
	    if {[regexp {[*]|[?]} $file]} {
		set flag PATTERN
	    } else {
		set flag FILE
	    }
	    cd $appPWD
	} else {
	    set directory $dirname
	    set file [file tail $path]
	    set flag PATH
	}
    }

    return [list $flag $directory $file]
}


# Gets called when the entry box gets keyboard focus. We clear the selection
# from the icon list . This way the user can be certain that the input in the 
# entry box is the selection.
#
proc ::LCARS::dialog::file::EntFocusIn {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    if {[string compare [$data(ent) get] ""]} {
	$data(ent) selection range 0 end
	$data(ent) icursor end
    } else {
	$data(ent) selection clear
    }

    tkIconList_Unselect $data(icons)

    if { [string equal [winfo class $w] TkFDialog] } {
	# If this is a File Dialog, make sure the buttons are labeled right.
	if {[string equal $data(type) open]} {
	    $data(okBtn) config -text "Open"
	} else {
	    $data(okBtn) config -text "Save"
	}
    }
}

proc ::LCARS::dialog::file::EntFocusOut {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    $data(ent) selection clear
}


# Gets called when user presses Return in the "File name" entry.
#
proc ::LCARS::dialog::file::ActivateEnt {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    set text [string trim [$data(ent) get]]
    set list [::LCARS::dialog::file::ResolveFile $data(selectPath) $text \
		  $data(-defaultextension)]
    set flag [lindex $list 0]
    set path [lindex $list 1]
    set file [lindex $list 2]

    switch -- $flag {
	OK {
	    if {[string equal $file ""]} {
		# user has entered an existing (sub)directory
		set data(selectPath) $path
		$data(ent) delete 0 end
	    } else {
		::LCARS::dialog::file::SetPathSilently $w $path
		set data(selectFile) $file
		::LCARS::dialog::file::Done $w
	    }
	}
	PATTERN {
	    set data(selectPath) $path
	    set data(filter) $file
	}
	FILE {
	    if {[string equal $data(type) open]} {
		tk_messageBox -icon warning -type ok -parent $w \
		    -message "File \"[file join $path $file]\" does not exist."
		$data(ent) selection range 0 end
		$data(ent) icursor end
	    } else {
		::LCARS::dialog::file::SetPathSilently $w $path
		set data(selectFile) $file
		::LCARS::dialog::file::Done $w
	    }
	}
	PATH {
	    tk_messageBox -icon warning -type ok -parent $w \
		-message "Directory \"$path\" does not exist."
	    $data(ent) selection range 0 end
	    $data(ent) icursor end
	}
	CHDIR {
	    tk_messageBox -type ok -parent $w -message \
	       "Cannot change to the directory \"$path\".\nPermission denied."\
		-icon warning
	    $data(ent) selection range 0 end
	    $data(ent) icursor end
	}
	ERROR {
	    tk_messageBox -type ok -parent $w -message \
	       "Invalid file name \"$path\"."\
		-icon warning
	    $data(ent) selection range 0 end
	    $data(ent) icursor end
	}
    }
}

# Gets called when user presses the Alt-s or Alt-o keys.
#
proc ::LCARS::dialog::file::InvokeBtn {w key} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    if {[string equal [$data(okBtn) cget -text] $key]} {
	tkButtonInvoke $data(okBtn)
    }
}

# Gets called when user presses the "parent directory" button
#
proc ::LCARS::dialog::file::UpDirCmd {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    if {[string compare $data(selectPath) "/"]} {
	set data(selectPath) [file dirname $data(selectPath)]
    }
}

# Join a file name to a path name. The "file join" command will break
# if the filename begins with ~
#
proc ::LCARS::dialog::file::JoinFile {path file} {
    if {[string match {~*} $file] && [file exists $path/$file]} {
	return [file join $path ./$file]
    } else {
	return [file join $path $file]
    }
}



# Gets called when user presses the "OK" button
#
proc ::LCARS::dialog::file::OkCmd {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    set text [tkIconList_Get $data(icons)]
    if {[string compare $text ""]} {
	set file [::LCARS::dialog::file::JoinFile $data(selectPath) $text]
	if {[file isdirectory $file]} {
	    ::LCARS::dialog::file::ListInvoke $w $text
	    return
	}
    }

    ::LCARS::dialog::file::ActivateEnt $w
}

# Gets called when user presses the "Cancel" button
#
proc ::LCARS::dialog::file::CancelCmd {w} {
    upvar ::LCARS::dialog::file::[winfo name $w] data
    global tkPriv

    set tkPriv(selectFilePath) ""
}

# Gets called when user browses the IconList widget (dragging mouse, arrow
# keys, etc)
#
proc ::LCARS::dialog::file::ListBrowse {w text} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    if {[string equal $text ""]} {
	return
    }

    set file [::LCARS::dialog::file::JoinFile $data(selectPath) $text]
    if {![file isdirectory $file]} {
	$data(ent) delete 0 end
	$data(ent) insert 0 $text

	if { [string equal [winfo class $w] TkFDialog] } {
	    if {[string equal $data(type) open]} {
		$data(okBtn) config -text "Open"
	    } else {
		$data(okBtn) config -text "Save"
	    }
	}
    } else {
	if { [string equal [winfo class $w] TkFDialog] } {
	    $data(okBtn) config -text "Open"
	}
    }
}

# Gets called when user invokes the IconList widget (double-click, 
# Return key, etc)
#
proc ::LCARS::dialog::file::ListInvoke {w text} {
    upvar ::LCARS::dialog::file::[winfo name $w] data

    if {[string equal $text ""]} {
	return
    }

    set file [::LCARS::dialog::file::JoinFile $data(selectPath) $text]
    set class [winfo class $w]
    if {[string equal $class TkChooseDir] || [file isdirectory $file]} {
	set appPWD [pwd]
	if {[catch {cd $file}]} {
	    tk_messageBox -type ok -parent $w -message \
	       "Cannot change to the directory \"$file\".\nPermission denied."\
		-icon warning
	} else {
	    cd $appPWD
	    set data(selectPath) $file
	}
    } else {
	set data(selectFile) $file
	::LCARS::dialog::file::Done $w
    }
}

# ::LCARS::dialog::file::Done --
#
#	Gets called when user has input a valid filename.  Pops up a
#	dialog box to confirm selection when necessary. Sets the
#	tkPriv(selectFilePath) variable, which will break the "tkwait"
#	loop in tkFDialog and return the selected filename to the
#	script that calls tk_getOpenFile or tk_getSaveFile
#
proc ::LCARS::dialog::file::Done {w {selectFilePath ""}} {
    upvar ::LCARS::dialog::file::[winfo name $w] data
    global tkPriv

    if {[string equal $selectFilePath ""]} {
	set selectFilePath [::LCARS::dialog::file::JoinFile $data(selectPath) \
		$data(selectFile)]
	set tkPriv(selectFile)     $data(selectFile)
	set tkPriv(selectPath)     $data(selectPath)

	if {[file exists $selectFilePath] && [string equal $data(type) save]} {
	    set reply [tk_messageBox -icon warning -type yesno\
		    -parent $w -message "File\
		    \"$selectFilePath\" already exists.\nDo\
		    you want to overwrite it?"]
	    if {[string equal $reply "no"]} {
		return
	    }
	}
    }
    set tkPriv(selectFilePath) $selectFilePath
}


package provide LCARSWidgets 1.0
