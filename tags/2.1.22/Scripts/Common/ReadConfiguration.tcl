#* 
#* ------------------------------------------------------------------
#* ReadConfiguration.tcl - Read Configuration files.
#* Created by Robert Heller on Sat Mar 12 10:03:59 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.6  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
#* Modification History:
#* Modification History: Revision 1.5  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.4  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.3  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.2  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/03/20 14:12:19  heller
#* Modification History: March 20 Lock down
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

#@Chapter:ReadConfiguration.tcl -- Read Configuration Files.
#@Label:ReadConfiguration.tcl
#$Id$

package require snit;#			Load the Snit package.
package require BWidget;#		Load the BWidget code
package require BWFileEntry;#		Load File Entry code
package require BWLabelComboBox;#	Load Label Combo Box code
package require BWLabelSpinBox;#	Load Label Spinbox code
package require LabelSelectColor;#	Load Label Select Color code

namespace eval ReadConfiguration {
# The Read Configuration File code is contained in this namespace.
# [index] ReadConfiguration!namespace|(

  namespace export ReadConfiguration
# Exported Configuration reading function. See ?proc:ReadConfiguration? 
# for this procedure's documentation.

  namespace export WriteConfiguration
# Exported Configuration reading function. See ?proc:WriteConfiguration? 
# for this procedure's documentation.

  namespace export ConfigurationType
# Exported Configuration creation snit macro. See ?macro:ConfigurationType?
# for this macros's documentation.
# [index] ReadConfiguration!namespace|)
}

