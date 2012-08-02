#* 
#* ------------------------------------------------------------------
#* CameraCalculator.tcl - Common Camera Calculator Code
#* Created by Robert Heller on Sun Jan 14 16:05:47 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.1  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
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

package require Tk
package require BWidget
package require BWStdMenuBar
package require BWHelp
package require Lens
package require CameraPrintDialog
package require Version

global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
#puts stderr "*** HelpDir = $HelpDir"

namespace eval CameraCalculator {
  variable PI [expr {acos(0.0)*2.0}]
  variable FilmWidths
  array set FilmWidths [list  \
	35mm [expr {36 / 25.4}] \
	DX16x24 [expr {16 / 25.4}] \
  ]
  set FilmNames {35mm DX16x24}
  variable Scales
  array set Scales {
   III		16
   G		20.3
   II		22.5
   Standard	26.59
   I            32
   0		48
   S		64
   00           76
   H0           87.1
   TT		120
   000		148
   N            160
   Z            200
   TTT		240
  }
  variable ScaleNames {III G II Standard I 0 S 00 H0 TT 000 N Z TTT}
  variable LensFiles {
	{{Lens Files} {.lenses} TEXT}
        {{All Files}  *         TEXT}
  }
}


proc CameraCalculator::CarefulExit {{dontask no}} {
  if {!$dontask} {
    set dontask [tk_messageBox -type yesno -icon question \
				-message "Really Exit?"]
  }
  if {!$dontask} {return}
  global IsSlave
  if {$IsSlave} {
    puts stdout "101 Exit"
    flush stdout
    set ans [gets stdin]
    #puts stderr "*** SignalExit: ans = '$ans'"
  }
  exit
}

proc CameraCalculator::MaxLength {list} {
  set maxlength 0
  foreach e $list {
    set length [string length "$e"]
    if {$length > $maxlength} {set maxlength $length}
  }
  return $maxlength
}

proc CameraCalculator::CameraCalculator {anyDistanceP} {
  variable ScaleNames
  variable FilmNames

  set menubar [StdMenuBar::MakeMenu \
	-file {"&File" {file} {file} 0 {
	{command "&New" {file:new} "New Lens" {Ctrl n} 
					-command {CameraCalculator::GetNewLensSpec}}
	{command "&Open..." {file:open} "Load Lenses" {Ctrl o}
					-command {CameraCalculator::LoadLenses}}
	{command "&Save"    {file:save} "Save Lenses" {Ctrl s}
					-command {CameraCalculator::SaveLenses}}
	{command "Save &As..." {file:save} "Save Lenses" {Ctrl s}
					-command {CameraCalculator::SaveLenses}}
        {command "&Print..." {file:print} "Print Diagram" {Ctrl p}
					-command {CameraCalculator::PrintDiagram}}
	{command "&Close" {file:close} "Close the application" {Ctrl q}
					-command {CameraCalculator::CarefulExit}}
	{command "E&xit" {file:exit}  "Close the application" {Ctrl q}
					-command {CameraCalculator::CarefulExit}}
	}
    }]

  variable Status {}
  pack [MainFrame::create .main -menu $menubar -textvariable CameraCalculator::Status] \
	-expand yes -fill both
  .main showstatusbar status
  set frame [.main getframe]
  set sw [ScrolledWindow::create $frame.canvasSW -scrollbar both -auto both]
  pack $sw -expand yes -fill both
  variable LensCanvas [canvas $sw.lensCanvas]
  pack $LensCanvas -expand yes -fill both
  $sw setwidget $LensCanvas
  set bottom $frame.bottom
  pack [frame $bottom -borderwidth 0] -fill x
  if {$anyDistanceP} {
    set distanceLF [LabelFrame::create $bottom.distanceLF \
					-text "Distance (inches):" -side left]
    pack $distanceLF -side left -fill x -expand yes
    variable DistanceSB [SpinBox::create [$distanceLF getframe].spinBox \
				-range {1.0 1000000.0 1.0} -width 5]
    pack $DistanceSB -fill x -expand yes
  } else {
    variable DistanceSB {}
  }
  set lensLF [LabelFrame::create $bottom.lensLF \
					-text "Lens:" -side left]
  pack $lensLF -side left -fill x -expand yes
  variable LensCB [Lens::LensComboBox create [$lensLF getframe].comboBox]
  pack $LensCB -fill x -expand yes
  $LensCB setvalue first
  set scaleLF [LabelFrame::create $bottom.scale2LF \
					-text "Scale:" -side left]
  pack $scaleLF -side left -fill x -expand yes
  variable ScaleCB [ComboBox::create [$scaleLF getframe].comboBox \
  				-editable no -values $ScaleNames \
				-width [MaxLength $ScaleNames]]
  $ScaleCB setvalue @[lsearch $ScaleNames H0]
  pack  $ScaleCB -fill x -expand yes
  set filmSizeLF [LabelFrame::create $bottom.filmSizeLF \
					-text "Film Image Size:" -side left]
  pack $filmSizeLF -side left -fill x -expand yes
  variable FilmSizeCB [ComboBox::create [$filmSizeLF getframe].comboBox \
  				-editable no -values $FilmNames \
				-width [MaxLength $FilmNames]]
  $FilmSizeCB setvalue @[lsearch $FilmNames 35mm]
  pack  $FilmSizeCB -fill x -expand yes

  pack [Button::create $bottom.compute -text "Compute" \
				-command CameraCalculator::Compute] -side right
  
}

proc CameraCalculator::GetNewLensSpec {} {
  variable LensCB
  Lens::Lens getnewlensspec -updatescript "$LensCB updatelenslist"
}

