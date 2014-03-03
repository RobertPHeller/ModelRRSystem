#* 
#* ------------------------------------------------------------------
#* splash.tcl - General purpose splash window
#* Created by Robert Heller on Mon Feb 27 13:13:31 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.4  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
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
package require Tk
package require tile

## @addtogroup TclCommon
#  @{

snit::widget splash {
## @brief Widget that implements a spash window.  
#
# A splash window is a toplevel that
# is displayed during startup and shows a startup graphic and shows the
# startup / initialization progress.
#
# @param path The widget path.
# @param ... Options:
# @arg -style Style name, default is Splash.
# @arg -titleforeground Delegated to the title widget as -forground.
# @arg -statusforeground Delegated to the status widget as -forground.
# @arg -background Background color.
# @arg -progressbar Flag that enables or disables the progress bar.
# @arg -image Spash image to display in the lower part of the splash window.
# @arg -icon Icon to display next to the text in the upper part of the 
#		 splash window.
# @arg -title Title text.
#
# @author Robert Heller \<heller\@deepsoft.com\>
# 
# @section splash_package Package provided
#
# Splash 1.0
#

  hulltype toplevel
  widgetclass Splash
  option -style -default Splash
  typeconstructor {
      ttk::style configure Splash -borderwidth 5 -relief ridge
      bind Splash <<ThemeChanged>> [mytypemethod _ThemeChanged %W]
  }
  typemethod _ThemeChanged {w} {
      $w _themeChanged
  }
  method _themeChanged {} {
      $hull configure \
            -borderwidth [ttk::style lookup $options(-style) -borderwidth] \
            -relief [ttk::style lookup $options(-style) -relief]
  }  
  component image
    ## @privatesection Image component.
  component progressBar
    ## Progress bar component.
  component title
    ## Title component.
  component icon
    ## Icon component.
  component status
    ## Status component.
  component header
    ## Header component.

  variable  currentProgress 0
  ## The current progress
  
  delegate option {-titleforeground foreground Foreground} to title as -foreground
  delegate option {-statusforeground foreground Foreground} to status as -foreground
  option -background -default #d9d9d9 -readonly yes -validatemethod CheckColor
  method CheckColor {option value} {
      ## Method to validate a color option.
      # @param option The option being set.
      # @param value  The value it is being set to.
      
      if {[catch [list winfo rgb $win $value] message]} {
          error "Option $option must have a legal color value.  Got $value"
      }
  }
  
  option {-progressbar progressBar ProgressBar} \
		-default yes \
		-readonly yes \
		-type snit::boolean
  option {-image image Image} \
	-default {} \
	-readonly yes \
	-validatemethod CheckImage
  option {-icon icon Icon} \
	-default {} \
	-readonly yes \
	-validatemethod CheckImage
  method CheckImage {option value} {
  ## Method to validate an image option.
  # @param option The option being set.
  # @param value  The value it is being set to.

    if {[string equal "$value" {}]} {
      return
    } elseif {[lsearch -exact [image names] "$value"] < 0} {
       error "Option $option must have a valid image (or be empty for none).  Got $value."
    }
  }
  option {-title title Title} \
	-default {} \
	-readonly yes

  method update {statusMessage percentDone} {
  ## @publicsection Method to update the splash window.
  # @param statusMessage The new status message.
  # @param percentDone The percent completed.

    $status configure -text "$statusMessage"
    set currentProgress $percentDone
    if {$percentDone >= 100} {$self enableClickDestroy}
  }

  method enableClickDestroy {} {
  ## Method to enable click to destroy.

    wm protocol $win WM_DELETE_WINDOW {}
    bind $win <1> "destroy $win"
  }

  method hide {} {
  ## Method to hide the splash window.

    wm withdraw $win
  }

  method show {} {
  ## Method to show the splash window.

    wm deiconify $win
  }

  constructor {args} {
  ## Constructor initialize a spash window.
  # @param ... Option list.
  # [index] constructor!splash

    wm withdraw $win
    wm overrideredirect $win yes
    wm protocol $win WM_DELETE_WINDOW {break}
    
    set options(-image) [from args -image]
    if {$options(-image) eq ""} {
        set imwidth 0
    } else {
        set imwidth [image width $options(-image)]
    }
    set options(-icon) [from args -icon]
    if {$options(-icon) eq ""} {
        set icowidth 0
    } else {
        set icowidth [image width $options(-icon)]
    }
    install header using frame $win.header \
          -width $imwidth
    install icon using ttk::label $header.icon -anchor nw 
    set titlewidth [expr {$imwidth - $icowidth}]
    if {$titlewidth < 0} {set titlewidth 0}
    #puts stderr "*** $type create $win: imwidth = $imwidth, icowidth = $icowidth, titlewidth = $titlewidth"
    install title using message $header.title \
		-aspect {1000} \
          -font {Times -10 roman} -width $titlewidth
    install image using ttk::label $win.image \
          -image $options(-image) -width $imwidth
    install progressBar using ttk::progressbar $win.progressBar \
          -orient horizontal \
          -maximum 100 \
          -variable [myvar currentProgress] \
          -length $imwidth
    set currentProgress 0
    install status using message $win.status \
          -aspect {700} \
          -font   {Times -10 roman} \
          -text	{} \
          -width $imwidth  -borderwidth 0 -relief flat
    $self configurelist $args
    foreach w [list $hull $header $title $progressBar $status $image $icon] {
      catch [list $w configure -background $options(-background)]
    }
    if {[string length "$options(-icon)"] || [string length "$options(-title)"]} {
      pack $header -fill x -expand yes
      if {[string length "$options(-icon)"]} {
	$icon configure -image "$options(-icon)"
	pack $icon -side left -expand yes
      }
      if {[string length "$options(-title)"]} {
	$title configure -text "$options(-title)"
	pack $title -side right -fill both -expand yes
      }
    }
    if {[string length "$options(-image)"]} {
      pack $image;# -fill x
    }
    update idle
    #puts stderr "*** $type create $win: reqwidth of $title is [winfo reqwidth $title]"
    #puts stderr "*** $type create $win: reqwidth of $icon is [winfo reqwidth $icon]"
    #puts stderr "*** $type create $win: reqwidth of $image is [winfo reqwidth $image]"
    #puts stderr "*** $type create $win: reqwidth of $win is [winfo reqwidth $win]"
    pack $status -fill x
    if {$options(-progressbar)} {
        pack $progressBar -fill x
    }
    update idle
    set w [winfo reqwidth $win]
    set h [winfo reqheight $win]
    set sw [winfo screenwidth $win]
    set sh [winfo screenheight $win]
    set rx [winfo rootx $win]
    set ry [winfo rooty $win]
    set xx [expr int($rx + (double($sw-$w) / 2.0) + .5)]
    set yy [expr int($ry + (double($sh-$h) / 2.0) + .5)]
    if {[expr $xx + $rx] > $sw} {set xx [expr $sw - $w]}
    if {[expr $yy + $ry] > $sh} {set yy [expr $sh - $h]}
    if {$xx < 0} {set xx 0}
    if {$yy < 0} {set yy 0}
    wm geom $win +$xx+$yy
    wm deiconify $win
    $self _themeChanged
    #puts stderr "*** $type create $win: bindtags are [bindtags $win]"
  }
}

## @}

package provide Splash 1.0
