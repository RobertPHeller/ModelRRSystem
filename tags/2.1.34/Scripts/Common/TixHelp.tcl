#* 
#* ------------------------------------------------------------------
#* TixHelp.tcl - Tix-based Help system
#* Created by Robert Heller on Tue Nov  1 14:01:42 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
#* Modification History: Nov 4, 2005 Lockdown
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

package require Tix

global HelpDir
# This is the path to the help file directory.  It is computed from
# the script library directory.
# [index] HelpDir!global variable

namespace eval tixHelp {
  variable HLinePattern
  # This is the help file pattern to pick up a help header line.

  set HLinePattern {^([0-9]+)[ 	](.*)$}

  variable HelpHistoryList
  # This is the help history list.

  set HelpHistoryList {}

  variable HelpHistoryListIndex
  # This is the help history index.

  set HelpHistoryListIndex -1

  variable HelpWindowInput 0

  variable HelpWindow
  variable HelpWindow_Command
  variable HelpWindow_TopicTree
  variable HelpWindow_Text
  variable HelpWindow_Buttons
  variable HelpWindow_ModeStatus

  namespace export HelpTopic
  namespace export HelpContext
  namespace export HelpWindow
  namespace export GetTopLevelOfFocus
}

proc tixHelp::GetTopLevelOfFocus {menu} {
# Procedure to get the toplevel that presently has focus.  This is used when
# generic pulldown menus are activated to determine which object the menu
# refers to.
# <in> menu -- this is the menu that was selected.  This is used to select
# which display to search on.
# [index] GetTopLevelOfFocus!procedure

  if {[catch [list winfo toplevel [focus -displayof $menu]] tl]} {
    return {}
  } elseif {[string length "$tl"] > 0} {
    return $tl
  } else {
    return {}
  }
}


if {[lsearch [package names] Tk] >= 0} {
bind HelpText <1> {
    tkTextButton1 %W %x %y
    %W tag remove sel 0.0 end
}
bind HelpText <B1-Motion> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkTextSelectTo %W %x %y
}
bind HelpText <Double-1> {
    set tkPriv(selectMode) word
    tkTextSelectTo %W %x %y
    catch {%W mark set insert sel.first}
}
bind HelpText <Triple-1> {
    set tkPriv(selectMode) line
    tkTextSelectTo %W %x %y
    catch {%W mark set insert sel.first}
}
bind HelpText <Shift-1> {
    tkTextResetAnchor %W @%x,%y
    set tkPriv(selectMode) char
    tkTextSelectTo %W %x %y
}
bind HelpText <Double-Shift-1>	{
    set tkPriv(selectMode) word
    tkTextSelectTo %W %x %y
}
bind HelpText <Triple-Shift-1>	{
    set tkPriv(selectMode) line
    tkTextSelectTo %W %x %y
}
bind HelpText <B1-Leave> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkTextAutoScan %W
}
bind HelpText <B1-Enter> {
    tkCancelRepeat
}
bind HelpText <ButtonRelease-1> {
    tkCancelRepeat
}
bind HelpText <Control-1> {
    %W mark set insert @%x,%y
}
bind HelpText <Left> {
    tkTextSetCursor %W insert-1c
}
bind HelpText <Right> {
    tkTextSetCursor %W insert+1c
}
bind HelpText <Up> {
    tkTextSetCursor %W [tkTextUpDownLine %W -1]
}
bind HelpText <Down> {
    tkTextSetCursor %W [tkTextUpDownLine %W 1]
}
bind HelpText <Shift-Left> {
    tkTextKeySelect %W [%W index {insert - 1c}]
}
bind HelpText <Shift-Right> {
    tkTextKeySelect %W [%W index {insert + 1c}]
}
bind HelpText <Shift-Up> {
    tkTextKeySelect %W [tkTextUpDownLine %W -1]
}
bind HelpText <Shift-Down> {
    tkTextKeySelect %W [tkTextUpDownLine %W 1]
}
bind HelpText <Control-Left> {
    tkTextSetCursor %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
}
bind HelpText <Control-Right> {
    tkTextSetCursor %W [tkTextNextWord %W insert]
}
bind HelpText <Control-Up> {
    tkTextSetCursor %W [tkTextPrevPara %W insert]
}
bind HelpText <Control-Down> {
    tkTextSetCursor %W [tkTextNextPara %W insert]
}
bind HelpText <Shift-Control-Left> {
    tkTextKeySelect %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
}
bind HelpText <Shift-Control-Right> {
    tkTextKeySelect %W [tkTextNextWord %W insert]
}
bind HelpText <Shift-Control-Up> {
    tkTextKeySelect %W [tkTextPrevPara %W insert]
}
bind HelpText <Shift-Control-Down> {
    tkTextKeySelect %W [tkTextNextPara %W insert]
}
bind HelpText <Prior> {
    tkTextSetCursor %W [tkTextScrollPages %W -1]
}
bind HelpText <Shift-Prior> {
    tkTextKeySelect %W [tkTextScrollPages %W -1]
}
bind HelpText <Next> {
    tkTextSetCursor %W [tkTextScrollPages %W 1]
}
bind HelpText <Shift-Next> {
    tkTextKeySelect %W [tkTextScrollPages %W 1]
}
bind HelpText <Control-Prior> {
    %W xview scroll -1 page
}
bind HelpText <Control-Next> {
    %W xview scroll 1 page
}

