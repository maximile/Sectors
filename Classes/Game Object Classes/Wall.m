//
//  Wall.m
//  Sectors
//
//  Created by Max Williams on 27/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Wall.h"


@implementation Wall 

@synthesize a, b, normal, shared, floorHeight, ceilingHeight, sector, sharedSector, interWorld;

- (id)initWithPointA:(vec3)newA B:(vec3)newB {
	if ([super init]==nil) return nil;
	
	a = newA;
	b = newB;
	
	return self;
}

+ (Wall *)wallFrom:(vec3)newA to:(vec3)newB {
	Wall *wall = [[Wall alloc] initWithPointA:newA B:newB];
	return [wall autorelease];
}

- (int)sectorsNeededWithFloorHeight:(float)sectorFloorHeight ceilingHeight:(float)sectorCeilingHeight {
	int needed = 0;
	if (interWorld) return 0;
	if (sectorFloorHeight<floorHeight) needed++;
	if (sectorCeilingHeight>ceilingHeight) needed++;
	return needed;
}

- (void)drawStencil {
	// if (interWorld == NO) return;
	// glColor4f(1,1,1,0);
	// glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE);
	glBegin(GL_QUADS);
		glVertex3f(a.x,ceilingHeight,a.z);
		glVertex3f(b.x,ceilingHeight,b.z);
		glVertex3f(b.x,floorHeight,b.z);
		glVertex3f(a.x,floorHeight,a.z);			
	glEnd();
}

- (void)setNormal:(vec3)newNormal {
	normal = newNormal;
	clipPlane = calloc(sizeof(GLdouble),4);
	GLdouble normX = normal.x;
	GLdouble normY = normal.y;
	GLdouble normZ = normal.z;
	clipPlane[0] = -normX;
	clipPlane[1] = -normY;
	clipPlane[2] = -normZ;
	
	// vec2 midpoint = vec2Make((a.x + b.x)/2,(a.z + b.z)/2);
	// float distance = sqrtf(midpoint.x*midpoint.x + midpoint.y*midpoint.y);
	// NSLog(@"%f",distance);
	
	vec2 A = vec2Make(a.x,a.z);
	vec2 B = vec2Make(b.x,b.z);
	vec2 C = vec2Make(0,0);
	
	float L = sqrtf((B.x-A.x)*(B.x-A.x) + (B.y-A.y)*(B.y-A.y));
	// float r = (C.x-A.x)*(B.x-A.x) + (C.y-A.y)*(B.y-A.y);
	// r /= L*L;
	float s = (A.y-C.y)*(B.x-A.x)-(A.x-C.x)*(B.y-A.y);
	s /= L*L;
	
	GLdouble distance = fabsf(s)*L;
	
	if (interWorld) NSLog(@"%f",distance);
	
	
	clipPlane[3] = distance;
	// clipPlane[3] = 0;
	// 
	clipPlane[0] = 0;
	clipPlane[1] = -1;
	clipPlane[2] = 0;
	clipPlane[3] = 0.5;
}

- (GLdouble *)clipPlane {
	return clipPlane;
}

@end
