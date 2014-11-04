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
package require tile
package require Dialog
package require LabelFrames
package require HTMLHelp 2.0


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
      set dialog [Dialog .printCanvasDialog \
			-class PrintCanvasDialog -bitmap questhead -default print \
			-cancel cancel -modal local -parent . \
			-side bottom -title [_ "Print Canvas"]]
      $dialog add print -text [_m "Button|Print"] -command [mytypemethod _Print]
      $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
      $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp help PrintCanvasDialog]
      set frame [$dialog getframe]
      set formLabel $frame.formLabel
      pack [ttk::label $formLabel -font {Helvetica -24 bold roman} \
				     -text [_ "Print Lens Diagram"]] -fill x
      set deviceSelect $frame.deviceSelect
      pack [ttk::labelframe $deviceSelect -text [_m "Label|Print Device"] -labelanchor nw \
      					     -relief ridge -borderwidth 2] \
	-expand yes -fill x
      pack $deviceSelect -expand yes -fill x
      set plw 8
      set prframe $deviceSelect.prframe
      pack [ttk::frame $prframe -borderwidth 0] -expand yes -fill x
      set rb1 $prframe.rb1
      pack [ttk::radiobutton $rb1 -text [_m "Label|Printer:"] -width $plw \
			     -value Printer \
			     -command [mytypemethod _TogglePrintDev] \
			     -variable [mytypevar _PrintCanvasOutputDevice]] \
	-side left -expand no -fill x
      set printE $prframe.entry
      pack [ttk::entry $printE] -side left -fill x -expand yes
      set printB $prframe.button
      pack [ttk::button $printB -text [_m "Button|Browse"] \
				   -command [mytypemethod _BrowsePrinters]] \
		-side right

      set fiframe $deviceSelect.f1frame
      pack [ttk::frame $fiframe -borderwidth 0] -expand yes -fill x
      set rb2 $fiframe.rb2
      pack [ttk::radiobutton $rb2 -text [_m "Label|File:"] -width $plw  \
			     -value File \
			     -command [mytypemethod _TogglePrintDev] \
			     -variable [mytypevar _PrintCanvasOutputDevice]] \
	-side left -expand no -fill x
      set fileE $fiframe.entry
      pack [ttk::entry $fileE -state disabled] -side left -fill x -expand yes
      set fileB $fiframe.button
      pack [ttk::button $fileB -text [_m "Button|Browse"] \
				  -command [mytypemethod _BrowsePSFiles] \
				  -state disabled] -side right

      set colorMode $frame.colorMode
      ttk::labelframe $colorMode -text [_m "Label|Color Mode"] -labelanchor nw \
				    -relief ridge -borderwidth 2
      pack $colorMode -expand yes -fill x
      set cmFrame $colorMode
      set colormodeCB $cmFrame.comboBox
      ttk::combobox $colormodeCB -values {color gray mono} -state readonly
      pack $colormodeCB -fill x
      $colormodeCB set color

      set canvasPos $frame.canvasPos
      ttk::labelframe $canvasPos -text [_m "Label|Canvas Position"] -labelanchor nw \
				    -relief ridge -borderwidth 2
      pack $canvasPos -expand yes -fill x
      set cpFrame $canvasPos
      set canvasXLF $cpFrame.xLF
      pack [LabelFrame $canvasXLF -text X:] -side left -fill x
      set canvasXSB [$canvasXLF getframe].spinBox
      pack [spinbox $canvasXSB -from -1000.0 -to 1000.0 -increment 1 -width 5] -fill x
      set canvasYLF $cpFrame.yLF
      pack [LabelFrame $canvasYLF -text Y:] -side left -fill x
      set canvasYSB [$canvasYLF getframe].spinBox
      pack [spinbox $canvasYSB -from -1000.0 -to 1000.0 -increment 1 -width 5] -fill x
      set canvasWidthLF $cpFrame.widthLF
      pack [LabelFrame $canvasWidthLF -text [_m "Label|Width:"]] -side left -fill x
      set canvasWidthSB [$canvasWidthLF getframe].spinBox
      pack [spinbox $canvasWidthSB -from 1 -to 1000 -increment 1 -width 5] -fill x
      set canvasHeightLF $cpFrame.heightLF
      pack [LabelFrame $canvasHeightLF -text [_m "Label|Height:"]] -side left -fill x
      set canvasHeightSB [$canvasHeightLF getframe].spinBox
      pack [spinbox $canvasHeightSB -from 1 -to 1000 -increment 1 -width 5] -fill x

      set pagePos $frame.pagePos
      ttk::labelframe $pagePos -text "Page Position" -labelanchor nw \
                                    -relief ridge -borderwidth 2
      pack $pagePos -expand yes -fill x
      set ppFrame $pagePos
      set anchoringFrame $ppFrame.anchoring
      pack [ttk::frame $anchoringFrame -borderwidth 0] -fill x -expand yes
      grid [ttk::radiobutton $anchoringFrame.nw -text NW -value nw \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 0 -column 0 -sticky news
      grid [ttk::radiobutton $anchoringFrame.n -text N -value n \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 0 -column 1 -sticky news
      grid [ttk::radiobutton $anchoringFrame.ne -text NE -value ne \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 0 -column 2 -sticky news
      grid [ttk::radiobutton $anchoringFrame.w -text W -value w \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 1 -column 0 -sticky news
      grid [ttk::radiobutton $anchoringFrame.center -text C -value center \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 1 -column 1 -sticky news
      grid [ttk::radiobutton $anchoringFrame.e -text E -value e \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 1 -column 2 -sticky news
      grid [ttk::radiobutton $anchoringFrame.sw -text SW -value sw \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 2 -column 0 -sticky news
      grid [ttk::radiobutton $anchoringFrame.s -text S -value s \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 2 -column 1 -sticky news
      grid [ttk::radiobutton $anchoringFrame.se -text SE -value se \
			-variable [mytypevar _PrintCanvasAnchor]] \
		-row 2 -column 2 -sticky news
      grid rowconfigure $anchoringFrame 0 -uniform
      grid rowconfigure $anchoringFrame 1 -uniform
      grid rowconfigure $anchoringFrame 2 -uniform
      grid columnconfigure $anchoringFrame 0 -uniform
      grid columnconfigure $anchoringFrame 1 -uniform
      grid columnconfigure $anchoringFrame 2 -uniform

      set posFrame       $ppFrame.pos
      pack [ttk::frame $posFrame -borderwidth 0] -fill x -expand yes
      set pageXLF $posFrame.xLF
      pack [LabelFrame $pageXLF -text X:] -side left -fill x
      set pageXSB [$pageXLF getframe].spinBox
      pack [spinbox $pageXSB -from 0.0 -to 612.0 -increment 1 -width 5] -fill x
      $pageXSB set 36.0
      set pageYLF $posFrame.yLF
      pack [LabelFrame $pageYLF -text Y:] -side left -fill x
      set pageYSB [$pageYLF getframe].spinBox
      pack [spinbox $pageYSB -from 0.0 -to 792.0 -increment 1 -width 5] -fill x
      $pageYSB set 36.0
      set pageWidthLF $posFrame.widthLF
      pack [LabelFrame $pageWidthLF -text [_m "Label|Width:"]] -side left -fill x
      set pageWidthSB [$pageWidthLF getframe].spinBox
      pack [spinbox $pageWidthSB -from 1 -to 612 -increment 1 -width 5 -text 612] -fill x
      $pageWidthSB set [expr {612 - 72}]
      set pageHeightLF $posFrame.heightLF
      pack [LabelFrame $pageHeightLF -text [_m "Label|Height:"]] -side left -fill x
      set pageHeightSB [$pageHeightLF getframe].spinBox
      pack [spinbox $pageHeightSB -from 1 -to 792 -increment 1 -width 5 -text 792] -fill x
      $pageHeightSB set [expr {792 - 72}]
    }
    typemethod createPrbDialog {} {
      if {![string equal "$prbdialog" {}] && [winfo exists $prbdialog]} {return}
      set prbdialog [Dialog $dialog.browsePrintersDialog \
			-class BrowsePrintersDialog -bitmap questhead \
			-default ok -cancel cancel -modal local -parent $dialog \
			-side bottom -title [_ "Select Printer"]]
      $prbdialog add ok -text [_m "Button|OK"] -command [mytypemethod _SelectPrinter]
      $prbdialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _CancelBrowsePrinters]
      $prbdialog add help -text [_m "Button|Help"] -command [list HTMLHelp HelpTopic BrowsePrintersDialog]
      set frame [$prbdialog getframe]
      set printerLF $frame.printerLF
      pack [LabelFrame $printerLF -text [_ "Printer:"]] -fill x
      set printerCB [$printerLF getframe].printerCB
      pack [ttk::combobox $printerCB -state readonly] -fill x

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
      set curprinter [$printE get]
      if {[string equal "$curprinter" {}]} {set curprinter "$defprinter"}
      set curprindex [lsearch $printers "$curprinter"]
      set defprindex [lsearch $printers "$defprinter"]
      if {$curprindex >= 0} {
	$printerCB set [lindex $printers $curprindex]
      } elseif {$defprindex >= 0} {
	$printerCB set [lindex $printers $defprindex]
      } else {
	$printerCB set [lindex $printers 0]
      }
      switch [$prbdialog draw] {
          ok {
              $printE delete 0 end
              $printE insert end [$printerCB get]
          }
      }
    }
    typemethod _BrowsePSFiles {} {
      set curfile "[$fileE get]"
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
         $fileE delete 0 end
         $fileE insert end "$newfile"
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
      $canvasXSB configure -from $minX -to $maxX -increment 1.0
      $canvasXSB set $minX
      $canvasYSB configure -from $minY -to $maxY -increment 1.0
      $canvasYSB set $minY
      $canvasWidthSB configure -from 1 -to $maxWidth -increment 1
      $canvasWidthSB set $maxWidth
      $canvasHeightSB configure -from 1 -to $maxHeight -increment 1
      $canvasHeightSB set $maxHeight
      set parent [from args -parent .]
      $dialog configure -parent $parent
      wm transient [winfo toplevel $dialog] $parent
      return [$dialog draw]
    }
    typemethod _Print {} {
      $dialog withdraw
      set result [$dialog enddialog print]
      global tcl_platform
      switch $_PrintCanvasOutputDevice {
	Printer {
	  set printer "[$printE get]"
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
	  if {[catch {open "[$fileE get]" w} printchan]} {
	    tk_messageBox -type ok -icon error -message [format [_ "Could not open %s for output: %s"] [$fileE get] $printchan]
	    return error
	  }
	}
      }
      $_Canvas postscript -channel $printchan \
		-colormode [$colormodeCB get] \
		-x [$canvasXSB get] -y [$canvasYSB get] \
		-width [$canvasWidthSB get] \
		-height [$canvasHeightSB get] \
		-pagex [$pageXSB get] -pagey [$pageYSB get] \
		-pagewidth [$pageWidthSB get] \
		-pageheight [$pageHeightSB get] \
		-pageanchor $_PrintCanvasAnchor
      close $printchan
      return $result
    }
    typemethod _Cancel {} {
      $dialog withdraw
      return [$dialog enddialog cancel]
    }
  }

}

package provide CameraPrintDialog 1.0
