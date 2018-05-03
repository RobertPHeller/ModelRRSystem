#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue May 1 09:31:57 2018
#  Last Modified : <180503.1041>
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


package require PCA9685;#  require the PCA9685 package
package require snit;#     require the SNIT OO framework

snit::integer DC_AND_STEPPERAddr -min 0x60 -max 0x7f

snit::enum StepperStyle -values {SINGLE DOUBLE INTERLEAVE MICROSTEP}

snit::enum StepperDir   -values {FORWARD BACKWARD}
snit::integer StepperNumber -min 0 -max 1
snit::integer Steps -min 1 -max 256
snit::type StepperMotor {
    typevariable MICROSTEPS 8
    typevariable MICROSTEP_CURVE [list 0 50 98 142 180 212 236 250 255]
    
    option -controller -readonly yes -default {}
    option -num -readonly yes -default 1 -type StepperNumber
    option -steps -readonly yes -default 200 -type Steps
    
    component MC
    delegate method * to MC
    variable sec_per_step 0.1
    variable steppingcounter 0
    variable currentstep 0
    variable PWMA 
    variable AIN2
    variable AIN1
    variable PWMB
    variable BIN2
    variable BIN1
    
    constructor {args} {
        $self configurelist $args
        set MC [$self cget -controller]
        switch [$self cget -num] {
            0 {
                set PWMA 8
                set AIN2 9
                set AIN1 10
                set PWMB 13
                set BIN2 12
                set BIN1 11
            }
            1 {
                set PWMA 2
                set AIN2 3
                set AIN1 4
                set PWMB 7
                set BIN2 6
                set BIN1 5
            }
        }
    }
    
    method setSpeed {rpm} {
        set sec_per_step [expr {60.0 / ($revsteps * $rpm)}]
        set steppingcounter 0
    }
    
    method oneStep {dir style} {
        StepperDir validate $dir
        StepperStyle validate $style
        set pwm_a [set pwm_b 255]
        switch $style {
            SINGLE {
                if {($currentstep / ($MICROSTEPS / 2)) % 2} {
                    # we're at an odd step, weird
                    if {$dir eq "FORWARD"} {
                        incr currentstep [expr {$MICROSTEPS/2}]
                    } else {
                        incr currentstep [expr {-($MICROSTEPS/2)}]
                    }
                } else {
                    # go to next even step
                    if {$dir eq "FORWARD"} {
                        incr currentstep $MICROSTEPS
                    } else {
                        incr currentstep -$MICROSTEPS
                    }
                }
            }
            DOUBLE {
                if {!(($currentstep / ($MICROSTEPS / 2)) % 2)} {
                    # we're at an even step, weird
                    if {$dir eq "FORWARD"} {
                        incr currentstep [expr {$MICROSTEPS/2}]
                    } else {
                        incr currentstep [expr {-($MICROSTEPS/2)}]
                    }
                } else {
                    # go to next odd step
                    if {$dir eq "FORWARD"} {
                        incr currentstep $MICROSTEPS
                    } else {
                        incr currentstep -$MICROSTEPS
                    }
                }
            }
            INTERLEAVE {
                if {$dir eq "FORWARD"} {
                    incr currentstep [expr {$MICROSTEPS/2}]
                } else {
                    incr currentstep [expr {-($MICROSTEPS/2)}]
                }
            }
            MICROSTEP {
                if {$dir eq "FORWARD"} {
                    incr currentstep 1
                } else {
                    incr currentstep -1
                    # go to next 'step' and wrap around
                    incr currentstep [expr {$MICROSTEPS * 4}]
                    set currentstep [expr {$currentstep % ($MICROSTEPS * 4)}]
                }
                set pwm_a [set pwm_b 0]
                if {$currentstep >= 0 && $currentstep <= $MICROSTEPS} {
                    set pwm_a [lindex $MICROSTEP_CURVE [expr {$MICROSTEPS - $currentstep}]]
                    set pwm_b [lindex $MICROSTEP_CURVE $currentstep]
                } elseif {$currentstep >= ($MICROSTEPS*2) && $currentstep <= ($MICROSTEPS*3)} {
                    set pwm_a [lindex $MICROSTEP_CURVE [expr {($MICROSTEPS*3) - $currentstep}]]
                    set pwm_b [lindex $MICROSTEP_CURVE [expr {$currentstep - ($MICROSTEPS*2)}]]
                } elseif {$currentstep >= ($MICROSTEPS*3) && $currentstep <= ($MICROSTEPS*4)} {
                    set pwm_a [lindex $MICROSTEP_CURVE [expr {$currentstep - ($MICROSTEPS*3)}]]
                    set pwm_b [lindex $MICROSTEP_CURVE [expr {($MICROSTEPS*4) - $currentstep}]]
                }
            }
        }            
        # go to next 'step' and wrap around
        incr currentstep [expr {$MICROSTEPS * 4}]
        set currentstep [expr {$currentstep % ($MICROSTEPS * 4)}]
        
        # only really used for microstepping, otherwise always on!
        setPWM $PWMA 0 [expr {$pwm_a*16}]
        setPWM $PWMB 0 [expr {$pwm_b*16}]
        
        # set up coil energizing!
        set coils [list 0 0 0 0]
        
        if {$style eq "MICROSTEP"} {
            if {$currentstep >= 0 && $currentstep < $MICROSTEPS} {
                set coils [list 1 1 0 0]
            } elseif {$currentstep >= $MICROSTEPS && $currentstep < ($MICROSTEPS*2)} {
                set coils [list 0 1 1 0]
            } elseif {$currentstep >= ($MICROSTEPS*2) && $currentstep < ($MICROSTEPS*3)} {
                set coils [list 0 0 1 1]
            } elseif {$currentstep >= ($MICROSTEPS*3) && $currentstep < ($MICROSTEPS*4)} {
                set coils [list 1 0 0 1]
            }
        } else {
            set step2coils [list [list 1 0 0 0] \
                            [list 1 1 0 0] \
                            [list 0 1 0 0] \
                            [list 0 1 1 0] \
                            [list 0 0 1 0] \
                            [list 0 0 1 1] \
                            [list 0 0 0 1] \
                            [list 1 0 0 1] ]
            set coils [lindex $step2coils [expr {$currentstep / ($MICROSTEPS / 2)}]]
        }
        
        #print "coils state = " + str(coils)
        setPin $AIN2 [lindex $coils 0]
        setPin $BIN1 [lindex $coils 1]
        setPin $AIN1 [lindex $coils 2]
        setPin $BIN2 [lindex $coils 3]
        
        return $currentstep
    }
    method step {steps direction stepstyle} {
        StepperStyle validate $stepstyle
        StepperDir   validate $direction
        
        set s_per_s $sec_per_step
        set lateststep 0
        
        if ($stepstyle eq "INTERLEAVE") {
            set s_per_s [expr {$s_per_s / 2.0}]
        }
        if ($stepstyle eq "MICROSTEP") {
            set s_per_s [expr {$s_per_s / double($MICROSTEPS)}]
            set steps   [expr {$steps * $MICROSTEPS}]
        }
        
        for {set s 0} {$s < $steps} {incr s} {
            set lateststep [$self oneStep $direction $stepstyle]
            after [expr {int($s_per_s * 1000)}]
        }
        if {$stepstyle eq "MICROSTEP"} {
            # this is an edge case, if we are in between full steps, lets just keep going
            # so we end on a full step
            while {$lateststep != 0 && $lateststep != $MICROSTEPS} {
                set lateststep [$self oneStep $direction $stepstyle]
                after [expr {int($s_per_s * 1000)}]
            }
        }
    }
    variable after_step_id {}
    method astep {steps direction stepstyle} {
        if {$after_step_id ne {}} {return}
        StepperStyle validate $stepstyle
        StepperDir   validate $direction
        
        set s_per_s $sec_per_step
        set lateststep 0
        
        if ($stepstyle eq "INTERLEAVE") {
            set s_per_s [expr {$s_per_s / 2.0}]
        }
        if ($stepstyle eq "MICROSTEP") {
            set s_per_s [expr {$s_per_s / double($MICROSTEPS)}]
            set steps   [expr {$steps * $MICROSTEPS}]
        }
        
        $self aOneStep $direction $stepstyle $lateststep $steps $s_per_s
    }
    method aOneStep {direction stepstyle lateststep steps s_per_s} {
        set after_step_id {}
        if {$steps > 0} {
            set lateststep [$self oneStep $direction $stepstyle]
            set after_step_id [after [expr {int($s_per_s * 1000)}] [mymethod aOneStep $direction $stepstyle $lateststep [expr {$steps - 1}] $s_per_s]]
        } elseif {$stepstyle eq "MICROSTEP"} {
            if {$lateststep != 0 && $lateststep != $MICROSTEPS} {
                set lateststep [$self oneStep $direction $stepstyle]
                set after_step_id [after [expr {int($s_per_s * 1000)}] [mymethod aOneStep $direction $stepstyle $lateststep $steps $s_per_s]]
            }
        }
    }
}


