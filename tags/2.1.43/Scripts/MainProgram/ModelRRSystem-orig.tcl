#!/usr/bin/wish
# Program: ModelRRSystem
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

global SrcDir
# Global containing the source directory.
# [index] SrcDir!global

set SrcDir [file dirname [info script]]
if {[string compare "$SrcDir" {.}] == 0} {set SrcDir [pwd]}

global CommonSrcDir
# Global containing the Common source directory.
# [index] CommonSrcDir!global

set CommonSrcDir [file join [file dirname $SrcDir] Common]

global BinLibDir
# Global containing the binary library directory.
# [index] BinLibDir!global

set BinLibDir [file join [file dirname [file dirname $SrcDir]] Lib]

global env
set env(LD_LIBRARY_PATH) $BinLibDir

lappend auto_path $CommonSrcDir $SrcDir $BinLibDir

package require StdMenuBar 1.0

package require Mrr 2.1

image create photo banner -file [file join $SrcDir banner.gif]
# Image used as a banner for all dialog boxes.
# [index] banner!image

image create photo DeepwoodsBanner -format gif -file [file join $SrcDir DeepwoodsBanner.gif]
# Deepwoods banner image.  Used in the splash screen.
# [index] DeepwoodsBanner!image


global SubProcesses
catch {unset SubProcesses}


