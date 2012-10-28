//
//  Quad.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/27/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat position[2]; // center
    int16_t size[2];
    uint8_t color[4];
} Quad;

static inline Quad QuadWithColor(int16_t x, int16_t y, int16_t width, int16_t height, uint8_t *color)
{
    Quad q = { x, y, width, height, color[0], color[1], color[2], color[3] };
    return q;
}

