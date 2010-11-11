//
//  Sector.m
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sector.h"
#import <OpenGL/glu.h>
#import "Sector+Tesselation.h"
#import "Wall.h"
#import "Game.h"
#import "Player.h"

// #import "chipmunk.h"
@implementation Sector

@synthesize walls, ceilingHeight, floorHeight, world;

+ (void)initialize {
	[self initializeTesselator];
}

void combineCallback(GLdouble coords[3], GLdouble *vertex_data[4], GLfloat weight[4], GLdouble **dataOut) {
	GLdouble *vertex;

	vertex = (GLdouble *) malloc(6 * sizeof(GLdouble));
	vertex[0] = coords[0];
	vertex[1] = coords[1];
	vertex[2] = coords[2];


	*dataOut = vertex;
}

void vertexCallback(GLvoid *vertex) {
	GLdouble *ptr;

	ptr = (GLdouble *) vertex;
	glVertex3dv((GLdouble *) ptr);
}

+ (void)processSharedWallsForSectors:(NSArray *)sectors {	
	for (Sector *sector in sectors) {	
		for (Wall *wall in sector.walls) {
			wall.sector = sector;
		}
	}
	
	for (Sector *sector in sectors) { // every sector
		for (Sector *otherSector in sectors) { // every sector
			if (sector != otherSector) {
				for (Wall *wall in sector.walls) { // every wall in sector
					for (Wall *otherWall in otherSector.walls) { // every wall in other sector
						float aa = fabs(wall.a.x - otherWall.a.x) + fabs(wall.a.z - otherWall.a.z);
						float bb = fabs(wall.b.x - otherWall.b.x) + fabs(wall.b.z - otherWall.b.z);
						float ab = fabs(wall.a.x - otherWall.b.x) + fabs(wall.a.z - otherWall.b.z);
						float ba = fabs(wall.b.x - otherWall.a.x) + fabs(wall.b.z - otherWall.a.z);
						const float maxDiff = 0.001;
						if ((aa<maxDiff && bb<maxDiff) || (ab<maxDiff && ba<maxDiff)) { // shared wall found
							wall.shared = YES;
							wall.ceilingHeight = otherSector.ceilingHeight;
							wall.floorHeight = otherSector.floorHeight;
							wall.sharedSector = otherSector;
							if (otherSector.world != sector.world) {
								wall.interWorld = YES;
								otherWall.interWorld = YES;
								NSLog(@"setting");
							}
						}
					}
				}
			}
		}
	}
	
	for (Sector *sector in sectors) {
		[sector makeVerticesFromWalls];
		[sector createFloorAndCeilingVertexData];
	}
}

- (void)addQuadTL:(vec3)tl TR:(vec3)tr BR:(vec3)br BL:(vec3)bl normal:(vec3)normal index:(int)index {
	wallNormalData[index*12] = normal.x;
	wallNormalData[index*12+1] = normal.y;
	wallNormalData[index*12+2] = normal.z;
	wallNormalData[index*12+3] = normal.x;
	wallNormalData[index*12+3+1] = normal.y;
	wallNormalData[index*12+3+2] = normal.z;
	wallNormalData[index*12+6] = normal.x;
	wallNormalData[index*12+6+1] = normal.y;
	wallNormalData[index*12+6+2] = normal.z;
	wallNormalData[index*12+9] = normal.x;
	wallNormalData[index*12+9+1] = normal.y;
	wallNormalData[index*12+9+2] = normal.z;
	
	wallVertexData[index*12] = tl.x;
	wallVertexData[index*12+1] = tl.y;
	wallVertexData[index*12+2] = tl.z;
	wallVertexData[index*12+3] = tr.x;
	wallVertexData[index*12+3+1] = tr.y;
	wallVertexData[index*12+3+2] = tr.z;
	wallVertexData[index*12+6] = br.x;
	wallVertexData[index*12+6+1] = br.y;
	wallVertexData[index*12+6+2] = br.z;
	wallVertexData[index*12+9] = bl.x;
	wallVertexData[index*12+9+1] = bl.y;
	wallVertexData[index*12+9+2] = bl.z;
}

