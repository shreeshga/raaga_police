//
//  RaagaPoliceViewController.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 11/08/10.
//  Copyright OML Digital Productions Pvt Ltd 2010. All rights reserved.
//



#import "RaagaPoliceViewController.h"
#import "RaagaPoliceAppDelegate.h"
#import "SBJSON.h"
#import "DSActivityView.h"

#define SPINNER_VIEW 100
#define kAnimationTime .5 //milliseconds
@implementation RaagaPoliceViewController

@synthesize levelMeter;
@synthesize btn_record;
@synthesize btn_scale;
@synthesize btn_play;
@synthesize btn_buy;
@synthesize btn_info;
//@synthesize message;
@synthesize raagaSource,isRunning;
@synthesize bgImages,scrollView,raagaList,curRaagaName,curListIndx,samplePlayer,jsonArray,purchaseMgr;
@synthesize adBannerView,adBannerViewIsVisible;
- (id)init {
	
	if ([super init] == nil){
		return nil;
	}
//	raagaScale = [[ NSMutableArray arrayWithObjects:@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B",nil] retain];
	raagaScale = [[NSMutableArray arrayWithObjects:@"Mandra Stayi",@"Madhya Stayi",@"Tara Stayi",nil] retain];
	raagaNote = [RaagaPoliceNote alloc];
	purchaseMgr = [InAppPurchaseMgr alloc];
	[raagaNote init:33.0 baseFreq:440.0];
	curListIndx = 0;
	curScale = 0;
	isRunning=0;
	[self loadRaagaList];
//	hitSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"farSound" ofType:@"caf"]];
	return self;
}


//- (void) doBounce:(id) indx {
//	NSAutoreleasePool *pool;
//    pool = [[NSAutoreleasePool alloc] init];	
//
//	[raagaList bounceBallAtIndex:(NSUInteger)indx];
//	[pool release];
//}

- (void) animate {
	//static int bounce =0;
	NSString* string = (NSString*)[curRaagaNotes objectAtIndex:curListIndx];	
	if(curListIndx && [string compare:[curRaagaNotes objectAtIndex:curListIndx-1]] == NSOrderedSame)	
		if([raagaList isBouncing]) { return;}
//		else	 if(bounce) { bounce--; return;} //To avoid bouncing two adjacent equal-note  balls.

	[raagaList bounceBallAtIndex:curListIndx];
	curListIndx ++;
	//raagaSource.currNote = curListIndxs[curListIndx];
//	bounce=28;
	//bounce=10;

	/** Level Completed */
	if (curListIndx == [curRaagaNotes count]) {
		[self levelCompleted];
	}
	else {
		raagaSource.currNote = [[curListIndxs objectAtIndex:curListIndx] intValue];
	}

}


- (void) levelCompleted {
	NSString* lmessage;
	UIAlertView* confirmView;
	curListIndx = 0;
	
	[raagaList resetBalls];
	[self stopRecognizing];
	[btn_record setTitle:@"Start"];	
	[message setHidden:YES];

	/* Prompt to Buy*/
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isProVersion"]) {
		lmessage = [NSString stringWithString:@"You have aced the current Raaga! Want to try more? Click OK to get more Raagas for $0.99"];
		confirmView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"Congrats")
												 message:lmessage
												delegate:self 
									   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK",@"OK"),nil];			
	}
	else {
		lmessage = [NSString stringWithString:@"You have aced the current Raaga! Well Done!"];
		confirmView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Congrats", @"Congrats")
												 message:lmessage
												delegate:self 
									   cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];	
		
	}
	[confirmView show];
	[confirmView release];
	
}

- (void) showFeedback {

	
	UIImageView* animation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedBack.png"]];
	[animation setFrame:CGRectMake(110,260,100,30)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.5];
	[UIView setAnimationRepeatCount:1];
	animation.alpha = 0;
	animation.transform = CGAffineTransformMakeScale (2.0, 2.0);
	[UIView commitAnimations];
	[self.view addSubview:animation];
	[animation release];

}