bind HelpText <Home> {
    tkTextSetCursor %W {insert linestart}
}
bind HelpText <Shift-Home> {
    tkTextKeySelect %W {insert linestart}
}
bind HelpText <End> {
    tkTextSetCursor %W {insert lineend}
}
bind HelpText <Shift-End> {
    tkTextKeySelect %W {insert lineend}
}
bind HelpText <Control-Home> {
    tkTextSetCursor %W 1.0
}
bind HelpText <Control-Shift-Home> {
    tkTextKeySelect %W 1.0
}
bind HelpText <Control-End> {
    tkTextSetCursor %W {end - 1 char}
}
bind HelpText <Control-Shift-End> {
    tkTextKeySelect %W {end - 1 char}
}
bind HelpText <Tab> {
  focus [tk_focusNext %W]
}
bind HelpText <Control-Tab> {
    focus [tk_focusNext %W]
}
bind HelpText <Control-Shift-Tab> {
    focus [tk_focusPrev %W]
}
bind HelpText <Control-i> {
    focus [tk_focusNext %W]
}
bind HelpText <Control-space> {
    %W mark set anchor insert
}
bind HelpText <Select> {
    %W mark set anchor insert
}
bind HelpText <Control-Shift-space> {
    set tkPriv(selectMode) char
    tkTextKeyExtend %W insert
}
bind HelpText <Shift-Select> {
    set tkPriv(selectMode) char
    tkTextKeyExtend %W insert
}
bind HelpText <Control-slash> {
    %W tag add sel 1.0 end
}
bind HelpText <Control-backslash> {
    %W tag remove sel 1.0 end
}
bind HelpText <<Copy>> {
    tk_textCopy %W
}
# Additional emacs-like bindings:

bind HelpText <Control-a> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W {insert linestart}
    }
}
bind HelpText <Control-b> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W insert-1c
    }
}
bind HelpText <Control-d> {
    if {!$tk_strictMotif} {
	%W delete insert
    }
}
bind HelpText <Control-e> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W {insert lineend}
    }
}
bind HelpText <Control-f> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W insert+1c
    }
}
bind HelpText <Control-n> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W [tkTextUpDownLine %W 1]
    }
}
bind HelpText <Control-o> {
    if {!$tk_strictMotif} {
	%W insert insert \n
	%W mark set insert insert-1c
    }
}
bind HelpText <Control-p> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W [tkTextUpDownLine %W -1]
    }
}
if {$tcl_platform(platform) != "windows"} {
	bind HelpText <Control-v> {
	    if {!$tk_strictMotif} {
		tkTextScrollPages %W 1
	    }
	}
}
bind HelpText <Meta-b> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
    }
}
bind HelpText <Meta-f> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W [tkTextNextWord %W insert]
    }
}
bind HelpText <Meta-less> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W 1.0
    }
}
bind HelpText <Meta-greater> {
    if {!$tk_strictMotif} {
	tkTextSetCursor %W end-1c
    }
}
# Macintosh only bindings:

