//
//  Sector+Tesselation.h
//  Sectors
//
//  Created by Max Williams on 27/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sector.h"

@interface Sector (Tesselation)

+ (void)initializeTesselator;
- (void)createFloorAndCeilingVertexData;

@end