- (void) checkLoop {	
	CFAbsoluteTime now  = CFAbsoluteTimeGetCurrent();
	float freq = [raagaSource getFrequency];
	if(!isRunning) {
		[levelMeter setNoteOffset:-INFINITY];
		// Image
		return;
	}
	if (freq != 0) {
		float diff = [raagaNote checkNoteIsHit:raagaSource.currNote with:freq];
		if(now - timeSinceBallHit  < kAnimationTime)
			return;
		[levelMeter setNoteOffset:diff];
		/* Yay!!*/
		if(!diff) {
			hitSound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"farSound" ofType:@"caf"]];
			[hitSound play];
			[self showFeedback];
			[self animate];
			timeSinceBallHit = CFAbsoluteTimeGetCurrent();
			[levelMeter setNoteOffset:-INFINITY];
		}
	}
	
}

- (IBAction) buyRaaga: (id)sender {

	UIAlertView* confirmView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm", @"Confirm Buy")
														message:@"Want to buy additional Raagas for $0.99?" 
													   delegate:self 
												cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK",@"OK"),nil];
	[confirmView show];
	[confirmView release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if(buttonIndex == 0) {
		//Cancel Button
		
	
	} else {
		//Ok Button		
		purchaseMgr.delegate = self;
		[DSBezelActivityView newActivityViewForView:self.view withLabel:@"Processing Payment..." width:180];	

//		UIActivityIndicatorView *busy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//		RaagaPoliceAppDelegate* appDel = [[UIApplication sharedApplication] delegate];
//		buyView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Processing", @"Confirm Buy")
//															  message:@"                                    " 
//															 delegate:self 
//													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:nil,nil];
//		
//
//		[buyView addSubview:busy];
//		[busy setCenter:CGPointMake(150,60)];
//		[busy setTag:SPINNER_VIEW];
//		[busy startAnimating];
//		[busy release];
//		
		[purchaseMgr loadStore];
		[purchaseMgr purchaseProUpgrade];
//
//		[buyView show];

	}
	

}

#pragma mark -
#pragma mark TransactionNotification

- (void) transactionComplete {
	NSError* error;
	NSUInteger i=0;
	NSLog(@"transaction complete");
	if(![btn_buy isHidden]) {
		NSLog(@"transaction complete- remove Animation");
		// Remove Busy Message
		[DSBezelActivityView removeViewAnimated:YES];	
		// Load the Raaga List again
		[raagaNames release];
		NSString *path = [[[NSBundle mainBundle] resourcePath]
						  stringByAppendingPathComponent:@"raagas.json"];
		
		
		NSString *jsonString = [[[NSString alloc] initWithContentsOfFile:(NSString*)path encoding:NSUTF8StringEncoding error:&error] autorelease];
		SBJSON *json = [[SBJSON new] autorelease];
		NSDictionary *raagas = [json objectWithString:jsonString error:&error];
		jsonArray = [[raagas objectForKey:@"Raagas"] retain];
		raagaCount =	[[raagas objectForKey:@"Count"] intValue];
		raagaNames = [[NSMutableArray alloc] init];
		while(i < raagaCount) {
			[raagaNames insertObject:[[jsonArray objectAtIndex:i] objectForKey:@"Name"] atIndex:i];
			i++;
		}
		[btn_buy setHidden:YES];
//		UIAlertView *View = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Info")
//															message:@"You have Successfully downloaded adavanced Raagas!" 
//														   delegate:nil 
//												  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
//		[View show];
//		[View release];
	}
//	/* Message */
//	UIAlertView *View = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"Info")
//														message:@"You have Successfully downloaded adavanced Raagas!" 
//													   delegate:nil 
//											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
//	[View show];
//	[View release];
}


- (void) transactionFailed {
	// Remove Busy Message
	//[buyView dismissWithClickedButtonIndex:1 animated:YES];
	int i=0;
	NSLog(@"transaction complete");
	if([DSBezelActivityView currentActivityView]) {
		NSLog(@"transaction complete - remove Animation");
		while([DSBezelActivityView currentActivityView] && i < 1000000) {//Hack!!!
			[DSBezelActivityView removeViewAnimated:NO];	
			i++;
		}
		UIAlertView *View = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
													   message:@"There was some Error, Please try again." 
													  delegate:nil 
											 cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[View show];
		[View release];
	}
}


-(void) loadRaagaList
{
	int i=0;
	NSError* error;
	bool purchased = [[NSUserDefaults standardUserDefaults] boolForKey:@"isProVersion"]; 
	NSString *path = [[[NSBundle mainBundle] resourcePath]
									 stringByAppendingPathComponent:@"raagas.json"];

	
	NSString *jsonString = [[[NSString alloc] initWithContentsOfFile:(NSString*)path encoding:NSUTF8StringEncoding error:&error] autorelease];
	SBJSON *json = [[SBJSON new] autorelease];
	NSDictionary *raagas = [json objectWithString:jsonString error:&error];
	
	if(raagas == nil){
		UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"No Data")
															message:@"No Raagas Available" 
														   delegate:nil 
													cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[errorView show];
		[errorView release];
		return;
	}
	//NSDictionary *concerts = [jsonString JSONValue];
	jsonArray = [[raagas objectForKey:@"Raagas"] retain];
	raagaCount =	[[raagas objectForKey:@"Count"] intValue];
	raagaNames = [[NSMutableArray alloc] init];
	while(i < raagaCount) {
		if(purchased == NO) {
			if([[[jsonArray objectAtIndex:i] objectForKey:@"State"] isEqualToString:@"Unlocked"]) 
				[raagaNames insertObject:[[jsonArray objectAtIndex:i] objectForKey:@"Name"] atIndex:i];
		}
		else
			[raagaNames insertObject:[[jsonArray objectAtIndex:i] objectForKey:@"Name"] atIndex:i];
		i++;
	}
	curRaagaNotes = [[[jsonArray objectAtIndex:curRaagaListIndx] objectForKey:@"Notes"] retain];
	
	NSMutableArray* temp = [[jsonArray objectAtIndex:curListIndx] objectForKey:@"Indices"];
	curListIndxs = [[NSMutableArray alloc] initWithArray:temp];
	curRaagaListIndx =0;
//	curListIndxs = [[NSMutableArray alloc] initWithObjects:0,2,4,7,11,0,0,11,7,4,2,0,nil];
	//TODO: Load levels,scores etc
	[curRaagaName setTitle:[raagaNames objectAtIndex:curRaagaListIndx] forState:UIControlStateNormal];
//	[curRaagaName setNeedsDisplay];

}


