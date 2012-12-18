//
//  QuadzGLKDrawer
//  Quadz
//
//  Created by Dirk Zimmermann on 11/28/12.
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

#import "QuadzGLKDrawer.h"

#import "DLog.h"
#import "QuadRenderer.h"
#import "QuadzRectTextureAtlas.h"
#import "QuadzFontTextureAtlas.h"
#import "QuadzBMFontTextureAtlas.h"

/** Whether to use a font texture or not */
static const enum
{
    QuadzGLKDrawerTexture = 0,
    QuadzGLKDrawerRectFontTexture,
    QuadzGLKDrawerBMFontTexture,
} QuadzGLKDrawerTextureType = QuadzGLKDrawerBMFontTexture;

static NSString * const QuadzGLKDrawerBounds = @"bounds";

// Uniform index
typedef enum : NSUInteger {
    UniformIndexModelViewProjection,
    UniformIndexTextureUnit0,
    UniformIndexMax
} UniformIndex;

@interface QuadzGLKDrawer ()
{
    GLint _uniforms[UniformIndexMax];
    GLuint _program;
}

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation QuadzGLKDrawer

- (id)initWithGLKView:(GLKView *)view
{
    self = [super init];
    if (self) {
        _view = view;
        DLog(@"%s view %@", __PRETTY_FUNCTION__, self.view);
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!self.context) {
            NSLog(@"Failed to create ES context");
        }
        
        self.view.context = self.context;
        self.view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
        
        _quadRenderer = [[QuadRenderer alloc] init];
        [self setupGL];
        self.view.delegate = self;
        [self.view addObserver:self forKeyPath:QuadzGLKDrawerBounds options:NSKeyValueObservingOptionOld |
         NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (id)initWithGLKViewController:(GLKViewController *)viewController
{
    if (self = [self initWithGLKView:(GLKView *) viewController.view]) {
        viewController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:QuadzGLKDrawerBounds];

    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)setupClearColor
{
    glClearColor(0.2f, 0.2f, .75f, 1.0f);
}

- (void)setupTextureAtlas;
{
    switch (QuadzGLKDrawerTextureType) {
        case QuadzGLKDrawerTexture: {
            NSString *texImagePath = [[NSBundle mainBundle] pathForResource:@"absurd124.png" ofType:nil];
            UIImage *texImage = [UIImage imageWithContentsOfFile:texImagePath];
            self.textureAtlas = [[QuadzRectTextureAtlas alloc] initWithImage:texImage
                                                                    tilesize:CGSizeMake(124.f, 124.f)];
        }
            break;
        case QuadzGLKDrawerRectFontTexture: {
            UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:96.f];
            self.textureAtlas = [[QuadzFontTextureAtlas alloc] initWithTilesize:CGSizeMake(124.f, 124.f)
                                                                           font:font start:'A' end:'z'];
        }
            break;
            
        case QuadzGLKDrawerBMFontTexture: {
            NSString *fntFilePath = [[NSBundle mainBundle] pathForResource:@"BMFont.fnt" ofType:nil];
            self.fontTextureAtlas = [[QuadzBMFontTextureAtlas alloc] initWithPath:fntFilePath];
        }
            break;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    GLint maxTextureSize;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
    glCheckError();
    DLog(@"%s maxTextureSize %d", __PRETTY_FUNCTION__, maxTextureSize);

    [self setupTextureAtlas];
    
    [self loadShaders];
    glUseProgram(_program);
    
    [self setupProjection];
    
    [self setupClearColor];
    
    [self.quadRenderer bind];
}

- (void)setupProjection
{
    DLog(@"%s viewport %@", __PRETTY_FUNCTION__, NSStringFromCGSize(self.scaledBounds));
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    GLKMatrix4 mvp = [self matrixOrthofLeft:0.f right:self.scaledBounds.width bottom:0.f top:self.scaledBounds.height
                                       near:-2.f far:2.f];
    glUniformMatrix4fv(_uniforms[UniformIndexModelViewProjection], 1, GL_FALSE, mvp.m);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.view && [keyPath isEqualToString:QuadzGLKDrawerBounds]) {
        CGRect old = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGRect new = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if (!CGRectEqualToRect(old, new)) {
            [self setupProjection];
        }
    }
}

#pragma mark - Util

/** Creates an orthographic projection matrix similar to glOrthof */
- (GLKMatrix4)matrixOrthofLeft:(GLfloat)left right:(GLfloat)right bottom:(GLfloat)bottom
                           top:(GLfloat)top near:(GLfloat)near far:(GLfloat)far
{
    GLfloat tx = -(right+left)/(right-left);
    GLfloat ty = -(top+bottom)/(top-bottom);
    GLfloat tz = -(far+near)/(far-near);
    return GLKMatrix4Make(2/(right-left), 0.f, 0.f, 0.f,
                          0.f, 2/(top-bottom), 0.f, 0.f,
                          0.f, 0.f, -2/(far-near), 0.f,
                          tx, ty, tz, 1.f);
}

/** @return view bounds in pixels */
- (CGSize)scaledBounds
{
    return CGSizeMake(self.view.bounds.size.width * self.view.contentScaleFactor,
                      self.view.bounds.size.height * self.view.contentScaleFactor);
}

- (CGPoint)scaledCenter
{
    CGSize bounds = self.scaledBounds;
    return CGPointMake(bounds.width/2, bounds.height/2);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    //[self.quadRenderer removeAllQuads];
    NSUInteger numberOfQuadsToDraw = rand() % (80 * 21 + 1);
    numberOfQuadsToDraw = 1;
    for (int i = 0; i < numberOfQuadsToDraw; ++i) {
        CGPoint position = CGPointMake(rand() % (NSUInteger) self.scaledBounds.width,
                                       rand() % (NSUInteger) self.scaledBounds.height);
        Quad quad;
        switch (QuadzGLKDrawerTextureType) {
            case QuadzGLKDrawerTexture:
            case QuadzGLKDrawerRectFontTexture:
                quad = [self.textureAtlas quadAtPosition:position
                                             withTexture:rand() % self.textureAtlas.numberOfTextures];
                QuadSetWidth(&quad, 64.f);
                QuadSetHeight(&quad, 64.f);
                break;
            case QuadzGLKDrawerBMFontTexture: {
                NSString *sample = self.fontTextureAtlas.sample;
                quad = [self.fontTextureAtlas quadAtPosition:position
                                                    withChar:[sample characterAtIndex:rand() % sample.length]];
                uint8_t color[] = { rand() % 255, rand() % 255, rand() % 255, 255 };
                QuadSetColor(&quad, color);
            }
                break;
        }
        [self.quadRenderer addQuad:quad];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    [self.quadRenderer draw];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, AttributeIndexPosition, "a_position");
    glBindAttribLocation(_program, AttributeIndexColor, "a_color");
    glBindAttribLocation(_program, AttributeIndexTexture0, "a_texCoord0");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    _uniforms[UniformIndexModelViewProjection] = glGetUniformLocation(_program, "u_modelViewProjectionMatrix");
    NSAssert1(_uniforms[UniformIndexModelViewProjection] != -1,
              @"invalid value %d for _uniforms[UniformIndexModelViewProjection] (u_modelViewProjectionMatrix)",
              _uniforms[UniformIndexModelViewProjection]);
    
    _uniforms[UniformIndexTextureUnit0] = glGetUniformLocation(_program, "s_texture0");
    NSAssert1(_uniforms[UniformIndexTextureUnit0] != -1,
              @"invalid value %d for _uniforms[UniformIndexTextureUnit] (s_texture0)",
              _uniforms[UniformIndexTextureUnit0]);
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
