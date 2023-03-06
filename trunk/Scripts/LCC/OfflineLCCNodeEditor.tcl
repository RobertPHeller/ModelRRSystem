#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Feb 24 13:14:30 2023
#  Last Modified : <230306.1537>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2023  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#*****************************************************************************


## @page OfflineLCCNodeEditor Offline LCC Node Editor
# @brief An offline node configuration editor.
# Edits a backup config file for a LCC node.
#
# @section OfflineLCCNodeEditorSYNOPSIS SYNOPSIS
#
# OfflineLCCNodeEditor xmlfile [backupconfigfile ...]
#
# @section OfflineLCCNodeEditorDESCRIPTION DESCRIPTION
# 
# Uses the saved CDI XML file from
# the node to create the configuration editor display and loads a backup 
# config file into the configuration editor and saves changes to a new backup 
# config file.
#
# @section OfflineLCCNodeEditorPARAMETERS PARAMETERS
#
# @arg xmlfile - the CDI XML file for the type of node. Required, no default.
# @arg backupconfigfile - [optional] backup config file(s) to edit.
# @par
#
# @section OfflineLCCNodeEditorOPTIONS OPTIONS
#
# @subsection OfflineLCCNodeEditorx11resource X11 Resource Options
#
# @arg -colormap: Colormap for main window
# @arg -display:  Display to use
# @arg -geometry: Initial geometry for window
# @arg -name:     Name to use for application
# @arg -sync:     Use synchronous mode for display server
# @arg -visual:   Visual for main window
# @arg -use:      Id of window in which to embed application
# @par
#
# @subsection OfflineLCCNodeEditorother Other options
#
# @arg -help Print a short help message and exit.
# @arg -debug Turn on debug output.
# @par
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\> 
#

set argv0 [file join  [file dirname [info nameofexecutable]] OfflineLCCNodeEditor]

package require gettext
package require Tk
package require tile
package require snit
package require MainWindow
package require ScrollWindow
package require ROText
package require snitStdMenuBar
package require HTMLHelp 2.0
package require LabelFrames
package require ParseXML
package require ConfigurationEditor
package require Dialog
package require ScrollTabNotebook
package require LayoutControlDBDialogs
package require LayoutControlDB
package require LayoutControlDBTable
package require ScrollableFrame
global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]

#puts stderr "*** HelpDir = $HelpDir"
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
#puts stderr "*** msgfiles = $msgfiles"