# if text black & highlight black -> text white, other text the same
if {$tcl_platform(platform) == "macintosh"} {
	bind HelpText <FocusIn> {
	    %W tag configure sel -borderwidth 0
	    %W configure -selectbackground systemHighlight -selectforeground systemHighlightText
	}
	bind HelpText <FocusOut> {
	    %W tag configure sel -borderwidth 1
	    %W configure -selectbackground white -selectforeground black
	}
	bind HelpText <Option-Left> {
	    tkTextSetCursor %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
	}
	bind HelpText <Option-Right> {
	    tkTextSetCursor %W [tkTextNextWord %W insert]
	}
	bind HelpText <Option-Up> {
	    tkTextSetCursor %W [tkTextPrevPara %W insert]
	}
	bind HelpText <Option-Down> {
	    tkTextSetCursor %W [tkTextNextPara %W insert]
	}
	bind HelpText <Shift-Option-Left> {
	    tkTextKeySelect %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
	}
	bind HelpText <Shift-Option-Right> {
	    tkTextKeySelect %W [tkTextNextWord %W insert]
	}
	bind HelpText <Shift-Option-Up> {
	    tkTextKeySelect %W [tkTextPrevPara %W insert]
	}
	bind HelpText <Shift-Option-Down> {
	    tkTextKeySelect %W [tkTextNextPara %W insert]
	}

# End of Mac only bindings
}


# Hyperhelp bindings

bind HelpText <g> {
  tixHelp::HelpTextHHGoto %W %x %y
}

bind HelpText <G> {
  tixHelp::HelpTextHHGoto %W %x %y
}

bind HelpText <s> {
  tixHelp::HelpTextHHSearch %W %x %y
}

bind HelpText <S> {
  tixHelp::HelpTextHHSearch %W %x %y
}

bind HelpText <r> {
  tixHelp::HelpTextHHRSearch %W %x %y
}

bind HelpText <R> {
  tixHelp::HelpTextHHRSearch %W %x %y
}

}

