//
//  RaagaPoliceSource.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 17/08/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import "RaagaPoliceSource.h"
#import "CAXException.h"
#import "pitch.hh"

#import "fft.hpp"

@interface RaagaPoliceSource () {
Analyzer *analyse;
}
@property (nonatomic) Analyzer* analyse;
@end

@implementation RaagaPoliceSource


@synthesize sineFile,queue,analyse;
@synthesize value,parent,currNote;


#pragma mark - 
#pragma mark Callback
static void listeningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime, UInt32 inNumberPacketsDescriptions, const AudioStreamPacketDescription *inPacketDescs) {
	RaagaPoliceSource *listener = (RaagaPoliceSource *)inUserData;
	SInt16* buffer = (SInt16*)inBuffer->mAudioData;
	UInt32 buffer_length = inBuffer->mAudioDataByteSize;
	
	//[listener setAudioBuffer:(SInt16*)inBuffer->mAudioData length: (UInt32)inBuffer->mAudioDataByteSize];
	@synchronized(listener) {	
		for(int i = 0; i < buffer_length/2;i++) {
			listener->audio_data_ft[i] = buffer[i];
		}
		listener->audio_data_len = buffer_length/2;
	}
	if(listener->analyse && listener->keep_running)
		listener->analyse->input(listener->audio_data_ft,(unsigned int)buffer_length/2);
	AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}



OSStatus readCallback (void  *inClientData,SInt64   inPosition,
					   UInt32   requestCount,void     *buffer, UInt32   *actualCount) {
	OSStatus ret = 0;
	RaagaPoliceSource *listener = (RaagaPoliceSource *)inClientData;
	ret = AudioFileReadBytes (listener->sineFile,
							  false,listener->startByte,
							  &listener->audio_data_len,
							  listener->audio_data);
	if(ret == EOF) {
		
		AudioFileClose(listener->sineFile);
		return false;
	}
	listener->startByte+=listener->audio_data_len;
	[listener copyBuffer:(SInt16*)listener->audio_data length: (UInt32)listener->audio_data_len];
	
	return noErr;
}	


void micStateChanged (void   *inClientData, AudioSessionPropertyID    inID,
						UInt32 inDataSize,const void   *inData) {

	RaagaPoliceSource* data = (RaagaPoliceSource*)inClientData;
	UInt32 micState = *(UInt32*) inData;
	if(inID != kAudioSessionProperty_AudioInputAvailable) return;	

	if (micState) {
	//	RaagaPoliceViewController* parent  = data->parent;
		OSStatus ret  = AudioQueueStart(data->queue, NULL);
		if(ret == noErr) {
			[[data->parent levelMeter] setAq:data->queue];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
															message:@"Mic Plugged in." 
														   delegate:nil 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}	
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
														message:@"Plug the Mic back in" 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

}


#pragma mark - 
#pragma mark Inititalize


- (id) init {
	if ([super init] == nil){
		return nil;
	}
	
	keep_running = true;
	isThreadExited = NO;
	value = [NSNumber alloc];
	[self initAudioQueue];
//	analyse = new Analyzer(kSAMPLERATE);
//	[NSThread detachNewThreadSelector:@selector(feedOnAudio) toTarget:self withObject:nil]; 
	return self;
}


-(void) initAudioQueue {

	AudioStreamBasicDescription format;
	
	Float64 rate=kSAMPLERATE;
	UInt32 size = sizeof(rate);	
	
	try {
		XThrowIfError(AudioSessionInitialize(NULL,NULL,NULL,NULL), "Could not Inititalize Audio Session");
		XThrowIfError(AudioSessionSetProperty (kAudioSessionProperty_PreferredHardwareSampleRate, size, &rate),
					  "Could not Set Property"); 
		
		format.mSampleRate = kSAMPLERATE;
		format.mFormatID = kAudioFormatLinearPCM;
		format.mFormatFlags =  kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
		format.mFramesPerPacket = format.mChannelsPerFrame = 1;
		format.mBitsPerChannel = 16;
		format.mBytesPerPacket = format.mBytesPerFrame = 2;
		
		//	fmt.mSampleRate = 44100;
		//	fmt.mFormatID = kAudioFormatLinearPCM;
		//	fmt.mFormatFlags = kLinearPCMFormatFlagIsFloat;
		//	fmt.mBitsPerChannel = sizeof(Float32) * 8;
		//	fmt.mChannelsPerFrame = 1; // set this to 2 for stereo
		//	fmt.mBytesPerFrame = fmt.mChannelsPerFrame * sizeof(Float32);
		//	fmt.mFramesPerPacket = 1;
		//	fmt.mBytesPerPacket = fmt.mFramesPerPacket * fmt.mBytesPerFrame;
		
		
		XThrowIfError(AudioQueueNewInput(&format, listeningCallback, self, NULL, NULL, 0, &queue),
					  "Could not Set Queue");
		XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, micStateChanged, self),
					  "Failed to Set mic Listener");

		AudioQueueBufferRef buffers[kBUFFERS];
		for (NSInteger i = 0; i < kBUFFERS; ++i) { 
			XThrowIfError(AudioQueueAllocateBuffer(queue, kBUFFERSIZE, &buffers[i]),"Failed to Allocate Buffer"); 
			XThrowIfError(AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL), " Failed to Enqueu Buffer"); 
		}
		
		//XThrowIfError(AudioQueueStart(queue, NULL),"Could not start Audio Queue");
	} 
	catch (CAXException e) {
		char buf[256];
		UInt32 micOn=0;
		UInt32 size = sizeof(micOn);
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		AudioSessionGetProperty (kAudioSessionProperty_AudioInputAvailable, &size, &micOn);
		if(!micOn) {
			if(queue) 
				AudioQueueDispose(queue, true);
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
														message:@"Cannot start Application," 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		return;
	}	
}

