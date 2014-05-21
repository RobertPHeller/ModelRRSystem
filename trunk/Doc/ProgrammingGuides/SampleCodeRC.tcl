#* 
#* ------------------------------------------------------------------
#* SampleCodeRC.tcl - Sample Code -- RC files
#* Created by Robert Heller on Sat Oct 13 13:55:04 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/10/22 17:45:41  heller
#* Modification History: 10222007
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

package require ReadConfiguration;#	Load configuration code


namespace eval SampleCode::Configuration {
  # Create the configuration object.
  snit::type Configuration {
    ReadConfiguration::ConfigurationType \
      {{Scratch Folder} scratchfolder directory {~/.scratchfolder} {}} \
      {{Layout Name} {layout name} string {My Layout} {}} \
      {{Layout Scale} {layout scale} enumerated {H0} {Z N H0 0 G}} \
      {{Layout Width} {layout width} integer 96 {10 200}} \
      {{Layout Height} {layout height} integer 48 {10 200}} \
      {{Background Color} backgroundcolor color white {}}
  }
}

proc SampleCode::Configuration::SampleCodeRC {} {
  # Add menu items
  $::SampleCode::Main menu add options command \
	-label "Edit Configuration" \
	-command "::SampleCode::Configuration::Configuration edit"
  $::SampleCode::Main menu add options command \
	-label "Save Configuration" \
	-command "::SampleCode::Configuration::Configuration save"
  $::SampleCode::Main menu add options command \
	-label "Load Configuration" \
	-command "::SampleCode::Configuration::Configuration load"
}

package provide SampleCodeRC 1.0
