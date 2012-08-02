#* 
#* ------------------------------------------------------------------
#* labelcombobox.tcl - Labeled ComboBox
#* Created by Robert Heller on Thu Feb 16 10:03:17 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.2  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2006/02/16 15:20:02  heller
#* Modification History: Added LabelComboBox
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Generic Project
#*     Copyright (C) 2005  Robert Heller D/B/A Deepwoods Software
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

#@Chapter:labelcombobox.tcl -- Labeled ComboBox megawidget.
#$Id$
# This is a specialized form of the LabelFrame widget containing a ComboBox
# Widget.  Most of the resources from the LabelFrame and ComboBox widgets
# are included in this widget.
#
# <option> -labeljustify From LabelFrame (-justify).
# <option> -labelwidth From LabelFrame (-width).
# <option> -labelanchor From LabelFrame (-anchor).
# <option> -labelheight From LabelFrame (-height).
# <option> -labelfont From LabelFrame (-font).
# <option> -labeltextvariable From LabelFrame (-textvariable).
# <option> -label From LabelFrame (-text).
# <option> -comboboxfg From ComboBox (-foreground).
# <option> -comboboxbg From ComboBox (-background).
# <option> -comboboxheight From ComboBox (-height).
# <option> -comboboxlistboxwidth From ComboBox (-listboxwidth).
# <option> -values From ComboBox.
# [index] LabelComboBox!widget

# ------------------------------------------------------------------------------
#  Index of commands:
#     - LabelComboBox::create
#     - LabelComboBox::configure
#     - LabelComboBox::cget
#     - LabelComboBox::bind
#     - LabelComboBox::get
#     - LabelComboBox::getlistbox
#     - LabelComboBox::getvalue
#     - LabelComboBox::icursor
#     - LabelComboBox::post
#     - LabelComboBox::setvalue
#     - LabelComboBox::unpost
# ------------------------------------------------------------------------------

namespace eval LabelComboBox {
# Namespace where this widget's code resides.
# [index] LabelComboBox!namespace

    proc use {} {}

    Widget::define LabelComboBox labelcombobox ComboBox LabelFrame

    Widget::bwinclude LabelComboBox LabelFrame .labf \
        remove {-relief -borderwidth -focus} \
        rename {-text -label} \
        prefix {label -justify -width -anchor -height -font -textvariable}

    Widget::bwinclude LabelComboBox ComboBox .combo \
        remove {-fg -bg} \
        rename {-foreground -comboboxfg -background -comboboxbg 
		-height -comboboxheight -listboxwidth comboboxlistboxwidth}

    Widget::addmap LabelComboBox "" :cmd {-background {}}

    Widget::syncoptions LabelComboBox ComboBox .combo {-autocomplete {} 
						       -bwlistbox {}
						       -expand {} -hottrack {}
						       -images {} -modifycmd {}
						       -postcommand {} 
						       -values {}}
    Widget::syncoptions LabelComboBox LabelFrame .labf {-label -text -underline {}}

