//
//  RaagaLines.m
//  RaagaPolice
//
//  Created by shreesh g ayachit on 15/10/10.
//  Copyright 2010 OML Digital Productions Pvt Ltd. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "RaagaLines.h"

@implementation RaagaLines

@synthesize notesToDisplay,bgColor,lineColor,graphColor,animationTimer;


//implement this, lest "[CALayer setDrawableProperties:]: unrecognized selector sent to instance" be vomited.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self performInit];
    }
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self performInit];
	}
	return self;
}


- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &rbWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &rbHeight);
	
	if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
}

- (void) performInit {
	bgColor = [[UIColor alloc] initWithRed:0. green:0. blue:0. alpha:0];
	lineColor = [[UIColor alloc] initWithRed:1. green:1. blue:1 alpha:0.];
	graphColor =[[UIColor alloc] initWithRed:0. green:1. blue:0 alpha:0.]; 
	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	self.opaque = NO;
	eaglLayer.opaque = NO;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
			kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
	if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
		[self release];
		return;
	}	
	//self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(refreshView) userInfo:nil repeats:YES];
	
	[self setupView];
}

-(void) setupView {
	glViewport(0, 0,rbWidth, rbHeight);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, rbWidth, 0, rbHeight, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnable(GL_BLEND);
	//glDisable(GL_LINE_SMOOTH);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	[self refreshView];
}


- (void) refreshView {
//	if(!viewFramebuffer) return;
//	[EAGLContext setCurrentContext:context];
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	glClearColor(0., 0., 0., 0.);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glPushMatrix();
	
	[self setupBackground];
	[self drawLines];
	glPopMatrix();
	glFlush();
//	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
//	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) setupBackground {
	CGRect bgRect = CGRectMake(0., 0., [self bounds].size.width, [self bounds].size.height);
	CGFloat *rgba= CGColorGetComponents(bgColor.CGColor);
	
	
	GLfloat vertices[] = {
		CGRectGetMinX(bgRect), CGRectGetMinY(bgRect),  
		CGRectGetMaxX(bgRect), CGRectGetMinY(bgRect),  
		CGRectGetMinX(bgRect), CGRectGetMaxY(bgRect),  
		CGRectGetMaxX(bgRect), CGRectGetMaxY(bgRect),  
	};
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	
	glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawLines {
	CGFloat *rgba= CGColorGetComponents(lineColor.CGColor);
	CGRect bgRect = CGRectMake(0., 0., [self bounds].size.width, [self bounds].size.height);
	//GLfloat points[200];
	
	
	glPushMatrix();
	

	glLineWidth(3.0);
//	glTranslatef(0., [self bounds].size.height, 0.);
//	glRotatef(-90., 0., 0., 1.);
//	static int lineexpos = 20;
//	if(lineexpos > CGRectGetMinX(bgRect) + 20)
//		lineexpos-=2;
//	else {
//		[self.animationTimer  invalidate];
//	}
	int lineexpos = 0;
	for (int i=1;i< 9 ; i++) {
		GLfloat vertices[] = {
			CGRectGetMinX(bgRect) + lineexpos , CGRectGetMinY(bgRect) + i*[self bounds].size.height/9,  
			CGRectGetMaxX(bgRect) + lineexpos, CGRectGetMinY(bgRect)+ i*[self bounds].size.height/9
		};
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
		glDrawArrays(GL_LINE_STRIP, 0, 2);
		
	}	
	
	glPopMatrix();
}


- (void) drawGraph:(float)userFreq {
	static GLfloat points[4] = {0};
	static int num_points =0;
	CGRect bgRect = CGRectMake(0., 0., [self bounds].size.width, [self bounds].size.height);

	
	[self refreshView];

	CGFloat *rgba= CGColorGetComponents(graphColor.CGColor);
	if(!viewFramebuffer) return;
		[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	points[0] = points[2];
	points[1] = points[3];	
	points[2] = ++num_points*5; 
	points[3] = CGRectGetMinY(bgRect) + (userFreq / 246) * 3;	
	
	if(num_points > 60)
	{
		points[2] = 0; 
		points[3] = 0;
		num_points = 0;
	}

	
	glPushMatrix();	
	
	glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
	//glEnableClientState(GL_COLOR_ARRAY);
	
	// points is a pointer to floats (2 per vertex)
	glLineWidth(3.0f);
	glVertexPointer(2, GL_FLOAT, 0, points);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glDrawArrays(GL_LINE_STRIP, 0, 2);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	//glDisableClientState(GL_COLOR_ARRAY);

	
	glPopMatrix();
	glFlush();
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}

//- (void) drawGraph:(float) userFreq {
//	static GLfloat points[4] = {0};
//	static int num_points =0;
//	CGFloat *rgba= CGColorGetComponents(graphColor.CGColor);
//	if(!viewFramebuffer) return;
//	[EAGLContext setCurrentContext:context];
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
//	
//	glPushMatrix();
//
//	
//	points[0] = points[2];
//	points[1] = points[3];	
//	points[2] = ++num_points*5; 
//	points[3] = rand() % 200;
//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//	glEnable(GL_BLEND);
//	glEnable(GL_LINE_SMOOTH);
//	
//	glLineWidth(2.0f);
//	glVertexPointer(2, GL_FLOAT, 0, points);
//	glEnableClientState(GL_VERTEX_ARRAY);
//
//	
//	
//	if(num_points > 80)
//	{
//		points[2] = 0; 
//		points[3] = 0;
//		num_points = 0;
//		[self refreshView];
//	}
//	
//	
//	glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
//	glDrawArrays(GL_LINE_STRIP, 0, 2);
//	
//	glDisableClientState(GL_VERTEX_ARRAY);
//	
//	glPopMatrix();
//	
//	
//	
//	glFlush();
//	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
//	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
//	
//	
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
	[self destroyFramebuffer];
}


@end
