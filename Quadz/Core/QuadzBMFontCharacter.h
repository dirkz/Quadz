//
//  QuadzBMFontCharacter.h
//  Quadz
//
//  Created by Dirk Zimmermann on 12/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuadzBMFontCharacter : NSObject

@property (nonatomic, readonly) unichar character;
@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) int xoffset;
@property (nonatomic, readonly) int yoffset;
@property (nonatomic, readonly) int xadvance;
@property (nonatomic, readonly) int yadvance;
@property (nonatomic, readonly) NSString *letter;

+ (id)characterWithCharacter:(unichar)character x:(int)x y:(int)y width:(int)width height:(int)height
                     xoffset:(int)xoffset yoffset:(int)yoffset xadvance:(int)xadvance letter:(NSString *)letter;

- (id)initWithCharacter:(unichar)character x:(int)x y:(int)y width:(int)width height:(int)height
                xoffset:(int)xoffset yoffset:(int)yoffset xadvance:(int)xadvance letter:(NSString *)letter;

@end
