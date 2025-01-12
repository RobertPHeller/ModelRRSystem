#* 
#* ------------------------------------------------------------------
#* IconFrame.tcl - Icon Frame (chessy window manager)
#* Created by Robert Heller on Tue Apr 22 21:43:10 2008
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
#*  $Id$
#* 

catch {ModelRRSystem::SplashWorkMessage "Loading Icon Frame Code" 50}

package require gettext
package require Tk
package require tile
package require snit
package require IconImage

namespace eval ModelRRSystem {
  snit::widgetadaptor IconFrame {
    option -logtext -default {}
    option -toolbaradd -default {}
    delegate option * to hull except {-confine -scrollregion -state}
    delegate method xview to hull
    delegate method yview to hull
    
    component programMenu

    constructor {args} {
      installhull using canvas -scrollregion {0 0 0 0}
      $self configurelist $args
      bind $win <Configure> [mymethod updatescrollregion %h %w]
      catch [list option readfile ~/.mrrSystemRc]
      install programMenu using menu $win.programMenu -tearoff 0
      set programCount [option get [winfo toplevel $win] mrrProgramCount MrrProgramCount]
      for {set i 1} {$i <= $programCount} {incr i} {
	set pTitle  "[option get [winfo toplevel $win] mrrProgramTitle$i MrrProgramTitle$i]"
	set pPath   "[option get [winfo toplevel $win] mrrProgramPath$i MrrProgramPath$i]"
	set pBitmap "[option get [winfo toplevel $win] mrrProgramBitmap$i MrrProgramBitmap$i]"
	set pFlags  "[option get [winfo toplevel $win] mrrProgramFlags$i MrrProgramFlags$i]"
	$programMenu add command -label "$pTitle" \
				 -command [mymethod runprogram "$pPath" "$pBitmap" "$pFlags"]
        if {[string length "$options(-toolbaradd)"] > 0} {
	  set name [$self titletoname "$pTitle"]
	  eval $options(-toolbaradd) [list $name -image [IconImage image "$pBitmap" -filetype xbm -icondir $::ImageDir] \
		-command  [mymethod runprogram "$pPath" "$pBitmap" "$pFlags"]]
	}
      }
    }
    method titletoname {title} {
      regsub -all {[[:space:]]} "$title" {} name
      return [string tolower "$name" 0 0]
    }
    method updatescrollregion {height width} {
#      puts stderr "*** $self UpdateScrollRegion $height $width"
      set currentSR [$hull cget -scrollregion]
#      puts stderr "*** -: currentSR = $currentSR"
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
	$hull configure -scrollregion $currentSR
      }
    }
    method runaprogram {} {
      $programMenu post [winfo pointerx [winfo toplevel $win]] \
			[winfo pointery [winfo toplevel $win]]
    }
    variable SubProcesses -array {}
    method runprogram {execPath {bm {}} {flags {}}} {
      switch -exact -- "$flags" {
	MrrTcl {
	  set LogSockets [tcl_socketpair]
	  # puts stderr "*** $self runprogram: LogSockets = $LogSockets"
	  set CtrlSockets [tcl_socketpair]
	  # puts stderr "*** $self runprogram: CtrlSockets = $CtrlSockets"
	  set logFp   [lindex $LogSockets 0]
	  set ctrlFp  [lindex $CtrlSockets 0]
	  # puts stderr "*** $self runprogram: logFp = $logFp, ctrlFp = $ctrlFp"
	  fconfigure $logFp -buffering line
	  fconfigure $ctrlFp -buffering line
	  set winlab  [$self addcontainer $logFp $execPath]
	  set wlab    [lindex $winlab 0]
	  set window  [lindex $winlab 1]
	  set winId   [winfo id $window]
	  set pipePid [exec $execPath -use $winId -isslave <@ [lindex $CtrlSockets 1] >@ [lindex $LogSockets 1] &]
	  set SubProcesses($logFp) [list $wlab $pipePid $ctrlFp [lindex $CtrlSockets 1] [lindex $LogSockets 1]]
	  fileevent $logFp readable [mymethod logprogramoutput $logFp]
	  #puts stderr "*** RunProgram (MrrTcl): logFp = $logFp, SubProcesses($logFp) = $SubProcesses($logFp)"
	}
	Foreign -
	default {
	  if {[catch [list open "|$execPath" r] logFp]} {
	    tk_messageBox -icon error -default ok -type ok \
		  -title "Error running program $execPath" \
		  -message "Error: $self runprogram: $execPath: $logFp" -parent $win
	    return
	  }
	  set pipePid [pid $logFp]
	  set SubProcesses($logFp) [list \
			[$self addicon $logFp $execPath $bm] \
			$pipePid {}]
	  fileevent $logFp readable [mymethod logprogramoutput $logFp]
	}
      }
    }
    method removeicon {iconLab} {
      $hull delete $iconLab
      set usedBBox [$hull  bbox all]
      if {[llength $usedBBox] == 0} {
        set usedBBox [list 0 0 [winfo reqwidth $win] [winfo reqheight $win]]
      }
      set currentSR [$hull cget -scrollregion]
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
	$hull configure -scrollregion $currentSR
      }
    }
    variable IconCounter 0
    method addicon {key text {bm {}}} {
      set i [$hull create text 0 0 -anchor nw -text "$text"]
      set bb [$hull bbox $i]
      $hull delete $i
      set dy [expr {int([lindex $bb 3]+.9) + 72}]
      set dx [expr {int([lindex $bb 2]+.9)}]
      if {$dx < 72} {set dx 72}
      for {set y 5} {$y < 1000} {incr y $dy} {
	for {set x 5} {$x < 1000} {incr x $dy} {
	  set occupied [expr {[llength \
			  [$hull find overlapping $x $y \
				   [expr {$x + $dx}] [expr {$y + $dy}]]] > 0}]
	  if {! $occupied } break
	}
	if {! $occupied } break
      }
      incr IconCounter
      if {[string length "$bm"] > 0} {
        $hull create bitmap [expr {$x + ($dx / 2.0)}] $y -anchor n -bitmap [IconBitmap insert "$bm" -icondir $::ImageDir] -tag I$IconCounter
	incr y 68
      }
      $hull create text [expr {$x  + ($dx / 2.0)}] $y -anchor n -text "$text" -tag I$IconCounter
      set bbox [$hull bbox I$IconCounter]
      $hull lower [$hull create rectangle [expr [lindex $bbox 0] - 1] \
                                     [expr [lindex $bbox 1] - 1] \
                                     [expr [lindex $bbox 2] + 1] \
                                     [expr [lindex $bbox 3] + 1] \
			  -tag I$IconCounter \
			  -fill grey75]  
      $hull bind I$IconCounter <1> [mymethod iconinfo $key]
      $hull bind I$IconCounter <3> [mymethod movewindoworicon $key]

      set usedBBox [$hull  bbox all]
      set currentSR [$hull cget -scrollregion]
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
	$hull configure -scrollregion $currentSR
      }
      return I$IconCounter
    }
    variable ContainerCounter 0
    method addcontainer {key text} {
      global ImageDir
      incr ContainerCounter
      set outer [frame $win.outer$ContainerCounter -borderwidth 8 -relief ridge]
      set i [$hull create text 0 0 -anchor nw -text "$text"]
      set bb [$hull bbox $i]
      $hull delete $i
      set dy [expr {int([lindex $bb 3]+.9) + 72}]
      set dx [expr {int([lindex $bb 2]+.9)}]
      if {$dx < 72} {set dx 72}
      for {set y 5} {$y < 1000} {incr y $dy} {
	for {set x 5} {$x < 1000} {incr x $dy} {
	  set occupied [expr {[llength \
			  [$hull find overlapping $x $y \
				   [expr {$x + $dx}] [expr {$y + $dy}]]] > 0}]
	  if {! $occupied } break
	}
	if {! $occupied } break
      }
      $hull create window $x $y -anchor nw -window $outer -tag "W$ContainerCounter"
      bind $outer <Configure> [mymethod propagategeometry]
      frame $outer.tbar -borderwidth 1 -relief flat
      pack $outer.tbar -fill x -side top
      menubutton $outer.tbar.sysmenu -bitmap @[file join $ImageDir menu.xbm] \
			 -menu $outer.tbar.sysmenu.m -relief raised
      pack $outer.tbar.sysmenu -side left
      menu $outer.tbar.sysmenu.m -type normal -tearoff 0
      $outer.tbar.sysmenu.m add command -label {Restore} -underline 0 \
			    -command [mymethod restoreprocess "$key"]
      $outer.tbar.sysmenu.m add command -label {Move} -underline 0 \
			    -command [mymethod movewindoworicon "$key"]
      $outer.tbar.sysmenu.m add command -label {Minimize} -underline 2 \
				    -command [mymethod minimizeprocess "$key"]
      $outer.tbar.sysmenu.m add separator
      $outer.tbar.sysmenu.m add command -label {Kill} -underline 0 \
				    -command [mymethod killsubprocess "$key"]
      button $outer.tbar.title -text "$text" -command [mymethod iconinfo "$key"]
      pack $outer.tbar.title -side left -expand 1 -fill x
      button $outer.tbar.icon -bitmap @[file join $ImageDir dot.xbm]  \
		  -command [mymethod minimizeprocess "$key"]
      pack $outer.tbar.icon -side right
      frame $outer.body -container 1
      pack $outer.body -expand 1 -fill both -side top
      set usedBBox [$hull  bbox all]
      set currentSR [$hull cget -scrollregion]
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
	$hull configure -scrollregion $currentSR
      }
      return [list "W$ContainerCounter" $outer.body]  
    }
    method iconinfo {fp} {
      #puts stderr "$self iconinfo $fp"
      if {[catch [list set SubProcesses($fp)] spinfo]} {return}
      #puts stderr "$self iconinfo: $spinfo"
      catch {$options(-logtext) insert end "$spinfo\n"}
    }
    variable MoveWindowOrIcon_State
    method movewindoworicon {fp} {
#      puts stderr "$self movewindoworicon $fp"
      if {[catch [list set SubProcesses($fp)] spinfo]} {return}
      set tag [lindex $spinfo 0]
      set MoveWindowOrIcon_State(done) 0
      set MoveWindowOrIcon_State(tag) $tag
      set coords [$hull coords $tag]
      set MoveWindowOrIcon_State(OrgX) [lindex $coords 0] 
      set MoveWindowOrIcon_State(OrgY) [lindex $coords 1]
      set MoveWindowOrIcon_State(StartX) {}
      set MoveWindowOrIcon_State(StartY) {}
      set MoveWindowOrIcon_State(CurX) $MoveWindowOrIcon_State(OrgX)
      set MoveWindowOrIcon_State(CurY) $MoveWindowOrIcon_State(OrgY)
      set MoveWindowOrIcon_State(BBox) [$hull bbox $tag]
      bind $win <ButtonPress-1>   [mymethod movewindoworicon_start %x %y]
      bind $win <Button1-Motion>  [mymethod movewindoworicon_move %x %y]
      bind $win <ButtonRelease-1> [mymethod movewindoworicon_finish %x %y]
      tkwait variable [myvar MoveWindowOrIcon_State(done)]
      bind $win <ButtonPress-1>   {}
      bind $win <Button1-Motion>  {}
      bind $win <ButtonRelease-1> {}
      $hull delete MotionShadow
      array unset MoveWindowOrIcon_State
#      puts stderr "$self movewindoworicon: bindings on $win: [bind $win]"
    }
    method movewindoworicon_start {mx my} {
#      puts stderr "*** $self movewindoworicon_start $mx $my"
      set MoveWindowOrIcon_State(StartX) [$hull canvasx $mx]
      set MoveWindowOrIcon_State(StartY) [$hull canvasy $my]
#      puts stderr "*** -: MoveWindowOrIcon_State(StartX) $MoveWindowOrIcon_State(StartX)"
#      puts stderr "*** -: MoveWindowOrIcon_State(StartY) $MoveWindowOrIcon_State(StartY)"
      $hull create rectangle [lindex $MoveWindowOrIcon_State(BBox) 0] \
			   [lindex $MoveWindowOrIcon_State(BBox) 1] \
			   [lindex $MoveWindowOrIcon_State(BBox) 2] \
			   [lindex $MoveWindowOrIcon_State(BBox) 3] \
			-fill {} -outline black -tag MotionShadow
    }
    method movewindoworicon_move {mx my} {
#      puts stderr "*** $self movewindoworicon_move $mx $my"
      set dx [expr [$hull canvasx $mx] - $MoveWindowOrIcon_State(StartX)]
      set dy [expr [$hull canvasy $my] - $MoveWindowOrIcon_State(StartY)]
#      puts stderr "*** -: dx = $dx, dy = $dy"
      set newX [expr $MoveWindowOrIcon_State(OrgX) + $dx]
      set newY [expr $MoveWindowOrIcon_State(OrgY) + $dy]
      set dxMS [expr $newX - $MoveWindowOrIcon_State(CurX)]
      set dyMS [expr $newY - $MoveWindowOrIcon_State(CurY)]
      set MoveWindowOrIcon_State(CurX) $newX
      set MoveWindowOrIcon_State(CurY) $newY
      $hull move MotionShadow $dxMS $dyMS
    }
    method movewindoworicon_finish {mx my} {
#      puts stderr "*** $self movewindoworicon_finish $mx $my"
      set dx [expr [$hull canvasx $mx] -$MoveWindowOrIcon_State(StartX)]
      set dy [expr [$hull canvasy $my] - $MoveWindowOrIcon_State(StartY)]
      set MoveWindowOrIcon_State(CurX) [expr $MoveWindowOrIcon_State(OrgX) + $dx]
      set MoveWindowOrIcon_State(CurY) [expr $MoveWindowOrIcon_State(OrgY) + $dy]
      $hull delete MotionShadow
      set dx [expr $MoveWindowOrIcon_State(CurX) - $MoveWindowOrIcon_State(OrgX)]
      set dy [expr $MoveWindowOrIcon_State(CurY) - $MoveWindowOrIcon_State(OrgY)]
      $hull move $MoveWindowOrIcon_State(tag) $dx $dy
      incr MoveWindowOrIcon_State(done)
      $self propagategeometry
    }
    method restoreprocess {fp} {
      if {[catch [list set SubProcesses($fp)] spinfo]} {return}
      set tag [lindex $spinfo 0]
      set outer [$hull itemcget $tag -window]
      pack $outer.body -expand 1 -fill both -side top
      $outer.tbar.icon configure -command [mymethod minimizeprocess "$fp"]
    }
    method minimizeprocess {fp} {
      if {[catch [list set SubProcesses($fp)] spinfo]} {return}
      set tag [lindex $spinfo 0]
      set outer [$hull itemcget $tag -window]
      pack forget $outer.body
      $outer.tbar.icon configure -command [mymethod restoreprocess "$fp"]
    }
    method killsubprocess {fp} {
#   puts stderr "*** KillSubprocess $fp"
      set spInfo $SubProcesses($fp)
      set ctrlFp "[lindex $spInfo 2]"
      puts $ctrlFp {201 Exit}
      flush $ctrlFp
    }
    method killallprocesses {} {
      foreach fp [array names SubProcesses] {
	$self killsubprocess $fp
      }
      while {[llength [array names SubProcesses]] > 0} {
	after 1000
	update idle
      }
    }
    method logprogramoutput {fp} {
      if {[gets $fp line] < 0} {
#        puts stderr "*** $self logprogramoutput: gets failed"
        catch {close $fp}
        set spInfo $SubProcesses($fp)
        unset SubProcesses($fp)
        $self removeicon [lindex $spInfo 0]
        set otherFps [lrange $spInfo 2 end]
        foreach fp $otherFps {catch [list close $fp]}
      } else {
#        puts stderr "*** $self logprogramoutput: '$line'"
        set spInfo $SubProcesses($fp)
        set ctrlFp "[lindex $spInfo 2]"
        if {[string length "$ctrlFp"] > 0 && [string compare {101 Exit} "$line"] == 0} {
          close $fp
          set spInfo $SubProcesses($fp)
          $self removeicon [lindex $spInfo 0]
          puts $ctrlFp "Bye"
          unset SubProcesses($fp)
          set otherFps [lrange $spInfo 2 end]
          foreach fp $otherFps {catch [list close $fp]}
        } elseif {[string length "$ctrlFp"] > 0 && [string compare {102 Withdraw} "$line"] == 0} {
          $self minimizeprocess $fp
        } elseif {[string length "$ctrlFp"] > 0 && [string compare {103 Restore} "$line"] == 0} {
          $self restoreprocess $fp
        } else {
          catch {$options(-logtext) insert end "$line\n"}
        }
      }
    }
    method propagategeometry {} {
      #puts stderr "*** PropagateGeometry $hull"
      set usedBBox [$hull  bbox all]
      set currentSR [$hull cget -scrollregion]
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
        $hull configure -scrollregion $currentSR
      }
    }
    typevariable DefaultPrograms -array {}
    typeconstructor {
      global env
      set exeext [file extension [info nameofexecutable]]
      set xtrkcadExe [auto_execok xtrkcad$exeext]
      if {"$xtrkcadExe" ne {}} {
        set "DefaultPrograms(MRR CAD)" [list [auto_execok xtrkcad$exeext] \
					  xtc64 \
					  {Foreign}]
      
#        puts stderr "*** IconFrame::typeconstructor: DefaultPrograms(MRR CAD) = $DefaultPrograms(MRR CAD)"
      }
      global tcl_platform
      if {"$tcl_platform(platform)" eq "windows"} {
	set pathSep {;}
      } else {
	set pathSep {:}
      }
      set savedPath "[set env(PATH)]"
      set mydir  "[file dirname  [info nameofexecutable]]"
      if {"$mydir" eq "." || "$mydir" eq ""} {set mydir [pwd]}
#      puts stderr "*** IconFrame::typeconstructor: mydir = $mydir"
      set env(PATH) "[file nativename ${mydir}]${pathSep}$env(PATH)"
#      puts stderr "*** IconFrame::typeconstructor: env(PATH) = $env(PATH)"
      if {[string equal [file tail [file dirname $mydir]] Scripts]} {
	set scripts [file dirname $mydir]
	foreach d [glob -nocomplain -types {d} -join $scripts *] {
	  set env(PATH) "[file nativename ${d}]${pathSep}$env(PATH)"
	}
      }
#      puts stderr "*** IconFrame::typeconstructor: env(PATH) = $env(PATH)"
      foreach pName {{Time Table} {Any Distance Camera} 
		     {Closest Distance Camera} {Resistor Calculator} 
		     {Freight Car Forwarder} {Freight Car Data Creator}
		     {CATD Panel Builder}} \
	      pProg {TimeTable AnyDistance Closest Resistor FCFMain
		     FCFCreate Dispatcher} \
	      pBitmap {TimeTable AnyDistance Closest 
		       resistor FCF FCFCre Dispatcher} {
	set progExe [auto_execok $pProg$exeext]
#	puts stderr "*** IconFrame::typeconstructor: (bare) progExe = $progExe"
	if {"$progExe" eq {}} {continue}
	set "DefaultPrograms($pName)" [list $progExe \
					    $pBitmap \
					    {MrrTcl}]
#	puts stderr "*** IconFrame::typeconstructor: DefaultPrograms($pName) = $DefaultPrograms($pName)"
      }
      set env(PATH) "$savedPath"
      set pIndex 0
      foreach pTitle [lsort -dictionary [array names DefaultPrograms]] {
	if {[catch [list set "DefaultPrograms($pTitle)"] pValues] == 0} {
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
#	  puts stderr "*** pValues (error) = \{$pValues\}"
	}
      }
      option add {*mrrProgramCount} $pIndex
    }
  }
}



package provide IconFrame 1.0
