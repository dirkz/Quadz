//
//  QuadzBMFontTextureAtlas.m
//  Quadz
//
//  Created by Dirk Zimmermann on 12/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "QuadzBMFontTextureAtlas.h"

#import "DLog.h"
#import "QuadzBMFontCharacter.h"

@interface QuadzBMFontTextureAtlas ()

@property (nonatomic) NSRegularExpression *propertyRegex;
@property (nonatomic) NSRegularExpression *lineTypeRegex;
@property (nonatomic) NSMutableDictionary *letters;

@end

@implementation QuadzBMFontTextureAtlas
{
    NSMutableString *_sample;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _letters = [NSMutableDictionary dictionary];
        _sample = [NSMutableString string];
        NSError *error;
        NSStringEncoding encoding;
        NSString *fileContents = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
        if (error) {
            return nil;
        }
        [fileContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [self processLine:line];
        }];

        NSString *imageName = self.pageFilename;
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
        NSDictionary *options = @{GLKTextureLoaderApplyPremultiplication: @YES, GLKTextureLoaderOriginBottomLeft: @YES};
        _textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:&error];
        NSAssert1(!error, @"error loading texture: %@", error);
    }
    return self;
}

- (NSRegularExpression *)propertyRegex
{
    if (!_propertyRegex) {
        NSString *pattern = @"(\\w+?)=\"?([\\w\\d,\\.]+)\"?\\b";
        NSError *error;
        NSAssert1(!error, @"error %@", error);
        _propertyRegex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    }
    return _propertyRegex;
}

- (NSRegularExpression *)lineTypeRegex
{
    if (!_lineTypeRegex) {
        NSString *pattern = @"^(\\w+)\\b";
        NSError *error;
        NSAssert1(!error, @"error %@", error);
        _lineTypeRegex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    }
    return _lineTypeRegex;
}

- (void)parseLineType:(NSString *)lineType key:(NSString *)key value:(NSString *)value
{
    if ([lineType isEqualToString:@"info"]) {
        if ([key isEqualToString:@"face"]) {
            _face = value;
        } else if ([key isEqualToString:@"charset"]) {
            _charset = value;
        } else if ([key isEqualToString:@"size"]) {
            _fontsize = [value floatValue];
        } else if ([key isEqualToString:@"scaleW"]) {
            _size = CGSizeMake([value floatValue], self.size.height);
        } else if ([key isEqualToString:@"bold"]) {
            _bold = [value boolValue];
        } else if ([key isEqualToString:@"italic"]) {
            _italic = [value boolValue];
        } else if ([key isEqualToString:@"unicode"]) {
            _unicode = [value boolValue];
        } else if ([key isEqualToString:@"smooth"]) {
            _smooth = [value boolValue];
        } else if ([key isEqualToString:@"aa"]) {
            _aa = [value boolValue];
        } else if ([key isEqualToString:@"stretchH"]) {
            _stretchH = [value floatValue];
        }
    } else if ([lineType isEqualToString:@"common"]) {
        if ([key isEqualToString:@"scaleW"]) {
            _size = CGSizeMake([value floatValue], self.size.height);
        } else if ([key isEqualToString:@"scaleH"]) {
            _size = CGSizeMake(self.size.width, [value floatValue]);
        } else if ([key isEqualToString:@"lineHeight"]) {
            _lineHeight = [value floatValue];
        } else if ([key isEqualToString:@"base"]) {
            _base = [value floatValue];
        } else if ([key isEqualToString:@"pages"]) {
            _pages = [value intValue];
            NSAssert1(self.pages == 1, @"Support for only one page (parsed %d)", self.pages);
        } else if ([key isEqualToString:@"packed"]) {
            _packed = [value boolValue];
        }
    } else if ([lineType isEqualToString:@"page"]) {
        if ([key isEqualToString:@"file"]) {
            _pageFilename = value;
        }
    }
}