/* - (void) stopAudioQueue {
	AudioQueueFlush(queue);
	AudioQueueStop(queue, true);
	AudioQueueDispose(queue, true);
} */

- (void) stopAudioQueue {
	AudioQueuePause(queue);
}

- (void) startAudioQueue {
	//XThrowIfError(AudioQueueStart(queue, NULL),"Could not start Audio Queue");
	try {
		XThrowIfError(AudioQueueStart(queue, NULL),"Could not start Audio Queue");
	}
	catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
}
- (void ) initWithSineWave {
	OSStatus ret;
	SInt64 numBytes =0;
	UInt32 size = sizeof(UInt64);
	UInt64
	fileSize;
	
	NSString *path = [NSString stringWithFormat:@"%@%@",
					  [[NSBundle mainBundle] resourcePath],
					  @"/440Hz-5sec.wav"];
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];

	try {
		audio_data_len= 32768;
		XThrowIfError(AudioFileOpenURL ( (CFURLRef)filePath,
										kAudioFileReadPermission,
										kAudioFileWAVEType,
										&sineFile),
					  "Could not open File");
		XThrowIfError(AudioFileGetProperty(sineFile,kAudioFilePropertyAudioDataByteCount ,
										   &size, &fileSize),"Get Property Error"); 
		do {		
			ret = AudioFileReadBytes (sineFile,
									  false,numBytes,
									  &audio_data_len,
									  audio_data);
			[self copyBuffer:audio_data length:audio_data_len];
			//	NSLog (@"Auto Correlation: %f",autoCorrelation(audio_data,audio_data_len/2));
			if(audio_data_len == 0) break;	
			numBytes+= audio_data_len;
		}while(numBytes <= fileSize );
		
	} catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		return;
	}	
	//XThrowIfError(AudioFileOpenWithCallbacks(self,readCallback,nil,nil,nil,kAudioFileWAVEType,&sineFile),"Could not open File");
	AudioFileClose(sineFile);
}


#pragma mark -
#pragma mark algorithmns

double autoCorrelation(SInt16* samples,int length)
{
	if(length >= AC_MIN_FREQ)
	{
		int lookupCount = AC_MIN_FREQ - AC_MAX_FREQ;
		double* results = (double*) malloc(sizeof(double)*lookupCount);
		for(int p=AC_MAX_FREQ;p<AC_MIN_FREQ;p++)
		{
			double psum = 0.0;
			for(int i=0;i<length-p;i++)
			{
				psum += samples[i]*samples[i+p];
			}
			results[p- (int)AC_MAX_FREQ] = psum / ((double)length);
		}
		double maxFreq = -1.79769313486231E+308;
		int maxIdx = -1;
		for(int i=0;i<lookupCount;i++)
		{
			if(results[i] > maxFreq)
			{
				maxFreq = results[i];
				maxIdx = i;
			}
		}
		free(results);
		return 1.0/((double)(maxIdx+AC_MAX_FREQ)/44100.0);
	}
	return 0.0;
}

