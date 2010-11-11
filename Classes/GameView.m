//
//  GameView.m
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"
#import "GameObject.h"
#import "Game.h"
#import "Stuff.h"
#import "Player.h"
#import "Sticker.h"
#import "Sector.h"
#import "Wall.h"

static NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
{
	NSOpenGLPFANoRecovery,
	NSOpenGLPFAWindow,
	NSOpenGLPFAAccelerated,
	NSOpenGLPFADoubleBuffer,
	NSOpenGLPFAColorSize, 24,
	NSOpenGLPFAAlphaSize, 8,
	NSOpenGLPFADepthSize, 24,
	NSOpenGLPFAStencilSize, 8,
	NSOpenGLPFASupersample,
	NSOpenGLPFASampleBuffers, 1,
	NSOpenGLPFASamples, 4,
	(NSOpenGLPixelFormatAttribute)nil	
};

@implementation GameView

NSTimer *gameTimer;

- (id)initWithFrame:(NSRect)frameRect {
	NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
	[pixelFormat autorelease];
	if (pixelFormat == nil) return nil;
	
	if ([super initWithFrame:frameRect pixelFormat:pixelFormat] == nil) return nil;
		
	game = [[Game alloc] init];
	[game startLevelNamed:@"TestLevel3"];

	[self performSelector:@selector(startTrackingMouse) withObject:nil afterDelay:0.0];
	gameTimer = [NSTimer scheduledTimerWithTimeInterval:TIMESTEP target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
	
	return self;
}

- (void)prepareOpenGL {	
	GLint swapInterval = 1;
	[[self openGLContext] setValues:&swapInterval forParameter: NSOpenGLCPSwapInterval];
	
	glEnable(GL_DEPTH_TEST);
	
	glEnable(GL_MULTISAMPLE);
	
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
		
	glEnable(GL_COLOR_MATERIAL);
	glShadeModel(GL_FLAT);
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHT1);
	float light_specular[4] = {0.5,0.5,0.5,1.0};
	// float light_ambient[4] = {0.4,0.4,0.4,1.0};
	float light_ambient[4] = {0.2,0.2,0.2,1.0};
	float light_diffuse[4] = {0.4,0.4,0.4,1.0};
	// float light_diffuse[4] = {0.0,0.0,0.0,1.0};
	glLightfv(GL_LIGHT0,GL_SPECULAR,light_specular);
	glLightfv(GL_LIGHT0,GL_AMBIENT,light_ambient);
	glLightfv(GL_LIGHT0,GL_DIFFUSE,light_diffuse);
	glLightfv(GL_LIGHT1,GL_SPECULAR,light_specular);
	glLightfv(GL_LIGHT1,GL_AMBIENT,light_ambient);
	glLightfv(GL_LIGHT1,GL_DIFFUSE,light_diffuse);
	
	float diffuse[4] = {0.6,0.6,0.6,1.0};
	float specular[4] = {0.0,0.0,0.0,1.0};
	float ambient[4] = {0.0,0.0,0.0,1.0};
	glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,diffuse);
	glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,specular);
	glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,ambient);
	
	for (GameObject *object in game.objects) {
		[object initOpenGLStuff];
	}
	
	[self reshape];
}

