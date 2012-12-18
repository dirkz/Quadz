//
//  QuadRenderer.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/28/12.
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

#import <GLKit/GLKit.h>

#import "QuadRenderer.h"

#import "QuadArray.h"
#import "DLog.h"

typedef struct {
    GLfloat position[2];
    GLfloat texture0[2];
    GLubyte color[4];
} vertex_t;

typedef GLushort QuadRendererIndexType;

static inline vertex_t VertexMakeWithColorPointer(GLfloat x, GLfloat y, GLfloat s, GLfloat t, QuadzColor color)
{
    vertex_t v = { x, y, s, t, color.r, color.g, color.b, color.a };
    return v;
}

@interface QuadRenderer ()

@property (nonatomic) QuadArray *quads;

@end

@implementation QuadRenderer
{
    /** the last vertex buffer we rendered in */
    vertex_t *_vertices;

    /** index buffer */
    GLushort *_indices;

    /** the last number of vertices rendered into @see _vertices */
    size_t _numberOfVertices;

    /** set to YES once the vertex arrays and vertex buffer objects were initialized */
    BOOL _setup;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _lastIndex;
}

- (id)init
{
    self = [super init];
    if (self) {
        _quads = [[QuadArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);

    if (_vertices) {
        free(_vertices);
    }
}

- (void)renderQuadArray:(QuadArray *)quads vertexBuffer:(vertex_t *)vertexBuffer indexBuffer:(GLushort *)indexBuffer
{
    _lastIndex = 0;
    vertex_t *vertex = vertexBuffer;
    GLushort *index = indexBuffer;
    for (size_t i = 0; i < quads.count; ++i) {
        Quad quad = [quads elementAt:i];

        CGFloat halfWidth = ((GLfloat) quad.width)/2;
        CGFloat halfHeight = ((GLfloat) quad.height)/2;

        // produce degenerate triangle to move to next quad position
        if (i > 0) {
            *index++ = _lastIndex-1;
            *index++ = _lastIndex;
        }

        CGRect textureRect = QuadTextureRect(quad);

        // bottom left
        *vertex++ = VertexMakeWithColorPointer(QuadX(quad) - halfWidth, QuadY(quad) - halfHeight,
                                               textureRect.origin.x,
                                               textureRect.origin.y - textureRect.size.height,
                                               QuadColor(quad));
        *index++ = _lastIndex++;

        // bottom right
        *vertex++ = VertexMakeWithColorPointer(QuadX(quad) + halfWidth, QuadY(quad) - halfHeight,
                                               textureRect.origin.x + textureRect.size.width,
                                               textureRect.origin.y - textureRect.size.height,
                                               QuadColor(quad));
        *index++ = _lastIndex++;

        // top left
        *vertex++ = VertexMakeWithColorPointer(QuadX(quad) - halfWidth, QuadY(quad) + halfHeight,
                                               textureRect.origin.x,
                                               textureRect.origin.y,
                                               QuadColor(quad));
        *index++ = _lastIndex++;

        // top right
        *vertex++ = VertexMakeWithColorPointer(QuadX(quad) + halfWidth, QuadY(quad) + halfHeight,
                                               textureRect.origin.x + textureRect.size.width,
                                               textureRect.origin.y,
                                               QuadColor(quad));
        *index++ = _lastIndex++;
    }
}

- (void)renderQuadArray:(QuadArray *)quads
{
    if (quads.count > 0) {
        // 4 vertices per quad, plus 2 vertices for degenerate triangles in between
        size_t newNumberOfVertices = quads.count * 4 + (quads.count-1) * 2;
        if (newNumberOfVertices != _numberOfVertices) {
            _numberOfVertices = newNumberOfVertices;
            _vertices = realloc(_vertices, _numberOfVertices * sizeof(vertex_t));
            _indices = realloc(_indices, _numberOfVertices * sizeof(GLushort));
        }
        [self renderQuadArray:quads vertexBuffer:_vertices indexBuffer:_indices];
    }
}

- (void)addQuad:(Quad)quad
{
    [self.quads addElement:quad];
}

- (void)removeAllQuads
{
    [self.quads removeAllElements];
}

- (void)bind
{
    if (!_setup) {
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glGenBuffers(1, &_indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

        glEnableVertexAttribArray(AttributeIndexPosition);
        glVertexAttribPointer(AttributeIndexPosition, 2, GL_FLOAT, GL_FALSE, sizeof(vertex_t),
                              (GLvoid *) offsetof(vertex_t, position));

        glEnableVertexAttribArray(AttributeIndexColor);
        glVertexAttribPointer(AttributeIndexColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(vertex_t),
                              (GLvoid *) offsetof(vertex_t, color));

        glEnableVertexAttribArray(AttributeIndexTexture0);
        glVertexAttribPointer(AttributeIndexTexture0, 2, GL_FLOAT, GL_FALSE, sizeof(vertex_t),
                              (GLvoid *) offsetof(vertex_t, texture0));

        _setup = YES;
    } else {
        glBindVertexArrayOES(_vertexArray);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    }
}

- (void)draw
{
    [self renderQuadArray:self.quads];
    if (_numberOfVertices) {
        glBufferData(GL_ARRAY_BUFFER, _numberOfVertices * sizeof(vertex_t), _vertices, GL_DYNAMIC_DRAW);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, _numberOfVertices * sizeof(GLushort), _indices, GL_DYNAMIC_DRAW);
        glDrawElements(GL_TRIANGLE_STRIP, _numberOfVertices, GL_UNSIGNED_SHORT, 0);
    }
}

- (NSUInteger)numberOfQuads
{
    return self.quads.count;
}

@end
