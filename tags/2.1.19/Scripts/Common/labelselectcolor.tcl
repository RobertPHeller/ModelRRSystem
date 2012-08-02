#* 
#* ------------------------------------------------------------------
#* labelselectcolor.tcl - Labeled SelectColor Widget
#* Created by Robert Heller on Fri Apr  7 14:02:53 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.1  2007/01/22 23:44:25  heller
#* Modification History: added files
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


#@Chapter:labelselectcolor.tcl -- LabelSelectColor, a labeled color selector
#$Id$
#This package provides a BWidget style megawidget for selecting colors, in
#the same style as a LabelEntry widget.
#
# This megawidget includes resources from the LabelFrame, Entry, and Button 
# widgets.
#
# <option> -labeljustify From LabelFrame (-justify).
# <option> -labelwidth From LabelFrame (-width).
# <option> -labelanchor From LabelFrame (-anchor).
# <option> -labelheight From LabelFrame (-height).
# <option> -labelfont From LabelFrame (-font).
# <option> -labeltextvariable From LabelFrame (-textvariable).
# <option> -label From LabelFrame (-text).
# <option> -selectcolorfg From Entry (-foreground).
# <option> -selectcolorbg From Entry (-background).
# <option> -text From Entry.
# <option> -buttonfg From Button (-foreground).
# <option> -buttonbg From Button (-background).
# <option> -buttonactivebg From Button (-activebackground).
# <option> -buttonactivefg From Button (-activeforeground).
# <option> -buttondisabledfg From Button (-disabledforeground).
# <option> -buttonhighlightbg From Button (-highlightbackground).
# <option> -buttonhighlightcolor From Button (-highlightcolor).
# [index] LabelSelectColor!widget


#  Index of commands:
#     - LabelSelectColor::create
#     - LabelSelectColor::ColorPopup
#     - LabelSelectColor::configure
#     - LabelSelectColor::cget
#     - LabelSelectColor::bind
#     - LabelSelectColor::setvalue
#     - LabelSelectColor::getvalue
# ------------------------------------------------------------------------------

namespace eval LabelSelectColor {
# The namespace where this widget lives.
# [index] LabelSelectColor!namespace

    proc use {} {}

    Widget::define LabelSelectColor labelselectcolor Entry Button LabelFrame

    Widget::bwinclude LabelSelectColor LabelFrame .labf \
        remove {-relief -borderwidth -focus} \
        rename {-text -label} \
        prefix {label -justify -width -anchor -height -font -textvariable}

    Widget::bwinclude LabelSelectColor Entry .selcolor \
        remove {-fg -bg} \
        rename {-foreground -selectcolorfg -background -selectcolorbg}

    Widget::bwinclude LabelSelectColor Button .b \
        remove {-anchor -bg -bitmap -borderwidth -bd -cursor -font
		-fg -highlightthickness -image -justify -padx -pady 
		-repeatdelay -repeatinterval -takefocus -text -textvariable 
		-wraplength -armcommand -command -default -disarmcommand 
		-height -helptext -helptype -helpvar -name -relief -state 
		-underline -width} \
	rename {-foreground -buttonfg -background -buttonbg
		-activebackground -buttonactivebg 
		-activeforeground -buttonactivefg
		-disabledforeground -buttondisabledfg
		-highlightbackground -buttonhighlightbg
		-highlightcolor -buttonhighlightcolor}
	

    Widget::addmap LabelSelectColor "" :cmd {-background {}}

    Widget::syncoptions LabelSelectColor Entry .selcolor {-text {}}
    Widget::syncoptions LabelSelectColor LabelFrame .labf {-label -text -underline {}}

