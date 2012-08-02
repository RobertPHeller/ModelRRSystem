#* 
#* ------------------------------------------------------------------
#* BWExtras.tcl -- Assorted extra composite widgets
#* ------------------------------------------------------------------
#* labelspinbox.tcl - Labeled SpinBox
#* Created by Robert Heller on Wed Feb 15 21:21:45 2006
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
#* Modification History: Revision 1.1.1.1  2006/02/16 14:58:07  heller
#* Modification History: Imported sources
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#* Copyright (c) 2006, Robert Heller
#* All rights reserved.
#* 
#* Redistribution and use in source and binary forms, with or without
#* modification, are permitted provided that the following conditions are
#* met:
#* 
#*     * Redistributions of source code must retain the above copyright
#*       notice, this list of conditions and the following disclaimer.
#*     * Redistributions in binary form must reproduce the above copyright
#*       notice, this list of conditions and the following disclaimer in the
#*       documentation and/or other materials provided with the distribution.
#*     * Neither the name of the Deepwoods Software nor the names of its
#*       contributors may be used to endorse or promote products derived from
#*       this software without specific prior written permission.
#* 
#* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
#* IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
#* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
#* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#* 
#* 


#@Chapter:labelspinbox.tcl -- Labeled SpinBox megawidget
#$Id$
# This is a specialized form of the LabelFrame widget containing a SpinBox
# Widget.  Most of the resources from the LabelFrame and SpinBox widgets
# are included in this widget.
#
# <option> -labeljustify From LabelFrame (-justify).
# <option> -labelwidth From LabelFrame (-width).
# <option> -labelanchor From LabelFrame (-anchor).
# <option> -labelheight From LabelFrame (-height).
# <option> -labelfont From LabelFrame (-font).
# <option> -labeltextvariable From LabelFrame (-textvariable).
# <option> -label From LabelFrame (-text).
# <option> -spinboxfg From SpinBox (-foreground).
# <option> -spinboxbg From SpinBox (-background).
# <option> -range From SpinBox.
# <option> -values From SpinBox.
# [index] LabelSpinBox!widget

# ------------------------------------------------------------------------------
#  Index of commands:
#     - LabelSpinBox::create
#     - LabelSpinBox::configure
#     - LabelSpinBox::cget
#     - LabelSpinBox::bind
#     - LabelSpinBox::setvalue
#     - LabelSpinBox::getvalue
# ------------------------------------------------------------------------------

namespace eval LabelSpinBox {
# Namespace where this widget's code resides.
# [index] LabelSpinBox!namespace

    proc use {} {}

    Widget::define LabelSpinBox labelspinbox SpinBox LabelFrame

    Widget::bwinclude LabelSpinBox LabelFrame .labf \
        remove {-relief -borderwidth -focus} \
        rename {-text -label} \
        prefix {label -justify -width -anchor -height -font -textvariable}

    Widget::bwinclude LabelSpinBox SpinBox .spin \
        remove {-fg -bg} \
        rename {-foreground -spinboxfg -background -spinboxbg}

    Widget::addmap LabelSpinBox "" :cmd {-background {}}

    Widget::syncoptions LabelSpinBox SpinBox .spin {-range {} -values {}}
    Widget::syncoptions LabelSpinBox LabelFrame .labf {-label -text 
						       -underline {}}

    ::bind BwLabelSpinBox <FocusIn> [list focus %W.labf]
    ::bind BwLabelSpinBox <Destroy> [list LabelSpinBox::_destroy %W]
}


# ------------------------------------------------------------------------------
#  Command LabelSpinBox::create
# ------------------------------------------------------------------------------
proc LabelSpinBox::create { path args } {
# Procedure to create a LabelSpinBox.
# <in> path -- Path to the new widget.
# <in> args -- Configuration options.
# [index] LabelSpinBox::create!procedure

    array set maps [list LabelSpinBox {} :cmd {} .labf {} .spin {}]
    array set maps [Widget::parseArgs LabelSpinBox $args]

    eval [list frame $path] $maps(:cmd) -class LabelSpinBox \
	    -relief flat -bd 0 -highlightthickness 0 -takefocus 0
    Widget::initFromODB LabelSpinBox $path $maps(LabelSpinBox)
	
    set labf  [eval [list LabelFrame::create $path.labf] $maps(.labf) \
                   [list -relief flat -borderwidth 0 -focus $path.spin]]
    set subf  [LabelFrame::getframe $labf]
    set spin [eval [list SpinBox::create $path.spin] $maps(.spin)]

    pack $spin -in $subf -fill both -expand yes
    pack $labf  -fill both -expand yes

    bindtags $path [list $path BwLabelSpinBox [winfo toplevel $path] all]

    return [Widget::create LabelSpinBox $path]
}


# ------------------------------------------------------------------------------
#  Command LabelSpinBox::configure
# ------------------------------------------------------------------------------
proc LabelSpinBox::configure { path args } {
# Procedure to configure a LabelSpinBox.
# <in> path -- Path to the new widget.
# <in> args -- Configuration options.
# [index] LabelSpinBox::configure!procedure

    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelSpinBox::cget
# ------------------------------------------------------------------------------
proc LabelSpinBox::cget { path option } {
# Procedure to get a configuation option.
# <in> path -- Path to the new widget.
# <in> option -- Configuration option to get.
# [index] LabelSpinBox::cget!procedure

    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command LabelSpinBox::setvalue
# ------------------------------------------------------------------------------
proc LabelSpinBox::setvalue { path args } {
# Procedure to set the value of the SpinBox.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the SpinBox setvalue procedure.
# [index] LabelSpinBox::getvalue!procedure

    return [eval [list ::setvalue $path.spin] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelSpinBox::getvalue
# ------------------------------------------------------------------------------
proc LabelSpinBox::getvalue { path args } {
# Procedure to get the value of the SpinBox.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the SpinBox getvalue procedure.
# [index] LabelSpinBox::getvalue!procedure

    return [eval [list ::getvalue $path.spin] $args]
}

# ------------------------------------------------------------------------------
#  Command LabelSpinBox::bind
# ------------------------------------------------------------------------------
proc LabelSpinBox::bind { path args } {
# Procedure to set a binding on the SpinBox entry.
# <in> path -- Path to the new widget.
# <in> args -- Arguments to pass to the SpinBox bind procedure.
# [index] LabelSpinBox::bind!procedure

    return [eval [list ::bind $path.spin] $args]
}


#------------------------------------------------------------------------------
#  Command LabelSpinBox::_path_command
#------------------------------------------------------------------------------
proc LabelSpinBox::_path_command { path cmd larg } {
# Path command for this megawidget.  Implements all of the megawidget commands.
# <in> path -- The path of the megawidget.
# <in> cmd -- The command name.
# <in> larg -- The command argument.
# [index] LabelSpinBox::_path_command!procedure

    if { [string equal $cmd "configure"] ||
         [string equal $cmd "cget"] ||
         [string equal $cmd "bind"] ||
	 [string equal $cmd "setvalue"] ||
	 [string equal $cmd "getvalue"]} {
        return [eval [list LabelSpinBox::$cmd $path] $larg]
    } else {
        return [eval [list $path.e:cmd $cmd] $larg]
    }
}


proc LabelSpinBox::_destroy { path } {
# Destructor function.
# <in> path -- The path of the megawidget. 
# [index] LabelSpinBox::_destroy!procedure

    Widget::destroy $path
}

package provide BWLabelSpinBox 1.0.0
