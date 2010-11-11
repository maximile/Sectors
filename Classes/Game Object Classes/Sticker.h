//
//  Sticker.h
//  Sectors
//
//  Created by Max Williams on 28/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameObject.h"
#import "Stuff.h"

@interface Sticker : GameObject {
	GLuint texture;
	vec3 pos;
	float angle;
	BOOL wall;
	NSString *message;
	int pixelsWide;
	int pixelsHigh;
	CGSize size;
	NSString *fontName;
	float fontSize;
	GLfloat color[3];
	NSTextAlignment alignment;
}

- (id)initWithDictionary:(NSDictionary *)info;
+ (Sticker *)stickerFromData:(NSDictionary *)info;

@end
