#* 
#* ------------------------------------------------------------------
#* SampleCodeCircle.tcl - Circle type
#* Created by Robert Heller on Sat Dec 22 08:14:43 2007
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

# $Id$

package require snit;#	Load the snit package
package require Tk;#	Load the Tk package
package require tile;# BWidget Code
package require grsupport 2.0;#	Load V2 Graphics Support package.

snit::type Circle {
  # Snit type for drawing circles.

  #*********************
  # Type variables:
  #*********************
  typevariable _MenuId 0;# Ever increasing id for menus

  #*********************
  # Type methods:
  #*********************
  typemethod _GenerateMenuPath {} {
    # Create a unique menu path.
    incr _MenuId
    return "circleMenu$_MenuId"
  }
  typemethod bindtocanvas {canvas sequence {extracode {}}} {
    # Bind circle creation to a canvas.
    bind $canvas $sequence \
	[mytypemethod _CreateCircle \
			$canvas %x %y "$extracode"]
  }
  typemethod _CreateCircle {canvas mx my extracode} {
    $type create %%AUTO%% $canvas \
		-x [$canvas canvasx $mx] \
		-y [$canvas canvasy $my] \
		-extracode "$extracode"
  }

  #*********************
  # Methods:
  #*********************
  GRSupport::VerifyDoubleMethod;# Verify double valued options.
  GRSupport::VerifyColorMethod;#  Verify color valued options.
  method _ConfigureXY {option value} {
  # Method to configure X or Y.
  # <in> option The name of the option to configure.
  # <in> value The new value.
  # [index] _ConfigureXY!method

    set oldx $options(-x)
    set oldy $options(-y)
    set options($option) $value
    set dx [expr {$options(-x) - $oldx}]
    set dy [expr {$options(-y) - $oldy}]
    $canvas move $selfns $dx $dy
    set x $options(-x)
    set y $options(-y)
    set size $options(-size)
    set sx [expr {$x + $size}]
    set sy [expr {$y + $size}]
    set centerX [expr {$x + ($size * 0.5)}]
    set centerY [expr {$y + ($size * 0.5)}]
  }
  method _ConfigureSize {option value} {
  # Method to configure size.
  # <in> option The name of the option to configure.
  # <in> value The new value.
  # [index] _ConfigureSize!method

    set deltaSize [expr {double($value) / double($options($option))}]
    set options($option) $value
    $canvas scale $selfns $centerX $centerY \
				$deltaSize $deltaSize
    foreach {x y sx sy} [$canvas coords $selfns] {break}
    set options(-x) $x
    set options(-y) $y
  }
  method _ConfigureFillColor {option value} {
  # Method to configure a fill color.
  # <in> option The name of the option to configure.
  # <in> value The new value.
  # [index] _ConfigureFillColor!method

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -fill "$value"}
  }
  method _ConfigureOutlineColor {option value} {
  # Method to configure an outline color.
  # <in> option The name of the option to configure.
  # <in> value The new value.
  # [index] _ConfigureOutlineColor!method

    set options($option) $value
    set  tag $selfns
    catch {$canvas itemconfigure ${tag}$option -outline "$value"}
  }
  method Circumfrence {} {
    # Method to return the circumfrence of the circle.
    # Uses PI from the Graphics Support library.
    return [expr {$options(-size) * $::GRSupport::PI}]
  }
  # Methods bound to events for circles: resizing, moving, and a popup menu
  # for changing colors and deleting
  method _StartResize {mx my} {
    set rx [expr {[$canvas canvasx $mx] - $centerX}]
    set ry [expr {[$canvas canvasy $my] - $centerY}]
    set Rdxy [expr {sqrt($rx*$rx + $ry*$ry)}]
    set RorgSize $options(-size)
  }
  method _Resize {mx my} {
    set x [expr {[$canvas canvasx $mx] - $centerX}]
    set y [expr {[$canvas canvasy $my] - $centerY}]
    set dxy [expr {sqrt($x*$x + $y*$y)}]
    set dsize [expr {($dxy - $Rdxy)*2.0}]
    $self configure -size [expr {$RorgSize + $dsize}]
    if {[string length "$options(-extracode)"] > 0} {
	uplevel #0 "$options(-extracode)"
    }
  }
  method _StopResize {mx my} {
    catch {unset Rdxy}
    catch {unset RorgSize}
  }
  method _StartMove {mx my} {
    set Mx [expr {[$canvas canvasx $mx] - $options(-x)}]
    set My [expr {[$canvas canvasy $my] - $options(-y)}]
  }
  method _Move {mx my} {
    set x [expr {[$canvas canvasx $mx] - $Mx}]
    set y [expr {[$canvas canvasy $my] - $My}]
    $self configure -x $x -y $y
    if {[string length "$options(-extracode)"] > 0} {
	uplevel #0 "$options(-extracode)"
    }
  }
  method _StopMove {mx my} {
    catch {unset Mx}
    catch {unset My}
  }
  method _PostMenu {X Y} {
    $menupath post $X $Y
  }
  method _setColor {opt menulab} {
    set newcolor [SelectColor $colormenupath -parent $canvas\
			-color "$options($opt)" -type  popup]
    if {[string length "$newcolor"] > 0} {
      $self configure $opt "$newcolor"
      $menupath entryconfigure "$menulab" -foreground "$newcolor"
    }
    $menupath unpost
  }
  method _delete {} {
    $self destroy
  }
  #***************************
  # Variables:
  #***************************
  variable canvas;#	Canvas the circle is drawn on.
  variable sx;#		Right side of circle.
  variable sy;#		Bottom side of circle.
  variable centerX;#	Center of circle (X).
  variable centerY;#	Center of circle (Y).
  variable menupath;#   Our popup menu
  variable colormenupath;#   Our ColorSelect popup menu
  variable Rdxy;#	Resizing variable
  variable RorgSize;#	Resizing variable
  variable Mx;#		Moving variable
  variable My;#		Moving variable

  #***************************
  # Options:
  #***************************
  # Upper left corner (x,y).
  option -x -default 0 -validatemethod _VerifyDouble \
			 -configuremethod _ConfigureXY
  option -y -default 0 -validatemethod _VerifyDouble \
			-configuremethod _ConfigureXY
  # Size (diameter) of circle.
  option -size -default 100 -validatemethod _VerifyDouble \
			    -configuremethod _ConfigureSize
  # Color of the circle.
  option -outline -default black -validatemethod _VerifyColor \
				-configuremethod _ConfigureOutlineColor
  option -fill -default black -validatemethod _VerifyColor \
				-configuremethod _ConfigureFillColor
  # Extra code to run after creating, moving, resizing, and deleting circles.
  option -extracode -default {} -readonly yes
  #***************************
  # Constructor: draw the circle.
  #***************************
  constructor {_canvas args} {
    set canvas $_canvas
    set tag $selfns
    catch {$canvas delete $tag}
    $self configurelist $args
    set x $options(-x)
    set y $options(-y)
    set size $options(-size)
    set sx [expr {$x + $size}]
    set sy [expr {$y + $size}]

    set menupath $canvas.[$type _GenerateMenuPath]
    set colormenupath $canvas.colormenu$_MenuId
    menu $menupath -tearoff no
    $menupath add command -label {Fill Color} \
			  -foreground "$options(-fill)" \
			  -command [mymethod _setColor \
					-fill {Fill Color}]    
    $menupath add command -label {Outline Color} \
			  -foreground "$options(-outline)" \
			  -command [mymethod _setColor \
					-outline {Outline Color}]    
    $menupath add command -label {Delete} \
			  -command [mymethod _delete]
    bind $menupath <Escape> "$menupath unpost"

    $canvas create oval $x $y $sx $sy \
		-outline "$options(-outline)" \
		-fill    "$options(-fill)" \
		-width   2 \
		-tag     [list $tag ${tag}-fill \
				${tag}-outline]
    $canvas bind $tag <Shift-ButtonPress-2> \
			[mymethod _StartResize %x %y]
    $canvas bind $tag <Shift-Button2-Motion> \
			[mymethod _Resize %x %y]
    $canvas bind $tag <Shift-ButtonRelease-2> \
			[mymethod _StopResize %x %y]
    $canvas bind $tag <ButtonPress-2> \
			[mymethod _StartMove %x %y]
    $canvas bind $tag <Button2-Motion> \
			[mymethod _Move %x %y]
    $canvas bind $tag <ButtonRelease-2> \
			[mymethod _StopMove %x %y]
    $canvas bind $tag <ButtonPress-3> \
			[mymethod _PostMenu %X %Y]
    if {[string length "$options(-extracode)"] > 0} {
	uplevel #0 "$options(-extracode)"
    }
  }
  #***************************
  # Descructor: remove the circle.
  #***************************
  destructor {
    catch {$canvas delete $selfns}
    catch {destroy $menupath}
    if {[string length "$options(-extracode)"] > 0} {
	uplevel #0 "$options(-extracode)"
    }
  }
}





package provide SampleCodeCircle 1.0
