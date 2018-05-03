#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue May 1 09:28:17 2018
#  Last Modified : <180501.1352>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
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


package require Tclwiringpi;#  require the Tclwiringpi package
package require snit;#     require the SNIT OO framework

snit::integer PCA9685Addr -min 0x40 -max 0x7f

snit::integer PCA9685Freq -min 24 -max 1526
snit::integer PWMValue    -min 0  -max 4096
snit::integer PWMChannel  -min 0  -max 15

snit::type PCA9685 {
    # Registers/etc:
    typevariable PCA9685_ADDRESS     0x40
    typevariable MODE1               0x00
    typevariable MODE2               0x01
    typevariable SUBADR1             0x02
    typevariable SUBADR2             0x03
    typevariable SUBADR3             0x04
    typevariable PRESCALE            0xFE
    typevariable LED0_ON_L           0x06
    typevariable LED0_ON_H           0x07
    typevariable LED0_OFF_L          0x08
    typevariable LED0_OFF_H          0x09
    typevariable ALL_LED_ON_L        0xFA
    typevariable ALL_LED_ON_H        0xFB
    typevariable ALL_LED_OFF_L       0xFC
    typevariable ALL_LED_OFF_H       0xFD
    # Bits:
    typevariable RESTART             0x80
    typevariable SLEEP               0x10
    typevariable ALLCALL             0x01
    typevariable INVRT               0x10
    typevariable OUTDRV              0x04
    
    option -address -default 0x40 -type ::PCA9685Addr -readonly yes
    variable devicefd {}
    constructor {args} {
        $self configurelist $args
        set devicefd [wiringPiI2CSetup [$self cget -address]]
        $self set_all_pwm 0 0
        wiringPiI2CWriteReg8 $devicefd $MODE2 $OUTDRV
        wiringPiI2CWriteReg8 $devicefd $MODE1 $ALLCALL
        after 5
        set mode1 [wiringPiI2CReadReg8 $devicefd $MODE1]
        set mode1 [expr {$mode1 & ~$SLEEP}]
        wiringPiI2CWriteReg8 $devicefd $MODE1 $mode1
        after 5
    }
    method set_pwm_freq {freq_hz} {
        PCA9685Freq validate $freq_hz
        set prescaleval 25000000.0;#                      25MHz
        set prescaleval [expr {$prescaleval / 4096.0}];#  12-bit
        set prescaleval [expr {$prescaleval / double($freq_hz)}]
        set prescaleval [expr {$prescaleval - 1.0}]
        set prescaleval [expr {int(floor($prescaleval + 0.5))}]
        set oldmode [wiringPiI2CReadReg8 $devicefd $MODE1]
        set newmode [expr {($oldmode & 0x7F) | $SLEEP}]; # sleep
        wiringPiI2CWriteReg8 $devicefd $MODE1 $newmode
        wiringPiI2CWriteReg8 $devicefd $PRESCALE $prescaleval
        wiringPiI2CWriteReg8 $devicefd $MODE1 $oldmode
        after 5
        wiringPiI2CWriteReg8 $devicefd $MODE1 [expr {$oldmode | $RESTART}]
    }
    
    method set_pwm {channel on off} {
        PWMChannel validate $channel
        PWMValue   validate $on
        PWMValue   validate $off
        wiringPiI2CWriteReg8 $devicefd [expr {$LED0_ON_L+4*$channel}] [expr {$on & 0xFF}]
        wiringPiI2CWriteReg8 $devicefd [expr {$LED0_ON_H+4*$channel}] [expr {$on >> 8}]
        wiringPiI2CWriteReg8 $devicefd [expr {$LED0_OFF_L+4*$channel}] [expr {$off & 0xFF}]
        wiringPiI2CWriteReg8 $devicefd [expr {$LED0_OFF_H+4*$channel}] [expr {$off >> 8}]
    }
    method set_all_pwm {on off} {
        wiringPiI2CWriteReg8 $devicefd $ALL_LED_ON_L [expr {$on & 0xFF}]
        wiringPiI2CWriteReg8 $devicefd $ALL_LED_ON_H [expr {$on >> 8}]
        wiringPiI2CWriteReg8 $devicefd $ALL_LED_OFF_L [expr {$off & 0xFF}]
        wiringPiI2CWriteReg8 $devicefd $ALL_LED_OFF_H [expr {$off >> 8}]
    }
}

package provide PCA9685 1.0
