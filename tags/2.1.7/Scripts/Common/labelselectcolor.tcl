#* 
#* ------------------------------------------------------------------
#* labelselectcolor.tcl - Labeled SelectColor Widget
#* Created by Robert Heller on Fri Apr  7 14:02:53 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
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


# ------------------------------------------------------------------------------
#  $Id$
# ------------------------------------------------------------------------------
#  Index of commands:
#     - LabelSelectColor::create
#     - LabelSelectColor::configure
#     - LabelSelectColor::cget
#     - LabelSelectColor::bind
#     - LabelSelectColor::setvalue
#     - LabelSelectColor::getvalue
# ------------------------------------------------------------------------------

namespace eval LabelSelectColor {
    Widget::define LabelSelectColor labelselectcolor SelectColor LabelFrame

    Widget::bwinclude LabelSelectColor LabelFrame .labf \
        remove {-relief -borderwidth -focus} \
        rename {-text -label} \
        prefix {label -justify -width -anchor -height -font -textvariable}

    Widget::bwinclude LabelSelectColor SelectColor .selcolor \
        remove {-fg -bg} \
        rename {-foreground -selectcolorfg -background -selectcolorbg}

    Widget::addmap LabelSelectColor "" :cmd {-background {}}

    Widget::syncoptions LabelSelectColor SelectColor .selcolor {-range -values {}}
    Widget::syncoptions LabelSelectColor LabelFrame .labf {-label -text -underline {}}

    ::bind BwLabelSelectColor <FocusIn> [list focus %W.labf]
    ::bind BwLabelSelectColor <Destroy> [list LabelSelectColor::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command LabelSelectColor::create
# ------------------------------------------------------------------------------
proc LabelSelectColor::create { path args } {
    array set maps [list LabelSelectColor {} :cmd {} .labf {} .selcolor {}]
    array set maps [Widget::parseArgs LabelSelectColor $args]

    eval [list frame $path] $maps(:cmd) -class LabelSelectColor \
	    -relief flat -bd 0 -highlightthickness 0 -takefocus 0
    Widget::initFromODB LabelSelectColor $path $maps(LabelSelectColor)
	
    set labf  [eval [list LabelFrame::create $path.labf] $maps(.labf) \
                   [list -relief flat -borderwidth 0 -focus $path.selcolor]]
    set subf  [LabelFrame::getframe $labf]
    set spin [eval [list SelectColor::create $path.selcolor] $maps(.selcolor)]

    pack $spin -in $subf -fill both -expand yes
    pack $labf  -fill both -expand yes

    bindtags $path [list $path BwLabelSelectColor [winfo toplevel $path] all]

    return [Widget::create LabelSelectColor $path]
}


# ------------------------------------------------------------------------------
#  Command LabelSelectColor::configure
# ------------------------------------------------------------------------------
proc LabelSelectColor::configure { path args } {
    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelSelectColor::cget
# ------------------------------------------------------------------------------
proc LabelSelectColor::cget { path option } {
    return [Widget::cget $path $option]
}



#------------------------------------------------------------------------------
#  Command LabelSelectColor::_path_command
#------------------------------------------------------------------------------
proc LabelSelectColor::_path_command { path cmd larg } {
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
    Widget::destroy $path
}

package provide LabelSelectColor 1.0