- (void)startTrackingMouse {
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)reshape {
	NSRect newBounds = [self bounds];
	glViewport(0,0,newBounds.size.width,newBounds.size.height);
	glLoadIdentity();
	glViewport(0, 0, [self bounds].size.width, [self bounds].size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	gluPerspective(45.0f,(GLfloat)newBounds.size.width/(GLfloat)newBounds.size.height,0.1f,100.0f);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();		
}

- (void)drawRect:(NSRect)rect {
	glClearColor(1, 1, 1, 1);
	glStencilMask(GL_TRUE);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

	glDisable(GL_STENCIL_TEST);

	glDisable(GL_CLIP_PLANE0);	
	
	glLoadIdentity();
	[game.player moveCameraToPOV];
		
	float light0Position[4] = {0.1,0.9,0.3,0.0};
	glLightfv(GL_LIGHT0,GL_POSITION,light0Position);
	float light1Position[4] = {-0.6,-0.2,0.4,0.0};
	glLightfv(GL_LIGHT1,GL_POSITION,light1Position);
	
	glLineWidth(2.0);
	
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glEnable(GL_LIGHT0);
	// glPolygonOffset(0,0);
	
	
	// test code to debug clip planes, to be removed
	// BOOL done = NO;
	
	// for (Sector *sector in game.sectors) {
	// 	for (Wall *wall in sector.walls) {
	// 		if (wall.interWorld) {
	// 			if (done == NO) {
	// 				// NSLog(@"%4.2d,%4.2d,%4.2d,%4.2d",wall.clipPlane[0],wall.clipPlane[1],wall.clipPlane[2],wall.clipPlane[3]);
	// 				glEnable(GL_CLIP_PLANE1);
	// 				if (sector.world == game.player.world) glClipPlane(GL_CLIP_PLANE1,wall.clipPlane);
	// 				// done = YES;
	// 			}
	// 		}
	// 	}
	// }
	
	
	
	// loop through interworld walls in current world, drawing stencil for each one
	
	NSMutableArray *interWorldWalls = [NSMutableArray arrayWithCapacity:0];
	for (Sector *sector in game.sectors) {
		if (sector.world == game.player.world) {
			for (Wall *wall in sector.walls) {
				if (wall.interWorld) {
					[interWorldWalls addObject:wall];
				}
				
			}
		}
	}
	
	
	for (Wall *wall in interWorldWalls) {
			
		// draw current world into depth
		glDisable(GL_STENCIL_TEST);
		glStencilMask(GL_FALSE);
		glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE);
		for (GameObject *object in game.objects) {
			if (object.world == game.player.world) {
				[object draw];
			}
		}
		
		// draw current wall's stencil
		glEnable(GL_STENCIL_TEST);
		glStencilMask(GL_TRUE);
		glStencilFunc(GL_ALWAYS, 1, 1);
		glStencilOp(GL_KEEP, GL_ZERO, GL_REPLACE);
		
		[wall drawStencil];
		
		glStencilMask(GL_FALSE);
		
		// draw scene behind wall
		
		// glEnable(GL_CLIP_PLANE0);
		// glClipPlane(GL_CLIP_PLANE0,wall.clipPlane);
		
		
		glClear(GL_DEPTH_BUFFER_BIT);
		glStencilFunc(GL_EQUAL, 1, 1);
		glStencilMask(GL_FALSE);
		glEnable(GL_STENCIL_TEST);
		// [wall drawStencil];
		
		glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE);
		
		for (GameObject *object in game.objects) {
			if (object.world!=game.player.world) {
				if ([object isKindOfClass:[Sticker class]]==NO)[object draw];
			}
		}
		for (GameObject *object in game.objects) {
			if (object.world!=game.player.world) {
				if ([object isKindOfClass:[Sticker class]])[object draw];
			}
		}
		
		glStencilMask(GL_TRUE);
		glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		glDisable(GL_CLIP_PLANE0);
	}
	
	// draw current world into depth
	
	glDisable(GL_STENCIL_TEST);
	glStencilMask(GL_FALSE);
	glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE);
	
	for (GameObject *object in game.objects) {
		if (object.world == game.player.world) {
			[object draw];
		}
	}	
	
	// draw all stencils
	
	for (Wall *wall in interWorldWalls) {
		glEnable(GL_STENCIL_TEST);
		glStencilMask(GL_TRUE);
		glStencilFunc(GL_ALWAYS, 1, 1);
		glStencilOp(GL_KEEP, GL_ZERO, GL_REPLACE);
		
		[wall drawStencil];
	}
	
	// draw current world without stencilled areas
	
	glClear(GL_DEPTH_BUFFER_BIT);
	glStencilFunc(GL_NOTEQUAL, 1, 1);
	glStencilMask(GL_FALSE);
	glEnable(GL_STENCIL_TEST);
	
	glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE);
	
	for (GameObject *object in game.objects) {
		if (object.world == game.player.world) {
			if ([object isKindOfClass:[Sticker class]] == NO) [object draw];
		}
	}	
	for (GameObject *object in game.objects) {
		if (object.world == game.player.world) {
			if ([object isKindOfClass:[Sticker class]]) [object draw];
		}
	}	
	
	
	
	
	// glEnable(GL_CLIP_PLANE0);
	// GLdouble plane[4] = {0,-1,0,0.8};
	// glClipPlane(GL_CLIP_PLANE0,plane);
	
	
	// draw current world
	// for (GameObject *object in game.objects) {
	// 	if (object.world==game.player.world) {
	// 		if ([object isKindOfClass:[Sticker class]]==NO)[object draw];
	// 	}
	// }
	// for (GameObject *object in game.objects) {
	// 	if (object.world==game.player.world) {
	// 		if ([object isKindOfClass:[Sticker class]])[object draw];
	// 	}
	// }
	// 
	// glClear(GL_DEPTH_BUFFER_BIT);
	// glStencilFunc(GL_EQUAL, 1, 1);
	// glStencilMask(GL_FALSE);
	// glEnable(GL_STENCIL_TEST);
	// 
	// 
	// // draw other world
	// for (GameObject *object in game.objects) {
	// 	if (object.world!=game.player.world) {
	// 		if ([object isKindOfClass:[Sticker class]]==NO)[object draw];
	// 	}
	// }
	// for (GameObject *object in game.objects) {
	// 	if (object.world!=game.player.world) {
	// 		if ([object isKindOfClass:[Sticker class]])[object draw];
	// 	}
	// }
		
	[[self openGLContext] flushBuffer];
}

