//
//  infoViewController.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 17/11/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface infoViewController : UIViewController {
	id delegate;
	IBOutlet UIButton* doneButton;
//	NSArray* images;
//	IBOutlet UITableView* table;
	IBOutlet UIWebView* webview;
	NSString* htmlString;
}

@property (nonatomic,retain) UIButton* doneButton;
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSArray* images;
//@property (nonatomic,retain) UITableView* table;
@property (nonatomic,retain) UIWebView* webview;
@property (nonatomic,retain)  NSString* htmlString;

-(IBAction) done:(id)sender;

@end

@protocol UIInfoViewDelegate

- (void) doneWithInfoView :(infoViewController *)controller;

@end
