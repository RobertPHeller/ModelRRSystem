#include <LedControl.h>
#include <stdio.h>
#include <string.h>

/** @page SignalDriverMax72xx SignalDriverMax72xx.ino
  * 
  * This is the firmware downloaded to the Ardunio to interface to the MAX72XX
  * LED multiplexer driving the signals.
  */


/*  
 * Create a new LedControl. 
 * We use pins 12,11 and 10 for the SPI interface
 * With our hardware we have connected pin 12 to the DATA IN-pin (1) of the first MAX7221
 * pin 11 is connected to the CLK-pin(13) of the first MAX7221
 * pin 10 is connected to the LOAD-pin(12) of the first MAX7221	 	
 * We will only have a single MAX7221 attached to the arduino 
 */
LedControl lc1=LedControl(12,11,10,1); 

/*
 * Testing control variables.
 */
int s_digit, e_digit, i_digit, i_bits;
boolean test = false;

void setup() {
  /* Set max intensity */
  lc1.setIntensity(0,15);
  /* Set all signals to 'dark' (no lights on). */
  lc1.clearDisplay(0);
  /* Wake up display. */
  lc1.shutdown(0,false);
  /* Announce ourself to the host */
  Serial.begin(115200);
  Serial.println("Signal Driver Max72XX 0.1");
  Serial.print("\n>>");
  Serial.flush();
  test = false;
}

/* Signal Aspects */
#define R_R B00001001 /* Red over Red (Stop) */
#define R_Y B00001010 /* Red over Yellow (Approach Limited) */
#define R_G B00001100 /* Red over Green (Slow Clear) */
#define Y_R B00010001 /* Yellow over Red (Approach) */
#define G_R B00100001 /* Green over red (Clear) */
#define DARK B00000000 /* Dark (all lights off) */

int GetAspectBits(const char *aspectname) {
  /* Test for each signal aspect string and when a match
   * Occurs, return the corresponding bit pattern. */
  if (strcasecmp("R_R",aspectname) == 0) return R_R;
  else if (strcasecmp("R_Y",aspectname) == 0) return R_Y;
  else if (strcasecmp("R_G",aspectname) == 0) return R_G;
  else if (strcasecmp("Y_R",aspectname) == 0) return Y_R;
  else if (strcasecmp("G_R",aspectname) == 0) return G_R;
  else if (strcasecmp("DARK",aspectname) == 0) return DARK;
  else return -1;
}
  
void loop() {
  /* Main loop... */
  char buffer[256]; /* Command line buffer. */
  char p_buffer[32]; /* Test prompt buffer. */
  int  len;         /* Line length. */
  char unused;
  int n;
  
  /* check if in test mode. */
  if (test) {
    /* Display the current test pattern on the current signal. */
    lc1.setRow(0, i_digit, i_bits);
    /* Print the current signal number and the current test pattern. */
    sprintf(p_buffer,"\n%d:%02x>>", i_digit, i_bits);
    Serial.print(p_buffer);
    Serial.flush();
    delay(1000);   /* One second sleep. */
    /* Compute the next pattern and/or signal number. */
    switch(i_bits) {
     case B00000000: /* Last pattern. Next signal number. */
        if (i_digit >= e_digit) { /* Last signal number, go to first signal number. */
         i_digit = s_digit;
        } else { /* Next signal number. */
         i_digit++;
        }
        i_bits  = B00000001; /* First pattern. */
        break;
     case B11111111: /* If at all on, go to all off. */
        i_bits = B00000000;
        break;
     case B10000000: /* If at top LED, go to all on. */
        i_bits = B11111111;
        break;
     default: /* Otherwise, shift left one bit. */
        i_bits = i_bits << 1;
        break;
    }
  }
  /* If there is serial data available... */
  if (Serial.available() > 0) {
    /* If testing, stop the test and clear the signal. */
    if (test) {
      test = false;
      lc1.setRow(0, i_digit, B00000000);
    }
    /* Read a line from the serial port (USB connection
       from the host computer. */
    len = Serial.readBytesUntil('\r',buffer,sizeof(buffer)-1);
    if (len <= 1) {
      /* Reissue command prompt. */
      Serial.print("\n>>");
      Serial.flush();
      return;
    }
    buffer[len] = '\0';
    switch (toupper(buffer[0])) {
      case 'D': /* Clear all signals to Dark. */
        lc1.clearDisplay(0);
        break;
      case 'S': /* Set one signal. */
        {
          
          char aspect[10];
          int  signalnum, aspectbits;
          if (sscanf(buffer,"%c %d %9s",&unused,&signalnum,aspect) != 3) {
            Serial.println("\nSyntax error (Set command)!");
          } else {
            /* Parse aspect string. */
            aspectbits = GetAspectBits(aspect);
            /* Check for legal aspect string. */
            if (aspectbits < 0) {
              Serial.println("\nSyntax error (Bad aspect)!");
            /* Check for legal signal number. */
            } else if (signalnum >= 0 && signalnum < 8) {
              lc1.setRow(0, signalnum, (byte) aspectbits);
            } else {
              Serial.println("\nSyntax error (Bad signal number)!");
            }
          }
          break;
        }
      case 'T': /* 
                 * Test mode. Test one or more signals, lighting LEDs in a sequence of patterns:
                 * First one LED, from bottom to top, then all on, than all off.  Repeat with the
                 * next signal.  After the last signal in the test, start over with the first
                 * signal in the test.  Repeat forever or until another command is sent.
                 */
        /* Parse command, getting the number of conversions.
         * One conversion means no arguments -- test all eight signals.  Two conversions means one
         * argument -- test one signal. Three conversions means two arguments -- test a range of
         * signals. */
        n = sscanf(buffer,"%c %d %d",&unused,&s_digit,&e_digit);
        /* sprintf(p_buffer,"\n*** n = %d",n);
        Serial.println(p_buffer);*/
        /* Fan out on conversion count. */
        switch (n) {
          case 1: /* No arguments -- test all signals. */
            s_digit = 0;
            e_digit = 7;
            i_digit = s_digit;
            i_bits = B00000001;
            test = true;
            break;
          case 2: /* One argument -- test one signal. */
            e_digit = s_digit;
            if (s_digit < 0 || s_digit > 7) {
              Serial.println("\nSyntax error (Bad signal number)!");
              break;
            }
            i_digit = s_digit;
            i_bits = B00000001;
            test = true;
            break;
          case 3: /* Two arguments -- test a range of signals. */
            if (s_digit < 0 || s_digit > 7) {
              Serial.println("\nSyntax error (Bad signal number)!");
              break;
            }
            if (e_digit < 0 || e_digit > 7) {
              Serial.println("\nSyntax error (Bad signal number)!");
              break;
            }
            i_digit = s_digit;
            i_bits = B00000001;
            test = true;
            break;
          default: /* Something else -- spit out an error message. */
            Serial.println("\nUnknown command!");
            break;
        }
        break;
      default:
         Serial.println("\nUnknown command!");
         break;  
    }
    /* Reissue command prompt. */
    Serial.print("\n>>");
    Serial.flush();
  }
}

