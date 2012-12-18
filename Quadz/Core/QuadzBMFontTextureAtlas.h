//
//  QuadzBMFontTextureAtlas.h
//  Quadz
//
//  Created by Dirk Zimmermann on 12/18/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Quad.h"

@class GLKTextureInfo;

@interface QuadzBMFontTextureAtlas : NSObject

@property (nonatomic, readonly) NSString *face;
@property (nonatomic, readonly) NSString *charset;
@property (nonatomic, readonly) CGFloat fontsize;
@property (nonatomic, readonly) BOOL bold;
@property (nonatomic, readonly) BOOL italic;
@property (nonatomic, readonly) BOOL unicode;
@property (nonatomic, readonly) BOOL smooth;
@property (nonatomic, readonly) BOOL aa;
@property (nonatomic, readonly) CGFloat stretchH;

@property (nonatomic, readonly) CGFloat base;
@property (nonatomic, readonly) CGFloat lineHeight;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) int pages;
@property (nonatomic, readonly) BOOL packed;

@property (nonatomic, readonly) NSString *pageFilename;

@property (nonatomic, readonly) GLKTextureInfo *textureInfo;

/** All chars as one string */
@property (nonatomic, readonly, copy) NSString *sample;

@property (nonatomic, readonly) CGSize tilesize;

- (id)initWithPath:(NSString *)path;
- (CGRect)textureRectForChar:(unichar)character;

/** A quad of the given char centered *exactly* around position, mo traits taken into account */
- (Quad)quadCenteredAtPosition:(CGPoint)position withChar:(unichar)character;

@end
