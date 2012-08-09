#* 
#* ------------------------------------------------------------------
#* TimeTable2TTStations.tcl - Station code
#* Created by Robert Heller on Sat Apr  1 23:00:59 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.4  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.3  2007/10/17 14:06:34  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.2  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.1  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
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

catch {SplashWorkMessage {Loading Station Code} 55}

package require snit
package require BWidget
package require BWLabelSpinBox

snit::type createAllStationsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent _MainDialog
  typecomponent _StationList
  typecomponent _AddOneStation
  typecomponent _AddOneStorageTrack
  typevariable  _StationIcon
  typevariable  _StorageTrackIcon
  typevariable  _SelectedStation
  typevariable  _StationAndTrackTree {}
  typeconstructor {
    global ImageDir
    set _StationIcon [image create photo -file [file join $ImageDir smallStation.gif]]
    set _StorageTrackIcon [image create photo -file [file join $ImageDir smallTrack.gif]]
    set _MainDialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$_MainDialog" {}] && [winfo exists $_MainDialog]} {return}
    set _MainDialog [Dialog::create .createAllStationsDialog \
			-bitmap questhead \
			-title "Create All Stations" \
			-modal local \
			-transient yes \
			-default 0 -cancel 1 \
			-parent . -side bottom]
    $_MainDialog add -name ok -text OK -command [mytypemethod _OK]
    $_MainDialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $_MainDialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $_MainDialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Create All Stations Dialog}]
    set frame [$_MainDialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Create All Stations}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set slScrollerFrame [LabelFrame::create $frame.slScrollerFrame \
				-text "Stations:" -side top]
    pack $slScrollerFrame -expand yes -fill both
    set slScroller [ScrolledWindow::create \
			[$slScrollerFrame getframe].slScroller \
			-auto both -scrollbar both]
    pack $slScroller -expand yes -fill both
    set _StationList [Tree::create $slScroller.stations]
    pack $_StationList -expand yes -fill both
    $_StationList bindImage <1> [mytypemethod _SelectStation]
    $_StationList bindText  <1> [mytypemethod _SelectStation]
    $slScroller setwidget $_StationList
    set add1StationFrame [LabelFrame::create $frame.add1StationFrame \
				-text "Add Station:" -side top]
    pack $add1StationFrame -fill x
    set _AddOneStation [$add1StationFrame getframe]
    pack [LabelEntry::create $_AddOneStation.name \
			-label "Name:" -labelwidth 12] -fill x
    $_AddOneStation.name bind <Return> "[list $_AddOneStation.addit invoke];break"
    pack [LabelSpinBox::create $_AddOneStation.smiles \
			-label "SMiles:" -labelwidth 12 \
			-range [list 0.0 3e6 .1]] -fill x
    $_AddOneStation.smiles bind <Return> "[list $_AddOneStation.addit invoke];break"
