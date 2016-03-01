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
#  Last Modified : <160301.1037>
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
    # This is a Tabbed Notebook widget, with scrollable tabs.  It implements
    # left and right arrows, as needed, to shift the tab row to the left or
    # right to allow for more tabs than will fit in the available space.
    #
    # Options:
    # @arg -style The style to use. The default is ScrollTabNotebook.
    # @arg -width The width in pixels.
    # @arg -height The height in pixels.
    # @par
    
    widgetclass ScrollTabNotebook
    hulltype ttk::frame
    
    option -style -default ScrollTabNotebook
    delegate option -width to hull
    delegate option -height to hull
    typeconstructor {
        ttk::style configure ScrollTabNotebook \
              -background [ttk::style lookup TNotebook -background]
        ttk::style configure ScrollTabNotebook.Tab \
              -background [ttk::style lookup TNotebook.Tab -background]
        ttk::style map ScrollTabNotebook.Tab -background \
              [list selected [ttk::style lookup TNotebook.Tab \
                              -background selected]]
              
        ttk::style configure ScrollTabNotebook.leftarrow \
              -relief flat -padding {0 0} -shiftrelief 0 \
              -background [ttk::style lookup TNotebook.Tab -background]
        ttk::style configure ScrollTabNotebook.rightarrow \
              -relief flat -padding {0 0} -shiftrelief 0 \
              -background [ttk::style lookup TNotebook.Tab -background]
        ttk::style layout ScrollTabNotebook.leftarrow [ttk::style layout TButton]
        ttk::style layout ScrollTabNotebook.rightarrow [ttk::style layout TButton]
        #puts stderr "*** $type typeconstructor: [ttk::style configure ScrollTabNotebook.leftarrow]"
        #puts stderr "*** $type typeconstructor: [ttk::style configure ScrollTabNotebook.rightarrow]"
        
        bind ScrollTabNotebook <<ThemeChanged>> [mytypemethod _themeChanged %W]
        bind ScrollTabNotebook <Configure> [mytypemethod _Configure %W %w %h]
    }
    typemethod _themeChanged {w} {
        ## @privatesection @brief Theme Changed typemethod.
        #
        # @param w The widget the theme changed for.
        
        $w _themeChanged_
    }
    method _themeChanged_ {} {
        ## @brief Theme Changed method.
        #
        
        #$hull configure -background [ttk::style lookup $options(-style) \
        #-background {} ""]
    }
    typemethod _Configure {widget width height} {
        ## @brief Configure typemethod.
        #
        # @param widget The widget the Configure event happened for.
        # @param width The new width.
        # @param height The new height.
        #
        
        $widget _Configure_ $width $height
    }
    method _Configure_ {width height} {
        ## @brief Configure  method.
        #
        # @param width The new width.
        # @param height The new height.
        #
        
        #puts stderr "*** $self _Configure_ $width $height"
        #puts stderr "*** $self _Configure_: \[winfo width $win\] = [winfo width $win]"
        #puts stderr "*** $self _Configure_: \[winfo height $win\] = [winfo height $win]"
        #update idle
        $self _recompute_sizes $width [expr {$height - [winfo reqheight $tabrow]}]
    }



    component tabrow
    ## Row containing the tabs.        
    component left
    ## Left arrow button.
    component tabs
    ## Scrolling tab frame (canvas).
    component right
    ## Right arrow button.
    component curpage
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
    ## The list of available pages.
    variable pages_opts -array {}
    ## The options for the available pages.

    constructor {args} {
        ## @publicsection @brief Constructor: create a ScrollTabNotebook.
        #
        # @param name Pathname of the widget.
        # @param ... Options:
        # @arg -style Widget style.
        # @arg -width The width of the widget.
        # @arg -height The height of the widget.
        # @par
        
        set options(-style) [from args -style]
        install tabrow using frame $win.tabrow -borderwidth 0
        grid $tabrow -row 0 -column 0 -sticky news
        install left using ttk::button $tabrow.leftarrow \
              -image [image create bitmap -data $_left] \
              -command [mymethod _scrolltabsleft] \
              -style ${options(-style)}.leftarrow
        grid columnconfigure $tabrow 0 -weight 0
        install tabs using canvas $tabrow.tabs \
              -background [ttk::style lookup $options(-style) -background] \
              -height 20 -borderwidth 0 \
              -xscrollcommand [mymethod _tabscroll]
        grid $tabs -row 0 -column 1 -sticky news
        grid columnconfigure $tabrow 1 -weight 1
        install right using ttk::button $tabrow.rightarrow \
              -image [image create bitmap -data $_right] \
              -command [mymethod _scrolltabsright] \
                       -style ${options(-style)}.rightarrow
        grid columnconfigure $tabrow 2 -weight 0
        grid columnconfigure $win 0 -weight 1
        set curpage {}
        $self configurelist $args
        update idle
        #puts stderr "*** $type create $self: arrow button heights: [winfo reqheight $left] [winfo reqheight $right]"
        #puts stderr "*** $type create $self: tabs canvas height: [winfo reqheight $tabs]"
        
    }
    method add {window args} {
        ## @brief Add a window to the end of the page list.
        # Adds a new window (page) to the list of managed pages.
        #
        # @param window The window to add.
        # @param ... Tab options:
        # @arg -state The state of the  tab (NOT IMPLEMENTED - state is always 
        #             normal).
        # @arg -sticky The stickyness (as in grid configure ... -sticky).
        # @arg -padding  The padding (as in grid configure ... -padx and -pady).
        # @arg -text  The text of the tab.
        # @arg -image  The image of the tab.
        # @arg -compound The compound of the tab (see the -compound option of
        #                labels and buttons).
        # @arg -underline The underline of the tab label (NOT IMPLEMENTED,
        #                the -underline option is ignored).
        # @par
        
        #puts stderr "*** $self add $window $args"
        set pindex [lsearch -exact $pages $window]
        if {$pindex < 0} {
            lappend pages $window
            $self _addtab $window $args
            if {$curpage eq {}} {
                $self _tabclick $window
            }
            $self _recompute_sizes \
                  [winfo width $win] \
                  [expr {[winfo height $win] - [winfo reqheight $tabrow]}]
        } else {
        }
    }
    method _recompute_sizes {{wmax 0} {hmax 0}} {
        ## @privatesection @brief Recompute sizes.
        #
        # @param wmax The minimum width (default 0).
        # @param hmax The minimum height (default 0).
        
        #update idletasks
        foreach page $pages {
            set w    [winfo width  $page]
            set h    [winfo height $page]
            set wmax [expr {$w>$wmax ? $w : $wmax}]
            set hmax [expr {$h>$hmax ? $h : $hmax}]
        }
        #puts stderr "*** $self compute_size: wmax = $wmax, hmax = $hmax"
        if {[winfo width $win] < $wmax} {
            $win configure -width $wmax
        }
        if {([winfo width $win] - [winfo reqheight $tabrow]) < $hmax} {
            $win configure -height [expr {$hmax + [winfo reqheight $tabrow]}]
        }
    }
    method _addtab {window theargs} {
        ## @brief Add a new tab.
        # Add a new window tab to the list of available pages.
        #
        # @param window The window to add.
        # @param theargs Tab options.  See method add.
        
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
                -outline {} \
                -width 2 \
                -fill [ttk::style lookup ${options(-style)}.Tab -background] \
                -tags [list $tag ${tag}_background]]
        $tabs lower $id $tag
        set tleft [lindex [$tabs bbox $tag] 0]
        set tright [lindex [$tabs bbox $tag] 2]
        set twidth [expr {($tright - $tleft) - 3}]
        set xsincr [$tabs cget -xscrollincrement]
        if {$twidth > $xsincr} {
            $tabs configure -xscrollincrement $twidth
        }
        $tabs bind $tag <1> [mymethod _tabclick $tag]
        $tabs configure -scrollregion [$tabs bbox all]
    }        
    method _scrolltabsleft {} {
        ## Method bound to the left arrow. Scroll left one tab.
        
        #puts stderr "*** $self _scrolltabsleft: [$tabs xview]"
        $tabs xview scroll -1 units
    }
    method _scrolltabsright {} {
        ## Method bound to the right arrow. Scroll right one tab.
        
        #puts stderr "*** $self _scrolltabsright: [$tabs xview]"
        $tabs xview scroll 1 units
    }
    method _tabscroll {first last} {
        ## Method bound to the -xscrollcommand of the tab row canvas.
        # Hides the arrow buttons when not needed.
        #
        # @param first Leftmost position information. Zero means the leftmost
        #              tab is already visible.
        # @param last Rightmost position information. One means the rightmost
        #              tab is already visible.
        
        #puts stderr "*** $self _tabscroll $first $last"
        if {$first <= 0} {
            $left configure -state disabled
            grid forget $left
        } else {
            $left configure -state normal
            grid configure $left -row 0 -column 0 -sticky news
        }
        if {$last >= 1} {
            $right configure -state disabled
            grid forget $right
        } else {
            $right configure -state normal
            grid configure $right -row 0 -column 2 -sticky news
        }        
    }
    
    method _tabclick {tag} {
        ## @brief Method bound to tabs.
        # Method to select a tab.
        #
        # @param tag The tag (window path) for the selected tab.
        
        if {$curpage eq $tag} {
            return
        } elseif {$curpage ne {}} {
            grid forget $curpage
            $tabs itemconfigure ${curpage}_background \
                  -fill [ttk::style lookup ${options(-style)}.Tab -background]
        }
        set padding $pages_opts($tag,-padding)
        set padx [lindex $padding 0]
        if {$padx eq {}} {set padx 0}
        set pady [lindex $padding 1]
        if {$pady eq {}} {set pady 0}
        grid $tag -row 1 -column 0 \
              -sticky $pages_opts($tag,-sticky) \
              -padx $padx -pady $pady \
              -in $win
        set curpage $tag
        $tabs itemconfigure ${tag}_background \
              -fill [ttk::style lookup ${options(-style)}.Tab \
                     -background selected]
        #$tabs itemconfigure ${tag}_background -state 
    }
}

## @}

package provide ScrollTabNotebook 1.0

