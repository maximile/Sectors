//
//  Sector+Tesselation.m
//  Sectors
//
//  Created by Max Williams on 27/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sector+Tesselation.h"
#import <OpenGL/glu.h>
#import "Wall.h"

@implementation Sector (Tesselation)

GLUtesselator *tesselator;
NSMutableArray *wallStore;

void newVertex(GLvoid *data) {
	Wall *wall = (Wall *) data;
	// float xVal = wall.a.x;
	// NSLog(@"%f",xVal);
	// [wallStore.lastObject addObject:wall];
	[wallStore addObject:wall];
}

void combinedVertex() {
	NSLog(@"Combined Vertex");
}

void beginPolygon(GLenum meshType) {
	// [wallStore addObject:[NSMutableArray arrayWithCapacity:50]];	
	// [wallStore.lastObject addObject:[NSNumber numberWithInt:meshType]];
	
}

void endPolygon() {
}
void edgeFlag() {
}

+ (void)initializeTesselator {
	tesselator = gluNewTess();
	gluTessProperty(tesselator, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_ODD);
	gluTessCallback(tesselator, GLU_TESS_VERTEX, &newVertex);
	gluTessCallback(tesselator, GLU_TESS_COMBINE, &combinedVertex);
	gluTessCallback(tesselator, GLU_TESS_BEGIN, &beginPolygon);
	gluTessCallback(tesselator, GLU_TESS_END, &endPolygon);
	gluTessCallback(tesselator, GLU_TESS_EDGE_FLAG, &edgeFlag);
	// gluTessCallback(tesselator, GLU_TESS_VERTEX, (GLvoid (*) ( )) &vertexCallback);
	// gluTessCallback(tesselator, GLU_TESS_BEGIN, (GLvoid (*) ( )) &glBegin);
	// gluTessCallback(tesselator, GLU_TESS_END, (GLvoid (*) ( )) &glEnd);
	// gluTessCallback(tesselator, GLU_TESS_COMBINE, (GLvoid (*) ( ))&combineCallback);	
}

- (void)createFloorAndCeilingVertexData {
	wallStore = [NSMutableArray arrayWithCapacity:50];
	
	gluTessBeginPolygon(tesselator,NULL);
	gluTessBeginContour(tesselator);
		
	for (Wall *wall in walls) {
		GLdouble coords[3] = {wall.a.x,floorHeight,wall.a.z};
		gluTessVertex(tesselator, coords, wall);
	}
	
	gluTessEndContour(tesselator);
	gluTessEndPolygon(tesselator);
	
	
	// calculate needed vertices
	// int trianglesToBeMade = 0;
	// for (NSMutableArray *triangleSet in wallStore) {
	// 	GLenum meshType = [[triangleSet objectAtIndex:0] intValue];
	// 	if (meshType==GL_TRIANGLES) trianglesToBeMade += triangleSet.count * 3;
	// 	if (meshType==GL_TRIANGLE_FAN) trianglesToBeMade += triangleSet.count -2 *3;
	// 	if (meshType==GL_TRIANGLE_STRIP) trianglesToBeMade += triangleSet.count -2 *3;
	// }
	// 
	// NSLog(@"\nfinished! moving on... (%i)\n\n",trianglesToBeMade);
	// 
	// floorVertexCount = trianglesToBeMade * 3;
	// ceilingVertexCount = trianglesToBeMade * 3;
	// 
	// 
	// floorVertexData = calloc(sizeof(GLfloat),trianglesToBeMade*9);
	// ceilingVertexData = calloc(sizeof(GLfloat),trianglesToBeMade*9);	
	// 
	// 
	// int index = 0;
	// for (NSMutableArray *triangleSet in wallStore) {
	// 	GLenum meshType = [[triangleSet objectAtIndex:0] intValue];
	// 	[triangleSet removeObjectAtIndex:0];
	// 	switch (meshType) {
	// 		case GL_TRIANGLES:
	// 			NSLog(@"yo triangles");
	// 			for (Wall *wall in triangleSet) {
	// 				floorVertexData[index*3] = wall.a.x;
	// 				floorVertexData[index*3+1] = floorHeight;
	// 				floorVertexData[index*3+2] = wall.a.z;
	// 				NSLog(@"floor vertex (%4.1f,%4.1f,%4.1f)",floorVertexData[index*3],floorVertexData[index*3+1],floorVertexData[index*3+2]);
	// 				ceilingVertexData[index*3] = wall.a.x;
	// 				ceilingVertexData[index*3+1] = ceilingHeight;
	// 				ceilingVertexData[index*3+2] = wall.a.z;
	// 				index ++;
	// 			}
	// 			break;
	// 		case GL_TRIANGLE_FAN:
	// 			NSLog(@"yo triangle fan");
	// 		
	// 			//int vertexIndex = 0;
	// 			for (int n=0; n<triangleSet.count - 2; n++) {
	// 				Wall *wall0 = [triangleSet objectAtIndex:n];
	// 				Wall *wall1 = [triangleSet objectAtIndex:n+1];
	// 				Wall *wall2 = [triangleSet objectAtIndex:n+2];
	// 				floorVertexData[index*3] = wall0.a.x;
	// 				floorVertexData[index*3+1] = floorHeight;
	// 				floorVertexData[index*3+2] = wall0.a.z;
	// 				ceilingVertexData[index*3] = wall0.a.x;
	// 				ceilingVertexData[index*3+1] = ceilingHeight;
	// 				ceilingVertexData[index*3+2] = wall0.a.z;
	// 				index ++;
	// 				floorVertexData[index*3] = wall1.a.x;
	// 				floorVertexData[index*3+1] = floorHeight;
	// 				floorVertexData[index*3+2] = wall1.a.z;
	// 				ceilingVertexData[index*3] = wall1.a.x;
	// 				ceilingVertexData[index*3+1] = ceilingHeight;
	// 				ceilingVertexData[index*3+2] = wall1.a.z;
	// 				index ++;
	// 				floorVertexData[index*3] = wall2.a.x;
	// 				floorVertexData[index*3+1] = floorHeight;
	// 				floorVertexData[index*3+2] = wall2.a.z;
	// 				ceilingVertexData[index*3] = wall2.a.x;
	// 				ceilingVertexData[index*3+1] = ceilingHeight;
	// 				ceilingVertexData[index*3+2] = wall2.a.z;
	// 				index ++;
	// 			}
	// 			break;
	// 		case GL_TRIANGLE_STRIP:
	// 		
	// 			break;
	// 		default:
	// 			NSLog(@"Invalid mesh type");
	// 	}
	// }
	// 
	// NSLog(@"yo");
	
	
	floorVertexCount = wallStore.count;
	ceilingVertexCount = wallStore.count;
	
	floorVertexData = calloc(sizeof(GLfloat),floorVertexCount*3);
	// floorNormalData = calloc(sizeof(GLfloat),floorVertexCount*3);
	ceilingVertexData = calloc(sizeof(GLfloat),floorVertexCount*3);
	ceilingNormalData = calloc(sizeof(GLfloat),floorVertexCount*3);
	
	int index=0;
	for (Wall *wall in wallStore) {
		floorVertexData[index*3] = wall.a.x;
		floorVertexData[index*3+1] = floorHeight;
		floorVertexData[index*3+2] = wall.a.z;
		ceilingVertexData[index*3] = wall.a.x;
		ceilingVertexData[index*3+1] = ceilingHeight;
		ceilingVertexData[index*3+2] = wall.a.z;
		index++;
	}
}

@end
