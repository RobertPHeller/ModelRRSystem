#* 
#* ------------------------------------------------------------------
#* TrackGraph.tcl - Track Graph snit wrapper for MRRXtrkCad (Boost Version)
#* Created by Robert Heller on Tue Apr 28 10:33:46 2009
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

package require Mrr
package require snit

namespace eval TrackGraph {
  snit::type TrackGraph {
    typecomponent layoutname
    delegate typemethod SourceFile       to layoutname
    delegate typemethod IsNodeP          to layoutname
    variable nid -1
    method MyNID {} {return $nid}
    typevariable idTable -array {}
    typevariable backPointers -array {}
    typemethod FindNode {nid} {
      if {[catch {set idTable($nid)} node]} {
	if {[$layoutname IsNodeP $nid]} {
	  set node [$type create %AUTO% $nid]
	  if {[$node AmIACompressedNode]} {
	    foreach s [$node Segments] {
	      set backPointers($s) $node
	    }
	  }
	  return $node
	} else {
	  return {}
	}
      } else {
	return $node
      }
    }
    constructor {_nid args} {
      set nid $_nid
      set idTable($nid) $self
      #$self configurelist $args
    }
    destructor {
      catch {unset idTable($nid)}
    }
    method NumEdges {} {
      if {[$layoutname IsCompressedNode $nid] && 
	  [llength [$layoutname CompressedNodeSegments $nid]] > 1} {
	return [$layoutname CompressedEdgeCount $nid]
      } else {
	return [$layoutname NumEdges $nid]
      }
    }
    method EdgeNode {edgenum} {
      if {[$layoutname IsCompressedNode $nid]} {
	set eid [$layoutname CompressedEdgeNode $nid $edgenum]
      } else {
	set eid [$layoutname EdgeIndex $nid $edgenum]
      }
      return [$type FindNode $eid]
    }
    method EdgeX {edgenum} {
      if {[$layoutname IsCompressedNode $nid] && 
	  [llength [$layoutname CompressedNodeSegments $nid]] > 1} {
        set segs [$layoutname CompressedNodeSegments $nid]
	if {[llength $segs] > 1} {
	  if {$edgenum == 0} {
	    return [$layoutname EdgeX [lindex $segs 0] 0]
	  } else {
	    return [$layoutname EdgeX [lindex $segs end] 1]
	  }
        } else {
	  return [$layoutname EdgeX $nid $edgenum]
        }
      } else {
	return [$layoutname EdgeX $nid $edgenum]
      }
    }
    method EdgeY {edgenum} {
      if {[$layoutname IsCompressedNode $nid] && 
	  [llength [$layoutname CompressedNodeSegments $nid]] > 1} {
        set segs [$layoutname CompressedNodeSegments $nid]
	if {[llength $segs] > 1} {
	  if {$edgenum == 0} {
	    return [$layoutname EdgeY [lindex $segs 0] 0]
	  } else {
	    return [$layoutname EdgeY [lindex $segs end] 1]
	  }
        } else {
	  return [$layoutname EdgeY $nid $edgenum]
        }
      } else {
	return [$layoutname EdgeY $nid $edgenum]
      }
    }
    method EdgeA {edgenum} {
      if {[$layoutname IsCompressedNode $nid] && 
	  [llength [$layoutname CompressedNodeSegments $nid]] > 1} {
        set segs [$layoutname CompressedNodeSegments $nid]
	if {[llength $segs] > 1} {
	  if {$edgenum == 0} {
	    return [$layoutname EdgeA [lindex $segs 0] 0]
	  } else {
	    return [$layoutname EdgeA [lindex $segs end] 1]
	  }
        } else {
	  return [$layoutname EdgeA $nid $edgenum]
        }
      } else {
	return [$layoutname EdgeA $nid $edgenum]
      }
    }
    method LengthOfNode {} {
      if {[$layoutname IsCompressedNode $nid] && 
	  [llength [$layoutname CompressedNodeSegments $nid]] > 1} {
	set len 0;
	foreach seg [$layoutname CompressedNodeSegments $nid] {
	  set len [expr {$len + [$layoutname LengthOfNode $seg]}]
	}
	return $len
      } else {
	return [$layoutname LengthOfNode $nid]
      }
    }

    method EdgeLength {edgenum} {
      if {[$layoutname IsCompressedNode $nid] && 
	  [llength [$layoutname CompressedNodeSegments $nid]] > 1} {
	return [$layoutname CompressedEdgeLength $nid $edgenum]
      } else {
	return [$layoutname EdgeLength $nid $edgenum]
      }
    }
    method TurnoutGraphic {} {return [$layoutname NodeTurnoutGraphic $nid]}
    method TurnoutRoutelist {} {return [$layoutname NodeTurnoutRoutelist $nid]}
    method TrackList {} {return [$layoutname TrackList $nid]}
    method TurnoutNumber {} {return [$layoutname TurnoutNumber $nid]}
    method NameOfNode {} {return [$layoutname NameOfNode $nid]}
    method SenseScript {} {return [$layoutname SenseScript $nid]}
    method NormalActionScript {} {return [$layoutname NormalActionScript $nid]}
    method ReverseActionScript {} {return [$layoutname ReverseActionScript $nid]}
    method NumberOfHeads {} {return [$layoutname NumberOfHeads $nid]}
    method SignalAspects {} {return [$layoutname SignalAspects $nid]}
    method OrigX {} {return [$layoutname OrigX $nid]}
    method OrigY {} {return [$layoutname OrigY $nid]}
    method Angle {} {return [$layoutname Angle $nid]}
    delegate typemethod LowestNode       to layoutname
    delegate typemethod HighestNode      to layoutname
    delegate typemethod CompressGraph    to layoutname
    typemethod Heads {} {
      set result {}
      foreach h [$layoutname Heads] {
	lappend result [$type FindNode $h]
      }
      return $result
    }
    typemethod Roots {} {
      set result {}
      foreach r [$layoutname Roots] {
	lappend result [$type FindNode $r]
      }
    }
    delegate typemethod IsCompressedNode to layoutname
    method AmIACompressedNode {} {return [$type IsCompressedNode $nid]}
    method CompressedNodePositionX {} {return [$layoutname CompressedNodePositionX $nid]}
    method CompressedNodePositionY {} {return [$layoutname CompressedNodePositionY $nid]}
    delegate typemethod CompressedGraphCircleLayout to layoutname
    delegate typemethod CompressedGraphKamadaKawaiSpring to layoutname
    delegate typemethod Emit to layoutname
    method Segments {} {return [$layoutname CompressedNodeSegments $nid]}
    method ParentNode {} {
      if {[catch {set backPointers($nid)} parent]} {
	return {}
      } else {
	return $parent
      }
    }
    typemethod KruskalMinimumSpanningTree {} {
      set tree [$layoutname CompressedGraphKruskalMinimumSpanningTree]
      set result {}
      foreach edgepair $tree {
	lappend result \
	   [list [$type FindNode [lindex $edgepair 0]] \
		 [$type FindNode [lindex $edgepair 1]] ]
      }
      return $result
    }
    typemethod PrimMinimumSpanningTree {} {
      set tree [$layoutname CompressedGraphPrimMinimumSpanningTree]
      set result {}
      foreach edgepair $tree {
	lappend result \
	   [list [$type FindNode [lindex $edgepair 0]] \
		 [$type FindNode [lindex $edgepair 1]] ]
      }
      return $result
    }
    method TypeOfNode {} {return [$layoutname TypeOfNode $nid]}
    typemethod ClearGraph {} {
      foreach nid [array names idTable] {$idTable($nid) destroy}
      array unset idTable
      array unset backPointers
      catch {$layoutname -delete}
      set layoutname {}
    }
    typemethod LoadLayout {filename} {
      $type ClearGraph
      set layoutname [new_MRRXtrkCad [file nativename "$filename"]]
      $layoutname ProcessFile
      $layoutname CompressGraph
    }
  }
}

package provide TrackGraph 1.0
