#* 
#* ------------------------------------------------------------------
#* PrintDialog.tcl - Common Print Dialog
#* Created by Robert Heller on Sat Apr 19 10:29:35 2008
#* Completely re-written to use pdf4tcl
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

# $Id: PrintDialog.tcl 624 2008-04-21 23:36:58Z heller $

package require gettext
package require Tk
package require tile
package require snit
package require LabelFrames
package require Dialog
package require pdf4tcl


catch {Dispatcher::SplashWorkMessage "Loading Print Dialog Code" 16}

namespace eval PrintDialog {
  snit::type PrintDialog {
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no

    typecomponent _printdialog
    typecomponent   printfileFE
    typecomponent   papersizeLCB
    typevariable printerIcon
    typevariable printerfiletypes { {{PDF Files} {.pdf}       }
				    {{All Files} *	      } }
    typeconstructor {
      set printerIcon [image create photo \
			-file [file join $::ImageDir largePrinter.gif]]
      set _printdialog {}
    }    
    typemethod createPrintDialog {} {
      if {"$_printdialog" ne "" && [winfo exists $_printdialog]} {return}
      set _printdialog [Dialog .dispatcher_printdialog -image $printerIcon \
				-cancel 1 -default 0 -modal local \
				-parent . -side bottom \
				-title [_ "Print"] -transient yes]
      $_printdialog add print  -text {Print}
      $_printdialog add cancel -text {Cancel}
      set frame [$_printdialog getframe]
      set lwidth [_mx "Label|Output file:" "Label|Paper size:"]
      set printfileFE [FileEntry $frame.printfileFE -label [_m "Label|Output file:"] \
						    -labelwidth $lwidth \
						    -filetypes $printerfiletypes \
						    -filedialog save]
      pack $printfileFE -fill x
      set papersizeLCB [LabelComboBox $frame.papersizeLCB -label [_m "Label|Paper size:"] \
							  -labelwidth $lwidth \
							  -editable no \
					  -values [::pdf4tcl::getPaperSizeList]]
      pack $papersizeLCB -fill x
      $papersizeLCB set [lindex [$frame.papersizeLCB cget -values] 0]
    }
    typemethod draw {args} {
      $type createPrintDialog
      set parent [from args -parent .]
      $_printdialog configure -parent $parent
      wm transient [winfo toplevel $_printdialog] $parent
      set filename [from args -filename printout.pdf]
      $printfileFE configure -text "$filename"
      set ans [$_printdialog draw]
      switch $ans {
	0 {
	  set result [::pdf4tcl::new %AUTO% -paper [$papersizeLCB cget -text] \
					    -file  [$printfileFE  cget -text] \
					    -margin 36]

	}
	1 {
	  set result {}
	}
      }
      return $result
    }
  }
}

package provide PrintDialog 2.0