#    puts stderr "*** ${type}::typeconstructor: $_AddOneStation.smiles bind = [$_AddOneStation.smiles bind]"
#    puts stderr "*** ${type}::typeconstructor: $_AddOneStation.smiles bind <Return> = [$_AddOneStation.smiles bind <Return>]"
    pack [Button::create $_AddOneStation.addit \
			-text "Add" -command [mytypemethod _AddOneStation]] \
			-fill x
    set add1StorageTrack [LabelFrame::create $frame.add1StorageTrack \
    				-text "Add Storage Track:" -side top]
    pack $add1StorageTrack -fill x
    set _AddOneStorageTrack [$add1StorageTrack getframe]
    pack [LabelEntry::create $_AddOneStorageTrack.station \
			-label "Station:" -labelwidth 12 \
			-editable no] -fill x
    pack [LabelEntry::create $_AddOneStorageTrack.trackname \
			-label "Track Name:" -labelwidth 12 \
			-state disabled] -fill x
    $_AddOneStorageTrack.trackname bind <Return> \
		"[list $_AddOneStorageTrack.addit invoke];break"
    pack [Button::create $_AddOneStorageTrack.addit \
			-text "Add" -command [mytypemethod _AddStorageTrack] \
			-state disabled] -fill x
    BWidget::focus set $_AddOneStation.name
  }
  typemethod _SelectStation {node} {
    set nodeData [$_StationList itemcget $node -data]
    if {[string equal [lindex $nodeData 0] "StorageTrack"]} {
	set node [$_StationList parent $node]
    }
    $_StationList selection clear
    $_StationList selection set $node
    $_AddOneStorageTrack.station configure -text "$node"
    $_AddOneStorageTrack.trackname configure -state normal
    $_AddOneStorageTrack.addit configure -state normal
  }
  typemethod _AddOneStation {} {
    set name "[$_AddOneStation.name cget -text]"
    set smiles [$_AddOneStation.smiles cget -text]
    set insertion end
    foreach node [$_StationList nodes root] {
      set nodeData [$_StationList itemcget $node -data]
      if {[string equal [lindex $nodeData 0] "StorageTrack"]} {continue}
      if {[lindex $nodeData 2] > $smiles} {
	set insertion [$_StationList index $node]
	break
      }
    }
    $_StationList insert $insertion root "$name" \
			-data [list Station "$name" $smiles] \
			-image $_StationIcon -text "$name"
    
    $type _SelectStation "$name"
  }
  typemethod _AddStorageTrack {} {
    set trackname "[$_AddOneStorageTrack.trackname cget -text]"
    set station   "[$_AddOneStorageTrack.station   cget -text]"
    $_StationList insert end "$station" "${station}-$trackname" \
    		-data [list StorageTrack "$trackname"] \
		-image $_StorageTrackIcon -text "$trackname"
  }
  typemethod draw {args} {
    $type createDialog
    $_StationList delete [$_StationList nodes root]
    $_AddOneStation.name configure -text {}
    $_AddOneStation.smiles configure -text 0.0
    $_AddOneStorageTrack.station configure -text {}
    $_AddOneStorageTrack.trackname configure -text {} -state disabled
    $_AddOneStorageTrack.addit configure -state disabled
    catch ".mrrSplash hide"
    wm transient [winfo toplevel $_MainDialog] [$_MainDialog cget -parent]
    set result [Dialog::draw $_MainDialog]
    catch ".mrrSplash show"
    return $result
  }
  typemethod _OK {} {
    set _StationAndTrackTree {}
#    puts stderr "*** ${type}::_OK"
    foreach node [$_StationList nodes root] {
#      puts stderr "*** ${type}::_OK: node = $node"
      set nodeData [$_StationList itemcget $node -data]
#      puts stderr "*** ${type}::_OK: nodeData = $nodeData"
      if {[string equal [lindex $nodeData 0] "StorageTrack"]} {continue}
      set ndata [lrange $nodeData 1 end]
      set tnames {}
      foreach strack [$_StationList nodes $node] {
	lappend tnames [lindex [$_StationList itemcget $strack -data] 1]
      }
      lappend ndata $tnames
      lappend _StationAndTrackTree $ndata
    }
#    puts stderr "*** ${type}::_OK: _StationAndTrackTree = $_StationAndTrackTree"
    Dialog::withdraw $_MainDialog
    return [Dialog::enddialog $_MainDialog ok]
  }
  typemethod _Cancel {} {
    set _StationAndTrackTree {}
    Dialog::withdraw $_MainDialog
    return [Dialog::enddialog $_MainDialog cancel]
  }
  typemethod stationTree {} {
    return $_StationAndTrackTree
  }
}

proc CreateAllStations {} {
  set what [createAllStationsDialog draw]
#  puts stderr "*** CreateAllStations: what = $what"
  switch -exact $what {
    ok {
	set stationTree [createAllStationsDialog stationTree]
#	puts stderr "*** CreateAllStations: stationTree = $stationTree"
	foreach station $stationTree {
#	  puts stderr "*** CreateAllStations: station = $station"
	  foreach {name smiles tracks} $station {
#	    puts stderr "*** CreateAllStations: name = $name, smiles = $smiles, tracks = $tracks"
	    set index [TimeTable AddStation "$name" $smiles]
#	    puts stderr "*** CreateAllStations: index = $index"
#	    puts stderr "*** CreateAllStations: tracks = $tracks"
	    foreach track $tracks {
#	      puts stderr "*** CreateAllStations: track = $track"
	      TimeTable AddStorageTrack $index "$track"
	    }
	  }
	}
	set stationCount [TimeTable NumberOfStations]
#	puts stderr "*** CreateAllStations: stationCount = $stationCount"
	return $stationCount
    }
    cancel {
      return 0
    }
  }
}

