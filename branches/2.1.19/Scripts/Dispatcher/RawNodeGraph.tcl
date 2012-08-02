#* 
#* ------------------------------------------------------------------
#* RawNodeGraph.tcl - Raw (uncompress) node graph
#* Created by Robert Heller on Thu Apr 10 16:47:06 2008
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

catch {Dispatcher::SplashWorkMessage "Loading Raw Node Graph" 16}

package require snit
package require Mrr


namespace eval RawNodeGraph {
  snit::type RawNode {
    typevariable NodeList {}
    typevariable Heads
    typecomponent layoutname
    delegate typemethod LowestNode to layoutname
    delegate typemethod HighestNode to layoutname
    delegate typemethod Emit to layoutname
    delegate typemethod SourceFile to layoutname
    delegate typemethod IsNodeP to layoutname

    variable list {}
    variable nid -1
    constructor {node {head {}}} {
#      puts stderr "$type create $self $node $head"
      if {![$layoutname IsNodeP $node]} {error "Cannot insert non-node: $node"}
      if {[$type InAGraphP $node]} {error "Cannot insert duplicate node: $node"}
      set nid $node
      if {[string length "$head"] == 0} {
	set head $self
	lappend Heads    $self
      }
      lappend NodeList $self
      $head AppendList $self
      for {set ie 0} {$ie < [$layoutname NumEdges $nid]} {incr ie} {
	set newNode [$layoutname EdgeIndex $nid $ie]
	if {[$layoutname IsNodeP $newNode] && ![$type InAGraphP $newNode]} {
	  $type create %AUTO% $newNode $head
	}
      }
    }
    method AppendList {node} {
      lappend list $node
    }
    method MyNID {} {return $nid}
    method Children {} {return $list}
    method NumEdges {} {return [$layoutname NumEdges $nid]}
    method LengthOfNode {} {return [$layoutname LengthOfNode $nid]}
    method TurnoutGraphic {} {return [$layoutname NodeTurnoutGraphic $nid]}
    method TurnoutRoutelist {} {return [$layoutname NodeTurnoutRoutelist $nid]}
    method TypeOfNode {} {return [$layoutname TypeOfNode $nid]}
    method EdgeIndex {edgenum} {return [$type RawNodeObject [$layoutname EdgeIndex $nid $edgenum]]}
    method EdgeX {edgenum} {return [$layoutname EdgeX $nid $edgenum]}
    method EdgeY {edgenum} {return [$layoutname EdgeY $nid $edgenum]}
    method EdgeA {edgenum} {return [$layoutname EdgeA $nid $edgenum]}
    typemethod LoadLayout {filename} {
      set layoutname [new_MRRXtrkCad [file nativename "$filename"]]
      $layoutname ProcessFile
      for {set node [$layoutname LowestNode]} {$node <= [$layoutname HighestNode]} {incr node} {
	if {[$layoutname IsNodeP $node] && ![$type InAGraphP $node]} {
	  $type create %AUTO% $node
	}
      }
    }
    typemethod RawNodeObject {nid} {
      foreach node $NodeList {
	if {[$node MyNID] == $nid} {return $node}
      }
      return {}
    }
    typemethod InAGraphP {nid} {
      foreach node $NodeList {
	if {[$node MyNID] == $nid} {return yes}
      }
      return no
    }
    typemethod AllHeads {} {return $Heads}
    typemethod AllNodes {} {return $NodeList}
    typemethod ClearGraph {} {
      catch {
	$layoutname delete
	unset layoutname
	foreach n $NodeList {
	  $n destory
	}
	unset NodeList
	unset Heads
      }
    }
  }
}

package provide RawNodeGraph 1.0
