#* 
#* ------------------------------------------------------------------
#* CompressedNodeGraph.tcl - Compressed Node Graph
#* Created by Robert Heller on Thu Apr 10 19:21:27 2008
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

catch {Dispatcher::SplashWorkMessage "Loading Compressed Node Graph" 16}

package require snit
package require RawNodeGraph

namespace eval CompressedNodeGraph {
  snit::type CompressedNode {
    typecomponent rawnodegraph -inherit yes
    typeconstructor {
      set rawnodegraph RawNodeGraph::RawNode
    }
    typevariable BackPointers -array {}
    typemethod BackPointer {rawnode} {
      if {[catch {set BackPointers($rawnode)} nodeid]} {
	return {}
      } else {
	return $nodeid
      }      
    }
    typemethod CompressedNodeObject {nid} {
      set rn [$rawnodegraph RawNodeObject $nid]
      return [$type BackPointer $rn]
    }
    typevariable roots {}
    typemethod Roots {} {return $roots}
    variable segments
    variable edgeX -array {}
    variable edgeY -array {}
    variable edgeA -array {}
    variable edge  -array {}
    method Segments {} {return $segments}
    component rawnode
    delegate method * to rawnode except {EdgeX EdgeY EdgeA EdgeIndex 
					 LengthOfNode}
    method EdgeX      {index} {return $edgeX($index)}
    method EdgeY      {index} {return $edgeY($index)}
    method EdgeA      {index} {return $edgeA($index)}
    method EdgeIndex  {index} {return  $edge($index)}
    method LengthOfNode {} {
      set length 0
      foreach rn $segments {
	set length [expr {$length + [$rn LengthOfNode]}]
      }
      return $length
    }
    option -update -readonly yes -default no
    constructor {_rawnode args} {
      $self configurelist $args
#      puts stderr "*** $type create $self $_rawnode"
#      puts stderr "*** $type create $self: \[$_rawnode MyNID\] = [$_rawnode MyNID]"
      if {![string equal [$_rawnode info type] "::RawNodeGraph::RawNode"]} {
	error "Expected a ::RawNodeGraph::RawNode, got $_rawnode"
      }
      set NodeId [$type BackPointer $_rawnode]
      if {[string length $NodeId] > 0} {
	error "Node already in graph: $_rawnode!"
      }
      set rawnode $_rawnode
      set NodeId $self
      set segments [list $rawnode]
      set BackPointers($rawnode) $self
      set nEdges [$self NumEdges]
      if {$nEdges == 2} {
	set rn0 [$rawnode EdgeIndex 0]
	set rn1 [$rawnode EdgeIndex 1]
	set edgeX(0) [$rawnode EdgeX 0]
	set edgeY(0) [$rawnode EdgeY 0]
	set edgeA(0) [$rawnode EdgeA 0]
	set edgeX(1) [$rawnode EdgeX 1]
	set edgeY(1) [$rawnode EdgeY 1]
	set edgeA(1) [$rawnode EdgeA 1]
#	puts stderr "*** -: (before loops) rn0 = $rn0, rn1 = $rn1"
	while {[string length $rn0] > 0 &&
           [lsearch -exact $segments $rn0] < 0 &&
	   [$rn0 NumEdges] == 2} {
#	  puts stderr "*** -: \[$rn0 EdgeIndex 0\] = [$rn0 EdgeIndex 0]"
#	  puts stderr "*** -: \[$rn0 EdgeIndex 1\] = [$rn0 EdgeIndex 1]"
	  set segments [linsert $segments 0 $rn0]
#	  puts stderr "*** -: (in first loop) segments = $segments"  
	  set BackPointers($rn0) $self
	  set edgeX(0) [$rn0 EdgeX 0]
	  set edgeY(0) [$rn0 EdgeY 0]
	  set edgeA(0) [$rn0 EdgeA 0]
	  if {[lsearch -exact $segments [$rn0 EdgeIndex 0]] == 1} {
	    set rn0 [$rn0 EdgeIndex 1]
	  } else {
	    set rn0 [$rn0 EdgeIndex 0]
	  }
#	  puts stderr "*** -: (in first loop) rn0 = $rn0"
	}
	if {[lsearch -exact $segments $rn0] >= 0} {
	  set rn0 {}
	}
	while {[string length $rn1] > 0 &&
           [lsearch -exact $segments $rn1] < 0 &&
	   [$rn1 NumEdges] == 2} {
#	  puts stderr "*** -: \[$rn1 EdgeIndex 0\] = [$rn1 EdgeIndex 0]"
#	  puts stderr "*** -: \[$rn1 EdgeIndex 1\] = [$rn1 EdgeIndex 1]"
	  lappend segments $rn1
#	  puts stderr "*** -: (in second loop) segments = $segments"  
	  set BackPointers($rn1) $self
	  set edgeX(1) [$rn1 EdgeX 1]
	  set edgeY(1) [$rn1 EdgeY 1]
	  set edgeA(1) [$rn1 EdgeA 1]
	  if {[lsearch -exact $segments [$rn1 EdgeIndex 1]] == [expr {[llength $segments] - 2}]} {
	    set rn1 [$rn1 EdgeIndex 0]
	  } else {
	    set rn1 [$rn1 EdgeIndex 1]
	  }
#	  puts stderr "*** -: (in second loop) rn1 = $rn1"
	}
	if {[lsearch -exact $segments $rn1] >= 0} {
	  set rn1 {}
	}
#	puts stderr "*** -: (after loops) rn0 = $rn0, rn1 = $rn1"
#	puts stderr "*** -: segments = $segments"
	if {[string length $rn0] == 0} {
	  set edge(0) {}
	} elseif {[string length [set rn0Id [$type BackPointer $rn0]]] > 0} {
	  set edge(0) $rn0Id
	} else {
	  set edge(0) [$type create %AUTO% $rn0 -update $options(-update)]
	}
	if {[string length $rn1] == 0} {
	  set edge(1) {}
	} elseif {[string length [set rn1Id [$type BackPointer $rn1]]] > 0} {
	  set edge(1) $rn1Id
	} else {
	  set edge(1) [$type create %AUTO% $rn1 -update $options(-update)]
	}
	if {$options(-update)} {update idle}
      } else {
	for {set ie 0} {$ie < $nEdges} {incr ie} {
	  set edgeX($ie) [$rawnode EdgeX $ie]
	  set edgeY($ie) [$rawnode EdgeY $ie]
	  set edgeA($ie) [$rawnode EdgeA $ie]
	  set rn [$rawnode EdgeIndex $ie]
	  if {[string length $rn] == 0} {
	    set edge($ie) {}
	  } elseif {[string length [set rnId [$type BackPointer $rn]]] > 0} {
	    set edge($ie) $rnId
	  } else {
	    set  edge($ie) [$type create %AUTO% $rn -update $options(-update)]
	  }
	  if {$options(-update)} {update idle}
        }
      }
    }
    typemethod ClearGraph {} {
      foreach nid [array names BackPointers] {$nid destroy}
      array unset BackPointers
      $rawnodegraph ClearGraph      
    }
    typemethod LoadLayout {filename args} {
      $type ClearGraph
      $rawnodegraph LoadLayout $filename
      foreach h [$rawnodegraph AllHeads] {
	if {[string length [$type BackPointer $h]] == 0} {
	  lappend roots [eval [list $type create %AUTO% $h] $args]

	}
      }
    }
  }
}

package provide CompressedNodeGraph 1.0
