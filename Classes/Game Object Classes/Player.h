//
//  Player.h
//  Sectors
//
//  Created by Max Williams on 26/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Stuff.h"
#import "GameObject.h"
#import "chipmunk.h"

#define headHeight 6.4
#define eyeHeight 6.0
#define crouchHeight 2.5

@interface Player : GameObject {
	vec3 pos;
	float heading; // radians
	float pitch; // radians
	cpBody *body;
	cpShape *shape;
	cpBody *dragger;
	float speedY;
	BOOL crouching;
	BOOL wantsToCrouch;
	float actualHeadHeight;
}

@property vec3 pos;
@property BOOL wantsToCrouch;
@property float actualHeadHeight;

+ (Player *)playerFromData:(NSDictionary *)info;
- (id)initWithPosition:(vec3)newPos heading:(float)newHeading pitch:(float)newPitch;
- (void)moveCameraToPOV;
- (void)pitchBy:(float)delta;
- (void)turnBy:(float)delta;
- (void)moveBy:(CGSize)offset;
- (void)jump;

@end
