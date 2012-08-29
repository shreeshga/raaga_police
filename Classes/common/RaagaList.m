//
//  RaagaList.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 05/09/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import "RaagaList.h"
#import "SwaraBallDelegate.h"

#define RAAGA_BALLS_Y 115
#define RAAGA_BALLS_X 0


@implementation RaagaList

@synthesize labels,hitList,isBouncing;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
	}
    return self;
}

- (void) createScrollView {
	// Initialize the scroll view with the same size as this view.
	ragaListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 150)];
	
	// Set behaviour for the scrollview
	ragaListScrollView.backgroundColor = [UIColor clearColor];
	ragaListScrollView.showsHorizontalScrollIndicator = FALSE;
	ragaListScrollView.showsVerticalScrollIndicator = FALSE;
	ragaListScrollView.scrollEnabled = YES;
	ragaListScrollView.bounces = FALSE;
	ragaListScrollView.opaque = FALSE;
	// Add ourselves as delegate receiver so we can detect when the user is scrolling.
	ragaListScrollView.delegate = self;
	[ragaListScrollView setContentSize:CGSizeMake(800, 150)];
	[self addSubview:ragaListScrollView];

}


- (void) resetBalls:(NSMutableArray*) raaga {
	
	

}

- (void) createBalls:(NSMutableArray*) raaga {
	CAShapeLayer* swara;
	//Create ScrollView
	if(!ragaListScrollView)
		[self createScrollView];
	
	if(swaraBalls) {
		for(int i=0; i < [labels count]; i++) {
			CAShapeLayer* swara  = [swaraBalls objectAtIndex:i];
			[swara removeAllAnimations];
			[swara removeFromSuperlayer];
		}
 		[swaraBalls release];
		ragaListScrollView.layer.sublayers = 0;
	}
	if(labels || hitList) {
		[labels release];
		free(hitList);
	}
	labels = [raaga retain];
	hitList = malloc(sizeof(int) * [labels count]);
	isBouncing=0;
	
	swaraBalls = [[NSMutableArray alloc] init];
	for(int i=0; i < [labels count]; i++) {
		swara = [[CALayer alloc] init];
		swara.bounds = CGRectMake(0, 0, 50, 50);
//		swara.position = CGPointMake(50*(i%6), 50*(i> 5?1:0));
		swara.position = CGPointMake(50*i+25, RAAGA_BALLS_Y);
		swaraDelegate = [[SwaraBallDelegate alloc] init];
		swaraDelegate.parent = self;
		swara.delegate = swaraDelegate;
		[swara setNeedsDisplay];
//		[self.layer addSublayer:swara];
		[ragaListScrollView.layer addSublayer:swara];		
		[swaraBalls addObject:swara];
		[swara release];
		hitList[i] = 0;
		//[self createStars];
		}
}

- (CGColorRef) black {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	return CGColorCreate(colorSpace, components);
}	

//- (void) createStars{
//	
//	NSString *path = [[[NSBundle mainBundle] resourcePath]
//					  stringByAppendingPathComponent:@"star.png"];
//	CFStringRef str = CFStringCreateWithCString(NULL,[path cStringUsingEncoding:NSUTF8StringEncoding] ,kCFStringEncodingUTF8);
//	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, str, kCFURLPOSIXPathStyle, NO);
//	CGDataProviderRef provider = CGDataProviderCreateWithURL(url);
//	CGImageRef starImage = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
//	CALayer* starLayer = [CALayer layer];
//    starLayer.bounds = CGRectMake(0, 0, 30, 30);
//    starLayer.position = CGPointMake(10,0);
//    starLayer.contents = (id)starImage;
//	
//	CGDataProviderRelease(provider);
//	//CGContextDrawImage(ctx, CGRectMake(0, 0,10,10), starImage);
//	
////	CAKeyframeAnimation* disperse = [CAKeyframeAnimation animationWithKeyPath:@"disperse"];
////	CGMutablePathRef drawpath = CGPathCreateMutable();
////	CGPathMoveToPoint(drawpath, NULL, 10., 60);
////	CGPathAddCurveToPoint(drawpath, NULL, 0., 10., 0., 20., 0., 0.);
////	disperse.duration = 1.;
////	disperse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
////	disperse.delegate = self;
////	
////	[starLayer	addAnimation:disperse forKey:@"disperse"];
////	CGPathRelease(drawpath);
//	[ragaListScrollView.layer addSublayer:starLayer];		
//	[starLayer release];
////	CGImageRelease(starImage);
//
//}
//



