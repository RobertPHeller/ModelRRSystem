#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Nov 29 13:57:57 2024
#  Last Modified : <241129.1358>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
## @copyright
#    Copyright (C) 2024  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# @file ReadCDIProgress.tcl
# @author Robert Heller
# @date Fri Nov 29 13:57:57 2024
# 
#
#*****************************************************************************



snit::widgetadaptor ReadCDIProgress {
    delegate option -parent to hull
    
    component bytesE
    variable  bytesRead
    component progress
    
    
    delegate option -totalbytes to progress as -maximum
    
    constructor {args} {
        installhull using Dialog -bitmap questhead -default dismis \
              -modal none -transient yes \
              -side bottom -title [_ "Reading CDI"] \
              -parent [from args -parent]
        $hull add dismis -text [_m "Button|Dismiss"] \
              -state disabled -command [mymethod _Dismis]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Dismis]
        set frame [$hull getframe]
        install bytesE using ttk::entry $frame.bytesE \
              -textvariable [myvar bytesRead] \
              -state readonly
        pack $bytesE -expand yes -fill x
        install progress using ttk::progressbar $frame.progress \
              -orient horizontal -mode determinate -length 256
        pack $progress -expand yes -fill x
        $self configurelist $args
    }
    method draw {args} {
        #puts stderr "*** $self draw $args"
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        $hull itemconfigure dismis -state disabled
        update idle
        return [$hull draw]
    }
    method withdraw {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Dismis {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
    method Update {bytesread} {
        #puts stderr "*** $self Update $bytesread"
        set bytesRead [_ "%5d bytes read of %5d" $bytesread \
                       [$progress cget -maximum]]
        $progress configure -value $bytesread
        update idle
    }
    method Done {} {
        #puts stderr "*** $self Done"
        $hull itemconfigure dismis -state normal
        update idle
    }
}

package provide ReadCDIProgress 1.0
