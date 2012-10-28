//
//  QuadArray.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadArray.h"

@implementation QuadArray

- (id)init
{
    if (self = [super initWithElementSize:sizeof(Quad)]) {
    }
    return self;
}

- (void)addElement:(Quad)quad
{
    [super addElement:&quad];
}

- (Quad)elementAt:(size_t)index
{
    Quad *quad = [super elementAt:index];
    return *quad;
}

@end
