//
//  RaagaPoliceNote.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 17/08/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import "RaagaPoliceNote.h"


@implementation RaagaPoliceNote

@synthesize m_offSet;
/**
 India Raagas are in equal temper mode. The different swaras are in a fixed proportion from the starting Swara.
 */
static float swaraRatio[] = {
							1,		// Sa 
							10.0/9,  //re
							9.0/8,   // RE
							5.0/4,   //ga
							81.0/64, //GA
							45.0/32, //ma
							64.0/45, //MA
							3.0/2,   //pa
							5.0/3,	//dha
							27.0/16, //DHA
							16.0/9,	//15.0/8,  //ni
							9.0/5,  // 31.0/16, //NI
							31.0/16 //2 Sa`
							};




//static float swaraFreqs[][4] = {
//	{65,130,260,522},//SA
//	{69,138,278,556},//ri
//	{72,145,296,582},//RA 9/8 10/9
//	{75,155,322,622},//ga
//	{82,163,328,654},//GA 5/4
//	{87,174,349,698},//ma
//	{92,183,370,740},//MA 17/12, 7/5, 10/7
//	{98,195,396,784},//PA
//	{103,207,415,830},//da
//	{110,220,440,880},//DA
//	{116,233,466,932},//ni
//	{122,245,495,987},//NI
//	
//};

- (void) init:(double)baseId baseFreq:(double)baseFreq {
	//float array[12] = {1,10.0/9,9.0/8,5.0/4,81.0/64,45.0/32,64.0/45,3.0/2,5.0/3,27.0/16,15.0/8,31.0/16};
	//swaraRatio = [[[NSArray alloc] initWithObjects:(id*)array count:12] retain];
	swaras = [[[NSArray alloc] initWithObjects:@"SA",@"ri",@"RI",@"ga",@"GA",@"ma",@"MA",@"PA",@"da",@"DA",@"ni",@"NI",@"SA'",nil] retain];
	notes = [[[NSArray alloc] initWithObjects:@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B",nil] retain];
		
	startKattai = baseKattai = 130.0;//261.1;
	m_baseFreq = baseFreq;
 	m_baseId = baseId;
	m_offSet = 0;
}

- (NSString*) getNoteStr:(double) freq {
	int id = [self getNoteId:freq];
	if (id == -1) return [NSString string] ;
	// Acoustical Society of America Octave Designation System
	//int octave = 2 + id / 12;
	return [notes objectAtIndex:(id + m_offSet) % 12];
}

- (UInt32) getNoteNum:(int) id {
	// C major scale
	int n = id % 12;
	return (n + (n > 4)) / 2;
}

- (bool)isSharp:(int) id {
	if (id < 0) return false;
	// C major scale
	switch (id % 12) {
		case 1: case 3: case 6: case 8: case 10: return true;
	}
	return false;
}

- (double) getNoteFreq:(int) id {
	if (id == -1) return 0.0;
	return m_baseFreq * pow(2.0, (id - m_baseId) / 12.0);
}

- (int) getNoteId:(double) freq  {
	double note = [self getNote:freq];
	if (note >= 0.0 && note < 100.0) return (int)(note + 0.5);
	return -1;
}

- (double) getNote:(double) freq {
	if (freq < 1.0) return [[NSDecimalNumber notANumber] doubleValue];
	return m_baseId + 12.0 * log(freq / m_baseFreq) / log(2.0);
}

- (double) getNoteOffset:(double) freq {
	double frac = freq / [self getNoteFreq:[self getNoteId:freq]];
	return 12.0 * log(frac) / log(2.0);
}

- (float) checkNoteIsHit:(int)note with:(float) freq {
	float found = 0;
//	if(freq > (baseKattai * [[swaraRatio objectAtIndex:note] floatValue] + 4)) {
//		//found =freq -  baseKattai * [[swaraRatio objectAtIndex:note] floatValue];
//	}
//	else if (freq < (baseKattai * [[swaraRatio objectAtIndex:note] floatValue]- 4)) { 
//		//found = freq - baseKattai * [[swaraRatio objectAtIndex:note] floatValue];
//	} 
//	else
//		found = YES;	
	if(freq > (startKattai  * swaraRatio[note] + 4) ||
	   freq < (startKattai * swaraRatio[note]  - 4) )		{
		found =freq -  startKattai * swaraRatio[note];
	}
//	for(int i =0;i<4;i++)
//	if((freq > swaraFreqs[note][i]+ 4 ) || (freq < swaraFreqs[note][i] - 4)) {
//		found = freq - swaraFreqs[note][i];
//	}	
//	else {
//		found = 0;	
//		break;
//	}
	return found;
}


- (void) setScale:(NSUInteger) scale {
//	startKattai = baseKattai  * pow(2, scale* .0833);
	switch (scale) {
		case 0:
			startKattai = baseKattai * pow(2, 0 * .0833);	
			break;
		case 1:
			startKattai = baseKattai * pow(2, 5 * .0833);	
			break;
		case 2:
			startKattai = baseKattai * pow(2, 11 * .0833);	
			break;
		default:
			break;
	}
}

- (void) dealloc {
	[super dealloc];
	//[swaraRatio release];
	[notes release];
	[swaras release];
}
@end