- (void) bounceBallAtIndex:(NSUInteger) index {
	CAShapeLayer* swara  = [swaraBalls objectAtIndex:index];
	CAKeyframeAnimation* bounce = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounce.removedOnCompletion = NO;
	CGFloat animationDuration = .8;
	
	BOOL stopBouncing = NO;
	CGFloat originalOffsetX = 0;
//	CGFloat originalOffsetY = 150-50*(index>5?1:0);
	//CGFloat originalOffsetY = 100;
	CGFloat originalOffsetY = 50;
	CGFloat offsetDivider = 1.0;
	
	CGMutablePathRef path = CGPathCreateMutable();
//	CGPathMoveToPoint(path, NULL, 50*(index % 6),50*(index>5?1:0));
	CGPathMoveToPoint(path, NULL, 50*(index)+25,RAAGA_BALLS_Y);

	hitList[index] = 1;
	// Add to the bounce path in decreasing excursions from the center
	while (stopBouncing != YES) {
		CGPathAddLineToPoint(path, NULL, 50*(index)+25 , RAAGA_BALLS_Y - originalOffsetY/offsetDivider);
//		CGPathAddLineToPoint(path, NULL, 50*(index%6), 50*(index>5?1:0));
		CGPathAddLineToPoint(path, NULL, 50*(index)+25,RAAGA_BALLS_Y);
		
		offsetDivider += 1.5	;
		animationDuration += 1/offsetDivider;
		if ((abs(originalOffsetX/offsetDivider) < 10) && (abs(originalOffsetY/offsetDivider) < 10)) {
			stopBouncing = YES;
		}
	}
	
	if(index == 5)
		[ragaListScrollView setContentOffset:CGPointMake(260,0) animated: YES];
	
	bounce.path = path;
	bounce.duration = animationDuration;
	bounce.delegate = self;
	CGPathRelease(path);
	//	bounce.autoreverses = YES;
	//	bounce.repeatCount = 2;

	
	[swara addAnimation:bounce forKey:@"bounce"];	
	[swara setNeedsDisplay];
	NSLog(@"Bouncing...");	
}


#pragma mark Animation delegate methods

- (void)animationDidStart:(CAAnimation *)theAnimation {
	isBouncing = 1;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
	isBouncing = 0;
}

- (void) resetBalls {
	for(int i =0 ; i < [labels count] ; i++) {
		hitList[i] = 0;
		CAShapeLayer* swara  = [swaraBalls objectAtIndex:i];
		[swara setNeedsDisplay];
	}
	[ragaListScrollView setContentOffset:CGPointMake(0,0) animated: YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// if the offset is less than 3, the content is scrolled to the far left. This would be the time to show/hide
	// an arrow that indicates that you can scroll to the right. The 3 is to give it some "padding".
	if(scrollView.contentOffset.x <= 3)
	{
		NSLog(@"Scroll is as far left as possible");
	}
	// The offset is always calculated from the bottom left corner, which means when the scroll is as far
	// right as possible it will not give an offset that is equal to the entire width of the content. Example:
	// The content has a width of 500, the scroll view has the width of 200. Then the content offset for far right
	// would be 300 (500-200). Then I remove 3 to give it some "padding"
	else if(scrollView.contentOffset.x >= (scrollView.contentSize.width - scrollView.frame.size.width)-3)
	{
		NSLog(@"Scroll is as far right as possible");
	}
	else
	{
		// The scoll is somewhere in between left and right. This is the place to indicate that the 
		// use can scroll both left and right
	}
	
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[swaraBalls dealloc];
	free(hitList);
	[ragaListScrollView release];
    [super dealloc];
}


@end
