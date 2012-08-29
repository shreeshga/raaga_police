//
//  infoViewController.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 17/11/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import "infoViewController.h"


@implementation infoViewController

@synthesize doneButton,delegate,webview,htmlString;
 

- (IBAction) done: (id) sender {
	
	[delegate doneWithInfoView:self];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (id) init {
	if(self != nil) {
//		images = [NSArray arrayWithObjects:
//				   [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info1.png"]] retain],
//				   [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info2.png"]] retain],
//				   [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info3.png"]] retain],
//				   nil];
		htmlString = [NSString stringWithString:@"<style type=\"text/css\"> "
					  "p { "
					   "font-family: Helvetica;"
					   "font-size: 17;"
					   "color: white;"
					  "}"
					  "h1 {"
					  "font-family: Helvetica;"
					  "font-size: 32;"
					   "color: white;"
					   "text-align: center;"
					  "}"
					  "#footer {"
					  "border-top: 1px solid #000;"
					  "font-family: Helvetica;"
					  "height: 35px;"
					  "}"
					  "</style><html> <head><h1> How to Use</h1> </head> <body> <p>Press on 'Start' to start singing "
					  "into the mic. Press ‘Stop’ to stop the "
					  "singing session.</p>"					  
					  "<p>Press on play icon to listen to "
					  "a recorded song sample of the current "
	 				  "raaga.</p>"
					  "<p>Press ‘Scale’ to set the starting range "
					  "of Swara. i.e to set the kattai.</p>"
					  "<p>The green level indicates the " 
					  "correct  pitch to sing the current " 
					  "swara. Increase/ decrease your "
					  "pitch level until you hit the green "
					  "bar.</p>"
					  "<p> The list of Swaras near the bottom, will show "
					  "which of the swaras you have hit. "
					  "You have to hit the current swara "
					  "before  moving to the next. You "
					  "cannot skip a swara."
					  "<p> The current Raaga name is displayed "
					  "below, select it to get a list of different "
					  "Raags to choose from. If there is only "
					  "one Raaga, select ‘Buy’ above to buy "
					  "additional Raagas."					  
					  "</body>"
					  "<div id=\"footer\">"
					  "<div> Built by OML Digital Pvt Ltd </div>"
					  "<div float=left ><img src=\"OMLDLogo_Black.jpg\" width=80 height=25> </img></div>"
					  "</div>"
					  "</html>"];
	}
		
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[webview loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	[webview setOpaque:NO];

    [super viewDidLoad];
}

#pragma mark -
#pragma mark UITableViewController methods


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (IBOutlet) done :(id) sender {
//
//	UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:info];
//	[self dismissModalViewControllerAnimated:YES];
//	[nav release];
//}


- (void)dealloc {
    [super dealloc];
}


@end