- (void) resetSession: (int) indx {
	curListIndx = 0;
	curRaagaListIndx = indx;

	//[self stopRecognizing];
	if(isRunning) {
		[self stopRecognizing];
		[btn_record setTitle:@"Start"];
		[message setHidden:YES];
	}
	
	[curListIndxs release];
	[curRaagaNotes release];
	//[raagaList release];


	//[raagaList createBalls];
	curRaagaNotes = [[[jsonArray objectAtIndex:curRaagaListIndx] objectForKey:@"Notes"] retain];
	curListIndxs = [[NSMutableArray alloc] initWithArray:[[jsonArray objectAtIndex:curListIndx] objectForKey:@"Indices"]];

	[curRaagaName setTitle:[raagaNames objectAtIndex:curRaagaListIndx] forState:UIControlStateNormal];

//	[raagaList release];
//	raagaList = [[RaagaList alloc] initWithFrame:CGRectMake(5.0f,230.0f,320.0f,150.0f)];
	[raagaList createBalls:curRaagaNotes];
	//[self.view addSubview:raagaList];
//	//	[self.view insertSubview:raagaList aboveSubview:slideMenuView];
//	[self viewWillAppear:true];
//	
}

- (IBAction)showOptions:(id)sender
{
	curListIndx = 0;
	[raagaList resetBalls];
	if(!isRunning) {
		message.hidden = NO;		
		[self startRecognizing];
		[btn_record setTitle:@"Stop"];
	}
	else {
		message.hidden = YES;
		
		[self stopRecognizing];
		[btn_record setTitle:@"Start"];
	}

}

