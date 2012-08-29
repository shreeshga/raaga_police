//
//  BallDelegate.m
//  Animation101
//
/*
     File: BallDelegate.m
 Abstract: The delegate for a ball
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "SwaraBallDelegate.h"
#import <QuartzCore/QuartzCore.h>


@implementation SwaraBallDelegate

@synthesize parent;




- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
	static int i=0;
    CGContextSaveGState(ctx);
    CGRect bounds = layer.bounds;
	//get the index of the Ball
	NSUInteger indx = layer.position.x / 50;
	NSMutableArray* lab = [parent labels];
	
//	if(layer.position.y / 50)
//		indx+=6;
	NSString* strin = [lab objectAtIndex:indx];
	char* str = [strin cStringUsingEncoding:NSASCIIStringEncoding];
	
	CGMutablePathRef clipPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(clipPath, NULL, CGRectMake(0.5, 0.5, bounds.size.width-1, bounds.size.height-1));
    CGContextAddPath(ctx, clipPath);
    CGContextClip(ctx);
    CGPathRelease(clipPath);
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.9, 0.1,0, 1.0,  // Start color
        0.3, 0.1, 0, 1.0 }; // End color
    
    gradient = CGGradientCreateWithColorComponents (colorSpace, components,
                                                      locations, num_locations);
    CGColorSpaceRelease(colorSpace);
    CGPoint startPoint, endPoint;
    CGFloat startRadius, endRadius;
    startPoint.x = CGRectGetMidX(bounds)-12;
    startPoint.y =  CGRectGetMidY(bounds)-10;
    endPoint.x = CGRectGetMidX(bounds);
    endPoint.y = CGRectGetMidY(bounds);
    startRadius = 0;
    endRadius = CGRectGetWidth(bounds)/2;
    CGContextDrawRadialGradient (ctx, gradient, startPoint,
                                 startRadius, endPoint, endRadius,0
                                 /*kCGGradientDrawsAfterEndLocation*/);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);

	if(parent.hitList[indx])
		CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
	else
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
	CGContextSelectFont(ctx, "Helvetica", 26.0, kCGEncodingMacRoman);
	
	CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0, -1.0));
    // And now we actually draw some text. This screen will demonstrate the typical drawing modes used.
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextShowTextAtPoint(ctx, 8.0, 32.0, str,strlen(str));
}



@end
