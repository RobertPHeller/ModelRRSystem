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
#*			51 Locke Hill Road
#*			Wendell, MA 01379-9728
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

# $Id: CTCPanelWindow.tcl 709 2009-05-01 15:20:49Z heller $

package require gettext
package require BWidget
package require snit
package require grsupport 2.0
package require CTCPanel 2.0
package require BWLabelSpinBox
package require BWLabelComboBox
package require LabelSelectColor
package require WrapIt
package require pdf4tcl
package require PrintDialog 2.0

catch {Dispatcher::SplashWorkMessage "Loading CTC Panel Window Code" 16}

namespace eval CTCPanelWindow {
  snit::widget CTCPanelWindow {
    widgetclass CTCPanelWindow
    hulltype    toplevel

    typevariable CodeLibraryDir {}
    typevariable OpenWindows -array {}
    typemethod selectwindowbyname {name} {
      if {[catch {set OpenWindows($name)} window]} {
	error [_ "No such window: $name!"]
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
	error [_ "Duplicate %s: %s" $option $value]
      }
    }
      
    option -filename -default {newctcpanel.tcl}
    delegate option -width to ctcpanel
    delegate option -height to ctcpanel
    delegate option -menu to hull
    option -hascmri -default no -validatemethod _VerifyBoolean \
				-configuremethod _ConfigureCMRI
    option -hasmrd -default no -validatemethod _VerifyBoolean \
				-configuremethod _ConfigureMRD
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
    option -simplemode -default no -validatemethod _VerifyBoolean \
					-configuremethod _ConfigureSimpleMode
    variable cmrinodes -array {}

    method _ConfigureMRD {option value} {
      set options($option) $value
      if {$value} {
	$main mainframe setmenustate mrd normal
      } else {
	$main mainframe setmenustate mrd disabled
      }
    }
    method _ConfigureSimpleMode {option value} {
      set options($option) $value
      set editmenu [$main mainframe getmenu edit]
      if {$value} {
	$main mainframe setmenustate edit:simplemode disabled
	$self AddModule SimpleMode
	$self GenerateMainLoop
      } else {
      	$main mainframe setmenustate edit:simplemode normal
      }
    }
    variable mrdnodes -array {}

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

      if {[WrapIt::CanWrapP]} {
	set wrapasstate normal
      } else {
	set wrapasstate disabled
      }
      if {$options(-simplemode)} {
	$self AddModule SimpleMode
	$self GenerateMainLoop
	set editstate disabled
      } else {
	set editstate normal
      }
      set fm1 {}
      lappend fm1 \
        [list command [_m "Menu|File|&New CTC Panel Window"] {file:new} \
			[_ "New CTC Panel Window"]  {Ctrl n} \
			-command [mytypemethod new -parent $win -simplemode $Dispatcher::SimpleMode]]
      lappend fm1 \
	[list command [_m "Menu|File|&Load..."]  {file:load} \
			[_ "Open and Load XTrkCad Layout File"] {Ctrl l} \
			-command Dispatcher::LoadLayout]
      lappend fm1 \
        [list command [_m "Menu|File|&Open..."] {file:open} \
			[_ "Open an existing CTC Panel Window file"] {Ctrl o} \
			-command [mytypemethod open -parent $win]]
      lappend fm1 \
        [list command [_m "Menu|File|&Save"] {file:save} \
			[_ "Save window code"] {Ctrl s} \
			-command [mymethod save]]
      lappend fm1 \
        [list command [_m "Menu|File|Save &As..."] {file:save} \
			[_ "Save window code"] {Ctrl a} \
			-command [mymethod saveas]]
      lappend fm1 \
	[list command [_m "Menu|File|Wrap As..."] {file:wrap} \
			[_ "Wrap window code"] {Ctrl w} \
			-command [mymethod wrapas] -state $wrapasstate]
      lappend fm1 \
	[list command [_m "Menu|File|Print..."] {file:print} \
			[_ "Print Panel"] {Ctrl p} \
			-command [mymethod print]]
      lappend fm1 \
	[list command [_m "Menu|File|Export as images..."] {file:export} \
			[_ "Export panel as images"] {Ctrl e} \
			-command [mymethod export]]
      lappend fm1 \
        [list command [_m "Menu|File|&Close"] {file:close} \
			[_ "Close the application"] {} \
			-command [mymethod close]]
      lappend fm1 \
        [list command [_m "Menu|File|E&xit"] {file:exit} \
			[_ "Exit the application"] {} \
			-command {Dispatcher::CarefulExit}]
      set filemenu [list [_m "Menu|&File"] {file} {file} 0 $fm1]
      #puts stderr "*** CTCPanelWindow::create: filemenu = $filemenu"
      set em1 {}
      lappend em1 \
        [list command [_m "Menu|Edit|&Undo"] {edit:undo} [_ "Undo last change"] {Ctrl z}]
      lappend em1 \
        [list command [_m "Menu|Edit|Cu&t"] {edit:cut edit:havesel} [_ "Cut selection to the paste buffer"] {Ctrl x} -command StdMenuBar::EditCut]
      lappend em1 \
        [list command [_m "Menu|Edit|&Copy"] {edit:copy edit:havesel} [_ "Copy selection to the paste buffer"] {Ctrl c} -command StdMenuBar::EditCopy]
      lappend em1 \
        [list command [_m "Menu|Edit|C&lear"] {edit:clear edit:havesel} [_ "Clear selection"] {} -command StdMenuBar::EditClear]
      lappend em1 \
        [list command [_m "Menu|Edit|&Delete"] {edit:delete edit:havesel} [_ "Delete selection"] {Ctrl d}]
      lappend em1 \
        {separator}
      lappend em1 \
        [list command [_m "Menu|Edit|Select All"] {edit:selectall} [_ "Select everything"] {}]
      lappend em1 \
        [list command [_m "Menu|Edit|De-select All"] {edit:deselectall edit:havesel} [_ "Select nothing"] {}]
      lappend em1 \
	{separator}
      lappend em1 \
	[list command [_m "Menu|Edit|(Re-)Generate Main Loop"] \
			{edit:mainloop edit:simplemode} \
			"" {} -command [mymethod GenerateMainLoop] -state $editstate] 
      lappend em1 \
	[list command [_m "Menu|Edit|User Code"] \
			{edit:usercode edit:simplemode} \
			"" {} -command [mymethod EditUserCode] -state $editstate] 
      set em1m {}
      lappend em1m \
	    [list command [_m "Menu|Edit|Modules|Track Work type"] \
			{edit:modules:trackwork edit:simplemode} \
			"" {} -command [mymethod AddModule TrackWork]  \
			-state $editstate]
      lappend em1m \
	    [list command  [_m "Menu|Edit|Modules|Switch Plate type"] \
			{edit:modules:switchplate edit:simplemode} \
			"" {} -command [mymethod AddModule SwitchPlates] \
			-state $editstate]
      set em1ms {}
      lappend em1ms \
		[list command [_m "Menu|Edit|Signals|Two Aspect Color Light"] \
			{edit:modules:signals:twoaspcolor edit:simplemode} \
			"" {} -command [mymethod AddModule Signals2ACL] \
			-state $editstate]
      lappend em1ms \
		[list command [_m "Menu|Edit|Signals|Three Aspect Color Light"] \
			{edit:modules:signals:threeaspcolor edit:simplemode} \
			"" {} -command [mymethod AddModule Signals3ACL] \
			-state $editstate]
      lappend em1ms \
		[list command [_m "Menu|Edit|Signals|Three Aspect Search Light"] \
			{edit:modules:signals:threeaspsearch edit:simplemode} \
			"" {} -command [mymethod AddModule Signals3ASL] \
			      -state $editstate] 

      lappend em1m \
	    [list cascade [_m "Menu|Edit|Signals"] \
			{edit:modules:signals edit:simplemode} \
			edit:modules:signals 0 $em1ms]

      lappend em1m \
	    [list command [_m "Menu|Edit|Signals|Signal Plate type"] \
			{edit:modules:signalplate edit:simplemode} \
			"" {} -command [mymethod AddModule SignalPlates] \
		 -state $editstate]
      lappend em1m \
	    [list command [_m "Menu|Edit|Signals|Control Point type"] \
			{edit:modules:controlpoint edit:simplemode} \
			"" {} -command [mymethod AddModule ControlPoints] \
		 -state $editstate]
      lappend em1m \
	    [list command [_m "Menu|Edit|Signals|Radio Group Type"] \
			{edit:modules:radiogroup edit:simplemode} \
			"" {} -command [mymethod AddModule Groups] \
		 -state $editstate]

      lappend em1 \
	[list cascade [_m "Menu|Edit|Modules"] \
			{edit:modules edit:simplemode} \
			edit:modules 0 $em1m]
      set editmenu [list [_m "Menu|&Edit"] {edit} {edit} 0 $em1]
      #puts stderr "*** CTCPanelWindow::create: editmenu = $editmenu"
      set mainmenu [StdMenuBar::MakeMenu -file  $filemenu -edit  $editmenu ]
      #puts stderr "*** CTCPanelWindow::create: mainmenu = $mainmenu"

      install main using mainwindow $win.main \
	-menu $mainmenu \
	-extramenus [list \
		      [_m "Menu|&Panel"] panel panel 0 [list \
			[list command [_m "Menu|Panel|Add Object"] {} [_ "Add Panel Object"] {} \
				-command [mymethod addpanelobject]] \
			[list command [_m "Menu|Panel|Edit Object"] {} [_ "Edit Panel Object"] {} \
				-command [mymethod editpanelobject]] \
			[list command [_m "Menu|Panel|Delete Object"] {} [_ "Delete Panel Object"] {} \
				-command [mymethod deletepanelobject]] \
			{separator} \
			[list command [_m "Menu|Panel|Configure"] {} [_ "Configure Panel Options"] {} \
				-command [mymethod configurepanel]] \
			] \
		      [_m "Menu|&C/Mri"] cmri cmri 0 [list \
			[list command [_m "Menu|C/Mri|Add node"] {} [_ "Add CMRI node"] {} \
				-command [mymethod addcmrinode]] \
			[list command [_m "Menu|C/Mri|Edit node"] {} [_ "Edit CMRI node"] {} \
				-command [mymethod editcmrinode]] \
			[list command [_m "Menu|C/Mri|Delete Node"] {} [_ "Delete CMRI node"] {} \
				-command [mymethod deletecmrinode]] \
			] \
		      [_m "Menu|&MRD"] mrd mrd 0 [list \
			[list command [_m "Menu|MRD|Add node"] {} [_ "Add MRD node"] {} \
				-command [mymethod addmrdnode]] \
			[list command [_m "Menu|MRD|Edit node"] {} [_ "Edit MRD node"] {} \
				-command [mymethod editmrdnode]] \
			[list command [_m "Menu|MRD|Delete node"] {} [_ "Delete MRD node"] {} \
				-command [mymethod deletemrdnode]] \
			] \
		    ]

      $main menu delete help [_m "Menu|Help|On Keys..."]
      $main menu delete help [_m "Menu|Help|Index..."]
      $main menu add help command \
	-label [_m "Menu|Help|Reference Manual"] \
	-command "::HTMLHelp::HTMLHelp help {Dispatcher Reference}"
      $main menu entryconfigure help [_m "Menu|Help|On Help..."] \
	-command "::HTMLHelp::HTMLHelp help Help"
      $main menu entryconfigure help [_m "Menu|Help|Tutorial..."] \
	-command "::HTMLHelp::HTMLHelp help {Dispatcher Tutorial}"
      $main menu entryconfigure help [_m "Menu|Help|On Version"] \
	-command "::HTMLHelp::HTMLHelp help Version"
      $main menu entryconfigure help [_m "Menu|Help|Copying"] \
	-command "::HTMLHelp::HTMLHelp help Copying"
      $main menu entryconfigure help [_m "Menu|Help|Warranty"] \
	-command "::HTMLHelp::HTMLHelp help Warranty"

      $main mainframe setmenustate cmri disabled
      $main mainframe setmenustate mrd disabled
      pack $main -expand yes -fill both

      set frame [$main scrollwindow getframe]
      install swframe using ScrollableFrame $frame.swframe \
			-constrainedheight yes -constrainedwidth yes
      pack $swframe -expand yes -fill both
      $main scrollwindow setwidget $swframe
      install ctcpanel using ::CTCPanel::CTCPanel [$swframe getframe].ctcpanel
      pack $ctcpanel -fill both -expand yes
      set dirty [$main mainframe addindicator]
      $dirty configure -bitmap gray50 -foreground red

      $self configurelist $args
      $swframe configure -width [expr {[$ctcpanel cget -width] + 15}] \
			 -height [$ctcpanel cget -height]
      wm title $win $options(-name)


      $main menu add view command \
		-label [_m "Menu|View|Zoom In"] \
		-accelerator {+} \
		-command "$ctcpanel zoomBy 2"
      set zoomMenu [menu [$main mainframe getmenu view].zoom -tearoff no]
      $main menu add view cascade \
		-label [_m "menu|View|Zoom"] \
		-menu $zoomMenu
      $main menu add view command \
		-label [_m "Menu|View|Zoom Out"] \
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


      $main showit
      set OpenWindows($options(-name)) $win
      Dispatcher::AddToWindows $win "$options(-name)"
      $self buildDialogs
      if {$options(-simplemode)} {
	$self AddModule SimpleMode
	$self GenerateMainLoop
      }
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
			   -message [_ "Window $options(-name) is modified.  Save it?"]]} {
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
				     -title [_ "File to save to"] \
				     -parent $win]
      }
      if {[string length "$filename"] == 0} {return}
      if {[file exists "$filename"]} {
	file rename -force "$filename" "${filename}~"
      }
      if {[catch {open "$filename" w} fp]} {
	catch {file rename -force "${filename}~" "$filename"}
	tk_messageBox -type ok -icon error  -parent $win \
		      -message [_ "Could not open $filename: %s" $fp]
	return
      }
      $self writeprog $fp [file rootname [file tail $filename]]
      close $fp
      if {[lsearch -exact [file attributes "$filename"] -permissions] >= 0} {
	file attributes "$filename" -permissions +x
      }
      $self configure -filename "$filename"
      $self cleardirty
    }
    method writeprog {fp module {iswraped no}} {
      if {$iswraped} {
	puts $fp "package provide app-$module 1.0"
      } else {
	puts $fp {#!/usr/bin/wish}
      }
      puts $fp "# Generated code: [clock format [clock scan now]]"
      puts $fp {# Generated by: $Id: CTCPanelWindow.tcl 709 2009-05-01 15:20:49Z heller $}
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
      puts $fp "# -hasmrd $options(-hasmrd)"
      puts $fp "# -simplemode $options(-simplemode)"
      puts $fp {# Load Tcl/Tk system supplied packages}
      puts $fp {package require Tk;#		Make sure Tk is loaded}
      puts $fp {package require BWidget;#       Load BWidgets}
      puts $fp {package require snit;#		Load Snit}
      puts $fp {}
      puts $fp {# Load MRR System packages}
      if {!$iswraped} {
	puts $fp {# Add MRR System package Paths}
	puts $fp {lappend auto_path /usr/local/lib/MRRSystem;# C++ (binary) packages}
	puts $fp {lappend auto_path /usr/local/share/MRRSystem;# Tcl (source) packages}
      }
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
      if {$options(-hasmrd)} {
	puts $fp {}
	puts $fp "package require Mrd"
	puts $fp {# MRD Nodes}
	foreach name [array names mrdnodes] {
	  puts $fp [list MRD $name $mrdnodes($name)]
	}
      }
      puts $fp {}
      puts $fp {# Add User code after this line}
      puts $fp "$userCode"
    }
    method wrapas {{filename {}}} {
#      puts stderr "*** $self wrapas $filename"
      if {[string length "$filename"] == 0} {
	set initdir [file dirname "$options(-filename)"]
	if {[string equal "$initdir" {.}]} {set initdir [pwd]}
	set exeext [file extension [info nameofexe]]
	set filetypes [list]
	lappend filetypes [list {Exe Files} [list "$exeext"] BINF]
	lappend filetypes {{All Files} *      BINF}
#	puts stderr "*** $self wrapas: exeext = \"$exeext\", filetypes = $filetypes"
	regsub -all {\.} [file extension "$options(-filename)"] {\\.} pattern
	regsub "$pattern" "$options(-filename)" "$exeext" exefile
#	puts stderr "*** $self wrapas: exefile = $exefile"
	set filename [tk_getSaveFile -initialfile "$exefile" \
				     -initialdir  "$initdir" \
				     -defaultextension "$exeext" \
				     -title [_ "File to save to"] \
				     -parent $win]

#				     -filetypes $filetypes \

      }
      if {[string length "$filename"] == 0} {return}
      if {[file exists "$filename"]} {
	file rename -force "$filename" "${filename}~"
      }
      WrapIt::WrapIt $filename [mymethod writeprog] $options(-hascmri) $options(-hasmrd)
    }
    method print {} {
      if {[llength [$ctcpanel objectlist]] < 1} {
	tk_messageBox -type ok -icon warning \
		-message [_ "Add some objects first!"] \
		-parent $win
	return
      }

      set printfile "[file rootname $options(-filename)].pdf"
      set pdfobj [PrintDialog::PrintDialog draw -parent $win \
					-filename $printfile]
      if {"$pdfobj" eq ""} {return}
      $pdfobj startPage
      $pdfobj canvas [set [$ctcpanel info vars schematic]] -bg yes -sticky nwe
      $pdfobj canvas [set [$ctcpanel info vars controls]] -bg yes -sticky swe
      $pdfobj write
      $pdfobj destroy
    }
    typecomponent _exportdialog
    typecomponent   exportSchematicfileFE
    typecomponent   exportSchematicfileCB
    typevariable    exportSchematicfileFlag yes
    typecomponent   exportControlsfileFE
    typecomponent   exportControlsfilCB
    typevariable    exportControlsfileFlag yes
    typevariable imageIcon
    typevariable imagefiletypes { {{GIF Files} {.gif}		}
				  {{PPM Files} {.ppm}	        }
				  {{BMP Files} {.bmp}	        }
				  {{JPEG Files} {.jpeg}	        }
				  {{PCX Files}  {.pcx}	        }
				  {{Pixmap Files} {.pixmap}     }
				  {{PNG Files} {.png}	        }
				  {{RAW Files} {.raw}	        }
				  {{SGI Files} {.sgi}	        }
				  {{SUN Files} {.sun}	        }
				  {{TGA Files} {.tga}	        }
				  {{TIFF Files} {.tiff}	        }
				  {{XPM Files} {.xpm}	        }
				  {{All Files} *	        } }
    typevariable allowedImageTypes {gif ppm bmp jpeg pcx pixmap png raw sgi 
				    sun tga tiff xpm}
    proc theimagetype {filename} {
#      puts stderr "*** CTCPanelWindow::theimagetype $filename"
#      puts stderr "*** CTCPanelWindow::theimagetype $filename's extension is '[file extension $filename]'"
      regsub {^\.} [file extension $filename] {} result
#      puts stderr "*** CTCPanelWindow::theimagetype: result = '$result'"
      return [string tolower $result]
    }
    proc checkImageType {filename} {
      return [expr {[lsearch -exact $allowedImageTypes [theimagetype $filename]] >= 0}]
    }
    typemethod createExportDialog {} {
      if {"$_exportdialog" ne "" && [winfo exists $_exportdialog]} {return}
      set _exportdialog [Dialog .dispatcher_exportdialog -image $imageIcon \
				-cancel 1 -default 0 -modal local \
				-parent . -side bottom \
				-title [_ "Image Export"] -transient yes]
      $_exportdialog add -name export	-text [_m "Button|Export"] \
					-command [mytypemethod _Export]
      $_exportdialog add -name cancel	-text [_m "Button|Cancel"]  \
					-command [mytypemethod _CanExport]
      set frame [$_exportdialog getframe]
      set lwidth [_mx "Label|Schematic Output file:" \
		      "Label|Controls Output file:"]
      set exportSchematicfileFE [FileEntry $frame.exportSchematicfileFE \
					-label [_m "Label|Schematic Output file:"] \
					-labelwidth $lwidth \
					-filetypes $imagefiletypes \
					-filedialog save]
      pack $exportSchematicfileFE -fill x
      set exportSchematicfileCB [checkbutton $frame.exportSchematicfileCB \
					-text [_ "Export Schematic?"] \
					-anchor w -justify left \
				-variable [mytypevar exportSchematicfileFlag]]
      pack $exportSchematicfileCB -fill x -expand yes
      set exportControlsfileFE [FileEntry $frame.exportControlsfileFE \
					-label [_m "Label|Controls Output file:"] \
					-labelwidth $lwidth \
					-filetypes $imagefiletypes \
					-filedialog save]
      pack $exportControlsfileFE -fill x
      set exportControlsfileCB [checkbutton $frame.exportControlsfileCB \
					-text [_ "Export Controls?"] \
					-anchor w -justify left \
				-variable [mytypevar exportControlsfileFlag]]
      pack $exportControlsfileCB -fill x -expand yes
    }
    typemethod _Export {} {
      set isOK yes
      if {$exportSchematicfileFlag && 
	  ![checkImageType "[$exportSchematicfileFE cget -text]"]} {
	tk_messageBox -icon warning  -parent $win \
		      -message [_ "Not a supported image type for Schematic file: %s" [theimagetype [$exportSchematicfileFE cget -text]]] \
		      -parent $_exportdialog -type ok
	set isOK no
      }
      if {$exportControlsfileFlag && 
	  ![checkImageType "[$exportControlsfileFE cget -text]"]} {
	tk_messageBox -icon warning  -parent $win \
		      -message [_ "Not a supported image type for Controls file: %s" [theimagetype [$exportControlsfileFE cget -text]]] \
		      -parent $_exportdialog -type ok
	set isOK no
      }
      if {$isOK} {
	$_exportdialog withdraw
	$_exportdialog enddialog export
      }
    }
    typemethod _CanExport {} {
      $_exportdialog withdraw
      $_exportdialog enddialog cancel
    }	
    typemethod drawExportDialog {args} {
      $type createExportDialog
      set parent [from args -parent .]
      $_exportdialog configure -parent $parent
      wm transient [winfo toplevel $_exportdialog] $parent
      set schematicfile [from args -schematicfile schematic.gif]
      set controlsfile [from args -controlsfile controls.gif]
      $exportSchematicfileFE configure -text "$schematicfile"
      $exportControlsfileFE configure -text "$controlsfile"
      set ans [$_exportdialog draw]
      switch $ans {
	export {set result [list]
	  if {$exportSchematicfileFlag} {
	    lappend result [$exportSchematicfileFE cget -text]
	  } else {
	    lappend result {}
	  }
	  if {$exportControlsfileFlag} {
	    lappend result [$exportControlsfileFE cget -text]
	  } else {
	    lappend result {}
	  } }
	cancel {set result [list {} {}]}
      }
      return $result
    }
    method export {} {
      set schematicfile "[file rootname $options(-filename)]_schematic.gif"
      set controlsfile "[file rootname $options(-filename)]_controls.gif"
      set outfiles [$type drawExportDialog -parent $win \
					   -schematicfile $schematicfile \
					   -controlsfile $controlsfile]
      update idletasks
      foreach {schematicfile controlsfile} $outfiles break
      if {"$schematicfile" ne ""} {
	set img [image create photo -format window -data [set [$ctcpanel info vars schematic]]]
	$img write "$schematicfile" -format [theimagetype $schematicfile]
	image delete $img
      }
      if {"$controlsfile" ne ""} {
	set img [image create photo -format window -data [set [$ctcpanel info vars controls]]]
	$img write "$controlsfile" -format [theimagetype $controlsfile]
	image delete $img
      }
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
    typemethod addmrdnode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] addmrdnode] $args]
    }
    typemethod editmrdnode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] editmrdnode] $args]
    }
    typemethod deletemrdnode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] deletemrdnode] $args]
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
				   -title [_ "CTC File to open"] \
				   -parent $parent]
#	puts stderr "*** $type open (after tk_getOpenFile): filename = '$filename'"
      }
      if {[string length "$filename"] == 0} {return}
      if {[catch {open "$filename" r} fp]} {
	tk_messageBox -type ok -icon error -parent $parent \
		      -message [_ "Could not open $filename: %s" $fp]
	return
      }
      set opts [list -filename "$filename"]
      set buffer {}
      while {[gets $fp line] >= 0} {
#	puts stderr "*** $type open (looking for options): line = '$line'"
	append buffer "$line"
	if {[info complete "$buffer"] && 
	    ![string equal "\\" "[string index $buffer end]"]} {
#	  puts stderr "*** $type open (looking for options): buffer = '$buffer'"
	  if {[regexp {^#} "$buffer"] < 1} {break}
	  if {[regexp {^# -} "$buffer"] < 1} {set buffer {};continue}
#	  puts stderr "*** $type open: buffer = '$buffer'"
#	  puts stderr "*** $type open: llength \$buffer is [llength $buffer]"
	  lappend opts [lindex $buffer 1] "[lindex $buffer 2]"
#	  puts stderr "*** $type open: opts = $opts"
	  set buffer {}
	} else {
	  append buffer "\n"
	}
      }
      set newWindow [eval [list $type create .ctcpanel%AUTO%] $opts]
      while {[gets $fp line] >= 0} {
#	puts stderr "*** $type open (looking for CTCPanelObjects): line = '$line'"
	if {[regexp {^# CTCPanelObjects$} "$line"] > 0} {break}
      }
      set buffer {}
      while {[gets $fp line] >= 0} {
#	puts stderr "*** $type open (reading CTCPanelObjects): line = '$line'"
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
      set mode {}
      while {$mode ne "EOF"} {
	while {[gets $fp line] >= 0} {
	  if {[regexp {^# CMRIBoards$} "$line"] > 0} {set mode CMRIBoards;break}
	  if {[regexp {^# MRD Nodes$} "$line"] > 0} {set mode MRDNodes;break}
	  if {[regexp {^# Add User code after this line$} "$line"] > 0} {
	    set mode UserCode
	    break;
	  }
	  set mode EOF
	}
#	puts stderr "*** $type open: mode is $mode"
	switch $mode {
	  CMRIBoards {
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
	  }
	  MRDNodes {
	    set buffer {}
	    while {[gets $fp line] >= 0} {
	      append buffer "$line"
	      if {[info complete "$buffer"] && 
		  ![string equal "\\" "[string index $buffer end]"]} {
#		puts stderr "*** $type open: (MRDNodes branch) buffer = '$buffer'"
		if {[regexp {^MRD[[:space:]]([[:alpha:]][[:alnum:]_.-]*)[[:space:]](0[[:digit:]]*)$} $buffer => name serial] > 0} {
#		  puts stderr "*** $type open: \$newWindow setmrdnode $name $serial"
		  $newWindow setmrdnode $name $serial
		} else {
		  break
		}
		set buffer {}
	      } else {
		append buffer "\n"
	      }
	    }
	  }
	  EOF {break}
	  UserCode -
	  default {
	    set code {}
	    set nl {}
	    while {[gets $fp line] >= 0} {
	      append code "$nl$line"
	      set nl "\n"
	    }
	    set mode EOF
	  }
	}
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
	error [_ "No such board: %s" $board]
      } else {
	return "$value"
      }
    }
    method cmrinodelist {} {
      return [array names cmrinodes]
    }

    method setmrdnode {name serial} {
      set mrdnodes($name) "$serial"
    }
    method getmrdnode {name} {
      if {[catch {set mrdnodes($name)} serial]} {
	error [_ "No such node: %s" $name]
      } else {
	return "$serial"
      }
    }
    method mrdnodelist {} {
      return [array names mrdnodes]
    }

    typecomponent newDialog
    typecomponent  new_nameLE
    typecomponent  new_widthLSB
    typecomponent  new_heightLSB
    typecomponent  new_hascmriLCB
    typecomponent  new_cmriportLCB
    typecomponent  new_cmrispeedLCB
    typecomponent  new_cmriretriesLSB
    typecomponent  new_hasmrdLCB
    typecomponent  new_simpleModeCB
    typevariable   _simpleMode no

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
      set imageIcon [image create photo \
			-file [file join $::ImageDir largeImage.gif]]
      set _exportdialog {}
    }
    typemethod createnewDialog {} {
      if {![string equal "$newDialog" {}] && [winfo exists $newDialog]} {return}
      set newDialog [Dialog::create .newCTCPanelWindowDialog \
			-bitmap questhead -default 0 \
			-cancel 1 -modal local -transient yes -parent . \
			-side bottom -title [_ "New CTCPanel"]]
      $newDialog add -name create -text [_m "Button|Create"] -command [mytypemethod _NewCreate]
      $newDialog add -name cancel -text [_m "Button|Cancel"] -command [mytypemethod _NewCancel]
      wm protocol [winfo toplevel $newDialog] WM_DELETE_WINDOW [mytypemethod _NewCancel]
      $newDialog add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Creating a new CTC Panel}}
      set frame [Dialog::getframe $newDialog]
      set lwidth [_mx "Label|Name:" "Label|Width:" "Label|Height:" \
		      "Label|Has CM/RI?" "Label|CM/RI Port:" \
		      "Label|CM/RI Speed:" "Label|CM/RI Retries:"]
      set new_nameLE [LabelEntry::create $frame.nameLE -label [_m "Label|Name:"] \
						   -labelwidth $lwidth\
						   -text {Unnamed}]
      pack $new_nameLE -fill x
      set new_widthLSB [LabelSpinBox::create $frame.widthLSB -label [_m "Label|Width:"] \
						   -labelwidth $lwidth \
						   -range {780 1000 10}]
      pack $new_widthLSB -fill x
      set new_heightLSB [LabelSpinBox::create $frame.heightLSB -label [_m "Label|Height:"] \
						   -labelwidth $lwidth \
						   -range {550 800 10}]
      pack $new_heightLSB -fill x
      set new_simpleModeCB [checkbutton $frame.simpleModeCB \
					-text [_m "Label|Simple Mode"] \
					-indicatoron yes \
					-offvalue no -onvalue yes \
					-command [mytypemethod togglesimplemode] \
					-justify left -anchor w \
					-variable [mytypevar _simpleMode]]
      pack $new_simpleModeCB -fill x -expand yes
      set new_hascmriLCB [LabelComboBox::create $frame.hascmriLCB \
						   -label [_m "Label|Has CM/RI?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no]
      $new_hascmriLCB setvalue last
      pack $new_hascmriLCB -fill x
      set new_cmriportLCB [LabelComboBox::create $frame.cmriportLCB \
						   -label [_m "Label|CM/RI Port:"] \
						   -labelwidth $lwidth \
						   -values {/dev/ttyS0 
							    /dev/ttyS1 
							    /dev/ttyS2 
							    /dev/ttyS3}]
      pack $new_cmriportLCB -fill x
      $new_cmriportLCB setvalue first
      set new_cmrispeedLCB [LabelComboBox::create $frame.cmrispeedLCB \
						   -label [_m "Label|CM/RI Speed:"] \
						   -labelwidth $lwidth \
						   -values {4800 9600 19200}]
      pack $new_cmrispeedLCB -fill x
      $new_cmrispeedLCB setvalue @1
      set new_cmriretriesLSB [LabelSpinBox::create $frame.cmriretriesLSB \
						   -label [_m "Label|CMR/I Retries:"] \
						   -labelwidth $lwidth \
						   -range {5000 20000 100}]
      pack $new_cmriretriesLSB -fill x
      $new_cmriretriesLSB configure -text 10000
      set new_hasmrdLCB [LabelComboBox::create $frame.hasmrdLCB \
						   -label [_m "Label|Has MRD?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no]
      $new_hasmrdLCB setvalue last
      pack $new_hasmrdLCB -fill x
    }
    typemethod togglesimplemode {} {
      if {$_simpleMode} {
	foreach w {new_hascmriLCB new_cmriportLCB new_cmrispeedLCB 
		   new_cmriretriesLSB new_hasmrdLCB} {
	  [set $w] configure -state disabled
	}
        $new_hasmrdLCB setvalue first
      } else {
	foreach w {new_hascmriLCB new_cmriportLCB new_cmrispeedLCB 
		   new_cmriretriesLSB new_hasmrdLCB} {
	  [set $w] configure -state normal
	}
        $new_hasmrdLCB setvalue last
      }
    }
    typemethod new {args} {
      set _simpleMode [from args -simplemode no]
      $type createnewDialog 
      set parent [from args -parent .]
      $newDialog configure -parent $parent
      $type togglesimplemode
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
    proc converttobool {value} {
      if {"$value" eq [_m "Answer|yes"]} {
	return yes
      } else {
	return no
      }
    }
    typemethod _NewCreate {} {
      $newDialog withdraw
      if {$_simpleMode} {
	$type create .ctcpanel%AUTO% -name "[$new_nameLE cget -text]" \
				     -width [$new_widthLSB cget -text] \
				     -height [$new_heightLSB cget -text] \
				     -hascmri 0 \
				     -cmriport /dev/ttyS0 \
				     -cmrispeed 9600 \
				     -cmriretries 10000 \
				     -hasmrd 1 \
				     -simplemode yes
      } else {
	$type create .ctcpanel%AUTO% -name "[$new_nameLE cget -text]" \
				     -width [$new_widthLSB cget -text] \
				     -height [$new_heightLSB cget -text] \
				     -hascmri [converttobool [$new_hascmriLCB cget -text]] \
				     -cmriport [$new_cmriportLCB cget -text] \
				     -cmrispeed [$new_cmrispeedLCB cget -text] \
				     -cmriretries [$new_cmriretriesLSB cget -text] \
				     -hasmrd [converttobool [$new_hasmrdLCB cget -text]] \
				     -simplemode no
      }
      
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
				-parent . -side bottom -title [_ "Select Panel"]]
      $selectPanelDialog add -name create -text [_m "Button|Select"] \
					  -command [mytypemethod _SelectPanel]
      $selectPanelDialog add -name cancel -text [_m "Button|Cancel"] \
					  -command [mytypemethod _SelectCancel]
      wm protocol [winfo toplevel $selectPanelDialog] WM_DELETE_WINDOW \
				[mytypemethod _SelectCancel]
      $selectPanelDialog add -name help -text [_m "Button|Help"] \
			     -command {HTMLHelp::HTMLHelp help {Select Panel Dialog}}
      set frame [Dialog::getframe $selectPanelDialog]
      set lwidth [_mx "Label|Name:"]
      set selectPanel_nameLCB [LabelComboBox $frame.nameLCB \
					-label [_m "Label|Name:"] \
					-labelwidth $lwidth\
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
	  tk_messageBox -type ok -icon warning -parent $win \
			-message [_ "Please create a panel first"]
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
	  puts stderr "*** $type addtrackworknodetopanel: [$node TypeOfNode]"
	  switch [$node TypeOfNode] {
	    TrackGraph::Block {
	     eval [list $panel addblocktopanel $node \
					-name [$node NameOfNode] \
					-occupiedcommand [$node SenseScript]] \
		  $args
	    }
	    TrackGraph::SwitchMotor {
	      set tn [[$node info type] FindNode [$node TurnoutNumber]]
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
    component addMRDNodeDialog
    component selectMRDNodeDialog
    component editUserCodeDialog

    method buildDialogs {} {

      install addPanelObjectDialog using CTCPanelWindow::AddPanelObjectDialog $win.addPanelObjectDialog -parent $win -ctcpanel $ctcpanel
      install selectPanelObjectDialog using CTCPanelWindow::SelectPanelObjectDialog $win.selectPanelObjectDialog -parent $win -ctcpanel $ctcpanel
      install configurePanelDialog using CTCPanelWindow::ConfigurePanelDialog $win.configurePanelDialog -parent $win
      install addCMRINodeDialog using CTCPanelWindow::AddCMRINodeDialog $win.addCMRINodeDialog -parent $win
      install selectCMRINodeDialog using CTCPanelWindow::SelectCMRINodeDialog $win.selectCMRINodeDialog -parent $win
      install addMRDNodeDialog using CTCPanelWindow::AddMRDNodeDialog $win.addMRDNodeDialog -parent $win
      install selectMRDNodeDialog using CTCPanelWindow::SelectMRDNodeDialog $win.selectMRDNodeDialog -parent $win
      install editUserCodeDialog  using CTCPanelWindow::EditUserCodeDialog $win.editUserCodeDialog -parent $win
    }

    method addblocktopanel {node args} {
#      puts stderr "*** $self addblocktopanel $node $args"
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -mode add -setoftypes {StraightBlock CurvedBlock HiddenBlock StubYard ThroughYard EndBumper}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addsimpleturnouttopanel {node args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -mode add -setoftypes {Switch}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addcomplextrackworktopanel {node args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -mode add -setoftypes {ScissorCrossover Crossover Crossing SingleSlip DoubleSlip ThreeWaySW}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
    }
    method addswitchplatetopanel {args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -mode add -setoftypes {SWPlate}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
      set objectType [lindex $result 0]
      set name       [lindex $result 1]
      if {$options(-simplemode) && 
	  ("$objectType" eq "SWPlate" || "$objectType" eq "SIGPlate")} {
	set initPlateCode {}
	append initPlateCode "#Initialize $name START\n"
	append initPlateCode "MainWindow ctcpanel seti $name C on\n"
	append initPlateCode "#Initialize $name END\n"
	if {[regexp -line -indices {(^# Main Loop Start$)} "$userCode" -> start] > 0} {
	  set userCode [string replace "$userCode" [lindex $start 0] [lindex $start 0] "$initPlateCode#"]
	} else {
	  append userCode "$initPlateCode"
	}
      }
    }
    method addpanelobject {args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -mode add -setoftypes {}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      eval [list $ctcpanel create] $result
      set objectType [lindex $result 0]
      set name       [lindex $result 1]
      if {$options(-simplemode) && 
	  ("$objectType" eq "SWPlate" || "$objectType" eq "SIGPlate")} {
	set initPlateCode {}
	append initPlateCode "#Initialize $name START\n"
	append initPlateCode "MainWindow ctcpanel seti $name C on\n"
	append initPlateCode "#Initialize $name END\n"
	if {[regexp -line -indices {(^# Main Loop Start$)} "$userCode" -> start] > 0} {
	  set userCode [string replace "$userCode" [lindex $start 0] [lindex $start 0] "$initPlateCode#"]
	} else {
	  append userCode "$initPlateCode"
	}
      }
    }
    method editpanelobject {args} {
      set objectToEdit [eval [list $selectPanelObjectDialog draw] $args]
      if {[string equal "$objectToEdit" {}]} {return}
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -mode edit -object $objectToEdit] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      $ctcpanel delete $objectToEdit
      eval [list $ctcpanel create] $result
    }
    method deletepanelobject {args} {
      set objectToDelete [eval [list $selectPanelObjectDialog draw] $args]
      if {[string equal "$objectToDelete" {}]} {return}
      if {[tk_messageBox -type yesno -icon question \
			 -message [_ "Really delete $objectToDelete?"] \
			 -parent $win]} {
        set objectType [$ctcpanel class $objectToDelete]
	$ctcpanel delete $objectToDelete
	if {$options(-simplemode) && 
	    ("$objectType" eq "SWPlate" || "$objectType" eq "SIGPlate")} {
	  set startPattern "(^#Initialize $objectToDelete START\$)"
	  set endPattern "(^#Initialize $objectToDelete END\$)"
	  #puts stderr "*** $self deletepanelobject: startPattern = \{$startPattern\}"
	  #puts stderr "*** $self deletepanelobject: endPattern = \{$endPattern\}"
	  #puts stderr "*** $self deletepanelobject: userCode (before) = \{$userCode\}"
	  if {[regexp -line -indices $startPattern "$userCode" -> start] > 0 &&
	      [regexp -line -indices $endPattern "$userCode" -> end] > 0} {
	    #puts stderr "*** $self deletepanelobject: start is $start, end is $end"
	    set userCode [string replace "$userCode" [lindex $start 0] [lindex $end 1] ""]
	    #puts stderr "*** $self deletepanelobject: userCode (after) = \{$userCode\}"
	  }
	}
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
			-message [_ "Really delete $nodeToDelete?"] \
			-parent $win]} {
	unset cmrinodes($nodeToDelete)
	$self setdirty
      }
    }
    ##### MRD methods
    method addmrdnode {args} {
      set result [eval [list $addMRDNodeDialog draw -mode add] $args]
      if {[string equal "$result" {}]} {return}
      set node [lindex $result 0]
      set serial [lindex $result 1]
      set mrdnodes($node) $serial
      $self setdirty
    }
    method editmrdnode {args} {
      set nodeToEdit [eval [list $selectMRDNodeDialog draw] $args]
      if {[string equal "$nodeToEdit" {}]} {return}
      set result [eval [list $addMRDNodeDialog draw -mode edit -node $nodeToEdit] $args]
      if {[string equal "$result" {}]} {return}
      set node [lindex $result 0]
      set serial [lindex $result 1]
      set mrdnodes($node) $serial
      $self setdirty
    }
    method deletemrdnode {args} {
      set nodeToDelete [eval [list $selectMRDNodeDialog draw] $args]
      if {[string equal "$nodeToDelete" {}]} {return}
      if {[tk_messageBox -type yesno -icon question \
			-message [_ "Really delete $nodeToDelete?"] \
			-parent $win]} {
	unset mrdnodes($nodeToDelete)
	$self setdirty
      }
    }
    method AddModule {modname} {
#      puts stderr "*** $self AddModule $modname"
      set startPattern "^#\\* ${modname}:START \\*\$"
      set endPattern "^#\\* ${modname}:END \\*\$"
#      puts stderr "*** $self AddModule: startPattern = '$startPattern', endPattern = '$endPattern'"
      set userCodeModulesFp [open [file join "$CodeLibraryDir" \
					     userCodeModules.tcl] r]
      while {[gets $userCodeModulesFp line] >= 0} {
	if {[regexp "$startPattern" "$line"] > 0} {break}
      }
      set moduleBuffer "${line}\n"
      set startLinePattern "^[regsub -all {\*} $line {\\*}]\$"
      if {![eof $userCodeModulesFp]} {
	while {[gets $userCodeModulesFp line] >= 0} {
	  if {[regexp "$endPattern" "$line"] > 0} {break}
	  append moduleBuffer "${line}\n"
	}
      }
      append moduleBuffer "${line}\n"
      set endLinePattern "^[regsub -all {\*} $line {\\*}]\$"
      close $userCodeModulesFp
#      puts stderr "*** $self AddModule: moduleBuffer = '$moduleBuffer'"
      if {[string length "$moduleBuffer"] > 0} {
	if {[regexp -line -indices $startLinePattern "$userCode" -> start] > 0 &&
	    [regexp -line -indices $endLinePattern "$userCode" -> end] > 0} {
	  set userCode [string replace "$userCode" [lindex $start 0] [lindex $end 1] "$moduleBuffer"]
	} else {
	  set userCode "${moduleBuffer}\n${userCode}"
	}
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
      if {$options(-hasmrd)} {
	append loop "  # Read all MRD state data\n"
	foreach node [array names mrdnodes] {
	  append loop "  $node GetStateData\n"
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
	  tk_messageBox -type ok -icon error  \
			-parent $win \
			-message [_ "Could not create tempfile: %s" $fp]
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
    option -simplemode -default no


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
    component   endBumperRB;#		End bumper track segment
    component   curvedBlockRB;#		Curved track segment
    component   hiddenBlockRB;#		Hidden track segment (bridge, tunnel)
    component   stubYardRB;#		Stub yard
    component   throughYardRB;#		Through yard
    component   crossingRB;#		Crossing
    component   switchRB;#		Simple switch (turnout)
    component   scissorCrossoverRB;#	Scissor Crossover
    component   crossoverRB;#		Crossover
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
    # Simple mode features for Switch Plates
    component mrdSerialNumberLE;#	MRD2-U serial number (SWitch Plates in simple mode)
    component switchNameLE;#		Trackwork controlled by this switch plate
    #
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
	EndBumper {xysch label position orientation occupiedcommand}
	CurvedBlock {xy1sch xy2sch radius label position occupiedcommand}
	ScissorCrossover {xysch label orientation flipped statecommand 
			  occupiedcommand}
	Crossover {xysch label orientation flipped statecommand 
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
				-side bottom -title [_ "Add Panel Object to panel"] \
				-parent [from args -parent]
      $hull add -name add    -text Add    -command [mymethod _Add]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name redraw -text Redraw -command [mymethod redrawgraphic]
      $hull add -name help -text Help -command {HTMLHelp::HTMLHelp help {Add Panel Object Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Control Point:" "Label|Radius:" \
		      "Label|Label:" "Label|Position:" "Label|Orientation:" \
		      "Label|Flipped?" "Label|Heads:" "Label|Crossing Type:" \
		      "Label|Left Label:" "Label|Center Label:" \
		      "Label|Right Label:" "Label|Has Center Position?" \
		      "Label|Color:" "Label|Occupied Script:" \
		      "Label|State Script:" "Label|Normal Script:" \
		      "Label|Reverse Script:" "Label|Left Script:" \
		      "Label|Center Script:" "Label|Right Script:" \
		      "Label|Action Script:" "Label|MRD2-U S#:" \
		      "Label|Switch Name:"]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $nameLE -fill x
      install objectTypeTF using TitleFrame $frame.objectTypeTF -side left \
				-text [_m "Label|Object Type"]
      pack $objectTypeTF -fill both
      set otframe [$objectTypeTF getframe]
      set row 0
      foreach {rb0 rb1 rb2 rb3 rb4} {sWPlateRB sIGPlateRB codeButtonRB toggleRB pushButtonRB lampRB cTCLabelRB straightBlockRB endBumperRB curvedBlockRB hiddenBlockRB stubYardRB throughYardRB crossingRB switchRB scissorCrossoverRB crossoverRB singleSlipRB doubleSlipRB threeWaySWRB signalRB schLabelRB} {
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
						-label [_m "Label|Control Point:"] \
						-labelwidth $lwidth
      pack $controlPointLCB -fill x
      install optionsFrame using frame $frame.optionsFrame -borderwidth 0 \
							   -relief flat
      pack $optionsFrame -expand yes -fill both
      install xyframe1 using TitleFrame $optionsFrame.xyframe1 -side left \
						    -text [_m "Label|First Coord"]
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
						-text [_m "Button|Use Crosshairs"]
      pack $b1 -side right
      install xyframe2 using TitleFrame $optionsFrame.xyframe2 -side left \
						    -text [_m "Label|Second Coord"]
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
						-text [_m "Button|Use Crosshairs"]
      pack $b2 -side right
      install radiusLSB using LabelSpinBox $optionsFrame.radiusLSB \
						-label [_m "Label|Radius:"] \
						-labelwidth $lwidth \
						-range {1 250 1}
      install labelLE using LabelEntry $optionsFrame.labelLE -label [_m "Label|Label:"] \
						      -labelwidth $lwidth
      install positionLCB using LabelComboBox $optionsFrame.positionLCB \
						-label [_m "Label|Position:"] \
						-labelwidth $lwidth \
						-editable no \
						-values {below above right left} \
						-modifycmd [mymethod redrawgraphic]
      $positionLCB setvalue first
      install orientationLCB using LabelComboBox $optionsFrame.orientationLCB \
						-label [_m "Label|Orientation:"] \
						-labelwidth $lwidth \
						-values {0 1 2 3 4 5 6 7} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $orientationLCB setvalue first
      install hvorientationLCB using LabelComboBox $optionsFrame.hvorientationLCB \
						-label [_m "Label|Orientation:"] \
						-labelwidth $lwidth \
						-values {horizontal vertical} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $hvorientationLCB setvalue first
      install flippedLCB using LabelComboBox $optionsFrame.flippedLCB \
						-label [_m "Label|Flipped?"] \
						-labelwidth $lwidth \
						-values {no yes} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $flippedLCB setvalue first
      install headsLCB using LabelComboBox $optionsFrame.headsLCB \
						-label [_m "Label|Heads:"] \
						-labelwidth $lwidth \
						-values {1 2 3} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $headsLCB setvalue first
      install typeLCB using LabelComboBox $optionsFrame.typeLCB \
						-label [_m "Label|Crossing Type:"] \
						-labelwidth $lwidth \
						-values {x90 x45} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $typeLCB setvalue first
      install leftlabelLE using LabelEntry $optionsFrame.leftlabelLE \
						-label [_m "Label|Left Label:"] \
						-labelwidth $lwidth
      install centerlabelLE using LabelEntry $optionsFrame.centerlabelLE \
						-label [_m "Label|Center Label:"] \
						-labelwidth $lwidth
      install rightlabelLE using LabelEntry $optionsFrame.rightlabelLE \
						-label [_m "Label|Right Label:"] \
						-labelwidth $lwidth
      install hascenterLCB using LabelComboBox $optionsFrame.hascenterLCB \
						-label [_m "Label|Has Center Position?"] \
						-labelwidth $lwidth \
						-values {no yes} \
						-editable no \
						-modifycmd [mymethod redrawgraphic]
      $hascenterLCB setvalue first
      install colorLSC using LabelSelectColor $optionsFrame.colorLSC \
						      -label [_m "Label|Color:"] \
						      -labelwidth $lwidth \
						      -text white
      install mrdSerialNumberLE using LabelEntry $optionsFrame.mrdSerialNumberLE \
						-label [_m "Label|MRD2-U S#:"] \
						-labelwidth $lwidth
      install switchNameLE using LabelEntry $optionsFrame.switchNameLE \
						-label [_m "Label|Switch Name:"] \
						-labelwidth $lwidth
      install occupiedcommandLF using LabelFrame $optionsFrame.occupiedcommandLF \
						-text [_m "Label|Occupied Script:"] \
						-width $lwidth
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
						-text [_m "Label|State Script:"] \
						-width $lwidth
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
						-text [_m "Label|Normal Script:"] \
						-width $lwidth
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
						-text [_m "Label|Reverse Script:"] \
						-width $lwidth
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
						-text [_m "Label|Left Script:"] \
						-width $lwidth
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
						-text [_m "Label|Center Script:"] \
						-width $lwidth
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
						-text [_m "Label|Right Script:"] \
						-width $lwidth
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
						-text [_m "Label|Action Script:"] \
						-width $lwidth
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
	    error [_ "Internal Error - no object selected!"]
	  }
	  if {![$options(-ctcpanel) exists "$options(-object)"]} {
	    error [_ "Internal Error - no object selected!"]
	  }
	  $nameLE configure -text "$options(-object)" -editable no
	  $controlPointLCB configure -text [$options(-ctcpanel) itemcget $options(-object) -controlpoint]
	  set objectType [$options(-ctcpanel) class "$options(-object)"]
	  set options(-setoftypes) [list $objectType]
#	  puts stderr "*** $self draw: objectType = $objectType"
#	  puts stderr "*** $self draw: options(-object) = '$options(-object)'"
	  $self packAndConfigureOptions $objectType
	  $hull itemconfigure add -text [_m "Button|Update"]
	  $hull configure -title [_ "Edit Panel Object"]
	}
	add -
	default {
	  if {[llength "$options(-setoftypes)"] == 0} {set options(-setoftypes) [array names objectTypeOptions]}
	  $nameLE configure -editable yes
	  if {[lsearch "$options(-setoftypes)" $objectType] < 0} {
	    set objectType [lindex $options(-setoftypes) 0]
	  }
	  $self packOptions $objectType
	  $hull itemconfigure add -text [_m "Button|Add"]
	  $hull configure -title [_ "Add Panel Object to panel"]
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
      if {[lsearch -exact $objectTypeOptions($objectType) radius] >= 0} {
	if {[$self doRangeCheck]} {
	  tk_messageBox -type ok -icon warning -parent $win \
		-message [_ "Range check warning.  Radius value adjusted."]
	}
      }
      set opts {}
      $self getOptions opts
#      puts stderr "*** $self redrawgraphic: opts is $opts"
      eval [list ::CTCPanel::$objectType create %AUTO% $self $graphicCanvas -controlpoint nil] $opts
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
		$xyframe1 configure -text [_m "Label|First Coord"]
		$b1 configure -command [mymethod _chschXY1]
	  }
	  xy2sch {
		pack $xyframe2 -fill x
		$xyframe2 configure -text [_m "Label|Second Coord"]
		$b2 configure -command [mymethod _chschXY2]
	  }
	  label {
		pack $labelLE -fill x
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
#      puts stderr "*** $self packAndConfigureOptions: options(-simplemode) is $options(-simplemode)"
      if {$options(-simplemode) && $objtype eq "SWPlate"} {
	pack $mrdSerialNumberLE -fill x
	$mrdSerialNumberLE configure -text ""
	pack $switchNameLE -fill x
	$switchNameLE configure -text ""
      }
      foreach opt $objectTypeOptions($objtype) {
	switch -exact $opt {
	  normalcommand {
		pack $normalcommandLF -fill x
		if {$options(-simplemode)} {
		  $normalcommandText configure -state disabled
		} else {
		  $normalcommandText configure -state normal
		}
	  }
	  reversecommand {
		pack $reversecommandLF -fill x
		if {$options(-simplemode)} {
		  $reversecommandText configure -state disabled
		} else {
		  $reversecommandText configure -state normal
		}
	  }
	  leftcommand {
		pack $leftcommandLF -fill x
		if {$options(-simplemode)} {
		  $leftcommandText  configure -state disabled
		} else {
		  $leftcommandText  configure -state normal
		}
	  }
	  centercommand {
		pack $centercommandLF -fill x
		if {$options(-simplemode)} {
		  $centercommandText  configure -state disabled
		} else {
		  $centercommandText  configure -state normal
		}
	  }
	  rightcommand {
		pack $rightcommandLF -fill x
		if {$options(-simplemode)} {
		  $rightcommandText  configure -state disabled
		} else {
		  $rightcommandText  configure -state normal
		}
	  }
	  command {
		pack $commandLF -fill x
		if {$options(-simplemode)} {
		  $commandText  configure -state disabled
		} else {
		  $commandText  configure -state normal
		}
	  }
	  statecommand {
		pack $statecommandLF -fill x
		if {$options(-simplemode)} {
		  $statecommandText  configure -state disabled
		} else {
		  $statecommandText  configure -state normal
		}
	  }
	  occupiedcommand {
		pack $occupiedcommandLF -fill x
		if {$options(-simplemode)} {
		  $occupiedcommandText  configure -state disabled
		} else {
		  $occupiedcommandText  configure -state normal
		}
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
	}
      }	
#      puts stderr "*** $self packAndConfigureOptions: options(-simplemode) is $options(-simplemode)"
      if {$options(-simplemode) && $objtype eq "SWPlate"} {
	set command "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
	set switch {}
	set mrdsn  {}
	regexp {Normal[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => switch mrdsn
	pack $mrdSerialNumberLE -fill x
	$mrdSerialNumberLE configure -text "$mrdsn"
	pack $switchNameLE -fill x
	$switchNameLE configure -text "$switch"
      }
      foreach opt $objectTypeOptions($objtype) {
	switch -exact $opt {
	  normalcommand {
		pack $normalcommandLF -fill x
		$normalcommandText delete 1.0 end
		$normalcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
		if {$options(-simplemode)} {
		  $normalcommandText configure -state disabled
		} else {
		  $normalcommandText configure -state normal
		}
	  }
	  reversecommand {
		pack $reversecommandLF -fill x
		$reversecommandText delete 1.0 end
		$reversecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -reversecommand]"
		if {$options(-simplemode)} {
		  $reversecommandText configure -state disabled
		} else {
		  $reversecommandText configure -state normal
		}
	  }
	  leftcommand {
		pack $leftcommandLF -fill x
		$leftcommandText delete 1.0 end
		$leftcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -leftcommand]"
		if {$options(-simplemode)} {
		  $leftcommandText  configure -state disabled
		} else {
		  $leftcommandText  configure -state normal
		}
	  }
	  centercommand {
		pack $centercommandLF -fill x
		$centercommandText delete 1.0 end
		$centercommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -centercommand]"
		if {$options(-simplemode)} {
		  $centercommandText  configure -state disabled
		} else {
		  $centercommandText  configure -state normal
		}
	  }
	  rightcommand {
		pack $rightcommandLF -fill x
		$rightcommandText delete 1.0 end
		$rightcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -rightcommand]"
		if {$options(-simplemode)} {
		  $rightcommandText  configure -state disabled
		} else {
		  $rightcommandText  configure -state normal
		}
	  }
	  command {
		pack $commandLF -fill x
		$commandText delete 1.0 end
		$commandText insert end "[$options(-ctcpanel) itemcget $options(-object) -command]"
		if {$options(-simplemode)} {
		  $commandText  configure -state disabled
		} else {
		  $commandText  configure -state normal
		}
	  }
	  statecommand {
		pack $statecommandLF -fill x
		$statecommandText delete 1.0 end
		$statecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -statecommand]"
		if {$options(-simplemode)} {
		  $statecommandText  configure -state disabled
		} else {
		  $statecommandText  configure -state normal
		}
	  }
	  occupiedcommand {
		pack $occupiedcommandLF -fill x
		$occupiedcommandText delete 1.0 end
		$occupiedcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -occupiedcommand]"
		if {$options(-simplemode)} {
		  $occupiedcommandText  configure -state disabled
		} else {
		  $occupiedcommandText  configure -state normal
		}
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
	  tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $name]
	  return
	}
	if {[lsearch -exact [$options(-ctcpanel) objectlist] "$name"] >= 0} {
	  tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Name '%s' already in use.  Pick another." $name]
	  return
	}
      }
      set cp "[$controlPointLCB cget -text]"
      if {![$self _CheckNameChars "$cp"]} {
	tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Illegal characters in control point, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $cp]
	return
      }
      if {$options(-simplemode) && $objectType eq "SWPlate"} {
	set swname "[$switchNameLE cget -text]"
	if {![$self _CheckNameChars "$name"]} {
	  tk_messageBox -type ok -icon error -parent $win \
		-message [_ "Illegal characters in switch name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $swname]
	  return
	}
	set mrdsn  "[$mrdSerialNumberLE cget -text]"
	if {![string is digit -strict $mrdsn]} {
	  tk_messageBox -type ok -icon error -parent $win \
		-message [_ "Illegal characters in MRD2-U serial number, must be all digits, got '%s'" $mrdsn]
	  return
	}
      }
      if {[lsearch -exact $objectTypeOptions($objectType) radius] >= 0} {
	if {[$self doRangeCheck]} {
	  tk_messageBox -type ok -icon warning -parent $win \
		-message [_ "Range check warning.  Radius value adjusted."]
	  return
	}
      }
      $hull withdraw
      lappend result "$objectType" "$name"
      lappend result -controlpoint "$cp"
      $self getOptions result
      return [$hull enddialog "$result"]
    }
    method doRangeCheck {} {
      $graphicCanvas delete all
      set opts {}
      $self getOptions opts
#      puts stderr "*** $self doRangeCheck: opts is $opts"
      if {[catch {eval [list ::CTCPanel::$objectType create %AUTO% $self $graphicCanvas -controlpoint nil] $opts} error]} {
#	puts stderr "*** $self doRangeCheck: error is '$error'"
	if {[string first {Range error: } "$error"] >= 0} {
	  set radius [from opts -radius]
	  set x1 [from opts -x1]
	  set x2 [from opts -x2]
	  set y1 [from opts -y1]
	  set y2 [from opts -y2]
	  set dx [expr {int(abs($x2 - $x1))}]
	  set dy [expr {int(abs($y2 - $y1))}]
#	  puts stderr "*** $self doRangeCheck: (1) radius=$radius, x1=$x1, x2=$x2, y1=$y1, y2=$y2, dx=$dx, dy=$dy"
	  if {$dx < 10} {
	    $x2LSB configure -text [expr {$x1 + 10}]
	    update idle
	    set x2 [$x2LSB cget -text]
	    set dx [expr {int(abs($x2 - $x1))}]
	  }
	  if {$dy < 10} {
	    $y2LSB configure -text [expr {$y1 + 10}]
	    update idle
	    set y2 [$y2LSB cget -text]
	    set dy [expr {int(abs($y2 - $y1))}]
	  }
#	  puts stderr "*** $self doRangeCheck: (2) radius=$radius, x1=$x1, x2=$x2, y1=$y1, y2=$y2, dx=$dx, dy=$dy"
	  if {$dx < $dy} {
	    $radiusLSB configure -text $dx
	  } else {
	    $radiusLSB configure -text $dy
	  }
#	  puts stderr "*** $self doRangeCheck: \[$radiusLSB cget -text\] = [$radiusLSB cget -text]"
#	  puts stderr "*** $self doRangeCheck: range error, radius adjusted."
	  return 1
	} else {
#	  puts stderr "*** $self doRangeCheck: some other error, punting."
	  error "$error" $::errorInfo $::errorCode
	}
#	puts stderr "*** $self doRangeCheck: some error handled."
      }
#      puts stderr "*** $self doRangeCheck: not a range error."
      return 0
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
		if {$options(-simplemode) && $objectType eq "SWPlate"} {
		  set normcommand [list SimpleMode::Normal [$nameLE cget -text] [$switchNameLE cget -text] [$mrdSerialNumberLE cget -text]]
		  lappend result -normalcommand $normcommand
		} else {
		  lappend result -normalcommand "[$normalcommandText get 1.0 end-1c]"
		}
	  }
	  reversecommand {
		if {$options(-simplemode) && $objectType eq "SWPlate"} {
		  set revcommand [list SimpleMode::Reverse [$nameLE cget -text] [$switchNameLE cget -text] [$mrdSerialNumberLE cget -text]]
		  lappend result -reversecommand $revcommand
		} else {
		  lappend result -reversecommand "[$reversecommandText get 1.0 end-1c]"
		}
	  }
	  leftcommand {
		if {$options(-simplemode) && $objectType eq "SIGPlate"} {
		  set leftcommand [list SimpleMode::Left [$nameLE cget -text]]
		  lappend result -leftcommand "$leftcommand"
		} else {
		  lappend result -leftcommand "[$leftcommandText get 1.0 end-1c]"
		}
	  }
	  centercommand {
		if {$options(-simplemode) && $objectType eq "SIGPlate"} {
		  set centercommand [list SimpleMode::Center [$nameLE cget -text]]
		  lappend result -centercommand "$centercommand"
		} else {
		  lappend result -centercommand "[$centercommandText get 1.0 end-1c]"
		}
	  }
	  rightcommand {
		if {$options(-simplemode) && $objectType eq "SIGPlate"} {
		  set rightcommand [list SimpleMode::Right [$nameLE cget -text]]
		  lappend result -rightcommand "$rightcommand"
		} else {
		  lappend result -rightcommand "[$rightcommandText get 1.0 end-1c]"
		}
	  }
	  command {
		if {$options(-simplemode) && $objectType eq "CodeButton"} {
		  set command [list SimpleMode::CodeButton "[$controlPointLCB cget -text]"]
		  lappend result -command $command
		} else {
		  lappend result -command "[$commandText get 1.0 end-1c]"
		}
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
				-side bottom -title [_ "Select Panel Object"] \
				-parent [from args -parent]
      $hull add -name select -text [_m "Button|Select"] -command [mymethod _Select]
      $hull add -name find   -text [_m "Button|Find"]   -command [mymethod _Find]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Select Panel Object Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Pattern:" "Label|Selection:"]
      install namePatternLE using LabelEntry $frame.namePatternLE \
					-label [_m "Label|Pattern:"] \
					-labelwidth $lwidth \
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
					-label [_m "Label|Selection:"] \
					-labelwidth $lwidth
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
	tk_messageBox -type ok -icon warning \
			 -parent $win \
			 -message [_ "No such object: %s" [$selectedNameLE cget -text]]
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
    component simpleModeCB;#		-simplemode
    component hascmriLCB;#		-hascmri
    component cmriportLCB;#		-cmriport
    component cmrispeedLCB;#		-cmrispeed
    component cmriretriesLSB;#		-cmriretries
    component hasmrdLCB;#		-hasmrd
    variable _simpleMode no
    
    constructor {args} {
#      puts stderr "*** $type create $self $args"
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title [_ "Edit Panel Options"] \
				-parent [from args -parent]
      $hull add -name update -text [_m "Button|Update"] -command [mymethod _Update]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Configuring CTC Panel Windows}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Width:" "Label|Height:" \
		      "Label|Has CM/RI?" "Label|CM/RI Port:" \
		      "Label|CM/RI Speed:" "Label|CM/RI Retries:"]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -editable no
      pack $nameLE -fill x
      install widthLSB using LabelSpinBox $frame.widthLSB -label [_m "Label|Width:"] \
						   -labelwidth $lwidth \
						   -range {780 1000 10}
      pack $widthLSB -fill x
      install heightLSB using LabelSpinBox $frame.heightLSB -label [_m "Label|Height:"] \
						   -labelwidth $lwidth \
						   -range {550 800 10}
      pack $heightLSB -fill x
      install simpleModeCB using checkbutton $frame.simpleModeCB \
					-text [_m "Label|Simple Mode"] \
					-indicatoron yes \
					-offvalue no -onvalue yes \
					-command [mymethod togglesimplemode] \
					-justify left -anchor w \
					-variable [myvar _simpleMode]
      pack $simpleModeCB -fill x -expand yes
      install hascmriLCB using LabelComboBox $frame.hascmriLCB \
						   -label [_m "Label|Has CM/RI?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no
      $hascmriLCB setvalue last
      pack $hascmriLCB -fill x
      install cmriportLCB using LabelComboBox $frame.cmriportLCB \
						   -label [_m "Label|CM/RI Port:"] \
						   -labelwidth $lwidth \
						   -values {/dev/ttyS0 
							    /dev/ttyS1 
							    /dev/ttyS2 
							    /dev/ttyS3}
      pack $cmriportLCB -fill x
      $cmriportLCB setvalue first
      install cmrispeedLCB using LabelComboBox $frame.cmrispeedLCB \
						   -label [_m "Label|CM/RI Speed:"] \
						   -labelwidth $lwidth \
						   -values {4800 9600 19200}
      pack $cmrispeedLCB -fill x
      $cmrispeedLCB setvalue @1
      install cmriretriesLSB using LabelSpinBox $frame.cmriretriesLSB \
						   -label [_m "Label|CM/RI Retries:"] \
						   -labelwidth $lwidth \
						   -range {5000 20000 100}
      pack $cmriretriesLSB -fill x
      $cmriretriesLSB configure -text 10000
      install hasmrdLCB using LabelComboBox $frame.hasmrdLCB \
						   -label [_m "Label|Has MRD?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no
      $hasmrdLCB setvalue last
      pack $hasmrdLCB -fill x
      $self configurelist $args
    }
    method togglesimplemode {} {
      set parent [$hull cget -parent]
      if {$_simpleMode} {
	foreach w {hascmriLCB cmriportLCB cmrispeedLCB 
		   cmriretriesLSB hasmrdLCB} {
	  [set $w] configure -state disabled
	}
        $hasmrdLCB configure -text [backtrans [$parent cget -hasmrd]]
      } else {
	foreach w {hascmriLCB cmriportLCB cmrispeedLCB 
		   cmriretriesLSB hasmrdLCB} {
	  [set $w] configure -state normal
	}
        if {![converttobool [$hasmrdLCB cget -text]]} {
	  $hasmrdLCB setvalue last
	}
      }
    }
    proc converttobool {value} {
      if {"$value" eq [_m "Answer|yes"]} {
	return yes
      } else {
	return no
      }
    }
    proc backtrans {value} {
      if {$value} {
	return [_m "Answer|yes"]
      } else {
	return [_m "Answer|no"]
      }
    }
    method draw {args} {
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient $win [winfo toplevel $parent]
      $nameLE configure -text "[$parent cget -name]"
      $widthLSB configure -text [$parent cget -width]
      $heightLSB configure -text [$parent cget -height]
      $hascmriLCB configure -text [backtrans [$parent cget -hascmri]]
      $cmriportLCB configure -text "[$parent cget -cmriport]"
      $cmrispeedLCB configure -text [$parent cget -cmrispeed]
      $cmriretriesLSB configure -text [$parent cget -cmriretries]
      $hasmrdLCB configure -text [backtrans [$parent cget -hasmrd]]
      set _simpleMode [$parent cget -simplemode]
      if {$_simpleMode} {
	$hascmriLCB configure -state disabled
	$cmriportLCB configure -state disabled
	$cmrispeedLCB configure -state disabled
	$cmriretriesLSB configure -state disabled
	$hasmrdLCB configure -state disabled
      }
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
      lappend result -hascmri [converttobool [$hascmriLCB cget -text]]
      lappend result -cmriport "[$cmriportLCB cget -text]"
      lappend result -cmrispeed [$cmrispeedLCB cget -text]
      lappend result -cmriretries [$cmriretriesLSB cget -text]
      lappend result -hasmrd [converttobool [$hasmrdLCB cget -text]]
      lappend result -simplemode $_simpleMode
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
				-side bottom -title [_ "Add CMR/I Node to panel"] \
				-parent [from args -parent]
      $hull add -name add    -text [_m "Button|Add"]    -command [mymethod _Add]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Add CMRI Node Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Address:" "Label|Board Type:" \
		      "Label|# Yellow Signals:" "Label|# Input ports:" \
		      "Label|# Output ports:" "Label|Delay Value:" \
		      "Label|Card Type Map:" "Label|Yellow Signal Map:"]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $nameLE -fill x
      install uaLSB using LabelSpinBox $frame.uaLSB  -label [_m "Label|Address:"] \
						     -labelwidth $lwidth \
						     -range {0 127 1}
      pack $uaLSB -fill x
      install nodeTypeLCB using LabelComboBox $frame.nodeTypeLCB \
					-label [_m "Label|Board Type:"] \
					-labelwidth $lwidth \
					-values {SUSIC USIC SMINI} \
					-editable no \
					-modifycmd [mymethod _updateCTLab]
      $nodeTypeLCB setvalue first
      pack $nodeTypeLCB -fill x
      install numberYellowSigsLSB using LabelSpinBox $frame.numberYellowSigsLSB \
					-label [_m "Label|# Yellow Signals:"] \
					-labelwidth $lwidth \
					-range {0 24 1}
      pack $numberYellowSigsLSB -fill x
      install numberInputsLSB using LabelSpinBox $frame.numberInputsLSB \
					-label [_m "Label|# Input ports:"] \
					-labelwidth $lwidth \
					-range {0 1023 1}
      pack $numberInputsLSB -fill x
      install numberOutputsLSB using LabelSpinBox $frame.numberOutputsLSB \
					-label [_m "Label|# Output ports:"] \
					-labelwidth $lwidth \
					-range {0 1023 1}
      pack $numberOutputsLSB -fill x
      install delayValueLSB using LabelSpinBox $frame.delayValueLSB \
					-label [_m "Label|Delay Value:"] \
					-labelwidth $lwidth \
					-range {0 65535 1}
      pack $delayValueLSB -fill x
      install cardTypeMapLE using LabelEntry $frame.cardTypeMapLE \
					-label [_m "Label|Card Type Map:"] \
					-labelwidth $lwidth

      pack $cardTypeMapLE -fill x
      $self configurelist $args
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
	  $hull itemconfigure add -text [_m "Button|Update"]
	  $hull configure -title [_ "Edit CMR/I node"]
	}
	add -
	default {
	  $nameLE configure -editable yes
	  $hull itemconfigure add -text [_m "Button|Add"]
	  $hull configure -title [_ "Add CMR/I Node to panel"]
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
	  tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $name]
	  return
	}
	set parent [$hull cget -parent]
	if {[lsearch -exact [$parent cmrinodelist] "$name"] >= 0} {
	  tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Name '%s' already in use.  Pick another." $name]
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
	$cardTypeMapLE configure -label [_m "Label|Yellow Signal Map:"]
	$numberInputsLSB configure -text 3
	$numberInputsLSB configure -state disabled
	$numberOutputsLSB configure -text 6
	$numberOutputsLSB configure -state disabled
      } else {
	$cardTypeMapLE configure -label [_m "Label|Card Type Map:"]
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
				-side bottom -title [_ "Select CMRI Node"] \
				-parent [from args -parent]
      $hull add -name select -text [_m "Button|Select"] -command [mymethod _Select]
      $hull add -name find   -text [_m "Button|Find"]   -command [mymethod _Find]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Select CMRI Node Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Pattern:" "Label|Selection:"]
      install namePatternLE using LabelEntry $frame.namePatternLE \
					-label [_m "Label|Pattern:"] \
					-labelwidth $lwidth \
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
					-label [_m "Label|Selection:"] \
					-labelwidth $lwidth
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
					[$parent mrdnodelist] \
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
	tk_messageBox -type ok -icon warning  -parent $win -message [_ "No such board: %s" [$selectedNameLE cget -text]]
	return
      }
      return [$hull enddialog "[$selectedNameLE cget -text]"]
    }
  }
  #### MRD Dialogs
  snit::widgetadaptor AddMRDNodeDialog {
    delegate option -parent to hull
    option -node -default {}
    option -mode -default add
    component nameLE;#			Name of board (symbol)   
    component serialLE;#		Serial number (0XYYYYYYY)

    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title [_ "Add MRD Node to panel"] \
				-parent [from args -parent]
      $hull add -name add    -text [_m "Button|Add"]    -command [mymethod _Add]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Add MRD Node Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Serial Number:"]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $nameLE -fill x
      install serialLE using LabelEntry $frame.serialLE \
					-label [_m "Label|Serial Number:"] \
					-labelwidth $lwidth \
					-text {}
      pack $serialLE -fill x
      $self configurelist $args
    }
    method draw {args} {
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient [winfo toplevel $win] $parent
      switch -exact $options(-mode) {
	edit {
	  set node [$parent getmrdnode "$options(-node)"]
	  $nameLE configure -text $options(-node) -editable no
	  $serialLE configure -text [lindex $node 0]
	  $hull itemconfigure add -text [_m "Button|Update"]
	  $hull configure -title [_ "Edit MRD node"]
	}
	add -
	default {
	  $nameLE configure -editable yes
	  $hull itemconfigure add -text [_m "Button|Add"]
	  $hull configure -title [_ "Add MRD Node to panel"]
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
      set serial "[$serialLE cget -text]"
      if {[string equal "$options(-mode)" add]} {
	if {![$self _CheckNameChars "$name"]} {
	  tk_messageBox -type ok -icon error -parent $win \
		-message [_ "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $name]
	  return
	}
	set parent [$hull cget -parent]
	if {[lsearch -exact [$parent mrdnodelist] "$name"] >= 0} {
	  tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Name '%s' already in use.  Pick another." $name]
	  return
	}
      }
      $hull withdraw
      return [$hull enddialog [list "$name" "$serial"]]
    }
  }
  snit::widgetadaptor SelectMRDNodeDialog {
    delegate option -parent to hull

    component namePatternLE;#		Search Pattern
    component nameListSW;#		Name list ScrollWindow
    component   nameList;#		Name list
    component selectedNameLE;#		Selected Name

    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 2 -modal local -transient yes \
				-side bottom -title [_ "Select MRD Node"] \
				-parent [from args -parent]
      $hull add -name select -text [_m "Button|Select"] -command [mymethod _Select]
      $hull add -name find   -text [_m "Button|Find"]   -command [mymethod _Find]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Select MRD Node Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Pattern:" "Label|Selection:"]
      install namePatternLE using LabelEntry $frame.namePatternLE \
					-label [_m "Label|Pattern:"] \
					-labelwidth $lwidth \
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
					-label [_m "Label|Selection:"] \
					-labelwidth $lwidth
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
					[$parent mrdnodelist] \
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
      if {[lsearch -exact [$parent mrdnodelist] \
			  "[$selectedNameLE cget -text]"] < 0} {
	tk_messageBox -parent $win -type ok -icon warning -message [_ "No such node: %s" [$selectedNameLE cget -text]]
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
				-side bottom -title [_ "Edit User Code"] \
				-parent [from args -parent]
      $hull add -name update -text [_m "Button|Update"] -command [mymethod _Update]
      $hull add -name cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Edit User Code Dialog}}
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
