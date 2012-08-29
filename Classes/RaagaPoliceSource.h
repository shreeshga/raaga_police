//
//  RaagaPoliceSource.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 17/08/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioServices.h>
#import <AudioToolbox/AudioFileStream.h>
#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "constants.h"
#import "RaagaPoliceAppDelegate.h"

@class RaagaPoliceViewController;
@interface RaagaPoliceSource : NSObject {
	
	SInt16 audio_data[kBUFFERSIZE];
	float audio_data_ft[kBUFFERSIZE];
	AudioQueueLevelMeterState *levels;

	UInt32 audio_data_len;

	AudioQueueRef queue;

	AudioFileID sineFile;
	SInt64 startByte;

	bool keep_running;
	volatile bool isThreadExited;
	NSNumber *value;
	NSUInteger currNote;
	RaagaPoliceViewController* parent;
	
}
- (id) init;
- (void) startAudioQueue;
- (void) initWithSineWave;
- (float) getFrequency;
- (void)feedOnAudio;
- (void) stopProcessing;
- (void) startProcessing;

@property (nonatomic,assign) AudioQueueRef queue;
@property int frequency;
@property (nonatomic) AudioFileID sineFile;
@property (nonatomic,retain) NSNumber* value;
@property (nonatomic) NSUInteger currNote;
@property (nonatomic,retain) RaagaPoliceViewController* parent;
@end
