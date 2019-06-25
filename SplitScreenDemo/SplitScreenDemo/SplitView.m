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

@interface SplitView ()
{
    GLuint renderBufferId;
    GLuint frameBufferId;
    
    GLuint program;
}

@property (nonatomic, strong) CAEAGLLayer *myEAGLLayer;

@property (nonatomic, strong) EAGLContext *myContext;

@end

@implementation SplitView

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
    
    program = glCreateProgram();
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShaer);
    
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
    glBindBuffer(GL_RENDERBUFFER, renderBufferId);
    
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEAGLLayer];
    
    glGenFramebuffers(1, &frameBufferId);
    glBindBuffer(GL_FRAMEBUFFER, frameBufferId);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBufferId);
}


- (void)setupContext {
    
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:self.myContext];
}

- (void)setupLayer {
    
    self.myEAGLLayer = (CAEAGLLayer *)self.layer;
    
    self.myEAGLLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false), kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}


@end
