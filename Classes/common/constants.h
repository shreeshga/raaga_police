/*
 *  constants.h
 *  RaagaPolice
 *
 *  Created by shreesh g ayachit on 17/08/10.
 *  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
 *
 */

//#define LOG2_N 13
#define kFFTSIZE (1 << LOG2_N) //32768
// Buffer of input must be <= kFFTSIZE
#define kBUFFERSIZE 32768

#define kBUFFERS 3
// Hardware sample rate
#define kSAMPLERATE 44100

#define AC_MIN_FREQ (1.0/(65.406/44100.0))
#define AC_MAX_FREQ (1.0/(1046.502/44100.0))



#define APP_PUSH_NOTIFICATION_URL @"http://oml.in/apps/raagapolice/apns.php?"
