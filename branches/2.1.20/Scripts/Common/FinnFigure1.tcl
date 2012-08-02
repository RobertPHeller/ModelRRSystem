#!/usr/bin/wish

canvas .canvas -width 512 -height 512
pack .canvas

set a 200
set b 200
set c 300
set d 300
set r 100


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

LabeledPoint $a $b {a}
LabeledPoint $c $d {c}

.canvas create oval [expr $a - $r] [expr $b - $r] [expr $a + $r] [expr $b + $r] \
		    -fill {} -outline black -width 2
.canvas create oval [expr $c - $r] [expr $d - $r] [expr $c + $r] [expr $d + $r] \
		    -fill {} -outline black -width 2

proc square {x} {return [expr $x * $x]}

set J [expr 2.0*($a-$c)]
set G [expr 2.0*($b-$d)]
set T [expr double([square $a]+[square $b]) - \
	    double([square $c]+[square $d])]

set u [expr (1.0 + ([square $J] / [square $G]))]
set v [expr (-2.0*$a) - ((2.0*$J*$T)/[square $G]) + ((2.0*$J*$b)/$G)  ]
set w [expr [square $a]+[square $b] + [square $T]/[square $G] - 2*$b*$T/$G - [square $r]]


set sqrt [expr sqrt([square $v]-4.0*$u*$w)]

set m1 [expr (-$v + $sqrt)/(2.0*$u)]
set n1 [expr ($T-$J*$m1)/$G]

LabeledPoint $m1 $n1 {m1} sw

set m2 [expr (-$v - $sqrt)/(2.0*$u)]
set n2 [expr ($T-$J*$m2)/$G]

LabeledPoint $m2 $n2 {m2} ne

proc printtops {} {
  .canvas postscript -file FinnFigure1.ps \
		     -pageheight 3i -pagewidth 3i \
		     -pagex 0i -pagey 0i -pageanchor sw
}

bind all <q> {exit}
bind all <Q> {exit}
bind all <p> {printtops}
bind all <P> {printtops}

