//
//  QuadArray.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/27/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadArray.h"

#import "Quad.h"

@interface QuadArray ()
{
    Quad *_quads;
    uint _maxNumberOfQuads;
}

@end

@implementation QuadArray

- (id)init
{
    self = [super init];
    if (self) {
        _maxNumberOfQuads = 10;
        _quads = calloc(_maxNumberOfQuads, sizeof(Quad));
    }
    return self;
}

@end