proc SplashScreen {} {
  # Build the ``Splash Screen'' -- A popup window that tells the user what 
  # we are all about.  It gives the version and brief copyright information.
  #
  # The upper part of the splash screen gives the brief information, with
  # directions on how to get detailed information.  The lower part contains
  # an image banner for Deepwoods Software.
  # [index] SplashScreen!procedure

  #global help_tips
  # build widget .mrrSplash
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .mrrSplash"
  } {
    catch "destroy .mrrSplash"
  }
  toplevel .mrrSplash 

  # Window manager configurations
  wm positionfrom .mrrSplash program
  wm sizefrom .mrrSplash program
  wm resizable .mrrSplash 0 0
  wm geometry .mrrSplash "+[expr ([winfo screenwidth .] / 2) - 254]+[expr ([winfo screenheight .] / 2) - 92]"
  wm title .mrrSplash {Model Railroad Timetable Chart Program V0.1}
  wm overrideredirect .mrrSplash 1

  bind .mrrSplash <1> {
      if {"[info procs XFEdit]" != ""} {
        catch "XFDestroy .mrrSplash"
      } {
        catch "destroy .mrrSplash"
      }
    }
  #enable_balloon .mrrSplash
  #set help_tips(.mrrSplash) {Click anywhere to dismiss splash window.}

  # build widget .mrrSplash.frame0
  frame .mrrSplash.frame0 \
    -background {#2ba2bf} -relief ridge -borderwidth 5

  # build widget .mrrSplash.frame0.frame1
  frame .mrrSplash.frame0.frame1 \
    -background {#2ba2bf}

  # build widget .mrrSplash.frame0.frame1.label4
  label .mrrSplash.frame0.frame1.label4 \
    -background {#2ba2bf} \
    -image banner

  # build widget .mrrSplash.frame0.frame1.message5
  message .mrrSplash.frame0.frame1.message5 \
    -background {#2ba2bf} \
    -foreground {white} \
    -aspect {800} \
    -font {-adobe-times-medium-r-*-*-*-100-*-*-*-*-*-*} \
    -padx {5} \
    -pady {2} \
    -text {Model Railroad Timetable Chart Program 0.1, Copyright (C) 2002 Robert Heller D/B/A Deepwoods Software Model Railroad Timetable Chart Program comes with ABSOLUTELY NO WARRANTY; for details select 'Warranty...' under the Help menu.  This is free software, and you are welcome to redistribute it under certain conditions; select 'Copying...' under the Help menu.}

  # build widget .mrrSplash.frame0.frame2
  frame .mrrSplash.frame0.frame2 \
    -background {#2ba2bf}

  # build widget .mrrSplash.frame0.frame2.label3
  label .mrrSplash.frame0.frame2.label3 \
    -background {#2ba2bf} \
    -image {DeepwoodsBanner}

  update
  wm withdraw .mrrSplash
  set bwidth [winfo reqwidth .mrrSplash.frame0.frame2.label3]
  set iwidth [winfo reqwidth .mrrSplash.frame0.frame1.label4]
  set mwidth [expr $bwidth - $iwidth]
  .mrrSplash.frame0.frame1.message5 configure -width $mwidth

  # pack master .mrrSplash.frame0.frame1
  pack configure .mrrSplash.frame0.frame1.label4 \
    -side left
  pack configure .mrrSplash.frame0.frame1.message5 \
    -side right

  # pack master .mrrSplash.frame0.frame2
  pack configure .mrrSplash.frame0.frame2.label3

  # pack master .mrrSplash.frame0
  pack configure .mrrSplash.frame0.frame1 \
    -fill y
  pack configure .mrrSplash.frame0.frame2 \
    -fill x
# end of widget tree

  # pack master .mrrSplash
  pack configure .mrrSplash.frame0

  wm deiconify .mrrSplash
}

SplashScreen

update

after 60000 {catch [list destroy .mrrSplash]}


catch [list source ~/.wishrc]

set pIndex 0

array set DefaultPrograms [list \
  {MRR CAD} [list {/usr/local/bin/xtrkcad} @[file join $SrcDir xtc64.xbm] {Foreign} ] \
  {Time Table} [list [file join [file dirname $SrcDir] TimeTable/mrrTimeTable.tcl] \
		      @[file join $SrcDir TimeTable.xbm] \
		      {MrrTcl} ] \
  {Any Distance Camera} [list [file join [file dirname $SrcDir] CameraScripts/AnyDistance.tcl] \
		      @[file join $SrcDir AnyDistance.xbm] \
		      {MrrTcl} ] \
  {Closest Distance Camera} [list [file join [file dirname $SrcDir] CameraScripts/Closest.tcl] \
		      @[file join $SrcDir Closest.xbm] \
		      {MrrTcl} ] \
  {Resistor Calculator} [list [file join [file dirname $SrcDir] CalcScripts/Resistor.tcl] \
				@[file join $SrcDir resistor.xbm] \
				{MrrTcl} ] \
]

foreach pTitle [array names DefaultPrograms] {
#  puts stderr "*** pTitle = '$pTitle'"
  if {[catch [list set "DefaultPrograms($pTitle)"] pValues] == 0} {
#    puts stderr "*** pValues (no error) = \{$pValues\}"
    set pPath "[lindex $pValues 0]"
    set pBitmap "[lindex $pValues 1]"
    set pFlags "[lindex $pValues 2]"
    incr pIndex
    set OptionBaseName "[format {*mrrProgram%%s%d} $pIndex]"
    option add [format "$OptionBaseName" Title] "$pTitle"
    option add [format "$OptionBaseName" Path] "$pPath"
    option add [format "$OptionBaseName" Bitmap] "$pBitmap"
    option add [format "$OptionBaseName" Flags] "$pFlags"
  } else {
    puts stderr "*** pValues (error) = \{$pValues\}"
  }
}

option add {*mrrProgramCount} $pIndex

catch [list option readfile ~/.mrrSystemRc]

global ProgramMenu
# Global containing the program list menu
# [index] ProgramMenu!global

set ProgramMenu {}

proc RunAProgram {} {
  global ProgramMenu

  if {[string length "$ProgramMenu"] == 0} {
    set programCount [option get . mrrProgramCount MrrProgramCount]
    set ProgramMenu [menu .programMenu -tearoff 0 -type normal]
    for {set i 1} {$i <= $programCount} {incr i} {
      set pTitle  "[option get . mrrProgramTitle$i MrrProgramTitle$i]"
      set pPath   "[option get . mrrProgramPath$i MrrProgramPath$i]"
      set pBitmap "[option get . mrrProgramBitmap$i MrrProgramBitmap$i]"
      set pFlags  "[option get . mrrProgramFlags$i MrrProgramFlags$i]"
      $ProgramMenu add command -label "$pTitle" -command [list RunProgram "$pPath" "$pBitmap" "$pFlags"]
    }
  }

  $ProgramMenu post [winfo pointerx .] [winfo pointery .]
  
}

proc RunProgram {execPath {bm {}} {flags {}}} {
  global SubProcesses

  switch -exact -- "$flags" {
    MrrTcl {
      set LogSockets [tcl_socketpair]
      set CtrlSockets [tcl_socketpair]
      set logFp   [lindex $LogSockets 0]
      set ctrlFp  [lindex $CtrlSockets 0]
      fconfigure $logFp -buffering line
      fconfigure $ctrlFp -buffering line
      set winlab  [AddContainer $logFp .iconFrame.ifouter.ifinner.iconCanvas $execPath]
      set wlab    [lindex $winlab 0]
      set window  [lindex $winlab 1]
      set winId   [winfo id $window]
      set pipePid [exec $execPath -use $winId -isslave <@ [lindex $CtrlSockets 1] >@ [lindex $LogSockets 1] &]
      fileevent $logFp readable "LogProgramOutput $logFp"
      set SubProcesses($logFp) [list $wlab $pipePid $ctrlFp [lindex $CtrlSockets 1] [lindex $LogSockets 1]]
      #puts stderr "*** RunProgram (MrrTcl): logFp = $logFp, SubProcesses($logFp) = $SubProcesses($logFp)"
    }
    Foreign -
    default {

      if {[catch [list open "|$execPath" r] logFp]} {
        tk_messageBox -icon error -default ok -type ok \
		  -title "Error running program $execPath" \
		  -message "Error: RunProgram: $execPath: $logFp" -parent .
        return
      }
      fileevent $logFp readable "LogProgramOutput $logFp"
      set pipePid [pid $logFp]
      set SubProcesses($logFp) [list \
        [AddIcon $logFp .iconFrame.ifouter.ifinner.iconCanvas $execPath $bm] \
        $pipePid \
	{}
      ]
    }
  }
}

proc RemoveIcon {canvas iconLab} {
  #puts stderr "*** RemoveIcon $canvas $iconLab"
  $canvas delete $iconLab
  set usedBBox [$canvas  bbox all]
  if {[llength $usedBBox] == 0} {
    set usedBBox [list 0 0 [winfo reqwidth $canvas] [winfo reqheight $canvas]]
  }
  set currentSR [$canvas cget -scrollregion]
  #puts stderr "*** -: usedBBox = $usedBBox, currentSR = $currentSR"
  set updateSR 0
  if {[lindex $usedBBox 0] < [lindex $currentSR 0]} {
    set currentSR [lreplace $currentSR 0 0 [lindex $usedBBox 0]]
    incr updateSR
  }
  if {[lindex $usedBBox 1] < [lindex $currentSR 1]} {
    set currentSR [lreplace $currentSR 1 1 [lindex $usedBBox 1]]
    incr updateSR
  }
  if {[lindex $usedBBox 2] > [lindex $currentSR 2]} {
    set currentSR [lreplace $currentSR 2 2 [lindex $usedBBox 2]]
    incr updateSR
  }
  if {[lindex $usedBBox 3] > [lindex $currentSR 3]} {
    set currentSR [lreplace $currentSR 3 3 [lindex $usedBBox 3]]
    incr updateSR
  }
  if {$updateSR > 0} {
    $canvas configure -scrollregion $currentSR
  }
}

global IconCounter
set IconCounter 0

proc AddIcon {key canvas text {bm {}}} {
  set i [$canvas create text 0 0 -anchor nw -text "$text"]
  set bb [$canvas bbox $i]
  $canvas delete $i
  set dy [expr int([lindex $bb 3]+.9) + 72]
  set dx [expr int([lindex $bb 2]+.9)]
  if {$dx < 72} {set dx 72}
  for {set y 5} {$y < 1000} {incr y $dy} {
    for {set x 5} {$x < 1000} {incr x $dy} {
      set occupued [expr [llength \
			  [$canvas find overlapping $x $y \
				   [expr $x + $dx] [expr $y + $dy]]] > 0]
      if {! $occupued } break
    }
    if {! $occupued } break
  }
  global IconCounter
  incr IconCounter
  if {[string length "$bm"] > 0} {
    $canvas create bitmap [expr $x + ($dx / 2.0)] $y -anchor n -bitmap "$bm" -tag I$IconCounter
    incr y 68
  }
  $canvas create text [expr $x  + ($dx / 2.0)] $y -anchor n -text "$text" -tag I$IconCounter
  set bbox [$canvas bbox I$IconCounter]
  $canvas lower [$canvas create rectangle [expr [lindex $bbox 0] - 1] \
                                     [expr [lindex $bbox 1] - 1] \
                                     [expr [lindex $bbox 2] + 1] \
                                     [expr [lindex $bbox 3] + 1] \
			  -tag I$IconCounter \
			  -fill grey75]  
  $canvas bind I$IconCounter <1> "IconInfo $key"
  $canvas bind I$IconCounter <3> "MoveWindowOrIcon $key"

  set usedBBox [$canvas  bbox all]
  set currentSR [$canvas cget -scrollregion]
  set updateSR 0
  if {[lindex $usedBBox 0] < [lindex $currentSR 0]} {
    set currentSR [lreplace $currentSR 0 0 [lindex $usedBBox 0]]
    incr updateSR
  }
  if {[lindex $usedBBox 1] < [lindex $currentSR 1]} {
    set currentSR [lreplace $currentSR 1 1 [lindex $usedBBox 1]]
    incr updateSR
  }
  if {[lindex $usedBBox 2] > [lindex $currentSR 2]} {
    set currentSR [lreplace $currentSR 2 2 [lindex $usedBBox 2]]
    incr updateSR
  }
  if {[lindex $usedBBox 3] > [lindex $currentSR 3]} {
    set currentSR [lreplace $currentSR 3 3 [lindex $usedBBox 3]]
    incr updateSR
  }
  if {$updateSR > 0} {
    $canvas configure -scrollregion $currentSR
  }
  return I$IconCounter
}

global ContainerCounter
# Global to hold container counter.
# [index] ContainerCounter!global

set ContainerCounter 0

proc AddContainer {key canvas text} {
  global ContainerCounter SrcDir
  incr ContainerCounter
  set outer [frame $canvas.outer$ContainerCounter -borderwidth 8 -relief ridge]
  set i [$canvas create text 0 0 -anchor nw -text "$text"]
  set bb [$canvas bbox $i]
  $canvas delete $i
  set dy [expr int([lindex $bb 3]+.9) + 72]
  set dx [expr int([lindex $bb 2]+.9)]
  if {$dx < 72} {set dx 72}
  for {set y 5} {$y < 1000} {incr y $dy} {
    for {set x 5} {$x < 1000} {incr x $dy} {
      set occupued [expr [llength \
			  [$canvas find overlapping $x $y \
				   [expr $x + $dx] [expr $y + $dy]]] > 0]
      if {! $occupued } break
    }
    if {! $occupued } break
  }
  $canvas create window $x $y -anchor nw -window $outer -tag "W$ContainerCounter"
  bind $outer <Configure> [list PropagateGeometry $canvas]
  frame $outer.tbar -borderwidth 1 -relief flat
  pack $outer.tbar -fill x -side top
  menubutton $outer.tbar.sysmenu -bitmap @[file join $SrcDir menu.xbm] \
				 -menu $outer.tbar.sysmenu.m -relief raised
  pack $outer.tbar.sysmenu -side left
  menu $outer.tbar.sysmenu.m -type normal -tearoff 0
  $outer.tbar.sysmenu.m add command -label {Restore} -underline 0 \
				    -command [list RestoreProcess "$key"]
  $outer.tbar.sysmenu.m add command -label {Move} -underline 0 \
				    -command [list MoveWindowOrIcon "$key"]
  $outer.tbar.sysmenu.m add command -label {Minimize} -underline 2 \
				    -command [list MinimizeProcess "$key"]
  $outer.tbar.sysmenu.m add separator
  $outer.tbar.sysmenu.m add command -label {Kill} -underline 0 \
				    -command [list KillSubprocess "$key"]
  button $outer.tbar.title -text "$text" -command [list IconInfo "$key"]
  pack $outer.tbar.title -side left -expand 1 -fill x
  button $outer.tbar.icon -bitmap @[file join $SrcDir dot.xbm]  \
			  -command [list MinimizeProcess "$key"]
  pack $outer.tbar.icon -side right
  frame $outer.body -container 1
  pack $outer.body -expand 1 -fill both -side top
  set usedBBox [$canvas  bbox all]
  set currentSR [$canvas cget -scrollregion]
  set updateSR 0
  if {[lindex $usedBBox 0] < [lindex $currentSR 0]} {
    set currentSR [lreplace $currentSR 0 0 [lindex $usedBBox 0]]
    incr updateSR
  }
  if {[lindex $usedBBox 1] < [lindex $currentSR 1]} {
    set currentSR [lreplace $currentSR 1 1 [lindex $usedBBox 1]]
    incr updateSR
  }
  if {[lindex $usedBBox 2] > [lindex $currentSR 2]} {
    set currentSR [lreplace $currentSR 2 2 [lindex $usedBBox 2]]
    incr updateSR
  }
  if {[lindex $usedBBox 3] > [lindex $currentSR 3]} {
    set currentSR [lreplace $currentSR 3 3 [lindex $usedBBox 3]]
    incr updateSR
  }
  if {$updateSR > 0} {
    $canvas configure -scrollregion $currentSR
  }
  return [list "W$ContainerCounter" $outer.body]  
} 

proc IconInfo {fp} {
  global SubProcesses

  if {[catch [list set SubProcesses($fp)] spinfo]} {return}
  .textFrame.textArea insert end "$spinfo\n"
}

proc MoveWindowOrIcon {fp} {
  global SubProcesses

  if {[catch [list set SubProcesses($fp)] spinfo]} {return}
  set canvas .iconFrame.ifouter.ifinner.iconCanvas
  set tag [lindex $spinfo 0]
  global MoveWindowOrIcon_State
  set MoveWindowOrIcon_State(done) 0
  set MoveWindowOrIcon_State(tag) $tag
  set coords [$canvas coords $tag]
  set MoveWindowOrIcon_State(OrgX) [lindex $coords 0] 
  set MoveWindowOrIcon_State(OrgY) [lindex $coords 1]
  set MoveWindowOrIcon_State(StartX) {}
  set MoveWindowOrIcon_State(StartY) {}
  set MoveWindowOrIcon_State(CurX) $MoveWindowOrIcon_State(OrgX)
  set MoveWindowOrIcon_State(CurY) $MoveWindowOrIcon_State(OrgY)
  set MoveWindowOrIcon_State(BBox) [$canvas bbox $tag]
  bind $canvas <ButtonPress-1>   {MoveWindowOrIcon_Start %W %x %y}
  bind $canvas <Button1-Motion>  {MoveWindowOrIcon_Move %W %x %y}
  bind $canvas <ButtonRelease-1> {MoveWindowOrIcon_Finish %W %x %y}
  tkwait variable MoveWindowOrIcon_State(done)
  bind $canvas <ButtonPress-1>   {}
  bind $canvas <Modion-1>        {}
  bind $canvas <ButtonRelease-1> {}
  unset MoveWindowOrIcon_State
}

proc MoveWindowOrIcon_Start {canvas mx my} {
  global MoveWindowOrIcon_State

  #puts stderr "*** MoveWindowOrIcon_Start $canvas $mx $my"
  set MoveWindowOrIcon_State(StartX) [$canvas canvasx $mx]
  set MoveWindowOrIcon_State(StartY) [$canvas canvasy $my]
  #puts stderr "*** -: MoveWindowOrIcon_State(StartX) $MoveWindowOrIcon_State(StartX)"
  #puts stderr "*** -: MoveWindowOrIcon_State(StartY) $MoveWindowOrIcon_State(StartY)"
  $canvas create rectangle [lindex $MoveWindowOrIcon_State(BBox) 0] \
			   [lindex $MoveWindowOrIcon_State(BBox) 1] \
			   [lindex $MoveWindowOrIcon_State(BBox) 2] \
			   [lindex $MoveWindowOrIcon_State(BBox) 3] \
			-fill {} -outline black -tag MotionShadow
}

proc MoveWindowOrIcon_Move {canvas mx my} {
  global MoveWindowOrIcon_State

  #puts stderr "*** MoveWindowOrIcon_Move $canvas $mx $my"
  set dx [expr [$canvas canvasx $mx] - $MoveWindowOrIcon_State(StartX)]
  set dy [expr [$canvas canvasy $my] - $MoveWindowOrIcon_State(StartY)]
  #puts stderr "*** -: dx = $dx, dy = $dy"
  set newX [expr $MoveWindowOrIcon_State(OrgX) + $dx]
  set newY [expr $MoveWindowOrIcon_State(OrgY) + $dy]
  set dxMS [expr $newX - $MoveWindowOrIcon_State(CurX)]
  set dyMS [expr $newY - $MoveWindowOrIcon_State(CurY)]
  set MoveWindowOrIcon_State(CurX) $newX
  set MoveWindowOrIcon_State(CurY) $newY
  $canvas move MotionShadow $dxMS $dyMS
}

proc MoveWindowOrIcon_Finish {canvas mx my} {
  global MoveWindowOrIcon_State

  set dx [expr [$canvas canvasx $mx] -$MoveWindowOrIcon_State(StartX)]
  set dy [expr [$canvas canvasy $my] - $MoveWindowOrIcon_State(StartY)]
  set MoveWindowOrIcon_State(CurX) [expr $MoveWindowOrIcon_State(OrgX) + $dx]
  set MoveWindowOrIcon_State(CurY) [expr $MoveWindowOrIcon_State(OrgY) + $dy]
  $canvas delete MotionShadow
  set dx [expr $MoveWindowOrIcon_State(CurX) - $MoveWindowOrIcon_State(OrgX)]
  set dy [expr $MoveWindowOrIcon_State(CurY) - $MoveWindowOrIcon_State(OrgY)]
  $canvas move $MoveWindowOrIcon_State(tag) $dx $dy
  incr MoveWindowOrIcon_State(done)
  PropagateGeometry $canvas
}

proc RestoreProcess {fp} {
  global SubProcesses

  if {[catch [list set SubProcesses($fp)] spinfo]} {return}
  set canvas .iconFrame.ifouter.ifinner.iconCanvas
  set tag [lindex $spinfo 0]
  set outer [$canvas itemcget $tag -window]
  pack $outer.body -expand 1 -fill both -side top
  $outer.tbar.icon configure -command [list MinimizeProcess "$fp"]
}

proc MinimizeProcess {fp} {
  global SubProcesses

  if {[catch [list set SubProcesses($fp)] spinfo]} {return}
  set canvas .iconFrame.ifouter.ifinner.iconCanvas
  set tag [lindex $spinfo 0]
  set outer [$canvas itemcget $tag -window]
  pack forget $outer.body
  $outer.tbar.icon configure -command [list RestoreProcess "$fp"]
}



proc KillSubprocess {fp} {
#  puts stderr "*** KillSubprocess $fp"
  global SubProcesses
  set spInfo $SubProcesses($fp)
  set ctrlFp "[lindex $spInfo 2]"
  puts $ctrlFp {201 Exit}
  flush $ctrlFp
}

proc LogProgramOutput {fp} {
  global SubProcesses
  #puts stderr "*** LogProgramOutput $fp"
  if {[gets $fp line] < 0} {
    #puts stderr "*** -: gets failed"
    close $fp
    set spInfo $SubProcesses($fp)
    unset SubProcesses($fp)
    RemoveIcon .iconFrame.ifouter.ifinner.iconCanvas [lindex $spInfo 0]
    set otherFps [lrange $spInfo 2 end]
    foreach fp $otherFps {catch [list close $fp]}
  } else {
    #puts stderr "*** -: '$line'"
    set spInfo $SubProcesses($fp)
    set ctrlFp "[lindex $spInfo 2]"
    if {[string length "$ctrlFp"] > 0 && [string compare {101 Exit} "$line"] == 0} {
      close $fp
      set spInfo $SubProcesses($fp)
      RemoveIcon .iconFrame.ifouter.ifinner.iconCanvas [lindex $spInfo 0]
      puts $ctrlFp "Bye"
      unset SubProcesses($fp)
      set otherFps [lrange $spInfo 2 end]
      foreach fp $otherFps {catch [list close $fp]}
    } elseif {[string length "$ctrlFp"] > 0 && [string compare {102 Withdraw} "$line"] == 0} {
      MinimizeProcess $fp
    } elseif {[string length "$ctrlFp"] > 0 && [string compare {103 Restore} "$line"] == 0} {
      RestoreProcess $fp
    } else {
      .textFrame.textArea insert end "$line\n"
    }
  }
}

proc PropagateGeometry {canvas} {
  #puts stderr "*** PropagateGeometry $canvas"
  set usedBBox [$canvas  bbox all]
  set currentSR [$canvas cget -scrollregion]
  #puts stderr "*** -: usedBBox = $usedBBox, currentSR = $currentSR"
  set updateSR 0
  if {[lindex $usedBBox 0] < [lindex $currentSR 0]} {
    set currentSR [lreplace $currentSR 0 0 [lindex $usedBBox 0]]
    incr updateSR
  }
  if {[lindex $usedBBox 1] < [lindex $currentSR 1]} {
    set currentSR [lreplace $currentSR 1 1 [lindex $usedBBox 1]]
    incr updateSR
  }
  if {[lindex $usedBBox 2] > [lindex $currentSR 2]} {
    set currentSR [lreplace $currentSR 2 2 [lindex $usedBBox 2]]
    incr updateSR
  }
  if {[lindex $usedBBox 3] > [lindex $currentSR 3]} {
    set currentSR [lreplace $currentSR 3 3 [lindex $usedBBox 3]]
    incr updateSR
  }
  if {$updateSR > 0} {
    $canvas configure -scrollregion $currentSR
  }
}  

proc UpdateScrollRegion {canvas height width} {
  #puts stderr "*** UpdateScrollRegion $canvas $height $width"
  set currentSR [$canvas cget -scrollregion]
  #puts stderr "*** -: currentSR = $currentSR"
  set updateSR 0
  if {$width > [lindex $currentSR 2]} {
    set currentSR [lreplace $currentSR 2 2 $width]
    incr updateSR
  }
  if {$height > [lindex $currentSR 3]} {
    set currentSR [lreplace $currentSR 3 3 $height]
    incr updateSR
  }
  if {$updateSR > 0} {
    $canvas configure -scrollregion $currentSR
  }
}    

# procedure to show window .
proc MainWindow {args} {# xf ignore me 7

  global SrcDir
  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1009 738
  wm minsize . 1 1
  wm protocol . WM_DELETE_WINDOW {CarefulExit}
  wm title . {Model Railroad System}


  MakeStandardMenuBar
  set fm [GetMenuByName File]
  $fm entryconfigure Exit -command {CarefulExit}
  $fm entryconfigure Close -command {CarefulExit}
  $fm entryconfigure Save  -state disabled
  $fm entryconfigure {Save As...}  -state disabled
  $fm entryconfigure New  -state disabled
  $fm entryconfigure {Open...}  -state disabled
  $fm entryconfigure {Print...}  -state disabled
  $fm add command  -label {Run Program} -command "RunAProgram"

  set em [GetMenuByName Edit]
  for {set i 0} {$i <= [$em index end]} {incr i} {
    $em entryconfigure $i -state disabled
  }

  set hm [GetMenuByName Help]
  for {set i 0} {$i <= [$hm index end]} {incr i} {
    $hm entryconfigure $i -state disabled
  }
  $hm entryconfigure {Warranty...} -state normal -command {HelpWarranty}
  $hm entryconfigure {Copying...} -state normal -command {HelpCopying}


  # build widget .iconFrame
  frame .iconFrame \
    -borderwidth {2}

  # build widget .iconFrame.ifouter
  frame .iconFrame.ifouter

  # build widget .iconFrame.ifouter.ifinner
  frame .iconFrame.ifouter.ifinner \
    -borderwidth {2}

  # build widget .iconFrame.ifouter.ifinner.iconCanvas
  canvas .iconFrame.ifouter.ifinner.iconCanvas \
    -relief {sunken} -borderwidth 2  \
    -xscrollcommand {.iconFrame.frame2.frame5.scrollbar10 set} \
    -yscrollcommand {.iconFrame.ifouter.frame4.scrollbar9 set}
  bind .iconFrame.ifouter.ifinner.iconCanvas <Configure> {UpdateScrollRegion %W %h %w}

  # build widget .iconFrame.ifouter.frame4
  frame .iconFrame.ifouter.frame4 \
    -borderwidth {2}

  # build widget .iconFrame.ifouter.frame4.scrollbar9
  scrollbar .iconFrame.ifouter.frame4.scrollbar9 \
    -command {.iconFrame.ifouter.ifinner.iconCanvas yview} \
    -width {13}

  # build widget .iconFrame.frame2
  frame .iconFrame.frame2 \
    -borderwidth {1}

  # build widget .iconFrame.frame2.frame5
  frame .iconFrame.frame2.frame5 \
    -borderwidth {2}

  # build widget .iconFrame.frame2.frame5.scrollbar10
  scrollbar .iconFrame.frame2.frame5.scrollbar10 \
    -command {.iconFrame.ifouter.ifinner.iconCanvas xview} \
    -orient {horizontal} \
    -width {13}

  # build widget .iconFrame.frame2.frame6
  frame .iconFrame.frame2.frame6 \
    -borderwidth {2}

  # build widget .iconFrame.frame2.frame6.frame11
  frame .iconFrame.frame2.frame6.frame11 \
    -borderwidth {2} \
    -height {13} \
    -width {16}

  # build widget .textFrame
  frame .textFrame \
    -relief {flat}

  # build widget .textFrame.scrollbar1
  scrollbar .textFrame.scrollbar1 \
    -command {.textFrame.textArea yview} \
    -relief {sunken}

  # build widget .textFrame.textArea
  text .textFrame.textArea \
    -relief {sunken} \
    -height {10}  \
    -wrap {word} \
    -yscrollcommand {.textFrame.scrollbar1 set}

  # pack master .textFrame
  pack configure .textFrame.scrollbar1 \
    -fill y \
    -side right
  pack configure .textFrame.textArea \
    -expand 1 \
    -fill both

  # pack master .iconFrame.ifouter
  pack configure .iconFrame.ifouter.ifinner \
    -expand 1 \
    -fill both \
    -side left
  pack configure .iconFrame.ifouter.frame4 \
    -fill y \
    -side right

  # pack master .iconFrame.ifouter.ifinner
  pack configure .iconFrame.ifouter.ifinner.iconCanvas \
    -expand 1 \
    -fill both \
    -side left

  # pack master .iconFrame.ifouter.frame4
  pack configure .iconFrame.ifouter.frame4.scrollbar9 \
    -expand 1 \
    -fill y

  # pack master .iconFrame.frame2
  pack configure .iconFrame.frame2.frame5 \
    -expand 1 \
    -fill both \
    -side left
  pack configure .iconFrame.frame2.frame6 \
    -fill y \
    -side right

  # pack master .iconFrame.frame2.frame5
  pack configure .iconFrame.frame2.frame5.scrollbar10 \
    -expand 1 \
    -fill x \
    -side left

  # pack master .iconFrame.frame2.frame6
  pack configure .iconFrame.frame2.frame6.frame11 \
    -expand 1 \
    -fill both

  # pack master .iconFrame
  pack configure .iconFrame.ifouter \
    -expand 1 \
    -fill both
  pack configure .iconFrame.frame2 \
    -fill x \
    -side bottom

  # pack slave .iconFrame
  pack configure .iconFrame \
    -expand 1 \
    -fill both

  # pack master .
  pack configure .iconFrame \
    -fill both
  pack configure .textFrame \
    -fill x

  .textFrame.textArea insert end {}



  if {"[info procs XFEdit]" != ""} {
    catch "XFMiscBindWidgetTree ."
    after 2 "catch {XFEditSetShowWindows}"
  }

  set w .
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  
  .iconFrame.ifouter.ifinner.iconCanvas configure -scrollregion \
	[list 0 0 \
	      [winfo reqwidth .iconFrame.ifouter.ifinner.iconCanvas] \
	      [winfo reqheight .iconFrame.ifouter.ifinner.iconCanvas]]
  wm deiconify $w
}

proc CarefulExit {} {
# Procedure to carefully exit.
# [index] CarefulExit!procedure

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Quit?} \
		-title {Careful Exit} -type yesno] {yes}] == 0} {exit}
}

proc HelpWarranty {} {
# Procedure to display Warranty information.
# [index] HelpWarranty!procedure

# .helpWarranty
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .helpWarranty
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .helpWarranty"
  } {
    catch "destroy .helpWarranty"
  }
  toplevel .helpWarranty 

  # Window manager configurations
  wm positionfrom .helpWarranty ""
  wm sizefrom .helpWarranty ""
  wm maxsize .helpWarranty 1000 768
  wm minsize .helpWarranty 10 10
  wm protocol .helpWarranty WM_DELETE_WINDOW {.helpWarranty.button15 invoke}
  wm title .helpWarranty {View Warranty}
  wm transient .helpWarranty .


  # build widget .helpWarranty.banner
  frame .helpWarranty.banner \
    -borderwidth {2}

  # build widget .helpWarranty.banner.label27
  label .helpWarranty.banner.label27 \
    -image {banner}

  # build widget .helpWarranty.banner.label28
  label .helpWarranty.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Warranty}

  # build widget .helpWarranty.frame
  frame .helpWarranty.frame \
    -relief {raised}

  # build widget .helpWarranty.frame.scrollbar1
  scrollbar .helpWarranty.frame.scrollbar1 \
    -command {.helpWarranty.frame.text2 yview}

  # build widget .helpWarranty.frame.text2
  text .helpWarranty.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.helpWarranty.frame.scrollbar1 set}
  # bindings
  bind .helpWarranty.frame.text2 <Key> {break}

  # build widget .helpWarranty.button15
  button .helpWarranty.button15 \
    -command {catch {destroy .helpWarranty}} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .helpWarranty.banner
  pack configure .helpWarranty.banner.label27 \
    -side left
  pack configure .helpWarranty.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .helpWarranty.frame
  pack configure .helpWarranty.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .helpWarranty.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .helpWarranty
  pack configure .helpWarranty.banner \
    -fill x
  pack configure .helpWarranty.frame \
    -expand 1 \
    -fill both
  pack configure .helpWarranty.button15 \
    -expand 1 \
    -fill x

  .helpWarranty.frame.text2 insert end {			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.
}

