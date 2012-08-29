//
//  RaagaList.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 05/09/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SwaraBallDelegate;
@interface RaagaList : UIView <UIScrollViewDelegate> {
	UIScrollView *ragaListScrollView;
	SwaraBallDelegate* swaraDelegate;
	NSMutableArray* swaraBalls;

@public
	NSMutableArray* labels;
	int* hitList;
	bool isBouncing;
}

@property (nonatomic, retain) UIScrollView* ragaListScrollView;
@property (nonatomic,assign) NSMutableArray* labels;
@property (nonatomic,assign) int* hitList;
@property (nonatomic,assign) bool isBouncing;

- (void) createBalls;
- (void) resetBalls;
@end
