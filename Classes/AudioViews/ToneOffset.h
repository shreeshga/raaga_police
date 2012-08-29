//
//  ToneOffset.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 31/10/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>

#import "GLLevelMeter.h"

#define kPeakFalloffPerSec	.7
#define kLevelFalloffPerSec .8
#define kMinDBvalue -80.0

@interface ToneOffset : UIView {
	AudioQueueRef				_aq;
	NSTimer						*_updateTimer;
	CGFloat						_refreshHz;
	float						noteOffset;
	GLLevelMeter				*level;
	UIColor						*_bgColor, *_borderColor;	
	CFAbsoluteTime				_peakFalloffLastFire;
}

@property				AudioQueueRef aq; // The AudioQueue object
@property				CGFloat refreshHz; // How many times per second to redraw
@property				float  noteOffset;
-(void)setBorderColor: (UIColor *)borderColor;
-(void)setBackgroundColor: (UIColor *)backgroundColor;

@end
