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
package require gettext
package require Tk
package require tile
package require grsupport 2.0
package require ButtonBox
package require pdf4tcl
package require PrintDialog 2.0
package require ROText
package require ListBox
package require IconImage
package require csv
package require LayoutControlDB

namespace eval TrackGraph {
  snit::type TrackGraph {
    typecomponent layoutname
    typecomponent layoutControlsDialog
    typeconstructor {
        set layoutname {}
    }
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
        set numedges [$layoutname CompressedEdgeCount $nid]
        # Handle deadends as a special case
	if {$numedges == 1} {
            return 2
        } else {
            return $numedges
        }
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
    method OnScript {} {return [$layoutname OnScript $nid]}
    method OffScript {} {return [$layoutname OffScript $nid]}
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
      if {[info exists layoutControlsDialog] &&
          $layoutControlsDialog ne {} &&
          [winfo exists $layoutControlsDialog]} {
          $layoutControlsDialog close
      }
    }
    typemethod LoadLayout {filename} {
      $type ClearGraph
      set layoutname [new_MRRXtrkCad [file nativename "$filename"]]
      $layoutname ProcessFile
      $layoutname CompressGraph
    }
    typemethod ViewLayoutControls {} {
        $type buildLayoutControlsDialog
        $layoutControlsDialog draw -parent . -nodes [$type AllControlNodes]
    }
    typemethod AllControlNodes {} {
        set result [list]
        foreach head [$type Heads] {
            if {[$head NumEdges] < 1} {
                lappend result $head
            }
        }
        return $result
    }
    typemethod buildLayoutControlsDialog {} {
        if {[info exists layoutControlsDialog] && 
            $layoutControlsDialog ne {} &&
            [winfo exists $layoutControlsDialog]} {
            return $layoutControlsDialog
        }
        set layoutControlsDialog [::TrackGraph::LayoutControlsDialog \
                                  create .layoutControlsDialog%AUTO%]
    }
    typemethod HasControls {} {
        foreach head [$type Heads] {
            if {[$head NumEdges] < 1} {
                return true
            }
        }
        return false
    }
  } 
  snit::widget LayoutControlsDialog {
      hulltype toplevel
      widgetclass LayoutControlsDialog
      
      component headerframe
      component iconimage
      component headerlabel
      component mainpane
      component   controllistsw
      component     controllist
      component   buttons
      
      option -title -configuremethod _SetTitle;# -default [_ "Layout Controls"]
      option -style -default LayoutControlsDialog
      option -parent -default .
      method _SetTitle {option value} {
          wm title $win "$value"
          $headerlabel configure -text "$value"
          set options($option) "$value"
      }
      method _themeChanged {} {
          foreach option {-activebackground -activeforeground -anchor -background 
              -borderwidth -cursor -disabledforeground -foreground 
              -highlightbackground -highlightcolor -highlightthickness 
              -padx -pady -takefocus} {
              set value [ttk::style lookup $options(-style) $option]
              catch [list $win configure $option "$value"]    
              catch [list $iconimage configure $option "$value"]
              catch [list $headerlabel configure $option "$value"]
              catch [list $mainpane configure $option "$value"]
              catch [list $controllistsw configure $option "$value"]
              catch [list $controllist configure $option "$value"]
              catch [list $buttons configure $option "$value"]
           }
       }
       option -nodes -default {}
       constructor {args} {
           wm withdraw $win 
           install headerframe using ttk::frame $win.headerframe \
                 -relief ridge -borderwidth 5
           pack  $headerframe -fill x
           install iconimage using ttk::label $headerframe.iconimage \
                 -image banner
           pack  $iconimage -side left
           install headerlabel using ttk::label $headerframe.headerlabel \
                 -anchor w -font {Helvetica -24 bold}
           pack  $headerlabel -side right -anchor w -expand yes -fill x
           install mainpane using ttk::panedwindow $win.mainpane \
                 -orient horizontal
           pack $mainpane -fill both -expand yes
           install controllistsw using ScrolledWindow $mainpane.controllistsw \
                 -scrollbar both -auto both
           $mainpane add $controllistsw -weight 5
           install controllist using ListBox \
                 [$controllistsw getframe].controllist -selectmode multiple
           $controllistsw setwidget $controllist
           install buttons using ButtonBox $mainpane.buttons \
                 -orient vertical
           $mainpane add $buttons -weight 1
           $buttons add ttk::button view   -text [_m "Button|View"] \
                 -command [mymethod viewselected] -state disabled
           $buttons add ttk::button extractselected \
                 -text [_m "Button|Extract Selected"] \
                 -command [mymethod extractselected] -state disabled
           $buttons add ttk::button extractall \
                 -text [_m "Button|Extract All"] \
                 -command [mymethod extractall] -state disabled
           $buttons add ttk::button extractblocks \
                 -text [_m "Button|Extract Blocks"] \
                 -command [mymethod extractblocks] \
                 -state disabled
           $buttons add ttk::button extractswitchmotors \
                 -text [_m "Button|Extract Switch Motors"] \
                 -command [mymethod extractswitchmotors] \
                 -state disabled
           $buttons add ttk::button extractsignals \
                 -text [_m "Button|Extract Signals"] \
                 -command [mymethod extractsignals] \
                 -state disabled
           $buttons add ttk::button extractsensors \
                 -text [_m "Button|Extract Sensors"] \
                 -command [mymethod extractsensors] \
                 -state disabled
           $buttons add ttk::button extractcontrols \
                 -text [_m "Button|Extract Controls"] \
                 -command [mymethod extractcontrols] \
                 -state disabled
           $buttons add ttk::button makedb \
                 -text [_m "Button|Make Layout Control DB"] \
                 -command [mymethod makelayoutcontroldb]
           $buttons add ttk::button dismis -text [_m "Button|Dismis"] \
                 -command [mymethod close]
           $self configure -title [_ "Layout Controls"]
           $self configurelist $args
           bind all <<TreeviewSelect>> [mymethod _selectionUpdated %W]
           wm transient $win .
           wm protocol $win WM_DELETE_WINDOW [mymethod close]
           bind <<ThemeChanged>> $win [mymethod _themeChanged]
       }
       method _selectionUpdated {w} {
           if {$w ne "$controllist.treeview"} {return}
           set selected [$controllist selection get]
           if {[llength $selected ] == 1} {
               $buttons itemconfigure view -state enabled
           } else {
               $buttons itemconfigure view -state disabled
           }
           if {[llength $selected ] >= 1} {
               $buttons itemconfigure extractselected -state enabled
           } else {
               $buttons itemconfigure extractselected -state disabled
           }
       }
       method viewselected {} {
           set selected [$controllist selection get]
           if {[llength $selected ] == 1} {
               set node [::TrackGraph::TrackGraph FindNode \
                         [lindex $selected 0]]
               #puts stderr "*** $self viewselected: node is $node ([$node MyNID], [$node TypeOfNode])"
               switch [$node TypeOfNode] {
                   TrackGraph::Block {
                       #puts stderr "*** $self viewselected: about to call ::NodeGraphCanvas::displayBlockInfo draw"
                       ::NodeGraphCanvas::displayBlockInfo draw -node $node -parent . -title [_ "Block %s" [$node NameOfNode]]
                   }
                   TrackGraph::SwitchMotor {
                       #puts stderr "*** $self viewselected: about to call ::NodeGraphCanvas::displaySwitchMotorInfo draw"
                       ::NodeGraphCanvas::displaySwitchMotorInfo draw -node $node -parent . -title [_ "Switch Motor %s" [$node NameOfNode]]
                   }
                   TrackGraph::Signal {
                       #puts stderr "*** $self viewselected: about to call ::NodeGraphCanvas::displaySignalInfo draw"
                       ::NodeGraphCanvas::displaySignalInfo draw -node $node -parent . -title [_ "Signal %s" [$node NameOfNode]]
                   }
                   TrackGraph::Sensor {
                       ::NodeGraphCanvas::displaySensorInfo draw -node $node -parent . -title [_ "Sensor %s" [$node NameOfNode]]
                   }
                   TrackGraph::Control {
                       ::NodeGraphCanvas::displayControlInfo draw -node $node -parent . -title [_ "Control %s" [$node NameOfNode]]
                   }
                   
               }
           }
       }           
       method draw {args} {
           $self configurelist $args
           wm deiconify $win
           # populate list
           $controllist delete [$controllist items]
           foreach b {view extractselected extractall extractblocks 
               extractswitchmotors extractsignals extractsensors 
               extractcontrols} {
               $buttons itemconfigure $b -state disabled
           }
           if {[llength $options(-nodes)] > 0} {
               $buttons itemconfigure  extractall -state normal
           }
           foreach n [lsort -command [myproc _nodetypeorder] $options(-nodes)] {
               switch [$n TypeOfNode] {
                   TrackGraph::Block {
                       $controllist insert end [$n MyNID] -data $n\
                             -text [format "%d: %s,\tTracks: %s" [$n MyNID] \
                                    [$n NameOfNode] [$n TrackList]] \
                             -image [IconImage image Block]
                       $buttons itemconfigure  extractblocks -state normal
                   }
                   TrackGraph::SwitchMotor {
                       $controllist insert end [$n MyNID] -data $n\
                             -text [format "%d: %s,\tTurnout: %d" [$n MyNID] \
                                    [$n NameOfNode] [$n TurnoutNumber]] \
                             -image [IconImage image SwitchMotor]
                       $buttons itemconfigure extractswitchmotors -state normal
                   }
                   TrackGraph::Signal {
                       $controllist insert end [$n MyNID] -data $n\
                             -text [format "%d: %s" [$n MyNID] \
                                    [$n NameOfNode]] \
                             -image [IconImage image Signal]
                       $buttons itemconfigure extractsignals -state normal
                   }
                   TrackGraph::Sensor {
                       $controllist insert end [$n MyNID] -data $n\
                             -text [format "%d: %s" [$n MyNID] \
                                    [$n NameOfNode]] \
                             -image [IconImage image Sensor]
                       $buttons itemconfigure extractsensors -state normal
                   }
                   TrackGraph::Control {
                       $controllist insert end [$n MyNID] -data $n\
                             -text [format "%d: %s" [$n MyNID] \
                                    [$n NameOfNode]] \
                             -image [IconImage image Control]
                       $buttons itemconfigure extractcontrols -state normal
                   }
                   
               }
           }
       }
       variable needblockhead yes
       variable needsmhead yes
       variable needsignalhead yes
       variable needsensorhead yes
       variable needcontrolhead yes
       method extractall {} {
           set filename [tk_getSaveFile -defaultextension .csv \
                         -filetypes {{{CSV Files} {.csv} TEXT}
                                    {{All Files} *     TEXT}
                                } -parent . -title "CSV File to open"]
           if {$filename eq {}} {return}
           if {[catch {open $filename w} fn]} {
               tk_messageBox -type ok -icon error  -parent $win \
                     [_ "Error opening %s: %s" $filename $fn]
               return
           }
           set needblockhead yes
           set needsmhead yes
           set needsignalhead yes
           set needsensorhead yes
           set needcontrolhead yes
           foreach n [lsort -command [myproc _nodetypeorder] $options(-nodes)] {
               $self _extractanode $n $fn
           }
           close $fn
       }
       method extractselected {} {
           set selected [$controllist selection get]
           if {[llength $selected ] > 0} {
               set filename [tk_getSaveFile -defaultextension .csv \
                             -filetypes {{{CSV Files} {.csv} TEXT} {{All Files} *     TEXT} } \
                             -parent . -title "CSV File to open"]
               if {$filename eq {}} {return}
               if {[catch {open $filename w} fn]} {
                   tk_messageBox -type ok -icon error  -parent $win \
                         [_ "Error opening %s: %s" $filename $fn]
                   return
               }
               set needblockhead yes
               set needsmhead yes
               set needsignalhead yes
               set needsensorhead yes
               set needcontrolhead yes
               foreach n [lsort -command [myproc _nodetypeorder] [_nodesfromids $selected]] {
                   $self _extractanode $n $fn
               }
               close $fn
           }
       }
       proc _nodesfromids {ids} {
           set result [list]
           foreach id $ids {
               lappend result [::TrackGraph::TrackGraph FindNode $id]
           }
           return $result
       }
       method extractblocks {} {
           set filename [tk_getSaveFile -defaultextension .csv \
                         -filetypes {{{CSV Files} {.csv} TEXT}
                                    {{All Files} *     TEXT}
                                } -parent . -title "CSV File to open"]
           if {$filename eq {}} {return}
           if {[catch {open $filename w} fn]} {
               tk_messageBox -type ok -icon error  -parent $win \
                     [_ "Error opening %s: %s" $filename $fn]
               return
           }
           set needblockhead yes
           foreach n $options(-nodes) {
               if {[$n TypeOfNode] eq "TrackGraph::Block"} {
                   $self _extractanode $n $fn
               }
           }
           close $fn
       }
       method extractswitchmotors {} {
           set filename [tk_getSaveFile -defaultextension .csv \
                         -filetypes {{{CSV Files} {.csv} TEXT}
                                    {{All Files} *     TEXT}
                                } -parent . -title "CSV File to open"]
           if {$filename eq {}} {return}
           if {[catch {open $filename w} fn]} {
               tk_messageBox -type ok -icon error  -parent $win \
                     [_ "Error opening %s: %s" $filename $fn]
               return
           }
           set needsmhead yes
           foreach n $options(-nodes) {
               if {[$n TypeOfNode] eq "TrackGraph::SwitchMotor"} {
                   $self _extractanode $n $fn
               }
           }
           close $fn
       }
       method extractsignals {} {
           set filename [tk_getSaveFile -defaultextension .csv \
                         -filetypes {{{CSV Files} {.csv} TEXT}
                                    {{All Files} *     TEXT}
                                } -parent . -title "CSV File to open"]
           if {$filename eq {}} {return}
           if {[catch {open $filename w} fn]} {
               tk_messageBox -type ok -icon error  -parent $win \
                     [_ "Error opening %s: %s" $filename $fn]
               return
           }
           set needsignalhead yes
           foreach n $options(-nodes) {
               if {[$n TypeOfNode] eq "TrackGraph::Signal"} {
                   $self _extractanode $n $fn
               }
           }
           close $fn
       }
       method extractsensors {} {
           set filename [tk_getSaveFile -defaultextension .csv \
                         -filetypes {{{CSV Files} {.csv} TEXT}
                                    {{All Files} *     TEXT}
                                } -parent . -title "CSV File to open"]
           if {$filename eq {}} {return}
           if {[catch {open $filename w} fn]} {
               tk_messageBox -type ok -icon error  -parent $win \
                     [_ "Error opening %s: %s" $filename $fn]
               return
           }
           set needsensorhead yes
           foreach n $options(-nodes) {
               if {[$n TypeOfNode] eq "TrackGraph::Sensor"} {
                   $self _extractanode $n $fn
               }
           }
           close $fn
       }
       method extractcontrols {} {
           set filename [tk_getSaveFile -defaultextension .csv \
                         -filetypes {{{CSV Files} {.csv} TEXT}
                                    {{All Files} *     TEXT}
                                } -parent . -title "CSV File to open"]
           if {$filename eq {}} {return}
           if {[catch {open $filename w} fn]} {
               tk_messageBox -type ok -icon error  -parent $win \
                     [_ "Error opening %s: %s" $filename $fn]
               return
           }
           set needcontrolhead yes
           foreach n $options(-nodes) {
               if {[$n TypeOfNode] eq "TrackGraph::Control"} {
                   $self _extractanode $n $fn
               }
           }
           close $fn
       }
       method _extractanode {node {fn stdout}} {
           set records [list]
           switch [$node TypeOfNode] {
               TrackGraph::Block {
                   if {$needblockhead} {
                       lappend records [list Name Type TrackList \
                                       SenseScript]
                       set needblockhead no
                   }
                   lappend records [list \
                                    [$node NameOfNode] \
                                    "Block" \
                                    [$node TrackList] \
                                    [$node SenseScript]]
               }
               TrackGraph::SwitchMotor {
                   if {$needsmhead} {
                       lappend records [list Name Type TurnoutNumber \
                                        NormalActionScript \
                                        ReverseActionScript SenseScript]
                       set needsmhead no
                   }
                   lappend records [list \
                                    [$node NameOfNode] \
                                    "SwitchMotor" \
                                    [$node TurnoutNumber] \
                                    [$node NormalActionScript] \
                                    [$node ReverseActionScript] \
                                    [$node SenseScript]]
               }
               TrackGraph::Signal {
                   if {$needsignalhead} {
                       lappend records [list Name Type NumberOfHeads \
                                        OrigX OrigY Angle \
                                        SignalAspectName \
                                        SignalAspectScript]
                       set needsignalhead no
                   }
                   set first yes
                   foreach asp [$node SignalAspects] {
                       foreach {name script} $asp {break}
                       if {$first} {
                           lappend records [list \
                                            [$node NameOfNode] \
                                            "Signal" \
                                            [$node NumberOfHeads] \
                                            [$node OrigX] \
                                            [$node OrigY] \
                                            [$node Angle] $name $script]
                           set first no
                       } else {
                           lappend records [list "" "" "" "" "" "" $name $script]
                       }
                   }
               }
               TrackGraph::Sensor {
                   if {$needsensorhead} {
                       lappend records [list Name Type OrigX OrigY \
                                       SenseScript]
                       set needsensorhead no
                   }
                   lappend records [list \
                                    [$node NameOfNode] \
                                    "Sensor" \
                                    [$node OrigX] [$node OrigY] \
                                    [$node SenseScript]]
               }
               TrackGraph::Control {
                   if {$needcontrolhead} {
                       lappend records [list Name Type OrigX OrigY \
                                       OnScript OffScript]
                       set needcontrolhead no
                   }
                   lappend records [list \
                                    [$node NameOfNode] \
                                    "Control" \
                                    [$node OrigX] [$node OrigY] \
                                    [$node OnScript] [$node OffScript]]
               }
           }
           puts -nonewline $fn [::csv::joinlist $records]
       }
       proc _nodetypeorder {a b} {
           return [string compare [$a TypeOfNode] [$b TypeOfNode]]
       }
       method close {} {
           wm withdraw $win
       }
       method makelayoutcontroldb {} {
           set filename [tk_getSaveFile -defaultextension .xml \
                         -filetypes {{{XML Files} {.xml} TEXT}
                         {{All Files} *     TEXT}
                     } -parent . -title "XML File to open"]
           set layoutdb [LayoutControlDB newdb]
           foreach n [lsort -command [myproc _nodetypeorder] $options(-nodes)] {
               _makelayoutcontrol $layoutdb $n
           }
           $layoutdb savedb $filename
       }
       proc _makelayoutcontrol {db node} {
           switch [$node TypeOfNode] {
               TrackGraph::Block {
                   set eventids [split [$node SenseScript] :]
                   lassign $eventids occ clr 
                   $db newBlock [$node NameOfNode] -occupiedevent $occ -clearevent $clr
               }
               TrackGraph::SwitchMotor {
                   set mnorm [$node NormalActionScript]
                   set mrev  [$node ReverseActionScript]
                   lassign [split [$node SenseScript] :] pnorm prev 
                   $db newTurnout [$node NameOfNode] -normalmotorevent $mnorm \
                         -reversemotorevent $mrev \
                         -normalpointsevent $pnorm \
                         -reversepointsevent $prev
               }
               TrackGraph::Signal {
                   $db newSignal [$node NameOfNode]
                   set sname [$node NameOfNode]
                   foreach asp [$node SignalAspects] {
                       lassign $asp name script 
                       $db addAspect $sname -aspect $name -look $name -eventid $script
                   }
               }
               TrackGraph::Sensor {
                   lassign [split [node SenseScript] :] on off 
                   $db newSensor [$node NameOfNode] -onevent $on -offevent $off
               }
               TrackGraph::Control {
                   lassign [split [node SenseScript] :] on off 
                   $db newControl [$node NameOfNode] -onevent $on -offevent $off
               }
           }
       }
   }
}

package provide TrackGraph 1.0