snit::type SelectOneStationDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent name
  typecomponent slist
  typecomponent slistlist
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .selectOneStationDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title {Select one station}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Select One Station Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Select one station}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set slist [eval [list ScrolledWindow::create $frame.slist] -scrollbar both -auto both]
    pack $slist -expand yes -fill both
    set slistlist [eval [list ListBox::create $frame.slist.list] -selectmode single]
    pack $slistlist -expand yes -fill both
    $slist setwidget $slistlist
    $slistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $slistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set name [LabelEntry::create $frame.name -label {Station Name Selection:}]
    pack $name -fill x
    $name bind <Return> [mytypemethod _OK]
  }
  typemethod _OK {} {
    Dialog::withdraw $dialog
    set result "[$name cget -text]"
    return [eval [list Dialog::enddialog $dialog] [list "$result"]]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list {}]]
  }

  typemethod draw {args} {
    $type createDialog
    set title [from args -title]
    if {[string length "$title"]} {$dialog configure -title "$title"}
    $slistlist delete [$slistlist items]
    set sindex 0
    ForEveryStation [TimeTable cget -this] station {    
      set _name  [Station_Name  $station]
      set _smile [Station_SMile $station]
      incr sindex
      $slistlist insert end $sindex \
		-data [list "$_name" $_smile] \
		-text [format {%-15s %-6.2f} "$_name" $_smile]
    }
    BWidget::focus set $name
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }

  typemethod _SelectFromList {selectedItem} {
    set elt [$slistlist itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval [list Dialog::withdraw $dialog]
    return [eval [list Dialog::enddialog $dialog] \
		[list $result]]
  }

  typemethod _BrowseFromList {selectedItem} {
    set elt [$slistlist itemcget $selectedItem -data]
    set value "[lindex $elt 0]"
    $name configure -text "$value"
  }
}

package require DWpanedw

snit::widget displayOneStation {
  TtStdShell DisplayOneStation

  component nameLabel
  component smileLabel
  component duplicateLabel
  component storageList
  component storageScroll

  option -title -default {Displaying one station} \
		-configuremethod _SetTitle

  option -station -default NULL -validatemethod _CheckStation
  method _CheckStation {option value} {
    if {[string equal "$value" {}]} {
      $self configure $option NULL
      set value [$self cget $option]
    }
    if {![string equal "$value" NULL] &&
	 [regexp {^_[0-9a-z]*_p_Station$} "$value"] < 1} {
      error "Not a pointer to a station: $value"
    }
  }

  method settopframeoption {frame option value} {
    catch [list $nameLabel configure $option "$value"]
    catch [list $smileLabel configure $option "$value"]
    catch [list $duplicateLabel configure $option "$value"]
    catch [list $storageList configure $option "$value"]
    catch [list $storageScroll configure $option "$value"]
  }

  method constructtopframe {frame args} {
    set header [frame $frame.header]
    pack $header -fill x -expand yes 
    set nameLabel [Label $header.name -relief sunken]
    pack $nameLabel -side left -expand yes -fill x
    pack [Label $header.at -text { at scale mile }] -fill x -side left
    set smileLabel [Label $header.smile -relief sunken]
    pack $smileLabel -side left -fill x
    set duplicateLabel [LabelEntry $header.duplicate -label "Duplicate Station:" -editable no]
    set storageScroll [ScrolledWindow::create $frame.storageScroll \
				-scrollbar both -auto both]
    pack $storageScroll -expand yes -fill both
    set storageList [ListBox::create $storageScroll.storageList]
    pack $storageList -expand yes -fill both
    $storageScroll setwidget $storageList
  }
  method initializetopframe {frame args} {
    $self configurelist $args
    set station [$self cget -station]
#    puts stderr "*** ${self}::initializetopframe: station = $station"
    if {[string equal $station NULL]} {
      $nameLabel configure -text {}
      $smileLabel configure -text {}
      $storageList delete [$storageList items]
      catch {pack forget $duplicateLabel}
      $self configure -title {}
    } else {
      $nameLabel configure -text "[Station_Name $station]"
      $smileLabel configure -text "[format {%6.2f} [Station_SMile $station]]"
      set duplIndex [Station_DuplicateStationIndex $station]
      if {$duplIndex < 0} {
	catch {pack forget $duplicateLabel}
      } else {
	set otherStation [TimeTable IthStation $duplIndex]
	if {[string equal $otherStation NULL]} {
	  catch {pack forget $duplicateLabel}
	} else {
	  set otherName "[Station_Name $otherStation]"
	  $duplicateLabel configure -text "$otherName"
	  catch {pack $duplicateLabel -side right}
	}
      }
      $self configure \
	-title \
	"[Station_Name $station] at SMile post [format {%6.2f} [Station_SMile $station]]"
      $storageList delete [$storageList items]
      foreach storage [Station_StorageTrackNameList $station] {
	$storageList insert end "$storage" -text "$storage"
      }
    }
  }
}