proc ReadConfiguration::ReadConfiguration {filename configurationArrayName} {
# [label] proc:ReadConfiguration
# This procedure reads in the configuration file named by the filename into
# the array named by configurationArrayName.
# <in> filename -- The name of the configuration file.
# <in> configurationArrayName -- The name of the array to hold the configuration.
# [index] ReadConfiguration::ReadConfiguration!procedure

  upvar $configurationArrayName configurationArray

  if {[catch [list open "$filename" r] fp]} {
    return [list -1 "Could not open $filename: $fp"]
  }
  set buffer {}
  set lineno 0
  set nl {}
  while {[gets $fp line] >= 0} {
    incr lineno
    if {[regexp {^#} "$line"] > 0} {
      set lineNoComment {}
    } elseif {[regexp {^(.*[^\\]+)#.*$} "$line" -> lineNoComment] < 1} {
      set lineNoComment "$line"
    }
    set lineNoComment [string trim "$lineNoComment"]
    append buffer "$nl$lineNoComment"
    set nl { }
    if {[info complete "$buffer"]} {
      set conflist "$buffer"
      set buffer {}
      set nl {}
      if {[llength "$conflist"] < 1} {
	continue
      } elseif {[llength "$conflist"] < 2} {
	lappend configurationArray(_Anonoymous_) "$conflist"
      } else {
	set name [lindex $conflist 0]
	set keyvalues [lindex $conflist 1]
	if {[llength $keyvalues] > 1 && [IsEven [llength $keyvalues]]} {
	  foreach {k v} $keyvalues {
	    set configurationArray($name:$k) $v
	  }
	} else {
	  set configurationArray($name) $keyvalues
	}
      }
    }
  }
  close $fp
  return [list 0 {}]
}

proc ReadConfiguration::IsEven {i} {
  return [expr {($i & 1) == 0}]
}

proc ReadConfiguration::WriteConfiguration {filename configurationArrayName} {
# [label] proc:WriteConfiguration
# This procedure writes the configuration contianed in configurationArrayName
# to the file named by the filename.
# <in> filename -- The name of the configuration file.
# <in> configurationArrayName -- The name of the array holding the configuration.
# [index] ReadConfiguration::WriteConfiguration!procedure

  upvar $configurationArrayName configurationArray

  if {[catch [list open "$filename" w] fp]} {
    return [list -1 "Could not open $filename: $fp"]
  }

  set elements [lsort -dictionary [array names configurationArray]]

  foreach element $elements {
    if {[string equal "$element" _Anonoymous_]} {
      foreach v $configurationArray($element) {
	puts $fp "$v"
      }
      continue
    }
    set nk [split "$element" :]
    if {[llength $nk] == 2} {
      set v $configurationArray($element)
      puts $fp [list [lindex $nk 0] [list [lindex $nk 1] $v]]
    } else {
      set v $configurationArray($element)
      puts $fp [list $element $v]
    }
  }
  close $fp
  return [list 0 {}]
}

snit::macro ReadConfiguration::ConfigurationType {args} {
# [label] macro:ConfigurationType
# This macro defines the body of a snit::type that implements a program's
# global configuration (or preferences).  The argument list is a set of 
# configuration variable defination lists.  Each list contains four elements: 
# the label, the key list name (a one or two element list), the type (one of 
# directory, infile, outfile, string, enumerated, integer, double, or color), 
# and the default value.  Enumerated types have an additional (fifth) element, 
# the set of possible values.  Numerical types (double and integer) have a 
# range of values as a fifth element. This macro should only be called inside a 
# snit::type defination.
#
# The configuration (aka preferences) are stored in the user's home directory.
# The file name under UNIX (including MacOSX) starts with a dot and contains
# the application rootname (from argv0).  Under MS-Windows, the file name
# does not start with a dot.  Instead .rc is appended.
# <args> The configuration variable definitions.
# <>
# Type methods defined:
# <load> Load the configuration.
# <save> Save the configuration. 
# <edit> Edit the configuration with a popup dialog.
# <getkeyoption> Get a keyed option.  Takes two arguments.
# <getoption> Get a non-keyed option. Takes one argument.
# <getanonoymous> Gets the anonoymous option.  Takes no arguments.

  # Configurations are ensemble commands
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  set arraydef {}
  set updateBody {}
  set applyBody {}
  set createDialogBody {
      if {![string equal "$_EditDialog" {}] && 
	  [winfo exists $_EditDialog]} {return}
      # Build dialog box
      set _EditDialog [Dialog::create .configuration \
				-bitmap questhead \
				-title "Edit Configuration" \
				-modal local \
				-transient yes \
				-default 0 -cancel 2 \
				-parent . -side bottom]
      # Dialog buttons
      $_EditDialog add -name ok \
		       -text OK \
		       -command [mytypemethod _OK]
      $_EditDialog add -name apply \
		       -text Apply \
		       -command [mytypemethod _Apply]
      $_EditDialog add -name cancel \
		       -text Cancel \
		       -command [mytypemethod _Cancel]
      wm protocol [winfo toplevel $_EditDialog] \
		WM_DELETE_WINDOW [mytypemethod _Cancel]
      $_EditDialog add -name help \
		       -text Help \
		       -command "HTMLHelp::HTMLHelp help {Edit Configuration}"
      # Dialog frame
      set frame [$_EditDialog  getframe]
  }

  # Components making up the dialog box for editing the configuration
  typecomponent _EditDialog;#		The dialog box
  foreach vdef $args {
    foreach {label name dt def opt} $vdef {break}
    set tc "_[join $name {}]"
    set wp [string tolower "[join $name {}]"]
    set an [join $name :]
    typecomponent $tc
    lappend arraydef $an $def
    append applyBody "\nset _Configuration($an) \[\$$tc cget -text\]"
    switch $dt {
      directory {
	append createDialogBody "\n\
	  set $tc \[FileEntry \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-filedialog directory \
		-title \{$label\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
        append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
      infile {
	append createDialogBody "\n\
	  set $tc \[FileEntry \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-filedialog open \
		-title \{$label\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
        append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
      outfile {
	append createDialogBody "\n\
	  set $tc \[FileEntry \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-filedialog save \
		-title \{$label\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
      }
      program {
	append createDialogBody "\n\
	  set $tc \[FileEntry \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-filedialog open \
		-title \{$label\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
        append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
      enumerated {
	append createDialogBody "\n\
	  set $tc \[LabelComboBox \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-editable no \
		-values \{$opt\}\] \n\
	  pack \$$tc -fill x\n\
	  \$$tc setvalue @\[lsearch -exact \{$opt\}\ \
				    \"\$_Configuration($an)\"\]"
        append updateBody "\n\
	  \$$tc setvalue @\[lsearch -exact \{$opt\}\ \
				    \"\$_Configuration($an)\"\]"
      }
      double {
	append createDialogBody "\n\
	  set $tc \[LabelSpinBox \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-range \{[lindex $opt 0] [lindex $opt 1] .1\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
        append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
      integer {
	append createDialogBody "\n\
	  set $tc \[LabelSpinBox \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-range \{[lindex $opt 0] [lindex $opt 1] 1\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
        append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
      color {
	append createDialogBody "\n\
	  set $tc \[LabelSelectColor \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
	append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
      boolean {
	append createDialogBody "\n\
	  set $tc \[LabelComboBox \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-editable no \
		-values \{true false\}\] \n\
	  pack \$$tc -fill x\n\
	  \$$tc setvalue @\[lsearch -exact \{true false\}\ \
				    \"\$_Configuration($an)\"\]"
        append updateBody "\n\
	  \$$tc setvalue @\[lsearch -exact \{true false\}\ \
				    \"\$_Configuration($an)\"\]"
      }
      default -
      string {
	append createDialogBody "\n\
	  set $tc \[LabelEntry \$frame.$wp \
		-labelwidth \$LabelWidth \
		-label \{$label\} \
		-text \"\$_Configuration($an)\"\] \n\
	  pack \$$tc -fill x"
        append updateBody "\n\
	  \$$tc configure -text \"\$_Configuration($an)\""
      }
    }    
  }
#  puts stderr "*** macro ReadConfiguration::ConfigurationType: arraydef = $arraydef"
  typevariable _Configuration -array $arraydef
  typevariable _ConfigurationFile
  typevariable LabelWidth 25;#	Label width
  typeconstructor {
    global tcl_platform
    global env
    global argv0
    switch $tcl_platform(platform) {
      windows {
	  set _ConfigurationFile \
		[file join $env(HOME) \
		      [string tolower \
			[file tail \
			   [file rootname \
			      "$argv0"]]].rc]
      }
      macintosh -
      unix {
	  set _ConfigurationFile \
		[file join $env(HOME) \
		    .[string tolower \
			[file tail \
			  [file rootname \
				"$argv0"]]]]
      }
    }
    set _EditDialog {}
  }
#  puts stderr "*** macro ReadConfiguration::ConfigurationType: updateBody = $updateBody"
  typemethod _UpdateDialog {} "$updateBody"
#  puts stderr "*** macro ReadConfiguration::ConfigurationType: createDialogBody = $createDialogBody"
  typemethod createDialog {} "$createDialogBody"
  typemethod load {} {
    ReadConfiguration::ReadConfiguration \
		"$_ConfigurationFile" \
		[mytypevar _Configuration]
  }
  typemethod save {} {
    ReadConfiguration::WriteConfiguration \
		"$_ConfigurationFile" \
		[mytypevar _Configuration]
  }
  typemethod edit {} {
    $type createDialog
    $type _UpdateDialog
    wm transient [winfo toplevel $_EditDialog] \
	   [$_EditDialog cget -parent]
    return [Dialog::draw $_EditDialog]
  }
  # typemethod bound to the OK button
  typemethod _OK {} {
    $type _Apply
    Dialog::withdraw $_EditDialog
    return [Dialog::enddialog $_EditDialog ok]
  }
  # typemethod bound to the Apply button
#  puts stderr "*** macro ReadConfiguration::ConfigurationType: applyBody = $applyBody"
  typemethod _Apply {} $applyBody
  # typemethod bound to the Cancel button
  typemethod _Cancel {} {
    Dialog::withdraw $_EditDialog
    return [Dialog::enddialog $_EditDialog cancel]
  }
  # type method to fetch a keyed option
  typemethod getkeyoption {name key} {
    if {[info exists _Configuration(${name}:${key})]} {
      return $_Configuration(${name}:${key})
    } else {
      error "No such keyed option: ${name}:${key}!"
    }
  }
  # type method to fetch a non-keyed option
  typemethod getoption {name} {
    if {[info exists _Configuration($name)]} {
      return $_Configuration($name)
    } else {
      error "No such option $name!"
    }
  }
  # type method to fetch anonoymous options
  typemethod getanonoymous {} {
    if {[info exists _Configuration(_Anonoymous_)]} {
      return $_Configuration(_Anonoymous_)
    } else {
      error "No Anonoymous options!"
    }
  }
}
        


package provide ReadConfiguration 1.0

