#* 
#* ------------------------------------------------------------------
#* PrintDialog.tcl - Common Print Dialog
#* Created by Robert Heller on Sat Apr 19 10:29:35 2008
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

package require BWLabelComboBox
package require BWFileEntry

catch {Dispatcher::SplashWorkMessage "Loading Print Dialog Code" 16}

namespace eval PrintDialog {
  snit::widgetadaptor PrintDialog {
    delegate option -parent to hull
    delegate option -title  to hull

    component printerRB
    component printerCB
    component fileRB
    component pfileFE
    component userframe
    method getframe {} {return $userframe}
    variable  _FileOrPrinter printer
    typevariable  _PostscriptFiles {
        {{Postscript Files}     {.ps}     }
        {{All Files}            *         }
    }
    constructor {args} {
      installhull using Dialog -bitmap questhead -default 0 \
				-cancel 1 -modal local -transient yes \
				-side bottom -title [from args -title {Print}] \
				-parent [from args -parent]
      $hull add -name print -text Print -command [mymethod _Print]
      $hull add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
      $hull add -name help -text Help -command {BWHelp::HelpTopic PrintDialog}
      set frame [$hull getframe]
      install printerRB using radiobutton $frame.printerRB \
				-command [mymethod _TogglePF] \
				-indicatoron yes \
				-value printer \
				-text "Print to printer" \
				-variable [myvar _FileOrPrinter]
      pack $printerRB -fill x
      install printerCB using LabelComboBox $frame.printerCB -label "Printer:" \
						    -labelwidth 15 \
						    -editable no
      pack $printerCB -fill x
      install fileRB using radiobutton $frame.fileRB \
				-command [mymethod _TogglePF] \
				-indicatoron yes \
				-value file \
				-text "Print to file" \
				-variable [myvar _FileOrPrinter]
      pack $fileRB -fill x
      install pfileFE using FileEntry $frame.pfileFE -label "File:" -state disabled \
					    -labelwidth 15 \
					    -filedialog save \
					    -defaultextension .ps \
					    -filetypes $_PostscriptFiles \
					    -title "File to print to"
      pack $pfileFE -fill x
      install userframe using frame $frame.userframe
      pack $userframe -expand yes -fill both
      $self configurelist $args
    }
    method draw {args} {
      $self configurelist $args
      wm transient [winfo toplevel $win] [$hull  cget -parent]
      set printers {}
      set defprinter {}
      global tcl_platform
      switch "$tcl_platform(platform)" {
	macintosh -
	unix {
	  set lpstat [auto_execok lpstat]
	  if {![catch [list open "|$lpstat -a" r] lpfp]} {
	    while {[gets $lpfp line] >= 0} {
	      if {[regexp {^([^[:space:]]*)[[:space:]]} "$line" -> printer] > 0} {
		lappend printers $printer
	      }
	    }
	    close $lpfp
	  }
	  if {![catch [list open "|$lpstat -d" r] lpfp]} {
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
      if {[string equal "$defprinter" {}]} {
	$printerCB setvalue 0
      } else {
	$printerCB configure -text "$defprinter"
      }
      return [$hull draw]
    }
    method _Print {} {
      switch $_FileOrPrinter {
        set lp [auto_execok lp]
	set lpr [auto_execok lpr]
	printer {
	  if {[string length "$lpr"] > 0} {
	    set _PrinterPath "|$lpr -P[$printerCB cget -text] -"
	  } elseif {[string length "$lp"] > 0
	    set _PrinterPath "|$lp -d [$printerCB cget -text] -"
	  } else {
	    error "Cannot find print command!"
	  }
	}
	file {
	  set _PrinterPath "[$pfileFE cget -text]"
	}
      }
      $hull withdraw
      return [$hull enddialog "$_PrinterPath"]
    }
    method _Cancel {} {
      set _PrinterPath {}
      $hull withdraw
      return [$hull enddialog "$_PrinterPath"]
    }
    method _TogglePF {} {
      switch $_FileOrPrinter {
	printer {
	  $printerCB configure -state normal
	  $pfileFE   configure -state disabled
	}
	file {
	  $pfileFE   configure -state normal
	  $printerCB configure -state disabled
	}
      }
    }
  }
}

package provide PrintDialog 1.0
