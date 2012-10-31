//
//  QuadRenderer.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/28/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Quad.h"

// Attribute index.
typedef enum : NSUInteger {
    AttributeIndexPosition,
    AttributeIndexColor,
    AttributeIndexTexture0,
    AttributeIndexMax
} AttributeIndex;

@class QuadArray;

@interface QuadRenderer : NSObject

- (void)addQuad:(Quad)quad;
- (void)removeAllQuads;
- (void)bind;
- (void)draw;

@end