- (void)parseCharacterLine:(NSString *)line
{
    __block unichar character = 0;
    __block int x = 0;
    __block int y = 0;
    __block int width = 0;
    __block int height = 0;
    __block int xoffset = 0;
    __block int yoffset = 0;
    __block int xadvance = 0;
    __block NSString *letter = @"";
    [self.propertyRegex
     enumerateMatchesInString:line options:0 range:NSMakeRange(0, line.length)
     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         NSString *key = [line substringWithRange:[result rangeAtIndex:1]];
         NSString *value = [line substringWithRange:[result rangeAtIndex:2]];
         if ([key isEqualToString:@"id"]) {
             character = [value intValue];
         } else if ([key isEqualToString:@"x"]) {
             x = [value intValue];
         } else if ([key isEqualToString:@"y"]) {
             y = [value intValue];
         } else if ([key isEqualToString:@"width"]) {
             width = [value intValue];
         } else if ([key isEqualToString:@"height"]) {
             height = [value intValue];
             _tilesize = CGSizeMake(self.tilesize.width, MAX(height, self.tilesize.height));
         } else if ([key isEqualToString:@"xoffset"]) {
             xoffset = [value intValue];
         } else if ([key isEqualToString:@"yoffset"]) {
             yoffset = [value intValue];
         } else if ([key isEqualToString:@"xadvance"]) {
             xadvance = [value intValue];
             _tilesize = CGSizeMake(MAX(self.tilesize.width, xadvance), self.tilesize.height);
         } else if ([key isEqualToString:@"letter"]) {
             letter = value;
         }
     }];
    [_sample appendFormat:@"%C", character];
    QuadzBMFontCharacter *bmChar = [QuadzBMFontCharacter
                                    characterWithCharacter:character x:x y:y
                                    width:width height:height xoffset:xoffset yoffset:yoffset
                                    xadvance:xadvance letter:letter];
    [self.letters setObject:bmChar forKey:[NSNumber numberWithUnsignedInt:character]];
}

- (void)processLine:(NSString *)line
{
    NSString *lineType = [self lineTypeForLine:line];
    if ([lineType isEqualToString:@"char"]) {
        [self parseCharacterLine:line];
    } else {
        [self.propertyRegex
         enumerateMatchesInString:line options:0 range:NSMakeRange(0, line.length)
         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
             NSString *key = [line substringWithRange:[result rangeAtIndex:1]];
             NSString *value = [line substringWithRange:[result rangeAtIndex:2]];
             [self parseLineType:lineType key:key value:value];
         }];
    }
}

- (NSString *)lineTypeForLine:(NSString *)line
{
    NSTextCheckingResult *match = [self.lineTypeRegex firstMatchInString:line options:0
                                                                   range:NSMakeRange(0, line.length)];
    if (match) {
        return [line substringWithRange:[match rangeAtIndex:1]];
    }
    return nil;
}

- (CGRect)textureRectForBMFontCharacter:(QuadzBMFontCharacter *)bmChar
{
    CGRect r = CGRectMake(((float) bmChar.x) / self.textureInfo.width,
                          ((float) self.textureInfo.height-bmChar.y) /  self.textureInfo.height,
                          ((float) bmChar.width) / self.textureInfo.width,
                          ((float) bmChar.height) / self.textureInfo.height);
    return r;
}

- (CGRect)textureRectForChar:(unichar)character
{
    QuadzBMFontCharacter *bmChar = [self.letters objectForKey:[NSNumber numberWithUnsignedInt:character]];
    NSAssert2(bmChar, @"Character '%C' %d not contained in texture atlas", character, character);
    return [self textureRectForBMFontCharacter:bmChar];
}

- (Quad)quadCenteredAtPosition:(CGPoint)position withChar:(unichar)character
{
    QuadzBMFontCharacter *bmChar = [self.letters objectForKey:[NSNumber numberWithUnsignedInt:character]];
    NSAssert1(bmChar, @"Character %d not contained in texture atlas", character);
    CGRect texRect = [self textureRectForBMFontCharacter:bmChar];
    return QuadWithTextureRect(position.x, position.y, bmChar.width, bmChar.height, texRect);
}

- (Quad)quadAtPosition:(CGPoint)position withChar:(unichar)character
{
    QuadzBMFontCharacter *bmChar = [self.letters objectForKey:[NSNumber numberWithUnsignedInt:character]];
    NSAssert1(bmChar, @"Character %d not contained in texture atlas", character);
    CGRect texRect = [self textureRectForBMFontCharacter:bmChar];

    // translate to the top left
    CGPoint p = CGPointMake(position.x - self.tilesize.width/2.f, position.y + self.tilesize.height/2.f);

    // apply traits
    p.x += bmChar.xoffset;
    p.y -= bmChar.yoffset;

    // translate 'back' to 'center'
    p.x += bmChar.width/2.f;
    p.y -= bmChar.height/2.f;

    return QuadWithTextureRect(p.x, p.y, bmChar.width, bmChar.height, texRect);
}

@end
