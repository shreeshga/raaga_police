//
//  RaagaPoliceViewController.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 11/08/10.
//  Copyright OML Digital Productions Pvt Ltd 2010. All rights reserved.
//


#import "constants.h"
#import <Foundation/Foundation.h>
#import "AQLevelMeter.h"
#import <UIKit/UIKit.h>
#import "RaagaPoliceSource.h"
#import "RaagaPoliceNote.h"
#import "RaagaPoliceSlideMenu.h"
#import "RaagaList.h"
#import "RaagaLines.h"
#import "infoViewController.h"
#import "InAppPurchaseMgr.h"
#import "iAd/ADBannerView.h"
#import "SoundEffect.h"
#import <AVFoundation/AVFoundation.h>

@interface RaagaPoliceViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource, 
					UIInfoViewDelegate, UIActionSheetDelegate,UIScrollViewDelegate,
					AVAudioPlayerDelegate,ADBannerViewDelegate,UIAlertViewDelegate>{
	
	
	IBOutlet UIBarButtonItem*	btn_record;
	IBOutlet UIBarButtonItem*	btn_scale;
	IBOutlet UIBarButtonItem*	btn_play;
	IBOutlet UIButton*	btn_buy;
    IBOutlet UIButton*	btn_info;                        
	IBOutlet UIImageView*			message;
		
	IBOutlet AQLevelMeter*		levelMeter;
	//IBOutlet RaagaLines*			raagaGraph;
	IBOutlet UIButton*			curRaagaName;

	NSMutableArray *bgImages;
	IBOutlet UIScrollView *scrollView;
	NSUInteger curPageIndex;
	NSUInteger curPhysicalPageIndex;
					
	NSMutableArray* curRaagaNotes;
	
	NSMutableArray*		raagaNames;
	NSUInteger curRaagaListIndx;
	NSUInteger raagaCount;
	
	
	NSMutableArray* curListIndxs;
	RaagaList*	raagaList;
	NSUInteger	curListIndx;
	NSMutableArray* jsonArray;
	
	NSMutableArray* raagaScale;
					
	RaagaPoliceSource*		raagaSource;
	RaagaPoliceNote* raagaNote;
	bool		isRunning;
	bool pickerFlag;
	NSUInteger curNoteHit;
	AVAudioPlayer* samplePlayer; 
	
	InAppPurchaseMgr*	purchaseMgr;
	//temp
	int curScale;
						
	id adBannerView;
	BOOL adBannerViewIsVisible;
                        
	UIView* contentView;
	UIAlertView* buyView;
	CFAbsoluteTime 	timeSinceBallHit;				
	SoundEffect* hitSound;					
}

@property (nonatomic, retain)	UIBarButtonItem		*btn_record;
@property (nonatomic, retain)	UIBarButtonItem		*btn_scale;
@property (nonatomic, retain)	UIBarButtonItem		*btn_play;
@property (nonatomic, retain)	UIButton		*btn_info;

@property (nonatomic, retain)	UIButton		*btn_buy;
@property (nonatomic, retain)	AQLevelMeter		*levelMeter;
//@property (nonatomic, retain)	RaagaLines			*raagaGraph;

@property (nonatomic, retain)	UIImageView				*message;
@property (nonatomic, retain)	UIButton			*curRaagaName;

@property (nonatomic, retain)	IBOutlet UIScrollView				*scrollView;
@property (nonatomic, retain) 	RaagaPoliceSource*		raagaSource;
@property (nonatomic, retain) 	RaagaPoliceNote*		raagaNote;
@property (nonatomic, retain)	NSMutableArray			*bgImages;
@property (nonatomic, retain) RaagaList* raagaList;
@property (nonatomic,retain) InAppPurchaseMgr* purchaseMgr;
@property (nonatomic) NSUInteger curListIndx;
@property (nonatomic) NSMutableArray*  jsonArray;
@property (nonatomic,retain) AVAudioPlayer* samplePlayer;

@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@property bool isRunning;
@property (nonatomic,retain) IBOutlet UIView* contentView;

-(IBAction) showScale:(id) sender;
-(IBAction) showOptions:(id) sender;
-(IBAction) playSample:(id) sender;
- (IBAction) showRaagas:(id)sender;
- (IBAction) showInfo:(id) sender;
- (IBAction) playOrPauseMusic: (id) sender;
- (IBAction) buyRaaga: (id)sender;
- (void) doBounce:(id) indx;
- (void) animate;
- (void) startRecognizing;
- (void) stopRecognizing;
@end

