//
//  Level.h
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Player;

@interface Level : NSObject {
	// NSArray *sectors;
	NSArray *objects;
	Player *player;
}

@property (readonly) NSArray *objects;
@property (retain) Player *player;

- (id)initWithArray:(NSArray *)levelData;

@end