proc tixHelp::HelpTextHHGoto {widget x y} {
# Function to implement the g/G key binding.

  variable HelpWindowInput
  set HelpWindowInput 0
  variable HelpWindow_Command
  variable HelpWindow
  $HelpWindow_Command config -label  "Goto:"
  set oldFocus [focus]
  set oldGrab [grab current $HelpWindow]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  [$HelpWindow_Command subwidget entry] delete 0 end
  grab [$HelpWindow_Command subwidget entry]
  focus [$HelpWindow_Command subwidget entry]
  tkwait variable tixHelp::HelpWindowInput
  catch {focus $oldFocus}
  grab release [$HelpWindow_Command subwidget entry]
  if {$oldGrab != ""} {  
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  HelpTopic "[[$HelpWindow_Command subwidget entry] get]"
}

proc tixHelp::HelpTextHHSearch {widget x y} {
# Function to implement the s/S key binding.

  variable HelpWindowInput
  set HelpWindowInput 0
  variable HelpWindow_Command
  variable HelpWindow
  variable HelpWindow_Text
  variable HelpWindow_ModeStatus
  $HelpWindow_Command config -label "Search forward:"
  set oldFocus [focus]
  set oldGrab [grab current $HelpWindow]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  [$HelpWindow_Command subwidget entry] delete 0 end
  grab [$HelpWindow_Command subwidget entry]
  focus [$HelpWindow_Command subwidget entry]
  tkwait variable tixHelp::HelpWindowInput
  catch {focus $oldFocus}
  grab release [$HelpWindow_Command subwidget entry]
  if {$oldGrab != ""} {  
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  set string "[[$HelpWindow_Command subwidget entry] get]"
  set found [[$HelpWindow_Text subwidget text] search -forwards -nocase -- \
    $string insert end]
  if {[string length "$found"] == 0} {
    $HelpWindow_ModeStatus configure -text "'$string' not found!"
  } else {
    [$HelpWindow_Text subwidget text] mark set insert $found
    [$HelpWindow_Text subwidget text] see $found
  }
}

proc tixHelp::HelpTextHHRSearch {widget x y} {
# Function to implement the r/R key binding.

  variable HelpWindowInput
  set HelpWindowInput 0
  variable HelpWindow_Command
  variable HelpWindow
  variable HelpWindow_Text
  variable HelpWindow_ModeStatus
  $HelpWindow_Command configure -label "Search backward:"
  set oldFocus [focus]
  set oldGrab [grab current $HelpWindow]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  [$HelpWindow_Command subwidget entry] delete 0 end
  grab [$HelpWindow_Command subwidget entry]
  focus [$HelpWindow_Command subwidget entry]
  tkwait variable tixHelp::HelpWindowInput
  catch {focus $oldFocus}
  grab release [$HelpWindow_Command subwidget entry]
  if {$oldGrab != ""} {  
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  set string "[[$HelpWindow_Command subwidget entry] get]"
  set found [[$HelpWindow_Text subwidget text] search -backwards -nocase -- \
    $string insert 1.0]
  if {[string length "$found"] == 0} {
    $HelpWindow_ModeStatus configure -text "'$string' not found!"
  } else {
    [$HelpWindow_Text subwidget text] mark set insert $found
    [$HelpWindow_Text subwidget text] see $found
  }
}


proc tixHelp::helptextbt {wname} {
  set bts [bindtags $wname]
  set ti  [lsearch  $bts {Text}]
  set bts [lreplace $bts $ti $ti HelpText]
  bindtags $wname $bts
  return $wname
}

proc tixHelp::CreateHelpWindow {} {
  variable HelpWindow
  variable HelpWindow_Command
  variable HelpWindow_TopicTree
  variable HelpWindow_Text
  variable HelpWindow_Buttons
  variable HelpWindow_ModeStatus
  variable HelpHistoryList
  variable HelpHistoryListIndex

  if {[info exists HelpWindow] && [winfo exists $HelpWindow]} {
    wm deiconify $HelpWindow
    return
  }

  set HelpWindow .helpWindow

  catch [list destroy $HelpWindow]

  toplevel $HelpWindow -class Help
  wm positionfrom $HelpWindow ""
  wm sizefrom $HelpWindow ""
  wm maxsize  $HelpWindow \
	[winfo screenwidth $HelpWindow] [winfo screenheight $HelpWindow]
  wm title $HelpWindow {Hyper Help}

  set titt [tixPanedWindow $HelpWindow.main -orient horizontal]
  pack $titt -expand yes -fill both -padx 4 -pady 4
  set ti   [$titt add ti -expand 1]; $ti config -bd 0
  set tt   [$titt add tt -expand 4 -min 400]; $tt config -bd 0
  set HelpWindow_TopicTree [tixTree $ti.toptree \
				    -command tixHelp::helpTopicCommand \
				    -options {hlist.Separator {>}}]
  pack $HelpWindow_TopicTree -expand yes -fill both -padx 4 -pady 4
  set HelpWindow_Text [tixScrolledText $tt.toptext]
  pack $HelpWindow_Text -expand yes -fill both -padx 4 -pady 4
  focus [helptextbt [$HelpWindow_Text subwidget text]]
  set HelpWindow_ModeStatus [label $HelpWindow.modeStatus -text {} -justify left]
  pack $HelpWindow_ModeStatus -fill x -anchor w -padx 4 -pady 4
  set HelpWindow_Command [tixLabelEntry $HelpWindow.command -label {} -labelside left]
  pack $HelpWindow_Command  -fill x -padx 4 -pady 4
  bind [$HelpWindow_Command subwidget entry] <Return> {
    incr tixHelp::HelpWindowInput
  }
  set HelpWindow_Buttons [tixButtonBox $HelpWindow.buttons -orientation horizontal]
  pack $HelpWindow_Buttons -fill x -padx 4 -pady 4
  set closeButton [$HelpWindow_Buttons add close -text Close -underline 0 -command [list wm withdraw $HelpWindow]]
  wm protocol $HelpWindow WM_DELETE_WINDOW [list wm withdraw $HelpWindow]
  set backButton [$HelpWindow_Buttons add back -text Back -underline 0 -command {tixHelp::HelpBackTopic}]
  set foreButton [$HelpWindow_Buttons add fore -text Forward -underline 0 -command {tixHelp::HelpForwardTopic}]
  set helpButton [$HelpWindow_Buttons add help -text Help -underline 0 -command {tixHelp::HelpTopic Help}]
  BindKeyAccels $HelpWindow {
	<Alt-c> {$tixHelp::HelpWindow_Buttons invoke close;break}
	<Alt-b> {$tixHelp::HelpWindow_Buttons invoke back;break}
	<Alt-f> {$tixHelp::HelpWindow_Buttons invoke fore;break}
	<Alt-h> {$tixHelp::HelpWindow_Buttons invoke help;break}
  }

  global HelpDir
  set index [file join $HelpDir hh.index]
  if {[file readable $index]} {
    variable HelpList
    variable HelpIndex
    set HelpList {}
    set ifp [open $index r]
    while {[gets $ifp line] >= 0} {
      set indexKey [lindex $line 0]
      set fileInfo [lindex $line 1]
      set HelpIndex($indexKey) "$fileInfo"
      lappend HelpList "$indexKey"
      [$HelpWindow_TopicTree subwidget hlist] add $indexKey -text [lindex [split $indexKey {>}] end]
    }
    close $ifp
  }
  
}

proc tixHelp::BindKeyAccels {w bindings} {
  if {[string equal [winfo class $w] {Menu}]} {return}
  foreach {b c} $bindings {
    bind $w $b $c
  }
  foreach c [winfo children $w] {BindKeyAccels $c $bindings}
}

proc tixHelp::helpTopicCommand {indexKey} {
  HelpTopic [lindex [split $indexKey {>}] end] 1 $indexKey
}

proc tixHelp::HelpBackTopic {} {
# Procedure to go ``back'' in the history list.

  variable HelpHistoryList
  variable HelpHistoryListIndex
  if {$HelpHistoryListIndex > 0} {
    incr HelpHistoryListIndex -1
    HelpTopic [lindex $HelpHistoryList $HelpHistoryListIndex] 0
  }
}

proc tixHelp::HelpForwardTopic {} {
# Procedure to go ``forward'' in the history list.

  variable HelpHistoryList
  variable HelpHistoryListIndex
  if {$HelpHistoryListIndex < [expr [llength $HelpHistoryList] - 1]} {
    incr HelpHistoryListIndex
    HelpTopic [lindex $HelpHistoryList $HelpHistoryListIndex] 0
  }
}

proc tixHelp::HelpTopic {{topic {}} {updateHistory 1} {key {}}} {
  global HelpDir
  variable HelpList
  variable HelpIndex
  variable HLinePattern
  variable HelpHistoryList
  variable HelpHistoryListIndex
  variable HelpWindow_Text
  variable HelpWindow_ModeStatus
  variable HelpWindow_TopicTree
 
  CreateHelpWindow

  if {$updateHistory == 1} {
    if {$HelpHistoryListIndex >= 0} {
      set HelpHistoryList [lrange $HelpHistoryList 0 $HelpHistoryListIndex]
      lappend HelpHistoryList "$topic"
      incr HelpHistoryListIndex      
    } else {
      set HelpHistoryList [list "$topic"]
      set HelpHistoryListIndex 0
    }
  }

  if {[string length "$key"] == 0} {
    set an [array names HelpIndex "*$topic"]
    if {[string length "$an"] == 0} {
      $HelpWindow_ModeStatus configure -text "$topic not found"
      return
    } else {
      if {[llength $an] > 1} {
 	set ai [lsearch -exact $an "$topic"]
	if {$ai >= 0} {
	  set key [lindex $an $ai]
	} else {
	  set ai [lsearch -glob $an "*>$topic"]
	  if {$ai >= 0} {
	    set key [lindex $an $ai]
	  } else {
	    set key [lindex [lsort -dictionary $an] 0]
	  }
	}
      } else {
      	set key [lindex $an 0]
      }
    }
  }
  
  [$HelpWindow_Text subwidget text] delete 1.0 end
  set index [lsearch -exact $HelpList $key]
  [$HelpWindow_TopicTree subwidget hlist] see $key
  [$HelpWindow_TopicTree subwidget hlist] selection clear
  [$HelpWindow_TopicTree subwidget hlist] selection set $key
  set fileInfo [set HelpIndex($key)]
  set file [file join $HelpDir [lindex $fileInfo 0]]
  set fpos [lindex $fileInfo 1]
  set buffer {}
  if {[catch [list open $file r] fp]} {
    [$HelpWindow_Text subwidget text]  insert end "Can't load $topic: $fp"
      return
  }
  seek $fp $fpos start
  set headline [gets $fp]
  if {[regsub {^[0-9]+} "$headline" {} newheadline] > 0} {
    set headline [string trim "$newheadline"]
  }
  while {[gets $fp line] >= 0} {
    if {[regexp "$HLinePattern" "$line" whole d1 d2] > 0} {break}
    append buffer "\n$line"
  }
  close $fp
    
  HeaderFormat [$HelpWindow_Text subwidget text] "$headline"
  BodyFormat [$HelpWindow_Text subwidget text] "$buffer"
  [$HelpWindow_Text subwidget text] mark set insert 1.0
  [$HelpWindow_Text subwidget text] see 1.0
}

proc tixHelp::HeaderFormat {text hline} {
# Procedure to format a header line.
  
  global tk_version
  if {$tk_version < 8.0} {
    regsub -nocase medium [$text cget -font] bold x
  } else {
    regsub -nocase normal [font actual [$text cget -font]] bold x
  }
  $text tag configure header -font "$x"
  $text insert end "$hline" header
}

proc tixHelp::BodyFormat {text body} {
# Procedure to format the body.

  global HelpDir
  $text tag configure link -foreground blue -underline 1
  set abspos 0
  while {[regexp -indices "\[<\{\[\]" "$body" ii] > 0} {
    set i [lindex $ii 0]
    set prefix [string range "$body" 0 [expr $i - 1]]
    if {[string compare "[string index $body $i]" {<}] == 0} {
      set j [string first {>} "$body"]
      $text insert end "$prefix" normal
      set link [string range "$body" [expr $i + 1] [expr $j - 1]]
      set body [string range "$body" [expr $j + 1] end]
      set pos [expr $abspos + $i]
      incr abspos [expr $j + 1]
      $text insert end "$link" [list link link$pos]
      $text tag bind link$pos <1> [list tixHelp::HelpTopic "$link"]
    } elseif {[string compare "[string index $body $i]" {[}] == 0} {
      set j [string first {]} "$body"]
      $text insert end "$prefix" normal
      set head [string range "$body" [expr $i + 1] [expr $j - 1]]
      set body [string range "$body" [expr $j + 1] end]
      set pos [expr $abspos + $i]
      incr abspos [expr $j + 1]
      $text insert end "$head" header
    } else {
      set j [string first "\}" "$body"]
      $text insert end "$prefix" normal
      set imagefile [file join $HelpDir \
			[string range "$body" [expr $i + 1] [expr $j - 1]]]
      set body [string range "$body" [expr $j + 1] end]
      set pos [expr $abspos + $i]
      image create photo himg$pos -file $imagefile
      incr abspos [expr $j + 1]
      $text image create end -image himg$pos -align top
    }
  }
  $text insert end "$body" normal
}
    

proc tixHelp::BindTagsAll {} {
# Procedure to set up the XmTrackingLocate bind tag.

  BindTagsW .
}

proc tixHelp::BindTagsW {w} {
# Helper procedure to set up the XmTrackingLocate bind tag.

  if {[lsearch -exact [bindtags $w] XmTrackingLocateTag] < 0} {
    bindtags $w [concat XmTrackingLocateTag [bindtags $w]]
  }
  foreach c [winfo children $w] {
    BindTagsW $c
  }
}
  
proc tixHelp::XmTrackingLocate {widget cursor} {
# Procedure to implement Motif's XmTrackingLocate function.

  variable XmTrackingLocateInfo
  BindTagsAll
  set tl [winfo toplevel $widget]
  set XmTrackingLocateInfo(cursor) "[$tl cget -cursor]"
  set XmTrackingLocateInfo(widget) {}
  set XmTrackingLocateInfo(grab) "[grab current $tl]"
  if {[string length "$XmTrackingLocateInfo(grab)"] > 0} {
    set XmTrackingLocateInfo(grabType) "[grab status $XmTrackingLocateInfo(grab)]"
  }
  $tl configure -cursor "$cursor"
  bind XmTrackingLocateTag <ButtonPress-1> "tixHelp::XmTrackingLocateClick $tl %X %Y;break"
  grab -global $tl
  tkwait variable tixHelp::XmTrackingLocateInfo(widget)
  grab release $tl
  if {[string length "$XmTrackingLocateInfo(grab)"] > 0} {
    if {"$XmTrackingLocateInfo(grabType)" == "global"} {
      grab set -global $XmTrackingLocateInfo(grab)
    } else {
      grab set $XmTrackingLocateInfo(grab)
    }
  }
  return $XmTrackingLocateInfo(widget)  
}

proc tixHelp::XmTrackingLocateClick {tl X Y} {
# XmTrackingLocate binding function.

  variable XmTrackingLocateInfo 
  bind XmTrackingLocateTag <ButtonPress-1> {}
  $tl configure -cursor "$XmTrackingLocateInfo(cursor)"
  set XmTrackingLocateInfo(widget) "[winfo containing $X $Y]"
}
  


proc tixHelp::HelpContext {{widget .}} {
# This procedure pops up an ``On Context'' help dialog.

  set widget "[XmTrackingLocate $widget question_arrow]"
  if {[string length "$widget"] > 0} {
    HelpWindow $widget
  }
}

proc tixHelp::HelpWindow {{widget .}} {
# This procedure pops up help for the current toplevel.

  CreateHelpWindow

  set tl [winfo toplevel $widget]
  set tlClass [winfo class $tl]

  regsub \\$tl $widget tl$tlClass. widgetCL

  while {[regsub -all {\.\.} $widgetCL {.} widgetCL1] > 0} {
    set widgetCL $widgetCL1
  }
  while {[regsub -all {\.$}  $widgetCL {}  widgetCL1] > 0} {
    set widgetCL $widgetCL1
  }

  variable HelpIndex

  set topicL [split $widgetCL {.}]
  while {[llength $topicL] > 0} {
    set topic [join $topicL {.}]
    set an [array names HelpIndex "*$topic"]
    if {[string length "$an"] > 0} break;
    set topicL [lrange $topicL 0 [expr [llength $topicL] - 2]]
  }
  if {[llength $topicL] > 0} {
    HelpTopic $topic
  } else {
    HelpTopic $widgetCL
  }
}


package provide TixHelp 1.0
