#* 
#* ------------------------------------------------------------------
#* CTCPanelWindow.tcl - CTC Panel Window widget
#* Created by Robert Heller on Mon Apr 14 11:23:02 2008
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

# $Id$

package require grsupport 2.0
package require CTCPanel 2.0
package require BWLabelSpinBox
package require BWLabelComboBox
package require LabelSelectColor

catch {Dispatcher::SplashWorkMessage "Loading CTC Panel Window Code" 16}

namespace eval CTCPanelWindow {
  snit::widget CTCPanelWindow {
    widgetclass CTCPanelWindow
    hulltype    toplevel

    typevariable CodeLibraryDir {}
    typevariable OpenWindows -array {}
    typemethod selectwindowbyname {name} {
      if {[catch {set OpenWindows($name)} window]} {
	error "No such window: $name!"
      } else {
	return $window
      }
    }
    typemethod allopenwindownames {} {return [array names OpenWindows]}

    component main
    component swframe
    component ctcpanel
    component dirty

    delegate method {ctcpanel create} to ctcpanel

    option -name -default {Unnamed} -readonly yes \
	   	 -validatemethod _CheckUniqueName
    method _CheckUniqueName {option value} {
      if {[lsearch -exact [array names OpenWindows] "$value"] >= 0} {
	error "Duplicate $option: $value"
      }
    }
      
    option -filename -default {newctcpanel.tcl}
    delegate option -width to ctcpanel
    delegate option -height to ctcpanel
    delegate option -menu to hull
    option -hascmri -default no -validatemethod _VerifyBoolean \
				-configuremethod _ConfigureCMRI
    GRSupport::VerifyBooleanMethod
    method _ConfigureCMRI {option value} {
      set options($option) $value
      if {$value} {
	$main mainframe setmenustate cmri normal
      } else {
	$main mainframe setmenustate cmri disabled
      }
    }
    option -cmriport -default /dev/ttyS1
    option -cmrispeed -default 9600
    option -cmriretries -default 1000
    variable cmrinodes -array {}

    variable userCode {}
    variable IsDirty yes

    method isdirtyp {} {return $IsDirty}
    method setdirty {} {
      set IsDirty yes
      $dirty configure -foreground red
    }
    method cleardirty {} {
      set IsDirty no
      $dirty configure -foreground [$dirty cget -background]
    }
    constructor {args} {
      wm protocol $win WM_DELETE_WINDOW {Dispatcher::CarefulExit}
      wm withdraw $win
      wm title $win {}
      install main using mainwindow $win.main \
	-extramenus [list \
		      &Panel panel panel 0 [list \
			[list command "Add Object" {} "Add Panel Object" {} \
				-command [mymethod addpanelobject]] \
			[list command "Edit Object" {} "Edit Panel Object" {} \
				-command [mymethod editpanelobject]] \
			[list command "Delete Object" {} "Delete Panel Object" {} \
				-command [mymethod deletepanelobject]] \
			{separator} \
			[list command "Configure" {} "Configure Panel Options" {} \
				-command [mymethod configurepanel]] \
			] \
		      &C/Mri cmri cmri 0 [list \
			[list command "Add node" {} "Add CMRI node" {} \
				-command [mymethod addcmrinode]] \
			[list command "Edit node" {} "Edit CMRI node" {} \
				-command [mymethod editcmrinode]] \
			[list command "Delete Node" {} "Delete CMRI node" {} \
				-command [mymethod deletecmrinode]] \
			] \
		    ]

      $main mainframe setmenustate cmri disabled
      pack $main -expand yes -fill both
      $main menu entryconfigure file New \
			-command [mytypemethod new -parent $win] \
			-dynamichelp "New CTC Panel Window" \
			-label "New CTC Panel Window" \
			-accelerator {Ctrl-N}
      $main menu insert file Open... \
		command -label Load... \
		-dynamichelp "Open and Load XTrkCad Layout File" \
		-command Dispatcher::LoadLayout \
		-underline 0 \
		-accelerator {Ctrl-L}
      $main menu entryconfigure file Open... \
		-command [mytypemethod open -parent $win] \
		-dynamichelp "Open an existing CTC Panel Window file" \
		-accelerator {Ctrl-O}
      $main menu entryconfigure file Save \
				-command [mymethod save] \
				-dynamichelp "Save window code" \
				-accelerator {Ctrl-S}
      $main menu entryconfigure file {Save As...} \
				-command [mymethod saveas] \
				-dynamichelp "Save window code" \
				-accelerator {Ctrl-A}
      $main menu entryconfigure file Print... -state disabled
      $main menu entryconfigure file Close -command [mymethod close]
      $main menu entryconfigure file Exit -command {Dispatcher::CarefulExit}

      set frame [$main scrollwindow getframe]
      install swframe using ScrollableFrame $frame.swframe \
			-constrainedheight yes -constrainedwidth yes
      pack $swframe -expand yes -fill both
      $main scrollwindow setwidget $swframe
      install ctcpanel using ::CTCPanel::CTCPanel [$swframe getframe].ctcpanel
      pack $ctcpanel -fill both -expand yes
      $self configurelist $args
      $swframe configure -width [expr {[$ctcpanel cget -width] + 15}] \
			 -height [$ctcpanel cget -height]
      wm title $win $options(-name)


      set dirty [$main mainframe addindicator]
      $dirty configure -bitmap gray50 -foreground red

      $main menu add view command \
		-label {Zoom In} \
		-accelerator {+} \
		-command "$ctcpanel zoomBy 2"
      set zoomMenu [menu [$main mainframe getmenu view].zoom -tearoff no]
      $main menu add view cascade \
		-label Zoom \
		-menu $zoomMenu
      $main menu add view command \
		-label {Zoom Out} \
		-accelerator {-} \
		-command "$ctcpanel zoomBy .5"
      $zoomMenu add command -label {16:1} -command "$ctcpanel setZoom 16"
      $zoomMenu add command -label {8:1} -command "$ctcpanel setZoom 8"
      $zoomMenu add command -label {4:1} -command "$ctcpanel setZoom 4"
      $zoomMenu add command -label {2:1} -command "$ctcpanel setZoom 2"
      $zoomMenu add command -label {1:1} -command "$ctcpanel setZoom 1"
      $zoomMenu add command -label {1:2} -command "$ctcpanel setZoom .5"
      $zoomMenu add command -label {1:4} -command "$ctcpanel setZoom .25"
      $zoomMenu add command -label {1:8} -command "$ctcpanel setZoom .125"
      $zoomMenu add command -label {1:16} -command "$ctcpanel setZoom .0625"


      $main menu add edit separator
      $main menu add edit command \
		-label {(Re-)Generate Main Loop} \
		-command [mymethod GenerateMainLoop]
      $main menu add edit command \
		-label {User Code} \
		-command [mymethod EditUserCode]
      set modMenu [menu [$main mainframe getmenu edit].modules -tearoff no]
      $main menu add edit cascade \
		-label {Modules} \
		-menu $modMenu
      $modMenu  add command -label {Track Work types} \
		-command [mymethod AddModule TrackWork]
      $modMenu  add command -label {Switch Plate type} \
		-command [mymethod AddModule SwitchPlates]
      set sigMenu [menu $modMenu.sigMenu -tearoff no]
      $modMenu  add cascade -label {Signals} \
		-menu $sigMenu
	$sigMenu add command -label {Two Aspect Color Light} \
			     -command [mymethod AddModule Signals2ACL]
	$sigMenu add command -label {Three Aspect Color Light} \
			     -command [mymethod AddModule Signals3ACL]
	$sigMenu add command -label {Three Aspect Search Light} \
			     -command [mymethod AddModule Signals3ASL]
      $modMenu  add command -label {Signal Plate type} \
		-command [mymethod AddModule SignalPlates]
      $modMenu  add command -label {Control Point type} \
		-command [mymethod AddModule ControlPoints]
      $modMenu  add command -label {Radio Group Type} \
		-command [mymethod AddModule Groups]

      $main showit
      set OpenWindows($options(-name)) $win
      Dispatcher::AddToWindows $win "$options(-name)"
      $self buildDialogs
    }
    destructor {
#      puts stderr "*** $self destroy: win = $win, array names OpenWindows = [array names OpenWindows]"
      if {![catch {set OpenWindows($options(-name))} xwin] &&
	  [string equal "$xwin" "$win"]} {
#	puts stderr "*** $self destroy: xwin = $xwin"
	catch {Dispatcher::RemoveFromWindows $win "$options(-name)"}
	unset OpenWindows($options(-name))
      }
    }
    method close {} {
      if {[$self isdirtyp]} {
	if {[tk_messageBox -type yesno -icon question -parent $win \
			   -message "Window $options(-name) is modified.  Save it?"]} {
	  $self save
	}
      }
#      puts stderr "*** $self close"
      destroy $self
    }
    method save {} {
      $self saveas "$options(-filename)"
    }
    method saveas {{filename {}}} {
      if {[string length "$filename"] == 0} {
	set initdir [file dirname "$options(-filename)"]
	if {[string equal "$initdir" {.}]} {set initdir [pwd]}
	set filename [tk_getSaveFile -initialfile "$options(-filename)" \
				     -initialdir  "$initdir" \
				     -defaultextension ".tcl" \
				     -filetypes { {{Tcl Files} {.tcl} TEXT}
						  {{All Files} *      TEXT} } \
				     -title "File to save to" \
				     -parent $win]
      }
      if {[string length "$filename"] == 0} {return}
      if {[file exists "$filename"]} {
	file rename -force "$filename" "${filename}~"
      }
      if {[catch {open "$filename" w} fp]} {
	catch {file rename -force "${filename}~" "$filename"}
	tk_messageBox -type ok -icon error \
		      -message "Could not open $filename: $fp"
	return
      }
      puts $fp {#!/usr/bin/wish}
      puts $fp "# Generated code: [clock format [clock scan now]]"
      puts $fp {# Generated by: $Id$}
      puts $fp {# Add your code to the bottom (after the 'Add User code after this line').}
      puts $fp {#}
      puts $fp [list # -name "$options(-name)"]
      puts $fp [list # -width [$ctcpanel cget -width]]
      puts $fp [list # -height [$ctcpanel cget -height]]
      puts $fp "# -hascmri $options(-hascmri)"
      if {$options(-hascmri)} {
	puts $fp [list # -cmriport "$options(-cmriport)"]
	puts $fp [list # -cmrispeed $options(-cmrispeed)]
	puts $fp [list # -cmriretries $options(-cmriretries)]
      }
      puts $fp {# Load Tcl/Tk system supplied packages}
      puts $fp {package require Tk;#            Make sure Tk is loaded}
      puts $fp {package require BWidget;#       Load BWidgets}
      puts $fp {package require snit;#          Load Snit}
      puts $fp {}
      puts $fp {# Load MRR System packages}
      puts $fp {# Add MRR System package Paths}
      puts $fp {lappend auto_path /usr/local/lib/MRRSystem;# C++ (binary) packages}
      puts $fp {lappend auto_path /usr/local/share/MRRSystem;# Tcl (source) packages}
      puts $fp {}
      puts $fp {package require BWStdMenuBar;#  Load the standard menu bar package}
      puts $fp {package require MainWindow;#    Load the Main Window package}
      puts $fp {package require CTCPanel 2.0;#  Load the CTCPanel package (V2)}
      puts $fp {package require grsupport 2.0;# Load Graphics Support code (V2)}
      puts $fp {}
      set panelCodeFp [open [file join "$CodeLibraryDir" \
				        panelCode.tcl] r]
      fcopy $panelCodeFp $fp
      close $panelCodeFp
      puts $fp {}
      puts $fp [list MainWindow createwindow -name "$options(-name)" \
					     -width [$ctcpanel cget -width] \
					     -height [$ctcpanel cget -height]]
      puts $fp {# CTCPanelObjects}
      foreach obj [$ctcpanel objectlist] {
	puts -nonewline $fp "MainWindow ctcpanel create "
	$ctcpanel print $obj $fp
      }
      if {$options(-hascmri)} {
	set cmriCodeFp [open [file join "$CodeLibraryDir" \
					cmriCode.tcl] r]
        fcopy $cmriCodeFp $fp
	close $cmriCodeFp
        puts $fp {}
        puts $fp [list CMriNode open "$options(-cmriport)" \
				     $options(-cmrispeed) \
				     $options(-cmriretries)]
	puts $fp {# CMRIBoards}
	foreach board [array names cmrinodes] {
	  puts $fp [concat CMriNode create $board $cmrinodes($board)]
	}
      }
      puts $fp {}
      puts $fp {# Add User code after this line}
      puts $fp "$userCode"
      close $fp
      file attributes "$filename" -permissions +x
      $self configure -filename "$filename"
      $self cleardirty
    }

    method showme {} {
      wm deiconify $win
      raise $win
    }

    method setUserCode {code} {
      set userCode "$code"
      $self setdirty
    }
    method getUserCode {} {return "$userCode"}

    typemethod addpanelobject {name args} {
      return [eval [list [$type selectwindowbyname "$name"] addpanelobject] $args]
    }
    typemethod editpanelobject {name args} {
      return [eval [list [$type selectwindowbyname "$name"] editpanelobject] $args]
    }
    typemethod deletepanelobject {name args} {
      return [eval [list [$type selectwindowbyname "$name"] deletepanelobject] $args]
    }
    typemethod configurepanel {name args} {
      return [eval [list [$type selectwindowbyname "$name"] configurepanel] $args]
    }
    typemethod addcmrinode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] addcmrinode] $args]
    }
    typemethod editcmrinode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] editcmrinode] $args]
    }
    typemethod deletecmrinode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] deletecmrinode] $args]
    }

    typemethod open {args} {
      set parent [from args -parent .]

      set filename [from args -file  {}]
#      puts stderr "*** $type open: filename = '$filename'"
      if {[string length "$filename"] == 0} {
        set filename [tk_getOpenFile -defaultextension ".tcl" \
      				   -initialfile newctcpanel.tcl \
				   -filetypes { {{Tcl Files} {.tcl} TEXT}
						{{All Files} *      TEXT} } \
				   -title "CTC File to open" \
				   -parent $parent]
#	puts stderr "*** $type open (after tk_getOpenFile): filename = '$filename'"
      }
      if {[string length "$filename"] == 0} {return}
      if {[catch {open "$filename" r} fp]} {
	tk_messageBox -type ok -icon error \
		      -message "Could not open $filename: $fp"
	return
      }
      set opts [list -filename "$filename"]
      set buffer {}
      while {[gets $fp line] >= 0} {
#        puts stderr "*** $type open (looking for options): line = '$line'"
	append buffer "$line"
	if {[info complete "$buffer"] && 
	    ![string equal "\\" "[string index $buffer end]"]} {
#	  puts stderr "*** $type open (looking for options): buffer = '$buffer'"
	  if {[regexp {^#} "$buffer"] < 1} {break}
	  if {[regexp {^# -} "$buffer"] < 1} {set buffer {};continue}
#	  puts stderr "$type open: buffer = '$buffer'"
#	  puts stderr "$type open: llength \$buffer is [llength $buffer]"
	  lappend opts [lindex $buffer 1] "[lindex $buffer 2]"
#	  puts stderr "$type open: opts = $opts"
	  set buffer {}
	} else {
	  append buffer "\n"
	}
      }
      set newWindow [eval [list $type create .ctcpanel%AUTO%] $opts]
      while {[gets $fp line] >= 0} {
#        puts stderr "*** $type open (looking for CTCPanelObjects): line = '$line'"
	if {[regexp {^# CTCPanelObjects$} "$line"] > 0} {break}
      }
      set buffer {}
      while {[gets $fp line] >= 0} {
#        puts stderr "*** $type open (reading CTCPanelObjects): line = '$line'"
	append buffer "$line"
	if {[info complete "$buffer"] && 
	    ![string equal "\\" "[string index $buffer end]"]} {
#	  puts stderr "*** $type open: buffer = $buffer"
	  if {[regexp {^MainWindow ctcpanel create (.*)$} "$buffer" -> obj] > 0} {
	    eval [list $newWindow ctcpanel create] $obj
	  } else {
	    break
	  }
	  set buffer {}
        } else {
	  append buffer "\n"
	}
      }
      while {[gets $fp line] >= 0} {
	if {[regexp {^# CMRIBoards$} "$line"] > 0} {break}
      }
      set buffer {}
      while {[gets $fp line] >= 0} {
	append buffer "$line"
	if {[info complete "$buffer"] && 
	    ![string equal "\\" "[string index $buffer end]"]} {
	  if {[regexp {^CMriNode create .*$} "$buffer"] > 0} {
	    $newWindow setcmrinode [lindex $buffer 2] "[lrange $buffer 3 end]"
	  } else {
	    break
	  }
	  set buffer {}
        } else {
	  append buffer "\n"
	}
      }
      while {[gets $fp line] >= 0} {
        if {[regexp {^# Add User code after this line$} "$line"] > 0} {break}
      }
      set code {}
      set nl {}
      while {[gets $fp line] >= 0} {
	append code "$nl$line"
	set nl "\n"
      }
      close $fp
      $newWindow setUserCode "$code"
      $newWindow cleardirty
      return $newWindow
    }
    method setcmrinode {board value} {
      set cmrinodes($board) "$value"
    }
    method getcmrinode {board} {
      if {[catch {set cmrinodes($board)} value]} {
	error "No such board: $board"
      } else {
	return "$value"
      }
    }
    method cmrinodelist {} {
      return [array names cmrinodes]
    }

    typecomponent newDialog
    typecomponent  new_nameLE
    typecomponent  new_widthLSB
    typecomponent  new_heightLSB
    typecomponent  new_hascmriLCB
    typecomponent  new_cmriportLCB
    typecomponent  new_cmrispeedLCB
    typecomponent  new_cmriretriesLSB

    typecomponent selectPanelDialog
    typecomponent   selectPanel_nameLCB

    typeconstructor {
#      puts stderr "*** $type constructor: \[info script\] = [info script]"
      set CodeLibraryDir [file join [file dirname \
					   [file dirname \
					         [file dirname \
						       [info script]]]] \
				      CodeLibrary]
      set newDialog {}
      set selectPanelDialog {}
    }
    typemethod createnewDialog {} {
      if {![string equal "$newDialog" {}] && [winfo exists $newDialog]} {return}
      set newDialog [Dialog::create .newCTCPanelWindowDialog \
			-bitmap questhead -default 0 \
			-cancel 1 -modal local -transient yes -parent . \
			-side bottom -title {New CTCPanel}]
      $newDialog add -name create -text Create -command [mytypemethod _NewCreate]
      $newDialog add -name cancel -text Cancel -command [mytypemethod _NewCancel]
      wm protocol [winfo toplevel $newDialog] WM_DELETE_WINDOW [mytypemethod _NewCancel]
      $newDialog add -name help -text Help -command {HTMLHelp::HTMLHelp help {Creating a new CTC Panel}}
      set frame [Dialog::getframe $newDialog]
      set new_nameLE [LabelEntry::create $frame.nameLE -label "Name:" \
						   -labelwidth 15\
						   -text {Unnamed}]
      pack $new_nameLE -fill x
      set new_widthLSB [LabelSpinBox::create $frame.widthLSB -label "Width:" \
						   -labelwidth 15 \
						   -range {780 1000 10}]
      pack $new_widthLSB -fill x
      set new_heightLSB [LabelSpinBox::create $frame.heightLSB -label "Height:" \
						   -labelwidth 15 \
						   -range {550 800 10}]
      pack $new_heightLSB -fill x
      set new_hascmriLCB [LabelComboBox::create $frame.hascmriLCB \
						   -label "Has CM/RI?" \
						   -labelwidth 15 \
						   -values {yes no} \
						   -editable no]
      $new_hascmriLCB setvalue last
      pack $new_hascmriLCB -fill x
      set new_cmriportLCB [LabelComboBox::create $frame.cmriportLCB \
						   -label "CM/RI Port:" \
						   -labelwidth 15 \
						   -values {/dev/ttyS0 
							    /dev/ttyS1 
							    /dev/ttyS2 
							    /dev/ttyS3}]
      pack $new_cmriportLCB -fill x
      $new_cmriportLCB setvalue first
      set new_cmrispeedLCB [LabelComboBox::create $frame.cmrispeedLCB \
						   -label "CM/RI Speed:" \
						   -labelwidth 15 \
						   -values {4800 9600 19200}]
      pack $new_cmrispeedLCB -fill x
      $new_cmrispeedLCB setvalue @1
      set new_cmriretriesLSB [LabelSpinBox::create $frame.cmriretriesLSB \
						   -label "CM/RI Retries:" \
						   -labelwidth 15 \
						   -range {5000 20000 100}]
      pack $new_cmriretriesLSB -fill x
      $new_cmriretriesLSB configure -text 10000
    }
    typemethod new {args} {
      $type createnewDialog
      set parent [from args -parent .]
      $newDialog configure -parent $parent
      wm transient [winfo toplevel $newDialog] $parent
      set nameindex 0
      set basename "[$new_nameLE cget -text]"
      regsub {[[:space:]][[:digit:]]+$} "$basename" {} basename
      while {[lsearch -exact [array names OpenWindows] "[$new_nameLE cget -text]"] >= 0} {
	incr nameindex
	$new_nameLE configure -text "$basename $nameindex"
      }
      return [$newDialog draw]
    }
    typemethod _NewCreate {} {
      $newDialog withdraw
      $type create .ctcpanel%AUTO% -name "[$new_nameLE cget -text]" \
				   -width [$new_widthLSB cget -text] \
				   -height [$new_heightLSB cget -text] \
				   -hascmri [$new_hascmriLCB cget -text] \
				   -cmriport [$new_cmriportLCB cget -text] \
				   -cmrispeed [$new_cmrispeedLCB cget -text] \
				   -cmriretries [$new_cmriretriesLSB cget -text]
      
      return [$newDialog enddialog Create]
    }
    typemethod _NewCancel {} {
      $newDialog withdraw
      return [$newDialog enddialog Cancel]
    }

    typemethod createselectPanelDialog {} {
      if {![string equal "$selectPanelDialog" {}] && 
	  [winfo exists $selectPanelDialog]} {return}
      set selectPanelDialog [Dialog::create .selectPanelDialog \
				-bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-parent . -side bottom -title {Select Panel}]
      $selectPanelDialog add -name create -text Select \
					  -command [mytypemethod _SelectPanel]
      $selectPanelDialog add -name cancel -text Cancel \
					  -command [mytypemethod _SelectCancel]
      wm protocol [winfo toplevel $selectPanelDialog] WM_DELETE_WINDOW \
				[mytypemethod _SelectCancel]
      $selectPanelDialog add -name help -text Help \
			     -command {HTMLHelp::HTMLHelp help {Select Panel Dialog}}
      set frame [Dialog::getframe $selectPanelDialog]
      set selectPanel_nameLCB [LabelComboBox $frame.nameLCB \
					-label "Name:" \
					-labelwidth 10\
					-editable no\
					-values {}]
      pack $selectPanel_nameLCB -fill x
    }
    typemethod selectpanel {args} {
      $type createselectPanelDialog
      set parent [from args -parent .]
      $selectPanelDialog configure -parent $parent
      wm transient [winfo toplevel $selectPanelDialog] $parent
      $selectPanel_nameLCB configure -values [$type allopenwindownames]
      $selectPanel_nameLCB setvalue first
      return [$selectPanelDialog draw]
    }
    typemethod _SelectPanel {} {
      $selectPanelDialog withdraw
      return [$selectPanelDialog enddialog "[$selectPanel_nameLCB cget -text]"]
    }
    typemethod _SelectCancel {} {
      $selectPanelDialog withdraw
      return [$selectPanelDialog enddialog {}]
    }
    typemethod addtrackworknodetopanel {node args} {
#      puts stderr "*** $type addtrackworknodetopanel $node"
      set nparent [from args -parent .]
      switch [llength [array names OpenWindows]] {
	0 {
	  tk_messageBox -type ok -icon warning \
			-message {Please create a panel first}
	  return
	}
	1 {
	  set panelName [lindex [array names OpenWindows] 0]
	}
	default {
	  set panelName [$type selectpanel -parent $nparent]
	}
      }
      if {[string equal "$panelName" {}]} {return}
      set panel [$type selectwindowbyname "$panelName"]
      $panel showme
      set blocks [from args -blocks]
      set switches [from args -switchmotors]
#      puts stderr "*** $type addtrackworknodetopanel: [$node NumEdges] edges"
      switch [$node NumEdges] {
	0 {
#	  puts stderr "*** $type addtrackworknodetopanel: [$node TypeOfNode]"
	  switch [$node TypeOfNode] {
	    TrackGraph::Block {
	     eval [list $panel addblocktopanel $node \
					-name [$node NameOfNode] \
					-occupiedcommand [$node SenseScript]] \
		  $args
	    }
	    TrackGraph::SwitchMotor {
	      set tn [RawNodeGraph::RawNode RawNodeObject [$node TurnoutNumber]]
	      if {[$tn NumEdges] == 3} {
		eval [list $panel addsimpleturnouttopanel $node \
				-name [$node NameOfNode] \
				-statecommand [$node SenseScript] \
				-normalcommand [$node NormalActionScript] \
				-reversecommand [$node ReverseActionScript]] \
		     $args
	      } else {
		eval [list $panel addcomplextrackworktopanel $node] $args
	      }
	    }
	  }
	}
	2 {
	  if {[llength $blocks] > 0} {
	    foreach b $blocks {
	      eval [list $panel addblocktopanel $b \
					-name [$b NameOfNode] \
					-occupiedcommand [$b SenseScript]] \
		  $args
	    }
	  } else {
	    eval [list $panel addblocktopanel $node] $args
	  }
	}
	3 {
	  if {[llength $blocks] > 0} {
	    lappend args -occupiedcommand [[lindex $blocks] SenseScript]
	    if {[llength $switches] == 0} {
	      lappend args -name [[lindex $blocks] NameOfNode]
	    }
	  }
	  if {[llength $switches] > 0} {
	    lappend args -name [[lindex $switches] NameOfNode]
	    lappend args -statecommand [[lindex $switches] SenseScript]
	    lappend args -normalcommand [[lindex $switches] NormalActionScript]
	    lappend args -reversecommand [[lindex $switches] ReverseActionScript]
	  }
	  eval [list $panel addsimpleturnouttopanel $node] $args
	  if {[llength $switches] > 0} {
	    set name [from args -name]
	    lappend args -name "${name}_Plate"
	    eval [list $panel addswitchplatetopanel] $args
	  }
	}
	default {
	  if {[llength $blocks] > 0} {
	    lappend args -occupiedcommand [[lindex $blocks] SenseScript]
	    if {[llength $switches] == 0} {
	      lappend args -name [[lindex $blocks] NameOfNode]
	    }
	  }
	  if {[llength $switches] > 0} {
	    lappend args -name [[lindex $switches] NameOfNode]
	    lappend args -statecommand [[lindex $switches] SenseScript]
	    lappend args -normalcommand [[lindex $switches] NormalActionScript]
	    lappend args -reversecommand [[lindex $switches] ReverseActionScript]
	  }
	  eval [list $panel addcomplextrackworktopanel $node] $args
	  if {[llength $switches] > 0} {
	    set name [from args -name]
	    lappend args -name "${name}_Plate"
	    eval [list $panel addswitchplatetopanel] $args
	  }
	}
      }
    }

    component addPanelObjectDialog
    component selectPanelObjectDialog
    component configurePanelDialog
    component addCMRINodeDialog
    component selectCMRINodeDialog
    component editUserCodeDialog

    method buildDialogs {} {

      install addPanelObjectDialog using CTCPanelWindow::AddPanelObjectDialog $win.addPanelObjectDialog -parent $win -ctcpanel $ctcpanel
      install selectPanelObjectDialog using CTCPanelWindow::SelectPanelObjectDialog $win.selectPanelObjectDialog -parent $win -ctcpanel $ctcpanel
      install configurePanelDialog using CTCPanelWindow::ConfigurePanelDialog $win.configurePanelDialog -parent $win
      install addCMRINodeDialog using CTCPanelWindow::AddCMRINodeDialog $win.addCMRINodeDialog -parent $win
      install selectCMRINodeDialog using CTCPanelWindow::SelectCMRINodeDialog $win.selectCMRINodeDialog -parent $win
      install editUserCodeDialog  using CTCPanelWindow::EditUserCodeDialog $win.editUserCodeDialog -parent $win
    }

    method addblocktopanel {node args} {
#      puts stderr "*** $self addblocktopanel $node $args"
      set result [eval [list $addPanelObjectDialog draw -mode add -setoftypes {StraightBlock CurvedBlock HiddenBlock StubYard ThroughYard}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addsimpleturnouttopanel {node args} {
      set result [eval [list $addPanelObjectDialog draw -mode add -setoftypes {Switch}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addcomplextrackworktopanel {node args} {
      set result [eval [list $addPanelObjectDialog draw -mode add -setoftypes {ScissorCrossover Crossing SingleSlip DoubleSlip ThreeWaySW}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addswitchplatetopanel {args} {
      set result [eval [list $addPanelObjectDialog draw -mode add -setoftypes {SWPlate}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addpanelobject {args} {
      set result [eval [list $addPanelObjectDialog draw -mode add -setoftypes {}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method editpanelobject {args} {
      set objectToEdit [eval [list $selectPanelObjectDialog draw] $args]
      if {[string equal "$objectToEdit" {}]} {return}
      set result [eval [list $addPanelObjectDialog draw -mode edit -object $objectToEdit] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      $ctcpanel delete $objectToEdit
      eval [list $ctcpanel create] $result
    }
    method deletepanelobject {args} {
      set objectToDelete [eval [list $selectPanelObjectDialog draw] $args]
      if {[string equal "$objectToDelete" {}]} {return}
      if {[tk_messageBox -type yesno -icon question \
			 -message "Really delete $objectToDelete?" \
			 -parent $win]} {
	$ctcpanel delete $objectToDelete
	$self setdirty
      }
    }
    method configurepanel {args} {
      set result [eval [list $configurePanelDialog draw] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      $self configurelist $result
    }
    method addcmrinode {args} {
      set result [eval [list $addCMRINodeDialog draw -mode add] $args]
      if {[string equal "$result" {}]} {return}
      set board [lindex $result 0]
      set opts  "[lrange $result 1 end]"
      set cmrinodes($board) "$opts"
      $self setdirty
    }
    method editcmrinode {args} {
      set nodeToEdit [eval [list $selectCMRINodeDialog draw] $args]
      if {[string equal "$nodeToEdit" {}]} {return}
      set result [eval [list $addCMRINodeDialog draw -mode edit -node $nodeToEdit] $args]
      if {[string equal "$result" {}]} {return}
      set board [lindex $result 0]
      set opts  "[lrange $result 1 end]"
      set cmrinodes($board) "$opts"
      $self setdirty
    }
    method deletecmrinode {args} {
      set nodeToDelete [eval [list $selectCMRINodeDialog draw] $args]
      if {[string equal "$nodeToDelete" {}]} {return}
      if {[tk_messageBox -type yesno -icon question \
			-message "Really delete $nodeToDelete?" \
			-parent $win]} {
	unset cmrinodes($nodeToDelete)
	$self setdirty
      }
    }
    method AddModule {modname} {
#      puts stderr "$self AddModule $modname"
      set startPattern "^#\\* ${modname}:START \\*\$"
      set endPattern "^#\\* ${modname}:END \\*\$"
#      puts stderr "$self AddModule: startPattern = '$startPattern', endPattern = '$endPattern'"
      set userCodeModulesFp [open [file join "$CodeLibraryDir" \
					     userCodeModules.tcl] r]
      while {[gets $userCodeModulesFp line] >= 0} {
	if {[regexp "$startPattern" "$line"] > 0} {break}
      }
      set moduleBuffer {}
      if {![eof $userCodeModulesFp]} {
	while {[gets $userCodeModulesFp line] >= 0} {
	  if {[regexp "$endPattern" "$line"] > 0} {break}
	  append moduleBuffer "${line}\n"
	}
      }
      close $userCodeModulesFp
#      puts stderr "$self AddModule: moduleBuffer = '$moduleBuffer'"
      if {[string length "$moduleBuffer"] > 0} {
	set userCode "${moduleBuffer}\n${userCode}"
	$self setdirty
      }
    }
    method GenerateMainLoop {} {
      set loop "\n# Main Loop Start\nwhile {true} \{\n"
      if {$options(-hascmri)} {
	append loop "  # Read all ports\n"
	foreach node [array names cmrinodes] {
	  append loop "  set ${node}_inbits \[$node inputs\]\n"
	}
      }
      append loop "  # Invoke all trackwork and get occupicency\n"
      foreach obj [$ctcpanel objectlist] {
#	puts stderr "*** $self GenerateMainLoop: \[$ctcpanel itemconfigure $obj\] = [$ctcpanel itemconfigure $obj]"
	if {![catch {$ctcpanel itemcget $obj -occupiedcommand}]} {
	  append loop "  MainWindow ctcpanel invoke $obj\n"
	}
      }
      if {$options(-hascmri)} {
	append loop "  # Write all output ports\n"
	foreach node [array names cmrinodes] {
	  append loop "  eval \[list $node outputs\] \$${node}_outbits\n"
	}
      }
      append loop "  update;# Update display\n\}\n# Main Loop End\n"
      if {[regexp -line -indices {(^# Main Loop Start$)} "$userCode" -> start] > 0 &&
	  [regexp -line -indices {(^# Main Loop End$)} "$userCode" -> end] > 0} {
#	puts stderr "*** $self GenerateMainLoop: start = $start, end = $end"
	set userCode [string replace "$userCode" [lindex $start 0] [lindex $end 1] "$loop"]
      } else {
	append userCode "$loop"
      }
      $self setdirty
    }
    method EditUserCode {args} {
      if {[::Dispatcher::Configuration getoption useExternalEditor]} {
	global tcl_platform
	global env
	switch $tcl_platform(platform) {
	  unix {
		set tmpdir /tmp
		catch {set tmpdir $::env(TMPDIR)}
	  } macintosh {
		set tmpdir /tmp
		catch {set tmpdir $::env(TMPDIR)}
		set tmpdir $::env(TRASH_FOLDER)  ;# a better place?
	  } default {
	        set tmpdir [pwd]
		catch {set tmpdir $::env(TMP)}
		catch {set tmpdir $::env(TEMP)}
	  }
	}
	set tempName [file join $tmpdir Code[pid].tcl]
	if {[catch {open "$tempName" w} fp]} {
	  tk_messageBox -type ok -icon error "Could not create tempfile: $fp"
	  return
	} else {
	  puts -nonewline $fp "$userCode"
	  close $fp
	}
	set edit [CTCPanelWindow::WaitExternalProgramASync editor%AUTO% \
			-commandline [list "[::Dispatcher::Configuration getoption externalEditor]" "$tempName"]]
	$edit wait
	$edit destroy
	if {![catch {open "$tempName" r} fp]} {
	  set userCode "[read $fp]"
	  close $fp
	  $self setdirty
	}
      } else {
        set result [eval [list $editUserCodeDialog draw "$userCode"] $args]
        switch -- $result {
	  cancel {}
	  update {
	    set userCode "[$editUserCodeDialog getcode]"
	    $self setdirty
	  }
 	}
      }
    }
  }
  snit::widgetadaptor AddPanelObjectDialog {
    delegate option -parent to hull
    option -ctcpanel -default {}
    option -setoftypes -default {}
    option -mode -default add
    option -object -default {}
    option -name -default {}
    option -occupiedcommand -default {}
    option -statecommand    -default {}
    option -normalcommand   -default {}
    option -reversecommand  -default {}


    component nameLE;#			Name of object
    component objectTypeTF;#		Object Type Frame
    variable objectType SWPlate;#	Current Object Type
    # Controls:
    component   sWPlateRB;#		Switch Plate
    component   sIGPlateRB;#		Signal Plate
    component   codeButtonRB;#		Code Button
    component   toggleRB;#		Toggle switch
    component   pushButtonRB;#		PushButton
    component   lampRB;#		Lamp
    component   cTCLabelRB;#		Label on controls
    # Trackwork:
    component   straightBlockRB;#	Straight track segment
    component   curvedBlockRB;#		Curved track segment
    component   hiddenBlockRB;#		Hidden track segment (bridge, tunnel)
    component   stubYardRB;#		Stub yard
    component   throughYardRB;#		Through yard
    component   crossingRB;#		Crossing
    component   switchRB;#		Simple switch (turnout)
    component   scissorCrossoverRB;#	Scissor Crossover
    component   singleSlipRB;#		Single slip switch
    component   doubleSlipRB;#		Double slip switch
    component   threeWaySWRB;#		Three way switch
    component   signalRB;#		Signal
    component   schLabelRB;#		Label on schematic
    # Graphic:
    component graphicSW;#		ScrolledWindow
    component   graphicCanvas;#		Canvas 
    # Standard options:
    component controlPointLCB;#		-controlpoint
    # Other options:
    component optionsFrame;#		Frame for other options
    component xyframe1;#		XY 1 options:
    component   x1LSB;#			-x1 or -x
    component   y1LSB;#			-y1 or -y
    variable    x1
    variable    y1
    component   b1
    component xyframe2;#		XY 2 options:
    component   x2LSB;#			-x2
    component   y2LSB;#			-y2
    variable    x2
    variable    y2
    component   b2
    component radiusLSB;#		-radius
    component labelLE;#			-label
    component positionLCB;#		-position
    component orientationLCB;#		-orientation (8-way)
    component hvorientationLCB;#	-orientation (horizontal / vertical)
    component flippedLCB;#		-flipped
    component headsLCB;#		-heads (1, 2, 3)
    component typeLCB;#			-type
    component leftlabelLE;#		-leftlabel
    component centerlabelLE;#		-centerlabel
    component rightlabelLE;#		-rightlabel
    component hascenterLCB;#		-hascenter
    component colorLSC;#		-color
    component occupiedcommandLF
    component   occupiedcommandSW
    component     occupiedcommandText;#	-occupiedcommand
    component statecommandLF
    component   statecommandSW
    component     statecommandText;#	-statecommand
    component normalcommandLF
    component   normalcommandSW
    component     normalcommandText;#	-normalcommand
    component reversecommandLF
    component   reversecommandSW
    component     reversecommandText;#	-reversecommand
    component leftcommandLF
    component   leftcommandSW
    component     leftcommandText;#	-leftcommand
    component centercommandLF
    component   centercommandSW
    component     centercommandText;#	-centercommand
    component rightcommandLF
    component   rightcommandSW
    component     rightcommandText;#	-rightcommand
    component commandLF
    component   commandSW
    component     commandText;#		-command

    typevariable objectTypeOptions -array {
	SWPlate {xyctl label normalcommand reversecommand}
	SIGPlate {xyctl label leftcommand centercommand rightcommand}
	CodeButton {xyctl command}
	Toggle {xyctl hvorientation leftlabel centerlabel rightlabel 
		hascenter leftcommand rightcommand centercommand}
	PushButton {xyctl label color command}
	Lamp {xyctl label color}
	CTCLabel {xyctl label color}
	SchLabel {xysch label color}
	Switch {xysch label orientation flipped statecommand
		occupiedcommand}
	StraightBlock {xy1sch xy2sch label position occupiedcommand}
	CurvedBlock {xy1sch xy2sch radius label position occupiedcommand}
	ScissorCrossover {xysch label orientation flipped statecommand 
			  occupiedcommand}
	Crossing {xysch label orientation flipped type occupiedcommand}
	SingleSlip {xysch label orientation flipped statecommand
		    occupiedcommand}
	DoubleSlip {xysch label orientation flipped statecommand
		    occupiedcommand}
	ThreeWaySW {xysch label orientation flipped statecommand
		    occupiedcommand}
	HiddenBlock {xy1sch xy2sch label orientation flipped occupiedcommand}
	StubYard {xysch label orientation flipped occupiedcommand}
	ThroughYard {xysch label orientation flipped occupiedcommand}
	Signal {xysch label orientation heads}
    }

    constructor {args} {
#      puts stderr "*** $type create $self $args"
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title {Add Panel Object to panel} \
				-parent [from args -parent]
      $hull add -name add    -text Add    -command [mymethod _Add]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name redraw -text Redraw -command [mymethod redrawgraphic]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Add Panel Object Dialog}}
      set frame [$hull getframe]
      install nameLE using LabelEntry $frame.nameLE -label "Name:" \
						    -labelwidth 15 \
						    -text {}
      pack $nameLE -fill x
      install objectTypeTF using TitleFrame $frame.objectTypeTF -side left \
				-text {Object Type}
      pack $objectTypeTF -fill both
      set otframe [$objectTypeTF getframe]
      set row 0
      foreach {rb0 rb1 rb2 rb3 rb4} {sWPlateRB sIGPlateRB codeButtonRB toggleRB pushButtonRB lampRB cTCLabelRB straightBlockRB curvedBlockRB hiddenBlockRB stubYardRB throughYardRB crossingRB switchRB scissorCrossoverRB singleSlipRB doubleSlipRB threeWaySWRB signalRB schLabelRB} {
	foreach rb [list $rb0 $rb1 $rb2 $rb3 $rb4] col {0 1 2 3 4} {
	  if {[string length "$rb"] == 0} {continue}
#	  puts stderr "*** $type create: rb = '$rb', col = $col"
	  regsub {RB$} "$rb" {} name
	  regexp {^([[:alpha:]])} "$name" -> char
	  regsub {^[[:alpha:]]} "$name" [string toupper $char] name
	  install $rb using radiobutton $otframe.$rb \
				-text "$name" \
				-command [mymethod packOptionsAndRedrawGr "$name"] \
				-value  "$name" \
				-variable [myvar objectType] \
				-anchor w
	  grid $otframe.$rb -column $col -row $row -sticky news
	}
	incr row
      }
      install graphicSW using ScrolledWindow $frame.graphicSW \
				-scrollbar both -auto both
      pack $graphicSW -expand yes -fill both
      install graphicCanvas using canvas \
				[$graphicSW getframe].graphicCanvas \
				-scrollregion {0 0 0 0} \
				-height 100 -width 100
      pack $graphicCanvas -expand yes -fill both
      $graphicSW setwidget $graphicCanvas
      bind $graphicCanvas <Configure> [mymethod updateSR %W %h %w]
      install controlPointLCB using LabelComboBox $frame.controlPointLCB \
						-label {Control Point:} \
						-labelwidth 15
      pack $controlPointLCB -fill x
      install optionsFrame using frame $frame.optionsFrame -borderwidth 0 \
							   -relief flat
      pack $optionsFrame -expand yes -fill both
      install xyframe1 using TitleFrame $optionsFrame.xyframe1 -side left \
						    -text {First Coord}
      install x1LSB using LabelSpinBox [$xyframe1 getframe].x1LSB \
						-label X: \
						-textvariable [myvar x1] \
						-range {0 1000 1}
      pack $x1LSB -side left -fill x -expand yes
      install y1LSB using LabelSpinBox [$xyframe1 getframe].y1LSB \
						-label Y: \
						-textvariable [myvar y1] \
						-range {0 1000 1}
      pack $y1LSB -side left -fill x -expand yes
      install b1 using Button [$xyframe1 getframe].b1 \
						-text "Use Crosshairs"
      pack $b1 -side right
      install xyframe2 using TitleFrame $optionsFrame.xyframe2 -side left \
						    -text {Second Coord}
      install x2LSB using LabelSpinBox [$xyframe2 getframe].x2LSB \
						-label X: \
						-textvariable [myvar x2] \
						-range {0 1000 1}
      pack $x2LSB -side left -fill x -expand yes
      install y2LSB using LabelSpinBox [$xyframe2 getframe].y2LSB \
						-label Y: \
						-textvariable [myvar y2] \
						-range {0 1000 1}
      pack $y2LSB -side left -fill x -expand yes
      install b2 using Button [$xyframe2 getframe].b2 \
						-text "Use Crosshairs"
      pack $b2 -side right
      install radiusLSB using LabelSpinBox $optionsFrame.radiusLSB \
						-label {Radius:} \
						-labelwidth 15 \
						-range {1 50 1}
      install labelLE using LabelEntry $optionsFrame.labelLE -label {Label:} \
						      -labelwidth 15
      install positionLCB using LabelComboBox $optionsFrame.positionLCB \
						-label {Position:} \
						-labelwidth 15 \
						-editable no \
						-values {below above right left} \
						-modifycmd [mymethod redrawgraphic]
      $positionLCB setvalue first
      install orientationLCB using LabelComboBox $optionsFrame.orientationLCB \
						-label {Orientation:} \
						-labelwidth 15 \
						-values {0 1 2 3 4 5 6 7} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $orientationLCB setvalue first
      install hvorientationLCB using LabelComboBox $optionsFrame.hvorientationLCB \
						-label {Orientation:} \
						-labelwidth 15 \
						-values {horizontal vertical} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $hvorientationLCB setvalue first
      install flippedLCB using LabelComboBox $optionsFrame.flippedLCB \
						-label {Flipped?} \
						-labelwidth 15 \
						-values {no yes} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $flippedLCB setvalue first
      install headsLCB using LabelComboBox $optionsFrame.headsLCB \
						-label {Heads:} \
						-labelwidth 15 \
						-values {1 2 3} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $headsLCB setvalue first
      install typeLCB using LabelComboBox $optionsFrame.typeLCB \
						-label {Crossing Type:} \
						-labelwidth 15 \
						-values {x90 x45} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $typeLCB setvalue first
      install leftlabelLE using LabelEntry $optionsFrame.leftlabelLE -label {Left Label:} \
						      -labelwidth 15
      install centerlabelLE using LabelEntry $optionsFrame.centerlabelLE -label {Center Label:} \
						      -labelwidth 15
      install rightlabelLE using LabelEntry $optionsFrame.rightlabelLE -label {Right Label:} \
						      -labelwidth 15
      install hascenterLCB using LabelComboBox $optionsFrame.hascenterLCB \
						      -label {Has Center Position?} \
						      -labelwidth 15 \
						      -values {no yes} \
						      -editable no \
						-modifycmd [mymethod redrawgraphic]
      $hascenterLCB setvalue first
      install colorLSC using LabelSelectColor $optionsFrame.colorLSC \
						      -label {Color:} \
						      -labelwidth 15 \
						      -text white
      install occupiedcommandLF using LabelFrame $optionsFrame.occupiedcommandLF \
						-text {Occupied Script:} \
						-width 15
      install occupiedcommandSW using ScrolledWindow \
			[$occupiedcommandLF getframe].occupiedcommandSW \
			-scrollbar both -auto both
      pack $occupiedcommandSW -expand yes -fill both
      install occupiedcommandText using text \
			[$occupiedcommandSW getframe].occupiedcommandText \
			-wrap none -width 40 -height 5
      bindtags $occupiedcommandText [list $occupiedcommandText Text]
      pack $occupiedcommandText -expand yes -fill both
      $occupiedcommandSW setwidget $occupiedcommandText
      install statecommandLF using LabelFrame $optionsFrame.statecommandLF \
						-text {State Script:} \
						-width 15
      install statecommandSW using ScrolledWindow \
			[$statecommandLF getframe].statecommandSW \
			-scrollbar both -auto both
      pack $statecommandSW -expand yes -fill both
      install statecommandText using text \
			[$statecommandSW getframe].statecommandText \
			-wrap none -width 40 -height 5
      bindtags $statecommandText [list $statecommandText Text]
      pack $statecommandText -expand yes -fill both
      $statecommandSW setwidget $statecommandText
      install normalcommandLF using LabelFrame $optionsFrame.normalcommandLF \
						-text {Normal Script:} \
						-width 15
      install normalcommandSW using ScrolledWindow \
			[$normalcommandLF getframe].normalcommandSW \
			-scrollbar both -auto both
      pack $normalcommandSW -expand yes -fill both
      install normalcommandText using text \
			[$normalcommandSW getframe].normalcommandText \
			-wrap none -width 40 -height 5
      bindtags $normalcommandText [list $normalcommandText Text]
      pack $normalcommandText -expand yes -fill both
      $normalcommandSW setwidget $normalcommandText
      install reversecommandLF using LabelFrame $optionsFrame.reversecommandLF \
						-text {Reverse Script:} \
						-width 15
      install reversecommandSW using ScrolledWindow \
			[$reversecommandLF getframe].reversecommandSW \
			-scrollbar both -auto both
      pack $reversecommandSW -expand yes -fill both
      install reversecommandText using text \
			[$reversecommandSW getframe].reversecommandText \
			-wrap none -width 40 -height 5
      bindtags $reversecommandText [list $reversecommandText Text]
      pack $reversecommandText -expand yes -fill both
      $reversecommandSW setwidget $reversecommandText
      install leftcommandLF using LabelFrame $optionsFrame.leftcommandLF \
						-text {Left Script:} \
						-width 15
      install leftcommandSW using ScrolledWindow \
			[$leftcommandLF getframe].leftcommandSW \
			-scrollbar both -auto both
      pack $leftcommandSW -expand yes -fill both
      install leftcommandText using text \
			[$leftcommandSW getframe].leftcommandText \
			-wrap none -width 40 -height 5
      bindtags $leftcommandText [list $leftcommandText Text]
      pack $leftcommandText -expand yes -fill both
      $leftcommandSW setwidget $leftcommandText
      install centercommandLF using LabelFrame $optionsFrame.centercommandLF \
						-text {Center Script:} \
						-width 15
      install centercommandSW using ScrolledWindow \
			[$centercommandLF getframe].centercommandSW \
			-scrollbar both -auto both
      pack $centercommandSW -expand yes -fill both
      install centercommandText using text \
			[$centercommandSW getframe].centercommandText \
			-wrap none -width 40 -height 5
      bindtags $centercommandText [list $centercommandText Text]
      pack $centercommandText -expand yes -fill both
      $centercommandSW setwidget $centercommandText
      install rightcommandLF using LabelFrame $optionsFrame.rightcommandLF \
						-text {Right Script:} \
						-width 15
      install rightcommandSW using ScrolledWindow \
			[$rightcommandLF getframe].rightcommandSW \
			-scrollbar both -auto both
      pack $rightcommandSW -expand yes -fill both
      install rightcommandText using text \
			[$rightcommandSW getframe].rightcommandText \
			-wrap none -width 40 -height 5
      bindtags $rightcommandText [list $rightcommandText Text]
      pack $rightcommandText -expand yes -fill both
      $rightcommandSW setwidget $rightcommandText
      install commandLF using LabelFrame $optionsFrame.commandLF \
						-text {Action Script:} \
						-width 15
      install commandSW using ScrolledWindow \
			[$commandLF getframe].commandSW \
 			-scrollbar both -auto both
      pack $commandSW -expand yes -fill both
      install commandText using text \
			[$commandSW getframe].commandText \
			-wrap none -width 40 -height 5
      bindtags $commandText [list $commandText Text]
      pack $commandText -expand yes -fill both
      $commandSW setwidget $commandText
      $self configurelist $args
      
    }
    method updateSR {canvas newheight newwidth} {
      set newSR 0
      set curSR [$canvas cget -scrollregion]
      set bbox  [$canvas bbox all]
      if {[llength $bbox] == 0} {set bbox $curSR}
      if {[lindex $bbox 2] != [lindex $curSR 2]} {
	set curSR [lreplace $curSR 2 2 [lindex $bbox 2]]
	set newSR 1
      }
      if {[lindex $curSR 2] < $newwidth} {
	set curSR [lreplace $curSR 2 2 $newwidth]
	set newSR 1
      }
      if {[lindex $bbox 3] != [lindex $curSR 3]} {
      set curSR [lreplace $curSR 3 3 [lindex $bbox 3]]
      set newSR 1
      }
      if {[lindex $curSR 3] < $newheight} {
	set curSR [lreplace $curSR 3 3 $newheight]
	set newSR 1
      }
      if {$newSR} {
	$canvas configure -scrollregion $curSR
      }
    }
    method draw {args} {
#      puts stderr "*** $self draw $args"
      $self configurelist $args
      if {"$options(-name)" ne ""} {
	$labelLE configure -text "$options(-name)"
	$nameLE configure -text "$options(-name)"
      }
      if {"$options(-occupiedcommand)" ne ""} {
	$occupiedcommandText delete 1.0 end
	$occupiedcommandText insert end "$options(-occupiedcommand)"
      }
      if {"$options(-statecommand)" ne ""} {
	$statecommandText delete 1.0 end
	$statecommandText insert end "$options(-statecommand)"
      }
      if {"$options(-normalcommand)" ne ""} {
	$normalcommandText delete 1.0 end
	$normalcommandText insert end "$options(-normalcommand)"
      }
      if {"$options(-reversecommand)" ne ""} {
	$reversecommandText delete 1.0 end
	$reversecommandText insert end "$options(-reversecommand)"
      }
      switch $options(-mode) {
        edit {
	  if {[string equal "$options(-object)" {}]} {
	    error "Internal Error - no object selected!"
	  }
	  if {![$options(-ctcpanel) exists "$options(-object)"]} {
	    error "Internal Error - no object selected!"
	  }
	  $nameLE configure -text "$options(-object)" -editable no
	  $controlPointLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -controlpoint]
	  set objectType [$options(-ctcpanel) class "$options(-object)"]
          set options(-setoftypes) [list $objectType]
#	  puts stderr "*** $self draw: objectType = $objectType"
#	  puts stderr "*** $self draw: options(-object) = '$options(-object)'"
	  $self packAndConfigureOptions $objectType
	  $hull itemconfigure add -text "Update"
	  $hull configure -title "Edit Panel Object"
        }
        add -
        default {
	  if {[llength "$options(-setoftypes)"] == 0} {set options(-setoftypes) [array names objectTypeOptions]}
	  $nameLE configure -editable yes
	  if {[lsearch "$options(-setoftypes)" $objectType] < 0} {
	    set objectType [lindex $options(-setoftypes) 0]
 	  }
	  $self packOptions $objectType
	  $hull itemconfigure add -text "Add"
	  $hull configure -title {Add Panel Object to panel}
        }
      }
      foreach objtype [array names objectTypeOptions] {
	regexp {^([[:alpha:]])} $objtype -> first
	regsub {^[[:alpha:]]} $objtype [string tolower $first] rb
	append rb RB
	if {[lsearch -exact $options(-setoftypes) $objtype] < 0} {
	  [set $rb] configure -state disabled
	} else {
	  [set $rb] configure -state normal
	}
      }
      wm transient [winfo toplevel $win] [$hull cget -parent]
      $controlPointLCB configure -values [$options(-ctcpanel) cplist]
      $self redrawgraphic
      return [$hull draw]
    }
    method checkInitCP {args} {}
    method updateAndSyncCP {args} {}
    method lappendCP {args} {}
    method getZoom {} {return 1.0}
    method redrawgraphic {} {
      $graphicCanvas delete all
      set opts {}
      $self getOptions opts
      if {[catch {eval [list ::CTCPanel::$objectType create %AUTO% $self $graphicCanvas -controlpoint nil] $opts} error]} {
	if {[string first {Range error: } "$error"] >= 0} {
	  from opts -x1
	  from opts -x2
	  from opts -y1
	  from opts -y2
	  from opts -radius
	  tk_messageBox -type ok -icon warning -parent $win \
			-message "Range error: radius too small for points.\n\
Adjust x, y, and radius values and click Redraw"
	  eval [list ::CTCPanel::$objectType create %AUTO% $self $graphicCanvas -controlpoint nil -x1 1 -y1 1 -x2 10 -y2 10 -radius 10] $opts
	} else {
	  error "$error" $::errorInfo $::errorCode
	}
      }          
      if {[lsearch -exact {SWPlate SIGPlate CodeButton Toggle Lamp CTCLabel PushButton} $objectType] < 0} {
	set background black
      } else {
	set background darkgreen
      }
      $graphicCanvas configure -scrollregion [$graphicCanvas bbox all] \
      				-background "$background"
      
    }      
    method packOptionsAndRedrawGr {objtype} {
      $self packOptions $objtype
      $self redrawgraphic
    }
    method packOptions {objtype} {
      foreach slave [pack slaves $optionsFrame] {pack forget $slave}
      foreach opt $objectTypeOptions($objtype) {
	switch -exact $opt {
	  xyctl {
		pack $xyframe1 -fill x
		$xyframe1 configure -text {}
		$b1 configure -command [mymethod _chctlXY1]
	  }
	  xysch {
		pack $xyframe1 -fill x
		$xyframe1 configure -text {}
		$b1 configure -command [mymethod _chschXY1]
	  }
	  xy1sch {
		pack $xyframe1 -fill x
		$xyframe1 configure -text {First Coord}
		$b1 configure -command [mymethod _chschXY1]
	  }
	  xy2sch {
		pack $xyframe2 -fill x
		$xyframe2 configure -text {Second Coord}
		$b2 configure -command [mymethod _chschXY2]
	  }
	  label {
		pack $labelLE -fill x
	  }
	  normalcommand {
		pack $normalcommandLF -fill x
	  }
	  reversecommand {
		pack $reversecommandLF -fill x
	  }
	  leftcommand {
		pack $leftcommandLF -fill x
	  }
	  centercommand {
		pack $centercommandLF -fill x
	  }
	  rightcommand {
		pack $rightcommandLF -fill x
	  }
	  command {
		pack $commandLF -fill x
	  }
	  hvorientation {
		pack $hvorientationLCB -fill x
	  }
	  leftlabel {
		pack $leftlabelLE -fill x
	  }
	  centerlabel {
		pack $centerlabelLE -fill x
	  }
	  rightlabel {
		pack $rightlabelLE -fill x
	  }
	  hascenter {
		pack $hascenterLCB -fill x
	  }
	  color {
		pack $colorLSC -fill x
	  }
	  orientation {
		pack $orientationLCB -fill x
	  }
	  flipped {
		pack $flippedLCB -fill x
	  }
	  heads {
		pack $headsLCB -fill x
	  }
	  statecommand {
		pack $statecommandLF -fill x
	  }
	  occupiedcommand {
		pack $occupiedcommandLF -fill x
	  }
	  position {
		pack $positionLCB -fill x
	  }
	  radius {
		pack $radiusLSB -fill x
	  }
	  type {
		pack $typeLCB -fill x
	  }
	}
      }
    }
    method packAndConfigureOptions {objtype} {
      foreach slave [pack slaves $optionsFrame] {pack forget $slave}
#      puts stderr "*** $self packAndConfigureOptions: objtype = $objtype, options(-object) = $options(-object), opts are [$options(-ctcpanel) itemconfigure $options(-object)]"
      foreach opt $objectTypeOptions($objtype) {
	switch -exact $opt {
	  xyctl {
		pack $xyframe1 -fill x
		$xyframe1 configure -text {}
		$b1 configure -command [mymethod _chctlXY1]
		set x1 [$options(-ctcpanel) itemcget $options(-object) -x]
		set y1 [$options(-ctcpanel) itemcget $options(-object) -y]
	  }
	  xysch {
		pack $xyframe1 -fill x
		$xyframe1 configure -text {}
		$b1 configure -command [mymethod _chschXY1]
		set x1 [$options(-ctcpanel) itemcget $options(-object) -x]
		set y1 [$options(-ctcpanel) itemcget $options(-object) -y]
	  }
	  xy1sch {
		pack $xyframe1 -fill x
		$xyframe1 configure -text {First Coord}
		$b1 configure -command [mymethod _chschXY1]
		set x1 [$options(-ctcpanel) itemcget $options(-object) -x1]
		set y1 [$options(-ctcpanel) itemcget $options(-object) -y1]
	  }
	  xy2sch {
		pack $xyframe2 -fill x
		$xyframe2 configure -text {Second Coord}
		$b2 configure -command [mymethod _chschXY2]
		set x2 [$options(-ctcpanel) itemcget $options(-object) -x2]
		set y2 [$options(-ctcpanel) itemcget $options(-object) -y2]
	  }
	  label {
		pack $labelLE -fill x
		$labelLE configure -text "[$options(-ctcpanel) itemcget $options(-object) -label]"
	  }
	  leftlabel {
		pack $leftlabelLE -fill x
		$leftlabelLE configure -text "[$options(-ctcpanel) itemcget $options(-object) -leftlabel]"
	  }
	  centerlabel {
		pack $centerlabelLE -fill x
		$centerlabelLE configure -text "[$options(-ctcpanel) itemcget $options(-object) -centerlabel]"
	  }
	  rightlabel {
		pack $rightlabelLE -fill x
		$rightlabelLE configure -text "[$options(-ctcpanel) itemcget $options(-object) -rightlabel]"
	  }
	  hvorientation {
		pack $hvorientationLCB -fill x
		$hvorientationLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -orientation]
	  }
	  hascenter {
		pack $hascenterLCB -fill x
		$hascenterLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -hascenter]
	  }
	  color {
		pack $colorLSC -fill x
		$colorLSC configure -text "[$options(-ctcpanel) itemcget $options(-object) -color]"
	  }
	  orientation {
		pack $orientationLCB -fill x
		$orientationLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -orientation]
	  }
	  flipped {
		pack $flippedLCB -fill x
		$flippedLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -flipped]
	  }
	  heads {
		pack $headsLCB -fill x
		$headsLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -heads]
	  }
	  position {
		pack $positionLCB -fill x
		$positionLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -position]
	  }
	  radius {
		pack $radiusLSB -fill x
		$radiusLSB configure -text [$options(-ctcpanel) itemcget $options(-object) -radius]
	  }
	  type {
		pack $typeLCB -fill x
		$typeLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -type]
	  }
	  normalcommand {
		pack $normalcommandLF -fill x
		$normalcommandText delete 1.0 end
		$normalcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
	  }
	  reversecommand {
		pack $reversecommandLF -fill x
		$reversecommandText delete 1.0 end
		$reversecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -reversecommand]"
	  }
	  leftcommand {
		pack $leftcommandLF -fill x
		$leftcommandText delete 1.0 end
		$leftcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -leftcommand]"
	  }
	  centercommand {
		pack $centercommandLF -fill x
		$centercommandText delete 1.0 end
		$centercommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -centercommand]"
	  }
	  rightcommand {
		pack $rightcommandLF -fill x
		$rightcommandText delete 1.0 end
		$rightcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -rightcommand]"
	  }
	  command {
		pack $commandLF -fill x
		$commandText delete 1.0 end
		$commandText insert end "[$options(-ctcpanel) itemcget $options(-object) -command]"
	  }
	  statecommand {
		pack $statecommandLF -fill x
		$statecommandText delete 1.0 end
		$statecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -statecommand]"
	  }
	  occupiedcommand {
		pack $occupiedcommandLF -fill x
		$occupiedcommandText delete 1.0 end
		$occupiedcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -occupiedcommand]"
	  }
	}
      }
    }
    method _Cancel {} {
      $hull withdraw
      return [$hull enddialog {}]
    }
    method _CheckNameChars {value} {
      return [expr {[regexp {^[[:alpha:]][[:alnum:]_.-]*$} "$value"] > 0}]
    }	
    method _Add {} {
      set name "[$nameLE cget -text]"
      if {[string equal "$options(-mode)" add]} {
	if {![$self _CheckNameChars "$name"]} {
	  tk_messageBox -type ok -icon error \
		      -message "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '$name'"
	  return
	}
	if {[lsearch -exact [$options(-ctcpanel) objectlist] "$name"] >= 0} {
	  tk_messageBox -type ok -icon error \
		      -message "Name '$name' already in use.  Pick another."
	  return
	}
      }
      set cp "[$controlPointLCB cget -text]"
      if {![$self _CheckNameChars "$cp"]} {
	tk_messageBox -type ok -icon error \
		      -message "Illegal characters in control point, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '$cp'"
	return
      }
      $hull withdraw
      lappend result "$objectType" "$name"
      lappend result -controlpoint "$cp"
      $self getOptions result
      return [$hull enddialog "$result"]
    }
    method getOptions {resultVar} {
      upvar $resultVar result
      foreach opt $objectTypeOptions($objectType) {
	switch -exact $opt {
	  xyctl -
	  xysch {
		lappend result -x  [$x1LSB cget -text] -y  [$y1LSB cget -text]
	  }
	  xy1sch {
		lappend result -x1  [$x1LSB cget -text] -y1  [$y1LSB cget -text]
	  }
	  xy2sch {
		lappend result -x2  [$x2LSB cget -text] -y2  [$y2LSB cget -text]
	  }
	  label {
		lappend result -label "[$labelLE cget -text]"
	  }
	  normalcommand {
		lappend result -normalcommand "[$normalcommandText get 1.0 end-1c]"
	  }
	  reversecommand {
		lappend result -reversecommand "[$reversecommandText get 1.0 end-1c]"
	  }
	  leftcommand {
		lappend result -leftcommand "[$leftcommandText get 1.0 end-1c]"
	  }
	  centercommand {
		lappend result -centercommand "[$centercommandText get 1.0 end-1c]"
	  }
	  rightcommand {
		lappend result -rightcommand "[$rightcommandText get 1.0 end-1c]"
	  }
	  command {
		lappend result -command "[$commandText get 1.0 end-1c]"
	  }
	  hvorientation {
		lappend result -orientation [$hvorientationLCB cget -text]
	  }
	  leftlabel {
		lappend result -leftlabel "[$leftlabelLE cget -text]"
	  }
	  centerlabel {
		lappend result -centerlabel "[$centerlabelLE cget -text]"
	  }
	  rightlabel {
		  lappend result -rightlabel "[$rightlabelLE cget -text]"
	  }
	  hascenter {
		lappend result -hascenter [$hascenterLCB cget -text]
	  }
	  color {
		lappend result -color "[$colorLSC cget -text]"
	  }
	  orientation {
		lappend result -orientation "[$orientationLCB cget -text]"
	  }
	  flipped {
		lappend result -flipped "[$flippedLCB cget -text]"
	  }
	  heads {
		lappend result -heads "[$headsLCB cget -text]"
	  }
	  statecommand {
		lappend result -statecommand "[$statecommandText get 1.0 end-1c]"
	  }
	  occupiedcommand {
		lappend result -occupiedcommand "[$occupiedcommandText get 1.0 end-1c]"
	  }
	  position {
		lappend result -position "[$positionLCB cget -text]"
	  }
	  radius {
		lappend result -radius "[$radiusLSB cget -text]"
	  }
	  type {
		lappend result -type "[$typeLCB cget -text]"
	  }
	}
      }
    }
    method _chschXY1 {} {
      $options(-ctcpanel) schematic crosshair -xvar [myvar x1] -yvar [myvar y1]
    }
    method _chschXY2 {} {
      $options(-ctcpanel) schematic crosshair -xvar [myvar x2] -yvar [myvar y2]
    }
    method _chctlXY1 {} {
      $options(-ctcpanel) controls crosshair -xvar [myvar x1] -yvar [myvar y1]
    }
  }
  snit::widgetadaptor SelectPanelObjectDialog {
    delegate option -parent to hull
    option -ctcpanel -default {}

    component namePatternLE;#		Search Pattern
    component nameListSW;#		Name list ScrollWindow
    component   nameList;#		Name list
    component selectedNameLE;#		Selected Name

    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 2 -modal local -transient yes \
				-side bottom -title {Select Panel Object} \
				-parent [from args -parent]
      $hull add -name select -text Select -command [mymethod _Select]
      $hull add -name find   -text Find   -command [mymethod _Find]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Select Panel Object Dialog}}
      set frame [$hull getframe]
      install namePatternLE using LabelEntry $frame.namePatternLE \
					-label "Pattern:" \
					-labelwidth 15 \
					-text {*}
      pack $namePatternLE -fill x
      $namePatternLE bind <Return> [mymethod _Find]
      install nameListSW using ScrolledWindow $frame.nameListSW \
			-scrollbar both -auto both
      pack $nameListSW -expand yes -fill both
      install nameList using ListBox [$nameListSW getframe].nameList \
			-selectmode single
      pack $nameList -expand yes -fill both
      $nameListSW setwidget $nameList
      $nameList bindText <1> [mymethod _ListSelect]
      $nameList bindText <Double-1> [mymethod _ListSelectAnd_Select]
      install selectedNameLE using LabelEntry $frame.nselectedNameLE \
					-label "Selection:" \
					-labelwidth 15
      pack $selectedNameLE -fill x
      $selectedNameLE bind <Return> [mymethod _Select]
      $self configurelist $args
    }
    method draw {args} {
      $self _Find
      return [$hull draw]
    }
    method _Cancel {} {
      $hull withdraw
      return [$hull enddialog {}]
    }
    method _Find {} {
      $nameList delete [$nameList items]
      set elts [lsort -dictionary [lsearch -glob -all -inline \
					[$options(-ctcpanel) objectlist] \
					"[$namePatternLE cget -text]"]]
      foreach elt $elts {
	$nameList insert end $elt -data $elt -text $elt
      }
    }
    method _ListSelect {item} {
      $selectedNameLE configure -text "[$nameList itemcget $item -data]"      
    }
    method _ListSelectAnd_Select {item} {
      $self _ListSelect $item
      return [$self _Select]
    }
    method _Select {} {
      if {[lsearch -exact [$options(-ctcpanel) objectlist] \
			  "[$selectedNameLE cget -text]"] < 0} {
	tk_messageBox -type ok -icon warning -message "No such object: [$selectedNameLE cget -text]"
	return
      }
      return [$hull enddialog "[$selectedNameLE cget -text]"]
    }
  }
  snit::widgetadaptor ConfigurePanelDialog  {
    delegate option -parent to hull


    component nameLE;#			-name (RO)
    component widthLSB;#		-width
    component heightLSB;#		-height
    component hascmriLCB;#		-hascmri
    component cmriportLCB;#		-cmriport
    component cmrispeedLCB;#		-cmrispeed
    component cmriretriesLSB;#		-cmriretries

    constructor {args} {
#      puts stderr "*** $type create $self $args"
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title {Edit Panel Options} \
				-parent [from args -parent]
      $hull add -name update -text Update -command [mymethod _Update]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Configuring CTC Panel Windows}}
      set frame [$hull getframe]
      install nameLE using LabelEntry $frame.nameLE -label "Name:" \
						    -labelwidth 15 \
						    -editable no
      pack $nameLE -fill x
      install widthLSB using LabelSpinBox $frame.widthLSB -label "Width:" \
						   -labelwidth 15 \
						   -range {780 1000 10}
      pack $widthLSB -fill x
      install heightLSB using LabelSpinBox $frame.heightLSB -label "Height:" \
						   -labelwidth 15 \
						   -range {550 800 10}
      pack $heightLSB -fill x
      install hascmriLCB using LabelComboBox $frame.hascmriLCB \
						   -label "Has CM/RI?" \
						   -labelwidth 15 \
						   -values {yes no} \
						   -editable no
      $hascmriLCB setvalue last
      pack $hascmriLCB -fill x
      install cmriportLCB using LabelComboBox $frame.cmriportLCB \
						   -label "CM/RI Port:" \
						   -labelwidth 15 \
						   -values {/dev/ttyS0 
							    /dev/ttyS1 
							    /dev/ttyS2 
							    /dev/ttyS3}
      pack $cmriportLCB -fill x
      $cmriportLCB setvalue first
      install cmrispeedLCB using LabelComboBox $frame.cmrispeedLCB \
						   -label "CM/RI Speed:" \
						   -labelwidth 15 \
						   -values {4800 9600 19200}
      pack $cmrispeedLCB -fill x
      $cmrispeedLCB setvalue @1
      install cmriretriesLSB using LabelSpinBox $frame.cmriretriesLSB \
						   -label "CM/RI Retries:" \
						   -labelwidth 15 \
						   -range {5000 20000 100}
      pack $cmriretriesLSB -fill x
      $cmriretriesLSB configure -text 10000
      $self configurelist $args
    }
    method draw {args} {
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient $win [winfo toplevel $parent]
      $nameLE configure -text "[$parent cget -name]"
      $widthLSB configure -text [$parent cget -width]
      $heightLSB configure -text [$parent cget -height]
      $hascmriLCB configure -text [$parent cget -hascmri]
      $cmriportLCB configure -text "[$parent cget -cmriport]"
      $cmrispeedLCB configure -text [$parent cget -cmrispeed]
      $cmriretriesLSB configure -text [$parent cget -cmriretries]
      return [$hull draw]
    }
    method _Cancel {} {
      $hull withdraw
      return [$hull enddialog {}]
    }
    method _Update {} {
      $hull withdraw
      lappend result -width [$widthLSB cget -text]
      lappend result -height [$heightLSB cget -text]
      lappend result -hascmri [$hascmriLCB cget -text]
      lappend result -cmriport "[$cmriportLCB cget -text]"
      lappend result -cmrispeed [$cmrispeedLCB cget -text]
      lappend result -cmriretries [$cmriretriesLSB cget -text]
      return [$hull enddialog $result]
    }
  }
  snit::widgetadaptor AddCMRINodeDialog {
    delegate option -parent to hull
    option -node -default {}
    option -mode -default add
    component nameLE;#		  Name of board (symbol)
    component uaLSB;#			UA of board (0-127)
    component nodeTypeLCB;#		Type of board (SUSIC, USIC, or SMINI)
    component numberYellowSigsLSB;#	-ns (0-24)
    component numberInputsLSB;#		-ni (0-1023)
    component numberOutputsLSB;#	-no (0-1023)
    component delayValueLSB;#		-dl (0-65535)
    component cardTypeMapLE;#		-ct (list of bytes)

    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title {Add CMR/I Node to panel} \
				-parent [from args -parent]
      $hull add -name add    -text Add    -command [mymethod _Add]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Add CMRI Node Dialog}}
      set frame [$hull getframe]
      install nameLE using LabelEntry $frame.nameLE -label "Name:" \
						    -labelwidth 18 \
						    -text {}
      pack $nameLE -fill x
      install uaLSB using LabelSpinBox $frame.uaLSB  -label "UA:" \
						     -labelwidth 18 \
						     -range {0 127 1}
      pack $uaLSB -fill x
      install nodeTypeLCB using LabelComboBox $frame.nodeTypeLCB \
					-label "Board Type:" \
					-labelwidth 18 \
					-values {SUSIC USIC SMINI} \
					-editable no \
					-modifycmd [mymethod _updateCTLab]
      $nodeTypeLCB setvalue first
      pack $nodeTypeLCB -fill x
      install numberYellowSigsLSB using LabelSpinBox $frame.numberYellowSigsLSB \
					-label {# Yellow Signals:} \
					-labelwidth 18 \
					-range {0 24 1}
      pack $numberYellowSigsLSB -fill x
      install numberInputsLSB using LabelSpinBox $frame.numberInputsLSB \
					-label {# Inputs:} \
					-labelwidth 18 \
					-range {0 1023 1}
      pack $numberInputsLSB -fill x
      install numberOutputsLSB using LabelSpinBox $frame.numberOutputsLSB \
					-label {# Outputs:} \
					-labelwidth 18 \
					-range {0 1023 1}
      pack $numberOutputsLSB -fill x
      install delayValueLSB using LabelSpinBox $frame.delayValueLSB \
					-label {Delay Value:} \
					-labelwidth 18 \
					-range {0 65535 1}
      pack $delayValueLSB -fill x
      install cardTypeMapLE using LabelEntry $frame.cardTypeMapLE \
					-label {Card Type Map:} \
					-labelwidth 18

      pack $cardTypeMapLE -fill x
    }
    method draw {args} {
#      puts stderr "*** $self draw $args"
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient [winfo toplevel $win] $parent
      switch -exact $options(-mode) {
	edit {
	  set node [$parent getcmrinode "$options(-node)"]
	  $nameLE configure -text $options(-node) -editable no
	  $uaLSB configure -text [lindex $node 0]
	  $nodeTypeLCB configure -text [lindex $node 1]
	  $self _updateCTLab
	  set opts [lrange $node 2 end]
	  $numberYellowSigsLSB configure -text [from opts -ns [$numberYellowSigsLSB cget -text]]
	  $numberInputsLSB configure -text [from opts -ni [$numberInputsLSB cget -text]]
	  $numberOutputsLSB configure -text [from opts -no [$numberOutputsLSB cget -text]]
	  $delayValueLSB configure -text [from opts -dl [$delayValueLSB cget -text]]
	  $cardTypeMapLE configure -text "[from opts -ct [$cardTypeMapLE cget -text]]"
	  $hull itemconfigure add -text "Update"
	  $hull configure -title {Edit CMR/I node}
	}
	add -
	default {
	  $nameLE configure -editable yes
	  $hull itemconfigure add -text "Add"
	  $hull configure -title {Add CMR/I Node to panel}
	}
      }
      return [$hull draw]
    }
    method _Cancel {} {
      $hull withdraw
      return [$hull enddialog {}]
    }
    method _CheckNameChars {value} {
      return [expr {[regexp {^[[:alpha:]][[:alnum:]_.-]*$} "$value"] > 0}]
    }
    method _Add {} {
      set name "[$nameLE cget -text]"
      if {[string equal "$options(-mode)" add]} {
	if {![$self _CheckNameChars "$name"]} {
	  tk_messageBox -type ok -icon error \
		      -message "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '$name'"
	  return
	}
	set parent [$hull cget -parent]
	if {[lsearch -exact [$parent cmrinodelist] "$name"] >= 0} {
	  tk_messageBox -type ok -icon error \
		      -message "Name '$name' already in use.  Pick another."
	  return
	}
      }
      $hull withdraw
      lappend result "$name" [$uaLSB cget -text] [$nodeTypeLCB cget -text]
      lappend result -ns [$numberYellowSigsLSB cget -text]
      lappend result -ni [$numberInputsLSB cget -text]
      lappend result -no [$numberOutputsLSB cget -text]
      lappend result -dl [$delayValueLSB cget -text]
      lappend result -ct "[$cardTypeMapLE cget -text]"
      return [$hull enddialog "$result"]
    }
    method _updateCTLab {} {
      if {[string equal "[$nodeTypeLCB cget -text]" {SMINI}]} {
	$cardTypeMapLE configure -label {Yellow Signal Map:}
	$numberInputsLSB configure -text 3
	$numberInputsLSB configure -state disabled
	$numberOutputsLSB configure -text 6
	$numberOutputsLSB configure -state disabled
      } else {
	$cardTypeMapLE configure -label {Card Type Map:}
	$numberInputsLSB configure -state normal
	$numberOutputsLSB configure -state normal
      }
    }
  }
  snit::widgetadaptor SelectCMRINodeDialog {
    delegate option -parent to hull

    component namePatternLE;#		Search Pattern
    component nameListSW;#		Name list ScrollWindow
    component   nameList;#		Name list
    component selectedNameLE;#		Selected Name

    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 2 -modal local -transient yes \
				-side bottom -title {Select CMRI Node} \
				-parent [from args -parent]
      $hull add -name select -text Select -command [mymethod _Select]
      $hull add -name find   -text Find   -command [mymethod _Find]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Select CMRI Node Dialog}}
      set frame [$hull getframe]
      install namePatternLE using LabelEntry $frame.namePatternLE \
					-label "Pattern:" \
					-labelwidth 18 \
					-text {*}
      pack $namePatternLE -fill x
      $namePatternLE bind <Return> [mymethod _Find]
      install nameListSW using ScrolledWindow $frame.nameListSW \
			-scrollbar both -auto both
      pack $nameListSW -expand yes -fill both
      install nameList using ListBox [$nameListSW getframe].nameList \
			-selectmode single
      pack $nameList -expand yes -fill both
      $nameListSW setwidget $nameList
      $nameList bindText <1> [mymethod _ListSelect]
      $nameList bindText <Double-1> [mymethod _ListSelectAnd_Select]
      install selectedNameLE using LabelEntry $frame.nselectedNameLE \
					-label "Selection:" \
					-labelwidth 18
      pack $selectedNameLE -fill x
      $selectedNameLE bind <Return> [mymethod _Select]
      $self configurelist $args
    }
    method draw {args} {
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient [winfo toplevel $win] $parent
      $self _Find
      return [$hull draw]
    }
    method _Cancel {} {
      $hull withdraw
      return [$hull enddialog {}]
    }
    method _Find {} {
      $nameList delete [$nameList items]
      set parent [$hull cget -parent]
      set elts [lsort -dictionary [lsearch -glob -all -inline \
					[$parent cmrinodelist] \
					"[$namePatternLE cget -text]"]]
      foreach elt $elts {
	$nameList insert end $elt -data $elt -text $elt
      }
    }
    method _ListSelect {item} {
      $selectedNameLE configure -text "[$nameList itemcget $item -data]"      
    }
    method _ListSelectAnd_Select {item} {
      $self _ListSelect $item
      return [$self _Select]
    }
    method _Select {} {
      set parent [$hull cget -parent]
      if {[lsearch -exact [$parent cmrinodelist] \
			  "[$selectedNameLE cget -text]"] < 0} {
	tk_messageBox -type ok -icon warning -message "No such board: [$selectedNameLE cget -text]"
	return
      }
      return [$hull enddialog "[$selectedNameLE cget -text]"]
    }
  }
  snit::widgetadaptor EditUserCodeDialog {
    delegate option -parent to hull

    component codeTextSW;#		ScrollWindow
    component   codeText;#		code text

    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title {Edit User Code} \
				-parent [from args -parent]
      $hull add -name update -text Update -command [mymethod _Update]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Edit User Code Dialog}}
      set frame [$hull getframe]
      install codeTextSW using ScrolledWindow $frame.codeTextSW \
		-scrollbar both -auto both
      pack $codeTextSW -expand yes -fill both
      install codeText using text [$codeTextSW getframe].codeText \
		-wrap none
      bindtags $codeText [list $codeText Text]
      pack $codeText -expand yes -fill both
      $codeTextSW setwidget $codeText
      $self configurelist $args
    }
    method draw {code args} {
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient [winfo toplevel $win] $parent
      $codeText delete 1.0 end
      $codeText insert end "$code"
      return [$hull draw]
    }
    method _Cancel {} {
      $hull withdraw   
      return [$hull enddialog cancel]
    }
    method _Update {} {
      $hull withdraw
      return [$hull enddialog update]
    }
    method getcode {} {
      return "[$codeText get 1.0 end]"
    }
  }
  snit::type WaitExternalProgramASync {
    option -commandline -readonly yes
    variable pipe
    variable processflag
    constructor {args} {
      $self configurelist $args
      if {![info exists options(-commandline)] || 
	  [string length "$options(-commandline)"] == 0} {
	error "-commandline is a required option!"
      }
      set pipe [open "|$options(-commandline)" r]
      set processflag 1
      fileevent $pipe readable [mymethod _ReadPipe]
    }
    destructor {
      if {[info exists processflag]} {
	if {$processflag > 0} {vwait [myvar processflag]}
      }
    }
    method _ReadPipe {} {
      if {[gets $pipe line] < 0} {
	catch {close $pipe}
	incr processflag -1
      }
    }
    method wait {} {
      if {$processflag > 0} {vwait [myvar processflag]}
    }
  }
}


package provide CTCPanelWindow 1.0
