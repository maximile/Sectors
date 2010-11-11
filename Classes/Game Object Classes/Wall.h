#import <Cocoa/Cocoa.h>
#import "OpenGL/GL.h"
#import "GameObject.h"
#import "Stuff.h"
#import "Sector.h"

@interface Wall : NSObject {
	vec3 a;
	vec3 b;
	BOOL shared;
	float floorHeight;
	float ceilingHeight;
	
	BOOL interWorld;
	vec3 normal;
	
	Sector *sector;
	Sector *sharedSector;
	
	GLdouble *clipPlane;
}

@property vec3 a;
@property vec3 b;
@property vec3 normal;
@property BOOL shared;
@property BOOL interWorld;
@property float floorHeight;
@property float ceilingHeight;
@property (assign) Sector *sector;
@property (assign) Sector *sharedSector;

- (id)initWithPointA:(vec3)newA B:(vec3)newB;
+ (Wall *)wallFrom:(vec3)newA to:(vec3)newB;
- (int)sectorsNeededWithFloorHeight:(float)sectorFloorHeight ceilingHeight:(float)sectorCeilingHeight;
- (void)drawStencil;
- (GLdouble *)clipPlane;

@end
