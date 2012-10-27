//
//  QuadzViewController.m
//  Quadz
//
//  Created by Dirk Zimmermann on 10/26/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

#import "QuadzViewController.h"

#import "DLog.h"

// Uniform index.
typedef enum : NSUInteger {
    UniformIndexModelViewProjection,
    UniformIndexMax
} UniformIndex;

// Attribute index.
typedef enum : NSUInteger {
    AttributeIndexPosition,
    AttributeIndexColor,
    AttributeIndexMax
} AttributeIndex;

typedef struct {
    GLshort position[2];
    GLubyte color[4];
} vertex_t;

@interface QuadzViewController ()
{
    GLint _uniforms[UniformIndexMax];
    GLuint _program;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic, readonly) CGSize scaledBounds;

@end

@implementation QuadzViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
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

    [self loadShaders];
    glUseProgram(_program);

    [self setupProjection];

    glClearColor(0.2f, 0.2f, .75f, 1.0f);

    const vertex_t vertices[] = {
        { -1, -1, 255, 255, 0, 255 },
        { 1, -1, 255, 255, 0, 255 },
        { -1, 1, 255, 255, 0, 255 },
        { 1, 1, 255, 255, 0, 255 },
    };
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(AttributeIndexPosition);
    glVertexAttribPointer(AttributeIndexPosition, 2, GL_SHORT, GL_FALSE, sizeof(vertex_t),
                          (GLvoid *) offsetof(vertex_t, position));
    glEnableVertexAttribArray(AttributeIndexColor);
    glVertexAttribPointer(AttributeIndexColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(vertex_t),
                          (GLvoid *) offsetof(vertex_t, color));
}

- (void)setupProjection
{
    DLog(@"%s viewport %@", __PRETTY_FUNCTION__, NSStringFromCGSize(self.scaledBounds));
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    GLKMatrix4 mvp = [self matrixOrthofLeft:-2.f right:2.f bottom:-2.f top:2.f near:-2.f far:2.f];
    glUniformMatrix4fv(_uniforms[UniformIndexModelViewProjection], 1, GL_FALSE, mvp.m);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
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

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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
