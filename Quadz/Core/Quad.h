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

typedef struct _QuadzColor
{
    GLubyte r;
    GLubyte g;
    GLubyte b;
    GLubyte a;
} QuadzColor;

static inline QuadzColor QuadzColorMake(GLubyte r, GLubyte g, GLubyte b, GLubyte a)
{
    QuadzColor color = { r, g, b, a };
    return color;
}

typedef struct {
    CGFloat x, y; // center position
    CGFloat width, height;
    CGRect texture; // texture rectangle with origin top left
    QuadzColor color; // foreground color
    QuadzColor backgroundColor;
} Quad;

static inline Quad QuadWithTextureRect(int16_t x, int16_t y, int16_t width, int16_t height, CGRect texRect)
{
    Quad q = {
        x, y, width, height, texRect.origin.x, texRect.origin.y, texRect.size.width, texRect.size.height,
        255, 255, 255, 255, 0, 0, 0, 0
    };
    return q;
}

static inline CGFloat QuadX(Quad q) { return q.x; }
static inline CGFloat QuadY(Quad q) { return q.y; }
static inline CGPoint QuadPosition(Quad q) { return CGPointMake(q.x, q.y); }
static inline CGFloat QuadWidth(Quad q) { return q.width; }
static inline CGFloat QuadHeight(Quad q) { return q.height; }
static inline CGSize QuadSize(Quad q) { return CGSizeMake(q.width, q.height); }
static inline void QuadSetWidth(Quad *q, CGFloat width) { q->width = width; }
static inline void QuadSetHeight(Quad *q, CGFloat height) { q->height = height; }
static inline void QuadSetSize(Quad *q, CGSize size) { q->width = size.width; q->height = size.height; }
static inline QuadzColor QuadColor(Quad q) { return q.color; }
static inline QuadzColor QuadBackgroundColor(Quad q) { return q.backgroundColor; }
static inline CGRect QuadTextureRect(Quad q) { return q.texture; }
static inline void QuadSetColor(Quad *q, QuadzColor color) {
    q->color = color;
}
static inline void QuadSetBackgroundColor(Quad *q, QuadzColor color) {
    q->backgroundColor = color;
}
