#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Aug 1 17:21:35 2021
#  Last Modified : <210802.1525>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2021  Robert Heller D/B/A Deepwoods Software
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


package require csv
package require snit
package require vfs::zip
package require vfs::mk4
package require ZipArchive
package require gettext
package require RollingStock
package require RollingStockEditor
package require MainWindow

set argv0 [file join [file dirname [info nameofexecutable]] [file rootname [file tail [info script]]]]
package require Version
namespace export _*
global ImageDir 
set ImageDir [file join [file dirname [file dirname [info script]]] \
              EILib]
global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
                                                    [info script]]]] Help]
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname\
                                                         [file dirname \
                                                          [info script]]]] \
                                                         Messages]]

snit::type EquipmentInventory {
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no
    typecomponent main
    typecomponent rollingstock
    typeconstructor {
        set main [mainwindow .main]
        pack $main -expand yes -fill both
        set rollingstock [RollingStockEditor [$main scrollwindow getframe].rse]
        $main scrollwindow setwidget $rollingstock
        $main menu entryconfigure file "New" -command [mytypemethod _new]
        $main menu entryconfigure file "Open..." -command [mytypemethod _open]
        $main menu entryconfigure file "Save" -command [mytypemethod _save]
        $main menu entryconfigure file "Save As..." -command [mytypemethod _saveas]
        $main menu entryconfigure file "Exit" -command [mytypemethod _exit]
        $main menu delete file "Close"
        $main showit
    }
    typemethod _new {} {
        RollingStock DeleteAll
        $rollingstock Refresh
    }
    typevariable filename_ "rollingstock.csv"
    typemethod _open {} {
        set filename [tk_getOpenFile -defaultextension .csv \
                      -filetypes {{{CSV Files} {.csv} TEXT}
                      {{All Files} *     TEXT}
                  } -parent . -title "Rolling Stock File to open"]
        if {"$filename" eq ""} {return}
        RollingStock ReadFile $filename
        $rollingstock Refresh
        set filename_ $filename
    }
    typemethod _save {} {
        $type _saveas $filename_
    }
    typemethod _saveas {{filename {}}} {
        if {"$filename" eq ""} {
            set filename [tk_getSaveFile -defaultextension .csv \
                          -filetypes {{{CSV Files} {.csv} TEXT}
                          {{All Files} *     TEXT}
                      } -parent . -title "Rolling Stock File to save to"]
        }
        if {"$filename" eq ""} {return}
        RollingStock WriteFile $filename
        set filename_ $filename
    }
    typemethod _exit {} {
        ::exit
    }
}