- (void) audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	samplePlayer.currentTime = 0;
	[btn_play setImage:[UIImage imageNamed:@"icon_play.png"]];
	btn_record.enabled = YES;
	btn_scale.enabled = YES;		

}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[samplePlayer stop];
	samplePlayer.currentTime = 0;

	[btn_play setImage:[UIImage imageNamed:@"icon_play.png"]];
	btn_record.enabled = YES;
	btn_scale.enabled = YES;	

}

- (IBAction) playSample:(id) sender
{
	NSError* error;
	UInt32 doChangeDefaultRoute = 1;
	
	if(!samplePlayer) {
		samplePlayer = [AVAudioPlayer alloc];
		NSLog(@"%@",[raagaNames objectAtIndex:curRaagaListIndx]);
		if([samplePlayer	 initWithContentsOfURL:[[NSBundle mainBundle] 
								URLForResource:@"hamsadhwani" 
													withExtension:@"wav"] error:&error]) {
			samplePlayer.delegate = self;
			//On iPhone the audio gets routed to top speaker in case of Play & Record.	
			AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
									 sizeof (doChangeDefaultRoute),
									 &doChangeDefaultRoute);
		
		}  /* else {
			[samplePlayer release];
			samplePlayer = nil;
		}*/
		
	}
	if([samplePlayer isPlaying]) {
		[samplePlayer stop];
		samplePlayer.currentTime = 0;
		[btn_play setImage:[UIImage imageNamed:@"icon_play.png"]];
		btn_record.enabled = YES;
		btn_scale.enabled = YES;
	}
	else {
		[[AVAudioSession sharedInstance] setCategory:  AVAudioSessionCategoryPlayAndRecord error: nil];
		
		[samplePlayer prepareToPlay];
		[samplePlayer setVolume:2.0];
		if ([samplePlayer play]) {
			[btn_play setImage:[UIImage imageNamed:@"icon_stop.png"]];			
			btn_record.enabled = NO;
			btn_scale.enabled = NO;
		} else {
			UIAlertView* confirmView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
																  message:@"Could not Play Raaga" 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil];
			[confirmView show];
			[confirmView release];
		}
	}
}


- (void) startRecognizing {
	isRunning=1;
	[raagaSource startProcessing];
}


- (void) stopRecognizing {
	isRunning=0;
	[raagaSource stopProcessing];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

	if(buttonIndex ==0) { //Done Button Clicked
		if(pickerFlag == 1) {
			[self resetSession:curRaagaListIndx];
		} 
		else if (pickerFlag ==0) {
			[raagaNote setScale:curScale];	
		}
		pickerFlag = -1;
	}

}



- (IBAction) showScale:(id)sender {
	
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Select starting note in Western Scale"
													  delegate:self
											 cancelButtonTitle:nil //@"Done"
										destructiveButtonTitle:@"Done"
											 otherButtonTitles:nil];
	// Add the picker
	UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,135,0,0)];
	pickerFlag = 0;
	pickerView.delegate = self;
	pickerView.showsSelectionIndicator = YES;    // note this is default to NO
	[pickerView selectRow:curScale inComponent:0 animated:NO];
	[menu addSubview:pickerView];
	[menu showInView:self.view];
	[menu setBounds:CGRectMake(0,0,320,700)];
	
	[pickerView release];
	[menu release];
	
//	[self startProcessing];
}