#if 0
- (void) performAppleFFT: (short*) buffer totalSamples:(UInt32) totalSamples  {
	//COMPLEX inFFT[kFFTSIZE];
	float inFFT[kFFTSIZE];
	
	for(UInt32 i =0; i< totalSamples*2 ; i++) {
		//		inFFT[i].real = buffer[i];
		//		inFFT[i].imag = 0;
		inFFT[i] = buffer[i];
	}
	
	m_fft_output.realp  = malloc(sizeof(float) * kFFTSIZE);
	m_fft_output.imagp  = malloc(sizeof(float) * kFFTSIZE);
	
	vDSP_ctoz((COMPLEX *) inFFT, 2, &m_fft_output, 1, kFFTSIZE/2);
	vDSP_fft_zrip (		m_fft_setup, 
				   &m_fft_output, 
				   1, 
				   LOG2_N,	// log2 32768
				   kFFTDirection_Forward
				   );
	
	//Get the Amplitude
	for(int i=0 ; i < kFFTSIZE / 2 ; i++) {
		freq_db[i] = sqrt((double)m_fft_output.realp[i] * (double) m_fft_output.realp[i] + 
						  (double)m_fft_output.imagp[i] * (double)m_fft_output.imagp[i])/(kFFTSIZE/2.0);
		
	}
}	

- (Float32) getPeak {
	double max = 0.0;
	UInt32 max_index = 0;
	int range =  kFFTSIZE/2 ;
	/*Find the Peak*/
	for(UInt32 i = 0 ; i < range ; i++) {
		//		float filter = (i * 1.0 * kSAMPLERATE/ kFFTSIZE);
		//		if( filter < 80 || filter > 1100)
		//		{
		//		/* Find in Human vocal range 80Hz - 1100Hz*/
		//			continue;
		//		}
		double db = freq_db_harmonic[i];
		if(db > max) {
			max = db;
			max_index = i;
		}
	}
	
	/* Calculate the Fundamental or "Pitch" if you please, for this sample */
	Float32 ret  = (Float32)max_index * mSampleRate / kFFTSIZE; 
	
	//NSLog(@"freq %f decibel %f @ [%d]",ret,max,max_index);
	return ret;
}


- (Float32) performHPS {
	int fft_range = kFFTSIZE/2;
	double freq_db[fft_range];
	double freq_db_harmonic[fft_range];
	double freq_db_h2[fft_range];
	double freq_db_h3[fft_range];
	double freq_db_h4[fft_range];
	
	memcpy(freq_db_harmonic, freq_db, fft_range);
	
	for(int i=1; i<= (fft_range -1)/2 ; i++) {
		freq_db_h2[i] =  (freq_db[2*i] + freq_db[2*i + 1]) / 2;
	}
	
	for(int i=1; i<= (fft_range -2)/3 ; i++) {
		freq_db_h3[i] =  (freq_db[3*i] + freq_db[3*i + 1] + freq_db[3*i + 2]) / 3;
	}
	
	for(int i=1; i<= (fft_range -3)/4 ; i++) {
		freq_db_h4[i] =  (freq_db[4*i] + freq_db[4*i + 1] + freq_db[4*i + 2] + freq_db[4*i + 3]) / 4;
	}
	
	for(int i = 0 ; i< fft_range ; i++) {
		freq_db_harmonic[i] =  freq_db[i] * freq_db_h2[i] * freq_db_h3[i] * freq_db_h4[i];
	}	
	
	
	return [self getPeak];
}
#endif

- (void)feedOnAudio {
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];	
	isThreadExited = NO;
	//RaagaPoliceSource* me = (RaagaPoliceSource*)param;
	while (keep_running == YES) {
		//NSLog(@" Average Power: %f Peak Power: %f",levels[0].mAveragePower,levels[0].mPeakPower);
		analyse->process();
		//sleep(.1);
	}
	isThreadExited = YES;
	//[[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(setNote:) withObject:value waitUntilDone:NO];
    [pool release];
}

- (float) getFrequency {
	if(!analyse || !keep_running) // Thread has exited.go Back!
		return 0;

//	double f = 440.0 * pow(2.0, (currNote - 33) / 12.0);
	return analyse->findTone(currNote);
}



- (void) stopProcessing {
	
	keep_running = NO;
	currNote = 0;
	while(isThreadExited == NO);
	[self stopAudioQueue];
	delete analyse;
}


- (void) startProcessing {
	[self startAudioQueue];
	[[parent levelMeter] setAq:[self queue]];
	keep_running = YES;
	currNote = 0;
	analyse = new Analyzer(kSAMPLERATE);
	[NSThread detachNewThreadSelector:@selector(feedOnAudio) toTarget:self withObject:nil]; 

}

- (void) dealloc {

	keep_running = false;
	AudioQueueFlush(queue);
	AudioQueueStop(queue, true);
	AudioQueueDispose(queue, true);	
	[value dealloc];
    if(analyse)
		delete analyse;
	[super dealloc];
}

@end