proc ViewOneStation {} {
  set stationName "[SelectOneStationDialog draw]"
#  puts stderr "*** ViewOneStation: stationName = $stationName"
  if {[string equal "$stationName" {}]} {return}
  set station [TimeTable IthStation [TimeTable FindStationByName \
					       "$stationName"]]
#  puts stderr "*** ViewOneStation: station = $station"
  if {[string equal "$station" NULL]} {return}

  set v [displayOneStation draw -station $station]
}

snit::type viewAllStationsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent mainframe
  typecomponent headerframe
  typecomponent iconimage
  typecomponent headerlabel
  typecomponent dismisbutton
  typecomponent slist
  typecomponent slistlist
  typecomponent stations
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .viewAllStationsDialog \
			-bitmap info \
			-default 0 -cancel 0 -modal none -transient yes \
			-parent . -side bottom -title {All Available Stations}]
    $dialog add -name dismis -text Dismis -command [mytypemethod _Dismis]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Dismis]
    set mainframe [$dialog getframe]
    set headerframe $mainframe.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    set scheduleSWindow $mainframe.scheduleSWindow
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {All Available Stations}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set slist [eval [list ScrolledWindow::create $mainframe.slist] -scrollbar both -auto both]
    pack $slist -expand yes -fill both
    set slistlist [eval [list ScrollableFrame::create $mainframe.slist.list]]
    pack $slistlist -expand yes -fill both
    $slist setwidget $slistlist
    set stations [$slistlist getframe]
    Label::create $stations.name0 -text {Name} -anchor w
    Label::create $stations.smile0 -text {Scale Mile} -anchor e
    foreach w  {name smile} \
	    c  {0    1} \
	    sk {w    e} {
      grid configure $stations.${w}0 -column $c -row 0 -sticky $sk
    }
  }
  typemethod _Dismis {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list {}]]
  }
  typevariable _NumberOfStationsInDialog 0
  typemethod draw {args} {
    $type createDialog
    set sindex 0
    ForEveryStation [TimeTable cget -this] station {
      incr sindex
      if {$sindex > $_NumberOfStationsInDialog} {
	Button::create $stations.name$sindex  -anchor w
	Label::create  $stations.smile$sindex -anchor e
        foreach w  {name smile} \
		c  {0    1} \
		sk {w    e} {
	  grid configure $stations.${w}$sindex -column $c -row $sindex -sticky $sk
	}
	incr _NumberOfStationsInDialog
      }
      $stations.name$sindex configure \
		-text "[Station_Name $station]" \
		-command [list displayOneStation draw \
			-station $station]
      $stations.smile$sindex configure \
		-text "[format {%6.2f} [Station_SMile $station]]"
    }
    for {set iextra $sindex} {$iextra < $_NumberOfStationsInDialog} {incr iextra} {
      foreach w {name smile} {
	destroy stations.${w}$iextra
      }
    }
    update idle
    set dialogWidth [expr 60 + [winfo reqwidth $stations]]
    set dialogHeight [expr (4 * $dialogWidth) / 3]
    if {$dialogHeight > 500} {set dialogHeight 500}
    set geo "${dialogWidth}x${dialogHeight}"
    $dialog configure -geometry "$geo"
    set _NumberOfStationsInDialog $sindex
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }
}

proc ViewAllStations {} {
  viewAllStationsDialog draw
}

proc SetDuplicateStationIndex {} {
  if {[TimeTable NumberOfTrains] > 0} {
    TtWarningMessage draw -message "Cannot update duplicate trackage once you have trains defined."
    return
  }
  set stationName "[SelectOneStationDialog draw -title {Station to update}]"
  if {[string equal "$stationName" {}]} {return}
  set station [TimeTable IthStation [TimeTable FindStationByName \
					"$stationName"]]
  set duplicateStationName "[SelectOneStationDialog draw -title {Duplicate Station?}]"
  if {[string equal "$duplicateStationName" {}]} {return}
  set duplStationID [TimeTable FindStationByName "$duplicateStationName"]
  Station_SetDuplicateStationIndex $station $duplStationID
}

