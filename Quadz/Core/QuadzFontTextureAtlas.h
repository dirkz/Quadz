//
//  QuadzFontTextureAtlas.h
//  Quadz
//
//  Created by Dirk Zimmermann on 11/30/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadzRectTextureAtlas.h"

@interface QuadzFontTextureAtlas : QuadzRectTextureAtlas

- (id)initWithTilesize:(CGSize)tilesize font:(UIFont *)font start:(unichar)start end:(unichar)end;

@end
