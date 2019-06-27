//
//  SplitView.m
//  SplitScreenDemo
//
//  Created by hys on 2019/6/25.
//  Copyright © 2019 hys. All rights reserved.
//

#import "SplitView.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 vertex;
    GLKVector2 textureCoord;
}CCVertex;

@interface SplitView ()
{
    GLuint renderBufferId;
    GLuint frameBufferId;
    
    GLuint program;
    
    GLuint vertexBufferId;
    GLuint textureId;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;

@property (nonatomic, strong) EAGLContext *myContext;

@end

@implementation SplitView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)commonInit {
    [self setupLayer];
    [self setupContext];
    [self setupRenderBufferFrameBuffer];
    [self setupVertexData];
    
    [self setupProgramWithName:@"SplitScreen_1"];
    [self loadTexture:@"kunkun.jpg"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self render];
}

- (void)renderWithName:(NSString *)name {
    
    [self setupProgramWithName:name];
    [self render];
}


#pragma mark - dealloc
- (void)dealloc {
    
    if ([EAGLContext currentContext] == self.myContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
    if (vertexBufferId) {
        glDeleteBuffers(1, &vertexBufferId);
        vertexBufferId = 0;
    }
    
}


#pragma mark - render
- (void)render {
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
    [self useProgram];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

#pragma mark - vertex data
- (void)setupVertexData {
    
    CCVertex vertexs[4] = {
        {{-1, -1, 0.0}, {0.0, 0.0}},
        {{1, -1, 0.0}, {1.0, 0.0}},
        {{-1, 1, 0.0}, {0.0, 1.0}},
        {{1, 1, 0.0}, {1.0, 1.0}},
    };
    
    if (vertexBufferId) {
        glDeleteBuffers(1, &vertexBufferId);
        vertexBufferId = 0;
    }
    
    GLuint arrayBufferId;
    glGenBuffers(1, &arrayBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, arrayBufferId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    vertexBufferId = arrayBufferId;
}

#pragma mark - load texture
- (void)loadTexture:(NSString *)fileName {
    
    UIImage *image = [UIImage imageNamed:fileName];
    CGImageRef imageRef = image.CGImage;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    void *data = malloc(width * height * 4);
    
    CGContextRef contextRef = CGBitmapContextCreate(data, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    
    CGContextTranslateCTM(contextRef, 0, height);
    CGContextScaleCTM(contextRef, 1.f, -1.f);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(contextRef);
    
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    free(data);
    
}


#pragma mark - use program
- (void)useProgram {
    
    glUseProgram(program);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (GLvoid *)NULL + offsetof(CCVertex, vertex));
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (GLvoid *)NULL + offsetof(CCVertex, textureCoord));
    
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(glGetUniformLocation(program, "sampler"), 0);
}


#pragma mark - compile shader & link program
- (void)setupProgramWithName:(NSString *)name {
    
    GLuint vertexShader;
    GLuint fragShaer;
    
    if (![self compileShader:&vertexShader name:[name stringByAppendingString:@".vsh"] type:GL_VERTEX_SHADER]) {
        
        return;
    }
    
    if (![self compileShader:&fragShaer name:[name stringByAppendingString:@".fsh"] type:GL_FRAGMENT_SHADER]) {
        
        return;
    }
    
    if (program) {
        glDeleteProgram(program);
    }
    
    program = glCreateProgram();
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShaer);
    
    glBindAttribLocation(program, 0, "position");
    glBindAttribLocation(program, 1, "textureCoords");
    
    glLinkProgram(program);
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(program, sizeof(message), NULL, message);
        NSLog(@"link error: %@", [NSString stringWithUTF8String:message]);
        return;
    }
    
    glDetachShader(program, vertexShader);
    glDetachShader(program, fragShaer);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragShaer);
}

- (GLint)compileShader:(GLuint *)shader name:(NSString *)name type:(GLenum)type {
    
    *shader = glCreateShader(type);
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    const char *sources = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
    glShaderSource(*shader, 1, &sources, NULL);
    glCompileShader(*shader);
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar message[512];
        glGetShaderInfoLog(*shader, sizeof(message), NULL, message);
        NSLog(@"compile error: %@", [NSString stringWithUTF8String:message]);
        return GL_FALSE;
    }
    
    return GL_TRUE;
}


#pragma mark - setup
- (void)setupRenderBufferFrameBuffer {
    
    glGenRenderbuffers(1, &renderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferId);
    
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    
    glGenFramebuffers(1, &frameBufferId);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferId);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBufferId);
}


- (void)setupContext {
    
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:self.myContext];
}

- (void)setupLayer {
    
    self.myEAGLLayer = (CAEAGLLayer *)self.layer;
    self.myEAGLLayer.contentsScale = [[UIScreen mainScreen] scale];
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false), kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (GLint)drawableWidth {
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}


- (GLint)drawableHeight {
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}

@end
