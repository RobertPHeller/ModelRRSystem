#!/usr/bin/tclsh

global argc argv argv0

if {$argc < 2} {
  puts stderr "usage: $argv0 dir DLL \[extra libs\]"
  exit 99
}

set dir "[lindex $argv 0]"
set dll "[lindex $argv 1]"
set extralibs [lrange $argv 2 end]

proc CreateCaughtLoad {lib} {
  return "catch \[list load \[file join \$dir $lib\]\]"
}

set cmd {}
foreach l $extralibs {
  append cmd "[CreateCaughtLoad $l];"
}

append cmd "load \[file join \$dir $dll\]"

puts stderr "*** '$cmd'"

if {[catch [eval $cmd] error]} {
  puts stderr "Error loading libs: $error"
  exit 98
}

set dllSpec [file join $dir $dll]
set pkg {}
foreach {f p} [info loaded] {
  if {[string equal "$f" "$dllSpec"]} {
    set pkg "$p"
    break
  }
}

if {[string length "$pkg"] == 0} {
  puts stderr "Could not load $dllSpec or $dllSpec has no Tcl_PkgProvide() or Tcl_PkgProvideEx() call."
  exit 97
}
  

if {[catch [list open [file join $dir pkgIndex.tcl] a] pfp]} {
  puts stderr "Could not open [file join $dir pkgIndex.tcl]: $pfp"
  exit 96
}


puts $pfp "package ifneeded $pkg [package present $pkg $cmds]"

close $pfp 


