//
//  QuadArray.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "PodArray.h"

#import "Quad.h"

@interface QuadArray : PodArray

- (void)addElement:(Quad)quad;
- (Quad)elementAt:(size_t)index;

@end
