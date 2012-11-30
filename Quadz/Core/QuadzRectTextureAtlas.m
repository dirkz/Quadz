//
//  QuadzRectTextureAtlas
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

#import <GLKit/GLKit.h>

#import "QuadzRectTextureAtlas.h"

@implementation QuadzRectTextureAtlas
{
    NSUInteger _rows;
    CGSize _textureTileSize;
}

- (id)initWithImage:(UIImage *)image tilesize:(CGSize)tilesize
{
    if (self = [super init]) {
        _tilesize = tilesize;
        NSError *error;
        NSDictionary *options = @{GLKTextureLoaderApplyPremultiplication: @YES, GLKTextureLoaderOriginBottomLeft: @YES};
        _textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:&error];
        NSAssert1(!error, @"error loading texture: %@", error);
        NSUInteger cols = image.size.width / _tilesize.width;
        _rows = image.size.height / _tilesize.height;
        _numberOfTextures = _rows * cols;
        _textureTileSize = CGSizeMake(_tilesize.width / _textureInfo.width, _tilesize.height / _textureInfo.height);
    }
    return self;
}

- (CGRect)textureRectAtIndex:(NSUInteger)index
{
    NSUInteger row = index / _rows;
    NSUInteger col = index % _rows;
    CGRect rect = CGRectMake(col * _textureTileSize.width, 1.f - row * _textureTileSize.height,
                             _textureTileSize.width, _textureTileSize.height);
    return rect;
}

- (Quad)quadAtPosition:(CGPoint)position withTexture:(NSUInteger)index
{
    CGRect r = [self textureRectAtIndex:index];
    return QuadWithTextureRect(position.x, position.y, _tilesize.width, _tilesize.height, r);
}

@end