- (IBAction) showRaagas:(id)sender {
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Select a Raaga"
													  delegate:self
											 cancelButtonTitle:nil //@"Done"
										destructiveButtonTitle:@"Done"
											 otherButtonTitles:nil];
	// Add the picker
	UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,135,0,0)];
	pickerFlag = 1;
	pickerView.delegate = self;
	pickerView.showsSelectionIndicator = YES;    // note this is default to NO
	[pickerView selectRow:curRaagaListIndx inComponent:0 animated:NO];
	[menu addSubview:pickerView];
	[menu showInView:self.view];
	[menu setBounds:CGRectMake(0,0,320,700)];
	
	[pickerView release];
	[menu release];
}


- (IBAction) showInfo:(id)sender {
	infoViewController* info = [[infoViewController alloc] init];
	info.delegate = self;
	info.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:info];
	[nav setNavigationBarHidden:YES];
	[self presentModalViewController:nav animated:YES];
	[nav release];
	[info release];
}
#pragma - 
#pragma mark PickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	if(pickerFlag == 0)	
		return (NSString*)[raagaScale objectAtIndex:row];
	else {
		
		return (NSString*)[raagaNames objectAtIndex:row];
	}

	   
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if(pickerFlag ==0)
		return [raagaScale count];
	else
		return [raagaNames count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(pickerFlag == 1) {
		curRaagaListIndx = [pickerView selectedRowInComponent:0];
	}
	else if (pickerFlag == 0)
		curScale = [pickerView selectedRowInComponent:0];
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark -
#pragma mark ScrollPage

- (NSUInteger)numberOfPages {
	return 3;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
    [super viewDidLoad];
	[self  init];

	raagaSource = [[RaagaPoliceSource alloc] init];
	raagaSource.parent = self;
	//Set the Level Meter
	UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
	[levelMeter setBackgroundColor:bgColor];
	[levelMeter setBorderColor:bgColor];
	[bgColor release];
	
	
	//PageViews
	self.bgImages = [NSMutableArray array];
	NSUInteger numberOfPhysicalPages = [self numberOfPages];
	for (NSUInteger i = 0; i < numberOfPhysicalPages; ++i)
		[self.bgImages addObject:[NSNull null]];

	NSMutableArray* buttonArray = [[NSMutableArray alloc] init];
	//UIImage* btnImage = [UIImage imageNamed:@"Swara.png"];
	for(int i = 0; i < [curRaagaNotes count]; i++)
	{
		// Rounded rect is nice
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		//[btn setBackgroundImage:btnImage forState:UIControlStateNormal];
		btn.opaque = FALSE;
		[btn setUserInteractionEnabled:NO];
		[btn setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 70.0f)];
		[btn setTitle:[NSString stringWithString:[curRaagaNotes objectAtIndex:i]] forState:UIControlStateNormal];		
		//[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[buttonArray addObject:btn];
		[btn release];
	}
	// initialize the slide menu by passing a suitable frame, background color and an array of buttons.
    //slideMenuView = [[SlideMenuView alloc] initWithFrameColorAndButtons:CGRectMake(0.0f, 300.0f, 
//														320.0f,  70.0f) 
//														backgroundColor:[UIColor darkGrayColor]  buttons:buttonArray];
//
//	[self.view addSubview:slideMenuView];
//	[self.view bringSubviewToFront:slideMenuView];

	raagaList = [[RaagaList alloc] initWithFrame:CGRectMake(5.0f,230.0f,320.0f,150.0f)];
//	[self.view addSubview:raagaList];
	[raagaList createBalls:curRaagaNotes];

	[self.view addSubview:raagaList];
//	[self.view insertSubview:raagaList aboveSubview:slideMenuView];
	
//	[self createAdBannerView];
    
	[self viewWillAppear:true];
}


- (BOOL)testMode {
	return YES;
}




- (CGSize)pageSize {
	return self.scrollView.frame.size;
}

- (NSUInteger)physicalPageIndex {
	CGSize pageSize = [self pageSize];
	return (self.scrollView.contentOffset.x + pageSize.width / 2) / pageSize.width;
}

