//
//  RectTextureAtlas.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/30/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Quad.h"

enum TextureAtlasCoordinates : NSUInteger {
    TextureAtlasCoordinatesBottomLeft,
    TextureAtlasCoordinatesBottomRight,
    TextureAtlasCoordinatesTopLeft,
    TextureAtlasCoordinatesTopRight,
    TextureAtlasCoordinatesMax,
};

@class GLKTextureInfo;

/** Very simple texture atlas with each texture the same rectangular size, indexed by number starting with texture
   0 in the top left. */
@interface RectTextureAtlas : NSObject

@property (nonatomic, readonly) GLKTextureInfo *textureInfo;
@property (nonatomic, readonly) NSUInteger numberOfTextures;

- (id)initWithImage:(UIImage *)image tilesize:(CGSize)tilesize;

/** @returns CGRect for texture where origin is top left */
- (CGRect)textureRectAtIndex:(NSUInteger)index;

- (Quad)quadAtPosition:(CGPoint)position withTexture:(NSUInteger)index;

@end