- (void)addToSpace:(cpSpace *)space {
	body = cpBodyNew(INFINITY, INFINITY);
	for (Wall *wall in walls) {
		cpShape *shape = cpSegmentShapeNew(body,cpv(wall.a.x,wall.a.z),cpv(wall.b.x,wall.b.z),0.0);
		shape->collision_type = WallCollisionType;
		shape->data = wall;
		cpSpaceAddStaticShape(space,shape);
	}
}

- (void)makeVerticesFromWalls {
	wallVertexCount = 0;
	for (Wall *wall in walls) {
		if (wall.shared == NO) wallVertexCount += 4;
		else wallVertexCount += [wall sectorsNeededWithFloorHeight:floorHeight ceilingHeight:ceilingHeight]*4;
	}
	
	// wallVertexCount = walls.count * 4;
	wallVertexData = calloc(sizeof(GLfloat),wallVertexCount * 3);
	wallNormalData = calloc(sizeof(GLfloat),wallVertexCount * 3);
	
	// determine winding
	float area = 0;
	for (Wall *wall in walls) {
		area = area + (wall.a.x * wall.b.z) - (wall.b.x * wall.a.z);
	}
	// NSLog(@"%f",area);
	
	int wallIndex = 0;
	for (Wall *wall in walls) {
		float wallAngle = atan2f(wall.b.z-wall.a.z,wall.b.x-wall.a.x);
		if (area>0) wallAngle += M_PI;
		vec3 normal = vec3Make(cos(wallAngle),0,sin(wallAngle));
		wall.normal = normal;
		
		vec3 tl,tr,br,bl;
		
		if (wall.shared == NO) {
			float y = ceilingHeight;
			tl = vec3Make(wall.a.x,y,wall.a.z);
			tr = vec3Make(wall.b.x,y,wall.b.z);
			y = floorHeight;
			br = vec3Make(wall.b.x,y,wall.b.z);
			bl = vec3Make(wall.a.x,y,wall.a.z);
			[self addQuadTL:tl TR:tr BR:br BL:bl normal:normal index:wallIndex];
			wallIndex++;
		}

		if (wall.shared == YES) {
			if (wall.interWorld == NO) {
				if (wall.floorHeight > floorHeight) {
					float y = wall.floorHeight;
					tl = vec3Make(wall.a.x,y,wall.a.z);
					tr = vec3Make(wall.b.x,y,wall.b.z);
					y = floorHeight;
					br = vec3Make(wall.b.x,y,wall.b.z);
					bl = vec3Make(wall.a.x,y,wall.a.z);
					[self addQuadTL:tl TR:tr BR:br BL:bl normal:normal index:wallIndex];
					wallIndex++;
				}
				if (wall.ceilingHeight < self.ceilingHeight) {
					float y = ceilingHeight;
					tl = vec3Make(wall.a.x,y,wall.a.z);
					tr = vec3Make(wall.b.x,y,wall.b.z);
					y = wall.ceilingHeight;
					br = vec3Make(wall.b.x,y,wall.b.z);
					bl = vec3Make(wall.a.x,y,wall.a.z);
					[self addQuadTL:tl TR:tr BR:br BL:bl normal:normal index:wallIndex];
					wallIndex++;
				}
			}
		}
		
	}
}

