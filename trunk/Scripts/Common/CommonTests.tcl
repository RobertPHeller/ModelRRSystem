#* 
#* ------------------------------------------------------------------
#* CommonTests.tcl - Test all common scripts
#* Created by Robert Heller on Mon Apr 16 09:26:05 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
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

# Include all of the base level packages.
package require Tk
package require tile
package require snit
package require snitStdMenuBar   
package require Splash
package require MainWindow
package require LabelFrames

# Set the help directory path
global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
# Set the common image directory path
global CommonImageDir 
set CommonImageDir [file join [file dirname [file dirname [info script]]] \
				Common]
# Load images.
# First banner used on the splash window
image create photo DeepwoodsBanner -format gif \
				   -file [file join $CommonImageDir \
						    DeepwoodsBanner.gif]
# Deepwoods banner image.  Used in the splash screen.
# [index] DeepwoodsBanner!image

# Withdraw the main toplevel (for now).
wm withdraw .

proc SplashScreen {} {
  # Build the ``Splash Screen'' -- A popup window that tells the user what 
  # we are all about.  It gives the version and brief copyright information.
  #
  # The upper part of the splash screen gives the brief information, with
  # directions on how to get detailed information.  The lower part contains
  # an image banner for Deepwoods Software.
  # [index] SplashScreen!procedure

  splash .mrrSplash \
	-title {Model Railroad Freight Car Common Scripts Test Program, Copyright (C) 2006 Robert Heller D/B/A Deepwoods Software Model Railroad Freight Car Forwarder comes with ABSOLUTELY NO WARRANTY; for details select 'Warranty...' under the Help menu.  This is free software, and you are welcome to redistribute it under certain conditions; select 'Copying...' under the Help menu.} \
	-image DeepwoodsBanner -background {#2ba2bf} \
        -titleforeground white -statusforeground {black}
}

# Splash window message updater.
proc SplashWorkMessage {message percent} {
  .mrrSplash update "$message" $percent
  update
}

# Pop up the splash screen
SplashScreen
update

# First step: build the main window.
SplashWorkMessage "Building Main window" 0

# Proc to build the main window
proc MainWindow {} {
# Define some global variables.
  global CommonImageDir Main
  global LogWindow MainWindow

# Set some basic window manager things relating to the main window.
  wm protocol . WM_DELETE_WINDOW {CarefulExit}
  wm withdraw .
  wm title . "Common Scripts test program"

  # Create the main window
  pack [set Main [mainwindow .main]]  -expand yes -fill both
  # Create and show a toolbar -- this toolbar will mirror the File menu
  $Main toolbar add tools
  $Main toolbar show tools
  # Disable the New menu item (not used) and create a disabled new button
  # in the toolbar
  $Main menu entryconfigure file New -state disabled
  image create photo NewButtonImage -file [file join $CommonImageDir new.gif]
  $Main toolbar addbutton tools new -image NewButtonImage -state disabled
  # Bind to the Open... menu item and create an Open button in the toolbar.
  # This will open the sample CTC Panel
  $Main menu entryconfigure file Open... -command "wm deiconify $Main.ctcpanel"
  image create photo OpenButtonImage -file [file join $CommonImageDir open.gif]
  $Main toolbar addbutton tools open -image OpenButtonImage -command "wm deiconify $Main.ctcpanel"
  # Disable the Save, Save As..., and Print menu items.
  $Main menu entryconfigure file {Save} -state disabled
  image create photo SaveButtonImage -file [file join $CommonImageDir save.gif]
  $Main toolbar addbutton tools save -image SaveButtonImage -state disabled
  $Main menu entryconfigure file {Save As...} -state disabled
  $Main menu entryconfigure file Print... -state disabled
  image create photo PrintButtonImage -file [file join $CommonImageDir print.gif]
  $Main toolbar addbutton tools print -image PrintButtonImage -state disabled
  # Bind Close and Exit menu items to the exit function and create an exit button.
  $Main menu entryconfigure file Close -command {CarefulExit}
  $Main menu entryconfigure file Exit -command {CarefulExit}
  image create photo CloseButtonImage -file [file join $CommonImageDir close.gif]
  $Main toolbar addbutton tools close -image  CloseButtonImage -command CarefulExit
  set MainWindow [$Main scrollwindow getframe]
  # Create a Log window (text area) and put some text there.
  pack [set LogWindow [text $MainWindow.text]] -fill both -expand yes
  $Main scrollwindow setwidget $LogWindow
  $LogWindow insert end {
Click on the Open button on the toolbar (or select the Open item on the file
menu) to view the sample CTC Panel.  Also try out the various labeled widgets
to the right.}

}

# Build the main window.
MainWindow

# Exit function
proc CarefulExit {} {
  switch -exact "[tk_messageBox -icon question -type yesno -message {Really Exit}]" {
    no {return}
    yes {
	exit
    }
  }
}

# Build the CTC Panel
SplashWorkMessage "Building CTC Panel" 33

# Load CTC Panel code
package require CTCPanel 2.0

# Proc to create the CTC Panel
proc CTCPanelWindow {} {
# Some globals
  global Main
  global TheCTCPanel

  # Create the CTC Panel on a new, transient toplevel.
  toplevel $Main.ctcpanel
  wm withdraw $Main.ctcpanel
  wm transient $Main.ctcpanel [winfo toplevel $Main]
  wm title $Main.ctcpanel "CTC Panel"
  wm protocol $Main.ctcpanel WM_DELETE_WINDOW "wm withdraw $Main.ctcpanel"
  # Create a main window
  set panelMain [MainFrame $Main.ctcpanel.panel]
  # With a toolbar
  set panelToolbar [$panelMain addtoolbar]
  # Close button
  pack [ttk::button $panelToolbar.close -image CloseButtonImage \
				   -command "wm withdraw $Main.ctcpanel"] \
	-side  right
  pack $panelMain -fill both -expand yes
  # Create a CTC Panel
  set TheCTCPanel [CTCPanel::CTCPanel [$panelMain getframe].panel]
  pack $TheCTCPanel -fill both -expand yes

  # Populate the CTC Panel:
  # Control point Foo:
  #   Control panel items for control point Foo
  $TheCTCPanel create SWPlate foo -x 100 -y 100 -label Foo \
				  -controlpoint Foo
  $TheCTCPanel create SIGPlate foosw -x 100 -y 200 -label Foo \
				     -controlpoint Foo
  $TheCTCPanel create Lamp fooerrorlamp -x 250 -y 100 \
					-label Error \
					-controlpoint Foo \
					-color red
  $TheCTCPanel create Lamp foopowerlamp -x 250 -y 200 \
					-label Power \
					-controlpoint Foo \
					-color green
  $TheCTCPanel create Toggle foopower -x 200 -y 200 \
				      -controlpoint Foo \
	-leftcommand "$TheCTCPanel setv foopowerlamp on" \
	-rightcommand "$TheCTCPanel setv foopowerlamp off"
  $TheCTCPanel setv foopower Right
  $TheCTCPanel create CTCLabel fooctclabel -x 150 -y 250 \
		   -label "Control Point Foo"
  $TheCTCPanel create SchLabel fooschlabel -x 150 -y 250 \
		   -label "Control Point Foo"
  $TheCTCPanel create CodeButton codefoo -x 200 -y 100 \
	-controlpoint Foo \
	-command "$TheCTCPanel invoke foopower"

#  $TheCTCPanel create ThroughYard Yard2 -x 100 -y 100 \
		-controlpoint YARD2 \
#		-label "Yard 2" -orientation 4
  #  Schematic items for control point Foo
  $TheCTCPanel create Switch foo-1 -x 100 -y 100 \
		-label "Foo 1" -controlpoint Foo

  # Create some mainline trackage:
  set fooMain [$TheCTCPanel coords foo-1 Main]
  set x1 [lindex $fooMain 0]
  set y1 [lindex $fooMain 1]
  set y2 $y1
  set x2 [expr {$x1 + 200}]
  $TheCTCPanel create StraightBlock b1 -x1 $x1 -x2 $x2 \
				       -y1 $y1 -y2 $y2

  set fooDivergance [$TheCTCPanel coords foo-1 Divergence]
  set dx1 [lindex $fooDivergance 0]
  set dy1 [lindex $fooDivergance 1]
  $TheCTCPanel create StraightBlock b2b -x1 $dx1 -x2 $x2 \
					-y1 $dy1 -y2 $dy1

  # A Scissor Crossover
  $TheCTCPanel create ScissorCrossover bar-1 -x $x2 -y $y2 \
					     -label "Bar 1"

  # A piece of curved track
  set barDiv [$TheCTCPanel coords bar-1 Main2R]
  set cux1 [lindex $barDiv 0]
  set cuy1 [lindex $barDiv 1]
  set cux2 [expr {$cux1 + 50}]
  set cuy2 [expr {$cuy1 + 50}]
  $TheCTCPanel create CurvedBlock b3 -x1 $cux2 -x2 $cux1 \
				     -y1 $cuy2 -y2 $cuy1 \
		-radius 50
  # Control point Baz
  $TheCTCPanel create Crossing baz-1 -controlpoint Baz \
	-x $cux2 -y $cuy2 \
	-orientation 2 -label "Baz 1"
  set barDiv [$TheCTCPanel coords bar-1 Main1R]
  set ssx [lindex $barDiv 0]
  set ssy [lindex $barDiv 1]
  # Control Point SS
  $TheCTCPanel create SingleSlip SS-1 -controlpoint SS \
	-x $ssx -y $ssy \
	-label "SS 1"
  set SSMain [$TheCTCPanel coords SS-1 MainR]
  set dsx [lindex $SSMain 0]
  set dsy [lindex $SSMain 1]
  $TheCTCPanel create DoubleSlip SS-2 -controlpoint SS \
	-x $dsx -y $dsy \
  	-label "SS 2"
  set DSMain [$TheCTCPanel coords SS-2 MainR]
  set twsx [lindex $DSMain 0]
  set twsy [lindex $DSMain 1]
  $TheCTCPanel create ThreeWaySW SS-3 -controlpoint SS \
	-x $twsx -y $twsy \
	-label "SS 3"
  set TWSMain [$TheCTCPanel coords SS-3 Main]
  set hbx1 [lindex $TWSMain 0]
  set hby1 [lindex $TWSMain 1]
  set hbx2 [expr {$hbx1 + 100}]
  set hby2 $hby1
  # A 'hidden' block
  $TheCTCPanel create HiddenBlock HB1 -x1 $hbx1 -x2 $hbx2 \
				      -y1 $hby1 -y2 $hby2
  set TWSLDivergence [$TheCTCPanel coords SS-3 RDivergence]
  set cx2a [lindex $TWSLDivergence 0]
  set cy2a [lindex $TWSLDivergence 1]
  set cx1a [expr {$cx2a + 25}]
  set cy1a [expr {$cy2a - 12.5}]
  # Another curved section
  $TheCTCPanel create CurvedBlock CU2a -x1 $cx1a -y1 $cy1a \
					-x2 $cx2a -y2 $cy2a \
					-radius 25
  set cx2b $cx1a
  set cy2b $cy1a
  set cx1b [expr {$cx2b + 25}]
  set cy1b [expr {$cy2b + 25}]
  # Another curved section  
  $TheCTCPanel create CurvedBlock CU2b -x1 $cx1b -y1 $cy1b \
					-x2 $cx2b -y2 $cy2b \
					-radius 25
  set ylx1 $cx1b
  set yly1 $cy1b
  set ylx2 $ylx1
  set yly2 [expr {$yly1 + 50}]
  # A Straight section
  $TheCTCPanel create StraightBlock YL -x1 $ylx1 -y1 $yly1 \
					-x2 $ylx2 -y2 $yly2
  # A stub yard (control point YARD1)
  $TheCTCPanel create StubYard Yard1 -x $ylx2 -y $yly2 \
				     -orientation 2 \
		-controlpoint YARD1 -label "Yard 1"
  # A through yard (control point YARD2)
  $TheCTCPanel create ThroughYard Yard2 -x $hbx2 -y $hby2 \
		-controlpoint YARD2 \
		-label "Yard 2" -orientation 0
}

CTCPanelWindow

SplashWorkMessage "Building slidout" 66

package require LabelFrames

proc TestSlidout {} {
  global Main

  set theframe [$Main slideout add testSlideout]
  pack [FileEntry $theframe.oldfile -label "Old file:" -labelwidth 20\
		-filedialog open -defaultextension .text \
		-filetypes { 
			{{Text Files}       {.text .txt}    TEXT}
			{{All Files}        *               }}] -fill x
  pack [FileEntry $theframe.newfile -label "New file:" -labelwidth 20\
		-filedialog save -defaultextension .text \
		-filetypes { 
			{{Text Files}       {.text .txt}    TEXT}
			{{All Files}        *               }}] -fill x
  pack [FileEntry $theframe.directory -label "Directory:" \
		-labelwidth 20\
		-filedialog directory] -fill x
  pack [LabelComboBox $theframe.combo -label "Pick one:" -labelwidth 20\
        -values {A B C D}] -fill x
  $theframe.combo set A
  pack [LabelSpinBox $theframe.spin -label "Pick a value:" \
		-labelwidth 20\
		-range {1 10 1}] -fill x
  pack [LabelSelectColor $theframe.color -label "Choose a color:"\
  		-labelwidth 20] -fill x
}

TestSlidout

$Main slideout show testSlideout

update idle
set extraX 0
foreach s [$Main slideout list] {
  set rw [$Main slideout reqwidth $s]
  if {$rw > $extraX} {set extraX $rw}
}


$Main showit $extraX

catch {SplashWorkMessage {Done} 100}



  
       
