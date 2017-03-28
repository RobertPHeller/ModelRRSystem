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
package require tile
package require snit
package require grsupport 2.0
package require CTCPanel 2.0
package require LabelFrames
package require WrapIt
package require pdf4tcl
package require PrintDialog 2.0
package require MainWindow
package require ScrollableFrame
package require ListBox
package require ScrollWindow 
package require ROText
package require ScrollTabNotebook

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
    option -hascmri -default no  -type snit::boolean \
				-configuremethod _ConfigureCMRI
    option -hasazatrax -default no  -type snit::boolean \
				-configuremethod _ConfigureAZATRAX
    option -hasmrd -default no  -type snit::boolean \
          -configuremethod _ConfigureAZATRAX
    option -hasctiacela -default no -type snit::boolean
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
    option -ctiacelaport -default /dev/ttyACM0
    option -simplemode -default no -type snit::boolean \
          -configuremethod _ConfigureSimpleMode
    option -openlcbmode -default no -type snit::boolean \
          -configuremethod _ConfigureOpenLCBMode
    option -openlcbtransport -default {}
    option -openlcbtransportopts -default {}
    variable cmrinodes -array {}
    variable cmrinodes_comments -array {}

    method _ConfigureAZATRAX {option value} {
      if {"$option" eq "-hasmrd"} {set option -hasazatrax}
      set options($option) $value
      if {$value} {
	$main mainframe setmenustate azatrax normal
      } else {
	$main mainframe setmenustate azatrax disabled
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
    method _ConfigureOpenLCBMode {option value} {
        #puts stderr "*** $self _ConfigureOpenLCBMode $option $value"
        set options($option) $value
        set editmenu [$main mainframe getmenu edit]
        if {$value} {
            $main mainframe setmenustate cmri disabled
            $main mainframe setmenustate azatrax disabled
            $main mainframe setmenustate edit:simplemode disabled
        } else {
            $main mainframe setmenustate edit:simplemode normal
        }
    }
    variable azatraxnodes -array {}
    variable azatraxnodes_comments -array {}
    
    variable openlcbnodes -array {}
    method getOpenLCBNodeOpt {name option} {
        if {[info exists openlcbnodes($name)]} {
            set theopts $openlcbnodes($name)
            set oindex [lsearch $theopts $option]
            if {$oindex < 0} {return {}}
            incr oindex
            return [lindex $theopts $oindex]
        } else {
            return {}
        }
    }
    method setOpenLCBNode {name opts} {
        set openlcbnodes($name) $opts
    }
    variable userCode {}
    variable IsDirty yes

    method isdirtyp {} {return $IsDirty}
    method setdirty {} {
      set IsDirty yes
      $dirty configure -background red
    }
    method cleardirty {} {
      set IsDirty no
      $dirty configure -background black
    }

    variable additionalPackages {}
    variable externalUserModules -array {}

    typevariable _filemenu {
        "[_m {Menu|&File}]" {file} {file} 0 {
            {command "[_m {Menu|File|&New CTC Panel Window}]" {file:new} "[_ {New CTC Panel Window}]" {Ctrl n} -command "[mytypemethod new -parent $win -simplemode $Dispatcher::SimpleMode]"}
            {command "[_m {Menu|File|&Load...}]"  {file:load} "[_ {Open and Load XTrkCad Layout File}]" {Ctrl l} -command Dispatcher::LoadLayout}
            {command "[_m {Menu|File|&Open...}]" {file:open} "[_ {Open an existing CTC Panel Window file}]" {Ctrl o} -command "[mytypemethod open -parent $win]"}
            {command "[_m {Menu|File|&Save}]" {file:save} "[_ {Save window code}]" {Ctrl s} -command "[mymethod save]"}
            {command "[_m {Menu|File|Save &As...}]" {file:save} "[_ {Save window code}]" {Ctrl a} -command "[mymethod saveas]"}
            {command "[_m {Menu|File|Wrap As...}]" {file:wrap} "[_ {Wrap window code}]" {Ctrl w} -command "[mymethod wrapas]" -state $wrapasstate}
            {command "[_m {Menu|File|Print...}]" {file:print} "[_ {Print Panel}]" {Ctrl p} -command "[mymethod print]"}
            {command "[_m {Menu|File|Export as images...}]" {file:export} "[_ {Export panel as images}]" {Ctrl e} -command "[mymethod export]"}
            {command "[_m {Menu|File|&Close}]" {file:close} "[_ {Close the application}]" {} -command "[mymethod close]"}
            {command "[_m {Menu|File|E&xit}]" {file:exit} "[_ {Exit the application}]" {} -command {Dispatcher::CarefulExit}}
        }
    }
    typevariable _editmenu {
        "[_m {Menu|&Edit}]" {edit} {edit} 0 {
            {command "[_m {Menu|Edit|&Undo}]" {edit:undo} "[_ {Undo last change}]" {Ctrl z}}
            {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut} -state disabled}
            {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy} -state disabled}
            {command "[_m {Menu|Edit|&Paste}]" {edit:paste} "[_ {Paste selection from the paste buffer}]" {Ctrl c} -command {StdMenuBar EditPaste} -state disabled}
            {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear} -state disabled}
            {command "[_m {Menu|Edit|&Delete}]" {edit:delete edit:havesel} "[_ {Delete selection}]" {Ctrl d}  -command {StdMenuBar EditClear} -state disabled}
            {separator}
            {command "[_m {Menu|Edit|Select All}]" {edit:selectall} "[_ {Select everything}]" {} -command {StdMenuBar EditSelectAll}}
            {command "[_m {Menu|Edit|De-select All}]" {edit:deselectall edit:havesel} "[_ {Select nothing}]" {} -command {StdMenuBar EditSelectNone} -state disabled}
            {separator}
            {command "[_m {Menu|Edit|(Re-)Generate Main Loop}]" {edit:mainloop edit:simplemode} {} {} -command "[mymethod GenerateMainLoop]" -state $editstate}
            {command "[_m {Menu|Edit|User Code}]" {edit:usercode edit:simplemode} {} {} -command "[mymethod EditUserCode]" -state $editstate}
            {cascade "[_m {Menu|Edit|Modules}]" {edit:modules edit:simplemode} edit:modules 0 -state $editstate {
                    {command "[_m {Menu|Edit|Modules|Track Work type}]" {edit:modules:trackwork edit:simplemode} {} {} -command "[mymethod AddModule TrackWork]" -state $editstate}
                    {command "[_m {Menu|Edit|Modules|Switch Plate type}]" {edit:modules:switchplate edit:simplemode} {} {} -command "[mymethod AddModule SwitchPlates]" -state $editstate}
                    {cascade "[_m {Menu|Edit|Signals}]" {edit:modules:signals edit:simplemode} edit:modules:signals 0 -state $editstate {
                            {command "[_m {Menu|Edit|Signals|Two Aspect Color Light}]" {edit:modules:signals:twoaspcolor edit:simplemode} {} {} -command "[mymethod AddModule Signals2ACL]" -state $editstate}
                            {command "[_m {Menu|Edit|Signals|Three Aspect Color Light}]" {edit:modules:signals:threeaspcolor edit:simplemode} {} {} -command "[mymethod AddModule Signals3ACL]" -state $editstate}
                            {command "[_m {Menu|Edit|Signals|Three Aspect Search Light}]" {edit:modules:signals:threeaspsearch edit:simplemode} {} {} -command "[mymethod AddModule Signals3ASL]" -state $editstate}
                    }}
                    {command "[_m {Menu|Edit|Signals|Signal Plate type}]" {edit:modules:signalplate edit:simplemode} {} {} -command "[mymethod AddModule SignalPlates]" -state $editstate}
                    {command "[_m {Menu|Edit|Signals|Control Point type}]" {edit:modules:controlpoint edit:simplemode} {} {} -command "[mymethod AddModule ControlPoints]" -state $editstate}
                    {command "[_m {Menu|Edit|Signals|Radio Group Type}]" {edit:modules:radiogroup edit:simplemode} {} {} -command "[mymethod AddModule Groups]" -state $editstate}
            }}
            {cascade "[_m {Menu|Edit|Additional Packages}]" {edit:additionalpackages edit:simplemode} edit:additionalpackages 0 -state $editstate {
                    {command "[_m {Menu|Edit|Additional Packages|XPressNet}]" {edit:additionalpackages edit:simplemode} {} {} -command "[mymethod AddAdditionalPackage XPressNet]" -state $editstate}
                    {command "[_m {Menu|Edit|Additional Packages|NCE}]" {edit:additionalpackages edit:simplemode} {} {} -command "[mymethod AddAdditionalPackage NCE]" -state $editstate}
                    {command "[_m {Menu|Edit|Additional Packages|Raildriver Client}]" {edit:additionalpackages edit:simplemode} {} {} -command "[mymethod AddAdditionalPackage RailDriverSupport]" -state $editstate}
            }}
            {command "[_m {Menu|Edit|Add External User Module}]" {edit:externalUserModules edit:simplemode} {} {} -command "[mymethod AddExternalUserModule]" -state $editstate}
    }}
    typevariable _extramenus {
        "[_m {Menu|&Panel}]" panel panel 0 {
            {command "[_m {Menu|Panel|Add Object}]" {} "[_ {Add Panel Object}]" {} -command "[mymethod addpanelobject]"}
            {command "[_m {Menu|Panel|Edit Object}]" {} "[_ {Edit Panel Object}]" {} -command "[mymethod editpanelobject]"}
            {command "[_m {Menu|Panel|Delete Object}]" {} "[_ {Delete Panel Object}]" {} -command "[mymethod deletepanelobject]"}
            {separator}
            {command "[_m {Menu|Panel|Configure}]" {} "[_ {Configure Panel Options}]" {} -command "[mymethod configurepanel]"}
        } "[_m {Menu|&C/Mri}]" cmri cmri 0 {
            {command "[_m {Menu|C/Mri|Add node}]" {} "[_ {Add CMRI node}]" {} -command "[mymethod addcmrinode]"}
            {command "[_m {Menu|C/Mri|Edit node}]" {} "[_ {Edit CMRI node}]" {} -command "[mymethod editcmrinode]"}
            {command "[_m {Menu|C/Mri|Delete Node}]" {} "[_ {Delete CMRI node}]" {} -command "[mymethod deletecmrinode]"}
        } "[_m {Menu|&Azatrax}]" azatrax azatrax 0 {
            {command "[_m {Menu|Azatrax|Add node}]" {} "[_ {Add Azatrax node}]" {} -command "[mymethod addazatraxnode]"}
            {command "[_m {Menu|Azatrax|Edit node}]" {} "[_ {Edit Azatrax node}]" {} -command "[mymethod editazatraxnode]"}
            {command "[_m {Menu|Azatrax|Delete node}]" {} "[_ {Delete Azatrax node}]" {} -command "[mymethod deleteazatraxnode]"}
        }
    }
    constructor {args} {
      wm protocol $win WM_DELETE_WINDOW {Dispatcher::CarefulExit}
      wm withdraw $win
      wm title $win {}
      
      #puts stderr "*** $type create $self $args"
      if {[WrapIt::CanWrapP]} {
	set wrapasstate normal
	WrapIt::CheckPackageBaseDir
      } else {
	set wrapasstate disabled
      }
      set editstate normal
      set options(-simplemode) [from args -simplemode]
      if {$options(-simplemode)} {
	$self AddModule SimpleMode
	$self GenerateMainLoop
	set editstate disabled
      }
      set options(-openlcbmode) [from args -openlcbmode]
      if {$options(-openlcbmode)} {
          set editstate disabled
      }
      
      set mainmenu [StdMenuBar MakeMenu -file [subst $_filemenu] -edit [subst $_editmenu] ]
      #puts stderr "*** CTCPanelWindow::create: mainmenu = $mainmenu (length is [llength $mainmenu])"
      set extramenus [subst $_extramenus]
      #puts stderr "*** CTCPanelWindow::create: extramenus = $extramenus (length is [llength $extramenus])"
      
      install main using mainwindow $win.main \
	-menu $mainmenu \
	-extramenus $extramenus

      $main menu delete help "[_m {Menu|Help|On Keys...}]"
      $main menu delete help "[_m {Menu|Help|Index...}]"
      $main menu add help command \
	-label [_m "Menu|Help|Reference Manual"] \
	-command "HTMLHelp help {Dispatcher Reference}"
      $main menu entryconfigure help [_m "Menu|Help|On Help..."] \
	-command "HTMLHelp help Help"
      $main menu entryconfigure help [_m "Menu|Help|Tutorial..."] \
	-command "HTMLHelp help {Dispatcher Tutorial}"
      $main menu entryconfigure help [_m "Menu|Help|On Version"] \
	-command "HTMLHelp help Version"
      $main menu entryconfigure help [_m "Menu|Help|Copying"] \
	-command "HTMLHelp help Copying"
      $main menu entryconfigure help [_m "Menu|Help|Warranty"] \
	-command "HTMLHelp help Warranty"
      if {$::tcl_platform(os) eq "Darwin"} {
          $main menu add help command \
                -label [_m "Menu|Help|About"] \
                -command ::tk::mac::standardAboutPanel
      }

      $main mainframe setmenustate cmri disabled
      $main mainframe setmenustate azatrax disabled
      pack $main -expand yes -fill both

      set frame [$main scrollwindow getframe]
      install swframe using ScrollableFrame $frame.swframe \
			-constrainedheight yes -constrainedwidth yes
      $main scrollwindow setwidget $swframe
      install ctcpanel using ::CTCPanel::CTCPanel [$swframe getframe].ctcpanel
      pack $ctcpanel -fill both -expand yes
      set dirty [$main mainframe addindicator -background black \
                 -image [IconImage image gray50 \
                         -filetype xbm \
                         -foreground [ttk::style lookup . \
                                      -background {} #d9d9d9] \
                         -background {}]]

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
      
      [$main mainframe getmenu edit] configure -postcommand [mymethod edit_checksel]
      $main showit
      set OpenWindows($options(-name)) $win
      Dispatcher::AddToWindows $win "$options(-name)"
      $self buildDialogs
      if {$options(-simplemode)} {
	$self AddModule SimpleMode
	$self GenerateMainLoop
      }
    }
    method edit_checksel {} {
        if {[catch {selection get}]} {
            $main mainframe setmenustate edit:havesel disabled
        } else {
            $main mainframe setmenustate edit:havesel normal
        }
    }
    destructor {
        #puts stderr "*** $self destroy: win = $win, array names OpenWindows = [array names OpenWindows]"
        if {![catch {set OpenWindows($options(-name))} xwin] &&
	  [string equal "$xwin" "$win"]} {
          #puts stderr "*** $self destroy: xwin = $xwin"
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
      #puts stderr "*** $self close"
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
    method writeprog {fp module {iswraped no} {libdir {}}} {
      if {$iswraped} {
	puts $fp "package provide app-$module 1.0"
      } else {
	puts $fp {#!/usr/bin/wish}
      }
      puts $fp "# Generated code: [clock format [clock scan now]]"
      puts $fp {# Generated by: $Id: CTCPanelWindow.tcl 709 2009-05-01 15:20:49Z heller $}
      puts $fp {# Add your code to the bottom (after the 'Add User code after this line').}
      puts $fp {#}
      puts -nonewline $fp {# }
      puts $fp [list -name "$options(-name)"]
      puts -nonewline $fp {# }
      puts $fp [list -width [$ctcpanel cget -width]]
      puts -nonewline $fp {# }
      puts $fp [list -height [$ctcpanel cget -height]]
      puts $fp "# -hascmri $options(-hascmri)"
      if {$options(-hascmri)} {
        puts -nonewline $fp {# }
	puts $fp [list -cmriport "$options(-cmriport)"]
        puts -nonewline $fp {# }
	puts $fp [list -cmrispeed $options(-cmrispeed)]
        puts -nonewline $fp {# }
	puts $fp [list -cmriretries $options(-cmriretries)]
      }
      puts $fp "# -hasctiacela $options(-hasctiacela)"
      if {$options(-hasctiacela)} {
          puts -nonewline $fp {# }
          puts $fp [list -ctiacelaport "$options(-ctiacelaport)"]
      }
      puts $fp "# -hasazatrax $options(-hasazatrax)"
      puts $fp "# -simplemode $options(-simplemode)"
      puts $fp "# -openlcbmode $options(-openlcbmode)"
      puts -nonewline $fp {# }
      puts $fp [list -openlcbtransport "$options(-openlcbtransport)"]
      puts -nonewline $fp {# }
      puts $fp [list -openlcbtransportopts "$options(-openlcbtransportopts)"]
      set line "# "
      append line [concat additionalPackages $additionalPackages]
      puts $fp $line
      foreach eum [array names externalUserModules] {
          set line "# "
          append line [list externalUserModule $eum $externalUserModules($eum)]
          puts $fp $line
          if {!$iswraped} {
              puts $fp "lappend auto_path $externalUserModules($eum)"
          }
      }
      puts $fp {# Load Tcl/Tk system supplied packages}
      puts $fp {package require Tk;#		Make sure Tk is loaded}
      puts $fp {package require tile;#          Load tile}
      puts $fp {package require snit;#		Load Snit}
      puts $fp {}
      puts $fp {# Load MRR System packages}
      if {!$iswraped} {
	puts $fp {# Add MRR System package Paths}
	puts $fp {lappend auto_path /usr/local/lib/MRRSystem;# C++ (binary) packages}
	puts $fp {lappend auto_path /usr/local/share/MRRSystem;# Tcl (source) packages}
      }
      puts $fp {}
      puts $fp {package require snitStdMenuBar;#  Load the standard menu bar package}
      puts $fp {package require LabelFrames;#   Label frame widgets}
      puts $fp {package require MainFrame;#     Main Frame widget}
      puts $fp {package require ScrollableFrame;#     Scrollable Frame widget}
      puts $fp {package require MainWindow;#    Load the Main Window package}
      puts $fp {package require CTCPanel 2.0;#  Load the CTCPanel package (V2)}
      puts $fp {package require grsupport 2.0;# Load Graphics Support code (V2)}
      puts $fp {}
      set panelCodeFp [open [file join "$CodeLibraryDir" \
					panelCode.tcl] r]
      fcopy $panelCodeFp $fp
      close $panelCodeFp
      puts $fp {}
      if {$options(-openlcbmode)} {
          puts $fp [list MainWindow createwindow -name "$options(-name)" \
                    -width [$ctcpanel cget -width] \
                    -height [$ctcpanel cget -height] \
                    -extramenus [subst {"[_m {Menu|OpenLCB}]" openlcb openlcb 0 {}}]]
      } else {
          puts $fp [list MainWindow createwindow -name "$options(-name)" \
                    -width [$ctcpanel cget -width] \
                    -height [$ctcpanel cget -height]]
      }
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
	foreach n [array names cmrinodes_comments] {
	  #puts stderr "*** $self writeprog: cmrinodes_comments($n) = '$cmrinodes_comments($n)'"
	}
	foreach board [array names cmrinodes] {
	  if {![catch {set cmrinodes_comments($board)} board_comment]} {
	    puts $fp "# $board_comment"
	  }
	  puts $fp [concat CMriNode create $board $cmrinodes($board)]
	}
      }
      if {$options(-hasazatrax)} {
	puts $fp {}
	puts $fp "package require Azatrax"
	puts $fp {# Azatrax Nodes}
	foreach name [array names azatraxnodes] {
	  foreach {sn prod} $azatraxnodes($name) {break}
	  if {![catch {set azatraxnodes_comments($name)} the_comment]} {
	    puts $fp "# $the_comment"
	  }
	  puts $fp "$prod $name -this \[Azatrax_OpenDevice $sn \$::Azatrax_id${prod}Product\]"

	}
      }
      if {$options(-hasctiacela)} {
          puts $fp {}
          puts $fp "package require CTIAcela"
          puts $fp {}
          puts $fp [list ctiacela::CTIAcela Acela "$options(-ctiacelaport)"]
          puts $fp [list Acela NetworkOnline]
      }
      if {$options(-openlcbmode)} {
          set openlcbCodeFp [open [file join "$CodeLibraryDir" \
                                   OpenLCBCode.tcl] r]
          fcopy $openlcbCodeFp $fp 
          puts $fp "OpenLCB_Dispatcher PopulateOpenLCBMenu"
          puts $fp "OpenLCB_Dispatcher ConnectToOpenLCB -transport $options(-openlcbtransport) $options(-openlcbtransportopts) -name \{$options(-name)\} -description \{$options(-filename)\}"
          puts $fp "# OpenLCB_Dispatcher Nodes"
          foreach openlcbele [array names openlcbnodes] {
              set nodeopts $openlcbnodes($openlcbele)
              puts $fp "# OpenLCB_Dispatcher $openlcbele $nodeopts"
              set eleclasstype [from nodeopts -eleclasstype]
              puts $fp "OpenLCB_Dispatcher create %AUTO% -name $openlcbele \\"
              puts $fp "\t-eleclasstype $eleclasstype \\"
              set evasplist [from nodeopts -eventidaspectlist]
              set prefix ""
              if {$evasplist ne ""} {
                  puts $fp "\t-eventidaspectlist \[list \\"
                  foreach {ev aspl} $evasplist {
                      puts $fp "\t\t\[lcc::EventID %AUTO% -eventidstring \{$ev\}\] \\"
                      puts $fp "\{$aspl\} \\"
                  }
                  puts -nonewline $fp "\t\]"
                  set prefix " \\\n"
              }
              foreach opt {-occupiedeventid -notoccupiedeventid 
                  -statenormaleventid -statereverseeventid -oneventid 
                  -offeventid -lefteventid -righteventid -centereventid 
                  -eventid -normaleventid -reverseeventid -normalindonev 
                  -normalindoffev -centerindonev -centerindoffev 
                  -reverseindonev -reverseindoffev -leftindonev -leftindoffev 
                  -rightindonev -rightindoffev} {
                  set ev [from nodeopts $opt]
                  if {$ev eq ""} {continue}
                  puts -nonewline $fp "$prefix\t$opt \[lcc::EventID %AUTO% -eventidstring \{$ev\}\]"
                  set prefix " \\\n"
              }
              puts $fp {}             
          }
          puts $fp "OpenLCB_Dispatcher SendMyEvents"
      } else {
          puts $fp {}
          puts $fp {# Add User code after this line}
          puts $fp "$userCode"
          if {$iswraped} {
              foreach eum [array names externalUserModules] {
                  RecursiveFileCopy $externalUserModules($eum) [file join $libdir $eum]
              }
          }
      }
    }
    proc RecursiveFileCopy {fromdir todir} {
        file mkdir $todir
        foreach f [glob -nocomplain [file join $fromdir *]] {
            if {[file isdirectory $f]} {
                RecursiveFileCopy $f [file join $todir [file tail $f]]
            } else {
                file copy $f $todir
            }
        }
    }
    method wrapas {{filename {}}} {
        #puts stderr "*** $self wrapas $filename"
        if {[string length "$filename"] == 0} {
            set initdir [file dirname "$options(-filename)"]
            if {[string equal "$initdir" {.}]} {set initdir [pwd]}
            set exeext [file extension [info nameofexe]]
            set filetypes [list]
            lappend filetypes [list {Exe Files} [list "$exeext"] BINF]
            lappend filetypes {{All Files} *      BINF}
            #puts stderr "*** $self wrapas: exeext = \"$exeext\", filetypes = $filetypes"
            regsub -all {\.} [file extension "$options(-filename)"] {\\.} pattern
            regsub "$pattern" "$options(-filename)" "$exeext" exefile
            #puts stderr "*** $self wrapas: exefile = $exefile"
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
        WrapIt::WrapIt $filename [mymethod writeprog] $options(-hascmri) $options(-hasazatrax) $options(-hasctiacela) $options(-openlcbmode) $additionalPackages
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
        #puts stderr "*** CTCPanelWindow::theimagetype $filename"
        #puts stderr "*** CTCPanelWindow::theimagetype $filename's extension is '[file extension $filename]'"
        regsub {^\.} [file extension $filename] {} result
        #puts stderr "*** CTCPanelWindow::theimagetype: result = '$result'"
        return [string tolower $result]
    }
    proc checkImageType {filename} {
      return [expr {[lsearch -exact $allowedImageTypes [theimagetype $filename]] >= 0}]
    }
    typemethod createExportDialog {} {
      if {"$_exportdialog" ne "" && [winfo exists $_exportdialog]} {return}
      set _exportdialog [Dialog .dispatcher_exportdialog -image $imageIcon \
				-cancel cancel -default export -modal local \
				-parent . -side bottom \
				-title [_ "Image Export"] -transient yes]
      $_exportdialog add export	-text [_m "Button|Export"] \
					-command [mytypemethod _Export]
      $_exportdialog add cancel	-text [_m "Button|Cancel"]  \
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
      set exportSchematicfileCB [ttk::checkbutton $frame.exportSchematicfileCB \
					-text [_ "Export Schematic?"] \
				-variable [mytypevar exportSchematicfileFlag]]
      pack $exportSchematicfileCB -fill x -expand yes
      set exportControlsfileFE [FileEntry $frame.exportControlsfileFE \
					-label [_m "Label|Controls Output file:"] \
					-labelwidth $lwidth \
					-filetypes $imagefiletypes \
					-filedialog save]
      pack $exportControlsfileFE -fill x
      set exportControlsfileCB [ttk::checkbutton $frame.exportControlsfileCB \
					-text [_ "Export Controls?"] \
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
      update;# idletasks
      raise [winfo toplevel $ctcpanel]
      update;# idletasks
      #puts stderr "*** $self export: \[wm stackorder [winfo parent [winfo toplevel $ctcpanel]]\] yields: [wm stackorder [winfo parent [winfo toplevel $ctcpanel]]]"
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
    typemethod addazatraxnode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] addazatraxnode] $args]
    }
    typemethod editazatraxnode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] editazatraxnode] $args]
    }
    typemethod deleteazatraxnode {name args} {
      return [eval [list [$type selectwindowbyname "$name"] deleteazatraxnode] $args]
    }

    typemethod open {args} {
      set parent [from args -parent .]

      set filename [from args -file  {}]
      #puts stderr "*** $type open: filename = '$filename'"
      if {[string length "$filename"] == 0} {
	set filename [tk_getOpenFile -defaultextension ".tcl" \
				   -initialfile newctcpanel.tcl \
				   -filetypes { {{Tcl Files} {.tcl} TEXT}
						{{All Files} *      TEXT} } \
				   -title [_ "CTC File to open"] \
				   -parent $parent]
        #puts stderr "*** $type open (after tk_getOpenFile): filename = '$filename'"
      }
      if {[string length "$filename"] == 0} {return}
      if {[catch {open "$filename" r} fp]} {
	tk_messageBox -type ok -icon error -parent $parent \
		      -message [_ "Could not open $filename: %s" $fp]
	return
      }
      set opts [list -filename "$filename"]
      set buffer {}
      set aplist {}
      array unset eums
      while {[gets $fp line] >= 0} {
          #puts stderr "*** $type open (looking for options): line = '$line'"
	append buffer "$line"
	if {[info complete "$buffer"] && 
	    ![string equal "\\" "[string index $buffer end]"]} {
            #puts stderr "*** $type open (looking for options): buffer = '$buffer'"
	  if {[regexp {^#} "$buffer"] < 1} {break}
	  if {[regexp {^# additionalPackages[[:space:]]*(.*)$} $line -> aplist] > 0} {
	    set buffer {}
	    continue
          }
          if {[regexp {^# externalUserModule[[:space:]]*(.*)$} $line -> eumlist] > 0} {
              set buffer {}
              set eums([lindex $eumlist 0]) [lindex $eumlist 1]
              continue
          }
	  if {[regexp {^# -} "$buffer"] < 1} {set buffer {};continue}
          #puts stderr "*** $type open: buffer = '$buffer'"
          #puts stderr "*** $type open: llength \$buffer is [llength $buffer]"
	  lappend opts [lindex $buffer 1] "[lindex $buffer 2]"
          #puts stderr "*** $type open: opts = $opts"
	  set buffer {}
	} else {
	  append buffer "\n"
	}
      }
      #puts stderr "*** $type open: aplist is '$aplist'"
      set newWindow [eval [list $type create .ctcpanel%AUTO%] $opts]
      foreach ap $aplist {
 	if {"$ap" eq ""} {continue}
	#puts stderr "*** $type open: ap is '$ap'"
	$newWindow AddAdditionalPackage $ap
      }
      foreach eum [array names eums] {
          $newWindow AddExternalUserModule_ $eum $eums($eum)
      }
      while {[gets $fp line] >= 0} {
          #puts stderr "*** $type open (looking for CTCPanelObjects): line = '$line'"
	if {[regexp {^# CTCPanelObjects$} "$line"] > 0} {break}
      }
      set buffer {}
      while {[gets $fp line] >= 0} {
          #puts stderr "*** $type open (reading CTCPanelObjects): line = '$line'"
	append buffer "$line"
	if {[info complete "$buffer"] && 
	    ![string equal "\\" "[string index $buffer end]"]} {
            #puts stderr "*** $type open: buffer = $buffer"
	  if {[regexp {^MainWindow ctcpanel create (.*)$} "$buffer" -> obj] > 0} {
              set o [eval [list $newWindow ctcpanel create] $obj]
              set name       [lindex $obj 1]
              $o bind <3> [list $newWindow _contextMenu $name %x %y %W]
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
	  if {[regexp {^# Azatrax Nodes$} "$line"] > 0} {set mode AZATRAXNodes;break}
          if {[regexp {^# OpenLCB_Dispatcher Nodes$} "$line"] > 0} {set mode OpenLCB_DispatcherNodes;break}
	  if {[regexp {^# Add User code after this line$} "$line"] > 0} {
	    set mode UserCode
	    break;
	  }
	  set mode EOF
	}
        #puts stderr "*** $type open: mode is $mode"
	set board_comment ""
	switch $mode {
	  CMRIBoards {
	    set buffer {}
	    while {[gets $fp line] >= 0} {
	      #puts stderr "*** $type open: read CMRIBoards loop: line = '$line'"
	      if {[regexp {^# Azatrax Nodes$} "$line"] > 0} {set mode AZATRAXNodes;break}
              if {[regexp {^# OpenLCB_Dispatcher Nodes$} "$line"] > 0} {set mode OpenLCB_DispatcherNodes;break}
              if {[regexp {^# Add User code after this line$} "$line"] > 0} {set mode UserCode;break}
	      if {[regexp {^# (.*)$} "$line" => board_comment] > 0} {continue}
	      append buffer "$line"
	      #puts stderr "*** $type open: read CMRIBoards loop: buffer = '$buffer'"
	      if {[info complete "$buffer"] && 
		  ![string equal "\\" "[string index $buffer end]"]} {
		if {[regexp {^CMriNode create .*$} "$buffer"] > 0} {
		  $newWindow setcmrinode [lindex $buffer 2] "[lrange $buffer 3 end]" "$board_comment"
		  set board_comment ""
		} else {
		  break
		}
		set buffer {}
	      } else {
		append buffer "\n"
	      }
	    }
	  }
	  AZATRAXNodes {
	    set buffer {}
	    while {[gets $fp line] >= 0} {
              if {[regexp {^# CMRIBoards} "$line"] > 0} {set mode CMRIBoards;break}
              if {[regexp {^# OpenLCB_Dispatcher Nodes$} "$line"] > 0} {set mode OpenLCB_DispatcherNodes;break}
              if {[regexp {^# Add User code after this line$} "$line"] > 0} {set mode UserCode;break}
	      if {[regexp {^# (.*)$} "$line" => board_comment] > 0} {continue}
	      append buffer "$line"
	      if {[info complete "$buffer"] && 
		  ![string equal "\\" "[string index $buffer end]"]} {
                  #puts stderr "*** $type open: (AZATRAXNodes branch) buffer = '$buffer'"
		if {[regexp {^(MRD|SL2|SR4)[[:space:]]([[:alpha:]][[:alnum:]_.-]*)[[:space:]]-this[[:space:]]\[Azatrax_OpenDevice[[:space:]](0[[:digit:]]*)[[:space:]]\$::Azatrax_id(MRD|SL2|SR4)Product\]}  $buffer => product name serial] > 0} {
		  #puts stderr "*** $type open: \$newWindow setazatraxnode $name $serial $product"
		  $newWindow setazatraxnode $name $serial $product $board_comment
		  set board_comment ""
		} else {
		  break
		}
		set buffer {}
	      } else {
		append buffer "\n"
	      }
	    }
	  }
	  
          OpenLCB_DispatcherNodes {
              set buffer {}
              while {[gets $fp line] >= 0} {
                  #puts stderr "*** $type open (OpenLCB_DispatcherNodes branch): line = $line"
                  if {[regexp {^# CMRIBoards} "$line"] > 0} {set mode CMRIBoards;break}
                  if {[regexp {^# Azatrax Nodes$} "$line"] > 0} {set mode AZATRAXNodes;break}
                  if {[regexp {^# OpenLCB_Dispatcher ([^[:space:]]+)[[:space:]](.*)$} "$line" => openlcbele nodeopts] > 0} {
                      #puts stderr "*** $type open (OpenLCB_DispatcherNodes branch) matched: openlcbele = $openlcbele, nodeopts = $nodeopts"
                      $newWindow setOpenLCBNode $openlcbele $nodeopts
                      continue
                  }
                  append buffer "$line"
                  if {[info complete "$buffer"] &&
                      ![string equal "\\" "[string index $buffer end]"]} {
                      set buffer {}
                  } else {
                      append buffer "\n"
                  }
              }
              set code {}
              set mode EOF
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
    method setcmrinode {board value {comment {}}} {
      set cmrinodes($board) "$value"
      if {$comment ne ""} {
	set cmrinodes_comments($board) "$comment"
      }
    }
    method getcmrinode {board} {
      if {[catch {set cmrinodes($board)} value]} {
	error [_ "No such board: %s" $board]
      } else {
	return "$value"
      }
    }
    method getcmrinode_comment {board} {
      if {[catch {set cmrinodes_comments($board)} value]} {
	return ""
      } else {
	return "$value"
      }
    }
    method cmrinodelist {} {
      return [array names cmrinodes]
    }

    method setazatraxnode {name serial product {comment {}}} {
      set azatraxnodes($name) [list "$serial" $product]
      if {$comment ne ""} {
	set azatraxnodes_comments($name) "$comment"
      }
    }
    method getazatraxnode {name} {
      if {[catch {set azatraxnodes($name)} serialprod]} {
	error [_ "No such node: %s" $name]
      } else {
	return $serialprod
      }
    }
    method getazatraxnode_comment {name} {
      if {[catch {set azatraxnodes_comments($name)} comment]} {
	return ""
      } else {
	return "$comment"
      }
    }
    method azatraxnodelist {} {
      return [array names azatraxnodes]
    }

    typecomponent newDialog
    typecomponent  new_nameLE
    typecomponent  new_widthLSB
    typecomponent  new_heightLSB
    typecomponent  new_hascmriLCB
    typecomponent  new_cmriportLCB
    typecomponent  new_cmrispeedLCB
    typecomponent  new_cmriretriesLSB
    typecomponent  new_hasazatraxLCB
    typecomponent  new_simpleModeCB
    typecomponent  new_openlcbModeCB
    typecomponent  new_hasctiacelaLCB
    typecomponent  new_ctiacelaportLCB
    typecomponent  new_transconstructorE
    typecomponent  new_transconstructorSB
    typevariable   _transconstructorname {}
    typecomponent  new_transoptsframeE
    typecomponent  new_transoptsframeSB
    typevariable   _transopts {}
    typevariable   _simpleMode no
    typevariable   _openlcbMode no

    typecomponent selectPanelDialog
    typecomponent   selectPanel_nameLCB
    
    typecomponent editContextMenu
    
    typeconstructor {
        #puts stderr "*** $type constructor: \[info script\] = [info script]"
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
      set editContextMenu [StdEditContextMenu .editContextMenu]
      $editContextMenu bind Entry
      $editContextMenu bind TEntry
      $editContextMenu bind Text
      $editContextMenu bind ROText
      $editContextMenu bind Spinbox
      
    }
                
                
    typemethod createnewDialog {} {
      if {![string equal "$newDialog" {}] && [winfo exists $newDialog]} {return}
      set newDialog [Dialog .newCTCPanelWindowDialog \
			-bitmap questhead -default create \
			-cancel cancel -modal local -transient yes -parent . \
			-side bottom -title [_ "New CTCPanel"]]
      $newDialog add create -text [_m "Button|Create"] -command [mytypemethod _NewCreate]
      $newDialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _NewCancel]
      wm protocol [winfo toplevel $newDialog] WM_DELETE_WINDOW [mytypemethod _NewCancel]
      $newDialog add help -text [_m "Button|Help"] -command {HTMLHelp help {Creating a new CTC Panel}}
      set frame [$newDialog getframe]
      set lwidth [_mx "Label|Name:" "Label|Width:" "Label|Height:" \
		      "Label|Has CM/RI?" "Label|CM/RI Port:" \
                  "Label|CM/RI Speed:" "Label|CM/RI Retries:" \
                  "Label|Has CTI Acela?" "Label|CTI Acela Port:"]
      set new_nameLE [LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						   -labelwidth $lwidth\
						   -text {Unnamed}]
      pack $new_nameLE -fill x
      set new_widthLSB [LabelSpinBox $frame.widthLSB -label [_m "Label|Width:"] \
						   -labelwidth $lwidth \
						   -range {780 1000 10}]
      pack $new_widthLSB -fill x
      set new_heightLSB [LabelSpinBox $frame.heightLSB -label [_m "Label|Height:"] \
						   -labelwidth $lwidth \
						   -range {550 800 10}]
      pack $new_heightLSB -fill x
      set new_simpleModeCB [ttk::checkbutton $frame.simpleModeCB \
					-text [_m "Label|Simple Mode"] \
					-offvalue no -onvalue yes \
					-command [mytypemethod togglesimplemode] \
					-variable [mytypevar _simpleMode]]
      pack $new_simpleModeCB -fill x -expand yes
      set new_openlcbModeCB [ttk::checkbutton $frame.openlcbModeCB \
					-text [_m "Label|OpenLCB Mode"] \
					-offvalue no -onvalue yes \
					-command [mytypemethod toggleopenlcbmode] \
					-variable [mytypevar _openlcbMode]]
      pack $new_openlcbModeCB -fill x -expand yes
      set transconstructor [LabelFrame $frame.transconstructor \
                            -text [_m "Label|OpenLCB Transport Constructor"]]
      pack $transconstructor -fill x -expand yes
      set cframe [$transconstructor getframe]
      set new_transconstructorE [ttk::entry $cframe.transcname \
                      -state disabled \
                      -textvariable [mytypevar _transconstructorname]]
      pack $new_transconstructorE -side left -fill x -expand yes
      set new_transconstructorSB [ttk::button $cframe.transcnamesel \
                         -text [_m "Label|Select"] \
                         -command [mytypemethod _seltransc] \
                         -state disabled]
      pack $new_transconstructorSB -side right
      set transoptsframe [LabelFrame $frame.transoptsframe \
                          -text [_m "Label|Constructor Opts"]]
      pack $transoptsframe -fill x -expand yes
      set oframe [$transoptsframe getframe]
      set new_transoptsframeE [ttk::entry $oframe.transoptsentry \
                          -state disabled \
                          -textvariable [mytypevar _transopts]]
      pack $new_transoptsframeE -side left -fill x -expand yes
      set new_transoptsframeSB [ttk::button $oframe.tranoptssel \
                       -text [_m "Label|Select"] \
                       -command [mytypemethod _seltransopt] \
                       -state disabled]
      pack $new_transoptsframeSB -side right
                          
                                   
      set new_hascmriLCB [LabelComboBox $frame.hascmriLCB \
						   -label [_m "Label|Has CM/RI?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no]
      $new_hascmriLCB set [lindex [$new_hascmriLCB cget -values] end]
      pack $new_hascmriLCB -fill x
      set new_cmriportLCB [LabelComboBox $frame.cmriportLCB \
						   -label [_m "Label|CM/RI Port:"] \
						   -labelwidth $lwidth \
						   -values {/dev/ttyS0 
							    /dev/ttyS1 
							    /dev/ttyUSBS0 
							    /dev/ttyUSBS1}]
      pack $new_cmriportLCB -fill x
      $new_cmriportLCB set [lindex [$new_cmriportLCB cget -values] 0]
      set new_cmrispeedLCB [LabelComboBox $frame.cmrispeedLCB \
						   -label [_m "Label|CM/RI Speed:"] \
						   -labelwidth $lwidth \
						   -values {4800 9600 19200}]
      pack $new_cmrispeedLCB -fill x
      $new_cmrispeedLCB set [lindex [$new_cmrispeedLCB cget -values] 1]
      set new_cmriretriesLSB [LabelSpinBox $frame.cmriretriesLSB \
						   -label [_m "Label|CMR/I Retries:"] \
						   -labelwidth $lwidth \
						   -range {5000 20000 100}]
      pack $new_cmriretriesLSB -fill x
      $new_cmriretriesLSB set 10000
      set new_hasazatraxLCB [LabelComboBox $frame.hasazatraxLCB \
						   -label [_m "Label|Has AZATRAX?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no]
      $new_hasazatraxLCB set [lindex [$new_hasazatraxLCB cget -values] end]
      pack $new_hasazatraxLCB -fill x
      set new_hasctiacelaLCB [LabelComboBox $frame.hasctiacelaLCB \
                              -label [_m "Label|Has CTI Acela?"] \
                              -labelwidth $lwidth \
                              -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
                              -editable no]
      
      $new_hasctiacelaLCB set [lindex [$new_hasctiacelaLCB cget -values] end]
      pack $new_hasctiacelaLCB -fill x
      set new_ctiacelaportLCB [LabelComboBox $frame.ctiacelaportLCB \
                               -label [_m "Label|CTI Acela Port:"] \
                               -labelwidth $lwidth \
                               -values {/dev/ttyS0
                                        /dev/ttyS1
                                        /dev/ttyACM0}]
      pack $new_ctiacelaportLCB -fill x
      $new_ctiacelaportLCB set [lindex [$new_ctiacelaportLCB cget -values] end]
    }
    typemethod togglesimplemode {} {
      if {$_simpleMode} {
	foreach w {new_hascmriLCB new_cmriportLCB new_cmrispeedLCB 
            new_cmriretriesLSB new_hasazatraxLCB new_hasctiacelaLCB 
            new_ctiacelaportLCB new_openlcbModeCB} {
	  [set $w] configure -state disabled
	}
        $new_hasazatraxLCB set [lindex [$new_hasazatraxLCB cget -values] 0]
      } else {
          foreach w {new_cmriportLCB new_cmrispeedLCB new_cmriretriesLSB 
              new_ctiacelaportLCB new_openlcbModeCB} {
            [set $w] configure -state normal
        }
        foreach w {new_hascmriLCB new_hasazatraxLCB new_hasctiacelaLCB} {
            [set $w] configure -state readonly
        }
        $new_hasazatraxLCB set [lindex [$new_hasazatraxLCB cget -values] end]
      }
    }
    typemethod toggleopenlcbmode {} {
        if {$_openlcbMode} {
            foreach w {new_hascmriLCB new_cmriportLCB new_cmrispeedLCB
                new_cmriretriesLSB new_hasazatraxLCB new_simpleModeCB 
                new_hasctiacelaLCB new_ctiacelaportLCB} {
                [set $w] configure -state disabled
            }
            foreach w {new_transconstructorE new_transoptsframeE} {
                [set $w] configure -state readonly
            }
            foreach w {new_transconstructorSB new_transoptsframeSB} {
                [set $w] configure -state normal
            }
        } else {
            foreach w {new_cmriportLCB new_cmrispeedLCB new_cmriretriesLSB 
                new_ctiacelaportLCB} {
                [set $w] configure -state normal
            }
            foreach w {new_hascmriLCB new_hasazatraxLCB new_simpleModeCB 
                new_hasctiacelaLCB} {
                [set $w] configure -state readonly
            }
            foreach w {new_transconstructorE new_transoptsframeE 
                new_transconstructorSB new_transoptsframeSB} {
                [set $w] configure -state disabled
            }
        }
    }
    typemethod _seltransc {} {
        #** Select a transport constructor.
        
        set result [lcc::OpenLCBNode selectTransportConstructor -parent [winfo toplevel $new_transconstructorE]]
        if {$result ne {}} {
            if {$result ne $_transconstructorname} {set _transopts {}}
            set _transconstructorname [namespace tail $result]
        }
    }
    typemethod _seltransopt {} {
        #** Select transport constructor options.
        
        if {$_transconstructorname ne ""} {
            set transportConstructors [info commands ::lcc::$_transconstructorname]
            #puts stderr "*** $type typeconstructor: transportConstructors is $transportConstructors"
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
            if {$transportConstructor ne {}} {
                set optsdialog [list $transportConstructor \
                                drawOptionsDialog \
                                -parent [winfo toplevel $new_transoptsframeE]]
                foreach x $_transopts {lappend optsdialog $x}
                set transportOpts [eval $optsdialog]
                if {$transportOpts ne {}} {
                    set _transopts $transportOpts
                }
            }
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
				     -hasazatrax 1 \
				     -simplemode yes
      } else {
	$type create .ctcpanel%AUTO% -name "[$new_nameLE cget -text]" \
              -width [$new_widthLSB cget -text] \
              -height [$new_heightLSB cget -text] \
              -hascmri [converttobool [$new_hascmriLCB cget -text]] \
              -cmriport [$new_cmriportLCB cget -text] \
              -cmrispeed [$new_cmrispeedLCB cget -text] \
              -cmriretries [$new_cmriretriesLSB cget -text] \
              -hasazatrax [converttobool [$new_hasazatraxLCB cget -text]] \
              -hasctiacela [converttobool [$new_hasctiacelaLCB cget -text]] \
              -ctiacelaport [$new_ctiacelaportLCB cget -text] \
              -openlcbmode $_openlcbMode \
              -openlcbtransport "$_transconstructorname" \
              -openlcbtransportopts "$_transopts" \
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
      set selectPanelDialog [.selectPanelDialog create \
				-bitmap questhead -default create \
				-cancel cancel -modal local -transient yes \
				-parent . -side bottom -title [_ "Select Panel"]]
      $selectPanelDialog add create -text [_m "Button|Select"] \
					  -command [mytypemethod _SelectPanel]
      $selectPanelDialog add cancel -text [_m "Button|Cancel"] \
					  -command [mytypemethod _SelectCancel]
      wm protocol [winfo toplevel $selectPanelDialog] WM_DELETE_WINDOW \
				[mytypemethod _SelectCancel]
      $selectPanelDialog add help -text [_m "Button|Help"] \
			     -command {HTMLHelp help {Select Panel Dialog}}
      set frame [$selectPanelDialog getframe]
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
      $selectPanel_nameLCB set [lindex [$selectPanel_nameLCB cget -values] 0]
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
        #puts stderr "*** $type addtrackworknodetopanel $node"
        set nparent [from args -parent .]
        switch [llength [array names OpenWindows]] {
            0 {
                tk_messageBox -type ok -icon warning -parent $nparent \
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
        #puts stderr "*** $type addtrackworknodetopanel: [$node NumEdges] edges"
        switch [$node NumEdges] {
            0 {
                #puts stderr "*** $type addtrackworknodetopanel: [$node TypeOfNode]"
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
                            eval [list $panel addcomplextrackworktopanel $node \
                                  -name [$node NameOfNode] \
                                  -statecommand [$node SenseScript] \
                                  -normalcommand [$node NormalActionScript] \
                                  -reversecommand [$node ReverseActionScript]] $args
                        }
                    }
                    TrackGraph::Signal {
                        set numheads [$node NumberOfHeads]
                        set aspects  [$node SignalAspects]
                        eval [list $panel addsignaltopanel $node \
                              -name [$node NameOfNode] \
                              -heads $numheads \
                              -aspectlist $aspects]
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
    component addAZATRAXNodeDialog
    component selectAZATRAXNodeDialog
    component editUserCodeDialog
    component addExternalUserModuleDialog

    method buildDialogs {} {

      install addPanelObjectDialog using CTCPanelWindow::AddPanelObjectDialog $win.addPanelObjectDialog -parent $win -ctcpanel $ctcpanel
      install selectPanelObjectDialog using CTCPanelWindow::SelectPanelObjectDialog $win.selectPanelObjectDialog -parent $win -ctcpanel $ctcpanel
      install configurePanelDialog using CTCPanelWindow::ConfigurePanelDialog $win.configurePanelDialog -parent $win
      install addCMRINodeDialog using CTCPanelWindow::AddCMRINodeDialog $win.addCMRINodeDialog -parent $win
      install selectCMRINodeDialog using CTCPanelWindow::SelectCMRINodeDialog $win.selectCMRINodeDialog -parent $win
      install addAZATRAXNodeDialog using CTCPanelWindow::AddAZATRAXNodeDialog $win.addAZATRAXNodeDialog -parent $win
      install selectAZATRAXNodeDialog using CTCPanelWindow::SelectAZATRAXNodeDialog $win.selectAZATRAXNodeDialog -parent $win
      install editUserCodeDialog  using CTCPanelWindow::EditUserCodeDialog $win.editUserCodeDialog -parent $win
      install addExternalUserModuleDialog using CTCPanelWindow::AddExternalUserModuleDialog $win.addExternalUserModuleDialog -parent $win
    }

    method addblocktopanel {node args} {
      #puts stderr "*** $self addblocktopanel $node $args"
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode add -setoftypes {StraightBlock CurvedBlock HiddenBlock StubYard ThroughYard EndBumper}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      if {$options(-openlcbmode)} {
          set node [lindex $result 1]
          switch [lindex $result 0] {
              SWPlate {
                  set openlcbnodes($node) [list -eleclasstype SwitchPlate]
              }
              SIGPlate {
                  set openlcbnodes($node) [list -eleclasstype SignalPlate]
              }
              CodeButton {
                  set openlcbnodes($node) [list -eleclasstype CodeButton]
              }
              Toggle {
                  set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
              }
              PushButton {
                  set openlcbnodes($node) [list -eleclasstype PushButton]
              }
              Lamp {
                  set openlcbnodes($node) [list -eleclasstype Lamp]
              }
              Switch -
              ScissorCrossover -
              Crossover -
              SingleSlip -
              DoubleSlip -
              ThreeWaySW {
                  set openlcbnodes($node) [list -eleclasstype Switch]
              }              
              StraightBlock -
              EndBumper -
              CurvedBlock -
              Crossing -
              HiddenBlock -
              StubYard -
              ThroughYard {
                  set openlcbnodes($node) [list -eleclasstype Block]
              }
              Signal {
                  set openlcbnodes($node) [list -eleclasstype Signal]
              }
          }
          foreach opt {-occupiedeventid -notoccupiedeventid 
              -statenormaleventid -statereverseeventid -eventidaspectlist 
              -oneventid -offeventid -lefteventid -righteventid -centereventid 
              -eventid -normaleventid -reverseeventid -normalindonev 
              -normalindoffev -centerindonev -centerindoffev -reverseindonev 
              -reverseindoffev -centereventid -leftindonev -leftindoffev 
              -centerindonev -centerindoffev -rightindonev -rightindoffev } {
              set val [from result $opt ""]
              if {$val eq ""} {continue}
              lappend openlcbnodes($node) $opt "$val"
          }
      }
      set o [eval [list $ctcpanel create] $result]
      set name       [lindex $result 1]
      $o bind <3> [mymethod _contextMenu $name %x %y %W]
      return $o      
    }
    method addsimpleturnouttopanel {node args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode add -setoftypes {Switch}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      if {$options(-openlcbmode)} {
          set node [lindex $result 1]
          switch [lindex $result 0] {
              SWPlate {
                  set openlcbnodes($node) [list -eleclasstype SwitchPlate]
              }
              SIGPlate {
                  set openlcbnodes($node) [list -eleclasstype SignalPlate]
              }
              CodeButton {
                  set openlcbnodes($node) [list -eleclasstype CodeButton]
              }
              Toggle {
                  set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
              }
              PushButton {
                  set openlcbnodes($node) [list -eleclasstype PushButton]
              }
              Lamp {
                  set openlcbnodes($node) [list -eleclasstype Lamp]
              }
              Switch -
              ScissorCrossover -
              Crossover -
              SingleSlip -
              DoubleSlip -
              ThreeWaySW {
                  set openlcbnodes($node) [list -eleclasstype Switch]
              }              
              StraightBlock -
              EndBumper -
              CurvedBlock -
              Crossing -
              HiddenBlock -
              StubYard -
              ThroughYard {
                  set openlcbnodes($node) [list -eleclasstype Block]
              }
              Signal {
                  set openlcbnodes($node) [list -eleclasstype Signal]
              }
          }
          foreach opt {-occupiedeventid -notoccupiedeventid 
              -statenormaleventid -statereverseeventid -eventidaspectlist 
              -oneventid -offeventid -lefteventid -righteventid -centereventid 
              -eventid -normaleventid -reverseeventid -normalindonev 
              -normalindoffev -centerindonev -centerindoffev -reverseindonev 
              -reverseindoffev -centereventid -leftindonev -leftindoffev 
              -centerindonev -centerindoffev -rightindonev -rightindoffev } {
              set val [from result $opt ""]
              if {$val eq ""} {continue}
              lappend openlcbnodes($node) $opt "$val"
          }
      }
      set o [eval [list $ctcpanel create] $result]
      set name       [lindex $result 1]
      $o bind <3> [mymethod _contextMenu $name %x %y %W]
      return $o      
    }
    method addcomplextrackworktopanel {node args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode add -setoftypes {ScissorCrossover Crossover Crossing SingleSlip DoubleSlip ThreeWaySW}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      if {$options(-openlcbmode)} {
          set node [lindex $result 1]
          switch [lindex $result 0] {
              SWPlate {
                  set openlcbnodes($node) [list -eleclasstype SwitchPlate]
              }
              SIGPlate {
                  set openlcbnodes($node) [list -eleclasstype SignalPlate]
              }
              CodeButton {
                  set openlcbnodes($node) [list -eleclasstype CodeButton]
              }
              Toggle {
                  set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
              }
              PushButton {
                  set openlcbnodes($node) [list -eleclasstype PushButton]
              }
              Lamp {
                  set openlcbnodes($node) [list -eleclasstype Lamp]
              }
              Switch -
              ScissorCrossover -
              Crossover -
              SingleSlip -
              DoubleSlip -
              ThreeWaySW {
                  set openlcbnodes($node) [list -eleclasstype Switch]
              }              
              StraightBlock -
              EndBumper -
              CurvedBlock -
              Crossing -
              HiddenBlock -
              StubYard -
              ThroughYard {
                  set openlcbnodes($node) [list -eleclasstype Block]
              }
              Signal {
                  set openlcbnodes($node) [list -eleclasstype Signal]
              }
          }
          foreach opt {-occupiedeventid -notoccupiedeventid 
              -statenormaleventid -statereverseeventid -eventidaspectlist 
              -oneventid -offeventid -lefteventid -righteventid -centereventid 
              -eventid -normaleventid -reverseeventid -normalindonev 
              -normalindoffev -centerindonev -centerindoffev -reverseindonev 
              -reverseindoffev -centereventid -leftindonev -leftindoffev 
              -centerindonev -centerindoffev -rightindonev -rightindoffev } {
              set val [from result $opt ""]
              if {$val eq ""} {continue}
              lappend openlcbnodes($node) $opt "$val"
          }
      }
      set o [eval [list $ctcpanel create] $result]
      set name       [lindex $result 1]
      $o bind <3> [mymethod _contextMenu $name %x %y %W]
      return $o      
    }
    method addswitchplatetopanel {args} {
      #puts stderr "*** $self addswitchplatetopanel $args"
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode add -setoftypes {SWPlate}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      if {$options(-openlcbmode)} {
          set node [lindex $result 1]
          switch [lindex $result 0] {
              SWPlate {
                  set openlcbnodes($node) [list -eleclasstype SwitchPlate]
              }
              SIGPlate {
                  set openlcbnodes($node) [list -eleclasstype SignalPlate]
              }
              CodeButton {
                  set openlcbnodes($node) [list -eleclasstype CodeButton]
              }
              Toggle {
                  set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
              }
              PushButton {
                  set openlcbnodes($node) [list -eleclasstype PushButton]
              }
              Lamp {
                  set openlcbnodes($node) [list -eleclasstype Lamp]
              }
              Switch -
              ScissorCrossover -
              Crossover -
              SingleSlip -
              DoubleSlip -
              ThreeWaySW {
                  set openlcbnodes($node) [list -eleclasstype Switch]
              }              
              StraightBlock -
              EndBumper -
              CurvedBlock -
              Crossing -
              HiddenBlock -
              StubYard -
              ThroughYard {
                  set openlcbnodes($node) [list -eleclasstype Block]
              }
              Signal {
                  set openlcbnodes($node) [list -eleclasstype Signal]
              }
          }
          foreach opt {-occupiedeventid -notoccupiedeventid 
              -statenormaleventid -statereverseeventid -eventidaspectlist 
              -oneventid -offeventid -lefteventid -righteventid -centereventid 
              -eventid -normaleventid -reverseeventid -normalindonev 
              -normalindoffev -centerindonev -centerindoffev -reverseindonev 
              -reverseindoffev -centereventid -leftindonev -leftindoffev 
              -centerindonev -centerindoffev -rightindonev -rightindoffev } {
              set val [from result $opt ""]
              if {$val eq ""} {continue}
              lappend openlcbnodes($node) $opt "$val"
          }
      }
      set o [eval [list $ctcpanel create] $result]
      set objectType [lindex $result 0]
      set name       [lindex $result 1]
      $o bind <3> [mymethod _contextMenu $name %x %y %W]
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
      return $o
    }
    method addsignaltopanel {node args} {
        #puts stderr "*** $self addsignaltopanel $node $args"
        set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode add -setoftypes {Signal}] $args]
        if {[string equal "$result" {}]} {return}
        $self setdirty
        if {$options(-openlcbmode)} {
            set node [lindex $result 1]
            switch [lindex $result 0] {
                SWPlate {
                    set openlcbnodes($node) [list -eleclasstype SwitchPlate]
                }
                SIGPlate {
                    set openlcbnodes($node) [list -eleclasstype SignalPlate]
                }
                CodeButton {
                    set openlcbnodes($node) [list -eleclasstype CodeButton]
                }
                Toggle {
                    set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
                }
                PushButton {
                    set openlcbnodes($node) [list -eleclasstype PushButton]
                }
                Lamp {
                    set openlcbnodes($node) [list -eleclasstype Lamp]
                }
                Switch -
                ScissorCrossover -
                Crossover -
                SingleSlip -
                DoubleSlip -
                ThreeWaySW {
                    set openlcbnodes($node) [list -eleclasstype Switch]
                }              
                StraightBlock -
                EndBumper -
                CurvedBlock -
                Crossing -
                HiddenBlock -
                StubYard -
                ThroughYard {
                    set openlcbnodes($node) [list -eleclasstype Block]
                }
                Signal {
                    set openlcbnodes($node) [list -eleclasstype Signal]
                }
            }
            foreach opt {-occupiedeventid -notoccupiedeventid 
                -statenormaleventid -statereverseeventid -eventidaspectlist 
                -oneventid -offeventid -lefteventid -righteventid -centereventid 
                -eventid -normaleventid -reverseeventid -normalindonev 
                -normalindoffev -centerindonev -centerindoffev -reverseindonev 
                -reverseindoffev -centereventid -leftindonev -leftindoffev 
                -centerindonev -centerindoffev -rightindonev -rightindoffev } {
                set val [from result $opt ""]
                if {$val eq ""} {continue}
                lappend openlcbnodes($node) $opt "$val"
            }
        }
        set o [eval [list $ctcpanel create] $result]
        set name       [lindex $result 1]
        $o bind <3> [mymethod _contextMenu $name %x %y %W]
        return $o      
    }
    method addpanelobject {args} {
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode add -setoftypes {}] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      if {$options(-openlcbmode)} {
          set node [lindex $result 1]
          switch [lindex $result 0] {
              SWPlate {
                  set openlcbnodes($node) [list -eleclasstype SwitchPlate]
              }
              SIGPlate {
                  set openlcbnodes($node) [list -eleclasstype SignalPlate]
              }
              CodeButton {
                  set openlcbnodes($node) [list -eleclasstype CodeButton]
              }
              Toggle {
                  set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
              }
              PushButton {
                  set openlcbnodes($node) [list -eleclasstype PushButton]
              }
              Lamp {
                  set openlcbnodes($node) [list -eleclasstype Lamp]
              }
              Switch -
              ScissorCrossover -
              Crossover -
              SingleSlip -
              DoubleSlip -
              ThreeWaySW {
                  set openlcbnodes($node) [list -eleclasstype Switch]
              }              
              StraightBlock -
              EndBumper -
              CurvedBlock -
              Crossing -
              HiddenBlock -
              StubYard -
              ThroughYard {
                  set openlcbnodes($node) [list -eleclasstype Block]
              }
              Signal {
                  set openlcbnodes($node) [list -eleclasstype Signal]
              }
          }
          foreach opt {-occupiedeventid -notoccupiedeventid 
              -statenormaleventid -statereverseeventid -eventidaspectlist 
              -oneventid -offeventid -lefteventid -righteventid -centereventid 
              -eventid -normaleventid -reverseeventid -normalindonev 
              -normalindoffev -centerindonev -centerindoffev -reverseindonev 
              -reverseindoffev -centereventid -leftindonev -leftindoffev 
              -centerindonev -centerindoffev -rightindonev -rightindoffev } {
              set val [from result $opt ""]
              if {$val eq ""} {continue}
              lappend openlcbnodes($node) $opt "$val"
          }
      }
      set o [eval [list $ctcpanel create] $result]
      set objectType [lindex $result 0]
      set name       [lindex $result 1]
      $o bind <3> [mymethod _contextMenu $name %x %y %W]
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
      return $o
    }
    method editpanelobject {args} {
      set objectToEdit [eval [list $selectPanelObjectDialog draw] $args]
      if {[string equal "$objectToEdit" {}]} {return}
      set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode edit -object $objectToEdit] $args]
      if {[string equal "$result" {}]} {return}
      $self setdirty
      $ctcpanel delete $objectToEdit
      if {$options(-openlcbmode)} {
          set node [lindex $result 1]
          switch [lindex $result 0] {
              SWPlate {
                  set openlcbnodes($node) [list -eleclasstype SwitchPlate]
              }
              SIGPlate {
                  set openlcbnodes($node) [list -eleclasstype SignalPlate]
              }
              CodeButton {
                  set openlcbnodes($node) [list -eleclasstype CodeButton]
              }
              Toggle {
                  set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
              }
              PushButton {
                  set openlcbnodes($node) [list -eleclasstype PushButton]
              }
              Lamp {
                  set openlcbnodes($node) [list -eleclasstype Lamp]
              }
              Switch -
              ScissorCrossover -
              Crossover -
              SingleSlip -
              DoubleSlip -
              ThreeWaySW {
                  set openlcbnodes($node) [list -eleclasstype Switch]
              }              
              StraightBlock -
              EndBumper -
              CurvedBlock -
              Crossing -
              HiddenBlock -
              StubYard -
              ThroughYard {
                  set openlcbnodes($node) [list -eleclasstype Block]
              }
              Signal {
                  set openlcbnodes($node) [list -eleclasstype Signal]
              }
          }
          foreach opt {-occupiedeventid -notoccupiedeventid 
              -statenormaleventid -statereverseeventid -eventidaspectlist 
              -oneventid -offeventid -lefteventid -righteventid -centereventid 
              -eventid -normaleventid -reverseeventid -normalindonev 
              -normalindoffev -centerindonev -centerindoffev -reverseindonev 
              -reverseindoffev -centereventid -leftindonev -leftindoffev 
              -centerindonev -centerindoffev -rightindonev -rightindoffev } {
              set val [from result $opt ""]
              if {$val eq ""} {continue}
              lappend openlcbnodes($node) $opt "$val"
          }
      }
      set o [eval [list $ctcpanel create] $result]
      set name       [lindex $result 1]
      $o bind <3> [mymethod _contextMenu $name %x %y %W]
      return $o
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
        if {$options(-openlcbmode)} {
            catch {unset openlcbnodes($objectToDelete)}
        }
	$self setdirty
      }
    }
    variable _cm {}
    method _contextMenu {name mx my w} {
        if {$_cm eq {}} {set _cm ${win}.cm}
        if {[winfo exists $_cm]} {destroy $_cm}
        menu $_cm 
        $_cm add command -label [_m "Menu|Context|Edit"] \
              -command [mymethod _edit_from_context $name]
        $_cm add command -label [_m "Menu|Context|Delete"] \
              -command [mymethod _delete_from_context $name]
        $_cm add command -label [_m "Menu|Context|Info"] \
              -command [mymethod _info_from_context $name]
        set root_x [expr {$mx + [winfo rootx $w]}]
        set root_y [expr {$my + [winfo rooty $w]}]
        $_cm post $root_x $root_y
        update idle
        tk_menuSetFocus $_cm
    }
    method _edit_from_context {name args} {
        #puts stderr "*** $self _edit_from_context $name"
        $_cm unpost
        set objectToEdit $name
        set result [eval [list $addPanelObjectDialog draw -simplemode $options(-simplemode) -openlcbmode $options(-openlcbmode) -mode edit -object $objectToEdit] $args]
        if {[string equal "$result" {}]} {return}
        $self setdirty
        $ctcpanel delete $objectToEdit
        if {$options(-openlcbmode)} {
            set node [lindex $result 1]
            switch [lindex $result 0] {
                SWPlate {
                    set openlcbnodes($node) [list -eleclasstype SwitchPlate]
                }
                SIGPlate {
                    set openlcbnodes($node) [list -eleclasstype SignalPlate]
                }
                CodeButton {
                    set openlcbnodes($node) [list -eleclasstype CodeButton]
                }
                Toggle {
                    set openlcbnodes($node) [list -eleclasstype ToggleSwitch]
                }
                PushButton {
                    set openlcbnodes($node) [list -eleclasstype PushButton]
                }
                Lamp {
                    set openlcbnodes($node) [list -eleclasstype Lamp]
                }
                Switch -
                ScissorCrossover -
                Crossover -
                SingleSlip -
                DoubleSlip -
                ThreeWaySW {
                    set openlcbnodes($node) [list -eleclasstype Switch]
                }              
                StraightBlock -
                EndBumper -
                CurvedBlock -
                Crossing -
                HiddenBlock -
                StubYard -
                ThroughYard {
                    set openlcbnodes($node) [list -eleclasstype Block]
                }
                Signal {
                    set openlcbnodes($node) [list -eleclasstype Signal]
                }
            }
            foreach opt {-occupiedeventid -notoccupiedeventid 
                -statenormaleventid -statereverseeventid -eventidaspectlist 
                -oneventid -offeventid -lefteventid -righteventid -centereventid 
                -eventid -normaleventid -reverseeventid -normalindonev 
                -normalindoffev -centerindonev -centerindoffev -reverseindonev 
                -reverseindoffev -centereventid -leftindonev -leftindoffev 
                -centerindonev -centerindoffev -rightindonev -rightindoffev } {
                set val [from result $opt ""]
                if {$val eq ""} {continue}
                lappend openlcbnodes($node) $opt "$val"
            }
        }
        set o [eval [list $ctcpanel create] $result]
        set name       [lindex $result 1]
        $o bind <3> [mymethod _contextMenu $name %x %y %W]
        return $o
    }
    method _delete_from_context {name args} {
        #puts stderr "*** $self _delete_from_context $name"
        $_cm unpost
        set objectToDelete $name
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
    method _info_from_context {name args} {
        CTCPanelWindow::displayPanelObject draw -ctcpanel $ctcpanel \
              -simplemode $options(-simplemode) -object $name -parent $win \
              -title [_ "Object %s" $name] -openlcbmode $options(-openlcbmode) 
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
      set comment [lindex $result 1]
      set opts  "[lrange $result 2 end]"
      set cmrinodes($board) "$opts"
      if {$comment ne ""} {set cmrinodes_comments($board) "$comment"}
      $self setdirty
    }
    method editcmrinode {args} {
      set nodeToEdit [eval [list $selectCMRINodeDialog draw] $args]
      if {[string equal "$nodeToEdit" {}]} {return}
      set result [eval [list $addCMRINodeDialog draw -mode edit -node $nodeToEdit] $args]
      #puts stderr "*** $self editcmrinode: result = $result"
      if {[string equal "$result" {}]} {return}
      set board [lindex $result 0]
      set comment [lindex $result 1]
      set opts  "[lrange $result 2 end]"
      set cmrinodes($board) "$opts"
      if {$comment ne ""} {set cmrinodes_comments($board) "$comment"}
      $self setdirty
    }
    method deletecmrinode {args} {
      set nodeToDelete [eval [list $selectCMRINodeDialog draw] $args]
      if {[string equal "$nodeToDelete" {}]} {return}
      if {[tk_messageBox -type yesno -icon question \
			-message [_ "Really delete $nodeToDelete?"] \
			-parent $win]} {
	unset cmrinodes($nodeToDelete)
	catch {unset cmrinodes_comments($nodeToDelete)}
	$self setdirty
      }
    }
    ##### AZATRAX methods
    method addazatraxnode {args} {
      set result [eval [list $addAZATRAXNodeDialog draw -mode add] $args]
      if {[string equal "$result" {}]} {return}
      set node [lindex $result 0]
      set serial [lindex $result 1]
      set prod  [lindex $result 2]
      set azatraxnodes($node) [list $serial $prod]
      set comment [lindex $result 3]
      if {$comment ne ""} {set azatraxnodes_comments($node) $comment}
      $self setdirty
    }
    method editazatraxnode {args} {
      set nodeToEdit [eval [list $selectAZATRAXNodeDialog draw] $args]
      if {[string equal "$nodeToEdit" {}]} {return}
      set result [eval [list $addAZATRAXNodeDialog draw -mode edit -node $nodeToEdit] $args]
      if {[string equal "$result" {}]} {return}
      set node [lindex $result 0]
      set serial [lindex $result 1]
      set prod  [lindex $result 2]
      set azatraxnodes($node) [list $serial $prod]
      set comment [lindex $result 3]
      if {$comment ne ""} {set azatraxnodes_comments($node) $comment}
      $self setdirty
    }
    method deleteazatraxnode {args} {
      set nodeToDelete [eval [list $selectAZATRAXNodeDialog draw] $args]
      if {[string equal "$nodeToDelete" {}]} {return}
      if {[tk_messageBox -type yesno -icon question \
			-message [_ "Really delete $nodeToDelete?"] \
			-parent $win]} {
	unset azatraxnodes($nodeToDelete)
	catch {unset azatraxnodes_comments($nodeToDelete)}
	$self setdirty
      }
    }
    method AddExternalUserModule {args} {
        set addModuleNameAndDir [eval [list $addExternalUserModuleDialog draw] $args]
        if {"$addModuleNameAndDir" eq ""} {return}
        foreach {name dir} $addModuleNameAndDir {break}
        set externalUserModules($name) $dir
        set userCode "package require $name\n$userCode"
    }
    method AddExternalUserModule_ {name dir} {
        set externalUserModules($name) $dir
        set userCode "package require $name\n$userCode"
    }
    method externalUserModuleDir {packageName} {
        if {[catch {set externalUserModules($packageName)} dir]} {
            return -code error -errorinfo $::errorInfo -errorcode $::errorCode $dir
        } else {
            return $dir
        }
    }
    method AddAdditionalPackage {packagename} {
      if {[lsearch -exact $additionalPackages $packagename] >= 0} {
	tk_messageBox -icon info -type ok -message [format [_ "Package %s has already been added!"] $packagename]
	return
      }
      switch $packagename {
	XPressNet {
	  set userCode "package require Xpressnet\n$userCode"
	}
	NCE {
	  set userCode "package require NCE\n$userCode"
	}
	RailDriverSupport {
	  set userCode "package require RaildriverClient\n$userCode"
	}
	default {
	  tk_messageBox -icon error -type ok -message [format [_ "Unknown package %s!"] $packagename]
	  return
	}
      }
      lappend additionalPackages $packagename
    }
    method AddModule {modname} {
        #puts stderr "*** $self AddModule $modname"
      set startPattern "^#\\* ${modname}:START \\*\$"
      set endPattern "^#\\* ${modname}:END \\*\$"
      #puts stderr "*** $self AddModule: startPattern = '$startPattern', endPattern = '$endPattern'"
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
      #puts stderr "*** $self AddModule: moduleBuffer = '$moduleBuffer'"
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
      if {$options(-hasazatrax)} {
	append loop "  # Read all AZATRAX state data\n"
	foreach node [array names azatraxnodes] {
	  append loop "  $node GetStateData\n"
	}
      }
      append loop "  # Invoke all trackwork and get occupicency\n"
      foreach obj [$ctcpanel objectlist] {
          #puts stderr "*** $self GenerateMainLoop: \[$ctcpanel itemconfigure $obj\] = [$ctcpanel itemconfigure $obj]"
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
          #puts stderr "*** $self GenerateMainLoop: start = $start, end = $end"
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
    option -openlcbmode -default no
    option -heads -default 0
    option -aspectlist -default {}

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
    component azatraxSerialNumberLE;#	Azatrax serial number (SWitch Plates in simple mode)
    component azatraxProductTypeLCB;#	Azatrax product type and index (SWitch Plates in simple mode)
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
    # OpenLCB events
    # Sensors
    component occupiedeventidLE
    component notoccupiedeventidLE
    component statenormaleventidLE
    component statereverseeventidLE
    # Actions
    component lefteventidLE
    component righteventidLE
    component centereventidLE
    component eventidLE
    component normaleventidLE
    component reverseeventidLE
    # Indicators
    component aspectlistLF
    component   aspectlistSTabNB
    variable    aspectlist -array {}
    component   addaspectB
    component normalindonevLE
    component normalindoffevLE
    component centerindonevLE
    component centerindoffevLE
    component reverseindonevLE
    component reverseindoffevLE
    component leftindonevLE
    component leftindoffevLE
    component rightindonevLE
    component rightindoffevLE
    component oneventidLE
    component offeventidLE
    
    
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
    typevariable objectTypeIndicatorEvents -array {
        Signal {aspectlist}
        SWPlate {normal center reverse}
        SIGPlate {left center right}
        Lamp {onoff}
    }

    constructor {args} {
        #puts stderr "*** $type create $self $args"
      installhull using Dialog -bitmap questhead -default add \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Add Panel Object to panel"] \
                                -parent [from args -parent]
      $hull add add    -text Add    -command [mymethod _Add]
      $hull add cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add redraw -text Redraw -command [mymethod redrawgraphic]
      $hull add help -text Help -command {HTMLHelp help {Add Panel Object Dialog}}
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
		      "Label|Action Script:" "Label|Azatrax S#:" \
                      "Label|Switch Name:" "Label|Azatrax Product:" \
                      "Label|Occupied EventID:" "Label|Not Occupied EventID:" \
                      "Label|State Normal EventID:" "Label|State Reversed EventID:" \
                      "Label|Left EventID:" "Label|Right EventID:" \
                      "Label|Center EventID:" "Label|Command EventID:" \
                      "Label|Normal EventID:" "Label|Reverse EventID:" \
                      "Label|Normal Indicator On EventID:" \
                      "Label|Normal Indicator Off EventID:" \
                      "Label|Center Indicator On EventID:" \
                      "Label|Center Indicator Off EventID:" \
                      "Label|Reverse Indicator On EventID:" \
                      "Label|Reverse Indicator Off EventID:" \
                      "Label|Left Indicator On EventID:" \
                      "Label|Left Indicator Off EventID:" \
                      "Label|Right Indicator On EventID:" \
                      "Label|Right Indicator Off EventID:" \
                      "Label|Lamp On EventID:" \
                      "Label|Lamp Off EventID:" ]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $nameLE -fill x
      install objectTypeTF using ttk::labelframe $frame.objectTypeTF \
            -text [_m "Label|Object Type"] \
            -labelanchor nw
      pack $objectTypeTF -fill both
      set otframe $objectTypeTF
      set row 0
      foreach {rb0 rb1 rb2 rb3 rb4} {sWPlateRB sIGPlateRB codeButtonRB toggleRB pushButtonRB lampRB cTCLabelRB straightBlockRB endBumperRB curvedBlockRB hiddenBlockRB stubYardRB throughYardRB crossingRB switchRB scissorCrossoverRB crossoverRB singleSlipRB doubleSlipRB threeWaySWRB signalRB schLabelRB} {
	foreach rb [list $rb0 $rb1 $rb2 $rb3 $rb4] col {0 1 2 3 4} {
	  if {[string length "$rb"] == 0} {continue}
          #puts stderr "*** $type create: rb = '$rb', col = $col"
	  regsub {RB$} "$rb" {} name
	  regexp {^([[:alpha:]])} "$name" -> char
	  regsub {^[[:alpha:]]} "$name" [string toupper $char] name
	  install $rb using ttk::radiobutton $otframe.$rb \
				-text "$name" \
				-command [mymethod packOptionsAndRedrawGr "$name"] \
				-value  "$name" \
				-variable [myvar objectType]
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
      $graphicSW setwidget $graphicCanvas
      bind $graphicCanvas <Configure> [mymethod updateSR %W %h %w]
      install controlPointLCB using LabelComboBox $frame.controlPointLCB \
						-label [_m "Label|Control Point:"] \
						-labelwidth $lwidth
      pack $controlPointLCB -fill x
      install optionsFrame using frame $frame.optionsFrame -borderwidth 0 \
							   -relief flat
      pack $optionsFrame -expand yes -fill both
      install xyframe1 using ttk::labelframe $optionsFrame.xyframe1 \
            -text [_m "Label|First Coord"] \
            -labelanchor nw
      install x1LSB using LabelSpinBox $xyframe1.x1LSB \
						-label X: \
						-textvariable [myvar x1] \
						-range {0 1000 1}
      pack $x1LSB -side left -fill x -expand yes
      install y1LSB using LabelSpinBox $xyframe1.y1LSB \
						-label Y: \
						-textvariable [myvar y1] \
						-range {0 1000 1}
      pack $y1LSB -side left -fill x -expand yes
      install b1 using ttk::button $xyframe1.b1 \
            -text [_m "Button|Use Crosshairs"]
      pack $b1 -side right
      install xyframe2 using ttk::labelframe $optionsFrame.xyframe2 \
            -text [_m "Label|Second Coord"] \
            -labelanchor nw
      install x2LSB using LabelSpinBox $xyframe2.x2LSB \
						-label X: \
						-textvariable [myvar x2] \
						-range {0 1000 1}
      pack $x2LSB -side left -fill x -expand yes
      install y2LSB using LabelSpinBox $xyframe2.y2LSB \
						-label Y: \
						-textvariable [myvar y2] \
						-range {0 1000 1}
      pack $y2LSB -side left -fill x -expand yes
      install b2 using ttk::button $xyframe2.b2 \
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
						-values {below above right left}
      $positionLCB set [lindex [$positionLCB cget -values] 0]
      install orientationLCB using LabelComboBox $optionsFrame.orientationLCB \
						-label [_m "Label|Orientation:"] \
						-labelwidth $lwidth \
						-values {0 1 2 3 4 5 6 7} \
						-editable no
      ## <<ComboboxSelected>>
      $orientationLCB set [lindex [$orientationLCB cget -values] 0]
      install hvorientationLCB using LabelComboBox $optionsFrame.hvorientationLCB \
						-label [_m "Label|Orientation:"] \
						-labelwidth $lwidth \
						-values {horizontal vertical} \
						-editable no
      $hvorientationLCB set [lindex [$hvorientationLCB cget -values] 0]
      install flippedLCB using LabelComboBox $optionsFrame.flippedLCB \
						-label [_m "Label|Flipped?"] \
						-labelwidth $lwidth \
						-values {no yes} \
						-editable no
      $flippedLCB set [lindex [$flippedLCB cget -values] 0]
      install headsLCB using LabelComboBox $optionsFrame.headsLCB \
						-label [_m "Label|Heads:"] \
						-labelwidth $lwidth \
						-values {1 2 3} \
						-editable no
      $headsLCB set [lindex [$headsLCB cget -values] 0]
      install typeLCB using LabelComboBox $optionsFrame.typeLCB \
						-label [_m "Label|Crossing Type:"] \
						-labelwidth $lwidth \
						-values {x90 x45} \
						-editable no
      $typeLCB set [lindex [$typeLCB cget -values] 0]
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
						-editable no
      $hascenterLCB set [lindex [$hascenterLCB cget -values] 0]
      install colorLSC using LabelSelectColor $optionsFrame.colorLSC \
						      -label [_m "Label|Color:"] \
						      -labelwidth $lwidth \
						      -text white
      install azatraxSerialNumberLE using LabelEntry $optionsFrame.azatraxSerialNumberLE \
						-label [_m "Label|Azatrax S#:"] \
						-labelwidth $lwidth
      install azatraxProductTypeLCB using LabelComboBox $optionsFrame.azatraxProductTypeLCB \
						-label [_m "Label|Azatrax Product:"] \
						-labelwidth $lwidth \
						-editable no \
						-values {MRD2-U {SL2 Switch 1} 
							 {SL2 Switch 2} 
							 {SR4 Switch 1} 
							 {SR4 Switch 2}}
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
      $commandSW setwidget $commandText
      ### OpenLCB events
      # Sensors
      install occupiedeventidLE using LabelEntry $optionsFrame.occupiedeventidLE \
            -label [_m "Label|Occupied EventID:"] \
            -labelwidth $lwidth
      install notoccupiedeventidLE using LabelEntry $optionsFrame.notoccupiedeventidLE \
            -label [_m "Label|Not Occupied EventID:"] \
            -labelwidth $lwidth
      install statenormaleventidLE using LabelEntry $optionsFrame.statenormaleventidLE \
            -label [_m "Label|State Normal EventID:"] \
            -labelwidth $lwidth
      install statereverseeventidLE using LabelEntry $optionsFrame.statereverseeventidLE \
            -label [_m "Label|State Reversed EventID:"] \
            -labelwidth $lwidth
      # Actions
      install lefteventidLE using LabelEntry $optionsFrame.lefteventidLE \
            -label [_m "Label|Left EventID:"] \
            -labelwidth $lwidth
      install righteventidLE using LabelEntry $optionsFrame.righteventidLE \
            -label [_m "Label|Right EventID:"] \
            -labelwidth $lwidth
      install centereventidLE using LabelEntry $optionsFrame.centereventidLE \
            -label [_m "Label|Center EventID:"] \
            -labelwidth $lwidth
      install eventidLE using LabelEntry $optionsFrame.eventidLE \
            -label [_m "Label|Command EventID:"] \
            -labelwidth $lwidth
      install normaleventidLE using LabelEntry $optionsFrame.normaleventidLE \
            -label [_m "Label|Normal EventID:"] \
            -labelwidth $lwidth
      install reverseeventidLE using LabelEntry $optionsFrame.reverseeventidLE \
            -label [_m "Label|Reverse EventID:"] \
            -labelwidth $lwidth
      # Indicators
      install aspectlistLF using ttk::labelframe $optionsFrame.aspectlistLF \
            -labelanchor nw -text [_m "Label|Signal Aspect Events"]
      install aspectlistSTabNB using ScrollTabNotebook \
            $aspectlistLF.aspectlistSTabNB
      pack $aspectlistSTabNB -expand yes -fill both
      install addaspectB using ttk::button $aspectlistLF.addaspectB \
            -text [_m "Label|Add another aspect"] \
            -command [mymethod _addaspect]
      pack $addaspectB -fill x
      install normalindonevLE using LabelEntry $optionsFrame.normalindonevLE \
            -label [_m "Label|Normal Indicator On EventID:"] \
            -labelwidth $lwidth
      install normalindoffevLE using LabelEntry $optionsFrame.normalindoffevLE \
            -label [_m "Label|Normal Indicator Off EventID:"] \
            -labelwidth $lwidth
      install centerindonevLE using LabelEntry $optionsFrame.centerindonevLE \
            -label [_m "Label|Center Indicator On EventID:"] \
            -labelwidth $lwidth
      install centerindoffevLE using LabelEntry $optionsFrame.centerindoffevLE \
            -label [_m "Label|Center Indicator Off EventID:"] \
            -labelwidth $lwidth
      install reverseindonevLE using LabelEntry $optionsFrame.reverseindonevLE \
            -label [_m "Label|Reverse Indicator On EventID:"] \
            -labelwidth $lwidth
      install reverseindoffevLE using LabelEntry $optionsFrame.reverseindoffevLE \
            -label [_m "Label|Reverse Indicator Off EventID:"] \
            -labelwidth $lwidth
      install leftindonevLE using LabelEntry $optionsFrame.leftindonevLE \
            -label [_m "Label|Left Indicator On EventID:"] \
            -labelwidth $lwidth
      install leftindoffevLE using LabelEntry $optionsFrame.leftindoffevLE \
            -label [_m "Label|Left Indicator Off EventID:"] \
            -labelwidth $lwidth
      install rightindonevLE using LabelEntry $optionsFrame.rightindonevLE \
            -label [_m "Label|Right Indicator On EventID:"] \
            -labelwidth $lwidth
      install rightindoffevLE using LabelEntry $optionsFrame.rightindoffevLE \
            -label [_m "Label|Right Indicator Off EventID:"] \
            -labelwidth $lwidth
      install oneventidLE using LabelEntry $optionsFrame.oneventidLE \
            -label [_m "Label|Lamp On EventID:"] \
            -labelwidth $lwidth
      install offeventidLE using LabelEntry $optionsFrame.offeventidLE \
            -label [_m "Label|Lamp Off EventID:"] \
            -labelwidth $lwidth
      
      $self configurelist $args
      bind $win <<ComboboxSelected>> [mymethod redrawgraphic]
      
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
    proc pairswap {pairlist} {
        #puts stderr "*** pairswap $pairlist"
        set result [list]
        foreach pair $pairlist {
            #puts stderr "*** pairswap: pair = $pair"
            foreach {b a} $pair {break}
            #puts stderr "*** pairswap: a = $a, b = $b"
            lappend result $a $b
            #puts stderr "*** pairswap: result is $result"
        }
        return $result
    }
    method draw {args} {
      #puts stderr "*** $self draw $args"
      $self configurelist $args
      set options(-parent) [$self cget -parent]

      if {"$options(-name)" ne ""} {
	$labelLE configure -text "$options(-name)"
	$nameLE configure -text "$options(-name)"
      }
      if {"$options(-occupiedcommand)" ne ""} {
          if {$options(-openlcbmode)} {
              if {[regexp {^([[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]])$} "$options(-occupiedcommand)" -> occId nooccId] > 0} {
                  $occupiedeventidLE configure -text $occId
                  $notoccupiedeventidLE configure -text $nooccId
              }
          } else {
              $occupiedcommandText delete 1.0 end
              $occupiedcommandText insert end "$options(-occupiedcommand)"
          }
      }
      if {"$options(-statecommand)" ne ""} {
          if {$options(-openlcbmode)} {
              if {[regexp {^([[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]])$} "$options(-statecommand)" -> normalId reverseId] > 0} {
                  $statenormaleventidLE configure -text $normalId
                  $normalindonevLE configure -text $normalId
                  $reverseindoffevLE configure -text $normalId
                  $statereverseeventidLE configure -text $reverseId
                  $reverseindonevLE configure -text $reverseId
                  $normalindoffevLE configure -text $reverseId
              }
          } else {
              $statecommandText delete 1.0 end
              $statecommandText insert end "$options(-statecommand)"
          }
      }
      if {"$options(-normalcommand)" ne ""} {
          if {$options(-openlcbmode)} {
              if {[regexp {^([[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]])$} "$options(-normalcommand)" -> smnormID] > 0} {
                  $normaleventidLE configure -text $smnormID
              }
          } else {
              $normalcommandText delete 1.0 end
              $normalcommandText insert end "$options(-normalcommand)"
          }
      }
      if {"$options(-reversecommand)" ne ""} {
          if {$options(-openlcbmode)} {
              if {[regexp {^([[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]]\.[[:xdigit:]][[:xdigit:]])$} "$options(-reversecommand)" -> smrevID] > 0} {
                  $reverseeventidLE configure -text $smrevID
              }
          } else {
              $reversecommandText delete 1.0 end
              $reversecommandText insert end "$options(-reversecommand)"
          }
      }
      if {"$options(-heads)" ne ""} {
          $headsLCB set $options(-heads)
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
          #puts stderr "*** $self draw: objectType = $objectType"
          #puts stderr "*** $self draw: options(-object) = '$options(-object)'"
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
      if {"$options(-aspectlist)" ne ""} {
          if {$options(-openlcbmode)} {
              $self clearallaspects
              $self populateaspects [pairswap $options(-aspectlist)]
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
      #puts stderr "*** $self redrawgraphic"
      $graphicCanvas delete all
      if {[lsearch -exact $objectTypeOptions($objectType) radius] >= 0} {
	if {[$self doRangeCheck]} {
	  tk_messageBox -type ok -icon warning -parent $win \
		-message [_ "Range check warning.  Radius value adjusted."]
	}
      }
      set opts {}
      #puts stderr "*** $self redrawgraphic: calling getOptions"
      set savedopenlcbmode $options(-openlcbmode)
      set options(-openlcbmode) no
      $self getOptions opts
      set options(-openlcbmode) $savedopenlcbmode
      #puts stderr "*** $self redrawgraphic: opts is $opts"
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
        #puts stderr "*** $self packOptions: options(-simplemode) is $options(-simplemode)"
        if {$options(-simplemode) && $objtype eq "SWPlate"} {
            pack $azatraxSerialNumberLE -fill x
            $azatraxSerialNumberLE configure -text ""
            pack $azatraxProductTypeLCB -fill x
            $azatraxProductTypeLCB set [lindex [$azatraxProductTypeLCB cget -values] 0]
            pack $switchNameLE -fill x
            $switchNameLE configure -text ""
        }
        foreach opt $objectTypeOptions($objtype) {
            switch -exact $opt {
                normalcommand {
                    if {$options(-openlcbmode)} {
                        pack $normaleventidLE -fill x
                    } else {
                        pack $normalcommandLF -fill x
                        if {$options(-simplemode)} {
                            $normalcommandText configure -state disabled
                        } else {
                            $normalcommandText configure -state normal
                        }
                    }
                }
                reversecommand {
                    if {$options(-openlcbmode)} {
                        pack $reverseeventidLE -fill x
                    } else {
                        pack $reversecommandLF -fill x
                        if {$options(-simplemode)} {
                            $reversecommandText configure -state disabled
                        } else {
                            $reversecommandText configure -state normal
                        }
                    }
                }
                leftcommand {
                    if {$options(-openlcbmode)} {
                        pack $lefteventidLE -fill x
                    } else {
                        pack $leftcommandLF -fill x
                        if {$options(-simplemode)} {
                            $leftcommandText  configure -state disabled
                        } else {
                            $leftcommandText  configure -state normal
                        }
                    }
                }
                centercommand {
                    if {$options(-openlcbmode)} {
                        pack $centereventidLE -fill x
                    } else {
                        pack $centercommandLF -fill x
                        if {$options(-simplemode)} {
                            $centercommandText  configure -state disabled
                        } else {
                            $centercommandText  configure -state normal
                        }
                    }
                }
                rightcommand {
                    if {$options(-openlcbmode)} {
                        pack $righteventidLE -fill x
                    } else {
                        pack $rightcommandLF -fill x
                        if {$options(-simplemode)} {
                            $rightcommandText  configure -state disabled
                        } else {
                            $rightcommandText  configure -state normal
                        }
                    }
                }
                command {
                    if {$options(-openlcbmode)} {
                        pack $eventidLE -fill x
                    } else {
                        pack $commandLF -fill x
                        if {$options(-simplemode)} {
                            $commandText  configure -state disabled
                        } else {
                            $commandText  configure -state normal
                        }
                    }
                }
                statecommand {
                    if {$options(-openlcbmode)} {
                        pack $statenormaleventidLE -fill x
                        pack $statereverseeventidLE -fill x
                    } else {
                        pack $statecommandLF -fill x
                        if {$options(-simplemode)} {
                            $statecommandText  configure -state disabled
                        } else {
                            $statecommandText  configure -state normal
                        }
                    }
                }
                occupiedcommand {
                    if {$options(-openlcbmode)} {
                        pack $occupiedeventidLE -fill x
                        pack $notoccupiedeventidLE -fill x
                    } else {
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
        if {$options(-openlcbmode)} {
            if {[info exists objectTypeIndicatorEvents($objtype)]} {
                foreach opt $objectTypeIndicatorEvents($objtype) {
                    switch -exact $opt {
                        aspectlist {
                            $self clearallaspects
                            pack $aspectlistLF -fill both -expand yes
                        }
                        normal {
                            pack $normalindonevLE -fill x
                            pack $normalindoffevLE -fill x
                        }
                        center {
                            pack $centerindonevLE -fill x
                            pack $centerindoffevLE -fill x
                        }
                        reverse {
                            pack $reverseindonevLE -fill x
                            pack $reverseindoffevLE -fill x
                        }
                        left {
                            pack $leftindonevLE -fill x
                            pack $leftindoffevLE -fill x
                        }
                        right {
                            pack $rightindonevLE -fill x
                            pack $rightindoffevLE -fill x
                        }
                        onoff {
                            pack $oneventidLE -fill x
                            pack $offeventidLE -fill x
                        }
                    }
                }
            }
        }
    
    }
    method packAndConfigureOptions {objtype} {
        foreach slave [pack slaves $optionsFrame] {pack forget $slave}
        #puts stderr "*** $self packAndConfigureOptions: objtype = $objtype, options(-object) = $options(-object), opts are [$options(-ctcpanel) itemconfigure $options(-object)]"
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
        #puts stderr "*** $self packAndConfigureOptions: options(-simplemode) is $options(-simplemode)"
        if {$options(-simplemode) && $objtype eq "SWPlate"} {
            set command "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
            set switch {}
            set azatraxsn  {}
            set azatraxprod {}
            set azatraxswn {}
            if {[regexp {NormalMRD[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => switch azatraxsn] > 0} {
                set azatraxprod MRD2-U
            } elseif {[regexp {NormalSL2[[:space:]]+([[:digit:]])[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => azatraxswn switch azatraxsn] > 0} {
                set azatraxprod "SL2 Switch $azatraxswn"
            } elseif {[regexp {NormalSR4[[:space:]]+([[:digit:]])[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => azatraxswn switch azatraxsn] > 0} {
                set azatraxprod "SR4 Switch $azatraxswn"
            } elseif {[regexp {Normal[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => switch azatraxsn] > 0} {
                set azatraxprod MRD2-U
            }
            pack $azatraxSerialNumberLE -fill x
            $azatraxSerialNumberLE configure -text "$azatraxsn"
            pack $azatraxProductTypeLCB -fill x
            $azatraxProductTypeLCB set $azatraxprod
            pack $switchNameLE -fill x
            $switchNameLE configure -text "$switch"
            
        }
        foreach opt $objectTypeOptions($objtype) {
            switch -exact $opt {
                normalcommand {
                    if {$options(-openlcbmode)} {
                        pack $normaleventidLE -fill x
                        $normaleventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -normaleventid]"
                    } else {
                        pack $normalcommandLF -fill x
                        $normalcommandText configure -state normal
                        $normalcommandText delete 1.0 end
                        $normalcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
                        if {$options(-simplemode)} {
                            $normalcommandText configure -state disabled
                        } else {
                            $normalcommandText configure -state normal
                        }
                    }
                }
                reversecommand {
                    if {$options(-openlcbmode)} {
                        pack $reverseeventidLE -fill x
                        $reverseeventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -reverseeventid]"
                    } else {
                        pack $reversecommandLF -fill x
                        $reversecommandText configure -state normal
                        $reversecommandText delete 1.0 end
                        $reversecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -reversecommand]"
                        if {$options(-simplemode)} {
                            $reversecommandText configure -state disabled
                        } else {
                            $reversecommandText configure -state normal
                        }
                    }
                }
                leftcommand {
                    if {$options(-openlcbmode)} {
                        pack $lefteventidLE -fill x
                        $lefteventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -lefteventid]"
                    } else {
                        pack $leftcommandLF -fill x
                        $leftcommandText  configure -state normal
                        $leftcommandText delete 1.0 end
                        $leftcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -leftcommand]"
                        if {$options(-simplemode)} {
                            $leftcommandText  configure -state disabled
                        } else {
                            $leftcommandText  configure -state normal
                        }
                    }
                }
                centercommand {
                    if {$options(-openlcbmode)} {
                        pack $centereventidLE -fill x
                        $centereventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -centereventid]"
                    } else {
                        pack $centercommandLF -fill x
                        $centercommandText configure -state normal
                        $centercommandText delete 1.0 end
                        $centercommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -centercommand]"
                        if {$options(-simplemode)} {
                            $centercommandText  configure -state disabled
                        } else {
                            $centercommandText  configure -state normal
                        }
                    }
                }
                rightcommand {
                    if {$options(-openlcbmode)} {
                        pack $righteventidLE -fill x
                        $righteventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -righteventid]"
                    } else {
                        pack $rightcommandLF -fill x
                        $rightcommandText configure -state normal
                        $rightcommandText delete 1.0 end
                        $rightcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -rightcommand]"
                        if {$options(-simplemode)} {
                            $rightcommandText  configure -state disabled
                        } else {
                            $rightcommandText  configure -state normal
                        }
                    }
                }
                command {
                    if {$options(-openlcbmode)} {
                        pack $eventidLE -fill x
                        $eventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -eventid]"
                    } else {
                        pack $commandLF -fill x
                        $commandText configure -state normal
                        $commandText delete 1.0 end
                        $commandText insert end "[$options(-ctcpanel) itemcget $options(-object) -command]"
                        if {$options(-simplemode)} {
                            $commandText  configure -state disabled
                        } else {
                            $commandText  configure -state normal
                        }
                    }
                }
                statecommand {
                    if {$options(-openlcbmode)} {
                        pack $statenormaleventidLE -fill x
                        pack $statereverseeventidLE -fill x
                        $statenormaleventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -statenormaleventid]"
                        $statereverseeventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -statereverseeventid]"
                    } else {
                        pack $statecommandLF -fill x
                        $statecommandText configure -state normal
                        $statecommandText delete 1.0 end
                        $statecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -statecommand]"
                        if {$options(-simplemode)} {
                            $statecommandText  configure -state disabled
                        } else {
                            $statecommandText  configure -state normal
                        }
                    }
                }
                occupiedcommand {
                    if {$options(-openlcbmode)} {
                        pack $occupiedeventidLE -fill x
                        pack $notoccupiedeventidLE -fill x
                        $occupiedeventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -occupiedeventid]"
                        $notoccupiedeventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -notoccupiedeventid]"
                    } else {
                        pack $occupiedcommandLF -fill x
                        $occupiedcommandText configure -state normal
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
        if {$options(-openlcbmode)} {
            if {[info exists objectTypeIndicatorEvents($objtype)]} {
                foreach opt $objectTypeIndicatorEvents($objtype) {
                    switch -exact $opt {
                        aspectlist {
                            $self clearallaspects
                            $self populateaspects [$options(-parent) getOpenLCBNodeOpt $options(-object) -eventidaspectlist]
                            pack $aspectlistLF -fill both -expand yes
                        }
                        normal {
                            pack $normalindonevLE -fill x
                            $normalindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -normalindonev]"
                            pack $normalindoffevLE -fill x
                            $normalindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -normalindoffev]"
                        }
                        center {
                            pack $centerindonevLE -fill x
                            $centerindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -centerindonev]"
                            pack $centerindoffevLE -fill x
                            $centerindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -centerindoffev]"
                        }
                        reverse {
                            pack $reverseindonevLE -fill x
                            $reverseindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -reverseindonev]"
                            pack $reverseindoffevLE -fill x
                            $reverseindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -reverseindoffev]"
                        }
                        left {
                            pack $leftindonevLE -fill x
                            $leftindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -leftindonev]"
                            pack $leftindoffevLE -fill x
                            $leftindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -leftindoffev]"
                        }
                        right {
                            pack $rightindonevLE -fill x
                            $rightindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -rightindonev]"
                            pack $rightindoffevLE -fill x
                            $rightindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -rightindoffev]"
                        }
                        onoff {
                            pack $oneventidLE -fill x
                            $oneventidLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -oneventid]"
                            pack $offeventidLE -fill x
                            $offeventidLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -offeventid]"
                        }
                    }
                }
            }
        }
    }
    method clearallaspects {} {
        foreach aspectfr [array names aspectlist *,frame] {
            set fr $aspectlist($aspectfr)
            $aspectlistSTabNB forget $aspectlistSTabNB.$fr
            destroy $aspectlistSTabNB.$fr
        }
        array unset aspectlist
    }
    method populateaspects {eventidaspectlist} {
        set aspectcount 0
        foreach {ev aspl} $eventidaspectlist {
            incr aspectcount
            set fr aspect$aspectcount
            set aspectlist($aspectcount,frame) $fr
            ttk::frame $aspectlistSTabNB.$fr
            $aspectlistSTabNB add $aspectlistSTabNB.$fr -text [_ "Aspect %d" $aspectcount] -sticky news
            set eventid_ [LabelEntry $aspectlistSTabNB.$fr.eventid \
                          -label [_m "Label|When this event occurs"] \
                          -text $ev]
            pack $eventid_ -fill x
            set aspectlist($aspectcount,eventid) "$ev"
            set aspl_ [LabelEntry $aspectlistSTabNB.$fr.aspl \
                       -label [_m "Label|the following aspect will be displayed."] \
                       -text $aspl]
            pack $aspl_ -fill x
            set aspectlist($aspectcount,aspl) "$aspl"
            set del [ttk::button $aspectlistSTabNB.$fr.delete \
                     -text [_m "Label|Delete Aspect"] \
                     -command [mymethod _deleteAspect $aspectcount]]
            pack $del -fill x
        }
    }
    method _addaspect {} {
        set aspectcount 0
        incr aspectcount
        set fr aspect$aspectcount
        while {[winfo exists $aspectlistSTabNB.$fr]} {
            incr aspectcount
            set fr aspect$aspectcount
        }
        set aspectlist($aspectcount,frame) $fr
        ttk::frame $aspectlistSTabNB.$fr
        $aspectlistSTabNB add $aspectlistSTabNB.$fr -text [_ "Aspect %d" $aspectcount] -sticky news
        set eventid_ [LabelEntry $aspectlistSTabNB.$fr.eventid \
                      -label [_m "Label|When this event occurs"] \
                      -text "00.00.00.00.00.00.00.00"]
        pack $eventid_ -fill x
        set aspectlist($aspectcount,eventid) "00.00.00.00.00.00.00.00"
        set aspl_ [LabelEntry $aspectlistSTabNB.$fr.aspl \
                   -label [_m "Label|the following aspect will be displayed."] \
                   -text {}]
        pack $aspl_ -fill x
        set aspectlist($aspectcount,aspl) {}
        set del [ttk::button $aspectlistSTabNB.$fr.delete \
                 -text [_m "Label|Delete Aspect"] \
                 -command [mymethod _deleteAspect $aspectcount]]
        pack $del -fill x
    }
    method _deleteaspect {index} {
        set fr $aspectlist($index,frame)
        $aspectlistSTabNB forget $aspectlistSTabNB.$fr
        unset $aspectlist($index,frame)
        unset $aspectlist($index,eventid)
        unset $aspectlist($index,aspl)
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
	set azatraxsn  "[$azatraxSerialNumberLE cget -text]"
	if {![string is digit -strict $azatraxsn]} {
	  tk_messageBox -type ok -icon error -parent $win \
		-message [_ "Illegal characters in Azatrax serial number, must be all digits, got '%s'" $azatraxsn]
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
      #puts stderr "*** $self _Add: calling getOptions"
      $self getOptions result
      return [$hull enddialog "$result"]
    }
    method doRangeCheck {} {
      $graphicCanvas delete all
      set opts {}
      #puts stderr "*** $self doRangeCheck: calling getOptions"
      set savedopenlcbmode $options(-openlcbmode)
      set options(-openlcbmode) no
      $self getOptions opts
      set options(-openlcbmode) $savedopenlcbmode
      #puts stderr "*** $self doRangeCheck: opts is $opts"
      if {[catch {eval [list ::CTCPanel::$objectType create %AUTO% $self $graphicCanvas -controlpoint nil] $opts} error]} {
          #puts stderr "*** $self doRangeCheck: error is '$error'"
	if {[string first {Range error: } "$error"] >= 0} {
	  set radius [from opts -radius]
	  set x1 [from opts -x1]
	  set x2 [from opts -x2]
	  set y1 [from opts -y1]
	  set y2 [from opts -y2]
	  set dx [expr {int(abs($x2 - $x1))}]
	  set dy [expr {int(abs($y2 - $y1))}]
          #puts stderr "*** $self doRangeCheck: (1) radius=$radius, x1=$x1, x2=$x2, y1=$y1, y2=$y2, dx=$dx, dy=$dy"
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
          #puts stderr "*** $self doRangeCheck: (2) radius=$radius, x1=$x1, x2=$x2, y1=$y1, y2=$y2, dx=$dx, dy=$dy"
	  if {$dx < $dy} {
	    $radiusLSB configure -text $dx
	  } else {
	    $radiusLSB configure -text $dy
	  }
          #puts stderr "*** $self doRangeCheck: \[$radiusLSB cget -text\] = [$radiusLSB cget -text]"
          #puts stderr "*** $self doRangeCheck: range error, radius adjusted."
	  return 1
	} else {
            #puts stderr "*** $self doRangeCheck: some other error, punting."
	  error "$error" $::errorInfo $::errorCode
	}
        #puts stderr "*** $self doRangeCheck: some error handled."
      }
      #puts stderr "*** $self doRangeCheck: not a range error."
      return 0
    }
    method getOptions {resultVar} {
      #puts stderr "*** $self getOptions $resultVar"
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
                      set prod [$azatraxProductTypeLCB cget -text]
                      set swn 0
                      if {$prod eq "MRD2-U"} {
                          set normcommand [list SimpleMode::NormalMRD [$nameLE cget -text] [$switchNameLE cget -text] [$azatraxSerialNumberLE cget -text]]
                      } else {
                          regexp {(SL2|SR4)[[:space:]]Switch[[:space:]]([[:digit:]])} $prod -> p swn
                          set normcommand [list SimpleMode::Normal${p} $swn [$nameLE cget -text] [$switchNameLE cget -text] [$azatraxSerialNumberLE cget -text]]
                      }
                      lappend result -normalcommand $normcommand
                  } elseif {$options(-openlcbmode)} {
                      lappend result -normaleventid "[$normaleventidLE get]"
                  } else {
                      lappend result -normalcommand "[$normalcommandText get 1.0 end-1c]"
                  }
              }
              reversecommand {
                  if {$options(-simplemode) && $objectType eq "SWPlate"} {
                      set prod [$azatraxProductTypeLCB cget -text]
                      set swn 0
                      if {$prod eq "MRD2-U"} {
                          set revcommand [list SimpleMode::ReverseMRD [$nameLE cget -text] [$switchNameLE cget -text] [$azatraxSerialNumberLE cget -text]]
                      } else {
                          regexp {(SL2|SR4)[[:space:]]Switch[[:space:]]([[:digit:]])} $prod -> p swn
                          set revcommand [list SimpleMode::Reverse${p} $swn [$nameLE cget -text] [$switchNameLE cget -text] [$azatraxSerialNumberLE cget -text]]
                      }
                      lappend result -reversecommand $revcommand
                  } elseif {$options(-openlcbmode)} {
                      lappend result -reverseeventid "[$reverseeventidLE get]"
                  } else {
                      lappend result -reversecommand "[$reversecommandText get 1.0 end-1c]"
                  }
              }
              leftcommand {
                  if {$options(-simplemode) && $objectType eq "SIGPlate"} {
                      set leftcommand [list SimpleMode::Left [$nameLE cget -text]]
                      lappend result -leftcommand "$leftcommand"
                  } elseif {$options(-openlcbmode)} {
                      lappend result -lefteventid "[$lefteventidLE get]"
                  } else {
                      lappend result -leftcommand "[$leftcommandText get 1.0 end-1c]"
                  }
              }
              centercommand {
                  if {$options(-simplemode) && $objectType eq "SIGPlate"} {
                      set centercommand [list SimpleMode::Center [$nameLE cget -text]]
                      lappend result -centercommand "$centercommand"
                  } elseif {$options(-openlcbmode)} {
                      lappend result -centereventid "[$centereventidLE get]"
                  } else {
                      lappend result -centercommand "[$centercommandText get 1.0 end-1c]"
                  }
              }
              rightcommand {
                  if {$options(-simplemode) && $objectType eq "SIGPlate"} {
                      set rightcommand [list SimpleMode::Right [$nameLE cget -text]]
                      lappend result -rightcommand "$rightcommand"
                  } elseif {$options(-openlcbmode)} {
                      lappend result -righteventid "[$righteventidLE get]"
                  } else {
                      lappend result -rightcommand "[$rightcommandText get 1.0 end-1c]"
                  }
              }
              command {
                  if {$options(-simplemode) && $objectType eq "CodeButton"} {
                      set command [list SimpleMode::CodeButton "[$controlPointLCB cget -text]"]
                      lappend result -command $command
                  } elseif {$options(-openlcbmode)} {
                      lappend result -eventid "[$eventidLE get]"
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
                  if {$options(-openlcbmode)} {
                      lappend result -statenormaleventid "[$statenormaleventidLE get]"
                      lappend result -statereverseeventid "[$statereverseeventidLE get]"
                  } else {
                      lappend result -statecommand "[$statecommandText get 1.0 end-1c]"
                  }
              }
              occupiedcommand {
                  if {$options(-openlcbmode)} {
                      lappend result -occupiedeventid "[$occupiedeventidLE get]"
                      lappend result -notoccupiedeventid "[$notoccupiedeventidLE get]"
                  } else {
                      lappend result -occupiedcommand "[$occupiedcommandText get 1.0 end-1c]"
                  }
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
      if {$options(-openlcbmode)} {
          if {[info exists objectTypeIndicatorEvents($objectType)]} {
              foreach opt $objectTypeIndicatorEvents($objectType) {
                  switch -exact $opt {
                      aspectlist {
                          set evaspl [list]
                          foreach aspectfr [array names aspectlist *,frame] {
                              regexp {^([[:digit:]]+),frame$} $aspectfr => aspectcount
                              set fr $aspectlist($aspectfr)
                              set eventid_ $aspectlistSTabNB.$fr.eventid
                              set aspl_    $aspectlistSTabNB.$fr.aspl
                              lappend evaspl "[$eventid_ get]" "[$aspl_ get]"
                          }
                          lappend result -eventidaspectlist $evaspl
                      }
                      normal {
                          lappend result -normalindonev "[$normalindonevLE get]"
                          lappend result -normalindoffev "[$normalindoffevLE get]"
                      }
                      center {
                          lappend result -centerindonev "[$centerindonevLE get]"
                          lappend result -centerindoffev "[$centerindoffevLE get]"
                      }
                      reverse {
                          lappend result -reverseindonev "[$reverseindonevLE get]"
                          lappend result -reverseindoffev "[$reverseindoffevLE get]"
                      }
                      left {
                          lappend result -leftindonev "[$leftindonevLE get]"
                          lappend result -leftindoffev "[$leftindoffevLE get]"
                      }
                      right {
                          lappend result -rightindonev "[$rightindonevLE get]"
                          lappend result -rightindoffev "[$rightindoffevLE get]"
                      }
                      onoff {
                          lappend result -oneventid "[$oneventidLE get]"
                          lappend result -offeventid "[$offeventidLE get]"
                      }
                  }
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
      installhull using Dialog -bitmap questhead -default select \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Select Panel Object"] \
				-parent [from args -parent]
      $hull add select -text [_m "Button|Select"] -command [mymethod _Select]
      $hull add find   -text [_m "Button|Find"]   -command [mymethod _Find]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Select Panel Object Dialog}}
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
    component openlcbModeCB;#           -openlcbmode
    component transconstructorE;#       -openlcbtransport
    component transconstructorSB
    variable   _transconstructorname {}
    component transoptsframeE;#         -openlcbtransportopts
    component transoptsframeSB
    variable   _transopts {}
    component hascmriLCB;#		-hascmri
    component cmriportLCB;#		-cmriport
    component cmrispeedLCB;#		-cmrispeed
    component cmriretriesLSB;#		-cmriretries
    component hasazatraxLCB;#		-hasazatrax
    component hasctiacelaLCB;#          -hasctiacela
    component ctiacelaportLCB;#         -ctiacelaport
    variable _simpleMode no
    variable _openlcbMode no
    
    constructor {args} {
        #puts stderr "*** $type create $self $args"
      installhull using Dialog -bitmap questhead -default update \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Edit Panel Options"] \
				-parent [from args -parent]
      $hull add update -text [_m "Button|Update"] -command [mymethod _Update]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Configuring CTC Panel Windows}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Width:" "Label|Height:" \
		      "Label|Has CM/RI?" "Label|CM/RI Port:" \
                  "Label|CM/RI Speed:" "Label|CM/RI Retries:" \
                  "Label|Has CTI Acela?" "Label|CTI Acela Port:"]
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
      install simpleModeCB using ttk::checkbutton $frame.simpleModeCB \
					-text [_m "Label|Simple Mode"] \
					-offvalue no -onvalue yes \
					-command [mymethod togglesimplemode] \
					-variable [myvar _simpleMode]
      pack $simpleModeCB -fill x -expand yes
      install openlcbModeCB using ttk::checkbutton $frame.openlcbModeCB \
            -text [_m "Label|OpenLCB Mode"] \
            -offvalue no -onvalue yes \
            -command [mymethod toggleopenlcbmode] \
            -variable [myvar _openlcbMode]
      pack $openlcbModeCB -fill x -expand yes
      set transconstructor [LabelFrame $frame.transconstructor \
                            -text [_m "Label|OpenLCB Transport Constructor"]]
      pack $transconstructor -fill x -expand yes
      set cframe [$transconstructor getframe]
      install transconstructorE using ttk::entry $cframe.transcname \
            -state disabled \
            -textvariable [myvar _transconstructorname]
      pack $transconstructorE -side left -fill x -expand yes
      install transconstructorSB using ttk::button $cframe.transcnamesel \
            -text [_m "Label|Select"] \
            -command [mymethod _seltransc] \
            -state disabled
      pack $transconstructorSB -side right
      set transoptsframe [LabelFrame $frame.transoptsframe \
                          -text [_m "Label|Constructor Opts"]]
      pack $transoptsframe -fill x -expand yes
      set oframe [$transoptsframe getframe]
      install transoptsframeE using ttk::entry $oframe.transoptsentry \
            -state disabled \
            -textvariable [myvar _transopts]
      pack $transoptsframeE -side left -fill x -expand yes
      install transoptsframeSB using ttk::button $oframe.tranoptssel \
            -text [_m "Label|Select"] \
            -command [mymethod _seltransopt] \
            -state disabled
      pack $transoptsframeSB -side right
      install hascmriLCB using LabelComboBox $frame.hascmriLCB \
						   -label [_m "Label|Has CM/RI?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no
      $hascmriLCB set [lindex [$hascmriLCB cget -values] end]
      pack $hascmriLCB -fill x
      install cmriportLCB using LabelComboBox $frame.cmriportLCB \
						   -label [_m "Label|CM/RI Port:"] \
						   -labelwidth $lwidth \
						   -values {/dev/ttyS0 
							    /dev/ttyS1 
							    /dev/ttyS2 
							    /dev/ttyS3}
      pack $cmriportLCB -fill x
      $cmriportLCB set [lindex [$cmriportLCB cget -values] 0]
      install cmrispeedLCB using LabelComboBox $frame.cmrispeedLCB \
						   -label [_m "Label|CM/RI Speed:"] \
						   -labelwidth $lwidth \
						   -values {4800 9600 19200}
      pack $cmrispeedLCB -fill x
      $cmrispeedLCB set [lindex [$cmrispeedLCB cget -values] 1]
      install cmriretriesLSB using LabelSpinBox $frame.cmriretriesLSB \
						   -label [_m "Label|CM/RI Retries:"] \
						   -labelwidth $lwidth \
						   -range {5000 20000 100}
      pack $cmriretriesLSB -fill x
      $cmriretriesLSB set 10000
      install hasazatraxLCB using LabelComboBox $frame.hasazatraxLCB \
						   -label [_m "Label|Has AZATRAX?"] \
						   -labelwidth $lwidth \
						   -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
						   -editable no
      $hasazatraxLCB set [lindex [$hasazatraxLCB cget -values] end]
      pack $hasazatraxLCB -fill x
      set hasctiacelaLCB [LabelComboBox $frame.hasctiacelaLCB \
                              -label [_m "Label|Has CTI Acela?"] \
                              -labelwidth $lwidth \
                              -values [list [_m "Answer|yes"] [_m "Answer|no"]] \
                              -editable no]
      
      $hasctiacelaLCB set [lindex [$hasctiacelaLCB cget -values] end]
      pack $hasctiacelaLCB -fill x
      set ctiacelaportLCB [LabelComboBox $frame.ctiacelaportLCB \
                               -label [_m "Label|CTI Acela Port:"] \
                               -labelwidth $lwidth \
                               -values {/dev/ttyS0
                                        /dev/ttyS1
                                        /dev/ttyACM0}]
      pack $ctiacelaportLCB -fill x
      $ctiacelaportLCB set [lindex [$ctiacelaportLCB cget -values] end]
      $self configurelist $args
    }
    method togglesimplemode {} {
      set parent [$hull cget -parent]
      if {$_simpleMode} {
	foreach w {hascmriLCB cmriportLCB cmrispeedLCB 
            cmriretriesLSB hasazatraxLCB hasctiacelaLCB 
            ctiacelaportLCB} {
	  [set $w] configure -state disabled
	}
        $hasazatraxLCB configure -text [backtrans [$parent cget -hasazatrax]]
      } else {
	foreach w {cmriportLCB cmrispeedLCB 
            cmriretriesLSB ctiacelaportLCB} {
	  [set $w] configure -state normal
        }
        foreach w {hascmriLCB hasazatraxLCB hasctiacelaLCB} {
            [set $w] configure -state readonly
        }
        if {![converttobool [$hasazatraxLCB cget -text]]} {
	  $hasazatraxLCB set [lindex [$hasazatraxLCB cget -values] end]
        }
      }
    }
    method toggleopenlcbmode {} {
        if {$_openlcbMode} {
            foreach w {hascmriLCB cmriportLCB cmrispeedLCB
                cmriretriesLSB hasazatraxLCB simpleModeCB 
                hasctiacelaLCB ctiacelaportLCB} {
                [set $w] configure -state disabled
            }
            foreach w {transconstructorE transoptsframeE} {
                [set $w] configure -state readonly
            }
            foreach w {transconstructorSB transoptsframeSB} {
                [set $w] configure -state normal
            }
        } else {
            foreach w {cmriportLCB cmrispeedLCB cmriretriesLSB 
                ctiacelaportLCB simpleModeCB} {
                [set $w] configure -state normal
            }
            foreach w {hascmriLCB hasazatraxLCB 
                hasctiacelaLCB} {
                [set $w] configure -state readonly
            }
            foreach w {transconstructorE transoptsframeE 
                transconstructorSB transoptsframeSB} {
                [set $w] configure -state disabled
            }
        }
    }
    method _seltransc {} {
        #** Select a transport constructor.
        
        set result [lcc::OpenLCBNode selectTransportConstructor -parent [winfo toplevel $transconstructorE]]
        if {$result ne {}} {
            if {$result ne $_transconstructorname} {set _transopts {}}
            set _transconstructorname [namespace tail $result]
        }
    }
    method _seltransopt {} {
        #** Select transport constructor options.
        
        if {$_transconstructorname ne ""} {
            set transportConstructors [info commands ::lcc::$_transconstructorname]
            #puts stderr "*** $type typeconstructor: transportConstructors is $transportConstructors"
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
            if {$transportConstructor ne {}} {
                set optsdialog [list $transportConstructor \
                                drawOptionsDialog \
                                -parent [winfo toplevel $transoptsframeE]]
                foreach x $_transopts {lappend optsdialog $x}
                set transportOpts [eval $optsdialog]
                if {$transportOpts ne {}} {
                    set _transopts $transportOpts
                }
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
      $hasazatraxLCB configure -text [backtrans [$parent cget -hasazatrax]]
      $hasctiacelaLCB configure -text [backtrans [$parent cget -hasctiacela]]
      $ctiacelaportLCB configure -text "[$parent cget -ctiacelaport]"
      set _simpleMode [$parent cget -simplemode]
      $self togglesimplemode
      set _openlcbMode [$parent cget -openlcbmode]
      $self toggleopenlcbmode
      set _transconstructorname [$parent cget -openlcbtransport]
      set _transopts [$parent cget -openlcbtransportopts]
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
      lappend result -hasazatrax [converttobool [$hasazatraxLCB cget -text]]
      lappend result -simplemode $_simpleMode
      lappend result -hasctiacela [converttobool [$hasctiacelaLCB cget -text]]
      lappend result -ctiacelaport "[$ctiacelaportLCB cget -text]"
      lappend result -openlcbmode $_openlcbMode
      lappend result -openlcbtransport $_transconstructorname
      lappend result -openlcbtransportopts $_transopts
      return [$hull enddialog $result]
    }
  }
  snit::widgetadaptor AddCMRINodeDialog {
    delegate option -parent to hull
    option -node -default {}
    option -mode -default add
    component nameLE;#		  	Name of board (symbol)
    component commentLE;#	  	Comment text
    component uaLSB;#			UA of board (0-127)
    component nodeTypeLCB;#		Type of board (SUSIC, USIC, or SMINI)
    component numberYellowSigsLSB;#	-ns (0-24)
    component numberInputsLSB;#		-ni (0-1023)
    component numberOutputsLSB;#	-no (0-1023)
    component delayValueLSB;#		-dl (0-65535)
    component cardTypeMapLE;#		-ct (list of bytes)

    constructor {args} {
      installhull using Dialog -bitmap questhead -default add \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Add CMR/I Node to panel"] \
				-parent [from args -parent]
      $hull add add    -text [_m "Button|Add"]    -command [mymethod _Add]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Add CMRI Node Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Address:" "Label|Board Type:" \
		      "Label|# Yellow Signals:" "Label|# Input ports:" \
		      "Label|# Output ports:" "Label|Delay Value:" \
		      "Label|Card Type Map:" "Label|Yellow Signal Map:" \
		      "Label|Comment:"]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $nameLE -fill x
      install commentLE using LabelEntry $frame.commentLE \
						-label [_m "Label|Comment:"] \
						-labelwidth $lwidth \
						-text {}
      pack $commentLE -fill x
      install uaLSB using LabelSpinBox $frame.uaLSB  -label [_m "Label|Address:"] \
						     -labelwidth $lwidth \
						     -range {0 127 1}
      pack $uaLSB -fill x
      install nodeTypeLCB using LabelComboBox $frame.nodeTypeLCB \
					-label [_m "Label|Board Type:"] \
					-labelwidth $lwidth \
					-values {SUSIC USIC SMINI} \
					-editable no
      bind $win <<ComboboxSelected>> [mymethod _updateCTLab]
      $nodeTypeLCB set [lindex [$nodeTypeLCB cget -values] 0]
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
        #puts stderr "*** $self draw $args"
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient [winfo toplevel $win] $parent
      switch -exact $options(-mode) {
	edit {
	  set node [$parent getcmrinode "$options(-node)"]
	  $nameLE configure -text $options(-node) -editable no
	  $commentLE configure -text [$parent getcmrinode_comment "$options(-node)"]
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
      lappend result "$name"
      lappend result "[$commentLE cget -text]"
      lappend result [$uaLSB cget -text] [$nodeTypeLCB cget -text]
      lappend result -ns [$numberYellowSigsLSB cget -text]
      lappend result -ni [$numberInputsLSB cget -text]
      lappend result -no [$numberOutputsLSB cget -text]
      lappend result -dl [$delayValueLSB cget -text]
      lappend result -ct "[$cardTypeMapLE cget -text]"
      #puts stderr "*** $self _Add: result = $result"
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
      installhull using Dialog -bitmap questhead -default select \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Select CMRI Node"] \
				-parent [from args -parent]
      $hull add select -text [_m "Button|Select"] -command [mymethod _Select]
      $hull add find   -text [_m "Button|Find"]   -command [mymethod _Find]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Select CMRI Node Dialog}}
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
	tk_messageBox -type ok -icon warning  -parent $win -message [_ "No such board: %s" [$selectedNameLE cget -text]]
	return
      }
      return [$hull enddialog "[$selectedNameLE cget -text]"]
    }
  }
  #### AZATRAX Dialogs
  snit::widgetadaptor AddAZATRAXNodeDialog {
    delegate option -parent to hull
    option -node -default {}
    option -mode -default add
    component nameLE;#			Name of board (symbol)   
    component commentLE;#		Board comment
    component serialLE;#		Serial number (0XYYYYYYY)
    component prodLSB;#			Product type {MRD SL2 SR4}

    constructor {args} {
      installhull using Dialog -bitmap questhead -default add \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Add AZATRAX Node to panel"] \
				-parent [from args -parent]
      $hull add add    -text [_m "Button|Add"]    -command [mymethod _Add]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Add AZATRAX Node Dialog}}
      set frame [$hull getframe]
      set lwidth [_mx "Label|Name:" "Label|Serial Number:" "Label|Product:" \
			"Label|Comment:"]
      install nameLE using LabelEntry $frame.nameLE -label [_m "Label|Name:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $nameLE -fill x
      install commentLE using LabelEntry $frame.commentLE -label [_m "Label|Comment:"] \
						    -labelwidth $lwidth \
						    -text {}
      pack $commentLE -fill x
      install serialLE using LabelEntry $frame.serialLE \
					-label [_m "Label|Serial Number:"] \
					-labelwidth $lwidth \
					-text {}
      pack $serialLE -fill x
      install prodLSB using LabelSpinBox $frame.prodLSB \
					-label [_m "Label|Product:"] \
					-labelwidth $lwidth \
					-editable no \
					-values [list MRD SL2 SR4]
      pack $prodLSB -fill x
      $self configurelist $args
    }
    method draw {args} {
      $self configurelist $args
      set parent [$hull cget -parent]
      wm transient [winfo toplevel $win] $parent
      switch -exact $options(-mode) {
	edit {
	  foreach {sn prod} [$parent getazatraxnode "$options(-node)"] {break}
	  if {$prod eq ""} {set prod MRD}
	  $nameLE configure -text $options(-node) -editable no
	  $commentLE configure -text [$parent getazatraxnode_comment "$options(-node)"]
	  $serialLE configure -text [lindex $sn 0]
	  $prodLSB  set $prod
	  $hull itemconfigure add -text [_m "Button|Update"]
	  $hull configure -title [_ "Edit Azatrax node"]
	}
	add -
	default {
	  $nameLE configure -editable yes
	  $prodLSB  set [lindex [$prodLSB cget -values] 0]
	  $hull itemconfigure add -text [_m "Button|Add"]
	  $hull configure -title [_ "Add Azatrax Node to panel"]
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
      set comment "[$commentLE cget -text]"
      set serial "[$serialLE cget -text]"
      set prod "[$prodLSB cget -text]"
      if {[string equal "$options(-mode)" add]} {
	if {![$self _CheckNameChars "$name"]} {
	  tk_messageBox -type ok -icon error -parent $win \
		-message [_ "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $name]
	  return
	}
	set parent [$hull cget -parent]
	if {[lsearch -exact [$parent azatraxnodelist] "$name"] >= 0} {
	  tk_messageBox -type ok -icon error -parent $win \
		      -message [_ "Name '%s' already in use.  Pick another." $name]
	  return
	}
      }
      $hull withdraw
      return [$hull enddialog [list "$name" "$serial" "$prod" "$comment"]]
    }
  }
  snit::widgetadaptor SelectAZATRAXNodeDialog {
    delegate option -parent to hull

    component namePatternLE;#		Search Pattern
    component nameListSW;#		Name list ScrollWindow
    component   nameList;#		Name list
    component selectedNameLE;#		Selected Name

    constructor {args} {
      installhull using Dialog -bitmap questhead -default select \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Select AZATRAX Node"] \
				-parent [from args -parent]
      $hull add select -text [_m "Button|Select"] -command [mymethod _Select]
      $hull add find   -text [_m "Button|Find"]   -command [mymethod _Find]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Select AZATRAX Node Dialog}}
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
					[$parent azatraxnodelist] \
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
      if {[lsearch -exact [$parent azatraxnodelist] \
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
      installhull using Dialog -bitmap questhead -default update \
				-cancel cancel -modal local -transient yes \
				-side bottom -title [_ "Edit User Code"] \
				-parent [from args -parent]
      $hull add update -text [_m "Button|Update"] -command [mymethod _Update]
      $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Edit User Code Dialog}}
      set frame [$hull getframe]
      install codeTextSW using ScrolledWindow $frame.codeTextSW \
		-scrollbar both -auto both
      pack $codeTextSW -expand yes -fill both
      install codeText using text [$codeTextSW getframe].codeText \
		-wrap none
      bindtags $codeText [list $codeText Text]
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
  snit::widgetadaptor AddExternalUserModuleDialog {
      delegate option -parent to hull

      component moduleNameLE
      component moduleDirFE
      
      constructor {args} {
          installhull using Dialog -bitmap questhead -default add \
                -cancel cancel -modal local -transient yes \
                -side bottom -title [_ "Add External User Module"] \
                -parent [from args -parent]
          $hull add add    -text [_m "Button|Add"]    -command [mymethod _Add]
          $hull add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
          wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
          $hull add help -text [_m "Button|Help"] -command {HTMLHelp help {Add External User Module}}
          set frame [$hull getframe]
          set lwidth [_mx "Label|Package Name:" "Label|Directory:"]
          install moduleNameLE using LabelEntry $frame.moduleNameLE -label [_m "Label|Package Name:"] \
                -labelwidth $lwidth -text {}
          pack $moduleNameLE -fill x
          install moduleDirFE using FileEntry $frame.moduleDirFE -label [_m "Label|Directory:"] \
                -labelwidth $lwidth -filedialog directory \
                -title [_ "External User Module Directory"]
          pack $moduleDirFE -fill x
          $self configurelist $args
      }
      method draw {args} {
          $self configurelist $args
          set parent [$hull cget -parent]
          wm transient [winfo toplevel $win] $parent
          return [$hull draw]
      }
      method _Cancel {} {
          $hull withdraw
          return [$hull enddialog {}]
      }
      method _CheckNameChars {value} {
          return [expr {[regexp {^[[:alpha:]][[:alnum:]_.-:]*$} "$value"] > 0}]
      }
      method _Add {} {
          set packageName "[$moduleNameLE cget -text]"
          if {![$self _CheckNameChars "$packageName"]} {
                tk_messageBox -type ok -icon error -parent $win \
                      -message [_ "Illegal characters in name, must start with a letter and contain only letters, digits, underscores, dots, and dashes, got '%s'" $packageName]
                return
          }
          set parent [$hull cget -parent]
          if {![catch {$parent externalUserModuleDir $packageName}]} {
              tk_messageBox -type ok -icon error -parent $win \
                    -message [_ "Package Name %s already in use!" $packageName]
              return
          }
          $hull withdraw
          return [$hull enddialog [list $packageName [$moduleDirFE cget -text]]]
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
  snit::widget displayPanelObject {
      Dispatcher::StdShell DisplayPanelObject
      
      component nameLE;#                  Name of object
      component objectTypeLE;#            Object Type
      component controlPointLE;#          -controlpoint
      component optionsFrame;#            options frame
      component xyframe1;#                XY 1 options:
      component   x1LE;#                  -x1 or -x
      component   y1LE;#                  -y1 or -y
      component xyframe2;#                XY 2 options:
      component   x2LE;#                  -x2
      component   y2LE;#                  -y2
      component radiusLE;#                -radius
      component labelLE;#                 -label
      component positionLE;#              -position
      component orientationLE;#           -orientation (8-way)
      component hvorientationLE;#         -orientation (horizontal / vertical)
      component flippedLE;#               -flipped
      component headsLE;#                 -heads (1, 2, 3)
      component typeLE;#                  -type
      component leftlabelLE;#		  -leftlabel
      component centerlabelLE;#		  -centerlabel
      component rightlabelLE;#		  -rightlabel
      component hascenterLCB;#		  -hascenter
      component colorLE;#		  -color
      # Simple mode features for Switch Plates
      component azatraxSerialNumberLE;#	  Azatrax serial number (SWitch Plates in simple mode)
      component azatraxProductTypeLE;#	  Azatrax product type and index (SWitch Plates in simple mode)
      component switchNameLE;#		  Trackwork controlled by this switch plate
      #
      component occupiedcommandLF
      component   occupiedcommandSW
      component     occupiedcommandText;# -occupiedcommand
      component statecommandLF
      component   statecommandSW
      component     statecommandText;#	  -statecommand
      component normalcommandLF
      component   normalcommandSW
      component     normalcommandText;#	  -normalcommand
      component reversecommandLF
      component   reversecommandSW
      component     reversecommandText;#  -reversecommand
      component leftcommandLF
      component   leftcommandSW
      component     leftcommandText;#	  -leftcommand
      component centercommandLF
      component   centercommandSW
      component     centercommandText;#	  -centercommand
      component rightcommandLF
      component   rightcommandSW
      component     rightcommandText;#	  -rightcommand
      component commandLF
      component   commandSW
      component     commandText;#	  -command
      # OpenLCB events
      # Sensors
      component occupiedeventidLE
      component notoccupiedeventidLE
      component statenormaleventidLE
      component statereverseeventidLE
      # Actions
      component lefteventidLE
      component righteventidLE
      component centereventidLE
      component eventidLE
      component normaleventidLE
      component reverseeventidLE
      # Indicators
      component aspectlistLF
      component   aspectlistSTabNB
      variable    aspectlist -array {}
      component   addaspectB
      component normalindonevLE
      component normalindoffevLE
      component centerindonevLE
      component centerindoffevLE
      component reverseindonevLE
      component reverseindoffevLE
      component leftindonevLE
      component leftindoffevLE
      component rightindonevLE
      component rightindoffevLE
      component oneventidLE
      component offeventidLE
      
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
      typevariable objectTypeIndicatorEvents -array {
          Signal {aspectlist}
          SWPlate {normal center reverse}
          SIGPlate {left center right}
          Lamp {onoff}
      }

      
      option -title -default {Displaying Object Info} \
            -configuremethod _SetTitle
      option -ctcpanel  -default {} -validatemethod _CheckPanel
      option -object -default {}
      option -simplemode -default no
      option -openlcbmode -default no
      
      method _CheckPanel {option value} {
          if {[catch {$value info type} typename]} {
              error "Expected a ::CTCPanel::CTCPanel, got $value"
          } elseif {{::CTCPanel::CTCPanel} ne $typename} {
              error "Expected a ::CTCPanel::CTCPanel, got $value ($typename)"
          } else {
              return $value
          }
      }
      
      method settopframeoption {frame option value} {
          #puts stderr "*** $self settopframeoption $frame $option $value"
      }
      method constructtopframe {frame args} {
          #puts stderr "*** $self constructtopframe $frame $args"
          set lwidth [_mx "Label|Name:" "Label|Control Point:" \
                      "Label|Radius:" "Label|Object Type:" \
		      "Label|Label:" "Label|Position:" "Label|Orientation:" \
		      "Label|Flipped?" "Label|Heads:" "Label|Crossing Type:" \
		      "Label|Left Label:" "Label|Center Label:" \
		      "Label|Right Label:" "Label|Has Center Position?" \
		      "Label|Color:" "Label|Occupied Script:" \
		      "Label|State Script:" "Label|Normal Script:" \
		      "Label|Reverse Script:" "Label|Left Script:" \
		      "Label|Center Script:" "Label|Right Script:" \
		      "Label|Action Script:" "Label|Azatrax S#:" \
		      "Label|Switch Name:" "Label|Azatrax Product:"]
          install nameLE using LabelEntry $frame.nameLE \
                -label [_m "Label|Name:"] \
                -labelwidth $lwidth \
                -editable no -text {}
          pack $nameLE -fill x
          install objectTypeLE using LabelEntry $frame.objectTypeLE \
                -label [_m "Label|Object Type:"] \
                -labelwidth $lwidth \
                -editable no -text {}
          pack $objectTypeLE -fill x
          install controlPointLE using LabelEntry $frame.controlPointLE \
                -label [_m "Label|Control Point:"] \
                -labelwidth $lwidth -editable no -text {}
          pack $controlPointLE -fill x
          install optionsFrame using frame $frame.optionsFrame -borderwidth 0 \
							   -relief flat
          pack $optionsFrame -expand yes -fill both
          install xyframe1 using ttk::labelframe $optionsFrame.xyframe1 \
                -text [_m "Label|First Coord"] \
                -labelanchor nw
          install x1LE using LabelEntry $xyframe1.x1LE \
						-label X: \
						-editable no
          pack $x1LE -side left -fill x -expand yes
          install y1LE using LabelEntry $xyframe1.y1LE \
						-label Y: \
						-editable no
          pack $y1LE -side left -fill x -expand yes
          install xyframe2 using ttk::labelframe $optionsFrame.xyframe2 \
                -text [_m "Label|Second Coord"] \
                -labelanchor nw
          install x2LE using LabelEntry $xyframe2.x2LE \
						-label X: \
						-editable no
          pack $x2LE -side left -fill x -expand yes
          install y2LE using LabelEntry $xyframe2.y2LE \
						-label Y: \
						-editable no
          pack $y2LE -side left -fill x -expand yes
          install radiusLE using LabelEntry $optionsFrame.radiusLE \
						-label [_m "Label|Radius:"] \
						-labelwidth $lwidth \
						-editable no
          install labelLE using LabelEntry $optionsFrame.labelLE \
                -label [_m "Label|Label:"] \
                -labelwidth $lwidth -editable no
          install positionLE using LabelEntry $optionsFrame.positionLE \
                -label [_m "Label|Position:"] \
                -labelwidth $lwidth \
                -editable no
          install orientationLE using LabelEntry $optionsFrame.orientationLE \
                -label [_m "Label|Orientation:"] \
                -labelwidth $lwidth \
                -editable no
          install hvorientationLE using LabelEntry $optionsFrame.hvorientationLE \
                -label [_m "Label|Orientation:"] \
                -labelwidth $lwidth \
                -editable no
          install flippedLE using LabelEntry $optionsFrame.flippedLE \
                -label [_m "Label|Flipped?"] \
                -labelwidth $lwidth \
                -editable no
          install headsLE using LabelEntry $optionsFrame.headsLE \
                -label [_m "Label|Heads:"] \
                -labelwidth $lwidth \
                -editable no
          install typeLE using LabelComboBox $optionsFrame.typeLE \
                -label [_m "Label|Crossing Type:"] \
                -labelwidth $lwidth \
                -editable no
          install leftlabelLE using LabelEntry $optionsFrame.leftlabelLE \
                -label [_m "Label|Left Label:"] \
                -labelwidth $lwidth
          install centerlabelLE using LabelEntry $optionsFrame.centerlabelLE \
                -label [_m "Label|Center Label:"] \
                -labelwidth $lwidth
          install rightlabelLE using LabelEntry $optionsFrame.rightlabelLE \
                -label [_m "Label|Right Label:"] \
                -labelwidth $lwidth
          install hascenterLE using LabelEntry $optionsFrame.hascenterLE \
                -label [_m "Label|Has Center Position?"] \
                -labelwidth $lwidth \
                -editable no
          install colorLE using LabelEntry $optionsFrame.colorLE \
                -label [_m "Label|Color:"] \
                -labelwidth $lwidth \
                -editable no
          install azatraxSerialNumberLE using LabelEntry $optionsFrame.azatraxSerialNumberLE \
                -label [_m "Label|Azatrax S#:"] \
                -labelwidth $lwidth \
                -editable no
          install azatraxProductTypeLE using LabelEntry $optionsFrame.azatraxProductTypeLE \
                -label [_m "Label|Azatrax Product:"] \
                -labelwidth $lwidth \
                -editable no
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
          install occupiedcommandText using ROText \
                [$occupiedcommandSW getframe].occupiedcommandText \
                -wrap none -width 40 -height 5
          $occupiedcommandSW setwidget $occupiedcommandText
          install statecommandLF using LabelFrame $optionsFrame.statecommandLF \
                -text [_m "Label|State Script:"] \
                -width $lwidth
          install statecommandSW using ScrolledWindow \
                [$statecommandLF getframe].statecommandSW \
                -scrollbar both -auto both
          pack $statecommandSW -expand yes -fill both
          install statecommandText using ROText \
                [$statecommandSW getframe].statecommandText \
                -wrap none -width 40 -height 5
          $statecommandSW setwidget $statecommandText
          install normalcommandLF using LabelFrame $optionsFrame.normalcommandLF \
                -text [_m "Label|Normal Script:"] \
                -width $lwidth
          install normalcommandSW using ScrolledWindow \
                [$normalcommandLF getframe].normalcommandSW \
                -scrollbar both -auto both
          pack $normalcommandSW -expand yes -fill both
          install normalcommandText using ROText \
                [$normalcommandSW getframe].normalcommandText \
                -wrap none -width 40 -height 5
          $normalcommandSW setwidget $normalcommandText
          install reversecommandLF using LabelFrame $optionsFrame.reversecommandLF \
                -text [_m "Label|Reverse Script:"] \
                -width $lwidth
          install reversecommandSW using ScrolledWindow \
                [$reversecommandLF getframe].reversecommandSW \
                -scrollbar both -auto both
          pack $reversecommandSW -expand yes -fill both
          install reversecommandText using ROText \
                [$reversecommandSW getframe].reversecommandText \
                -wrap none -width 40 -height 5
          $reversecommandSW setwidget $reversecommandText
          install leftcommandLF using LabelFrame $optionsFrame.leftcommandLF \
                -text [_m "Label|Left Script:"] \
                -width $lwidth
          install leftcommandSW using ScrolledWindow \
                [$leftcommandLF getframe].leftcommandSW \
                -scrollbar both -auto both
          pack $leftcommandSW -expand yes -fill both
          install leftcommandText using ROText \
                [$leftcommandSW getframe].leftcommandText \
                -wrap none -width 40 -height 5
          $leftcommandSW setwidget $leftcommandText
          install centercommandLF using LabelFrame $optionsFrame.centercommandLF \
                -text [_m "Label|Center Script:"] \
                -width $lwidth
          install centercommandSW using ScrolledWindow \
                [$centercommandLF getframe].centercommandSW \
                -scrollbar both -auto both
          pack $centercommandSW -expand yes -fill both
          install centercommandText using ROText \
                [$centercommandSW getframe].centercommandText \
                -wrap none -width 40 -height 5
          $centercommandSW setwidget $centercommandText
          install rightcommandLF using LabelFrame $optionsFrame.rightcommandLF \
                -text [_m "Label|Right Script:"] \
                -width $lwidth
          install rightcommandSW using ScrolledWindow \
                [$rightcommandLF getframe].rightcommandSW \
                -scrollbar both -auto both
          pack $rightcommandSW -expand yes -fill both
          install rightcommandText using ROText \
                [$rightcommandSW getframe].rightcommandText \
                -wrap none -width 40 -height 5
          $rightcommandSW setwidget $rightcommandText
          install commandLF using LabelFrame $optionsFrame.commandLF \
                -text [_m "Label|Action Script:"] \
                -width $lwidth
          install commandSW using ScrolledWindow \
                [$commandLF getframe].commandSW \
                -scrollbar both -auto both
          pack $commandSW -expand yes -fill both
          install commandText using ROText \
                [$commandSW getframe].commandText \
                -wrap none -width 40 -height 5
          $commandSW setwidget $commandText
          ### OpenLCB events
          # Sensors
          install occupiedeventidLE using LabelEntry $optionsFrame.occupiedeventidLE \
                -label [_m "Label|Occupied EventID:"] \
                -labelwidth $lwidth -editable no
          install notoccupiedeventidLE using LabelEntry $optionsFrame.notoccupiedeventidLE \
                -label [_m "Label|Not Occupied EventID:"] \
                -labelwidth $lwidth -editable no
          install statenormaleventidLE using LabelEntry $optionsFrame.statenormaleventidLE \
                -label [_m "Label|State Normal EventID:"] \
                -labelwidth $lwidth -editable no
          install statereverseeventidLE using LabelEntry $optionsFrame.statereverseeventidLE \
                -label [_m "Label|State Reversed EventID:"] \
                -labelwidth $lwidth -editable no
          # Actions
          install lefteventidLE using LabelEntry $optionsFrame.lefteventidLE \
                -label [_m "Label|Left EventID:"] \
                -labelwidth $lwidth -editable no
          install righteventidLE using LabelEntry $optionsFrame.righteventidLE \
                -label [_m "Label|Right EventID:"] \
                -labelwidth $lwidth -editable no
          install centereventidLE using LabelEntry $optionsFrame.centereventidLE \
                -label [_m "Label|Center EventID:"] \
                -labelwidth $lwidth -editable no
          install eventidLE using LabelEntry $optionsFrame.eventidLE \
                -label [_m "Label|Command EventID:"] \
                -labelwidth $lwidth -editable no
          install normaleventidLE using LabelEntry $optionsFrame.normaleventidLE \
                -label [_m "Label|Normal EventID:"] \
                -labelwidth $lwidth -editable no
          install reverseeventidLE using LabelEntry $optionsFrame.reverseeventidLE \
                -label [_m "Label|Reverse EventID:"] \
                -labelwidth $lwidth -editable no
          # Indicators
          install aspectlistLF using ttk::labelframe $optionsFrame.aspectlistLF \
                -labelanchor nw -text [_m "Label|Signal Aspect Events"]
          install aspectlistSTabNB using ScrollTabNotebook \
                $aspectlistLF.aspectlistSTabNB
          pack $aspectlistSTabNB -expand yes -fill both
          install normalindonevLE using LabelEntry $optionsFrame.normalindonevLE \
                -label [_m "Label|Normal Indicator On EventID:"] \
                -labelwidth $lwidth -editable no
          install normalindoffevLE using LabelEntry $optionsFrame.normalindoffevLE \
                -label [_m "Label|Normal Indicator Off EventID:"] \
                -labelwidth $lwidth -editable no
          install centerindonevLE using LabelEntry $optionsFrame.centerindonevLE \
                -label [_m "Label|Center Indicator On EventID:"] \
                -labelwidth $lwidth -editable no
          install centerindoffevLE using LabelEntry $optionsFrame.centerindoffevLE \
                -label [_m "Label|Center Indicator Off EventID:"] \
                -labelwidth $lwidth -editable no
          install reverseindonevLE using LabelEntry $optionsFrame.reverseindonevLE \
                -label [_m "Label|Reverse Indicator On EventID:"] \
                -labelwidth $lwidth -editable no
          install reverseindoffevLE using LabelEntry $optionsFrame.reverseindoffevLE \
                -label [_m "Label|Reverse Indicator Off EventID:"] \
                -labelwidth $lwidth -editable no
          install leftindonevLE using LabelEntry $optionsFrame.leftindonevLE \
                -label [_m "Label|Left Indicator On EventID:"] \
                -labelwidth $lwidth -editable no
          install leftindoffevLE using LabelEntry $optionsFrame.leftindoffevLE \
                -label [_m "Label|Left Indicator Off EventID:"] \
                -labelwidth $lwidth -editable no
          install rightindonevLE using LabelEntry $optionsFrame.rightindonevLE \
                -label [_m "Label|Right Indicator On EventID:"] \
                -labelwidth $lwidth -editable no
          install rightindoffevLE using LabelEntry $optionsFrame.rightindoffevLE \
                -label [_m "Label|Right Indicator Off EventID:"] \
                -labelwidth $lwidth -editable no
          install oneventidLE using LabelEntry $optionsFrame.oneventidLE \
                -label [_m "Label|Lamp On EventID:"] \
                -labelwidth $lwidth -editable no
          install offeventidLE using LabelEntry $optionsFrame.offeventidLE \
                -label [_m "Label|Lamp Off EventID:"] \
                -labelwidth $lwidth -editable no
          
          $self configurelist $args
      }
      method initializetopframe {frame args} {
          #puts stderr "*** $self initializetopframe $frame $args"
          $self configurelist $args
          if {"$options(-object)" ne ""} {
              $nameLE configure -text "$options(-object)"
          }
          $controlPointLE configure \
                -text [$options(-ctcpanel) itemcget $options(-object) \
                       -controlpoint]
          set objectType [$options(-ctcpanel) class "$options(-object)"]
          $objectTypeLE configure -text $objectType
          $self packAndConfigureOptions $objectType
      }
      method packAndConfigureOptions {objtype} {
          #puts stderr "*** $self packAndConfigureOptions $objtype"
          catch {foreach slave [pack slaves $optionsFrame] {pack forget $slave}} err
          #puts stderr "*** $self packAndConfigureOptions: err = $err"
          #puts stderr "*** $self packAndConfigureOptions: optionsFrame cleared"
          foreach opt $objectTypeOptions($objtype) {
              #puts stderr "*** $self packAndConfigureOptions: opt = $opt"
              switch -exact $opt {
                  xyctl {
                      pack $xyframe1 -fill x
                      $xyframe1 configure -text {}
                      set x1 [$options(-ctcpanel) itemcget $options(-object) \
                              -x]
                      set y1 [$options(-ctcpanel) itemcget $options(-object) \
                              -y]
                      $x1LE configure -text $x1
                      $y1LE configure -text $y1
                  }
                  xysch {
                      pack $xyframe1 -fill x
                      $xyframe1 configure -text {}
                      set x1 [$options(-ctcpanel) itemcget $options(-object) \
                              -x]
                      set y1 [$options(-ctcpanel) itemcget $options(-object) \
                              -y]
                      $x1LE configure -text $x1
                      $y1LE configure -text $y1
                  }
                  xy1sch {
                      pack $xyframe1 -fill x
                      $xyframe1 configure -text {First Coord}
                      set x1 [$options(-ctcpanel) itemcget $options(-object) -x1]
                      set y1 [$options(-ctcpanel) itemcget $options(-object) -y1]
                      $x1LE configure -text $x1
                      $y1LE configure -text $y1
                  }
                  xy2sch {
                      pack $xyframe2 -fill x
                      $xyframe2 configure -text {Second Coord}
                      set x2 [$options(-ctcpanel) itemcget $options(-object) -x2]
                      set y2 [$options(-ctcpanel) itemcget $options(-object) -y2]
                      $x2LE configure -text $x2
                      $y2LE configure -text $x2
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
                      pack $hvorientationLE -fill x
                      $hvorientationLE configure -text [$options(-ctcpanel) itemcget $options(-object) -orientation]
                  }
                  hascenter {
                      pack $hascenterLE -fill x
                      $hascenterLE configure -text [$options(-ctcpanel) itemcget $options(-object) -hascenter]
                  }
                  color {
                      pack $colorLE -fill x
                      $colorLE configure -text "[$options(-ctcpanel) itemcget $options(-object) -color]"
                  }
                  orientation {
                      pack $orientationLE -fill x
                      $orientationLE configure -text [$options(-ctcpanel) itemcget $options(-object) -orientation]
                  }
                  flipped {
                      pack $flippedLE -fill x
                      $flippedLE configure -text [$options(-ctcpanel) itemcget $options(-object) -flipped]
                  }
                  heads {
                      pack $headsLE -fill x
                      $headsLE configure -text [$options(-ctcpanel) itemcget $options(-object) -heads]
                  }
                  position {
                      pack $positionLE -fill x
                      $positionLE configure -text [$options(-ctcpanel) itemcget $options(-object) -position]
                  }
                  radius {
                      pack $radiusLE -fill x
                      $radiusLE configure -text [$options(-ctcpanel) itemcget $options(-object) -radius]
                  }
                  type {
                      pack $typeLE -fill x
                      $typeLE configure -text [$options(-ctcpanel) itemcget $options(-object) -type]
                  }
              }
          }
          #puts stderr "*** $self packAndConfigureOptions: options(-simplemode) is $options(-simplemode)"
          if {$options(-simplemode) && $objtype eq "SWPlate"} {
              set command "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
              set switch {}
              set azatraxsn  {}
              set azatraxprod {}
              set azatraxswn {}
              if {[regexp {NormalMRD[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => switch azatraxsn] > 0} {
                  set azatraxprod MRD2-U
              } elseif {[regexp {NormalSL2[[:space:]]+([[:digit:]])[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => azatraxswn switch azatraxsn] > 0} {
                  set azatraxprod "SL2 Switch $azatraxswn"
              } elseif {[regexp {NormalSR4[[:space:]]+([[:digit:]])[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => azatraxswn switch azatraxsn] > 0} {
                  set azatraxprod "SR4 Switch $azatraxswn"
              } elseif {[regexp {Normal[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)$} "$command" => switch azatraxsn] > 0} {
                  set azatraxprod MRD2-U
              }
              pack $azatraxSerialNumberLE -fill x
              $azatraxSerialNumberLE configure -text "$azatraxsn"
              pack $azatraxProductTypeLCB -fill x
              $azatraxProductTypeLE configure -text $azatraxprod
              pack $switchNameLE -fill x
              $switchNameLE configure -text "$switch"
          }
          foreach opt $objectTypeOptions($objtype) {
              #puts stderr "*** $self packAndConfigureOptions: opt = $opt"
              switch -exact $opt {
                  normalcommand {
                    if {$options(-openlcbmode)} {
                        pack $normaleventidLE -fill x
                        $normaleventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -normaleventid]"
                    } else {
                        pack $normalcommandLF -fill x
                        $normalcommandText configure -state normal
                        $normalcommandText delete 1.0 end
                        $normalcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -normalcommand]"
                    }
                  }
                  reversecommand {
                      if {$options(-openlcbmode)} {
                          pack $reverseeventidLE -fill x
                          $reverseeventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -reverseeventid]"
                      } else {
                          pack $reversecommandLF -fill x
                          $reversecommandText configure -state normal
                          $reversecommandText delete 1.0 end
                          $reversecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -reversecommand]"
                      }
                  }
                  leftcommand {
                      if {$options(-openlcbmode)} {
                          pack $lefteventidLE -fill x
                          $lefteventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -lefteventid]"
                      } else {
                          pack $leftcommandLF -fill x
                          $leftcommandText  configure -state normal
                          $leftcommandText delete 1.0 end
                          $leftcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -leftcommand]"
                      }
                  }
                  centercommand {
                    if {$options(-openlcbmode)} {
                        pack $centereventidLE -fill x
                        $centereventidLE configure -text \
                              "[$options(-parent) getOpenLCBNodeOpt $options(-object) -centereventid]"
                    } else {
                        pack $centercommandLF -fill x
                        $centercommandText configure -state normal
                        $centercommandText delete 1.0 end
                        $centercommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -centercommand]"
                    }
                  }
                  rightcommand {
                      if {$options(-openlcbmode)} {
                          pack $righteventidLE -fill x
                          $righteventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -righteventid]"
                      } else {
                          pack $rightcommandLF -fill x
                          $rightcommandText configure -state normal
                          $rightcommandText delete 1.0 end
                          $rightcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -rightcommand]"
                      }
                  }
                  command {
                      if {$options(-openlcbmode)} {
                          pack $eventidLE -fill x
                          $eventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -eventid]"
                      } else {
                          pack $commandLF -fill x
                          $commandText configure -state normal
                          $commandText delete 1.0 end
                          $commandText insert end "[$options(-ctcpanel) itemcget $options(-object) -command]"
                      }
                  }
                  statecommand {
                      if {$options(-openlcbmode)} {
                          pack $statenormaleventidLE -fill x
                          pack $statereverseeventidLE -fill x
                          $statenormaleventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -statenormaleventid]"
                          $statereverseeventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -statereverseeventid]"
                      } else {
                          pack $statecommandLF -fill x
                          $statecommandText configure -state normal
                          $statecommandText delete 1.0 end
                          $statecommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -statecommand]"
                      }
                  }
                  occupiedcommand {
                      if {$options(-openlcbmode)} {
                          pack $occupiedeventidLE -fill x
                          pack $notoccupiedeventidLE -fill x
                          $occupiedeventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -occupiedeventid]"
                          $notoccupiedeventidLE configure -text \
                                "[$options(-parent) getOpenLCBNodeOpt $options(-object) -notoccupiedeventid]"
                      } else {
                          pack $occupiedcommandLF -fill x
                          $occupiedcommandText configure -state normal
                          $occupiedcommandText delete 1.0 end
                          $occupiedcommandText insert end "[$options(-ctcpanel) itemcget $options(-object) -occupiedcommand]"
                      }
                  }
              }
          }
          if {$options(-openlcbmode)} {
              if {[info exists objectTypeIndicatorEvents($objtype)]} {
                  foreach opt $objectTypeIndicatorEvents($objtype) {
                      switch -exact $opt {
                          aspectlist {
                              $self clearallaspects
                              $self populateaspects [$options(-parent) getOpenLCBNodeOpt $options(-object) -eventidaspectlist]
                              pack $aspectlistLF -fill both -expand yes
                          }
                          normal {
                              pack $normalindonevLE -fill x
                              $normalindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -normalindonev]"
                              pack $normalindoffevLE -fill x
                              $normalindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -normalindoffev]"
                          }
                          center {
                              pack $centerindonevLE -fill x
                              $centerindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -centerindonev]"
                              pack $centerindoffevLE -fill x
                              $centerindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -centerindoffev]"
                          }
                          reverse {
                              pack $reverseindonevLE -fill x
                              $reverseindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -reverseindonev]"
                              pack $reverseindoffevLE -fill x
                              $reverseindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -reverseindoffev]"
                          }
                          left {
                              pack $leftindonevLE -fill x
                              $leftindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -leftindonev]"
                              pack $leftindoffevLE -fill x
                              $leftindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -leftindoffev]"
                          }
                          right {
                              pack $rightindonevLE -fill x
                              $rightindonevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -rightindonev]"
                              pack $rightindoffevLE -fill x
                              $rightindoffevLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -rightindoffev]"
                          }
                          onoff {
                              pack $oneventidLE -fill x
                              $oneventidLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -oneventid]"
                              pack $offeventidLE -fill x
                              $offeventidLE configure -text "[$options(-parent) getOpenLCBNodeOpt $options(-object) -offeventid]"
                          }
                      }
                  }
              }
          }
      }
      method clearallaspects {} {
          foreach aspectfr [array names aspectlist *,frame] {
              set fr $aspectlist($aspectfr)
              $aspectlistSTabNB forget $aspectlistSTabNB.$fr
              destroy $aspectlistSTabNB.$fr
          }
          array unset aspectlist
      }
      method populateaspects {eventidaspectlist} {
          set aspectcount 0
          foreach {ev aspl} $eventidaspectlist {
              incr aspectcount
              set fr aspect$aspectcount
              set aspectlist($aspectcount,frame) $fr
              ttk::frame $aspectlistSTabNB.$fr
              $aspectlistSTabNB add $aspectlistSTabNB.$fr -text [_ "Aspect %d" $aspectcount] -sticky news
              set eventid_ [LabelEntry $aspectlistSTabNB.$fr.eventid \
                            -label [_m "Label|When this event occurs"] \
                            -text $ev -editable no]
              pack $eventid_ -fill x
              set aspectlist($aspectcount,eventid) "$ev"
              set aspl_ [LabelEntry $aspectlistSTabNB.$fr.aspl \
                         -label [_m "Label|the following aspect will be displayed."] \
                         -text $aspl -editable no]
              pack $aspl_ -fill x
              set aspectlist($aspectcount,aspl) "$aspl"
          }
      }
      
  }
}


package provide CTCPanelWindow 1.0


