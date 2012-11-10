//
//  Quad.h
//  Quadz
//
//  Created by Dirk Zimmermann on 10/27/12.
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

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat x, y; // center position
    int16_t width, height;
    CGRect texture; // texture rectangle with origin top left
    uint8_t color[4];
} Quad;

static inline Quad QuadWithColor(int16_t x, int16_t y, int16_t width, int16_t height, uint8_t *color)
{
    Quad q = { x, y, width, height, 0.f, 0.f, 0.f, 0.f, color[0], color[1], color[2], color[3] };
    return q;
}

static inline Quad QuadWithTextureRect(int16_t x, int16_t y, int16_t width, int16_t height, CGRect texRect)
{
    Quad q = {
        x, y, width, height, texRect.origin.x, texRect.origin.y, texRect.size.width, texRect.size.height,
        255, 255, 255, 255
    };
    return q;
}

static inline CGFloat QuadX(Quad q) { return q.x; }
static inline CGFloat QuadY(Quad q) { return q.y; }
static inline int16_t QuadWidth(Quad q) { return q.width; }
static inline int16_t QuadHeight(Quad q) { return q.height; }
static inline uint8_t *QuadColor(Quad *q) { return q->color; }
static inline CGRect QuadTextureRect(Quad q) { return q.texture; }
static inline void QuadSetColor(Quad *q, uint8_t color[4]) {
    q->color[0] = color[0]; q->color[1] = color[1];
    q->color[2] = color[2]; q->color[3] = color[3];
}
