//
//  Sector.h
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpenGL/GL.h"
#import "GameObject.h"
#import "Stuff.h"

@interface Sector : GameObject {
	float ceilingHeight;
	float floorHeight;
	
	GLfloat floorColor[3];
	GLfloat ceilingColor[3];
	GLfloat wallsColor[3];
	
	GLfloat *wallVertexData;
	GLfloat *wallNormalData;
	GLint wallVertexCount;
	NSArray *walls;
	
	GLfloat *floorVertexData;
	GLfloat *floorNormalData;
	GLint floorVertexCount;
	GLfloat *ceilingVertexData;
	GLfloat *ceilingNormalData;
	GLint ceilingVertexCount;
	
	
	cpBody *body;
}

@property (retain) NSArray* walls;
@property float ceilingHeight;
@property float floorHeight;

- (void)makeVerticesFromWalls;
+ (Sector *)sectorFromData:(NSDictionary *)data;
+ (void)processSharedWallsForSectors:(NSArray *)sectors;

@end