proc ClearDuplicateStationIndex {} {
  if {[TimeTable NumberOfTrains] > 0} {
    TtWarningMessage draw -message "Cannot update duplicate trackage once you have trains defined."
    return
  }
  set stationName "[SelectOneStationDialog draw -title {Station to update}]"
  if {[string equal "$stationName" {}]} {return}
  set station [TimeTable IthStation [TimeTable FindStationByName \
					"$stationName"]]
  Station_SetDuplicateStationIndex $station -1
}

snit::type SelectAStorageTrackName {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent name
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .selectAStorageTrackName \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom \
			-title {Select a storage track name}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Select A Storage Track Name}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Select a storage track name}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set name [LabelEntry::create $frame.name -label {Storage Track Name:}]
    pack $name -fill x
    $name bind <Return> [mytypemethod _OK]
  }
  typemethod _OK {} {
    Dialog::withdraw $dialog
    set result "[$name cget -text]"
    return [eval [list Dialog::enddialog $dialog] [list "$result"]]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list {}]]
  }
  typemethod draw {args} {
    $type createDialog
    set title [from args -title]
    if {[string length "$title"]} {$dialog configure -title "$title"}
    BWidget::focus set $name
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }
}

proc AddStorageTrack {} {
  set stationName "[SelectOneStationDialog draw -title {Station to update}]"
  if {[string equal "$stationName" {}]} {return}
  set station [TimeTable IthStation [TimeTable FindStationByName \
					"$stationName"]]
  set storageTrackName "[SelectAStorageTrackName draw -title {Storage Track To Add}]"
  if {[string equal [Station_FindStorageTrack $station "$storageTrackName"] NULL]} {
    $::ChartDisplay addAStorageTrack \
	$station [Station_AddStorageTrack $station "$storageTrackName"]
  } else {
    TtErrorMessage draw -message "Storage track $storageTrackName already exists at station $stationName!"
  }
}


package provide TTStations 1.0

catch {
$::Main menu add view separator
$::Main menu add view command -label {View One Station} \
			      -command ViewOneStation \
	 		      -dynamichelp "View a single station"
$::Main menu add view command -label {View All Stations} \
			      -command ViewAllStations \
			      -dynamichelp "View all stations"
$::Main menu add stations command -label {Set Duplicate Station} \
				  -command SetDuplicateStationIndex \
				  -dynamichelp "Set Duplicate Station"
$::Main menu add stations command -label {Clear Duplicate Station} \
				  -command ClearDuplicateStationIndex \
				  -dynamichelp "Clear Duplicate Station"
$::Main menu add stations command -label {Add Storage Track} \
				  -command AddStorageTrack \
				  -dynamichelp "Add Storage Track"
$::Main buttons add -name setDuplicateStationIndex -anchor w \
		    -text {Set Duplicate Station} \
		    -command SetDuplicateStationIndex \
		    -helptext "Set Duplicate Station"
$::Main buttons add -name clearDuplicateStationIndex -anchor w \
		    -text {Clear Duplicate Station} \
		    -command ClearDuplicateStationIndex \
		    -helptext "Clear Duplicate Station"
$::Main buttons add -name addStorageTrack -anchor w \
		    -text {Add Storage Track} \
		    -command AddStorageTrack \
		    -helptext "Add Storage Track"
image create photo SetDuplicateStationIndexImage \
			-file [file join $ImageDir setdupstation.gif]
$::Main toolbar addbutton tools setDuplicateStationIndex \
			-image SetDuplicateStationIndexImage \
			-command SetDuplicateStationIndex \
			-helptext "Set Duplicate Station"
image create photo ClearDuplicateStationIndexImage \
			-file [file join $ImageDir cleardupstation.gif]
$::Main toolbar addbutton tools clearDuplicateStationIndex \
			 -image ClearDuplicateStationIndexImage \
			 -command ClearDuplicateStationIndex \
			 -helptext "Clear Duplicate Station"
image create photo AddStorageTrackImage \
			-file [file join $ImageDir addstorage.gif]
$::Main toolbar addbutton tools addStorageTrack \
			-image AddStorageTrackImage \
			-command AddStorageTrack \
			-helptext "Add Storage Track"
}
