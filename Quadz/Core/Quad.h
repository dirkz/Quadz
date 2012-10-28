//
//  Quad.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/27/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    // center position
    CGFloat x, y;
    int16_t width, height;
    uint8_t color[4];
} Quad;

static inline Quad QuadWithColor(int16_t x, int16_t y, int16_t width, int16_t height, uint8_t *color)
{
    Quad q = { x, y, width, height, color[0], color[1], color[2], color[3] };
    return q;
}

static inline CGFloat QuadX(Quad q) { return q.x; }
static inline CGFloat QuadY(Quad q) { return q.y; }
static inline int16_t QuadWidth(Quad q) { return q.width; }
static inline int16_t QuadHeight(Quad q) { return q.height; }
static inline uint8_t *QuadColor(Quad *q) { return q->color; }
