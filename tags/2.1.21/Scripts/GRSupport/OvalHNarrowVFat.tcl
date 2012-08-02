#!/usr/bin/wish8.3

global Corners
array set Corners {
   LL {@LLHNarrowVFat.xbm 100 131 sw}
   LR {@LRHNarrowVFat.xbm 101 132 se}
   UL {@ULHNarrowVFat.xbm 101 132 nw}
   UR {@URHNarrowVFat.xbm 100 131 ne}
}

set w [expr [lindex $Corners(LL) 1] + [lindex $Corners(LR) 1]]
set h [expr [lindex $Corners(LL) 2] + [lindex $Corners(UL) 2]]

canvas .c -width  $w -height $h -borderwidth 0
pack .c

set color [format {#%02x%02x%02x} 254 152 202]

foreach c [array names Corners] {
  set item $Corners($c)
  set bm [lindex $item 0]
  set anchor [lindex $item 3]
  switch -exact -- $anchor {
    sw {.c create bitmap 0  $h -anchor $anchor -foreground $color -bitmap $bm}
    se {.c create bitmap $w $h -anchor $anchor -foreground $color -bitmap $bm}
    nw {.c create bitmap 0   0 -anchor $anchor -foreground $color -bitmap $bm}
    ne {.c create bitmap $w  0 -anchor $anchor -foreground $color -bitmap $bm}
  }
}
