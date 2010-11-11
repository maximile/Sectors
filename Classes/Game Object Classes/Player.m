//
//  Player.m
//  Sectors
//
//  Created by Max Williams on 26/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Stuff.h"
#import "Player.h"
#import "Game.h"
#import "Sector.h"
#import "Wall.h"

@implementation Player

@synthesize pos, world, wantsToCrouch, actualHeadHeight;

- (Sector *)currentSector {
	vec2 a = vec2Make(self.pos.x,self.pos.z);
	vec2 b = vec2Make(0,100000);
	for (Sector *sector in [Game currentGame].sectors) {
		if (sector.world == world) {
			int crossCount = 0;
			for (Wall *wall in sector.walls) {
				vec2 c = vec2Make(wall.a.x,wall.a.z);
				vec2 d = vec2Make(wall.b.x,wall.b.z);
				if (lineABIntersectsLineCD(a,b,c,d)) crossCount++;
			}
			if (crossCount%2==1) return sector;
		}
	}
	return nil;
}

- (void)jump {
	float floorHeight = self.currentSector.floorHeight;
	if (pos.y<floorHeight+0.01) speedY += 0.5;
	
}

- (void)turnBy:(float)delta {
	heading += delta;
}

- (void)pitchBy:(float)delta {
	pitch += delta;
	if (pitch<-M_PI/2) pitch=-M_PI/2;
	if (pitch>M_PI/2) pitch=M_PI/2;
}

- (void)moveBy:(CGSize)offset {
	vec2 vector = vec2Make(offset.width,offset.height);
	vector = rotateVector(vector,heading);
	pos = vec3Make(pos.x+vector.x,pos.y,pos.z+vector.y);
	// dragger->p = cpv(body->p.x+vector.x,body->p.y+vector.y);
	// dragger->p = cpv(pos.x,pos.z);
	cpBodySlew(dragger,cpv(pos.x,pos.z),TIMESTEP);
	// dragger->v = cpv(vector.x,vector.y);
	// cpBodyApplyForce
	// NSLog(@"%@",self.currentSector);
}

- (void)moveCameraToPOV {
	glRotatef(rad2deg(pitch),1,0,0);
	glRotatef(rad2deg(heading),0,1,0);
	glTranslatef(-body->p.x,-(pos.y+actualHeadHeight-(headHeight-eyeHeight)),-body->p.y);
}

- (id)initWithPosition:(vec3)newPos heading:(float)newHeading pitch:(float)newPitch {
	if ([super init]==nil) return nil;
	
	pos = newPos;
	heading = newHeading;
	pitch = newPitch;
	actualHeadHeight = headHeight;
	
	return self;
}

+ (Player *)playerFromData:(NSDictionary *)info {
	vec3 newPos = vec3FromString([info valueForKey:@"Position"]);
	float newHeading = [[info valueForKey:@"Heading"] floatValue];
	float newPitch = [[info valueForKey:@"Pitch"] floatValue];
	Player *player = [[Player alloc] initWithPosition:newPos heading:newHeading pitch:newPitch];
	player.world = 1;
	return [player autorelease];
}

vec3 oldPos;

- (void)physicsStepped:(cpSpace *)space {
	pos.x = body->p.x;
	pos.z = body->p.y;
	
	Sector *currentSector = self.currentSector;
	float floorHeight = currentSector.floorHeight;
	float ceilingHeight = currentSector.ceilingHeight;
	
	if (ceilingHeight-floorHeight < headHeight) crouching = YES;
	else crouching = wantsToCrouch;
	
	actualHeadHeight = (crouching?(actualHeadHeight+crouchHeight)/2:((actualHeadHeight+headHeight)/2));
	
	if (pos.y<floorHeight) pos.y = (pos.y+floorHeight)/2;
	
	if (pos.y>=floorHeight+0.01) speedY -= 0.05;
	if (speedY<0 && (pos.y<floorHeight+0.01)) speedY = 0.0;
	
	if (pos.y+actualHeadHeight >= ceilingHeight) {
		if (speedY>0.0) speedY = 0.0;
		pos.y = (pos.y + (ceilingHeight-actualHeadHeight))/2;
	}
	
	pos.y += speedY;
	// self.pos = vec3Make(pos.y,self.currentSector.floorHeight,pos.z);
	
	// check for world change
	
	BOOL changed = NO;
	for (Sector *sector in [Game currentGame].sectors) {
		for (Wall *wall in sector.walls) {
			if (wall.interWorld) {
				if (lineABIntersectsLineCD(
					vec2Make(wall.a.x,wall.a.z),
					vec2Make(wall.b.x,wall.b.z),
					vec2Make(oldPos.x,oldPos.z),
					vec2Make(pos.x,pos.z)
				)) {
					if (changed == NO) {
						if (world==1) world = 2;
						else world = 1;
						NSLog(@"New World: %i",world);
						changed = YES;
					}
				}
			}
		}
	}
	
	oldPos = pos;
}

- (void)addToSpace:(cpSpace *)space {
	float mass = 10;
	float friction = 0;
	
	dragger = cpBodyNew(10,INFINITY);
	dragger->p = cpv(pos.x,pos.z);
	cpSpaceAddBody(space,dragger);
	
	body = cpBodyNew(mass,INFINITY);
	body->p = cpv(pos.x,pos.z);
	body->data = self;
	cpSpaceAddBody(space,body);

	shape = cpCircleShapeNew(body,1.0,cpvzero);
	shape->u = friction;
	shape->collision_type = PlayerCollisionType;
		
	cpSpaceAddShape(space, shape);
	
	cpConstraint *pinJoint = cpPinJointNew(body,dragger,cpvzero,cpvzero);
	cpSpaceAddConstraint(space,pinJoint);
}

@end
