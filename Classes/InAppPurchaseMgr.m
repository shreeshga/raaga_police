//
//  InAppPurchaseMgr.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 21/11/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//

#import "InAppPurchaseMgr.h"
#define kInAppPurchaseProUpgradeProductId @"com.omld.raagapolice.proRaagas"


@implementation InAppPurchaseMgr

@synthesize delegate;
#pragma -
#pragma Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestRaagasProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
	//Add listeners
	[[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(transactionComplete) 
									name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(transactionFailed) 
												 name:kInAppPurchaseManagerTransactionFailedNotification object:nil];	
	
									 
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProVersion" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
	
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
	[self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
		[self finishTransaction:transaction wasSuccessful:NO];
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
//														message:[transaction.error localizedDescription] 
//													   delegate:nil 
//											  cancelButtonTitle:@"OK" 
//											  otherButtonTitles:nil];
//		[alert show];
//		[alert release];		
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        //[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		[self finishTransaction:transaction wasSuccessful:NO];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}
- (void) requestRaagasProductData {

	NSSet*	productIdentifiers = [NSSet setWithObject:@"com.omld.raagapolice.proRaagas"];
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	productsRequest.delegate = self;
	[productsRequest start];
}


#pragma mark -
#pragma mark SKProductsRequestsDelegate methods

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	NSArray	*products = response.products;
	raagasProduct = [products count] == 1?	[[products firstObject] retain] : nil;
	if(raagasProduct) {
		NSLog(@"Product Title: %@",raagasProduct.localizedTitle);
		NSLog(@"Product Description: %@",raagasProduct.productIdentifier);
		NSLog(@"Product Price: %@",raagasProduct.price);
		NSLog(@"Product Id: %@",raagasProduct.productIdentifier);		
	
	}
	
	for(	NSString *invalidProductId in response.invalidProductIdentifiers) {
		NSLog(@"Invalid product id:%@",invalidProductId);
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
														message:@"Invalid product id" 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	
	[productsRequest release];
	[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseMgrProdcutsFetchedNotification object:self];
}



@end
