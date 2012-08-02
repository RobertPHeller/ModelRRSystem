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
	  $hull create line $XX $YY [expr $XX + 100.0] $YY \
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
      set NID [$node MyNID]
#      puts stderr "*** $self create node: NID = $NID"
      if {[llength [$hull find withtag T$NID]] > 0} {return}
      set rowbase [from args -rowbase $options(-defaultrowbase)]
      while {![catch [list set UsedXY(Used,$X,$Y)]]} {
	if {[expr $X + 50] > $options(-drawwidth)} {
	  set Y [expr {$Y + 75}]
	  set X $rowbase
	} else {
	  set X [expr {$X + 50}]
	  set Y $Y
	}
      }
      set UsedXY(Used,$X,$Y) $node
      $hull create oval $X $Y [expr $X + 30] [expr $Y + 30] \
		-outline $outline -fill white -tag T$NID
      $hull create text [expr $X + 15] [expr $Y + 15] -text $NID \
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
	if {[expr $X + 50] > $options(-drawwidth)} {
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
      NodeGraphCanvas::displayNodeInfo draw -node $node -parent $win -title "Node $node"
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
      CTCPanelWindow::CTCPanelWindow addtrackworknodetopanel $data(node) \
					-parent $win
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
      catch [list $segmentList   configure $option "$value"]
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
