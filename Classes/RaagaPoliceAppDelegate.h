//
//  RaagaPoliceAppDelegate.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 11/08/10.
//  Copyright OML Digital Productions Pvt Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RaagaPoliceViewController;

@interface RaagaPoliceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	NSTimer* timer;
	BOOL isProVersion;
	BOOL shouldResume;
	CFMutableDictionaryRef connectionToInfoMapping;
    IBOutlet RaagaPoliceViewController *viewController;
    UINavigationController* nav;
}

- (void)setNote:(NSNumber*)value;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) IBOutlet UINavigationController* nav;
@property (readwrite)  BOOL isProVersion;

@property (nonatomic, retain) IBOutlet RaagaPoliceViewController *viewController;
@end

