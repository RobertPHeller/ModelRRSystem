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

## @addtogroup TclCommon
#  @{


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
## This is a specialized form of the LabelFrame widget containing a ComboBox
# Widget.  Most of the resources from the LabelFrame and ComboBox widgets
# are included in this widget.
#
# @param path The widget path.
# @param ... Options:
# @arg -labeljustify From LabelFrame (-justify).
# @arg -labelwidth From LabelFrame (-width).
# @arg -labelanchor From LabelFrame (-anchor).
# @arg -labelheight From LabelFrame (-height).
# @arg -labelfont From LabelFrame (-font).
# @arg -labeltextvariable From LabelFrame (-textvariable).
# @arg -label From LabelFrame (-text).
# @arg -comboboxfg From ComboBox (-foreground).
# @arg -comboboxbg From ComboBox (-background).
# @arg -comboboxheight From ComboBox (-height).
# @arg -comboboxlistboxwidth From ComboBox (-listboxwidth).
# @arg -values From ComboBox.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @section labelcombobox_package Package provided
#
# BWLabelComboBox 1.0
#


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



# ------------------------------------------------------------------------------
#  Command LabelComboBox::create
# ------------------------------------------------------------------------------
proc create { path args } {
## Procedure to create a LabelComboBox.
# @param path Path to the new widget.
# @param ... Configuration options.

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
proc configure { path args } {
## Procedure to configure a LabelComboBox.
# @param path Path to the new widget.
# @param ... Configuration options.

    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelComboBox::cget
# ------------------------------------------------------------------------------
proc cget { path option } {
## Procedure to get a configuation option.
# @param path Path to the new widget.
# @param option Configuration option to get.

    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command LabelComboBox::bind
# ------------------------------------------------------------------------------
proc bind { path args } {
## Procedure to set a binding on the ComboBox entry.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox bind procedure.

    return [eval [list ComboBox::bind $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::get
# ------------------------------------------------------------------------------
proc get { path args } {
## Procedure to get the ComboBox value.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox get procedure

    return [eval [list ComboBox::get $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::getlistbox
# ------------------------------------------------------------------------------
proc getlistbox { path args } {
## Procedure to get the listbox of the ComboBox widget.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox getlistbox procedure.

    return [eval [list ComboBox::getlistbox $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::getvalue
# ------------------------------------------------------------------------------
proc getvalue { path args } {
## Procedure to get the value of the ComboBox.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox getvalue procedure.

    return [eval [list ComboBox::getvalue $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::icursor
# ------------------------------------------------------------------------------
proc icursor { path args } {
## Pass through procedure for the ComboBox icursor function.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox icursor function.

    return [eval [list ComboBox::icursor $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::post
# ------------------------------------------------------------------------------
proc post { path args } {
## Pass through procedure for the ComboBox post function.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox post function.

    return [eval [list ComboBox::post $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::setvalue
# ------------------------------------------------------------------------------
proc setvalue { path args } {
## Pass through procedure for the ComboBox setvalue function.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox setvalue function.

    return [eval [list ComboBox::setvalue $path.combo] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelComboBox::unpost
# ------------------------------------------------------------------------------
proc unpost { path args } {
## Pass through procedure for the ComboBox unpost function.
# @param path Path to the new widget.
# @param ... Arguments to pass to the ComboBox unpost function.

    return [eval [list ComboBox::unpost $path.combo] $args]
}


#------------------------------------------------------------------------------
#  Command LabelComboBox::_path_command
#------------------------------------------------------------------------------
proc _path_command { path cmd larg } {
## @private Path command for this megawidget.  Implements all of the megawidget commands.
# @param path The path of the megawidget.
# @param cmd The command name.
# @param larg The command argument.

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


proc _destroy { path } {
## @private Destructor function.
# @param path The path of the megawidget. 

    Widget::destroy $path
}
}

## @}
package provide BWLabelComboBox 1.0.0
