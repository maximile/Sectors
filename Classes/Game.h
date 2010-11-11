//
//  Game.h
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "chipmunk.h"

@class Player;

@interface Game : NSObject {
	NSMutableArray *objects;
	Player *player;
	cpSpace *space;
	NSMutableArray *sectors;
}

@property (readonly) NSArray *sectors;
@property (readonly) NSArray *objects;
@property (retain) Player *player;

+ (Game *)currentGame;
- (void)startLevelNamed:(NSString *)levelFileName;
- (void)updatePhysics;

@end
