#!/usr/bin/wish

canvas .canvas -width 500 -height 250
pack .canvas

set a1 210
set b1 110
set c1 110
set d1  10
set r1 100
set m1 110
set n1 110
set  r 100

global font
set font [list Times -50 italic]
proc LabeledPoint {x y l {anchor s}} {
  global font

  .canvas create oval [expr $x - 5] [expr $y - 5] [expr $x + 5] [expr $y + 5] \
		    -fill black
  if {[regexp {s} "$anchor"] > 0} {
    set texty [expr $y - 2]
  } else {
    set texty [expr $y + 15]
  }
  set l [.canvas create text $x $texty -anchor $anchor -text "$l" -font "$font"]
  set bbox [.canvas bbox $l]
  set arrowx1 [lindex $bbox 0]
  set arrowx2 [lindex $bbox 2]
  set arrowy  [expr [lindex $bbox 1] - 2]
  .canvas create line $arrowx1 $arrowy $arrowx2 $arrowy -arrow last -width 4
}

LabeledPoint $a1 $b1 {a} w
LabeledPoint $c1 $d1 {c} n

.canvas create oval [expr $m1 - $r] [expr $n1 - $r] [expr $m1 + $r] [expr $n1 + $r] \
		    -fill {} -outline black -width 2


set c2 [expr 210 + 250]
set d2 110
set a2 [expr 110 + 250]
set b2  10
set r2 100
set m2 [expr 110 + 250]
set n2 110

LabeledPoint $a2 $b2 {a} n
LabeledPoint $c2 $d2 {c} w

.canvas create oval [expr $m2 - $r] [expr $n2 - $r] [expr $m2 + $r] [expr $n2 + $r] \
		    -fill {} -outline black -width 2



proc printtops {} {
  .canvas postscript -file FinnFigure2a.ps \
		     -pageheight 1.5i -pagewidth 1.5i \
		     -pagex 0i -pagey 0i -pageanchor sw \
		     -height 250 -width 250 \
		     -x 0 -y 0
  .canvas postscript -file FinnFigure2b.ps \
		     -pageheight 1.5i -pagewidth 1.5i \
		     -pagex 0i -pagey 0i -pageanchor sw \
		     -height 250 -width 250 \
		     -x 250 -y 0
}

bind all <q> {exit}
bind all <Q> {exit}
bind all <p> {printtops}
bind all <P> {printtops}

