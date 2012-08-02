#* 
#* ------------------------------------------------------------------
#* NodeGraphCanvas.tcl - Canvas widget that displays node graphs
#* Created by Robert Heller on Fri Apr 11 10:05:37 2008
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

# $Id$

package require snit
package require Tk
package require BWidget
package require grsupport 2.0
package require BWLabelSpinBox
package require PrintDialog

catch {Dispatcher::SplashWorkMessage "Loading Node Graph Display Code" 16}

namespace eval NodeGraphCanvas {
  snit::widgetadaptor NodeGraphCanvas {
    delegate option * to hull
    delegate method * to hull
    GRSupport::VerifyIntegerMethod
    option -defaultrowbase -default 20 -validatemethod _VerifyInteger
    option -drawwidth -default 850 -validatemethod _VerifyInteger

    component nodeMenu;#		Node menu.
    component findDialog;#		FindNode Dialog
    component   nodeIDLSP;#		Node ID
    component printDialog;#		Print Dialog
    

    constructor {args} {
      installhull using canvas -scrollregion {0 0 0 0}
      install nodeMenu using menu $win.nodeMenu -tearoff no
      $nodeMenu add command -label {Node Info} -command [mymethod MenuNodeInfo]
      $nodeMenu add command -label {Add To Panel} -command [mymethod MenuAddToPanel]
      install findDialog using Dialog::create $win.findNodeDialog \
			-bitmap questhead -default 0 \
			-cancel 1 -modal local -transient yes -parent . \
			-side bottom -title {Find Node By ID}
      $findDialog add -name find -text Find -command [mymethod _Find]
      $findDialog add -name cancel -text Cancel -command [mymethod _Cancel]
      wm protocol [winfo toplevel $findDialog] WM_DELETE_WINDOW [mymethod _Cancel]
      $findDialog add -name help -text Help -command {HTMLHelp::HTMLHelp help {Find Node Dialog}}
      set frame [Dialog::getframe $findDialog]
      install nodeIDLSP using LabelSpinBox $frame.nodeIDLSP -label "Node ID:" \
					-range {1 9999 1}
      pack $nodeIDLSP -fill x
      wm transient [winfo toplevel $findDialog] [winfo toplevel $win]
      install printDialog using PrintDialog::PrintDialog $win.printDialog \
					-title {Print Graph} -parent $win
      $self configurelist $args
    }
    variable UsedXY -array {}
    variable LastX 20
    variable LastY 20
    method resetlastXY {} {
      set LastX 20
      set LastY 20
      catch {array unset UsedXY}
    }
    method {create track} {XX YY args} {
      set node [from args -node {}]
      if {[string length $node] == 0} {return}
      set NID [$node MyNID]
      switch -exact -- "[$node TypeOfNode]" {
	TrackGraph::Track {
	  $hull create line $XX $YY [expr {$XX + 100.0}] $YY \
		-width 2.0 -fill blue -tag nid$NID
	}
	TrackGraph::Turnout {
	  TurnoutGraphic tgr -this [$node TurnoutGraphic]
	  set segCnt [tgr cget -numSegments]
#	  puts stderr "*** $self create track: segCnt = $segCnt"
	  for {set i 0} {$i < $segCnt} {incr i} {
#	    puts stderr "*** $self create track:  \[tgr segmentI $i\] = [tgr segmentI $i]"
	    SegVector seg -this [tgr segmentI $i]
	    switch -exact -- [seg tgType] {
	      SegVector::S {
		set gPos1 [seg cget -gPos1]
		set gPos2 [seg cget -gPos2]
#		puts stderr "*** $self create track(S): gPos1 = $gPos1, gPos2 = $gPos2"
		$hull create line [expr {$XX + ([lindex $gPos1 0] * 10)}] \
				  [expr {$YY + ([lindex $gPos1 1] * 10)}] \
				  [expr {$XX + ([lindex $gPos2 0] * 10)}] \
				  [expr {$YY + ([lindex $gPos2 1] * 10)}] \
				  -width 2.0 -fill blue -tag nid$NID
	      }
	      SegVector::C {
		set gPos1 [seg cget -gPos1]
		set rad [seg cget -radius]
		set ang0 [seg cget -ang0]
		set ang1 [seg cget -ang1]
#		puts stderr "*** $self create track(C): gPos1 = $gPos1, rad = $rad, ang0 = $ang0, ang1 = $ang1"
		$hull create arc \
			[expr {$XX + (([lindex $gPos1 0] - $rad) * 10)}] \
			[expr {$YY + (([lindex $gPos1 1] + $rad) * 10)}] \
			[expr {$XX + (([lindex $gPos1 0] + $rad) * 10)}] \
			[expr {$YY + (([lindex $gPos1 1] - $rad) * 10)}] \
			-start [GRSupport::RadiansToDegrees $ang0] \
			-extent [GRSupport::RadiansToDegrees $ang1] \
			-style arc -outline blue -width 2.0 -tag nid$NID
	      }
	      SegVector::J {
	      }
	    }
	    rename seg {}
	  }
	  rename tgr {}
	}
	TrackGraph::Turntable {
	}
	default {
	}
      }
    }
    variable blocknodes -array {}
    variable switchnodes -array {}
    method {create node} {X Y args} {
#      puts stderr "*** $self create node $X $Y $args"
      set ishead  [from args -ishead  no]
      if {$ishead} {
	set outline green
      } else {
	set outline black
      }
      set node [from args -node {}]
      if {[string length $node] == 0} {return}
      switch [$node TypeOfNode] {
	TrackGraph::Block {
	  set TrkNID {}
	  foreach tn [$node TrackList] {
	    switch [namespace tail [$node info type]] {
	      RawNode {
		set tracknode [[$node info type] RawNodeObject $tn]
		set tn [$tracknode MyNID]
	      }
	      CompressedNode {
		set tracknode [[$node info type] CompressedNodeObject $tn]
		set tn [$tracknode MyNID]
	      }
	      default {set tracknode {}}
	    }
	    if {"$tracknode" eq ""} {continue}
	    if {[llength [$hull find withtag T$tn]] > 0} {
	      set TrkNID $tn
	      break
	    }
	  }
	  if {"$TrkNID" ne ""} {
	    set coords [$hull coords T$TrkNID]
	    $hull create oval [expr {[lindex $coords 0] - 1}] \
			      [expr {[lindex $coords 1] - 1}] \
			      [expr {[lindex $coords 2] + 1}] \
			      [expr {[lindex $coords 3] + 1}] \
			      -outline blue -fill {} -tag T$TrkNID
	    lappend blocknodes($TrkNID) $node
	  }
	  return
	}
	TrackGraph::SwitchMotor {
	  set TrkNID [$node TurnoutNumber]
	  if {[llength [$hull find withtag T$TrkNID]] > 0} {
	    set coords [$hull coords T$TrkNID]
	    $hull create oval [expr {[lindex $coords 0] - 1}] \
                              [expr {[lindex $coords 1] - 1}] \
                              [expr {[lindex $coords 2] + 1}] \
                              [expr {[lindex $coords 3] + 1}] \
			      -outline orange -fill {} -tag T$TrkNID
	    lappend switchnodes($TrkNID) $node
	  }
	  return
	}
      }

      set NID [$node MyNID]
#      puts stderr "*** $self create node: NID = $NID"
      if {[llength [$hull find withtag T$NID]] > 0} {return}
      set rowbase [from args -rowbase $options(-defaultrowbase)]
      while {![catch [list set UsedXY(Used,$X,$Y)]]} {
	if {[expr {$X + 50}] > $options(-drawwidth)} {
	  set Y [expr {$Y + 75}]
	  set X $rowbase
	} else {
	  set X [expr {$X + 50}]
	  set Y $Y
	}
      }
      set UsedXY(Used,$X,$Y) $node
      $hull create oval $X $Y [expr {$X + 30}] [expr {$Y + 30}] \
		-outline $outline -fill white -tag T$NID
      $hull create text [expr {$X + 15}] [expr {$Y + 15}] -text $NID \
		-fill $outline -tag [list TLab$NID]
      $hull bind T$NID <1> [mymethod NodeInfo $node]
      $hull bind TLab$NID <1> [mymethod NodeInfo $node]
      $hull bind T$NID <3> [mymethod NodeMenu $node %X %Y]
      $hull bind TLab$NID <3> [mymethod NodeMenu $node %X %Y]
      $self create track $X $Y -node $node
      set bbox [$hull bbox all]
      set sr   [$hull cget -scrollregion]
      set newsr 0
      if {[lindex $bbox 0] < [lindex $sr 0]} {
        set sr [lreplace $sr 0 0 [lindex $bbox 0]]
	incr newsr
      }
      if {[lindex $bbox 1] < [lindex $sr 1]} {
        set sr [lreplace $sr 1 1 [lindex $bbox 1]]
	incr newsr
      }
      if {[lindex $bbox 2] > [lindex $sr 2]} {
        set sr [lreplace $sr 2 2 [lindex $bbox 2]]
	incr newsr
      }
      if {[lindex $bbox 3] > [lindex $sr 3]} {
        set sr [lreplace $sr 3 3 [lindex $bbox 3]]
	incr newsr
      }
      if {$newsr > 0} {$hull configure -scrollregion $sr}
    }
    method getLastX {} {return $LastX}
    method getLastY {} {return $LastY}
    method {create graph} {X Y args} {
#      puts stderr "*** $self create graph $X $Y $args"
      set node [from args -node {}]
      if {[string length $node] == 0} {return}
      set NID [$node MyNID]
#      puts stderr "*** $self create graph: NID = $NID"
      if {[llength [$hull find withtag T$NID]] > 0} {return}
      set rowbase [from args -rowbase $options(-defaultrowbase)]
      while {![catch [list set UsedXY(Used,$X,$Y)]]} {
	if {[expr {$X + 50}] > $options(-drawwidth)} {
	  set Y [expr {$Y + 75}]
	  set X $rowbase
	} else {
	  set X [expr {$X + 50}]
	  set Y $Y
	}
      }
      $self create node $X $Y -node $node -ishead [from args -ishead no]
      set lastX [expr {$X + 50}]
      if {$lastX > $LastX} {set LastX $lastX}
      set lastY [expr {$Y + 50}]
      if {$lastY > $LastY} {set LastY $lastY}
      if {[expr {$X + 50}] > $options(-drawwidth)} {
	set nextY [expr {$Y + 75}]
	set nextX $rowbase
      } else {
	set nextX [expr {$X + 50}]
	set nextY $Y
      }
      for {set ie 0} {$ie < [$node NumEdges]} {incr ie} {
	set nextNode [$node EdgeIndex $ie]
        if {[string length "$nextNode"] == 0} {continue}
	set nntag "T$[$nextNode MyNID]"
	if {[llength [$hull find withtag $nntag]] > 0} {continue}
	$self create graph $nextX $nextY -node $nextNode -rowbase $rowbase -ishead no
	set nextY [expr {$Y + 75}]
      }
      set XC [expr {$X + 15}]
      set YC [expr {$Y + 15}]
      for {set ie 0} {$ie < [$node NumEdges]} {incr ie} {
	set nextNode [$node EdgeIndex $ie]
	if {[string length "$nextNode"] == 0} {continue}
	set NNID [$nextNode MyNID]
	set nntag "T$NNID"
	set coords [$hull coords $nntag]
        set nextX [expr {([lindex $coords 0] + [lindex $coords 2]) / 2.0}]
        set nextY [expr {([lindex $coords 1] + [lindex $coords 3]) / 2.0}]
	if {$XC < $nextX} {
	  set X1 [expr {$XC + 15}]
	  set X2 [expr {$nextX - 15}]
	} elseif {$XC == $nextX} {
	  set X1 $XC
	  set X2 $XC
	} else {
	  set X1 [expr {$XC - 15}]
	  set X2 [expr {$nextX + 15}]
	}
	if {$YC < $nextY} {
	  set Y1 [expr {$YC + 15}]
	  set Y2 [expr {$nextY - 15}]
	} elseif {$YC == $nextY} {
	  set Y1 $YC
	  set Y2 $YC
	} else {
	  set Y1 [expr {$YC - 15}]
	  set Y2 [expr {$nextY + 15}]
	}
	$hull create line $X1 $Y1 $X2 $Y2 \
			  -arrow last \
			  -fill  black \
			  -tag E${NID}-${NNID}
	$hull bind E${NID}-${NNID} <1> [mymethod EdgeInfo $node $ie]
      }
    }
    method NodeInfo {node} {
#      puts stderr "*** $self NodeInfo $node"
      switch [$node TypeOfNode] {
	TrackGraph::Block {
	  NodeGraphCanvas::displayBlockInfo draw -node $node -parent $win -title "Block [$node NameOfNode]"
	}
	TrackGraph::SwitchMotor {
	  NodeGraphCanvas::displaySwitchMotorInfo draw -node $node -parent $win -title "Switch Motor [$node NameOfNode]"
	}
	default {
	  NodeGraphCanvas::displayNodeInfo draw -node $node -parent $win -title "Node $node"
	  set TrkNID [$node MyNID]
	  if {![catch {set blocknodes($TrkNID)} blocklist]} {
	    puts stderr "*** $self NodeInfo: blocklist = $blocklist"
	    foreach b $blocklist {
	      NodeGraphCanvas::displayBlockInfo draw -node $b -parent $win -title "Block [$b NameOfNode]"
	    }
	  }
	  if {![catch {set switchnodes($TrkNID)} switchlist]} {
	    puts stderr "*** $self NodeInfo: switchlist = $switchlist"
	    foreach s $switchlist {
	      NodeGraphCanvas::displaySwitchMotorInfo draw -node $s -parent $win -title "Switch Motor [$s NameOfNode]"
	    }
	  }
	}
      }
    }
    method EdgeInfo {node edgeIndex} {
      NodeGraphCanvas::displayEdgeInfo draw -node $node -edge $edgeIndex -parent $win -title "Node $node"
    }
    method NodeMenu {node X Y} {
      $nodeMenu activate none
      $nodeMenu post $X $Y
      upvar #0 $nodeMenu data
      set data(oldfocus) [focus]
      set data(node) $node
      focus $nodeMenu
    }
    method MenuNodeInfo {} {
      upvar #0 $nodeMenu data
      $self NodeInfo $data(node)
    }
    method MenuAddToPanel {} {
      upvar #0 $nodeMenu data
      if {[catch {set blocknodes([$data(node) MyNID])} blocks]} {set blocks {}}
      if {[catch {set switchnodes([$data(node) MyNID])} switches]} {set switches {}}
      CTCPanelWindow::CTCPanelWindow addtrackworknodetopanel $data(node) \
					-parent $win -blocks $blocks \
					-switchmotors $switches
    }
    method see {tagorid} {
      set bbox [$hull bbox $tagorid]
      set sr [$hull cget -scrollregion]
      set leftedge   [lindex $sr 0]
      set rightedge  [lindex $sr 2]
      set topedge    [lindex $sr 1]
      set bottomedge [lindex $sr 3]
      set leftmost   [lindex $bbox 0]
      set rightmost  [lindex $bbox 2]
      set topmost    [lindex $bbox 1]
      set bottommost [lindex $bbox 3]
      set leftminfraction [expr {double($leftmost - $leftedge) / double($rightedge - $leftedge)}]
      set leftmaxfraction [expr {double($rightmost - $leftedge) / double($rightedge - $leftedge)}]
#      puts "*** $self see:  bottommost = $bottommost, topmost = $topmost, topedge = $topedge, bottomedge = $bottomedge"
      set topminfraction [expr {double($topmost - $topedge) / double($bottomedge - $topedge)}]
      set topmaxfraction [expr {double($bottommost - $topedge) / double($bottomedge - $topedge)}]
      set xwhere [$hull xview]
      if {$leftminfraction < [lindex $xwhere 0]} {
	$hull xview moveto $leftmaxfraction
      } elseif {$leftmaxfraction > [lindex $xwhere 1]} {
	$hull xview moveto $leftminfraction
      }
      set ywhere [$hull yview]
#      puts "*** $self see: ywhere = $ywhere, topminfraction = $topminfraction, topmaxfraction = $topmaxfraction"
      if {$topminfraction < [lindex $ywhere 0]} {
	$hull yview moveto $topmaxfraction
      } elseif {$topmaxfraction > [lindex $ywhere 1]} {
	$hull yview moveto $topminfraction
      }
    }
    variable LastHighlightedNode {}
    method HighLightNode {node} {
      if {[string length "$LastHighlightedNode"] > 0} {
	$self UnHighLightNode $LastHighlightedNode
	set LastHighlightedNode {}
      }
      set NID [$node MyNID]
      $hull itemconfigure T$NID -fill red
      $hull raise T$NID
      $hull raise TLab$NID
      set LastHighlightedNode $node
      $self see T$NID
    }
    method UnHighLightNode {node} {
      set NID [$node MyNID]
      $hull itemconfigure T$NID -fill white
    }
    method _Find {} {
      Dialog::withdraw $findDialog
      set nid [$nodeIDLSP cget -text]
#      puts stderr "*** $type _Find: \[RawNodeGraph::RawNode RawNodeObject $nid\] = [RawNodeGraph::RawNode RawNodeObject $nid]"
      set node [CompressedNodeGraph::CompressedNode CompressedNodeObject $nid]
      if {[string length "$node"] == 0} {
	tk_messageBox -type ok -icon error -message "No such node ID: $nid"
	return
      }
      $self HighLightNode $node
      return [eval [list Dialog::enddialog $findDialog] [list Find]]
    }
    method _Cancel {} {
      Dialog::withdraw $findDialog
      return [eval [list Dialog::enddialog $findDialog] [list Cancel]]
    }
    method searchbyid {} {
      if {[llength [$hull find all]] < 1} {
	tk_messageBox -type ok -icon warning \
			-message "Load a track graph first!"
	return
      }
      return [Dialog::draw $findDialog]
    }
    method print {} {
      if {[llength [$hull find all]] < 1} {
	tk_messageBox -type ok -icon warning \
			-message "Load a track graph first!"
	return
      }
      set prPath "[$printDialog draw]"
      if {[string length "$prPath"] > 0} {
	foreach {minx miny maxx maxy} [$hull cget -scrollregion] {break}
	set width [expr {$maxx - $minx}]
	set height [expr {$maxy - $miny}]
	if {$width > $height} {
	  set pageopts [list -pageanchor sw -rotate yes -pagex .5i -pagey .25i -pagewidth 10i]
	} else {
	  set pageopts [list -pageanchor sw -rotate no -pagex .25i -pagey .5i -pageheight 10i]
        }
#        puts stderr "*** $self print: width = $width, height = $height, pageopts = $pageopts"
	eval [list $hull postscript -file "$prPath" -x $minx -y $miny \
			 -width [expr {$maxx - $minx}] \
			 -height [expr {$maxy - $miny}]] $pageopts
      }
    }
  }
  catch {
  # Standard Motif bindings:

    bind ROText <1> {
      tk::TextButton1 %W %x %y
      %W tag remove sel 0.0 end
    }
    bind ROText <B1-Motion> {
      set tk::Priv(x) %x
      set tk::Priv(y) %y
      tk::TextSelectTo %W %x %y
    }
    bind ROText <Double-1> {
      set tk::Priv(selectMode) word
      tk::TextSelectTo %W %x %y
      catch {%W mark set insert sel.last}
      catch {%W mark set anchor sel.first}
    }
    bind ROText <Triple-1> {
      set tk::Priv(selectMode) line
      tk::TextSelectTo %W %x %y
      catch {%W mark set insert sel.last}
      catch {%W mark set anchor sel.first}
    }
    bind ROText <Shift-1> {
      tk::TextResetAnchor %W @%x,%y
      set tk::Priv(selectMode) char
      tk::TextSelectTo %W %x %y
    }
    bind ROText <Double-Shift-1>	{
      set tk::Priv(selectMode) word
      tk::TextSelectTo %W %x %y 1
    }
    bind ROText <Triple-Shift-1>	{
      set tk::Priv(selectMode) line
      tk::TextSelectTo %W %x %y
    }
    bind ROText <B1-Leave> {
      set tk::Priv(x) %x
      set tk::Priv(y) %y
      tk::TextAutoScan %W
    }
    bind ROText <B1-Enter> {
      tk::CancelRepeat
    }
    bind ROText <ButtonRelease-1> {
      tk::CancelRepeat
    }
    bind ROText <Control-1> {
      %W mark set insert @%x,%y
    }
    bind ROText <Left> {
      tk::TextSetCursor %W insert-1c
    }
    bind ROText <Right> {
      tk::TextSetCursor %W insert+1c
    }
    bind ROText <Up> {
      tk::TextSetCursor %W [tk::TextUpDownLine %W -1]
    }
    bind ROText <Down> {
      tk::TextSetCursor %W [tk::TextUpDownLine %W 1]
    }
    bind ROText <Shift-Left> {
      tk::TextKeySelect %W [%W index {insert - 1c}]
    }
    bind ROText <Shift-Right> {
      tk::TextKeySelect %W [%W index {insert + 1c}]
    }
    bind ROText <Shift-Up> {
      tk::TextKeySelect %W [tk::TextUpDownLine %W -1]
    }
    bind ROText <Shift-Down> {
      tk::TextKeySelect %W [tk::TextUpDownLine %W 1]
    }
    bind ROText <Control-Left> {
      tk::TextSetCursor %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
    }
    bind ROText <Control-Right> {
      tk::TextSetCursor %W [tk::TextNextWord %W insert]
    }
    bind ROText <Control-Up> {
      tk::TextSetCursor %W [tk::TextPrevPara %W insert]
    }
    bind ROText <Control-Down> {
      tk::TextSetCursor %W [tk::TextNextPara %W insert]
    }
    bind ROText <Shift-Control-Left> {
      tk::TextKeySelect %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
    }
    bind ROText <Shift-Control-Right> {
      tk::TextKeySelect %W [tk::TextNextWord %W insert]
    }
    bind ROText <Shift-Control-Up> {
      tk::TextKeySelect %W [tk::TextPrevPara %W insert]
    }
    bind ROText <Shift-Control-Down> {
      tk::TextKeySelect %W [tk::TextNextPara %W insert]
    }
    bind ROText <Prior> {
      tk::TextSetCursor %W [tk::TextScrollPages %W -1]
    }
    bind ROText <Shift-Prior> {
      tk::TextKeySelect %W [tk::TextScrollPages %W -1]
    }
    bind ROText <Next> {
      tk::TextSetCursor %W [tk::TextScrollPages %W 1]
    }
    bind ROText <Shift-Next> {
      tk::TextKeySelect %W [tk::TextScrollPages %W 1]
    }
    bind ROText <Control-Prior> {
      %W xview scroll -1 page
    }
    bind ROText <Control-Next> {
      %W xview scroll 1 page
    }
    
    bind ROText <Home> {
      tk::TextSetCursor %W {insert linestart}
    }
    bind ROText <Shift-Home> {
      tk::TextKeySelect %W {insert linestart}
    }
    bind ROText <End> {
      tk::TextSetCursor %W {insert lineend}
    }
    bind ROText <Shift-End> {
      tk::TextKeySelect %W {insert lineend}
    }
    bind ROText <Control-Home> {
      tk::TextSetCursor %W 1.0
    }
    bind ROText <Control-Shift-Home> {
      tk::TextKeySelect %W 1.0
    }
    bind ROText <Control-End> {
      tk::TextSetCursor %W {end - 1 char}
    }
    bind ROText <Control-Shift-End> {
      tk::TextKeySelect %W {end - 1 char}
    }
  
    bind ROText <Control-Tab> {
      focus [tk_focusNext %W]
    }
    bind ROText <Control-Shift-Tab> {
      focus [tk_focusPrev %W]
    }
    bind ROText <Select> {
      %W mark set anchor insert
    }
    bind ROText <<Copy>> {
      tk_textCopy %W
    }
    # Additional emacs-like bindings:
  
    bind ROText <Control-a> {
        if {!$tk_strictMotif} {
  	tk::TextSetCursor %W {insert linestart}
      }
    }
    bind ROText <Control-b> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W insert-1c
      }
    }
    bind ROText <Control-e> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W {insert lineend}
      }
    }
    bind ROText <Control-f> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W insert+1c
      }
    }
    bind ROText <Control-n> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W [tk::TextUpDownLine %W 1]
      }
    }
    bind ROText <Control-p> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W [tk::TextUpDownLine %W -1]
      }
    }
    if {[string compare $tcl_platform(platform) "windows"]} {
      bind ROText <Control-v> {
        if {!$tk_strictMotif} {
	  tk::TextScrollPages %W 1
        }
      }
    }
  
    bind ROText <Meta-b> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
      }
    }
    bind ROText <Meta-f> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W [tk::TextNextWord %W insert]
      }
    }
    bind ROText <Meta-less> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W 1.0
      }
    }
    bind ROText <Meta-greater> {
      if {!$tk_strictMotif} {
  	tk::TextSetCursor %W end-1c
      }
    }
    # Macintosh only bindings:
  
    # if text black & highlight black -> text white, other text the same
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      bind ROText <FocusIn> {
        %W tag configure sel -borderwidth 0
        %W configure -selectbackground systemHighlight -selectforeground systemHighlightText
      }
      bind ROText <FocusOut> {
        %W tag configure sel -borderwidth 1
        %W configure -selectbackground white -selectforeground black
      }
      bind ROText <Option-Left> {
        tk::TextSetCursor %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
      }
      bind ROText <Option-Right> {
        tk::TextSetCursor %W [tk::TextNextWord %W insert]
      }
      bind ROText <Option-Up> {
        tk::TextSetCursor %W [tk::TextPrevPara %W insert]
      }
      bind ROText <Option-Down> {
        tk::TextSetCursor %W [tk::TextNextPara %W insert]
      }
      bind ROText <Shift-Option-Left> {
        tk::TextKeySelect %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
      }
      bind ROText <Shift-Option-Right> {
        tk::TextKeySelect %W [tk::TextNextWord %W insert]
      }
      bind ROText <Shift-Option-Up> {
        tk::TextKeySelect %W [tk::TextPrevPara %W insert]
      }
      bind ROText <Shift-Option-Down> {
        tk::TextKeySelect %W [tk::TextNextPara %W insert]
      }
  
      # End of Mac only bindings
    }
  }
  snit::widget displayBlockInfo {
    Dispatcher::StdShell DisplayBlockInfo

    component nodeID
    component trackListLF
    component   trackListE
    component   trackListS
    component senseScriptLF
    component   senseScriptSW
    component     senseScriptT

    option -title -default {Displaying Block Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      if {[catch {$value info type} typename]} {
	error "Expected a RawNode or CompressedNode, got $value"
      } elseif {[lsearch -exact {::RawNodeGraph::RawNode 
				 ::CompressedNodeGraph::CompressedNode} \
				$typename] < 0} {
	error "Expected a RawNode or CompressedNode, got $value ($typename)"
      } else {
	if {[$value TypeOfNode] ne "TrackGraph::Block"} {
	  error "Expected a Block, got $value ([$value TypeOfNode])"
	}
        return $value
      }
    }
    method settopframeoption {frame option value} {
      catch [list $nodeID configure $option "$value"]
      catch [list $trackListLF configure $option "$value"]
      catch [list $trackListE configure $option "$value"]
      catch [list $trackListS configure $option "$value"]
      catch [list $senseScriptLF configure $option "$value"]
      catch [list $senseScriptSW configure $option "$value"]
      catch [list $senseScriptT configure $option "$value"]
    }

    method constructtopframe {frame args} {
      install nodeID using LabelEntry $frame.nodeID -label "Block: " \
						    -labelwidth 14 -editable no
      pack $nodeID -fill x
      install trackListLF using LabelFrame $frame.trackListLF \
						    -text "Track List:" \
						    -width 14
      pack $trackListLF -fill x
      install trackListE using Entry [$trackListLF getframe].e \
						    -editable no
      pack $trackListE -expand yes -fill x
      install trackListS using scrollbar [$trackListLF getframe].s \
						    -orient horizontal \
						    -command "$trackListE xview"
      $trackListE configure -xscrollcommand [mymethod _trackListS]
      install senseScriptLF using LabelFrame $frame.senseScriptLF \
						    -text "Sense Script:" \
						    -width 14
      pack $senseScriptLF -fill x
      install senseScriptSW using ScrolledWindow [$senseScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $senseScriptSW -expand yes -fill both
      install senseScriptT using text [$senseScriptSW getframe].t \
					-height 4 -width 40
      pack $senseScriptT -expand yes -fill both
      $senseScriptSW setwidget $senseScriptT
      bindtags $senseScriptT [list $senseScriptT ROText . all]
    }
    method _trackListS {s e} {
      if {$s == 0 && $e == 1} {
	pack forget $trackListS
      } else {
	pack $trackListS -expand yes -fill x
	$trackListS set $s $e
      }
    }
    method initializetopframe {frame args} {
      $self configurelist $args
      set node [$self cget -node]
      if {[string length "$node"] == 0} {return}
      $nodeID configure -text [$node NameOfNode]
      $trackListE configure -text [$node TrackList]
      $senseScriptT delete 1.0 end
      $senseScriptT insert end "[$node SenseScript]"
    }
    
  }
  snit::widget displaySwitchMotorInfo {
    Dispatcher::StdShell DisplaySwitchMotorInfo

    component nodeID
    component turnoutNumber
    component normalActionScriptLF
    component   normalActionScriptSW
    component    normalActionScriptT
    component reverseActionScriptLF
    component   reverseActionScriptSW
    component     reverseActionScriptT
    component senseScriptLF
    component   senseScriptSW
    component     senseScriptT

    option -title -default {Displaying Switch Motor Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      if {[catch {$value info type} typename]} {
	error "Expected a RawNode or CompressedNode, got $value"
      } elseif {[lsearch -exact {::RawNodeGraph::RawNode 
				 ::CompressedNodeGraph::CompressedNode} \
				$typename] < 0} {
	error "Expected a RawNode or CompressedNode, got $value ($typename)"
      } else {
	if {[$value TypeOfNode] ne "TrackGraph::SwitchMotor"} {
	  error "Expected a Switch Motor, got $value ([$value TypeOfNode])"
	}
        return $value
      }
    }
    method settopframeoption {frame option value} {
      catch [list $nodeID configure $option "$value"]
      catch [list $turnoutNumber configure $option "$value"]
      catch [list $normalActionScriptLF configure $option "$value"]
      catch [list $normalActionScriptSW
      catch [list $normalActionScriptT configure $option "$value"]
      catch [list $reverseActionScriptLF configure $option "$value"]
      catch [list $reverseActionScriptSW
      catch [list $reverseActionScriptT configure $option "$value"]
      catch [list $senseScriptLF configure $option "$value"]
      catch [list $senseScriptSW configure $option "$value"]
      catch [list $senseScriptT configure $option "$value"]
    }

    method constructtopframe {frame args} {
      install nodeID using LabelEntry $frame.nodeID -label "Switch Motor: " \
						    -labelwidth 21 -editable no
      pack $nodeID -fill x
      install turnoutNumber using LabelEntry $frame.turnoutNumber \
						    -label "Turnout Number:" \
						    -labelwidth 21 -editable no
      pack $turnoutNumber -fill x
      install normalActionScriptLF using LabelFrame $frame.normalActionScriptLF \
						    -text "Normal Action Script:" \
						    -width 21
      pack $normalActionScriptLF -fill x
      install normalActionScriptSW using ScrolledWindow [$normalActionScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $normalActionScriptSW -expand yes -fill both
      install normalActionScriptT using text [$normalActionScriptSW getframe].t \
					-height 4 -width 40
      pack $normalActionScriptT -expand yes -fill both
      $normalActionScriptSW setwidget $normalActionScriptT
      bindtags $normalActionScriptT [list $normalActionScriptT ROText . all]
      install reverseActionScriptLF using LabelFrame $frame.reverseActionScriptLF \
						    -text "Reverse Action Script:" \
						    -width 21
      pack $reverseActionScriptLF -fill x
      install reverseActionScriptSW using ScrolledWindow [$reverseActionScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $reverseActionScriptSW -expand yes -fill both
      install reverseActionScriptT using text [$reverseActionScriptSW getframe].t \
					-height 4 -width 40
      pack $reverseActionScriptT -expand yes -fill both
      $reverseActionScriptSW setwidget $reverseActionScriptT
      bindtags $reverseActionScriptT [list $reverseActionScriptT ROText . all]
      install senseScriptLF using LabelFrame $frame.senseScriptLF \
						    -text "Sense Script:" \
						    -width 21
      pack $senseScriptLF -fill x
      install senseScriptSW using ScrolledWindow [$senseScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $senseScriptSW -expand yes -fill both
      install senseScriptT using text [$senseScriptSW getframe].t \
					-height 4 -width 40
      pack $senseScriptT -expand yes -fill both
      $senseScriptSW setwidget $senseScriptT
      bindtags $senseScriptT [list $senseScriptT ROText . all]
    }
    method initializetopframe {frame args} {
      $self configurelist $args
      set node [$self cget -node]
      if {[string length "$node"] == 0} {return}
      $nodeID configure -text [$node NameOfNode]
      $turnoutNumber configure -text [$node TurnoutNumber]
      $normalActionScriptT delete 1.0 end
      $normalActionScriptT insert end "[$node NormalActionScript]"
      $reverseActionScriptT delete 1.0 end
      $reverseActionScriptT insert end "[$node RormalActionScript]"
      $senseScriptT delete 1.0 end
      $senseScriptT insert end "[$node SenseScript]"
    }
    
  }
  snit::widget displayNodeInfo {
    Dispatcher::StdShell DisplayNodeInfo

    component nodeID
    component nodeType
    component nodeLength
    component nodeNumEdges
    component infoFrameSW
    component   infoFrame
    component segmentList


    option -title -default {Displaying Node Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      if {[catch {$value info type} typename]} {
	error "Expected a RawNode or CompressedNode, got $value"
      } elseif {[lsearch -exact {::RawNodeGraph::RawNode 
				 ::CompressedNodeGraph::CompressedNode} \
				$typename] < 0} {
	error "Expected a RawNode or CompressedNode, got $value ($typename)"
      } else {
        return $value
      }
    }
    method settopframeoption {frame option value} {
      catch [list $nodeID configure $option "$value"]
      catch [list $nodeType configure $option "$value"]
      catch [list $nodeLength configure $option "$value"]
      catch [list $nodeNumEdges configure $option "$value"]
      catch [list $infoFrameSW configure $option "$value"]
      catch [list $infoFrame   configure $option "$value"]
      if {![catch [list winfo children $infoFrame] children]} {
	foreach c $children {
	  catch [list $c  configure $option "$value"]
	}
      }
    }

    method constructtopframe {frame args} {
      set hframe [frame $frame.hframe -relief flat -borderwidth 0]
      pack $hframe -expand yes -fill x
      pack [Label $hframe.l1 -text "Node "] -side left
      install nodeID using Label $hframe.nodeID
      pack $nodeID -side left
      pack [Label $hframe.l2 -text " ("] -side left
      install nodeType using Label $hframe.nodeType
      pack $nodeType -side left
      pack [Label $hframe.l3 -text ", "] -side left
      install nodeLength using Label $hframe.nodeLength
      pack $nodeLength -side left
      pack [Label $hframe.l4 -text " long), "] -side left
      install nodeNumEdges using Label $hframe.nodeNumEdges
      pack $nodeNumEdges -side left
      pack [Label $hframe.l5 -text " edges:"] -side left -anchor w -fill x
      install infoFrameSW using ScrolledWindow::create $frame.infoFrameSW \
				-scrollbar both -auto both
      pack $infoFrameSW -expand yes -fill both
      install infoFrame using ScrollableFrame::create \
			[$infoFrameSW getframe].infoFrame
      pack $infoFrame -expand yes -fill both
      $infoFrameSW setwidget $infoFrame
      install segmentList using LabelEntry::create $frame.segmentList \
	-editable no -relief flat -label "Segments List:"
    }
    method initializetopframe {frame args} {
#      puts stderr "*** $self initializetopframe $frame $args"
      $self configurelist $args
      set rows [lindex [grid size $infoFrame] 1]
      for {set ir 0} {$ir < $rows} {incr ir} {
        eval [concat grid forget [grid slave $infoFrame -row $ir]]
      }
      set node [$self cget -node]
#      puts stderr "*** $self initializetopframe: node = $node"
      if {[string length "$node"] == 0} {return}
      $nodeID configure -text [$node MyNID]
      $nodeType configure -text "[$node TypeOfNode]"
      $nodeLength configure -text [$node LengthOfNode]
      $nodeNumEdges configure -text [$node NumEdges]
      for {set ie 0} {$ie < [$node NumEdges]} {incr ie} {
	set nextNode [$node EdgeIndex $ie]
	set edgeX    [$node EdgeX $ie]
	set edgeY    [$node EdgeY $ie]
	set edgeA    [$node EdgeA $ie]
	if {[string length "$nextNode"] == 0} {
	  set NNID {<E>}
	} else {
	  set NNID [$nextNode MyNID]
	}
	if {![winfo exists $infoFrame.nid$ie]} {
	  Label $infoFrame.nid$ie -anchor e
	  Label $infoFrame.l1$ie -anchor w -text {: }
	  Label $infoFrame.x$ie -anchor e
	  Label $infoFrame.l2$ie -anchor w -text {, }
	  Label $infoFrame.y$ie -anchor e
	  Label $infoFrame.l4$ie -anchor w -text {, }
	  Label $infoFrame.a$ie -anchor e
	}
        $infoFrame.nid$ie configure -text "$NNID"
	$infoFrame.x$ie   configure -text $edgeX
	$infoFrame.y$ie   configure -text $edgeY
	$infoFrame.a$ie   configure -text $edgeA
	foreach wid {nid l1 x l2 y l4 a} \
		c   {0   1  2 3  4 5  6} \
		sk  {e   w  e w  e w  e} {
	  grid configure $infoFrame.${wid}$ie -column $c -row $ie -sticky $sk
	}
      }
      switch [$node info type] {
	::RawNodeGraph::RawNode {
	  catch [pack forget $segmentList]
	}
	::CompressedNodeGraph::CompressedNode {
	  catch [pack $segmentList -fill x]
	  set segmentIds {}
	  foreach seg [$node Segments] {
	    lappend segmentIds [$seg MyNID]
	  }
	  $segmentList configure -text "$segmentIds"
	}
      }
    }
  }
  snit::widget displayEdgeInfo {
    Dispatcher::StdShell DisplayEdgeInfo

    component node1ID
    component node2ID
    component edgeX
    component edgeY
    component edgeA
    option -title -default {Displaying Node Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      if {[catch {$value info type} typename]} {
	error "Expected a RawNode or CompressedNode, got $value"
      } elseif {[lsearch -exact {::RawNodeGraph::RawNode 
				 ::CompressedNodeGraph::CompressedNode} \
				$typename] < 0} {
	error "Expected a RawNode or CompressedNode, got $value ($typename)"
      } else {
        return $value
      }
    }
    option -edge -default 0 -validatemethod _VerifyInteger
    GRSupport::VerifyIntegerMethod

    method settopframeoption {frame option value} {
      catch [list $node1ID configure $option "$value"]
      catch [list $node2ID configure $option "$value"]
      catch [list $edgeX configure $option "$value"]
      catch [list $edgeY configure $option "$value"]
      catch [list $edgeA configure $option "$value"]
    }
    method constructtopframe {frame args} {
#      puts stderr "*** $self constructtopframe $frame $args"
      install node1ID using LabelEntry::create $frame.node1ID \
	-editable no -relief flat -label "Node:" -labelwidth 11
      pack $node1ID -fill x
      install node2ID using LabelEntry::create $frame.node2ID \
	-editable no -relief flat -label "Edge Node:" -labelwidth 11
      pack $node2ID -fill x
      install edgeX using LabelEntry::create $frame.edgeX \
	-editable no -relief flat -label "Edge X:" -labelwidth 11
      pack $edgeX -fill x
      install edgeY using LabelEntry::create $frame.edgeY \
	-editable no -relief flat -label "Edge Y:" -labelwidth 11
      pack $edgeY -fill x
      install edgeA using LabelEntry::create $frame.edgeA \
	-editable no -relief flat -label "Edge Angle:" -labelwidth 11
      pack $edgeA -fill x
    }
    method initializetopframe {frame args} {
#      puts stderr "*** $self initializetopframe $frame $args"
      $self configurelist $args
      set node [$self cget -node]
      set ie   [$self cget -edge]
      $node1ID configure -text [$node MyNID]
      set node2 [$node EdgeIndex $ie]
      if {[string length "$node2"] > 0} {
	$node2ID configure -text [$node2 MyNID]
      } else {
	$node2ID configure -text {<E>}
      }
      $edgeX configure -text [$node EdgeX $ie]
      $edgeY configure -text [$node EdgeY $ie]
      $edgeA configure -text [$node EdgeA $ie]
    }
  }
}





package provide NodeGraphCanvas 1.0
