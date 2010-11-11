//
//  GameObject.m
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

@synthesize world;

- (void)draw {
	return;
}

- (void)addToSpace:(cpSpace *)space {
	return;
}

- (void)physicsStepped:(cpSpace *)space {
	return;
}

- (id)init {
	if ([super init]==nil) return nil;
	
	world = 1;
	
	return self;
}

- (void)initOpenGLStuff {
	return;
}

@end
