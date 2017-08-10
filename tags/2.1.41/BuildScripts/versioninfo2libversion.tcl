#!/usr/bin/tclsh

global argv argv argv0

if {[llength $argv] != 1} {
  puts stderr "usage: $argv0 version-info"
  exit 99
}

set vinfo [split [lindex $argv 0] {:}]
puts "[lindex $vinfo 0].[lindex $vinfo 2].[lindex $vinfo 1]"

