#* 
#* ------------------------------------------------------------------
#* mainwindow.tcl - General purpose main window
#* Created by Robert Heller on Mon Feb 27 13:14:39 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
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

package require snit
package require BWidget
package require BWHelp
package require BWStdMenuBar
package require DWpanedw

#@Chapter:mainwindow.tcl -- An extension of the BWidget MainFrame widget
#$Id$


snit::widgetadaptor mainwindow {
# A widget that is heavily extended from the BWidget MainFrame windget.
# This widget starts with a MainFrame, and adds a paned window with a
# scrolled window and a button menu, and zero or more slide out frames.
# also management methods for toolbars and for menus.
#
# <option> -menu The basic MainFrame -menu option.  Defaults to the Motif
#		 standard set of menus (File, Edit, View, Options, and Help).
# <option> -extramenus Like the basic MainFrame -menu option, but can be used
# 	   when the just additional menus need to be added to the standard
#	   set.
# <option> -height Widget height.  Delegated to the hull (MainFrame) widget.
# <option> -width Widget width.  Delegated to the hull (MainFrame) widget.
# <option> -separator Include a separator between windows on the MainFrame
#		widget.
# <option> -dontwithdraw Boolean to suppress withdrawing the toplevel while
#		it is being built.
# [index] mainwindow!widget

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
  # Method to add a button to the button menu.  See the  ButtonBox add method.
  # <in> args -- Arguments passed to the ButtonBox add method.
  # [index] buttons add!method
 
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
  # Method to delete a button from  the button menu.  See the  ButtonBox delete
  # method.
  # <in> index -- Passed to the ButtonBox delete method.
  # [index] buttons delete!method

    set res [eval [list $buttons delete $index]]
    set width 0
    foreach s [pack slaves $right] {
      incr width [winfo reqwidth $s]
    }
    $panewindow paneconfigure right -minsize $width
    return $res
  }

  method {buttons insert} {index args} {
  # Method to insert a button to the button menu.  See the  ButtonBox insert 
  # method.
  # <in> args -- Arguments passed to the ButtonBox insert method.
  # [index] buttons insert!method
 
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
  # Method to configure a button in the button menu.  See the  ButtonBox 
  # itemconfigure method.
  # <in> index -- Argument passed to the ButtonBox itemconfigure method.
  # <in> args -- Arguments passed to the ButtonBox itemconfigure method.
  # [index] buttons itemconfigure!method
 
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
  # Method to add a new slideout frame to the main window.  A slide out frame
  # is a frame that can be packed and unpacked as needed and is  shown in the
  # right pane of the pane window.
  # <in> name -- The name of the slideout frame.
  # [index] slideout add!method

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
  # Method to show (display) a slideout frame.
  # <in> name -- The name of the slideout.
  # [index] slideout show!method

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
  # Method to hide  a slideout frame.
  # <in> name -- The name of the slideout.
  # [index] slideout hide!method

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
  # Method to get the frame of a slideout frame.
  # <in> name -- The name of the slideout.
  # [index] slideout getframe!method

    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } else {
      return $frame
    }
  }
  method {slideout isshownp} {name} {
  # Method to test to see if the named slideout is being shown.
  # <in> name -- The name of the slideout.
  # [index] slideout isshownp!method

    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } elseif {[catch [list pack info $frame]]} {
      return 0
    } else {
      return 1
    }
  }

  method {slideout list} {} {
  # Method to return a list of defined slideout frames.
  # [index] slideout list!method

    return [array names slideouts]
  }

  method {slideout reqwidth} {name} {
  # Method to return the requested width of the named slideout  frame.
  # <in> name -- The name of the slideout.
  # [index] slideout reqwidth!method

    if {[catch [list set slideouts($name)] frame]} {
      error "$name does not exist!"
    } else {
      return [winfo reqwidth $frame]
    }
  }

  method {toolbar add} {name} {
  # Method to add a toolbar to the main frame.
  # <in> name -- The name of the new toolbar.
  # [index] toolbar add!method

    if {![catch [list set toolbars($name,frame)] frame]} {
      error "$name already exists, cannot add again!"
    }
    set toolbars($name,frame) [$hull addtoolbar]
    set toolbars($name,index) $numtoolbars
    incr numtoolbars
  }

  method {toolbar show} {name} {
  # Method to show a toolbar.
  # <in> name -- The name of the toolbar.
  # [index] toolbar show!method

    if {[catch [list set toolbars($name,index)] index]} {
      error "$name does not exist!"
    } else {
      $hull showtoolbar $index 1
    }
  }

  method {toolbar hide} {name} {
  # Method to hide a toolbar.
  # <in> name -- The name of the toolbar.
  # [index] toolbar hide!method

    if {[catch [list set toolbars($name,index)] index]} {
      error "$name does not exist!"
    } else {
      $hull showtoolbar $index 0
    }
  }

  method {toolbar setbuttonstate} {name state} {
  # Method to set the state of the buttons in a toolbar.
  # <in> name -- The name of the toolbar.
  # [index] toolbar setbuttonstate!method

    if {[catch [list set toolbars($name,frame)] frame]} {
      error "$name does not exist!"
    } else {
      foreach b [winfo children $frame] {
        catch [list $b configure -state $state]
      }
    }
  }

  method {toolbar addbutton} {name bname args} {
  # Method to add a button to a toolbar.
  # <in> name -- The name of the toolbar.
  # <in> bname -- The name of the button.
  # <in> args -- Button configuration options (passed to Button).
  # [index] toolbar addbutton!method

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
  # Method to configure a button on a toolbar.
  # <in> name -- The name of the toolbar.
  # <in> bname -- The name of the button.
  # <in> args -- Button configuration options (passed to configure).
  # [index] toolbar buttonconfigure!method

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
  # Method to get a configuration option of a button on a toolbar.
  # <in> name -- The name of the toolbar.
  # <in> bname -- The name of the button.
  # <in> option -- Button configuration option (passed to cget).
  # [index] toolbar buttoncget!method

    if {[catch [list set toolbars($name,frame)] frame]} {
      error "$name does not exist!"
    } else {
      return [$frame.$bname cget $option]
    }
  }

  method {menu activate} {menuid index} {
  # Method to activate a menu on the main frame.
  # <in> menuid Menu id.
  # <index> index Menu item index.
  # [index] menu activate!method

    set menu [$hull getmenu $menuid]
    return [eval [list $menu activate $index]]
  }

  method {menu add} {menuid entrytype args} {
  # Method to add a menu entry to a menu on the main frame.
  # <in> menuid Menu id.
  # <in> entrytype The type of entry.
  # <in> args The arguments to pass to the  entry creation command.
  # [index] menu add!method

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

  method {menu delete} {menuid index args} {
  # Method to delete an entry from a menu.
  # <in> menuid Menu id.
  # <index> index Menu item index.
  # <in> args The arguments to pass to the menu delete command.
  # [index] menu delete!method
  
    set menu [$hull getmenu $menuid]
    return [eval [list $menu delete $index] [list $args]]
  }

  method {menu entrycget} {menuid index option} {
  # Method to get an option value of a menu entry.
  # <in> menuid Menu id.
  # <index> index Menu item index.
  # <in> option The option to fetch.
  # [index] menu entrycget!method

    set menu [$hull getmenu $menuid]
    return [eval [list $menu entrycget $index $option]]
  }

  method {menu entryconfigure} {menuid index args} {
  # Method to configure options of a menu entry.
  # <in> menuid Menu id.
  # <index> index Menu item index.
  # <in> args The arguments to pass on to entryconfigure.
  # [index] menu entryconfigure!method

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
  # Method to set the bind the status line to the help variable of the menu.
  # <in> menuid Menu id.
  # [index] menu sethelpvar!method

    set menu [$hull getmenu $menuid]
    DynamicHelp::add $menu -variable [myvar status]
  }

  method {menu index} {menuid index} {
  # Method to get the index of a menu entry.
  # <in> menuid Menu id.
  # <in> index  The index of the menu entry.
  # [index] menu index!method

    set menu [$hull getmenu $menuid]
    return [eval [list $menu index $index]]
  }

  method {menu insert} {menuid index entrytype args} {
  # Method to insert a menu entry to a menu on the main frame.
  # <in> menuid Menu id.
  # <in> index  The index to insert before.
  # <in> entrytype The type of entry.
  # <in> args The arguments to pass to the  entry creation command.
  # [index] menu add!method

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
  # Method to invoke a menu entry.
  # <in> menuid Menu id.
  # <in> index  The index to invoke.
  # [index] menu invoke!method

    set menu [$hull getmenu $menuid]
    return [eval [list $menu invoke $index]]
  }

  method {menu type} {menuid index} {
  # Method to return the type of a menu entry.
  # <in> menuid Menu id.   
  # <in> index  The index to get the type of.
  # [index] menu type!method

    set menu [$hull getmenu $menuid]
    return [eval [list $menu type $index]]
  }

  method showit {{extraX 0}} {
  # Method to show the main window.
  # <in> extraX Extra width to add when computing the position to map the 
  #		window at.  Defaults to 0.
  # [index] showit!method

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
  # Method to set the status message.
  # <in> statusmessage The status message to display.
  # [index] setstatus!method

    set status "$statusmessage"
  }

  method setprogress {progressvalue} {
  # Method to set the progress bar value.
  # <in> progressvalue The amount of the progress.
  # [index] setprogress!method

    if {![string is integer -strict "$progressvalue"]} {
      error "Expected an integer, got $progressvalue"
    }
    if {$progressvalue < 0 || $progressvalue > 100} {
      error "Expected an integer between 0 and 100, got $progressvalue"
    }
    set progress $progressvalue
  }

  constructor {args} {
  # Constructor --  build a full featured main window.
  # <in> args  Option value list.
  # [index] constructor!method

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
    install panewindow using PanedWindow $frame.panewindow -side top
    pack $panewindow -expand yes -fill both
    set main [$panewindow  add -weight 1]
    install scrollwindow using ScrolledWindow $main.scrollwindow \
						-scrollbar both -auto both
    pack $scrollwindow -fill both -expand yes
    install wipmessage using message $main.wipmessage \
		-aspect 1500 -anchor w -justify left
    pack $wipmessage -fill x -anchor w
    set right [$panewindow  add -weight 0 -name right]
    install buttons using ButtonBox $right.buttons \
		-orient vertical -pady 0 -padx 0 -spacing 0
    pack $buttons -fill y -side left
    $panewindow paneconfigure right -minsize [winfo reqwidth $buttons]
    $self configurelist $args
#    update
  }

}




package provide MainWindow 1.0
