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

# $Id: NodeGraphCanvas.tcl 624 2008-04-21 23:36:58Z heller $

package require gettext
package require snit
package require Tk
package require tile
package require grsupport 2.0
package require Dialog
package require LabelFrames
package require pdf4tcl
package require PrintDialog 2.0
package require ROText

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


    constructor {args} {
      installhull using canvas -scrollregion {0 0 0 0}
      install nodeMenu using menu $win.nodeMenu -tearoff no
      $nodeMenu add command -label [_m "Label|Node Info"] -command [mymethod MenuNodeInfo]
      $nodeMenu add command -label [_m "Label|Add To Panel"] -command [mymethod MenuAddToPanel]
      install findDialog using Dialog $win.findNodeDialog \
			-bitmap questhead -default find \
			-cancel cancel -modal local -transient yes -parent . \
			-side bottom -title [_ "Find Node By ID"]
      $findDialog add find -text [_m "Button|Find"] -command [mymethod _Find]
      $findDialog add cancel -text [_m "Button|Cancel"] -command [mymethod _Cancel]
      wm protocol [winfo toplevel $findDialog] WM_DELETE_WINDOW [mymethod _Cancel]
      $findDialog add help -text [_m "Button|Help"] -command {HTMLHelp::HTMLHelp help {Find Node Dialog}}
      set frame [$findDialog getframe]
      install nodeIDLSP using LabelSpinBox $frame.nodeIDLSP -label [_m "Label|Node ID:"] \
					-range {1 9999 1}
      pack $nodeIDLSP -fill x
      wm transient [winfo toplevel $findDialog] [winfo toplevel $win]
      $self configurelist $args
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
    variable signals [list]
    variable sensors [list]
    variable controls [list]
    method {create block} {node} {
      #puts stderr "*** $self create block $node"
      set TrkNID {}
      foreach tn [$node TrackList] {
	#puts stderr "*** $self create block: tn = $tn"
	set tracknode [[$node info type] FindNode $tn]
	if {![$tracknode AmIACompressedNode]} {
	  set tracknode [$tracknode ParentNode]
	  set tn [$tracknode MyNID]
	}
	#puts stderr "*** $self create block: tn = $tn, tracknode = $tracknode"
	if {[llength [$hull find withtag T$tn]] > 0} {
	  set TrkNID $tn
	  break
	}
      }
      if {"$TrkNID" eq ""} {return}
      set coords [$hull coords T$TrkNID]
      $hull create oval [expr {[lindex $coords 0] - 1}] \
      			[expr {[lindex $coords 1] - 1}] \
			[expr {[lindex $coords 2] + 1}] \
			[expr {[lindex $coords 3] + 1}] \
			-outline blue -fill {} -tag T$TrkNID
      lappend blocknodes($TrkNID) $node
      #parray blocknodes
    }
    method {create switchmotor} {node} {
      #puts stderr "*** $self create switchmotor $node"
      set tn [$node TurnoutNumber]
      #puts stderr "*** $self create switchmotor: tn = $tn"
      set tracknode [[$node info type] FindNode $tn]
      #puts stderr "*** $self create switchmotor: tracknode = $tracknode"
      if {[llength [$hull find withtag T$tn]] > 0} {
	set TrkNID $tn
      } else {
	return
      }
      set coords [$hull coords T$TrkNID]
      $hull create oval [expr {[lindex $coords 0] - 1}] \
      			[expr {[lindex $coords 1] - 1}] \
			[expr {[lindex $coords 2] + 1}] \
			[expr {[lindex $coords 3] + 1}] \
			-outline orange -fill {} -tag T$TrkNID
      lappend switchnodes($TrkNID) $node
      #parray switchnodes
    }
    method isdrawnp {node} {
        set NID [$node MyNID]
        if {[llength [$hull find withtag T$NID]] > 0} {
            return yes
        } else {
            return no
        }
    }
    method {create orphannode} {node {x 50} {y 50}} {
        set NID [$node MyNID]
        set bbox [$hull bbox T$NID]
        if {[llength $bbox] > 0} {return}
        set x0 [expr {$x - 15}]
        set y0 [expr {$y - 15}]
        set x1 [expr {$x + 15}]
        set y1 [expr {$y + 15}]
        set x_orig $x
        while {[llength [$hull find overlapping $x0 $y0 $x1 $y1]] > 0} {
            set x [expr {$x + 100}]
            if {$x > 750} {
                set y [expr {$y + 100}]
                set y0 [expr {$y - 15}]
                set y1 [expr {$y + 15}]
                set x $x_orig
            }
            set x0 [expr {$x - 15}]
            set x1 [expr {$x + 15}]
        }
        $self create node $node $x $y
    }
    method {create signal} {node {x 50} {y 50}} {
        set NID [$node MyNID]
        set bbox [$hull bbox T$NID]
        if {[llength $bbox] > 0} {return}
        set x0 [expr {$x - 15}]
        set y0 [expr {$y - 15}]
        set x1 [expr {$x + 15}]
        set y1 [expr {$y + 15}]
        set x_orig $x
        while {[llength [$hull find overlapping $x0 $y0 $x1 $y1]] > 0} {
            set x [expr {$x + 100}]
            if {$x > 750} {
                set y [expr {$y + 100}]
                set y0 [expr {$y - 15}]
                set y1 [expr {$y + 15}]
                set x $x_orig
            }
            set x0 [expr {$x - 15}]
            set x1 [expr {$x + 15}]
        }
        $self create node $node $x $y
        set coords [$hull coords T$NID]
        $hull create oval [expr {[lindex $coords 0] - 1}] \
      			[expr {[lindex $coords 1] - 1}] \
			[expr {[lindex $coords 2] + 1}] \
			[expr {[lindex $coords 3] + 1}] \
			-outline green -fill {} -tag T$NID
        lappend signals $node
    }
    method {create sensor} {node {x 50} {y 50}} {
        set NID [$node MyNID]
        set bbox [$hull bbox T$NID]
        if {[llength $bbox] > 0} {return}
        set x0 [expr {$x - 15}]
        set y0 [expr {$y - 15}]
        set x1 [expr {$x + 15}]
        set y1 [expr {$y + 15}]
        set x_orig $x
        while {[llength [$hull find overlapping $x0 $y0 $x1 $y1]] > 0} {
            set x [expr {$x + 100}]
            if {$x > 750} {
                set y [expr {$y + 100}]
                set y0 [expr {$y - 15}]
                set y1 [expr {$y + 15}]
                set x $x_orig
            }
            set x0 [expr {$x - 15}]
            set x1 [expr {$x + 15}]
        }
        $self create node $node $x $y
        set coords [$hull coords T$NID]
        $hull create oval [expr {[lindex $coords 0] - 1}] \
      			[expr {[lindex $coords 1] - 1}] \
			[expr {[lindex $coords 2] + 1}] \
			[expr {[lindex $coords 3] + 1}] \
			-outline lightgreen -fill {} -tag T$NID
        lappend sensors $node
    }
    method {create control} {node {x 50} {y 50}} {
        set NID [$node MyNID]
        set bbox [$hull bbox T$NID]
        if {[llength $bbox] > 0} {return}
        set x0 [expr {$x - 15}]
        set y0 [expr {$y - 15}]
        set x1 [expr {$x + 15}]
        set y1 [expr {$y + 15}]
        set x_orig $x
        while {[llength [$hull find overlapping $x0 $y0 $x1 $y1]] > 0} {
            set x [expr {$x + 100}]
            if {$x > 750} {
                set y [expr {$y + 100}]
                set y0 [expr {$y - 15}]
                set y1 [expr {$y + 15}]
                set x $x_orig
            }
            set x0 [expr {$x - 15}]
            set x1 [expr {$x + 15}]
        }
        $self create node $node $x $y
        set coords [$hull coords T$NID]
        $hull create oval [expr {[lindex $coords 0] - 1}] \
      			[expr {[lindex $coords 1] - 1}] \
			[expr {[lindex $coords 2] + 1}] \
			[expr {[lindex $coords 3] + 1}] \
			-outline lightblue -fill {} -tag T$NID
        lappend controls $node
    }
    method {create node} {node X Y args} {
#      puts stderr "*** $self create node $X $Y $args"
      set outline black
      if {[string length $node] == 0} {return}
      set NID [$node MyNID]
#      puts stderr "*** $self create node: NID = $NID"
      if {[llength [$hull find withtag T$NID]] > 0} {return}
      $hull create oval [expr {$X - 15}] [expr {$Y - 15}] \
			[expr {$X + 15}] [expr {$Y + 15}] \
		-outline $outline -fill white -tag T$NID
      $hull create text $X $Y -text $NID \
		-fill $outline -tag [list TLab$NID]
      $hull bind T$NID <1> [mymethod NodeInfo $node]
      $hull bind TLab$NID <1> [mymethod NodeInfo $node]
      $hull bind T$NID <3> [mymethod NodeMenu $node %X %Y]
      $hull bind TLab$NID <3> [mymethod NodeMenu $node %X %Y]
      $self create track $X [expr {$Y - 25}] -node $node
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
    method {create edge} {s t {x 50} {y 50} } {
      set s_NID [$s MyNID]
      set t_NID [$t MyNID]
      set bbox_s [$hull bbox T$s_NID]
      if {[llength $bbox_s] > 0} {
	set s_x [expr {double([lindex $bbox_s 0] + [lindex $bbox_s 2]) / 2.0}]
	set s_y [expr {double([lindex $bbox_s 1] + [lindex $bbox_s 3]) / 2.0}]
      } else {
	set s_x $x
	set s_y $y
	set x0 [expr {$s_x - 15}]
	set y0 [expr {$s_y - 15}]
	set x1 [expr {$s_x + 15}]
	set y1 [expr {$s_y + 15}]
	set s_x_orig $s_x
	while {[llength [$hull find overlapping $x0 $y0 $x1 $y1]] > 0} {
	  set s_x [expr {$s_x + 100}]
	  if {$s_x > 750} {
	    set s_y [expr {$s_y + 100}]
	    set y0 [expr {$s_y - 15}]
	    set y1 [expr {$s_y + 15}]
	    set s_x $s_x_orig
	  }
	  set x0 [expr {$s_x - 15}]
	  set x1 [expr {$s_x + 15}]
	}
        $self create node $s $s_x $s_y
      }
      set bbox_t [$hull bbox T$t_NID]
      if {[llength $bbox_t] > 0} {
	set t_x [expr {double([lindex $bbox_t 0] + [lindex $bbox_t 2]) / 2.0}]
	set t_y [expr {double([lindex $bbox_t 1] + [lindex $bbox_t 3]) / 2.0}]
      } else {
	set t_x [expr {$s_x + 100}]
	set t_y $s_y
	set x0 [expr {$t_x - 15}]
	set y0 [expr {$t_y - 15}]
	set x1 [expr {$t_x + 15}]
	set y1 [expr {$t_y + 15}]
	while {[llength [$hull find overlapping $x0 $y0 $x1 $y1]] > 0} {
	  set t_y [expr {$t_y + 100}]
	  set y0 [expr {$t_y - 15}]
	  set y1 [expr {$t_y + 15}]
	}
#    puts stderr "*** DisplayEdge: t_x = $t_x, t_y = $t_y"
	$self create node $t $t_x $t_y
      }
      $hull lower [$hull create line $s_x $s_y $t_x $t_y -tag [list E$s_NID-$t_NID edge]]
      set nedges [$s NumEdges]
#      puts stderr "*** DisplayEdge: nedges = $nedges, t = $t"
      for {set ie 0} {$ie < $nedges} {incr ie} {
#	puts stderr "*** DisplayEdge: ie = $ie, \[$s EdgeNode $ie\] = [$s EdgeNode $ie]"
	if {[$s EdgeNode $ie] eq $t} {break}
      }
      $hull bind E$s_NID-$t_NID <1> [mymethod EdgeInfo $s $ie]
    }
    method NodeInfo {node} {
        if {[$node TypeOfNode] eq "TrackGraph::Signal"} {
            NodeGraphCanvas::displaySignalInfo draw -node $node -parent $win -title [_ "Signal %s" [$node NameOfNode]]
        } elseif {[$node TypeOfNode] eq "TrackGraph::Sensor"} {
            NodeGraphCanvas::displaySensorInfo draw -node $node -parent $win -title [_ "Sensor %s" [$node NameOfNode]]
        } elseif {[$node TypeOfNode] eq "TrackGraph::Control"} {
            NodeGraphCanvas::displayControlInfo draw -node $node -parent $win -title [_ "Control %s" [$node NameOfNode]]
        } else {
            NodeGraphCanvas::displayNodeInfo draw -node $node -parent $win -title [_ "Node %s" $node]
            set TrkNID [$node MyNID]
            #puts stderr "*** $self NodeInfo: TrkNID = $TrkNID"
            #      parray blocknodes
            #      parray switchnodes
            if {![catch {set blocknodes($TrkNID)} blocklist]} {
                #	puts stderr "*** $self NodeInfo: blocklist = $blocklist"
                foreach b $blocklist {
                    #	  puts stderr "*** $self NodeInfo: b = $b, Name is [$b NameOfNode], SenseScript is [$b SenseScript], TrackList is [$b TrackList]"
                    NodeGraphCanvas::displayBlockInfo draw -node $b -parent $win -title [_ "Block %s" [$b NameOfNode]]
                }
            }
            if {![catch {set switchnodes($TrkNID)} switchlist]} {
                #	puts stderr "*** $self NodeInfo: switchlist = $switchlist"
                foreach s $switchlist {
                    NodeGraphCanvas::displaySwitchMotorInfo draw -node $s -parent $win -title [_ "Switch Motor %s" [$s NameOfNode]]
                }
            }
        }
    }
    method EdgeInfo {node edgeIndex} {
      NodeGraphCanvas::displayEdgeInfo draw -node $node -edge $edgeIndex -parent $win -title [_ "Node %s" $node]
    }
    method NodeMenu {node X Y} {
      if {[lsearch -exact {TrackGraph::Sensor TrackGraph::Control} [$node TypeOfNode]] < 0} {
          $nodeMenu entryconfigure [_m "Label|Add To Panel"] -state normal
      } else {
          $nodeMenu entryconfigure [_m "Label|Add To Panel"] -state disabled
      }
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
      #puts stderr "*** $self see: sr = $sr"
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
      $findDialog withdraw
      set nid [$nodeIDLSP cget -text]
#      puts stderr "*** $type _Find: \[RawNodeGraph::RawNode RawNodeObject $nid\] = [RawNodeGraph::RawNode RawNodeObject $nid]"
      set node [TrackGraph::TrackGraph FindNode $nid]
      if {[string length "$node"] == 0} {
	tk_messageBox -type ok -icon error -message [_ "No such node ID: %d" $nid]
	return
      }
      $self HighLightNode $node
      return [eval [list $findDialog enddialog] [list Find]]
    }
    method _Cancel {} {
      $findDialog withdraw
      return [eval [list $findDialog enddialog] [list Cancel]]
    }
    method searchbyid {} {
      if {[llength [$hull find all]] < 1} {
	tk_messageBox -type ok -icon warning \
			-message [_ "Load a track graph first!"]
	return
      }
      return [$findDialog draw]
    }
    method print {} {
      if {[llength [$hull find all]] < 1} {
	tk_messageBox -type ok -icon warning \
			-message [_ "Load a track graph first!"]
	return
      }

      set pdfobj [PrintDialog::PrintDialog draw -parent $win]
      if {"$pdfobj" eq ""} {return}
      $pdfobj startPage
      $pdfobj canvas $hull -bg yes -sticky nwe
      $pdfobj write
      $pdfobj destroy
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
      #puts stderr "*** $self _CheckNode $option $value"
      if {[catch {$value info type} typename]} {
        #puts stderr "*** $self _CheckNode: Expected a TrackGraph, got $value"
	error "Expected a TrackGraph, got $value"
      } elseif {[namespace tail "$typename"] ne "TrackGraph"} {
	#puts stderr "*** $self _CheckNode: Expected a TrackGraph, got $value ($typename)"
	error "Expected a TrackGraph, got $value ($typename)"
      } else {
	if {[$value TypeOfNode] ne "TrackGraph::Block"} {
	  #puts stderr "*** $self _CheckNode: Expected a Block, got $value ([$value TypeOfNode])"
	  error "Expected a Block, got $value ([$value TypeOfNode])"
	}
        return $value
      }
    }
    method constructtopframe {frame args} {
      set lwidth [expr {1+[_mx "Label|Block:" "Label|Track List:" \
					   "Label|Sense Script:"]}]
      install nodeID using LabelEntry $frame.nodeID -label [_m "Label|Block:"] \
						    -labelwidth $lwidth \
						    -editable no
      pack $nodeID -fill x
      install trackListLF using LabelFrame $frame.trackListLF \
						    -text [_m "Label|Track List:"] \
						    -width $lwidth
      pack $trackListLF -fill x
      install trackListE using ttk::entry [$trackListLF getframe].e \
						    -state readonly
      pack $trackListE -expand yes -fill x
      install trackListS using ttk::scrollbar [$trackListLF getframe].s \
						    -orient horizontal \
						    -command "$trackListE xview"
      $trackListE configure -xscrollcommand [mymethod _trackListS]
      install senseScriptLF using LabelFrame $frame.senseScriptLF \
						    -text [_m "Label|Sense Script:"] \
						    -width $lwidth
      pack $senseScriptLF -fill x
      install senseScriptSW using ScrolledWindow [$senseScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $senseScriptSW -expand yes -fill both
      install senseScriptT using ROText [$senseScriptSW getframe].t \
					-height 4 -width 40
      $senseScriptSW setwidget $senseScriptT
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
      #puts stderr "*** $self initializetopframe: node = $node, \[$node TrackList\] is [$node TrackList]"
      set state [$trackListE cget -state]
      $trackListE configure -state normal
      $trackListE delete 0 end
      $trackListE insert end "[$node TrackList]"
      $trackListE configure -state $state
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
	error "Expected a TrackGraph, got $value"
      } elseif {[namespace tail "$typename"] ne "TrackGraph"} {
	error "Expected a TrackGraph, got $value ($typename)"
      } else {
	if {[$value TypeOfNode] ne "TrackGraph::SwitchMotor"} {
	  error "Expected a Switch Motor, got $value ([$value TypeOfNode])"
	}
        return $value
      }
    }

    method constructtopframe {frame args} {
      set lwidth [expr {1+[_mx "Label|Switch Motor:" \
					   "Label|Turnout Number:" \
					   "Label|Normal Action Script:" \
					   "Label|Reverse Action Script:" \
					   "Label|Sense Script:"]}]
      install nodeID using LabelEntry $frame.nodeID -label [_m "Label|Switch Motor:"] \
						    -labelwidth $lwidth -editable no
      pack $nodeID -fill x
      install turnoutNumber using LabelEntry $frame.turnoutNumber \
						    -label [_m "Label|Turnout Number:"] \
						    -labelwidth $lwidth -editable no
      pack $turnoutNumber -fill x
      install normalActionScriptLF using LabelFrame $frame.normalActionScriptLF \
						    -text [_m "Label|Normal Action Script:"] \
						    -width $lwidth
      pack $normalActionScriptLF -fill x
      install normalActionScriptSW using ScrolledWindow [$normalActionScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $normalActionScriptSW -expand yes -fill both
      install normalActionScriptT using ROText [$normalActionScriptSW getframe].t \
					-height 4 -width 40
      $normalActionScriptSW setwidget $normalActionScriptT
      install reverseActionScriptLF using LabelFrame $frame.reverseActionScriptLF \
						    -text [_m "Label|Reverse Action Script:"] \
						    -width $lwidth
      pack $reverseActionScriptLF -fill x
      install reverseActionScriptSW using ScrolledWindow [$reverseActionScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $reverseActionScriptSW -expand yes -fill both
      install reverseActionScriptT using ROText [$reverseActionScriptSW getframe].t \
					-height 4 -width 40
      $reverseActionScriptSW setwidget $reverseActionScriptT
      install senseScriptLF using LabelFrame $frame.senseScriptLF \
						    -text [_m "Label|Sense Script:"] \
						    -width $lwidth
      pack $senseScriptLF -fill x
      install senseScriptSW using ScrolledWindow [$senseScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $senseScriptSW -expand yes -fill both
      install senseScriptT using ROText [$senseScriptSW getframe].t \
					-height 4 -width 40
      $senseScriptSW setwidget $senseScriptT
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
      $reverseActionScriptT insert end "[$node ReverseActionScript]"
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
    component infoFrame
    component segmentList

    option -title -default {Displaying Node Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      if {[catch {$value info type} typename]} {
	error "Expected a TrackGraph node, got $value"
      } elseif {{::TrackGraph::TrackGraph} ne $typename} {
	error "Expected a TrackGraph node, got $value ($typename)"
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
      catch [list $segmentList   configure $option "$value"]
      if {![catch [list winfo children $infoFrame] children]} {
	foreach c $children {
	  catch [list $c  configure $option "$value"]
	}
      }
    }

    method constructtopframe {frame args} {
      set hframe [ttk::frame $frame.hframe -relief flat -borderwidth 0]
      pack $hframe -expand yes -fill x
      pack [ttk::label $hframe.l1 -text [_m "Label|Node "]] -side left
      install nodeID using ttk::label $hframe.nodeID
      pack $nodeID -side left
      pack [ttk::label $hframe.l2 -text " ("] -side left
      install nodeType using ttk::label $hframe.nodeType
      pack $nodeType -side left
      pack [ttk::label $hframe.l3 -text ", "] -side left
      install nodeLength using ttk::label $hframe.nodeLength
      pack $nodeLength -side left
      pack [ttk::label $hframe.l4 -text [_m "Label| long), "]] -side left
      install nodeNumEdges using ttk::label $hframe.nodeNumEdges
      pack $nodeNumEdges -side left
      pack [ttk::label $hframe.l5 -text [_m "Label| edges:"]] -side left -anchor w -fill x
      install infoFrameSW using ScrolledWindow $frame.infoFrameSW \
				-scrollbar both -auto both
      pack $infoFrameSW -expand yes -fill both
      install infoFrame using ScrollableFrame \
			[$infoFrameSW getframe].infoFrame
      $infoFrameSW setwidget $infoFrame
      install segmentList using LabelEntry $frame.segmentList \
            -editable no -label [_m "Label|Segments List:"]
      
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
	set nextNode [$node EdgeNode $ie]
	set edgeX    [$node EdgeX $ie]
	set edgeY    [$node EdgeY $ie]
	set edgeA    [$node EdgeA $ie]
#	puts stderr "*** $self initializetopframe: nextNode = $nextNode"
	if {[string length "$nextNode"] == 0} {
	  set NNID {<E>}
	} else {
	  set NNID [$nextNode MyNID]
	}
	if {![winfo exists $infoFrame.nid$ie]} {
	  ttk::label $infoFrame.nid$ie -anchor e
	  ttk::label $infoFrame.l1$ie -anchor w -text {: }
	  ttk::label $infoFrame.x$ie -anchor e
	  ttk::label $infoFrame.l2$ie -anchor w -text {, }
	  ttk::label $infoFrame.y$ie -anchor e
	  ttk::label $infoFrame.l4$ie -anchor w -text {, }
	  ttk::label $infoFrame.a$ie -anchor e
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
#      puts stderr "*** $self initializetopframe: \[$node AmIACompressedNode\] = [$node AmIACompressedNode]"
      if {[$node AmIACompressedNode]} {
	catch [pack $segmentList -fill x]
	$segmentList configure -text [$node Segments]
      } else {
	catch [pack forget $segmentList]
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
	error "Expected a TrackGraph node, got $value"
      } elseif {{::TrackGraph::TrackGraph} ne $typename} {
	error "Expected a TrackGraph node, got $value ($typename)"
      } else {
        return $value
      }
    }
    option -edge -default 0 -validatemethod _VerifyInteger
    GRSupport::VerifyIntegerMethod

    method constructtopframe {frame args} {
#      puts stderr "*** $self constructtopframe $frame $args"
      set lwidth [expr {1+[_mx "Label|Node:" "Label|Edge Node:" \
					   "Label|Edge X:" "Label|Edge Y:" \
					   "Label|Edge Angle:"]}]
      install node1ID using LabelEntry $frame.node1ID \
	-editable no -label [_m "Label|Node:"] -labelwidth $lwidth
      pack $node1ID -fill x
      install node2ID using LabelEntry $frame.node2ID \
	-editable no -label [_m "Label|Edge Node:"] -labelwidth $lwidth
      pack $node2ID -fill x
      install edgeX using LabelEntry $frame.edgeX \
	-editable no -label [_m "Label|Edge X:"] -labelwidth $lwidth
      pack $edgeX -fill x
      install edgeY using LabelEntry $frame.edgeY \
	-editable no -label [_m "Label|Edge Y:"] -labelwidth $lwidth
      pack $edgeY -fill x
      install edgeA using LabelEntry $frame.edgeA \
	-editable no -label [_m "Label|Edge Angle:"] -labelwidth $lwidth
      pack $edgeA -fill x
    }
    method initializetopframe {frame args} {
#      puts stderr "*** $self initializetopframe $frame $args"
      $self configurelist $args
      set node [$self cget -node]
      set ie   [$self cget -edge]
#      puts stderr "*** $self initializetopframe: ie = $ie"
      $node1ID configure -text [$node MyNID]
      set node2 [$node EdgeNode $ie]
#      puts stderr "*** $self initializetopframe: node2 = $node2"
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
  snit::widget displaySignalInfo {
      Dispatcher::StdShell DisplaySignalInfo
      
      component nodeID
      component numberHeads
      component positionLF
      component   posX
      variable    _posx
      component   posY
      variable    _posy
      component   posA
      variable    _posa
      component aspectsLF
      component   aspectsSW
      component     aspectsLB
      
      option -title -default {Displaying Signalr Info} -configuremethod _SetTitle
      option -node -default {} -validatemethod _CheckNode
      method _CheckNode {option value} {
          if {[catch {$value info type} typename]} {
              error "Expected a TrackGraph, got $value"
          } elseif {[namespace tail "$typename"] ne "TrackGraph"} {
              error "Expected a TrackGraph, got $value ($typename)"
          } else {
              if {[$value TypeOfNode] ne "TrackGraph::Signal"} {
                  error "Expected a Signal, got $value ([$value TypeOfNode])"
              }
              return $value
          }
      }
      
      method constructtopframe {frame args} {
          set lwidth [expr {1+[_mx "Label|Signal:" \
                               "Label|Number of Heads:" \
                               "Label|Aspects:" \
                               "Label|Position:"]}]
          install nodeID using LabelEntry $frame.nodeID \
                -label [_m "Label|Signal:"] \
                -labelwidth $lwidth -editable no
          pack $nodeID -fill x
          install numberHeads using LabelEntry $frame.numberHeads \
                -label [_m "Label|Number of Heads:"] \
                -labelwidth $lwidth -editable no
          pack $numberHeads -fill x
          install positionLF using LabelFrame $frame.positionLF \
                -text [_m "Label|Position:"] -width $lwidth
          pack $positionLF -fill x
          set posframe [$positionLF getframe]
          install posX using ttk::entry $posframe.posX -state readonly \
                -textvariable [myvar _posx]
          pack $posX -side left -expand yes
          install posY using ttk::entry $posframe.posY -state readonly \
                -textvariable [myvar _posy]
          pack $posY -side left -expand yes
          install posA using ttk::entry $posframe.posA -state readonly \
                -textvariable [myvar _posa]
          pack $posA -side left -expand yes
          install aspectsLF using ttk::labelframe $frame.aspectsLF \
                -text [_m "Label|Aspects:"] \
                -labelanchor nw
          pack $aspectsLF -expand yes -fill both
          install aspectsSW using ScrolledWindow $aspectsLF.aspectsSW \
                -scrollbar both -auto both
          pack $aspectsSW -expand yes -fill both
          install aspectsLB using ttk::treeview [$aspectsSW getframe].aspectsLB \
                -columns {name script} \
                -displaycolumns {name script} \
                -selectmode none \
                -show headings
          $aspectsSW setwidget $aspectsLB
          $aspectsLB column  name -anchor w
          $aspectsLB heading name -text [_m "Label|Name"] -anchor w
          $aspectsLB column script -anchor w
          $aspectsLB heading script -text [_m "Label|Script"] -anchor w
      }
      method initializetopframe {frame args} {
          $self configurelist $args
          set node [$self cget -node]
          if {[string length "$node"] == 0} {return}
          $nodeID configure -text [$node NameOfNode]
          $numberHeads configure -text [$node NumberOfHeads]
          set _posx [format "%0.3f" [$node OrigX]]
          set _posy [format "%0.3f" [$node OrigY]]
          set _posa [format "A%0.3f" [$node Angle]]
          $aspectsLB delete [$aspectsLB children {}]
          foreach aspect [$node SignalAspects] {
              $aspectsLB insert {} end -values $aspect
          }
      }
  }
  snit::widget displaySensorInfo {
    Dispatcher::StdShell DisplaySensofInfo

    component nodeID
    component positionLF
    component   posX
    variable    _posx
    component   posY
    variable    _posy
    component senseScriptLF
    component   senseScriptSW
    component     senseScriptT

    option -title -default {Displaying Sensor Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      #puts stderr "*** $self _CheckNode $option $value"
      if {[catch {$value info type} typename]} {
        #puts stderr "*** $self _CheckNode: Expected a TrackGraph, got $value"
	error "Expected a TrackGraph, got $value"
      } elseif {[namespace tail "$typename"] ne "TrackGraph"} {
	#puts stderr "*** $self _CheckNode: Expected a TrackGraph, got $value ($typename)"
	error "Expected a TrackGraph, got $value ($typename)"
      } else {
	if {[$value TypeOfNode] ne "TrackGraph::Sensor"} {
	  #puts stderr "*** $self _CheckNode: Expected a Sensor, got $value ([$value TypeOfNode])"
	  error "Expected a Sensor, got $value ([$value TypeOfNode])"
	}
        return $value
      }
    }
    method constructtopframe {frame args} {
      set lwidth [expr {1+[_mx "Label|Sensor:" "Label|Position:" \
					   "Label|Sense Script:"]}]
      install nodeID using LabelEntry $frame.nodeID -label [_m "Label|Sensor:"] \
						    -labelwidth $lwidth \
						    -editable no
      pack $nodeID -fill x
      install positionLF using LabelFrame $frame.positionLF \
            -text [_m "Label|Position:"] -width $lwidth
      pack $positionLF -fill x
      set posframe [$positionLF getframe]
      install posX using ttk::entry $posframe.posX -state readonly \
            -textvariable [myvar _posx]
      pack $posX -side left -expand yes
      install posY using ttk::entry $posframe.posY -state readonly \
            -textvariable [myvar _posy]
      pack $posY -side left -expand yes
      install senseScriptLF using LabelFrame $frame.senseScriptLF \
						    -text [_m "Label|Sense Script:"] \
						    -width $lwidth
      pack $senseScriptLF -fill x
      install senseScriptSW using ScrolledWindow [$senseScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $senseScriptSW -expand yes -fill both
      install senseScriptT using ROText [$senseScriptSW getframe].t \
					-height 4 -width 40
      $senseScriptSW setwidget $senseScriptT
    }
    method initializetopframe {frame args} {
      $self configurelist $args
      set node [$self cget -node]
      if {[string length "$node"] == 0} {return}
      $nodeID configure -text [$node NameOfNode]
      set _posx [format "%0.3f" [$node OrigX]]
      set _posy [format "%0.3f" [$node OrigY]]
      $senseScriptT delete 1.0 end
      $senseScriptT insert end "[$node SenseScript]"
    }
    
  }
  snit::widget displayControlInfo {
    Dispatcher::StdShell DisplayControlInfo

    component nodeID
    component positionLF
    component   posX
    variable    _posx
    component   posY
    variable    _posy
    component onScriptLF
    component   onScriptSW
    component     onScriptT
    component offScriptLF
    component   offScriptSW
    component     offScriptT

    option -title -default {Displaying Control Info} -configuremethod _SetTitle
    option -node -default {} -validatemethod _CheckNode
    method _CheckNode {option value} {
      #puts stderr "*** $self _CheckNode $option $value"
      if {[catch {$value info type} typename]} {
        #puts stderr "*** $self _CheckNode: Expected a TrackGraph, got $value"
	error "Expected a TrackGraph, got $value"
      } elseif {[namespace tail "$typename"] ne "TrackGraph"} {
	#puts stderr "*** $self _CheckNode: Expected a TrackGraph, got $value ($typename)"
	error "Expected a TrackGraph, got $value ($typename)"
      } else {
	if {[$value TypeOfNode] ne "TrackGraph::Control"} {
	  #puts stderr "*** $self _CheckNode: Expected a Control, got $value ([$value TypeOfNode])"
	  error "Expected a Control, got $value ([$value TypeOfNode])"
	}
        return $value
      }
    }
    method constructtopframe {frame args} {
      set lwidth [expr {1+[_mx "Label|Control:" "Label|Position:" \
                           "Label|On Script:" \
                           "Label|Off Script:"]}]
      install nodeID using LabelEntry $frame.nodeID -label [_m "Label|Control:"] \
						    -labelwidth $lwidth \
						    -editable no
      pack $nodeID -fill x
      install positionLF using LabelFrame $frame.positionLF \
            -text [_m "Label|Position:"] -width $lwidth
      pack $positionLF -fill x
      set posframe [$positionLF getframe]
      install posX using ttk::entry $posframe.posX -state readonly \
            -textvariable [myvar _posx]
      pack $posX -side left -expand yes
      install posY using ttk::entry $posframe.posY -state readonly \
            -textvariable [myvar _posy]
      pack $posY -side left -expand yes
      install onScriptLF using LabelFrame $frame.onScriptLF \
						    -text [_m "Label|On Script:"] \
						    -width $lwidth
      pack $onScriptLF -fill x
      install onScriptSW using ScrolledWindow [$onScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $onScriptSW -expand yes -fill both
      install onScriptT using ROText [$onScriptSW getframe].t \
					-height 4 -width 40
      $onScriptSW setwidget $onScriptT
      install offScriptLF using LabelFrame $frame.offScriptLF \
						    -text [_m "Label|Off Script:"] \
						    -width $lwidth
      pack $offScriptLF -fill x
      install offScriptSW using ScrolledWindow [$offScriptLF getframe].sw \
					-scrollbar both -auto both
      pack $offScriptSW -expand yes -fill both
      install offScriptT using ROText [$offScriptSW getframe].t \
					-height 4 -width 40
      $offScriptSW setwidget $offScriptT
    }
    method initializetopframe {frame args} {
      $self configurelist $args
      set node [$self cget -node]
      if {[string length "$node"] == 0} {return}
      $nodeID configure -text [$node NameOfNode]
      set _posx [format "%0.3f" [$node OrigX]]
      set _posy [format "%0.3f" [$node OrigY]]
      $onScriptT delete 1.0 end
      $onScriptT insert end "[$node OnScript]"
      $offScriptT delete 1.0 end
      $offScriptT insert end "[$node OffScript]"
    }
    
  }
}





package provide NodeGraphCanvas 1.0
