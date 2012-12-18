//
//  QuadzBMFontCharacter.m
//  Quadz
//
//  Created by Dirk Zimmermann on 12/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadzBMFontCharacter.h"

@implementation QuadzBMFontCharacter

+ (id)characterWithCharacter:(unichar)character x:(int)x y:(int)y width:(int)width height:(int)height
                     xoffset:(int)xoffset yoffset:(int)yoffset xadvance:(int)xadvance letter:(NSString *)letter
{
    return [[self alloc] initWithCharacter:character x:x y:y width:width height:height
                                   xoffset:xoffset yoffset:yoffset xadvance:xadvance letter:letter];
}

- (id)initWithCharacter:(unichar)character x:(int)x y:(int)y width:(int)width height:(int)height
                xoffset:(int)xoffset yoffset:(int)yoffset xadvance:(int)xadvance letter:(NSString *)letter
{
    self = [super init];
    if (self) {
        _character = character;
        _x = x;
        _y = y;
        _width = width;
        _height = height;
        _xoffset = xoffset;
        _yoffset = yoffset;
        _xadvance = xadvance;
        _letter = [letter copy];
    }
    return self;
}

@end
