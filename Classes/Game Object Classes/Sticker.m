//
//	Sticker.m
//	Sectors
//
//	Created by Max Williams on 28/10/2009.
//	Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sticker.h"
#import "NSViewTexture.h"
#import "Stuff.h"

@implementation Sticker

+ (Sticker *)stickerFromData:(NSDictionary *)info {
	Sticker *sticker = [[Sticker alloc] initWithDictionary:info];
	return [sticker autorelease];
}

- (void)initOpenGLStuff {
	// NSView *view;
	// view = ConvenienceCreateNSTextView(
	//         256,
	//         256,
	//         "Apple Chancery",
	//         24.0f,
	//         0,
	//         "Hello, world!\n\nThis is a test!");
	// // GLuint testTex;
	//     glGenTextures(1, &texture);
	//     glBindTexture(GL_TEXTURE_2D, texture);
	//     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	//     TexImageNSView(GL_TEXTURE_2D, view);
	//     
	// NSLog(@"aegriohaeio, %u",texture);
	
	NSRect rect = NSMakeRect(0.0f, 0.0f, (float)pixelsWide, (float)pixelsHigh);
	NSTextView *view = [[NSTextView alloc] initWithFrame:rect];
	[view setBackgroundColor:[NSColor clearColor]];
	[view setTypingAttributes: [NSDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName]];
	[view setFont: [NSFont fontWithName:fontName size:fontSize]];
	[view setAlignment:alignment];
	[view setString:message];
	
	glGenTextures(1,&texture);
	glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    TexImageNSView(GL_TEXTURE_2D, view);	
}

- (id)initWithDictionary:(NSDictionary *)info {
	if ([super init]==nil) return nil;
	
	pos = vec3FromString([info valueForKey:@"Position"]);
	angle = [[info valueForKey:@"Angle"] floatValue];
	message = [info valueForKey:@"Message"];
	fontName = [info valueForKey:@"Font"];
	wall = [[info valueForKey:@"Wall Sticker"] boolValue];
	
	vec3 tempColor;
	if ([info valueForKey:@"Color"] != nil)
		tempColor = vec3FromString([info valueForKey:@"Color"]);
	else tempColor = vec3Make(0.6,0.6,0.6);
	color[0] = tempColor.x;
	color[1] = tempColor.y;
	color[2] = tempColor.z;
	
	pixelsWide = 1024;
	pixelsHigh = 512;
	if ([info valueForKey:@"Texture Dimensions"]!=nil) {
		vec2 pixelSize = vec2FromString([info valueForKey:@"Texture Dimensions"]);
		pixelsWide = pixelSize.x;
		pixelsHigh = pixelSize.y;
	}
	
	size = CGSizeMake(pixelsWide/500,pixelsHigh/500);
	
	if ([info valueForKey:@"Draw Size"]!=nil) {
		vec2 drawSize = vec2FromString([info valueForKey:@"Draw Size"]);
		size.width = drawSize.x;
		size.height = drawSize.y;
	}
	
	fontSize = 80;
	if ([info valueForKey:@"Font Size"]!=nil) fontSize = [[info valueForKey:@"Font Size"] floatValue];
	
	alignment = NSCenterTextAlignment;
	NSString *alignmentString = [info valueForKey:@"Alignment"];
	if ([alignmentString isEqualToString:@"Left"]) alignment = NSLeftTextAlignment;
	if ([alignmentString isEqualToString:@"Right"]) alignment = NSRightTextAlignment;
	
	return self;
}

- (void)draw {
	glColor3fv(color);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
	// glDisable(GL_LIGHTING);
    glBindTexture(GL_TEXTURE_2D, texture);
    glEnable(GL_TEXTURE_2D);
    
	glEnable(GL_POLYGON_OFFSET_FILL);
	glPolygonOffset(-1,1);

	glPushMatrix();
	glTranslatef(pos.x,pos.y,pos.z);
	glRotatef(angle,0,1,0);
	glScalef(4,4,4);
	float widthBy2 = size.width/2;
	float heightBy2 = size.height/2;
	if (wall==NO) {
	    glBegin(GL_QUADS);
	        glTexCoord2f(1.0f, 1.0f);
	        glVertex3f(-widthBy2, 0.0f, -heightBy2);
	        glTexCoord2f(0.0f, 1.0f);
	        glVertex3f(widthBy2, 0.0f,-heightBy2);
	        glTexCoord2f(0.0f, 0.0f);
	        glVertex3f(widthBy2, 0.0f,heightBy2);
	        glTexCoord2f(1.0f, 0.0f);
	        glVertex3f(-widthBy2, 0.0f, heightBy2);
	    glEnd();
	}
	if (wall==YES) {
	    glBegin(GL_QUADS);
	        glTexCoord2f(1.0f, 1.0f);
	        glVertex3f(-widthBy2, -heightBy2, 0.0f);
	        glTexCoord2f(0.0f, 1.0f);
	        glVertex3f(widthBy2, -heightBy2,0.0f);
	        glTexCoord2f(0.0f, 0.0f);
	        glVertex3f(widthBy2, heightBy2, 0.0f);
	        glTexCoord2f(1.0f, 0.0f);
	        glVertex3f(-widthBy2, heightBy2, 0.0f);
	    glEnd();
	}
	glPopMatrix();
	
	glPolygonOffset(0,0);
	
}

@end
