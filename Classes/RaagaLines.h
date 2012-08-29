//
//  RaagaLines.h
//  RaagaPolice
//
//  Created by shreesh g ayachit on 15/10/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//



#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface RaagaLines : UIView {
	NSString	*notesToDisplay;
    NSTimer *animationTimer;
	
	//OPENGL
	GLint						rbWidth;
	GLint						rbHeight;
	EAGLContext					*context;
	GLuint						viewRenderbuffer, viewFramebuffer;
	UIColor						*bgColor,*lineColor,*graphColor;
}

@property  (retain) NSString* notesToDisplay;
@property  (retain) UIColor*	bgColor;
@property  (retain) UIColor*	lineColor;
@property  (retain) UIColor*	graphColor;
@property (retain) NSTimer* animationTimer;
@end
