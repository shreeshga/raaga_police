//
//  RaagaPoliceAppDelegate.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 11/08/10.
//  Copyright OML Digital Productions Pvt Ltd 2010. All rights reserved.
//

#import "RaagaPoliceAppDelegate.h"
#import "RaagaPoliceViewController.h"
#import "DSActivityView.h"
@implementation RaagaPoliceAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize isProVersion;
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	NSDate *start = [NSDate date];
	if(connectionToInfoMapping == nil) {
		connectionToInfoMapping =
		CFDictionaryCreateMutable(
								  kCFAllocatorDefault,
								  0,
								  &kCFTypeDictionaryKeyCallBacks,
								  &kCFTypeDictionaryValueCallBacks);	
	}
	
	
    nav = [[UINavigationController alloc]initWithRootViewController:viewController];
	// Override point for customization after application launch.	
	timer = [NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(tick:) userInfo:start repeats: YES];
	shouldResume = NO;
    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	
	NSLog(@"Registering for push notifications...");    
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationType(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];

    return YES;
}


#pragma mark -
#pragma mark PushNotifications
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken { 
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    if ( ![userDefaults boolForKey:@"DeviceRegistered"] )  //if ( null, nil or "false" )
    {
        // send it somehow to your server - apple says the best way is to
        // send it as bytes : ( assuming you wrote a "sendProviderDeviceToken" method )
        [self sendProviderDeviceToken: devToken];
		NSLog(@"Device Token: %@", devToken); // log the device token as ascii
	}	
}

- (void) sendProviderDeviceToken: (NSData*) deviceToken {
	NSString* URLString = [NSString stringWithString:APP_PUSH_NOTIFICATION_URL];
	NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&lt;&gt;<;>"]];
	dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	//Append AppName
	URLString = [URLString stringByAppendingString:@"app=RaagaPolice&"];
	URLString = [URLString stringByAppendingFormat:@"deviceid=%@",dt];
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSURLConnection* conn = [NSURLConnection connectionWithRequest:request delegate:self];
	
	CFDictionaryAddValue(connectionToInfoMapping, conn,	[NSMutableDictionary
														 dictionaryWithObject:[NSMutableData data]
														 forKey:@"deviceid"]); 
	[conn start];
	[DSBezelActivityView newActivityViewForView:viewController.view withLabel:@"Registering.." width:180];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo { 
	UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
		//the app is in the foreground, so here you do your stuff since the OS does not do it for you
		//navigate the "aps" dictionary looking for "loc-args" and "loc-key", for example, or your personal payload)
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[[userInfo valueForKey:@"aps"]
																					valueForKey:@"alert"]
													   delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}	
    application.applicationIconBadgeNumber = 0;	
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
	
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
	NSLog(str);
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{



}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	//	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
	//														message:[error localizedDescription] 
	//													   delegate:nil 
	//											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
	//	[errorView show];
	//	[errorView release];
	[DSBezelActivityView removeViewAnimated:YES];	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Network Error."
												   delegate:self cancelButtonTitle: @"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
	NSMutableDictionary *connectionInfo = (NSMutableDictionary *) CFDictionaryGetValue(connectionToInfoMapping, connection);
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSData* mData;
	if(mData = [connectionInfo objectForKey:@"deviceid"]) {
		if (![userDefaults boolForKey:@"DeviceRegistered"] )  {
			[userDefaults setBool:YES forKey:@"DeviceRegistered"]; 
		}	
		connection = nil;
	}
	[DSBezelActivityView removeViewAnimated:YES];
}	




- (void)tick: (NSTimer*) _timer {
//	if(freq != 0)
//		[viewController checkIfNoteIsHit:lnote];
//	[viewController.levelMeter setNoteOffset:note];
//		NSLog(@"Time Taken for getFrequency:%f",[_timer.userInfo timeIntervalSinceNow]);	
//		NSLog(@"Time Taken for feedback:%f",[_timer.userInfo timeIntervalSinceNow]);
	[viewController checkLoop];
}



//- (void)setNote:(NSNumber*)value {
//	float freq = [value floatValue];
//	NSString* lnote;
//	if(freq) {
//		lnote = [NSString stringWithString:[note getNoteStr:freq]];
//		[viewController.songNote   setText:lnote];
//	}
//	else {
//		[viewController.songNote   setText:@""];
//	}
//	if(freq != 0)
//		[viewController checkIfNoteIsHit:lnote];
//}
//

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	if(viewController.isRunning) {
		shouldResume = YES;
		[viewController stopRecognizing];
//		[viewController.btn_record setTitle:@"Start"];
	}
	[timer invalidate];

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

	if(shouldResume) {
		[viewController startRecognizing];
		shouldResume = NO;
	
	}
	timer = [NSTimer scheduledTimerWithTimeInterval: .1 target: self selector: @selector(tick:) userInfo:nil repeats: YES];

}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[connectionToInfoMapping release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
