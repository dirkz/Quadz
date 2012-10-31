//
//  RectTextureAtlas.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/30/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "RectTextureAtlas.h"

@implementation RectTextureAtlas
{
    CGSize _tilesize;
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
