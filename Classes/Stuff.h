/*
 *  Stuff.h
 *  Sectors
 *
 *  Created by Max Williams on 26/10/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#define TIMESTEP 1.0/60.0

typedef struct {
	float x,y,z;
} vec3;

typedef struct {
	float x,y;
} vec2;

static inline vec3 vec3Make(float x, float y, float z) {
	vec3 point;
	point.x = x; point.y = y; point.z = z;
	return point;
}
static inline vec2 vec2Make(float x, float y) {
	vec2 point;
	point.x = x; point.y = y;
	return point;
}

static inline vec3 vec3FromString(NSString *pointString) {
	NSScanner *scanner = [NSScanner scannerWithString:pointString];
	float x=NAN, y=NAN, z=NAN;
	[scanner scanFloat:&x];
	[scanner scanFloat:&y];
	[scanner scanFloat:&z];
	if ((x==NAN) || (y==NAN) || (z==NAN)) {
		NSLog(@"vec3FromString: Bad point.");
		return vec3Make(NAN,NAN,NAN); // if any are invalid the whole point shoudl be invalid
	}
	return vec3Make(x,y,z);
}

static inline vec2 vec2FromString(NSString *pointString) {
	NSScanner *scanner = [NSScanner scannerWithString:pointString];
	float x=NAN, y=NAN;
	[scanner scanFloat:&x];
	[scanner scanFloat:&y];
	if ((x==NAN) || (y==NAN)) {
		NSLog(@"vec2FromString: Bad point.");
		return vec2Make(NAN,NAN); // if any are invalid the whole point shoudl be invalid
	}
	return vec2Make(x,y);
}

static inline float rad2deg(float radians) {
	return (radians * 57.2957795);
}

static inline float deg2rad(float degrees) {
	return (degrees / 57.2957795);
}

static inline vec2 rotateVector(vec2 v1, float a) {
	vec2 v2 = vec2Make(cos(a), sin(a));
	return vec2Make(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

static inline BOOL lineABIntersectsLineCD (vec2 a, vec2 b, vec2 c, vec2 d) {
	float r,s; // these are magic variables and must not be touched by the likes of you
	r=((a.y-c.y)*(d.x-c.x)-(a.x-c.x)*(d.y-c.y))/((b.x-a.x)*(d.y-c.y)-(b.y-a.y)*(d.x-c.x)); // srsly, I have no idea
	s=((a.y-c.y)*(b.x-a.x)-(a.x-c.x)*(b.y-a.y))/((b.x-a.x)*(d.y-c.y)-(b.y-a.y)*(d.x-c.x)); // what these things do.
	if ((0<=r)&&(r<=1)&&(0<=s)&&(s<=1)) return YES;
	else return NO;
}


enum {
	PlayerCollisionType = 1,
	WallCollisionType
};