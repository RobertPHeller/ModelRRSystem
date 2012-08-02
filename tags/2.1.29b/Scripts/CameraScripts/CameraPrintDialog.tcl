#* 
#* ------------------------------------------------------------------
#* CameraPrintDialog.tcl - Camera Print Dialog
#* Created by Robert Heller on Fri Jan 12 15:39:19 2007
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

package require gettext
package require Tk
package require snit
package require BWidget

namespace eval CameraPrintDialog {
  snit::type PrintCanvasDialog {
    pragma -hastypedestroy no
    pragma -hasinstances no
    pragma -hastypeinfo no

    typecomponent dialog
    typecomponent  formLabel
    typecomponent  deviceSelect
    typecomponent    rb1
    typecomponent    printE
    typecomponent    printB
    typecomponent    rb2
    typecomponent    fileE
    typecomponent    fileB
    typecomponent  colorMode
    typecomponent    colormodeCB
    typecomponent  canvasPos
    typecomponent    canvasXSB
    typecomponent    canvasYSB
    typecomponent    canvasWidthSB
    typecomponent    canvasHeightSB
    typecomponent  pagePos
    typecomponent    anchoringFrame
    typecomponent    posFrame
    typecomponent      pageXSB
    typecomponent      pageYSB
    typecomponent      pageWidthSB
    typecomponent      pageHeightSB

    typecomponent prbdialog
    typecomponent   printerCB
 
    typevariable _Canvas {}
    typevariable _PrintCanvasOutputDevice Printer
    typevariable _PrintCanvasAnchor sw
    typeconstructor {
      set dialog {}
      set prbdialog {}
    }
    typemethod createDialog {} {
      if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
      set dialog [Dialog::create .printCanvasDialog \
			-class PrintCanvasDialog -bitmap questhead -default 0 \
			-cancel 1 -modal local -parent . \
			-side bottom -title [_ "Print Canvas"]]
      $dialog add -name print -text [_m "Button|Print"] -command [mytypemethod _Print]
      $dialog add -name cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
      $dialog add -name help -text [_m "Button|Help"] -command [list BWHelp::HelpTopic PrintCanvasDialog]
      set frame [$dialog getframe]
      set formLabel $frame.formLabel
      pack [Label::create $formLabel -font {Helvetica -24 bold roman} \
				     -text [_ "Print Lens Diagram"]] -fill x
      set deviceSelect $frame.deviceSelect
      pack [LabelFrame::create $deviceSelect -text [_m "Label|Print Device"] -side top \
      					     -relief ridge -borderwidth 2] \
	-expand yes -fill x
      pack $deviceSelect -expand yes -fill x
      set plw 8
      set prframe [$deviceSelect getframe].prframe
      pack [frame $prframe -borderwidth 0] -expand yes -fill x
      set rb1 $prframe.rb1
      pack [radiobutton $rb1 -text [_m "Label|Printer:"] -width $plw -anchor w \
			     -value Printer \
			     -command [mytypemethod _TogglePrintDev] \
			     -variable [mytypevar _PrintCanvasOutputDevice]] \
	-side left -expand yes -fill x
      set printE $prframe.entry
      pack [Entry::create $printE] -side left -fill x
      set printB $prframe.button
      pack [Button::create $printB -text [_m "Button|Browse"] \
				   -command [mytypemethod _BrowsePrinters]] \
		-side right

      set fiframe [$deviceSelect getframe].f1frame
      pack [frame $fiframe -borderwidth 0] -expand yes -fill x
      set rb2 $fiframe.rb2
      pack [radiobutton $rb2 -text [_m "Label|File:"] -width $plw -anchor w \
			     -value File \
			     -command [mytypemethod _TogglePrintDev] \
			     -variable [mytypevar _PrintCanvasOutputDevice]] \
	-side left -expand yes -fill x
      set fileE $fiframe.entry
      pack [Entry::create $fileE -state disabled] -side left -fill x
      set fileB $fiframe.button
      pack [Button::create $fileB -text [_m "Button|Browse"] \
				  -command [mytypemethod _BrowsePSFiles] \
				  -state disabled] -side right

      set colorMode $frame.colorMode
      LabelFrame::create $colorMode -text [_m "Label|Color Mode"] -side top \
				    -relief ridge -borderwidth 2
      pack $colorMode -expand yes -fill x
      set cmFrame [$colorMode getframe] 
      set colormodeCB $cmFrame.comboBox
      ComboBox::create $colormodeCB -values {color gray mono} -editable no
      pack $colormodeCB -fill x
      $colormodeCB setvalue first

      set canvasPos $frame.canvasPos
      LabelFrame::create $canvasPos -text [_m "Label|Canvas Position"] -side top \
				    -relief ridge -borderwidth 2
      pack $canvasPos -expand yes -fill x
      set cpFrame [$canvasPos getframe]
      set canvasXLF $cpFrame.xLF
      pack [LabelFrame::create $canvasXLF -text X:] -side left -fill x
      set canvasXSB [$canvasXLF getframe].spinBox
      pack [SpinBox::create $canvasXSB -range {-1000.0 1000.0 1} -width 5] -fill x
      set canvasYLF $cpFrame.yLF
      pack [LabelFrame::create $canvasYLF -text Y:] -side left -fill x
      set canvasYSB [$canvasYLF getframe].spinBox
      pack [SpinBox::create $canvasYSB -range {-1000.0 1000.0 1} -width 5] -fill x
      set canvasWidthLF $cpFrame.widthLF
      pack [LabelFrame::create $canvasWidthLF -text [_m "Label|Width:"]] -side left -fill x
      set canvasWidthSB [$canvasWidthLF getframe].spinBox
      pack [SpinBox::create $canvasWidthSB -range {1 1000 1} -width 5] -fill x
      set canvasHeightLF $cpFrame.heightLF
      pack [LabelFrame::create $canvasHeightLF -text [_m "Label|Height:"]] -side left -fill x
      set canvasHeightSB [$canvasHeightLF getframe].spinBox
      pack [SpinBox::create $canvasHeightSB -range {1 1000 1} -width 5] -fill x

      set pagePos $frame.pagePos
      LabelFrame::create $pagePos -text "Page Position" -side top \
                                    -relief ridge -borderwidth 2
      pack $pagePos -expand yes -fill x
      set ppFrame [$pagePos getframe]
      set anchoringFrame $ppFrame.anchoring
      pack [frame $anchoringFrame -borderwidth 0] -fill x -expand yes
      grid [radiobutton $anchoringFrame.nw -text NW -value nw \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 0 -column 0 -sticky news
      grid [radiobutton $anchoringFrame.n -text N -value n \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 0 -column 1 -sticky news
      grid [radiobutton $anchoringFrame.ne -text NE -value ne \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 0 -column 2 -sticky news
      grid [radiobutton $anchoringFrame.w -text W -value w \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 1 -column 0 -sticky news
      grid [radiobutton $anchoringFrame.center -text C -value center \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 1 -column 1 -sticky news
      grid [radiobutton $anchoringFrame.e -text E -value e \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 1 -column 2 -sticky news
      grid [radiobutton $anchoringFrame.sw -text SW -value sw \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 2 -column 0 -sticky news
      grid [radiobutton $anchoringFrame.s -text S -value s \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 2 -column 1 -sticky news
      grid [radiobutton $anchoringFrame.se -text SE -value se \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 2 -column 2 -sticky news
      grid rowconfigure $anchoringFrame 0 -uniform
      grid rowconfigure $anchoringFrame 1 -uniform
      grid rowconfigure $anchoringFrame 2 -uniform
      grid columnconfigure $anchoringFrame 0 -uniform
      grid columnconfigure $anchoringFrame 1 -uniform
      grid columnconfigure $anchoringFrame 2 -uniform

      set posFrame       $ppFrame.pos
      pack [frame $posFrame -borderwidth 0] -fill x -expand yes
      set pageXLF $posFrame.xLF
      pack [LabelFrame::create $pageXLF -text X:] -side left -fill x
      set pageXSB [$pageXLF getframe].spinBox
      pack [SpinBox::create $pageXSB -range {0.0 612.0 1} -width 5] -fill x
      $pageXSB configure -text 36.0
      set pageYLF $posFrame.yLF
      pack [LabelFrame::create $pageYLF -text Y:] -side left -fill x
      set pageYSB [$pageYLF getframe].spinBox
      pack [SpinBox::create $pageYSB -range {0.0 792.0 1} -width 5] -fill x
      $pageYSB configure -text 36.0
      set pageWidthLF $posFrame.widthLF
      pack [LabelFrame::create $pageWidthLF -text [_m "Label|Width:"]] -side left -fill x
      set pageWidthSB [$pageWidthLF getframe].spinBox
      pack [SpinBox::create $pageWidthSB -range {1 612 1} -width 5 -text 612] -fill x
      $pageWidthSB configure -text [expr {612 - 72}]
      set pageHeightLF $posFrame.heightLF
      pack [LabelFrame::create $pageHeightLF -text [_m "Label|Height:"]] -side left -fill x
      set pageHeightSB [$pageHeightLF getframe].spinBox
      pack [SpinBox::create $pageHeightSB -range {1 792 1} -width 5 -text 792] -fill x
      $pageHeightSB configure -text [expr {792 - 72}]
    }
    typemethod createPrbDialog {} {
      if {![string equal "$prbdialog" {}] && [winfo exists $prbdialog]} {return}
      set prbdialog [Dialog::create $dialog.browsePrintersDialog \
			-class BrowsePrintersDialog -bitmap questhead \
			-default 0 -cancel 1 -modal local -parent $dialog \
			-side bottom -title [_ "Select Printer"]]
      $prbdialog add -name ok -text [_m "Button|OK"] -command [mytypemethod _SelectPrinter]
      $prbdialog add -name cancel -text [_m "Button|Cancel"] -command [mytypemethod _CancelBrowsePrinters]
      $prbdialog add -name help -text [_m "Button|Help"] -command [list BWHelp::HelpTopic BrowsePrintersDialog]
      set frame [$prbdialog getframe]
      set printerLF $frame.printerLF
      pack [LabelFrame::create $printerLF -text [_ "Printer:"]] -fill x
      set printerCB [$printerLF getframe].printerCB
      pack [ComboBox::create $printerCB -editable no] -fill x

    }
    typemethod _SelectPrinter {} {
      $prbdialog withdraw
      return [$prbdialog enddialog ok]
    }
    typemethod _CancelBrowsePrinters {} {
      $prbdialog withdraw
      return [$prbdialog enddialog cancel]
    }
    typemethod _TogglePrintDev {} {
      switch $_PrintCanvasOutputDevice {
	Printer {
	  $printE configure -state normal
	  $printB configure -state normal
	  $fileE  configure -state disabled
	  $fileB  configure -state disabled
	}
	File {
	  $printE configure -state disabled
	  $printB configure -state disabled
	  $fileE  configure -state normal
	  $fileB  configure -state normal
	}
      }
    }
    
    typemethod _BrowsePrinters {} {
      $type createPrbDialog
      set printers {}
      set defprinter {}
      global tcl_platform
      switch -exact "$tcl_platform(platform)" {
	macintosh -
	unix {
	  if {![catch [list open "|[auto_execok lpstat] -a" r] lpfp]} {
	    while {[gets $lpfp line] >= 0} {
	      if {[regexp {^([^[:space:]]*)[[:space:]]} "$line" -> printer] > 0} {
		lappend printers $printer
	      }
	    }
	    close $lpfp
	  }
	  if {![catch [list open "|[auto_execok lpstat] -d" r] lpfp]} {
	    if {[gets $lpfp line] >= 0} {
	      regexp {destination:[[:space:]]*([^[:space:]]*)[[:space:]]*.*$} "$line" -> defprinter
	    }
	    close $lpfp
	  }
	}
        windows {
        }
      }
      $printerCB configure -values $printers
      set curprinter [$printE cget -text]
      if {[string equal "$curprinter" {}]} {set curprinter "$defprinter"}
      set curprindex [lsearch $printers "$curprinter"]
      set defprindex [lsearch $printers "$defprinter"]
      if {$curprindex >= 0} {
	$printerCB setvalue @$curprindex
      } elseif {$defprindex >= 0} {
	$printerCB setvalue @$defprindex
      } else {
	$printerCB setvalue first
      }
      switch [$prbdialog draw] {
	ok {
	  $printE configure -text [lindex $printers [$printerCB getvalue]]
	}
      }
    }
    typemethod _BrowsePSFiles {} {
      set curfile "[$fileE cget -text]"
      set curdirectory [file dirname "$curfile"]
      set newfile [tk_getSaveFile -defaultextension .ps \
				  -filetypes {
					{{Postscript Files} .ps TEXT}
					{{All Files} * TEXT}
				  } \
				  -initialfile "$curfile" \
				  -initialdir "$curdirectory" \
				  -parent $dialog \
				  -title [_ "Postscript file to save output to"]]
      if {![string equal "$newfile" {}]} {
	$fileE configure -text "$newfile"
      }
    }
    typemethod draw {args} {
      $type createDialog
      set _Canvas [from args -canvas {}]
      if {[string length "$_Canvas"] == 0} {
	tk_messageBox -type ok -icon error -message [_ "Missing -canvas option!"]
	return
      }
      if {![winfo exists $_Canvas]} {
	tk_messageBox -type ok -icon error -message [format [_ "%s does not exist!"] $_Canvas]
	return
      }
      set sr [$_Canvas cget -scrollregion]
      if {[llength $sr] == 0} {set sr [$_Canvas bbox all]}
      if {[llength $sr] == 0} {
	tk_messageBox -type ok -icon warning -message [format [_ "%s is empty, print aborted!"] $_Canvas]
	return
      }
      set minX [lindex $sr 0]
      set maxX [lindex $sr 2]
      set maxWidth [expr {$maxX - $minX + 1}]
      set minY [lindex $sr 1]
      set maxY [lindex $sr 3]
      set maxHeight [expr {$maxY - $minY + 1}]
      $canvasXSB configure -range [list $minX $maxX 1.0] -text $minX
      $canvasYSB configure -range [list $minY $maxY 1.0] -text $minY
      $canvasWidthSB configure -range [list 1 $maxWidth 1] -text $maxWidth
      $canvasHeightSB configure -range [list 1 $maxHeight 1] -text $maxHeight
      set parent [from args -parent .]
      $dialog configure -parent $parent
      wm transient [winfo toplevel $dialog] $parent
      return [Dialog::draw $dialog]
    }
    typemethod _Print {} {
      Dialog::withdraw $dialog
      set result [Dialog::enddialog $dialog print]
      global tcl_platform
      switch $_PrintCanvasOutputDevice {
	Printer {
	  set printer "[$printE cget -text]"
	  switch -exact "$tcl_platform(platform)" {
	    macintosh -
	    unix {
	      set lp [auto_execok lp]
	      set lpr [auto_execok lpr]
	      if {[string equal "$lp" {}] || [catch {open "|$lp -d $printer" w} printchan]} {
		if {[string equal "$lpr" {}] || [catch {open "|$lpr -P$printer" w} printchan]} {
		  tk_messageBox -type ok -icon error -message [format [_ "Could not open pipe to printer queue: %s"] $printchan]
		  return error
		}
	      }
	    }
	    windows {
	      tk_messageBox -type ok -icon error -message [_ "No spooling command available"]
	      return error
	    }
	  }
	}
	File {
	  if {[catch {open "[$fileE cget -text]" w} printchan]} {
	    tk_messageBox -type ok -icon error -message [format [_ "Could not open %s for output: %s"] [$fileE cget -text] $printchan]
	    return error
	  }
	}
      }
      $_Canvas postscript -channel $printchan \
		-colormode [$colormodeCB cget -text] \
		-x [$canvasXSB cget -text] -y [$canvasYSB cget -text] \
		-width [$canvasWidthSB cget -text] \
		-height [$canvasHeightSB cget -text] \
		-pagex [$pageXSB cget -text] -pagey [$pageYSB cget -text] \
		-pagewidth [$pageWidthSB cget -text] \
		-pageheight [$pageHeightSB cget -text] \
		-pageanchor $_PrintCanvasAnchor
      close $printchan
      return $result
    }
    typemethod _Cancel {} {
      Dialog::withdraw $dialog
      return [Dialog::enddialog $dialog cancel]
    }
  }

}

package provide CameraPrintDialog 1.0