+ (NSArray *)wallArrayFromString:(NSString *)wallString {
	// prepare string
	
	wallString = [wallString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *wallStrings = [wallString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	// create list of coordinates and count
	
	vec3 coords[wallStrings.count]; // can't be more than that; might be fewer
	int coordCount = 0;
	
	for (NSString *currentWallString in wallStrings) {
		NSScanner * scanner = [NSScanner scannerWithString:currentWallString];
		float x = NAN, z = NAN;
		[scanner scanFloat:&x];
		[scanner scanFloat:&z];
		if ((x!=NAN) && (z!=NAN)) {
			coords[coordCount] = vec3Make(x,NAN,z);
			coordCount++;
		}
	}
	
	if (coordCount == 0) return [NSArray array];
	
	// create walls from coords
	
	NSMutableArray *walls = [NSMutableArray arrayWithCapacity:coordCount];
	for (int i=0; i<coordCount-1; i++) { // skip the last one; it's special
		[walls addObject:[Wall wallFrom:coords[i] to:coords[i+1]]];
	}
	[walls addObject:[Wall wallFrom:coords[coordCount-1] to:coords[0]]];
	
	return walls;
}

- (id)initWithDictionary:(NSDictionary *)info {
	if ([super init]==nil) return nil;
	
	ceilingHeight = [[info valueForKey:@"Ceiling Height"] floatValue];
	floorHeight = [[info valueForKey:@"Floor Height"] floatValue];
	
	walls = [[Sector wallArrayFromString:[info valueForKey:@"Walls"]] retain];
	
	vec3 newFloorColor, newCeilingColor, newWallsColor;
	
	if ([info valueForKey:@"Floor Color"] != nil)
		newFloorColor = vec3FromString([info valueForKey:@"Floor Color"]);
	else newFloorColor = vec3Make(0.6,0.6,0.6);
	
	if ([info valueForKey:@"Ceiling Color"] != nil)
		newCeilingColor = vec3FromString([info valueForKey:@"Ceiling Color"]);
	else newCeilingColor = vec3Make(0.6,0.6,0.6);

	if ([info valueForKey:@"Walls Color"] != nil)
		newWallsColor = vec3FromString([info valueForKey:@"Walls Color"]);
	else newWallsColor = vec3Make(0.8,0.8,0.8);
	
	floorColor[0] = newFloorColor.x;
	floorColor[1] = newFloorColor.y;
	floorColor[2] = newFloorColor.z;
	ceilingColor[0] = newCeilingColor.x;
	ceilingColor[1] = newCeilingColor.y;
	ceilingColor[2] = newCeilingColor.z;
	wallsColor[0] = newWallsColor.x;
	wallsColor[1] = newWallsColor.y;
	wallsColor[2] = newWallsColor.z;
	
	world = 1;
	if ([info valueForKey:@"World"]) world = [[info valueForKey:@"World"] intValue];
	
	return self;
}

- (void)draw {
	// glEnable(GL_BLEND);
	// glDisable(GL_LIGHTING);
    // glBindTexture(GL_TEXTURE_2D, texture);
    glDisable(GL_TEXTURE_2D);
    
	glEnableClientState(GL_NORMAL_ARRAY);
	glColor3fv(wallsColor);
	glVertexPointer(3, GL_FLOAT, 0, wallVertexData);
	glNormalPointer(GL_FLOAT, 0, wallNormalData);
	glDrawArrays(GL_QUADS, 0, wallVertexCount);

	glDisableClientState(GL_NORMAL_ARRAY);
	glNormal3f(0,0,1);
	glColor3fv(floorColor);
	glVertexPointer(3, GL_FLOAT, 0, floorVertexData);
	glDrawArrays(GL_TRIANGLES, 0, floorVertexCount);
	glVertexPointer(3, GL_FLOAT, 0, ceilingVertexData);
	glNormal3f(0,0,-1);	
	glColor3fv(ceilingColor);
	glDrawArrays(GL_TRIANGLES, 0, ceilingVertexCount);
	
	if (world!=[Game currentGame].player.world) return;
	
	// for (Wall *wall in walls) {
	// 	if (wall.interWorld) {
	// 		glEnable(GL_STENCIL_TEST);
	// 		glStencilMask(GL_TRUE);
	// 		
	// 		glStencilFunc(GL_ALWAYS, 1, 1);
	// 		glStencilOp(GL_KEEP, GL_ZERO, GL_REPLACE);
	// 		glColor4f(1,1,1,0);
	// 		glBegin(GL_QUADS);
	// 			glVertex3f(wall.a.x,ceilingHeight,wall.a.z);
	// 			glVertex3f(wall.b.x,ceilingHeight,wall.b.z);
	// 			glVertex3f(wall.b.x,floorHeight,wall.b.z);
	// 			glVertex3f(wall.a.x,floorHeight,wall.a.z);			
	// 		glEnd();
	// 		glStencilMask(GL_FALSE);
	// 	}
	// }
}

+ (Sector *)sectorFromData:(NSDictionary *)dict {
	Sector *sector = [[Sector alloc] initWithDictionary:dict];
	return [sector autorelease];
}

- (void)dealloc {
	free(wallNormalData);
	free(wallVertexData);
	
	[super dealloc];
}

@end
