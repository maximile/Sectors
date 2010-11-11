//
//  Game.m
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Game.h"
#import "Level.h"
#import "Player.h"
#import "Sector.h"
#import "Wall.h"

// Game * selfPointer;

int playerWallCollision(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data) {
	// Player *player = (Player *)a->data;
	Wall *wall = (Wall *)b->data;
	
	Player *player = [Game currentGame].player;
	
	if (wall.sector.world != player.world) return 0;
	
	float maxPlayerFootLevel = player.pos.y+1.9;
	if (wall.shared == YES) {
		if ((wall.sector.floorHeight > maxPlayerFootLevel)||(wall.sharedSector.floorHeight > maxPlayerFootLevel))
			return 1;
		if (wall.sector.ceilingHeight < player.actualHeadHeight) return 1;
		if (wall.sharedSector.ceilingHeight < player.actualHeadHeight) return 1;
		if (wall.sharedSector.ceilingHeight - wall.sharedSector.floorHeight < player.actualHeadHeight) return 1;
		if (wall.sector.ceilingHeight - wall.sharedSector.floorHeight < player.actualHeadHeight) return 1;
		return 0;
	}
	return 1;
}

@implementation Game

@synthesize objects, player, sectors;

+ (void)initialize {
	if ([self class]==[Game class]) {
		cpInitChipmunk();
	}
}

static Game *currentGame;

+ (Game *)currentGame {
	return currentGame;
}

- (id)init {
	if ([super init]==nil) return nil;
	
	space = cpSpaceNew();
	space->iterations = 100;
	space->damping = 0.5;
	
	
	cpSpaceAddCollisionPairFunc(space, PlayerCollisionType, WallCollisionType, playerWallCollision, NULL);
	
	currentGame = self;
	return self;
}

- (void)startLevel:(Level *)newLevel {
	[objects release];
	objects = [newLevel.objects mutableCopy];
	
	NSMutableArray *tempSectors = [NSMutableArray arrayWithCapacity:objects.count];
	for (GameObject *object in objects) {
		if ([object isKindOfClass:[Sector class]]) [tempSectors addObject:object];
	}
	
	sectors = [tempSectors copy];
	
	[Sector processSharedWallsForSectors:sectors];
	
	for (GameObject *object in objects) {
		[object addToSpace:space];
	}
	
	self.player = newLevel.player;
}

- (void)updatePhysics {
	cpSpaceStep(space,TIMESTEP);
	for (GameObject *object in objects) {
		[object physicsStepped:space];
	}
}

- (void)startLevelNamed:(NSString *)levelFileName {
	NSArray * info;
	
	NSString *errorDesc = nil;
	NSString *levelInfoPath = [[NSBundle mainBundle] pathForResource:levelFileName ofType:@"plist"];
	NSData *levelInfoXML = [[NSFileManager defaultManager] contentsAtPath:levelInfoPath];
	info = (NSArray *)[NSPropertyListSerialization propertyListFromData:levelInfoXML mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&errorDesc];
	
	if (errorDesc != nil) {
	 	NSLog(@"%@",errorDesc);
		return;
	}
	
	Level *level = [[[Level alloc] initWithArray:info] autorelease];
	[self startLevel:level];
}

@end