    ::bind BwLabelSelectColor <FocusIn> [list focus %W.labf]
    ::bind BwLabelSelectColor <Destroy> [list LabelSelectColor::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command LabelSelectColor::create
# ------------------------------------------------------------------------------
proc LabelSelectColor::create { path args } {
# Creation procedure
# <in> path -- The megawidget's path.
# <in> args -- Options for this widget.
# [index] LabelSelectColor::create!procedure

    array set maps [list LabelSelectColor {} :cmd {} .labf {} .selcolor {} .b {}]
    array set maps [Widget::parseArgs LabelSelectColor $args]

    eval [list frame $path] $maps(:cmd) -class LabelSelectColor \
	    -relief flat -bd 0 -highlightthickness 0 -takefocus 0
    Widget::initFromODB LabelSelectColor $path $maps(LabelSelectColor)
	
    set labf  [eval [list LabelFrame::create $path.labf] $maps(.labf) \
                   [list -relief flat -borderwidth 0 -focus $path.selcolor]]
    set subf  [LabelFrame::getframe $labf]
    set entry [eval [list Entry::create $path.selcolor] $maps(.selcolor)]
    set initcolor "[$entry cget -text]"
    if {[string equal "$initcolor" {}]} {$entry configure -text "white"}
    set button [eval [list Button::create $path.b] $maps(.b)]
    set paletteimage [image create photo -file [file join $::BWIDGET::LIBRARY images palette.gif]]
    $button configure -image $paletteimage
    $button configure -command [list LabelSelectColor::ColorPopup $path]
    pack $entry -in $subf -side left -fill both -expand yes
    pack $button -in $subf -side right
    pack $labf  -fill both -expand yes

    bindtags $path [list $path BwLabelSelectColor [winfo toplevel $path] all]

    return [Widget::create LabelSelectColor $path]
}


# ------------------------------------------------------------------------------
#  Procedure bound to palette button
# ------------------------------------------------------------------------------
proc LabelSelectColor::ColorPopup  {path} {
# Procedure bound to the palette button to select a color.
# <in> path -- The path of the megawidget.
# [index] LabelSelectColor::ColorPopup!procedure

  set newcolor [SelectColor $path.colormenu \
				-color "[$path.selcolor cget -text]" \
				-type popup]
  if {[string length "$newcolor"] > 0} {
     $path.selcolor configure -text "$newcolor"
  }
}

# ------------------------------------------------------------------------------
#  Command LabelSelectColor::configure
# ------------------------------------------------------------------------------
proc LabelSelectColor::configure { path args } {
# Configuration procedure: configure one or more options for this widget.
# <in> path -- The path of the megawidget.
# <in> args -- Option value pairs.
# [index] LabelSelectColor::configure!procedure

    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelSelectColor::cget
# ------------------------------------------------------------------------------
proc LabelSelectColor::cget { path option } {
# Configuration option accessor procedure: access one option directly.
# <in> path -- The path of the megawidget.
# <in> option -- The option to access
# [index] LabelSelectColor::cget!procedure

    return [Widget::cget $path $option]
}



#------------------------------------------------------------------------------
#  Command LabelSelectColor::_path_command
#------------------------------------------------------------------------------
proc LabelSelectColor::_path_command { path cmd larg } {
# Path command for this megawidget.  Implements all of the megawidget commands.
# <in> path -- The path of the megawidget.
# <in> cmd -- The command name.
# <in> larg -- The command argument.
# [index] LabelSelectColor::_path_command!procedure

    if { [string equal $cmd "configure"] ||
         [string equal $cmd "cget"] ||
         [string equal $cmd ""] ||
	 [string equal $cmd "setvalue"] ||
	 [string equal $cmd "getvalue"]} {
        return [eval [list LabelSelectColor::$cmd $path] $larg]
    } else {
        return [eval [list $path.e:cmd $cmd] $larg]
    }
}


proc LabelSelectColor::_destroy { path } {
# Destructor function.
# <in> path -- The path of the megawidget. 
# [index] LabelSelectColor::_destroy!procedure

    Widget::destroy $path
}

package provide LabelSelectColor 1.0
