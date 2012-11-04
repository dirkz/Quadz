//
//  QuadzViewController.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/26/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadzViewController.h"

#import "DLog.h"
#import "QuadRenderer.h"
#import "RectTextureAtlas.h"

// Uniform index.
typedef enum : NSUInteger {
    UniformIndexModelViewProjection,
    UniformIndexTextureUnit0,
    UniformIndexMax
} UniformIndex;

@interface QuadzViewController ()
{
    GLint _uniforms[UniformIndexMax];
    GLuint _program;
}

@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, readonly) CGSize scaledBounds;
@property (nonatomic) QuadRenderer *quadRenderer;
@property (nonatomic) RectTextureAtlas *textureAtlas;

@end

@implementation QuadzViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.preferredFramesPerSecond = 60;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;

    _quadRenderer = [[QuadRenderer alloc] init];
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

    GLint maxTextureSize;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
    glCheckError();
    DLog(@"%s maxTextureSize %d", __PRETTY_FUNCTION__, maxTextureSize);

    NSString *texImagePath = [[NSBundle mainBundle] pathForResource:@"geoduck 20x40.png" ofType:nil];
    UIImage *texImage = [UIImage imageWithContentsOfFile:texImagePath];
    _textureAtlas = [[RectTextureAtlas alloc] initWithImage:texImage tilesize:CGSizeMake(20.f, 40.f)];
    
    [self loadShaders];
    glUseProgram(_program);

    [self setupProjection];

    glClearColor(0.2f, 0.2f, .75f, 1.0f);

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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupProjection];
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

- (void)update
{
    Quad quad = [self.textureAtlas quadAtPosition:CGPointMake(rand() % (NSUInteger) self.scaledBounds.width,
                                                              rand() % (NSUInteger) self.scaledBounds.height)
                                      withTexture:rand() % 1000];
    [self.quadRenderer addQuad:quad];
}

#pragma mark - GLKView and GLKViewController delegate methods

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