snit::enum MotorCommand   -values {FORWARD BACKWARD BRAKE RELEASE}

snit::integer MotorNumber -min 0 -max 3
    
    
snit::type DCMotor {
    option -controller -readonly yes -default {}
    option -num -readonly yes -default 1 -type MotorNumber
    
    component MC
    delegate method * to MC
    variable PWMpin
    variable IN1pin
    variable IN2pin
    
    constructor {args} {
        $self configurelist $args
        set MC [$self cget -controller]
        switch [$self cget -num] {
            0 {
                set PWMpin 8
                set IN1pin 9
                set IN2pin 10
            }
            1 {
                set PWMpin 13
                set IN1pin 12
                set IN2pin 11
            }
            2 {
                set PWMpin 2
                set IN1pin 3
                set IN2pin 4
            }
            3 {
                set PWMpin 7
                set IN1pin 6
                set IN2pin 5
            }
        }
    }
    method run {command} {
        MotorCommand vaidate $command
        switch $command {
            FORWARD {
                setPin $IN2pin 0
                setPin $IN1pin 1
            }
            BACKWARD {
                setPin $IN1pin 0
                setPin $IN2pin 1
            }
            RELEASE {
                setPin $IN1pin 0
                setPin $IN2pin 0
            }
        }
    }
    method setSpeed {speed} {
        if {$speed < 0} {set speed 0}
        if {$speed > 255} {set speed 255}
        setPWM $PWMpin 0 [expr {$speed * 16}]
    }
}

