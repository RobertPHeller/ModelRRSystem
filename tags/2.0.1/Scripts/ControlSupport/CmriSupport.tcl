#* 
#* ------------------------------------------------------------------
#* CmriSupport.tcl - CMRI Node Control Support
#* Created by Robert Heller on Sun May 30 19:37:31 2004
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2004/06/06 13:59:45  heller
#* Modification History: Start of C/MRI Support code.
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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
#* $Id$


global ShareDir ScriptsDir
if {![info exists ShareDir] || ![info exists ScriptsDir]} {
  set scriptdir [file dirname [info script]]
  if {[string length "$scriptdir"] == 0 || [string equal "$scriptdir" {.}]} {
    set scriptdir [pwd]
  }
  set ScriptsDir [file dirname $scriptdir]
  if {[string length "$ScriptsDir"] == 0 || [string equal "$ScriptsDir" {.}]} {
    set ScriptsDir [pwd]
  }
  set ShareDir [file dirname $ScriptsDir]
  if {[string length "$ShareDir"] == 0 || [string equal "$ShareDir" {.}]} {
    set ShareDir [pwd]
  }
  set ScriptsDir [file join $ShareDir Scripts]
  lappend auto_path $ScriptsDir
}

package ifneeded Cmri 1.0 {
  load [file join $ShareDir Lib cmri[info sharedlibextension]]
}

proc DefineNode {name CMriBusObject UA NodeType args} {
  upvar #0 ${name}_data data
  set data(CMriBusObject) $CMriBusObject
  switch -exact -- $NodeType {
    SUSIC -
    USIC {
      tclParseConfigSpec ${name}_data \
	{ {-ns ns Ns 0 tclVerifyInteger}
	  {-ni ni Ni 0 tclVerifyInteger}
	  {-no no No 0 tclVerifyInteger}
	  {-ct ct Ct {}}
	  {-dl dl Dl 0 tclVerifyInteger} } "" $args
    }
    SMINI {
      array set data {-ni 3 -no 6 -dl 0}
      tclParseConfigSpec ${name}_data \
	{ {-ns ns Ns 0 tclVerifyInteger}
	  {-ct ct Ct {}} } "" $args
    }
  }
  switch -exact -- $NodeType {
    SUSIC {set ctype X}
    USIC  {set ctype N}
    SMINI {set ctype M}
  }
  $CMriBusObject InitBoard $data(-ct) $data(-ni) $data(-no) $data(-ns) $UA $ctype $data(-dl)
  set arglist {function args}
  set body {}
  append body "  upvar #0 ${name}_data data\n"
  append body "  switch -exact -- \$function \{\n"
  append body "    inputs \{\n"
  append body "      return \[\$data(CMriBusObject) Inputs \$data(-ni) $UA\]\n"
  append body "    \}\n"
  append body "    outputs \{\n"
  append body "      \$data(CMriBusObject) Outputs \$args $UA\n"
  append body "    \}\n"
  append body "  \}\n"
  uplevel #0 [list proc $name $arglist $body]
}
    


