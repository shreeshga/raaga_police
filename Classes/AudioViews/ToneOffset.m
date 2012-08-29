//
//  ToneOffset.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 31/10/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import "ToneOffset.h"

//#import "CAStreamBasicDescription.h"

@interface ToneOffset (ToneOffset_priv)
- (void)layoutMeters;
@end


@implementation ToneOffset

@synthesize noteOffset;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code		
		_refreshHz = 1. / 30.;
		_bgColor = nil;
		_borderColor = nil;
		[self layoutMeters];
	
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		_refreshHz = 1. / 30.;
		[self layoutMeters];
	}
	return self;
}

- (void)layoutMeters
{
	CGRect totalRect;
	CGRect fr;	
	//totalRect = CGRectMake(0., 0., [self frame].size.width + 2., [self frame].size.height);
	totalRect = CGRectMake(0., 0., [self frame].size.width, [self frame].size.height + 2.);

	if (1) {
		fr = CGRectMake(
					totalRect.origin.x +totalRect.size.width, 
					totalRect.origin.y, 
					totalRect.size.width - 2., 
					totalRect.size.height
					);
	} //else {
//	fr = CGRectMake(
//				totalRect.origin.x, 
//				totalRect.origin.y + (totalRect.size.height), 
//				totalRect.size.width, 
//				totalRect.size.height - 2.
//				);
//	}		
	level = [[GLLevelMeter alloc] initWithFrame:fr];
	//else level = [[LevelMeter alloc] initWithFrame:fr];
	
	level.numLights = 30;
	level.vertical = YES; //self.vertical;
	level.bgColor = _bgColor;
	level.borderColor = _borderColor;
	
	[self addSubview:level];
}


- (void) _refresh {	
	level.peakLevel = noteOffset;
	[level setNeedsDisplay];
}


- (void) _init {
	_updateTimer = [NSTimer 
					scheduledTimerWithTimeInterval:_refreshHz 
					target:self 
					selector:@selector(_refresh) 
					userInfo:nil 
					repeats:YES
					];	

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[level dealloc];
    [super dealloc];
}


@end
