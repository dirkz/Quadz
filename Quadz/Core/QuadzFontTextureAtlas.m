//
//  QuadzFontTextureAtlas.m
//  Quadz
//
//  Created by Dirk Zimmermann on 11/30/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadzFontTextureAtlas.h"


@implementation QuadzFontTextureAtlas
{
    unichar _start;
}

- (id)initWithTilesize:(CGSize)tilesize font:(UIFont *)font start:(unichar)start end:(unichar)end
{
    UIImage *tileImage = [self fontImageWithFont:font tilesize:tilesize start:start end:end];
    [UIImagePNGRepresentation(tileImage) writeToFile:@"/tmp/font.png" atomically:YES];
    if (self = [super initWithImage:tileImage tilesize:tilesize]) {
        _start = start;
        self.numberOfTextures = end - start + 1;
    }
    return self;
}

- (UIImage *)fontImageWithFont:(UIFont *)font tilesize:(CGSize)tilesize start:(unichar)start end:(unichar)end
{
    uint numberOfTiles = end - start + 1;
    CGSize textureSize = [self textureSizeForNumberOfTiles:numberOfTiles tilesize:tilesize];

    UIGraphicsBeginImageContextWithOptions(textureSize, YES, 1.f);
    [[UIColor whiteColor] setFill];
    [[UIColor whiteColor] setStroke];

    CGSize gap = CGSizeMake(0.f, 0.f);
    NSMutableString *string = [NSMutableString stringWithCapacity:1];
    CGRect drawRect = CGRectMake(0.f, 0.f, tilesize.width, tilesize.height);
    for (unichar ch = start; ch <= end; ++ch) {
        [string deleteCharactersInRange:NSMakeRange(0, string.length)];
        [string appendFormat:@"%C", (unsigned short) ch];
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        CGContextClipToRect(UIGraphicsGetCurrentContext(), drawRect);
        [string drawInRect:drawRect withFont:font];
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
        drawRect = [self nextDrawRect:drawRect textureSize:textureSize tileSize:tilesize gap:gap];
        NSAssert1(CGRectContainsRect(CGRectMake(0.f, 0.f, textureSize.width, textureSize.height), drawRect),
                  @"Out of texture size at char %d", ch);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (CGSize)textureSizeForNumberOfTiles:(uint)numberOfTiles tilesize:(CGSize)tilesize
{
    static float sizes[] = { 128, 256, 512, 1024, 2048, 4096 };
    for (uint heightIndex = 0; heightIndex < sizeof(sizes)/sizeof(float); ++heightIndex) {
        float height = sizes[heightIndex];
        for (uint widthIndex = 0; widthIndex < sizeof(sizes)/sizeof(float); ++widthIndex) {
            float width = sizes[widthIndex];
            uint xTiles = (width + 1.f) / (tilesize.width + 1.f);
            uint yTiles = (height + 1.f) / (tilesize.height + 1.f);
            uint tiles = xTiles * yTiles;
            if (tiles >= numberOfTiles) {
                return CGSizeMake(width, height);
            }
        }
    }
    return CGSizeZero;
}

- (CGRect)nextDrawRect:(CGRect)drawRect textureSize:(CGSize)textureSize tileSize:(CGSize)tilesize gap:(CGSize)gap
{
    drawRect.origin.x += tilesize.width + gap.width;
    if (drawRect.origin.x > textureSize.width - tilesize.width - gap.width) {
        drawRect.origin.x = 0.f;
        drawRect.origin.y += tilesize.height + gap.height;
    }
    return drawRect;
}

@end