- (void)setPhysicalPageIndex:(NSUInteger)newIndex {
	self.scrollView.contentOffset = CGPointMake(newIndex * [self pageSize].width, 0);
}

- (NSUInteger)physicalPageForPage:(NSUInteger)page {
	//NSParameterAssert(page < [self numberOfPages]);
	if (page >= [self numberOfPages]) {
		page = [self numberOfPages] - 1;
	}	
	return (page);
}

- (BOOL)isPhysicalPageLoaded:(NSUInteger)pageIndex {
	return [self.bgImages objectAtIndex:pageIndex] != [NSNull null];
}


- (NSUInteger)pageForPhysicalPage:(NSUInteger)physicalPage {
	
	//NSParameterAssert(physicalPage < [self numberOfPages]);
	if (physicalPage >= [self numberOfPages]) {
		physicalPage = [self numberOfPages] - 1;
	}
	return physicalPage;
	
}


- (UIView *)loadViewForPage:(NSUInteger)pageIndex {
	UIImage *image = nil;
	switch(pageIndex % 2) {
		case 0: image = [UIImage imageNamed:@"splash.jpg"]; break;
		case 1: image = [UIImage imageNamed:@"splash.jpg"]; break;
	}
	UIImageView *pageView = [[[UIImageView alloc] initWithImage:image] autorelease];
	pageView.contentMode = UIViewContentModeScaleAspectFill;
	return pageView;
}

- (CGRect)alignView:(UIView *)view forPage:(NSUInteger)pageIndex inRect:(CGRect)rect {
	UIImageView *imageView = (UIImageView *)view;
	CGSize imageSize = imageView.image.size;
	CGFloat ratioX = rect.size.width / imageSize.width, ratioY = rect.size.height / imageSize.height;
	CGSize size = (ratioX < ratioY ?
				   CGSizeMake(rect.size.width, ratioX * imageSize.height) :
				   CGSizeMake(ratioY * imageSize.width, rect.size.height));
	return CGRectMake(rect.origin.x + (rect.size.width - size.width) / 2,
					  rect.origin.y + (rect.size.height - size.height) / 2,
					  size.width, size.height);
}


- (UIView *)viewForPhysicalPage:(NSUInteger)pageIndex {
	NSParameterAssert(pageIndex >= 0);
	NSParameterAssert(pageIndex < [self.bgImages count]);
	
	UIView *pageView;
	if ([self.bgImages objectAtIndex:pageIndex] == [NSNull null]) {
		pageView = [self loadViewForPage:pageIndex];
		[self.bgImages replaceObjectAtIndex:pageIndex withObject:pageView];
		[self.scrollView addSubview:pageView];
		NSLog(@"View loaded for page %d", pageIndex);
	} else {
		pageView = [self.bgImages objectAtIndex:pageIndex];
	}
	return pageView;
}


- (void)layoutPhysicalPage:(NSUInteger)pageIndex {
	UIView *pageView = [self viewForPhysicalPage:pageIndex];
	CGSize pageSize = [self pageSize];
	pageView.frame = [self alignView:pageView forPage:[self pageForPhysicalPage:pageIndex] inRect:CGRectMake(pageIndex * pageSize.width, 0, pageSize.width, pageSize.height)];
}