proc CameraCalculator::LoadLenses {{filename {}}} {
  variable LensCB
  variable LensFiles
  if {[string equal "$filename" {}]} {
    set filename [tk_getOpenFile -defaultextension .lens \
				 -filetypes $LensFiles \
				 -parent . \
				 -title "File to load lenses from"]
  }
  if {[string equal "$filename" {}]} {return}
  if {[catch {open "$filename" r} lensfp]} {
    tk_messageBox -type ok -icon error -message "Could not open $filename: $lensfp"
    return
  }
  Lens::Lens readlensesfromchannel $lensfp
  close $lensfp
  $LensCB updatelenslist
}

proc CameraCalculator::SaveLenses {{filename {}}} {
  variable LensFiles
  if {[string equal "$filename" {}]} {
    set filename [tk_getOpenFile -defaultextension .lens \
				 -filetypes $LensFiles \
				 -parent . \
				 -title "File to save lenses to"]
  }
  if {[string equal "$filename" {}]} {return}
  if {[catch {open "$filename" w} lensfp]} {
    tk_messageBox -type ok -icon error -message "Could not open $filename: $lensfp"
    return
  }
  Lens::Lens writelensestochannel $lensfp
  close $lensfp
}

proc CameraCalculator::Compute {} {
  variable PI
  variable FilmWidths
  variable Scales
  variable LensCanvas
  variable DistanceSB
  variable LensCB
  variable ScaleCB
  variable FilmSizeCB
  variable Status

  set selectedLens [$LensCB getselectedlens]
  set AngView [$selectedLens viewAngleRadians]
  set angle [expr {double($AngView) / 2.0}]
  set minfocus [$selectedLens cget -minimumfocus]
  set lensname [$selectedLens cget -name]
  if {[string equal $DistanceSB {}]} {
    set distance $minfocus
  } else {
    set distanceIn [$DistanceSB cget -text]
    if {![string is double -strict "$distanceIn"]} {
      tk_messageBox -type ok -icon error -message "Please enter a number for distance!"
      return
    }
    set distance [expr {double($distanceIn) / 12.0}]
  }
  if {$distance < $minfocus} {
    set distance $minfocus
  }
  set scale $Scales([$ScaleCB get])
  set depthScaleFeet  [expr {$scale * $distance}]
  set widthScaleFeet  [expr {($depthScaleFeet  * tan($angle)) *  2.0}]
  set widthRealInches [expr {($widthScaleFeet / double($scale)) * 12.0}]
  set depthRealInches [expr {($depthScaleFeet / double($scale)) * 12.0}]
  set filmWidth $FilmWidths([$FilmSizeCB get])
  set scaleSlideWidthInches [expr {$filmWidth * $scale}]
  set scaleSlideScaleFactor [expr {$widthRealInches / $scaleSlideWidthInches}]
  set Status "$lensname at [expr {int($depthRealInches)}] inches"
  
  $LensCanvas delete all
  $LensCanvas create line 1.5c 1.5c [expr {$widthRealInches + 1.5}]c 1.5c \
			  [expr {$widthRealInches + 1.5}]c 1.5c \
			  [expr {($widthRealInches / 2.0) + 1.5}]c \
			  [expr {$depthRealInches + 1.5}]c \
			  [expr {($widthRealInches / 2.0) + 1.5}]c \
			  [expr {$depthRealInches + 1.5}]c 1.5c 1.5c \
		-width 3 -join miter
  $LensCanvas create text [expr {($widthRealInches / 2.0) + 1.5}]c .5c \
	-anchor n \
	-text "$widthScaleFeet scale feet, $widthRealInches real inches"
  $LensCanvas create line 1.5c 1c [expr {$widthRealInches + 1.5}]c 1c -arrow both
  $LensCanvas create text 1.5c [expr {($depthRealInches /  2.0) + 3.5}]c \
	-anchor w \
	-text "$depthScaleFeet scale feet,\n$depthRealInches real inches"
  $LensCanvas create line 1c 1.5c 1c [expr {$depthRealInches + 1.5}]c \
		-arrow both
  $LensCanvas create line 1.5c [expr {$depthRealInches + 1.5}]c \
			  [expr {($widthRealInches / 2.0) + 1.5}]c \
			  [expr {$depthRealInches + 1.5}]c \
			  -stipple gray25 -width 2
  $LensCanvas create text [expr {($widthRealInches / 2.0) + 1.5}]c 2c \
	-anchor n -text {(Scene focal plane)}
  set t [$LensCanvas create text [expr {($widthRealInches / 2.0) + 1.5}]c \
				 [expr {$depthRealInches + 2.0}]c \
	-anchor n -text {(Camera)}]
  set bottom [lindex [$LensCanvas bbox $t] 3]
  set t [$LensCanvas create text [expr {($widthRealInches / 2.0) + 1.5}]c \
  				 [expr {$bottom + 5}]  -anchor n \
			-text {(Lens bottom even with "ground")}]
  set bottom [lindex [$LensCanvas bbox $t] 3]
  set t [$LensCanvas create text [expr {($widthRealInches / 2.0) + 1.5}]c \
  				 [expr {$bottom + 5}]  -anchor n \
			-text "Lens: $lensname"]
  set bottom [lindex [$LensCanvas bbox $t] 3]
  $LensCanvas create text [expr {($widthRealInches / 2.0) + 1.5}]c \
                          [expr {$bottom + 5}]  -anchor n \
	-text "[$ScaleCB get] Slide width is $scaleSlideWidthInches inches, scale factor is $scaleSlideScaleFactor"
  $LensCanvas configure -scrollregion [$LensCanvas bbox all]
}

proc CameraCalculator::PrintDiagram {} {
  variable LensCanvas
  CameraPrintDialog::PrintCanvasDialog draw -canvas $LensCanvas
}


package provide CameraCalculator 1.0
