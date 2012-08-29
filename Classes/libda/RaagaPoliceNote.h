//
//  RaagaPoliceNote.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 17/08/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RaagaPoliceNote : NSObject {
	//NSArray *swaraRatio;
	NSArray *swaras;
	NSArray *notes;
	float baseKattai;
	float startKattai;
	double m_baseFreq;
	int m_baseId;
	NSUInteger  m_offset;
	
		
}	
- (void) init:(double)baseId baseFreq:(double)baseFreq;
/// get name of note
- (NSString*) getNoteStr:(double)freq;
/// get note number for id
- (UInt32) getNoteNum:(int) id;
/// true if sharp note
- (bool) isSharp:(int) id;
/// get frequence for note id
- (double) getNoteFreq:(int) id;
/// get note id for frequence
- (int) getNoteId:(double) freq;
/// get note for frequence
- (double) getNote:(double) freq;
/// get note offset for frequence
- (double) getNoteOffset:(double) freq;

- (float) checkNoteIsHit:(int) note with:(float) freq;
- (void) setScale:(NSUInteger) scale;
@property (nonatomic,assign) NSUInteger m_offSet;
@end
