#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Aug 4 19:41:54 2015
#  Last Modified : <150804.2158>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2015  Robert Heller D/B/A Deepwoods Software
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
#
# 
#
#*****************************************************************************


#*************************    
# command line arguments: BundleName Version Copyright
#*************************

if {$argc < 3} {
    puts stderr "usage: [file rootname [file tail [info script]]].kit BundleName Version Copyright"
    exit 99
}

set BundleName "[lindex $argv 0]"
set Version    "[lindex $argv 1]"
set Copyright  "[lindex $argv 2]"

set xmlfp [open "${BundleName}.plist" w]
puts $xmlfp {<?xml version="1.0" encoding="ISO-8859-1"?>}
puts $xmlfp {<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">}
puts $xmlfp {<plist version="1.0">}
puts $xmlfp {  <dict>}
puts $xmlfp {    <key>CFBundleName</key>}
puts $xmlfp "[format {    <string>%s</string>} $BundleName]"
puts $xmlfp {    <key>CFBundleDisplayName</key>}
puts $xmlfp "[format {    <string>%s</string>} $BundleName]"
puts $xmlfp {    <key>CFBundleIdentifier</key>}
puts $xmlfp "[format {    <string>com.deepsoft.%s</string>} $BundleName]"
puts $xmlfp {    <key>CFBundleVersion</key>}
puts $xmlfp "[format {    <string>%s</string>} $Version]"
puts $xmlfp {    <key>CFBundlePackageType</key>}
puts $xmlfp {    <string>APPL</string>}
puts $xmlfp {    <key>CFBundleExecutable</key>}
puts $xmlfp "[format {    <string>%s</string>} $BundleName]"
puts $xmlfp {    <key>CFBundleLongVersionString</key>}
puts $xmlfp "[format {    <string>Version %s</string>} $Version]"
puts $xmlfp {    <key>CFBundleShortVersionString</key>}
puts $xmlfp "[format {    <string>%s</string>} $Version]"
puts $xmlfp {    <key>CFBundleGetInfoString</key>}
puts $xmlfp "[format {    <string>%s Version %s</string>} $BundleName $Version]"
puts $xmlfp {    <key>CFBundleIconFile</key>}
puts $xmlfp "[format {    <string>%s</string>} $BundleName]"
puts $xmlfp {    <key>CFBundleInfoDictionaryVersion</key>}
puts $xmlfp {    <string>6.0</string>}
puts $xmlfp {    <key>NSHumanReadableCopyright</key>}
puts $xmlfp "[format {    <string>Copyright %s</string>} $Copyright]"
puts $xmlfp {  </dict>}
puts $xmlfp {</plist>}
close $xmlfp


    