BOOL moveForwards;
BOOL moveBackwards;
BOOL moveLeft;
BOOL moveRight;

- (void)timerFired {	
	const float movementSpeed = 0.5;
	float xSpeed = 0;
	float zSpeed = 0;
	if (moveForwards) zSpeed -= movementSpeed;
	if (moveBackwards) zSpeed += movementSpeed;
	if (moveLeft) xSpeed -= movementSpeed;
	if (moveRight) xSpeed += movementSpeed;
	
	[game.player moveBy:CGSizeMake(xSpeed,zSpeed)];
	[game updatePhysics];	
	
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)theEvent {
	if ([theEvent isARepeat]) return;
	if ([[theEvent characters] isEqualToString:@"w"]) moveForwards = YES;
	if ([[theEvent characters] isEqualToString:@"s"]) moveBackwards = YES;
	if ([[theEvent characters] isEqualToString:@"a"]) moveLeft = YES;
	if ([[theEvent characters] isEqualToString:@"d"]) moveRight = YES;
	if ([[theEvent characters] isEqualToString:@" "]) [game.player jump];
	if ([[theEvent characters] isEqualToString:@"c"]) game.player.wantsToCrouch = YES;
}

- (void)keyUp:(NSEvent *)theEvent {
	if ([[theEvent characters] isEqualToString:@"w"]) moveForwards = NO;
	if ([[theEvent characters] isEqualToString:@"s"]) moveBackwards = NO;
	if ([[theEvent characters] isEqualToString:@"a"]) moveLeft = NO;
	if ([[theEvent characters] isEqualToString:@"d"]) moveRight = NO;
	if ([[theEvent characters] isEqualToString:@"c"]) game.player.wantsToCrouch = NO;
	
}

- (void)mouseMoved:(NSEvent *)theEvent {
	[game.player turnBy:theEvent.deltaX/100];
	[game.player pitchBy:theEvent.deltaY/100];
	// [self setNeedsDisplay:YES];
}

@end