- (void)currentPageIndexDidChange {
	[self layoutPhysicalPage:curPhysicalPageIndex];
	if (curPhysicalPageIndex+1 < [self.bgImages count])
		[self layoutPhysicalPage:curPhysicalPageIndex+1];
	//if (curPhysicalPageIndex > 0)
//		[self layoutPhysicalPage:curPhysicalPageIndex-1];
//	self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", 1+curPageIndex, [self numberOfPages]];
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	if (_rotationInProgress)
//		return; // UIScrollView layoutSubviews code adjusts contentOffset, breaking our logic
	
	NSUInteger newPageIndex = self.physicalPageIndex;
	if (newPageIndex == curPhysicalPageIndex) return;
	curPhysicalPageIndex = newPageIndex;
	curPageIndex = [self pageForPhysicalPage:curPhysicalPageIndex];
	
	[self currentPageIndexDidChange];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSLog(@"scrollViewDidEndDecelerating");
	NSUInteger physicalPage = self.physicalPageIndex;
	NSUInteger properPage = [self physicalPageForPage:[self pageForPhysicalPage:physicalPage]];
	if (physicalPage != properPage)
		self.physicalPageIndex = properPage;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)layoutPages {
	CGSize pageSize = self.scrollView.frame.size;
	self.scrollView.contentSize = CGSizeMake([self.bgImages count] * pageSize.width, pageSize.height);
	
	// move all visible pages to their places, because otherwise they may overlap
	for (NSUInteger pageIndex = 0; pageIndex < [self.bgImages count]; ++pageIndex)
		if ([self isPhysicalPageLoaded:pageIndex])
			[self layoutPhysicalPage:pageIndex];
}


- (void) doneWithInfoView :(infoViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark iAdsMethods

- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

- (void)createAdBannerView {
    Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] 
							  initWithFrame:CGRectZero] autorelease];
        [adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
														  ADBannerContentSizeIdentifier320x50, 
														  ADBannerContentSizeIdentifier480x32, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier480x32];
        } else {
            [adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier320x50];            
        }
        [adBannerView setFrame:CGRectOffset([adBannerView frame], 0, 
											  -  [self getBannerHeight])];
        [adBannerView setDelegate:self];
		
        [self.view addSubview:adBannerView];        
    }
}

- (void)fixupAdView:(UIDeviceOrientation)toInterfaceOrientation {
    if (adBannerView != nil) {        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            [adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier480x32];
        } else {
            [adBannerView setCurrentContentSizeIdentifier:
			 ADBannerContentSizeIdentifier320x50];
        }          
        [UIView beginAnimations:@"fixupViews" context:nil];
        if (adBannerViewIsVisible) {
            CGRect adBannerViewFrame = [adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 0;
            [adBannerView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.origin.y = 
			[self getBannerHeight:toInterfaceOrientation];
            contentViewFrame.size.height = self.view.frame.size.height - 
			[self getBannerHeight:toInterfaceOrientation];
            contentView.frame = contentViewFrame;
        } else {
            CGRect adBannerViewFrame = [adBannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = 
			-[self getBannerHeight:toInterfaceOrientation];
            [adBannerView setFrame:adBannerViewFrame];
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.origin.y = 0;
            contentViewFrame.size.height = self.view.frame.size.height;
            contentView.frame = contentViewFrame;            
        }
        [UIView commitAnimations];
    }   
}


#pragma mark -
#pragma mark ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!adBannerViewIsVisible) {                
        adBannerViewIsVisible = YES;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (adBannerViewIsVisible)
    {        
        adBannerViewIsVisible = NO;
        [self fixupAdView:[UIDevice currentDevice].orientation];
    }
}


#pragma mark -
#pragma mark ViewEvents

- (void)viewWillAppear:(BOOL)animated {
	[self layoutPages];
	[self currentPageIndexDidChange];
	[self setPhysicalPageIndex:[self physicalPageForPage:curPageIndex]];
	[self fixupAdView:[UIDevice currentDevice].orientation];

}



// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.bgImages = nil;
}


- (void)dealloc {
	[samplePlayer release];
	[btn_record release];
	[btn_scale release];
	[levelMeter release];
	[raagaSource dealloc];
	[raagaNote dealloc];
	[raagaList dealloc];
	[curRaagaNotes release];
	[curListIndxs release];
	[raagaScale release];
	[raagaNames release];
	[jsonArray release];
	[purchaseMgr release];
	[hitSound release];
	self.adBannerView = nil;
	[super dealloc];
}

@end
