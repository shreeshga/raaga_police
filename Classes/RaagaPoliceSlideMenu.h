//
//  Created by Björn Sållarp on 2008-10-04.
//  Copyright MightyLittle Industries 2008. All rights reserved.
//
//  Read my blog @ http://jsus.is-a-geek.org/blog
//

#import <UIKit/UIKit.h>


@interface SlideMenuView : UIView <UIScrollViewDelegate> {
	UIScrollView *menuScrollView;
	UIImageView *rightMenuImage;
	UIImageView *leftMenuImage;
	NSMutableArray *menuButtons;
}

-(id) initWithFrameColorAndButtons:(CGRect)frame backgroundColor:(UIColor*)bgColor  buttons:(NSMutableArray*)buttonArray;
- (void) highlightButtonAtIndex:(NSUInteger) currIndex;
- (void) deselectButtonAtIndex: (NSUInteger) currIndex;
- (void) bounceItemAtIndex:(NSUInteger) index;


@property (nonatomic, retain) UIScrollView* menuScrollView;
@property (nonatomic, retain) UIImageView* rightMenuImage;
@property (nonatomic, retain) UIImageView* leftMenuImage;
@property (nonatomic, retain) NSMutableArray* menuButtons;
@end