snit::widgetadaptor GetNIDDialog {
    delegate option -parent to hull
    delegate option -modal  to hull
    component NIDLE;#                  NID
    constructor {args} {
        installhull using Dialog -bitmap questhead -default ok \
              -cancel cancel -transient yes \
              -side bottom -title [_ "NID for new blank configuration"] \
              -parent [from args -parent]
        $hull add ok     -text [_m "Label|Ok"]     -command [mymethod _Ok]
        $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
        set frame [$hull getframe]
        install NIDLE using LabelEntry $frame.nidLE \
              -label [_m "Label|NID:"] -text {00:00:00:00:00:00}
        pack $NIDLE -fill x
        $self configurelist $args
    }
    method draw {args} {
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        return [$hull draw]
    }
    method _Ok {} {
        set nid "[$NIDLE cget -text]"
        if {[catch {lcc::nid validate $nid} err]} {
            tk_messageBox -type ok -icon error -message $err
            return
        }
        $hull withdraw
        return [$hull enddialog $nid]
    }
    method _Cancel {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
}
    
snit::type OfflineLCCNodeEditor {
    #*************************************************************************
    # Offline LCC Node Editor Main program -- provide offline node 
    #                                         configuration editing.
    #*************************************************************************
    
    pragma -hastypeinfo false
    pragma -hastypedestroy false
    pragma -hasinstances false
    
    typecomponent mainWindow;# Main window
    typecomponent   log
    typevariable CDI
    
    typevariable _debug no;# Debug flag
    
    typevariable CDIs_FormTLs [list]
    typecomponent layoutcontroldb
    typecomponent getNIDDialog
    typecomponent newTurnoutDialog
    typecomponent newBlockDialog
    typecomponent newSignalDialog
    typecomponent newSensorDialog
    typecomponent newControlDialog
    typecomponent layoutControlTable
    typecomponent layoutControlsLF
    typecomponent   layoutcontrolsNB
    typecomponent     editturnoutW
    typecomponent     editblockW
    typecomponent     editsensorW
    typecomponent     editcontrolW
    typecomponent     editsignalW
    typemethod _buildDialogs {} {
        putdebug "*** $type _buildDialogs"
        set getNIDDialog     [GetNIDDialog .getNIDDialog -parent .]
        set newTurnoutDialog [::lcc::NewTurnoutDialog .main.newTurnoutDialog -parent .main -modal none]
        putdebug "*** $type _buildDialogs: newTurnoutDialog is $newTurnoutDialog"
        set newBlockDialog   [::lcc::NewBlockDialog   .main.newBlockDialog -parent .main -modal none]
        set newSignalDialog  [::lcc::NewSignalDialog  .main.newSignalDialog -parent .main -modal none]
        set newSensorDialog  [::lcc::NewSensorDialog  .main.newSensorDialog -parent .main -modal none]
        set newControlDialog [::lcc::NewControlDialog .main.newControlDialog -parent .main -modal none]
        
    }
    typemethod _newTurnout {} {
        putdebug "*** $type _newTurnout: newTurnoutDialog is $newTurnoutDialog"
        $newTurnoutDialog draw -db $layoutcontroldb
    }
    typemethod _newBlock {} {
        $newBlockDialog   draw -db $layoutcontroldb
    }
    typemethod _newSignal {} {
        $newSignalDialog  draw -db $layoutcontroldb
    }
    typemethod _newSensor {} {
        $newSensorDialog  draw -db $layoutcontroldb
    }
    typemethod _newControl {} {
        $newControlDialog draw -db $layoutcontroldb
    }
        
    typemethod _loadLCDB {} {
        set filename [tk_getOpenFile -defaultextension .xml \
                      -filetypes {{{XML Files} {.xml} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "XML File to open"]
        if {"$filename" ne {}} {
            if {$layoutcontroldb ne ""} {$layoutcontroldb destroy}
            set layoutcontroldb [::lcc::LayoutControlDB olddb $filename]
            $layoutControlTable configure -db $layoutcontroldb
            $layoutControlTable Refresh
            foreach tl $CDIs_FormTLs {
                if {[winfo exists $tl] && ![$tl cget -displayonly]} {
                    $tl configure -layoutdb $layoutcontroldb
                }
            }
        }
    }
        
    typemethod _saveLCDB {} {
        set filename [tk_getSaveFile -defaultextension .xml \
                      -filetypes {{{XML Files} {.xml} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "XML File to open"]
        if {"$filename" ne {}} {
            $layoutcontroldb savedb "$filename"
        }
    }

    proc putdebug {message} {
        if {$_debug} {
            puts stderr $message
        }
    }
    proc hexdump { header data} {
        if {$_debug} {
            puts -nonewline stderr $header
            foreach byte $data {
                puts -nonewline stderr [format " %02X" $byte]
            }
            puts stderr {}
        }
    }

    typemethod usage {} {
        #* Print a usage message.
        
        puts stdout [_ "Usage: %s \[X11 Resource Options\] -- \[Other options\] xmlfile \[backupconfigfile ...\]" $::argv0]
        puts stdout {}
        puts stdout [_ "X11 Resource Options:"]
        puts stdout [_ " -colormap: Colormap for main window"]
        puts stdout [_ "-display:  Display to use"]
        puts stdout [_ "-geometry: Initial geometry for window"]
        puts stdout [_ "-name:     Name to use for application"]
        puts stdout [_ "-sync:     Use synchronous mode for display server"]
        puts stdout [_ "-visual:   Visual for main window"]
        puts stdout [_ "-use:      Id of window in which to embed application"]
        puts stdout {}
        puts stdout [_ "Other options:"]
        puts stdout [_ "-help: Print this help message and exit."]
        puts stdout [_ "-debug: Enable debug output."]
        puts stdout {}
        puts stdout [_ "Parameters:"]
        puts stdout [_ "xmlfile - CDI XML file"]
        puts stdout [_ "backupconfigfile - optional backup config file(s)"]
    }
    proc hidpiP {w} {
        set scwidth [winfo screenwidth $w]
        set scmmwidth [winfo screenmmwidth $w]
        set scinchwidth [expr {$scmmwidth / 25.4}]
        set scdpiw [expr {$scwidth / $scinchwidth}]
        set scheight [winfo screenheight $w]
        set scmmheight [winfo screenmmheight $w]
        set scinchheight [expr {$scmmheight / 25.4}]
        set scdpih [expr {$scheight / $scinchheight}]
        return [expr {($scdpiw > 100) || ($scdpih > 100)}]
    }
    typeconstructor {
        #* Type constructor -- create all of the one time computed stuff.
        #* This includes processing the CLI, building the main window and
        #* opening CDIs for any files passed on the command line.
        
        if {[llength $::argv] < 1} {
            error "CDI XML file missing!"
        }
        # Does the user want help?  
        set helpP [lsearch $::argv -help]
        if {$helpP >= 0} {
            wm withdraw .
            $type usage
            exit
        }
        set debugIdx [lsearch $::argv -debug]
        if {$debugIdx >= 0} {
            set _debug yes
            set ::argv [lreplace $::argv $debugIdx $debugIdx]
        }
        putdebug "*** $type typeconstructor: ::argv is $::argv"
        set fp [open [lindex $::argv 0] r]
        set CDI [ParseXML %AUTO% [read $fp]]
        close $fp
        # Build main GUI window. 
        set mainWindow [mainwindow .main -scrolling no \
                        -height 480 -width 640]
        pack $mainWindow -expand yes -fill both
        $mainWindow menu entryconfigure file "Exit" -command [mytypemethod _carefulExit]
        $mainWindow menu entryconfigure file "New" -command [mytypemethod _newblank]
        $mainWindow menu entryconfigure file "Open..." -command [mytypemethod _openbackupfile]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Load Layout Control DB"] \
              -dynamichelp "[_ {Load a Layout Control DB File}]" \
              -accelerator Ctrl+L \
              -underline 0 \
              -command "[mytypemethod _loadLCDB]"
        bind [winfo toplevel $mainWindow] <Control-Key-L> [mytypemethod _loadLCDB]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Menu|File|Save Layout Control DB"] \
              -dynamichelp "[_ {Save a Layout Control DB File}]" \
              -accelerator Ctrl+S \
              -underline 0 \
              -command "[mytypemethod _saveLCDB]"
        bind [winfo toplevel $mainWindow] <Control-Key-S> [mytypemethod _saveLCDB]
        $mainWindow menu add edit separator
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Turnout"] \
              -dynamichelp "[_ {Create new turnout}]" \
              -command "[mytypemethod _newTurnout]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Block"] \
              -dynamichelp "[_ {Create new block}]" \
              -command "[mytypemethod _newBlock]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Signal"] \
              -dynamichelp "[_ {Create new signal}]" \
              -command "[mytypemethod _newSignal]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Sensor"] \
              -dynamichelp "[_ {Create new sensor}]" \
              -command "[mytypemethod _newSensor]"
        $mainWindow menu add edit command \
              -label [_m "Menu|Edit|New Control"] \
              -dynamichelp "[_ {Create new control}]" \
              -command "[mytypemethod _newControl]"
        $mainWindow menu entryconfigure help "On Help..." -command {HTMLHelp help Help}
        $mainWindow menu delete help "On Keys..."
        $mainWindow menu delete help "Index..."
        $mainWindow menu delete help "Tutorial..."
        $mainWindow menu entryconfigure help "On Version" -command {HTMLHelp help Version}
        $mainWindow menu entryconfigure help "Warranty" -command {HTMLHelp help Warranty}
        $mainWindow menu entryconfigure help "Copying" -command {HTMLHelp help Copying}
        $mainWindow menu add help command \
              -label [_m "Menu|Help|Reference Manual"] \
              -command {HTMLHelp help "Offline LCC Node Editor Reference"}
        # Hook in help files.
        HTMLHelp setDefaults "$::HelpDir" "index.html#offlineedit"
        
        set layoutcontroldb [::lcc::LayoutControlDB newdb]
        set topframe [ScrollableFrame \
                      [$mainWindow scrollwindow getframe].topframe \
                      -constrainedwidth yes -constrainedheight yes]
        $mainWindow scrollwindow setwidget $topframe
        set scrollw [ScrolledWindow $topframe.scrollw]
        pack $scrollw -expand yes -fill both
        set layoutControlTable [::lcc::LayoutControlDBTable \
                                [$scrollw getframe].layoutControlTable \
                                -itemeditor [mytypemethod _editLayoutControlItem]]
        $scrollw setwidget $layoutControlTable
        set layoutControlsLF [ttk::labelframe \
                              $topframe.layoutControlsLF \
                              -text [_m "Label|Layout Controls"]]
        pack $layoutControlsLF -fill x
        set layoutcontrolsNB [ScrollTabNotebook \
                              $layoutControlsLF.layoutcontrolsNB]
        pack $layoutcontrolsNB -fill both -expand yes
        set editturnoutW [::lcc::NewTurnoutWidget \
                          $layoutcontrolsNB.editturnoutW \
                          -edit true]
        $layoutcontrolsNB add $editturnoutW -text [_m "Label|Turnout"]
        set editblockW [::lcc::NewBlockWidget \
                        $layoutcontrolsNB.editblockW \
                        -edit true]
        $layoutcontrolsNB add $editblockW -text [_m "Label|Block"]
        set editsensorW [::lcc::NewSensorWidget \
                         $layoutcontrolsNB.editsensorW \
                         -edit true]
        $layoutcontrolsNB add $editsensorW -text [_m "Label|Sensor"]
        set editcontrolW [::lcc::NewControlWidget \
                          $layoutcontrolsNB.editcontrolW \
                          -edit true]
        $layoutcontrolsNB add $editcontrolW -text [_m "Label|Control"]
        #set editturnoutW [::lcc::NewTurnoutWidget \
        #                  $layoutcontrolsNB.editturnoutW \
        #                  -edit true]
        #$layoutcontrolsNB add $editturnoutW -text [_m "Label|Turnout"]
        set buttons [ButtonBox $topframe.buttons \
                     -orient horizontal]
        pack $buttons -fill x
        $buttons add ttk::button refresh \
              -text [_m "Label|Refresh"] \
              -command [mytypemethod _reloadLayoutControlTable]
        $buttons add ttk::button close \
              -text [_m "Label|Close Window"] \
              -command [list wm withdraw  .layoutControlView]
        
        $layoutControlTable configure -db $layoutcontroldb
        $layoutControlTable Refresh
        
        foreach f [lrange $::argv 1 end] {
            lappend CDIs_FormTLs \
                  [lcc::ConfigurationEditor \
                   .cdi[_fnametowindow [file rootname [file tail $f]]] \
                   -cdi $CDI \
                   -offlineedit yes \
                   -loadfile $f -layoutdb $layoutcontroldb]
        }
        $type _buildDialogs
        $mainWindow showit
        update idle
    }
    proc _fnametowindow {filename} {
        return [regsub -all {[^[:alnum:]]} $filename {}]
    }
    typemethod _carefulExit {} {
        #* Exit method.

        exit
    }
    typemethod _openbackupfile {} {
        set filename [tk_getOpenFile -defaultextension .txt \
                      -filetypes {{{Backup Config Files} {.txt} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "Backup Config File to open"]
        if {"$filename" ne {}} {
            lappend CDIs_FormTLs \
                  [lcc::ConfigurationEditor \
                   .cdi[_fnametowindow [file rootname [file tail $filename]]] \
                   -cdi $CDI \
                   -offlineedit yes \
                   -loadfile $filename -layoutdb $layoutcontroldb]
        }
    }
    typemethod _newblank {} {
        set nid [$getNIDDialog draw -parent .]
        if {$nid ne {}} {
            lappend CDIs_FormTLs \
                  [lcc::ConfigurationEditor \
                   .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDI -nid $nid \
                   -layoutdb $layoutcontroldb \
                   -offlineedit yes]
        }
    }
    typemethod _editLayoutControlItem {what name args} {
        #puts stderr "*** _editLayoutControlItem '$what' '$name' '$args'"
        switch $what {
            block {
                $editblockW Load "$name" -db $layoutcontroldb
                $layoutcontrolsNB select $editblockW
            }
            turnout {
                $editturnoutW Load "$name" -db $layoutcontroldb
                $layoutcontrolsNB select $editturnoutW
            }
            sensor {
                $editsensorW Load "$name" -db $layoutcontroldb
                $layoutcontrolsNB select $editsensorW
            }
            control {
                $editcontrolW Load "$name" -db $layoutcontroldb
                $layoutcontrolsNB select $editcontrolW
            }
        }
    }
    typemethod _ViewLayoutControlDB {} {
        if {$layoutControlView eq {}} {
            set layoutControlView [toplevel .layoutControlView]
            wm withdraw  .layoutControlView
            wm transient .layoutControlView .
            wm title     .layoutControlView [_ "Layout Control Database"]
            wm protocol  .layoutControlView WM_DELETE_WINDOW \
                  [list wm withdraw  .layoutControlView]
            set scrollw [ScrolledWindow .layoutControlView.scrollw]
            pack $scrollw -expand yes -fill both
            set layoutControlTable [::lcc::LayoutControlDBTable \
                                    [$scrollw getframe].layoutControlTable \
                                    -itemeditor [mytypemethod _editLayoutControlItem]]
            $scrollw setwidget $layoutControlTable
            set layoutControlsLF [ttk::labelframe \
                                  .layoutControlView.layoutControlsLF \
                                  -text [_m "Label|Layout Controls"]]
            pack $layoutControlsLF -fill x
            set layoutcontrolsNB [ScrollTabNotebook \
                                  $layoutControlsLF.layoutcontrolsNB]
            pack $layoutcontrolsNB -fill both -expand yes
            set editturnoutW [::lcc::NewTurnoutWidget \
                              $layoutcontrolsNB.editturnoutW \
                              -edit true]
            $layoutcontrolsNB add $editturnoutW -text [_m "Label|Turnout"]
            set editblockW [::lcc::NewBlockWidget \
                              $layoutcontrolsNB.editblockW \
                              -edit true]
            $layoutcontrolsNB add $editblockW -text [_m "Label|Block"]
            set editsensorW [::lcc::NewSensorWidget \
                              $layoutcontrolsNB.editsensorW \
                              -edit true]
            $layoutcontrolsNB add $editsensorW -text [_m "Label|Sensor"]
            set editcontrolW [::lcc::NewControlWidget \
                              $layoutcontrolsNB.editcontrolW \
                              -edit true]
            $layoutcontrolsNB add $editcontrolW -text [_m "Label|Control"]
            #set editturnoutW [::lcc::NewTurnoutWidget \
            #                  $layoutcontrolsNB.editturnoutW \
            #                  -edit true]
            #$layoutcontrolsNB add $editturnoutW -text [_m "Label|Turnout"]
            set buttons [ButtonBox .layoutControlView.buttons \
                         -orient horizontal]
            pack $buttons -fill x
            $buttons add ttk::button refresh \
                  -text [_m "Label|Refresh"] \
                  -command [mytypemethod _reloadLayoutControlTable]
            $buttons add ttk::button close \
                  -text [_m "Label|Close Window"] \
                  -command [list wm withdraw  .layoutControlView]
            
        }
        $layoutControlTable configure -db $layoutcontroldb
        $layoutControlTable Refresh
        wm deiconify $layoutControlView
    }
    typemethod _reloadLayoutControlTable {} {
        $layoutControlTable Refresh
    }
}

        
    

