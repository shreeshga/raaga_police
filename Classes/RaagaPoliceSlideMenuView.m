//
//  Created by Björn Sållarp on 2008-10-04.
//  Copyright MightyLittle Industries 2008. All rights reserved.
//
//  Read my blog @ http://jsus.is-a-geek.org/blog
//

#import "RaagaPoliceSlideMenu.h"


@implementation SlideMenuView
@synthesize menuScrollView, rightMenuImage, leftMenuImage;
@synthesize menuButtons;

-(id) initWithFrameColorAndButtons:(CGRect)frame backgroundColor:(UIColor*)bgColor  buttons:(NSMutableArray*)buttonArray  {
	
	if (self = [super initWithFrame:frame]) {
		
		// Initialize the scroll view with the same size as this view.
		menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		
		// Set behaviour for the scrollview
		menuScrollView.backgroundColor = bgColor;
		menuScrollView.showsHorizontalScrollIndicator = FALSE;
		menuScrollView.showsVerticalScrollIndicator = FALSE;
		menuScrollView.scrollEnabled = YES;
		menuScrollView.bounces = FALSE;
		menuScrollView.opaque = FALSE;
		// Add ourselves as delegate receiver so we can detect when the user is scrolling.
		menuScrollView.delegate = self;
		
		// Add the buttons to the scrollview
		menuButtons = buttonArray;
		
		float totalButtonWidth = 0.0f;
		
		for(int i = 0; i < [menuButtons count]; i++)
		{
			UIButton *btn = [menuButtons objectAtIndex:i];
			
			// Move the buttons position in the x-demension (horizontal).
			CGRect btnRect = btn.frame;
			btnRect.origin.x = totalButtonWidth;
			[btn setFrame:btnRect];
			
			// Add the button to the scrollview
			[menuScrollView addSubview:btn];
			
			// Add the width of the button to the total width.
			totalButtonWidth += btn.frame.size.width;
		}
		
		// Update the scrollview content rect, which is the combined width of the buttons
		[menuScrollView setContentSize:CGSizeMake(totalButtonWidth, self.frame.size.height)];
		
		[self addSubview:menuScrollView];		
	}
	return self;
}



- (id) initWithFrameAndAnimaton:(CGRect) frame {



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

- (void) highlightButtonAtIndex:(NSUInteger) currIndex	{

	UIButton* btn = [menuButtons objectAtIndex:currIndex];
	btn.highlighted = YES; 
}

- (void) deselectButtonAtIndex: (NSUInteger) currIndex {
	
	UIButton* btn = [menuButtons objectAtIndex:currIndex];
	btn.highlighted = NO; 
}

- (void) bounceItemAtIndex:(NSUInteger) index {


}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[menuButtons release];
	[rightMenuImage release];
	[leftMenuImage release];
	[menuScrollView release];
    [super dealloc];
}


@end