# end of widget tree

  set w .helpWarranty
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

}

proc HelpCopying {} {
# Procedure to display Copying information.
# [index] HelpCopying!procedure

# .helpCopying
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .helpCopying
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .helpCopying"
  } {
    catch "destroy .helpCopying"
  }
  toplevel .helpCopying 

  # Window manager configurations
  wm positionfrom .helpCopying ""
  wm sizefrom .helpCopying ""
  wm maxsize .helpCopying 1000 768
  wm minsize .helpCopying 10 10
  wm protocol .helpCopying WM_DELETE_WINDOW {.helpCopying.button15 invoke}
  wm title .helpCopying {View Copying}
  wm transient .helpCopying .


  # build widget .helpCopying.banner
  frame .helpCopying.banner \
    -borderwidth {2}

  # build widget .helpCopying.banner.label27
  label .helpCopying.banner.label27 \
    -image {banner}

  # build widget .helpCopying.banner.label28
  label .helpCopying.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {View Copying}

  # build widget .helpCopying.frame
  frame .helpCopying.frame \
    -relief {raised}

  # build widget .helpCopying.frame.scrollbar1
  scrollbar .helpCopying.frame.scrollbar1 \
    -command {.helpCopying.frame.text2 yview}

  # build widget .helpCopying.frame.text2
  text .helpCopying.frame.text2 \
    -wrap {word} \
    -yscrollcommand {.helpCopying.frame.scrollbar1 set}
  # bindings
  bind .helpCopying.frame.text2 <Key> {break}

  # build widget .helpCopying.button15
  button .helpCopying.button15 \
    -command {catch {destroy .helpCopying}} \
    -padx {9} \
    -pady {3} \
    -text {Dismiss}

  # pack master .helpCopying.banner
  pack configure .helpCopying.banner.label27 \
    -side left
  pack configure .helpCopying.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .helpCopying.frame
  pack configure .helpCopying.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .helpCopying.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .helpCopying
  pack configure .helpCopying.banner \
    -fill x
  pack configure .helpCopying.frame \
    -expand 1 \
    -fill both
  pack configure .helpCopying.button15 \
    -expand 1 \
    -fill x

  .helpCopying.frame.text2 insert end {		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
                          675 Mass Ave, Cambridge, MA 02139, USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

			    Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.




		    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)




These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.




  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.




  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

		     END OF TERMS AND CONDITIONS




	Appendix: How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
convey the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    [<one line to give the program's name and a brief idea of what it does.>]
    Copyright (C) 19yy  [<name of author>]

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this
when it starts in an interactive mode:

    Gnomovision version 69, Copyright (C) 19yy name of author
    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, the commands you use may
be called something other than `show w' and `show c'; they could even be
mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your
school, if any, to sign a "copyright disclaimer" for the program, if
necessary.  Here is a sample; alter the names:

  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
  `Gnomovision' (which makes passes at compilers) written by James Hacker.

  [<signature of Ty Coon>], 1 April 1989
  Ty Coon, President of Vice

This General Public License does not permit incorporating your program into
proprietary programs.  If your program is a subroutine library, you may
consider it more useful to permit linking proprietary applications with the
library.  If this is what you want to do, use the GNU Library General
Public License instead of this License.
}

# end of widget tree

  set w .helpCopying
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w

}

MainWindow
raise .mrrSplash .

