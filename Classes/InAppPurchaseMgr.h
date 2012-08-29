//
//  InAppPurchaseMgr.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 21/11/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"


#define kInAppPurchaseMgrProdcutsFetchedNotification @"kInAppPurchaseMgrProdcutsFetchedNotification"

@interface InAppPurchaseMgr : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {

	SKProduct *raagasProduct;
	SKProductsRequest	*productsRequest;
	id delegate;
}

@property (assign) id delegate;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;

@end
