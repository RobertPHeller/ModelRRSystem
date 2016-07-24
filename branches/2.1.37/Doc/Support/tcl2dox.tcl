#!/usr/bin/tclsh
#* 
#* ------------------------------------------------------------------
#* tcl2dox.tcl - Tcl2Dox -- Generate a structural docfile for Doxygen from Tcl code
#* Created by Robert Heller on Sun Nov  8 08:44:53 2009
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

## @file tcl2dox.tcl
#  @brief Generate a structural docfile for Doxygen from Tcl code.
#  This file reads in a properly documented Tcl file and generates on
#  stdout a structural docfile suitable for Doxygen.
#

namespace eval tcl2dox {
## 
# @brief Namespace used for tcl2dox's code and variables.
# This namespace is used to hold all of tcl2dox's procedures and variables.
#

  variable flineno 0
  ## File line number

  proc ProcessBody {struturaltype structname isclass needgroup haselements bodylist} {
    ## @brief Process an element body.
    # This function processes an element's body, possibly recursing for those
    # elements that can contain subelements.
    # 
    # @param struturaltype The structural type word, one of file, namespace, 
    #			   class, fn, or var.
    # @param structname    The name or declaration for the struturaltype.
    # @param isclass       Are we in a class definiation?
    # @param needgroup     Do we need grouping?
    # @param haselements   Does the item have subelements?
    # @param bodylist	   List of body lines.
    

    #puts stderr "*** ProcessBody $struturaltype $structname $isclass $needgroup $haselements [lrange $bodylist 0 3]..."

    variable flineno
    if {$struturaltype eq "file"} {set flineno 0}
    set lineno 0
    set state LookingForDocBlockOrElementStart
    set elementblock {}
    set currentStructuralType $struturaltype
    set currentStructname     $structname
    set completedDocBlock no
    set needendgroup no
    set elementblock_flineno $flineno
    foreach line $bodylist {
      incr lineno
      if {$struturaltype eq "file"} {incr flineno}
      #puts stderr "*** ProcessBody: lineno = $lineno, flineno = $flineno, line is $line"
      switch -exact $state {
	LookingForDocBlockOrElementStart {
	  #if {$currentStructuralType eq "namespace"} {puts stderr "*** ProcessBody: line is $line"}
	  if {[regexp {^[[:space:]]*#([#!])+[[:space:]]*(.*)$} \
			"$line" -> CH L] > 0} {
	    #if {$currentStructuralType eq "namespace"} {puts stderr "*** ProcessBody: CH = $CH, L = $L"}
	    if {"$struturaltype" eq "file" && $lineno == 1 && "$CH" eq {!}} {continue}
	    set state ProcessingDocBlock
	    puts stdout "/** $L"
	  } elseif {[string trim "$line"] ne ""} {
	    if {!$haselements} {return}
	    if {[regexp {^[[:space:]]*#} "$line"] > 0} {continue}
	    set elementblock "$line\n"
	    set elementblock_flineno $lineno
	    if {[info complete "$elementblock"]} {
	      set state [DoElement $elementblock $isclass $structname \
				     currentStructuralType currentStructname \
				     $elementblock_flineno]
	      set elementblock {}
	    } else {
	      set state LookingForCompleteElement
	    }
	  }
	}
	ProcessingDocBlock {
	  if {[regexp {^[[:space:]]*#[#!]*[[:space:]]*(.*)$} \
			"$line" -> L] > 0} {
	    puts stdout " * $L"
	  } else {
	    puts stdout " */"
	    if {$needgroup} {
	      puts stdout "$currentStructuralType $currentStructname \{"
	      if {$isclass} {
		puts stdout "public:"
	      }
	      set needendgroup yes
	      set needgroup no
	    } elseif {[regexp {^snit::(boolean|double|fpixels|integer|listtype|pixels|stringtype|window)} $currentStructuralType => thetype] > 0} {
	      switch $thetype {
		integer {set thetype int}
		boolean {set thetype bool}
		stringtype {set thetype {char *}}
	      }
	      puts stdout "typedef $thetype $currentStructname  ;"
	    } elseif {$currentStructuralType eq "snit::enum"} {
	      puts stdout "enum $currentStructname ;"
	    } elseif {$currentStructuralType ne "file"} {
	      puts stdout "$currentStructname ;"
	    }
	    if {!$haselements} {return}
	    set state LookingForDocBlockOrElementStart
	    set elementblock {}
	    if {[string trim "$line"] ne ""} {
	      set elementblock "$line\n"
	      if {[info complete "$elementblock"]} {
		set state [DoElement $elementblock $isclass $structname \
				     currentStructuralType currentStructname \
				     $elementblock_flineno]
	        set elementblock {}
	      } else {
	        set state LookingForCompleteElement
	      }
	    }
	  }
	}
	LookingForCompleteElement {
	  append elementblock "$line\n"
	  if {[info complete "$elementblock"]} {
	    set state [DoElement $elementblock $isclass $structname \
				     currentStructuralType currentStructname \
				     $elementblock_flineno]
	    set elementblock {}
	  }
	}
      }
    }
    if {$needendgroup} {puts stdout "\};"}
  }
  proc ProcessENumElements {structname bodylist} {
    ## @brief Process an enum's elements.
    # This function processes an enum's elements.
    #
    # @param structname    The name or declaration for the struturaltype.
    # @param bodylist	 List of body lines.

    #puts stderr "*** ProcessENumElements $structname [lrange $bodylist 0 3]..."

    variable flineno
    set lineno 0
    set state LookingForDocBlockOrElement
    set elementblock {}
    set currentStructuralType enum
    set currentStructname     $structname
    set completedDocBlock no
    set needendgroup no
    set needgroup yes
    set needcomma no
    foreach line $bodylist {
      incr lineno
      incr flineno
      #puts stderr "*** ProcessENumElements: line($lineno) is $line"
      #puts stderr "*** ProcessENumElements: state = $state"
      switch -exact $state {
	LookingForDocBlockOrElement {
	  if {[regexp {^[[:space:]]*#([#!])+[[:space:]]*(.*)$} \
	 		"$line" -> CH L] > 0} {
	    set state ProcessingDocBlock
	    if {$needcomma} {puts stdout ","}
	    puts stdout "#line $flineno"
	    puts stdout "/** $L"
	  } elseif {[string trim "$line"] ne ""} {
	    if {[regexp {^[[:space:]]*#} "$line"] > 0} {continue}
	    set elementblock ${line}
	    set needcomma yes
	    set state LookingForDocBlockOrElement
	  }
	}
	ProcessingDocBlock {
	  if {[regexp {^[[:space:]]*#[#!]*[[:space:]]*(.*)$} \
			"$line" -> L] > 0} {
	    puts stdout " * $L"
	  } else {
	    puts stdout " */"
	    if {$needgroup} {
	      puts stdout "enum $currentStructname \{"
	      set needendgroup yes
	      set needgroup no
	      set needcomma no
	    } elseif {$elementblock ne {}} {
	      puts  -nonewline stdout ${elementblock}
	      set needcomma yes
	      set elementblock {}
	    }
	    set state LookingForDocBlockOrElement
	    if {[string trim "$line"] ne ""} {
	      set elementblock ${line}
	    }
	  }
	}
      }
    }
    if {$elementblock ne {}} {puts stdout $elementblock}
    if {$needcomma} {puts stdout {}}
    if {$needendgroup} {puts stdout "\};"}
  }
  proc DoElement {eblock isclass classname curSTVar curSNVar elementblock_flineno} {
  ##
  # @brief Process an element.
  # Process one element in a body.
  #
  # @param eblock The element's block (as a concat'ed string).
  # @param isclass Are we in a class definiatation?
  # @param classname The name of the class we are in.
  # @param curSTVar The name of the currentStructuralType variable to pass 
  #		    back the new struct type in, if element is a variable.
  # @param curSNVar The name of the currentStructname variable to pass
  #		    back the new struct name in, if element is a variable.
  #

    upvar $curSTVar currentStructuralType
    upvar $curSNVar currentStructname
    if {[regexp {[[:space:]]*([^[:space:]]+)[[:space:]]} \
	"$eblock" -> firstword] < 1} {
      return LookingForDocBlockOrElementStart
    } 	
    puts stdout "#line $elementblock_flineno"

    switch -exact -- $firstword {
      method {
	set structType fn
	set structname "[regsub -all {[[:space:]]} [lindex $eblock 1] {_}] ("
	append structname [ProcessParams [lindex $eblock 2]]
	append structname ")"
	ProcessBody $structType "$structname" no no no [split [lindex $eblock 3] "\n"]
	return LookingForDocBlockOrElementStart
      }
      
      snit::macro {
	set structType fn
	append structname "[namespace tail [regsub -all {[[:space:]]} [lindex $eblock 1] {_}]] ("
	append structname [ProcessParams [lindex $eblock 2]]
	append structname ")"
	ProcessBody $structType "$structname" no no no [split [lindex $eblock 3] "\n"]
	return LookingForDocBlockOrElementStart
      }
      proc {
	set structType fn
	if {$isclass} {
	  set structname "static "
	} else {
	  set structname ""
	}
	append structname "[regsub -all {[[:space:]]} [lindex $eblock 1] {_}] ("
	append structname [ProcessParams [lindex $eblock 2]]
	append structname ")"
	ProcessBody $structType "$structname" no no no [split [lindex $eblock 3] "\n"]
	return LookingForDocBlockOrElementStart
      }
      typemethod {
	set structType fn
	set structname "static "
	append structname "[regsub -all {[[:space:]]} [lindex $eblock 1] {_}] ("
	append structname [ProcessParams [lindex $eblock 2]]
	append structname ")"
	ProcessBody $structType "$structname" no no no [split [lindex $eblock 3] "\n"]
	return LookingForDocBlockOrElementStart
      }
      constructor {
	set structType fn
	set structname "$classname (name, "
	append structname [ProcessParams [lindex $eblock 1]]
	append structname ")"
	ProcessBody $structType "$structname" no no no [split [lindex $eblock 2] "\n"]
	return LookingForDocBlockOrElementStart
      }
      destructor {
	set structType fn
	set structname "~$classname ()"
	ProcessBody $structType "$structname" no no no [split [lindex $eblock 1] "\n"]
        return LookingForDocBlockOrElementStart
      }

      snit::boolean -
      snit::double -
      snit::fpixels -
      snit::integer -
      snit::listtype -
      snit::pixels -
      snit::stringtype -
      snit::window {
	set currentStructuralType $firstword
	if {[regexp {[[:space:]]*[^[:space:]]+[[:space:]]+([^[:space:]]+).*$} \
		"$eblock" -> varname] < 1} {
	  return LookingForDocBlockOrElementStart
	}
	set currentStructname "$varname"
	return LookingForDocBlockOrElementStart
      }
      
      snit::type -
      snit::widget -
      snit::widgetadaptor {
	set structType class
	set structname [lindex $eblock 1]
	ProcessBody $structType "$structname" yes yes yes [split [lindex $eblock 2] "\n"]
	return LookingForDocBlockOrElementStart
      }
      namespace {
	#puts stderr "*** DoElement: \[lindex \$eblock 0\] = [lindex $eblock 0]"
	#puts stderr "*** DoElement: \[lindex \$eblock 1\] = [lindex $eblock 1]"
	#puts stderr "*** DoElement: \[lindex \$eblock 2\] = [lindex $eblock 2]"
        if {"[lindex $eblock 1]" eq "eval"} {
	  set structType namespace
	  set structname [lindex $eblock 2]
	  ProcessBody $structType "$structname" no yes yes [split [lindex $eblock 3] "\n"]
	}
	return LookingForDocBlockOrElementStart
      }
      snit::enum {
	#puts stderr "*** DoElement: \[lindex \$eblock 0\] = [lindex $eblock 0]"
	#puts stderr "*** DoElement: \[lindex \$eblock 1\] = [lindex $eblock 1]"
	#puts stderr "*** DoElement: \[lindex \$eblock 2\] = [lindex $eblock 2]"
	#puts stderr "*** DoElement: \[lindex \$eblock 3\] = [lindex $eblock 3]"
	set structType enum
	set structname [lindex $eblock 1]
	ProcessENumElements "$structname" [split [lindex $eblock 3] "\n"]
	return LookingForDocBlockOrElementStart
      }
      component -
      variable -
      global {
	set currentStructuralType var
	if {[regexp {[[:space:]]*[^[:space:]]+[[:space:]]+([^[:space:]]+).*$} \
		"$eblock" -> varname] < 1} {
	  return LookingForDocBlockOrElementStart
	}
	set currentStructname "$varname"
	return LookingForDocBlockOrElementStart
      }
      typecomponent -
      typevariable {
	set currentStructuralType var
	if {[regexp {[[:space:]]*[^[:space:]]+[[:space:]]+([^[:space:]]+).*$} \
		"$eblock" -> varname] < 1} {
	  return LookingForDocBlockOrElementStart
	}
	set currentStructname "static $varname"
        return LookingForDocBlockOrElementStart
      }
      default {
	return LookingForDocBlockOrElementStart
      }
    }
  }
  proc ProcessParams {paramlist} {
  ## 
  # @brief Process a parameter list.
  # Converts a Tcl parameter list into a C++ flavored parameter list.
  #
  # @param paramlist The Tcl parameter list.
  #

    set result {}
    set comma {}
    foreach p $paramlist {
      if {[llength $p] == 1} {
	if {"$p" == "args" && "$p" eq [lindex $paramlist end]} {
	  append result "$comma ..."
	} else {
	  append result "$comma $p"
	}
      } else {
	append result "$comma [lindex $p 0] = "
	if {[string is integer -strict [lindex $p 1]]} {
	  append result [lindex $p 1]
	} elseif {[string is double -strict [lindex $p 1]]} {
	  append result [lindex $p 1]
	} else {
	  append result {"}
	  append result [lindex $p 1]
	  append result {"}
	}
      }
      set comma ","
    }	
    return $result
  }
}

if {$::argc < 1} {
  puts stderr "usage: $::argv0 filename"
  exit 99
}

set filename [lindex $argv 0]
if {[catch {open $filename r} fp]} {
  puts stderr "$::argv0: open $filename r: $fp"
  exit 98
}

tcl2dox::ProcessBody file [file tail $filename] no no yes [split [read $fp] "\n"]
close $fp
