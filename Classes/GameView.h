//
//  GameView.h
//  Sectors
//
//  Created by Max Williams on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/GL.h>
#import <OpenGL/glu.h>
@class Game;

@interface GameView : NSOpenGLView {
	Game *game;
}

@end
