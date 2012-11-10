//
//  RectTextureAtlas.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/30/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

//
// Copyright 2012 Dirk Zimmermann
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
