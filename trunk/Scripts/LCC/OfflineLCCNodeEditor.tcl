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
#  Last Modified : <230224.1519>
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
# xmlfile - the CDI XML file for the type of node. Required, no default.
# backupconfigfile - [optional] backup config file(s) to edit.
#
# @options OfflineLCCNodeEditorOPTIONS OPTIONS
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
# none.
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
package require LayoutControlDB
package require Dialog
package require ScrollTabNotebook

global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]

#puts stderr "*** HelpDir = $HelpDir"
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
#puts stderr "*** msgfiles = $msgfiles"

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

    typeconstructor {
        #* Type constructor -- create all of the one time computed stuff.
        #* This includes processing the CLI, building the main window and
        #* opening CDIs for any files passed on the command line.
        
        if {[llength $::argv] < 1} {
            error "CDI XML file missing!"
        }
        set fp [open [lindex $::argv 0] r]
        set CDI [ParseXML %AUTO% [read $fp]]
        close $fp
        # Build main GUI window. 
        set mainWindow [mainwindow .main -scrolling yes \
                        -height 480 -width 640]
        pack $mainWindow -expand yes -fill both
        $mainWindow menu entryconfigure file "Exit" -command [mytypemethod _carefulExit]
        $mainWindow menu entryconfigure file "Open..." -command [mytypemethod _openbackupfile]
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
        HTMLHelp setDefaults "$::HelpDir" "index.html#toc"
        set log [ROText [$mainWindow scrollwindow getframe].log \
                 -height 24 -width 80]
        $mainWindow scrollwindow setwidget $log
        foreach f [lrange $::argv 1 end] {
            lcc::ConfigurationEditor .cdi[_fnametowindow $f] -cdi $CDI -offlineedit yes \
                  -loadfile $f
        }
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
}

        
    

