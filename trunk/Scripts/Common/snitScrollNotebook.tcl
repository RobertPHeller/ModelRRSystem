#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Feb 27 15:54:05 2016
#  Last Modified : <160228.0835>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
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

package require gettext
package require Tk
package require tile
package require snit

## @addtogroup TclCommon
# @{


snit::widget ScrollTabNotebook {
    ## @brief Tabbed Notebook with scrollable tabs.
    #
    
    widgetclass ScrollTabNotebook
    hulltype ttk::frame
    
    option -style -default ScrollTabNotebook
    delegate option -width to hull
    delegate option -height to hull
    typeconstructor {
        ttk::style configure ScrollTabNotebook \
              -background [ttk::style lookup TFrame -background] \
              -tabbackground [ttk::style lookup TFrame -background]
        ttk::style map ScrollTabNotebook \
              -tabbackground \
              [list active [ttk::style lookup TFrame -background active] \
               disabled [ttk::style lookup TFrame -background disabled]]
        ttk::style layout ScrollTabNotebook {
            leftarrow -side left 
            rightarrow -side right
        }
        ttk::style configure ScrollTabNotebook.leftarrow \
              -relief flat -padding {0 0} -shiftrelief 0
        ttk::style configure ScrollTabNotebook.rightarrow \
              -relief flat -padding {0 0} -shiftrelief 0
        puts stderr "*** $type typeconstructor: [ttk::style layout ScrollTabNotebook]"
        puts stderr "*** $type typeconstructor: [ttk::style configure ScrollTabNotebook.leftarrow]"
        puts stderr "*** $type typeconstructor: [ttk::style configure ScrollTabNotebook.rightarrow]"
        
        bind $type <<ThemeChanged>> [mytypemethod _themeChanged %W]
    }
    typemethod _themeChanged {w} {
        ## @privatesection @brief Theme Changed typemethod.
        #
        # @param w The widget the theme changed for.
        
        $w _themeChanged_
    }
    method _themeChanged_ {} {
        ## @@brief Theme Changed method.
        #
        
        #$hull configure -background [ttk::style lookup $options(-style) \
        #-background {} ""]
    }
    
    component left;
    ## Left arrow button.
    component tabs;
    ## Scrolling tab frame (canvas).
    component right;
    ## Right arrow button.
    component curpage;
    ## The current page.
    
    typevariable _left {
#define left_width 16
#define left_height 16
static unsigned char left_bits[] = {
   0x00, 0x70, 0x00, 0x7e, 0x00, 0x7e, 0x80, 0x7f, 0xf0, 0x7f, 0xfe, 0x7f,
   0xfe, 0x7f, 0xff, 0x7f, 0xff, 0x7f, 0xfe, 0x7f, 0xfe, 0x7f, 0xf0, 0x7f,
   0x80, 0x7f, 0x00, 0x7e, 0x00, 0x7e, 0x00, 0x70};
    }
    ## Bitmap for the left button.
    typevariable _right {
#define right_width 16
#define right_height 16
static unsigned char right_bits[] = {
   0x08, 0x00, 0x78, 0x00, 0x78, 0x00, 0xf8, 0x01, 0xf8, 0x0f, 0xf8, 0x7f,
   0xf8, 0x7f, 0xf8, 0xff, 0xf8, 0xff, 0xf8, 0x7f, 0xf8, 0x7f, 0xf8, 0x0f,
   0xf8, 0x01, 0x78, 0x00, 0x78, 0x00, 0x08, 0x00};
    }
    ## Bitmap for the right button.
    variable pages {}
    variable pages_opts -array {}

    constructor {args} {
        ## @publicsection @brief Constructor: create a ScrollTabNotebook.
        #
        # @param name Pathname of the widget.
        # @param ... Options:
        # @arg -style Widget style.
        # @par
        
        set options(-style) [from args -style]
        set tabrow [frame $win.tabrow -borderwidth 0]
        grid $tabrow -row 0 -column 0 -sticky news
        install left using ttk::button $tabrow.leftarrow \
              -image [image create bitmap -data $_left] \
              -command [mymethod _scrolltabsleft]
        #                       -style ${options(-style)}.leftarrow
        pack $left -side left
        install tabs using canvas $tabrow.tabs \
              -background [ttk::style lookup $options(-style) -tabbackground] \
              -height 26
        pack $tabs  -fill x -side left -expand yes
        install right using ttk::button $tabrow.rightarrow \
              -image [image create bitmap -data $_right] \
              -command [mymethod _scrolltabsright]
        #               -style ${options(-style)}.rightarrow
        pack $right -side right
        grid columnconfigure $win 0 -weight 0 -pad 0
        grid columnconfigure $win 2 -weight 0 -pad 0
        set curpage {}
        $self configurelist $args
        
    }
    method add {window args} {
        #puts stderr "*** $self add $window $args"
        set pindex [lsearch -exact $pages $window]
        if {$pindex < 0} {
            lappend pages $window
            $self _addtab $window $args
            if {$curpage eq {}} {
                $self _tabclick $window
            }
            $self _recompute_sizes
        } else {
        }
    }
    method _recompute_sizes {} {
        set wmax 0
        set hmax 0
        update idletasks
        foreach page $pages {
            set w    [winfo reqwidth  $page]
            set h    [winfo reqheight $page]
            set wmax [expr {$w>$wmax ? $w : $wmax}]
            set hmax [expr {$h>$hmax ? $h : $hmax}]
        }
        #puts stderr "*** $self compute_size: wmax = $wmax, hmax = $hmax"
        $win configure -width $wmax -height [expr {$hmax + 15}]
    }
    method _addtab {window theargs} {
        #puts stderr "*** $self _addtab $window $theargs"
        foreach o {-state -sticky -padding -text -image -compound -underline} {
            switch -- $o {
                -state {
                    set pages_opts($window,$o) [from theargs $o normal]
                }
                -sticky -
                -padding -
                -text -
                -image -
                -underline {
                    set pages_opts($window,$o) [from theargs $o {}]
                }
                -compound {
                    set pages_opts($window,$o) [from theargs $o none]
                }
            }
        }
        if {[llength $theargs] > 0} {
            error [_ "Unknown option: %s" [lindex $theargs 0]]
        }
            
        set compound $pages_opts($window,-compound)
        if {$compound eq "none"} {
            if {$pages_opts($window,-image) ne {}} {
                set compound image
            } else {
                set compound text
            }
        } elseif {$pages_opts($window,-image) eq {}} {
            set compound text
        } elseif {$pages_opts($window,-text) eq {}} {
            set compound image
        }
        set x [lindex [$tabs bbox all] 2]
        if {$x eq {}} {set x 0}
        set x [expr {$x + 5}]
        set tag $window
        switch $compound {
            text {
                set id [$tabs create text $x 3 -anchor nw \
                        -text $pages_opts($window,-text) \
                        -font [ttk::style lookup TNotebook -font] \
                        -tags $tag]
            }
            image {
                set id [$tabs create image $x 3 -anchor nw \
                        -image $pages_opts($window,-image) \
                        -tags $tag]
            }
            bottom -
            center {
                set id [$tabs create text 0 0 -anchor nw \
                        -font [ttk::style lookup TNotebook -font]]
                set twidth [lindex [$tabs bbox $id] 2]
                $tabs delete $id
                set id [$tabs create image 0 0 -anchor nw \
                        -image $pages_opts($window,-image)]
                set iwidth [lindex [$tabs bbox $id] 2]
                $tabs delete $id
                set w $twidth
                if {$iwidth > $w} {set w $iwidth}
                set imoff [expr {double($w - $iwidth) / 2.0}]
                set txoff [expr {double($w - $twidth) / 2.0}]
                set id [$tabs create text [expr {$x + $txoff}] 3  \
                        -anchor nw \
                        -text $pages_opts($window,-text) \
                        -font [ttk::style lookup TNotebook -font] \
                        -tags $tag]
                set yim [lindex [$tabs bbox $id] 3]
                set id [$tabs create image [expr {$x + $imoff}] $yim \
                        -anchor nw \
                        -image $pages_opts($window,-image) \
                        -tags $tag]
            }
            top {
                set id [$tabs create text 0 0 -anchor nw \
                        -font [ttk::style lookup TNotebook -font]]
                set twidth [lindex [$tabs bbox $id] 2]
                $tabs delete $id
                set id [$tabs create image 0 0 -anchor nw \
                        -image $pages_opts($window,-image)]
                set iwidth [lindex [$tabs bbox $id] 2]
                $tabs delete $id
                set w $twidth
                if {$iwidth > $w} {set w $iwidth}
                set imoff [expr {double($w - $iwidth) / 2.0}]
                set txoff [expr {double($w - $twidth) / 2.0}]
                set id [$tabs create image [expr {$x + $imoff}] 3 \
                        -anchor nw \
                        -image $pages_opts($window,-image) \
                        -tags $tag]
                set ytx [lindex [$tabs bbox $id] 3]
                set id [$tabs create text [expr {$x + $txoff}] $ytx  \
                        -anchor nw \
                        -text $pages_opts($window,-text) \
                        -font [ttk::style lookup TNotebook -font] \
                        -tags $tag]
            }
            left {
                set id [$tabs create text 0 0 -anchor nw \
                        -font [ttk::style lookup TNotebook -font]]
                set theight [lindex [$tabs bbox $id] 3]
                $tabs delete $id
                set id [$tabs create image 0 0 -anchor nw \
                        -image $pages_opts($window,-image)]
                set iheight [lindex [$tabs bbox $id] 3]
                $tabs delete $id
                set h $theight
                if {$iheight > $h} {set h $iheight}
                set imoff [expr {(double($h - $iheight) / 2.0)+3}]
                set txoff [expr {(double($h - $theight) / 2.0)+3}]
                set id [$tabs create image $x $imoff \
                        -anchor nw \
                        -image $pages_opts($window,-image) \
                        -tags $tag]
                set xtx [lindex [$tabs bbox $id] 2]
                set id [$tabs create text [expr {$x + $xtx}] $txoff  \
                        -anchor nw \
                        -text $pages_opts($window,-text) \
                        -font [ttk::style lookup TNotebook -font] \
                        -tags $tag]
            }
            right {
                set id [$tabs create text 0 0 -anchor nw \
                        -font [ttk::style lookup TNotebook -font]]
                set theight [lindex [$tabs bbox $id] 3]
                $tabs delete $id
                set id [$tabs create image 0 0 -anchor nw \
                        -image $pages_opts($window,-image)]
                set iheight [lindex [$tabs bbox $id] 3]
                $tabs delete $id
                set h $theight
                if {$iheight > $h} {set h $iheight}
                set imoff [expr {double(($h - $iheight) / 2.0)+3}]
                set txoff [expr {double(($h - $theight) / 2.0)+3}]
                set id [$tabs create text $x $txoff  \
                        -anchor nw \
                        -text $pages_opts($window,-text) \
                        -font [ttk::style lookup TNotebook -font] \
                        -tags $tag]
                set xim [lindex [$tabs bbox $id] 2]
                set id [$tabs create image [expr {$x +$xim}] $imoff \
                        -anchor nw \
                        -image $pages_opts($window,-image) \
                        -tags $tag]
            }
        }
        set style [$self cget -style]
        set baseBBox [$tabs bbox $tag]
        #puts stderr "*** $self _addtab: baseBBox = $baseBBox"
        set rcoords [list \
                     [expr {[lindex $baseBBox 0] - 3}] \
                     [expr {[lindex $baseBBox 1] - 3}] \
                     [expr {[lindex $baseBBox 2] + 3}] \
                     [expr {[lindex $baseBBox 3] + 3}] \
                     ]                     
        set id [$tabs create rectangle $rcoords \
                -outline black \
                -width 2 \
                -fill [ttk::style lookup $options(-style) -tabbackground] \
                -tags [list $tag ${tag}_background]]
        $tabs lower $id $tag
        set tleft [lindex [$tabs bbox $tag] 0]
        set tright [lindex [$tabs bbox $tag] 2]
        set twidth [expr {($tright - $tleft) - 4}]
        set xsincr [$tabs cget -xscrollincrement]
        if {$twidth > $xsincr} {
            $tabs configure -xscrollincrement $twidth
        }
        $tabs bind $tag <1> [mymethod _tabclick $tag]
        $tabs configure -scrollregion [$tabs bbox all]
    }        
    #method insert {pos window args} {
    #    set pindex [lsearch -exact $pages $window]
    #    if {$pindex < 0} {
    #        set indx [$self index $pos]
    #        set pages [linsert $pages $indx $indx $window]
    #         $self _inserttab $indx $window $args
    #        $self _tabclick $tag
    #    } else {
    #        $self _tabclick $window
    #    }
    #}
    method _scrolltabsleft {} {
        #puts stderr "*** $self _scrolltabsleft: [$tabs xview]"
        $tabs xview scroll -1 units
    }
    method _scrolltabsright {} {
        #puts stderr "*** $self _scrolltabsright: [$tabs xview]"
        $tabs xview scroll 1 units
    }
            
    
    method _tabclick {tag} {
        if {$curpage eq $tag} {
            return
        } elseif {$curpage ne {}} {
            grid forget $curpage
            $tabs itemconfigure ${curpage}_background -outline black
        }
        grid $tag -row 1 -column 0 \
              -sticky $pages_opts($tag,-sticky) \
              -in $win
        set curpage $tag
        $tabs itemconfigure ${tag}_background -outline {}
        #$tabs itemconfigure ${tag}_background -state active
    }
}

## @}

package provide ScrollTabNotebook 1.0

