//
//  Level.m
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Level.h"
#import "Sector.h"
#import "Player.h"
#import "Sticker.h"

@implementation Level

@synthesize objects, player;

- (id)initWithArray:(NSArray *)levelData {
	if ([self init]==nil) return nil;
		
	NSMutableArray *tempObjects = [NSMutableArray arrayWithCapacity:levelData.count];
	
	for (NSDictionary *itemInfo in levelData) {
		NSString *type = [itemInfo valueForKey:@"Type"];
		if ([type isEqualToString:@"Sector"]) [tempObjects addObject:[Sector sectorFromData:itemInfo]];
		if ([type isEqualToString:@"Sticker"]) [tempObjects addObject:[Sticker stickerFromData:itemInfo]];
		if ([type isEqualToString:@"Start"]) self.player = [Player playerFromData:itemInfo];
	}
	
	// must have a valid player
	if (player == nil) player = [[[Player alloc] initWithPosition:vec3Make(0,0,0) heading:0 pitch:0] autorelease];
	[tempObjects addObject:player];
	
	objects = [tempObjects copy];
	return self;
}

- (void)dealloc {
	[objects release];
	[super dealloc];
}

@end
