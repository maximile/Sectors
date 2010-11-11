//
//  GameObject.h
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "chipmunk.h"

@interface GameObject : NSObject {
	int world;
}

@property int world;

- (void)draw;
- (void)addToSpace:(cpSpace *)space;
- (void)physicsStepped:(cpSpace *)space;
- (void)initOpenGLStuff;

@end
