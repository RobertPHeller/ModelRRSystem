#* 
#* ------------------------------------------------------------------
#* mainwindow.tcl - General purpose main window
#* Created by Robert Heller on Mon Feb 27 13:14:39 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
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

# $Id$

package require snit
package require BWidget
package require BWHelp
package require BWStdMenuBar
package require DWpanedw

snit::widgetadaptor mainwindow {
  option -menu \
	-readonly yes \
	-default {
	   "&File" {file:menu} {file} 0 {
	        {command "&New"     {file:new} ""     {Ctrl n}}
	        {command "&Open..." {file:open} "" {Ctrl o}}
	        {command "&Save"    {file:save} "" {Ctrl s}}
		{command "Save &As..." {file:saveas} "" {Ctrl a}}
		{command "&Print..." {file:print} "" {Ctrl p}}
	        {command "&Close" {file:close} "Close the application" {Ctrl c}}
	        {command "E&xit" {file:exit} "Exit the application" {Ctrl q}}
	    }
	    "&Edit" {edit:menu} {edit} 0 {
		{command "&Undo" {edit:undo} "Undo last change" {Ctrl z}}
		{command "Cu&t" {edit:cut edit:havesel} "Cut selection to the paste buffer" {Ctrl x} -command StdMenuBar::EditCut}
		{command "&Copy" {edit:copy edit:havesel} "Copy selection to the paste buffer" {Ctrl c} -command StdMenuBar::EditCopy}
		{command "&Paste" {edit:paste edit:havesel} "Paste in the paste buffer" {Ctrl v} -command StdMenuBar::EditPaste}
		{command "C&lear" {edit:clear edit:havesel} "Clear selection" {} -command StdMenuBar::EditClear}
		{command "&Delete" {edit:delete edit:havesel} "Delete selection" {Ctrl d}}
		{separator}
		{command "Select All" {edit:selectall} "Select everything" {}}
		{command "De-select All" {edit:deselectall edit:havesel} "Select nothing" {}}
	    }
	    "&View" {view:menu} {view} 0 {
	    }
	    "&Options" {options:menu} {options} 0 {
	    }
	    "&Help" {help:menu} {help} 0 {
		{command "On &Context..." {help:context} "Help on context" {} -command BWHelp::HelpContext}
		{command "On &Help..." {help:help} "Help on help" {} -command "BWHelp::HelpTopic Help"}
		{command "On &Window..." {help:window} "Help on the current window" {} -command "BWHelp::HelpWindow"}
		{command "On &Keys..." {help:keys} "Help on keyboard accelerators" {} -command "BWHelp::HelpTopic Keys"}
		{command "&Index..." {help:index} "Help index" {} -command "BWHelp::HelpTopic Index"}
		{command "&Tutorial..." {help:tutorial} "Tutorial" {}  -command "BWHelp::HelpTopic Tutorial"}
		{command "On &Version" {help:version} "Version" {} -command "BWHelp::HelpTopic Version"}
		{command "Warranty" {help:warranty} "Warranty" {} -command "BWHelp::HelpTopic Warranty"}
		{command "Copying" {help:copying} "Copying" {} -command "BWHelp::HelpTopic Copying"}
	    }
	}
  option {-extramenus extraMenus ExtraMenus} \
	-readonly yes \
	-default {}
  delegate option -height to hull
  delegate option -width  to hull
  option -separator -default both
  option {-dontwithdraw dontWithdraw DontWithdraw} -readonly yes -default 0
  delegate method {mainframe *} to hull except {getframe addtoobar gettoolbar 
						showtoolbar}
  component scrollwindow
  delegate method {scrollwindow *} to scrollwindow
  component wipmessage
  delegate method {wipmessage *} to wipmessage
  component right
  component buttons
  delegate method {buttons *} to buttons except {add insert delete itemconfigure}
  component panewindow
  variable slideouts -array {}
  variable toolbars  -array {}
  variable numtoolbars 0
  variable progress
  variable status

  method {buttons add} {args} {
    set helptext [from args -helptext]
    set helptype [from args -helptype]
    set helpvar  [from args -helpvar]
    if {[string length "$helptext"]} {
      lappend args -helptext "$helptext" -helptype variable \
		   -helpvar [myvar status]
    }
    set res [eval [list $buttons add] $args]
    set width 0
    foreach s [pack slaves $right] {
      incr width [winfo reqwidth $s]
    }
    $panewindow paneconfigure right -minsize $width
    return $res
  }

  method {buttons delete} {index} {
    set res [eval [list $buttons delete $index]]
    set width 0
    foreach s [pack slaves $right] {
      incr width [winfo reqwidth $s]
    }
    $panewindow paneconfigure right -minsize $width
    return $res
  }

  method {buttons insert} {index args} {
    set helptext [from args -helptext]
    set helptype [from args -helptype]
    set helpvar  [from args -helpvar]
    if {[string length "$helptext"]} {
      lappend args -helptext "$helptext" -helptype variable \
		   -helpvar [myvar status]
    }
    set res [eval [list $buttons insert $index] $args]
    set width 0
    foreach s [pack slaves $right] {
      incr width [winfo reqwidth $s]
    }
    $panewindow paneconfigure right -minsize $width
    return $res
  }

  method {buttons itemconfigure} {index args} {
    set helptext [from args -helptext]
    set helptype [from args -helptype]
    set helpvar  [from args -helpvar]
    if {[string length "$helptext"]} {
      lappend args -helptext "$helptext" -helptype variable \
		   -helpvar [myvar status]
    }
    set res [eval [list $buttons itemconfigure $index] $args]
    set width 0
    foreach s [pack slaves $right] {
      incr width [winfo reqwidth $s]
    }
    $panewindow paneconfigure right -minsize $width
    return $res
  }

  method {slideout add} {name} {
    if {![catch [list set slideouts($name)] frame]} {
      error "$name already exists, cannot add again!"
    }
    set frame $right.[string tolower $name]
    if {[winfo exists $frame]} {
      error "$name already exists, cannot add again!"
    }
    frame $frame -borderwidth 0 -relief flat
    set slideouts($name) $frame
    return $frame
  }
  method {slideout show} {name} {
    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } else {
      pack $frame -side right -expand yes -fill both
      set width 0
      foreach s [pack slaves $right] {
	incr width [winfo reqwidth $s]
      }
      $panewindow paneconfigure right -minsize $width
      return $frame
    }
  }
  method {slideout hide} {name} {
    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } else {
      pack forget $frame
      set width 0
      foreach s [pack slaves $right] {
	incr width [winfo reqwidth $s]
      }
      $panewindow paneconfigure right -minsize $width
      return $frame
    }
  }
  method {slideout getframe} {name} {
    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } else {
      return $frame
    }
  }
  method {slideout isshownp} {name} {
    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } elseif {[catch [list pack info $frame]]} {
      return 0
    } else {
      return 1
    }
  }

  method {slideout list} {} {
    return [array names slideouts]
  }

  method {slideout reqwidth} {name} {
    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } else {
      return [winfo reqwidth $frame]
    }
  }

  method {toolbar add} {name} {
    if {![catch [list set toolbars($name,frame)] frame]} {
      error "$name already exists, cannot add again!"
    }
    set toolbars($name,frame) [$hull addtoolbar]
    set toolbars($name,index) $numtoolbars
    incr numtoolbars
  }

  method {toolbar show} {name} {
    if {[catch [list set toolbars($name,index)] index]} {
      error "$name does not exist!"
    } else {
      $hull showtoolbar $index 1
    }
  }

  method {toolbar hide} {name} {
    if {[catch [list set toolbars($name,index)] index]} {
      error "$name does not exist!"
    } else {
      $hull showtoolbar $index 0
    }
  }

  method {toolbar setbuttonstate} {name state} {
    if {[catch [list set toolbars($name,frame)] frame]} {
      error "$name does not exist!"
    } else {
      foreach b [winfo children $frame] {
        catch [list $b configure -state $state]
      }
    }
  }

  method {toolbar addbutton} {name bname args} {
    if {[catch [list set toolbars($name,frame)] frame]} {
      error "$name does not exist!"
    } else {
      set helptext [from args -helptext]
      set helptype [from args -helptype]
      set helpvar  [from args -helpvar]
      if {[string length "$helptext"]} {
        lappend args -helptext "$helptext" -helptype variable \
			-helpvar [myvar status]
      }
      pack [eval [list Button $frame.$bname] $args] -side left
    }
  }

  method {toolbar buttonconfigure} {name bname args} {
    if {[catch [list set toolbars($name,frame)] frame]} {
      error "$name does not exist!"
    } else {
      set helptext [from args -helptext]
      set helptype [from args -helptype]
      set helpvar  [from args -helpvar]
      if {[string length "$helptext"]} {
        lappend args -helptext "$helptext" -helptype variable \
			-helpvar [myvar status]
      }
      return [eval [list $frame.$bname configure] $args]
    }
  }

  method {toolbar buttoncget} {name bname option} {
    if {[catch [list set toolbars($name,frame)] frame]} {
      error "$name does not exist!"
    } else {
      return [$frame.$bname cget $option]
    }
  }

  method {menu activate} {menuid index} {
    set menu [$hull getmenu $menuid]
    return [eval [list $menu activate $index]]
  }

  method {menu add} {menuid entrytype args} {
    set menu [$hull getmenu $menuid]
#    puts stderr "*** ${type}::menu add (before from): args = $args"
    set dynhelp [from args -dynamichelp]
#    puts stderr "*** ${type}::menu add (after from): args = $args, dynhelp = $dynhelp"
    set res [eval [list $menu add $entrytype] $args]
    if {[string length "$dynhelp"]} {
      DynamicHelp::add $menu -index [$menu index end] \
			     -variable [myvar status] \
			     -text "$dynhelp"
    }
    return $res
  }

  method {menu delete} {menuid index1 args} {
    set menu [$hull getmenu $menuid]
    return [eval [list $menu delete $index1] [list $args]]
  }

  method {menu entrycget} {menuid index option} {
    set menu [$hull getmenu $menuid]
    return [eval [list $menu entrycget $index $option]]
  }

  method {menu entryconfigure} {menuid index args} {
    set menu [$hull getmenu $menuid]
    set dynhelp [from args -dynamichelp]
    if {[string length "$dynhelp"]} {
      DynamicHelp::add $menu -index [$menu index $index] \
			     -variable [myvar status] \
			     -text "$dynhelp"
    }
    return [eval [list $menu entryconfigure $index] $args]
  }

  method {menu sethelpvar} {menuid} {
    set menu [$hull getmenu $menuid]
    DynamicHelp::add $menu -variable [myvar status]
  }

  method {menu index} {menuid index} {
    set menu [$hull getmenu $menuid]
    return [eval [list $menu index $index]]
  }

  method {menu insert} {menuid index entrytype args} {
    set menu [$hull getmenu $menuid]
    set dynhelp [from args -dynamichelp]
    set index [$menu index $index]
    set res [eval [list $menu insert $index $entrytype] $args]
    if {[string length "$dynhelp"]} {
      DynamicHelp::add $menu -index $index \
			     -variable [myvar status] \
			     -text "$dynhelp"
    }
    return $res
  }

  method {menu invoke} {menuid index} {
    set menu [$hull getmenu $menuid]
    return [eval [list $menu invoke $index]]
  }

  method {menu type} {menuid index} {
    set menu [$hull getmenu $menuid]
    return [eval [list $menu type $index]]
  }

  method showit {{extraX 0}} {
    set toplevel [winfo toplevel $win]
    if {![string equal [wm state $toplevel] {withdrawn}]} {return}
    update idle
    set x [expr {[winfo screenwidth $toplevel]/2 - ([winfo reqwidth $toplevel]+$extraX)/2 \
	    - [winfo vrootx $toplevel]}]
    set y [expr {[winfo screenheight $toplevel]/2 - [winfo reqheight $toplevel]/2 \
	    - [winfo vrooty $toplevel]}]
    if {$x < 0} {set x 0}
    if {$y < 0} {set y 0}
    wm geom $toplevel +$x+$y
    wm deiconify $toplevel
  }

  method setstatus {statusmessage} {
    set status "$statusmessage"
  }

  method setprogress {progressvalue} {
    if {![string is integer -strict "$progressvalue"]} {
      error "Expected an integer, got $progressvalue"
    }
    if {$progressvalue < 0 || $progressvalue > 100} {
      error "Expected an integer between 0 and 100, got $progressvalue"
    }
    set progress $progressvalue
  }

  constructor {args} {
#    puts stderr "*** ${type}::constructor $args"
    set options(-dontwithdraw) [from args -dontwithdraw]
#    puts stderr "*** ${type}::constructor: options(-dontwithdraw) = $options(-dontwithdraw)"
    set options(-menu) [from args -menu]
    set options(-extramenus) [from args -extramenus]
    if {[llength $options(-extramenus)] > 0} {
      set helpIndex [lsearch -exact $options(-menu) "&Help"]
      set menudesc  [eval [list linsert $options(-menu) $helpIndex] \
			  $options(-extramenus)]
    } else {
      set menudesc $options(-menu)
    }
    set options(-separator) [from args -separator]
    set status {}
    set progress 0
    installhull using MainFrame -menu $menudesc \
			-separator $options(-separator) \
			-textvariable [myvar status] \
			-progressvar [myvar progress] \
			-progressmax 100 \
			-progresstype normal
    $hull showstatusbar progression
    set toplevel [winfo toplevel $win]
#    puts stderr "*** ${type}::constructor: wm state $toplevel = [wm state $toplevel]"
    if {!$options(-dontwithdraw)} {wm withdraw $toplevel}
    set frame [$hull getframe]
    set panewindow $frame.panewindow
    pack [PanedWindow $panewindow -side top] -expand yes -fill both
    set main [$panewindow  add -weight 1]
    set scrollwindow $main.scrollwindow
    pack [ScrolledWindow $scrollwindow -scrollbar both -auto both] \
		-fill both -expand yes
    set wipmessage $main.wipmessage
    pack [message $wipmessage -aspect 1500 -anchor w -justify left] \
	-fill x -anchor w
    set right [$panewindow  add -weight 0 -name right]
    set buttons $right.buttons
    pack [ButtonBox $buttons -orient vertical -pady 0 -padx 0 -spacing 0] \
		-fill y -side left
    $panewindow paneconfigure right -minsize [winfo reqwidth $buttons]
    $self configurelist $args
#    update
  }

}




package provide MainWindow 1.0
