#* 
#* ------------------------------------------------------------------
#* grsupport2.tcl - Graphics Support Version 2
#* Created by Robert Heller on Tue Jan 23 16:51:22 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
#* Modification History:
#* Modification History: Revision 1.2  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.1  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
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


## @defgroup GRSupportModule GRSupportModule
#  @brief Graphics Support code.
#
# A collection of packages to help with various graphics needs.
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
#  @{


namespace eval GRSupport {
## @brief Code to support the various graphics packages.
#
# Namespace where all of the graphics support code lives.
#
#
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @section grsupport2_package Package provided
#
# grsupport 2.0
#

  variable PI2 
  ## Variable containing @f$\pi/2@f$.
  # This variable is read-only.

  set PI2 [expr {acos(0.0)}]
  trace add variable PI2 {write unset} GRSupport::_ROPI2
  proc _ROPI2 {name1 name2 op} {
    ## @private A variable trace to enforce the read-only-ness of PI2.
    variable PI2
    set PI2 [expr {acos(0.0)}]
    error "Attempt to modify $name1 ($op)!"
  }
  variable PI
  ## Variable containing @f$\pi@f$.
  # This variable is read-only.

  set PI  [expr {$PI2 * 2.0}]
  trace add variable PI {write unset} GRSupport::_ROPI
  proc _ROPI {name1 name2 op} {
    ## @private A variable trace to enforce the read-only-ness of PI.
    variable PI2
    variable PI
    set PI  [expr {$PI2 * 2.0}]
    error "Attempt to modify $name1 ($op)!"
  }

  proc DegreesToRadians {degrees} {
  ## Function  to convert from degrees to radians.
  # @param degrees Value to convert to radians.

    variable PI
    return [expr {(double($degrees) / 180.0) * $PI}]
  }
  proc RadiansToDegrees {rads} {
  ## Function  to convert from radians to degrees.
  # @param rads Value to convert to degrees.

    variable PI
    return [expr {$rads * (180.0 / $PI)}]
  }

snit::macro GRSupport::VerifyDoubleMethod {} {
## Snit macro defining a validate method for doubles.

  method _VerifyDouble {option value} {
    if {[string is double -strict "$value"]} {
      return $value
    } else {
      error "Expected a double for $option, but got $value!"
    }
  }
}

snit::macro GRSupport::VerifyBooleanMethod {} {
## Snit macro defining a validate method for booleans.

  method _VerifyBoolean {option value} {
    if {[string is boolean -strict "$value"]} {
      return $value
    } else {
      error "Expected a boolean for $option, but got $value!"
    }
  }
}

snit::macro GRSupport::VerifyIntegerMethod {} {
## Snit macro defining a validate method integers.

  method _VerifyInteger {option value} {
    if {[string is integer -strict "$value"]} {
      return $value
    } else {
      error "Expected a integer for $option, but got $value!"
    }
  }
}

snit::macro GRSupport::VerifyOrientationHVMethod {} {
## Snit macro defining a validate method for orientation (horizontal or 
# vertical).

  method _VerifyOrientationHV {option value} {
    if {[lsearch -exact {horizontal vertical} "$value"] < 0} {
      error "Expected an orientation (horizontal or vertical) for $option, but got $value!"
    } else {
      return $value
    }
  }
}

snit::macro GRSupport::VerifyColorMethod {} {
## Snit macro defining a validate method for colors.

  method _VerifyColor {option value} {
    if {[catch {winfo rgb . "$value"}]} {
      error "Expected a color for $option, got $value!"
    } else {
      return "$value"
    }
  }
}

  namespace export PI2 PI DegreesToRadians RadiansToDegrees \
		   VerifyDoubleMethod VerifyBooleanMethod \
		   VerifyIntegerMethod VerifyOrientationHVMethod \
		   VerifyColorMethod

}

## @}

package provide grsupport 2.0