snit::integer PinValue -min 0 -max 1
snit::integer PinIndex -min 0 -max 15

snit::type MotorHAT {
    component pwm
    delegate method * to pwm
    option -address -readonly yes -default 0x60 -type DC_AND_STEPPERAddr
    option -freq -readonly yes -default 1600 -type PCA9685Freq
    variable motors -array {}
    variable steppers -array {}
    constructor {args} {
        $self configurelist $args
        install pwm using PCA9685 ${selfns}_PWM -address [$self cget -address]
        setPWMFreq [$self cget -freq]
        for {set i 0} {$i < 4} {incr i} {
            set motors($i) [DCMotor ${selfns}_Motor$i -controller $selfns -num $i]
        }
        for {set i 0} {$i < 2} {incr i} {
            set steppers($i) [StepperMotor ${selfns}_Stepper$i -controller $selfns -num $i]
        }
    }
    method setPin {pin value} {
        PinIndex validate $pin
        PinValue validate $value
        switch $value {
            0 {
                setPWM $pin 0 4096
            }
            1 {
                setPWM $pin 4096 0
            }
        }
    }
    method getStepper {steps num} {
        Steps validate $steps
        StepperNumber validate $num
        return $steppers($num)
    }
    method getMotor {num} {
        MotorNumber validate $num
        return $motors($num)
    }
}