    ::bind BwLabelComboBox <FocusIn> [list focus %W.labf]
    ::bind BwLabelComboBox <Destroy> [list LabelComboBox::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command LabelComboBox::create
# ------------------------------------------------------------------------------
proc LabelComboBox::create { path args } {
# Procedure to create a LabelComboBox.
# <in> path -- Path to the new widget.
# <in> args -- Configuration options.
# [index] LabelComboBox::create!procedure

    array set maps [list LabelComboBox {} :cmd {} .labf {} .combo {}]
    array set maps [Widget::parseArgs LabelComboBox $args]

    eval [list frame $path] $maps(:cmd) -class LabelComboBox \
	    -relief flat -bd 0 -highlightthickness 0 -takefocus 0
    Widget::initFromODB LabelComboBox $path $maps(LabelComboBox)
	
    set labf  [eval [list LabelFrame::create $path.labf] $maps(.labf) \
                   [list -relief flat -borderwidth 0 -focus $path.combo]]
    set subf  [LabelFrame::getframe $labf]
    set combo [eval [list ComboBox::create $path.combo] $maps(.combo)]

    pack $combo -in $subf -fill both -expand yes
    pack $labf  -fill both -expand yes

    bindtags $path [list $path BwLabelComboBox [winfo toplevel $path] all]

    return [Widget::create LabelComboBox $path]
}


# ------------------------------------------------------------------------------
#  Command LabelComboBox::configure
# ------------------------------------------------------------------------------
proc LabelComboBox::configure { path args } {
# Procedure to configure a LabelComboBox.
# <in> path -- Path to the new widget.
# <in> args -- Configuration options.
# [index] LabelComboBox::configure!procedure

    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelComboBox::cget
# ------------------------------------------------------------------------------
proc LabelComboBox::cget { path option } {
# Procedure to get a configuation option.
# <in> path -- Path to the new widget.
# <in> option -- Configuration option to get.
# [index] LabelComboBox::cget!procedure

    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command LabelComboBox::bind
# ------------------------------------------------------------------------------
proc LabelComboBox::bind { path args } {
# Procedure to set a binding on the ComboBox entry.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox bind procedure.
# [index] LabelComboBox::bind!procedure

    return [eval [list ComboBox::bind $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::get
# ------------------------------------------------------------------------------
proc LabelComboBox::get { path args } {
# Procedure to get the ComboBox value.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox get procedure
# [index] LabelComboBox::get!procedure

    return [eval [list ComboBox::get $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::getlistbox
# ------------------------------------------------------------------------------
proc LabelComboBox::getlistbox { path args } {
# Procedure to get the listbox of the ComboBox widget.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox getlistbox procedure.
# [index] LabelComboBox::getlistbox!procedure

    return [eval [list ComboBox::getlistbox $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::getvalue
# ------------------------------------------------------------------------------
proc LabelComboBox::getvalue { path args } {
# Procedure to get the value of the ComboBox.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox getvalue procedure.
# [index] LabelComboBox::getvalue!procedure

    return [eval [list ComboBox::getvalue $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::icursor
# ------------------------------------------------------------------------------
proc LabelComboBox::icursor { path args } {
# Pass through procedure for the ComboBox icursor function.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox icursor function.
# [index] LabelComboBox::icursor!procedure

    return [eval [list ComboBox::icursor $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::post
# ------------------------------------------------------------------------------
proc LabelComboBox::post { path args } {
# Pass through procedure for the ComboBox post function.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox post function.
# [index] LabelComboBox::post!procedure

    return [eval [list ComboBox::post $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::setvalue
# ------------------------------------------------------------------------------
proc LabelComboBox::setvalue { path args } {
# Pass through procedure for the ComboBox setvalue function.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox setvalue function.
# [index] LabelComboBox::setvalue!procedure

    return [eval [list ComboBox::setvalue $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::unpost
# ------------------------------------------------------------------------------
proc LabelComboBox::unpost { path args } {
# Pass through procedure for the ComboBox unpost function.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the ComboBox unpost function.
# [index] LabelComboBox::unpost!procedure

    return [eval [list ComboBox::unpost $path.combo] $args]
}


#------------------------------------------------------------------------------
#  Command LabelComboBox::_path_command
#------------------------------------------------------------------------------
proc LabelComboBox::_path_command { path cmd larg } {
# Path command for this megawidget.  Implements all of the megawidget commands.
# <in> path -- The path of the megawidget.
# <in> cmd -- The command name.
# <in> larg -- The command argument.
# [index] LabelComboBox::_path_command!procedure

    if { [string equal $cmd "configure"] ||
         [string equal $cmd "cget"] ||
         [string equal $cmd "bind"] ||
	 [string equal $cmd "get"] ||
	 [string equal $cmd "getlistbox"] ||
	 [string equal $cmd "getvalue"] ||
	 [string equal $cmd "icursor"] ||
	 [string equal $cmd "post"] ||
	 [string equal $cmd "setvalue"] ||
	 [string equal $cmd "unpost"]} {
        return [eval [list LabelComboBox::$cmd $path] $larg]
    } else {
        return [eval [list $path.e:cmd $cmd] $larg]
    }
}


proc LabelComboBox::_destroy { path } {
# Destructor function.
# <in> path -- The path of the megawidget. 
# [index] LabelComboBox::_destroy!procedure

    Widget::destroy $path
}

package provide BWLabelComboBox 1.0.0
