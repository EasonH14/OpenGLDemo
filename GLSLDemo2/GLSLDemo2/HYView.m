//
//  CCView.m
//  GLSLDemo2
//
//  Created by iMac on 2019/6/14.
//  Copyright © 2019 iMac. All rights reserved.
//

#import "HYView.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "GLESMath.h"

typedef struct {
    GLfloat vertex[3];
    GLfloat color[3];
    GLfloat textureCoord[2];
} CCVertex;


@interface HYView ()
{
    GLuint colorRenderBuffer;
    GLuint depthRenderBuffer;
    GLuint frameBuffer;
    GLuint elementsBuffer;
    
    GLfloat xDegree;
    GLfloat yDegree;
    GLfloat zDegree;
    
    GLboolean bx;
    GLboolean by;
    GLboolean bz;
    
    GLuint vertexShader, fragmentShader, program;
    
    NSTimer *timer;
}

@property (nonatomic, strong) EAGLContext *myContext;

@property (nonatomic, strong) CAEAGLLayer *myEaglLayer;

@end


@implementation HYView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self settupLayer];
    
    [self setupContext];
    
    [self deleteRenderBufferFrameBuffer];
    
    [self setupRenderBufferFrameBuffer];
    
    [self prepareToDraw];
    
    [self render];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)settupLayer {
    
    self.myEaglLayer = (CAEAGLLayer *)self.layer;
    
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    self.myEaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(false), kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
}


- (void)setupContext {
    
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:self.myContext];
    
}


- (void)deleteRenderBufferFrameBuffer {
    
    glDeleteRenderbuffers(1, &colorRenderBuffer);
    colorRenderBuffer = 0;
    
    glDeleteRenderbuffers(1, &depthRenderBuffer);
    depthRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &frameBuffer);
    frameBuffer = 0;
}

- (void)setupRenderBufferFrameBuffer {
    
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEaglLayer];
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // 将renderBuffer 附着到 frameBuffer 的color 附着点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
    
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH24_STENCIL8, GL_RENDERBUFFER, depthRenderBuffer);
}

// 从图片载入纹理
- (GLuint)loadTexture:(NSString *)fileName {
    
    // 解压图片
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        return 0;
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    // 根据图片大小分配空间
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    // 创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的每一行的内存所占的字节数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef context = CGBitmapContextCreate(spriteData, width, height, CGImageGetBitsPerComponent(spriteImage), CGImageGetBytesPerRow(spriteImage), CGImageGetColorSpace(spriteImage), CGImageGetBitmapInfo(spriteImage));
    
    // 绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), spriteImage);
    
    // 释放上下文
    CGContextRelease(context);
    
    GLuint textureId;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    
    free(spriteData);
    
    return textureId;
}


- (void)prepareToDraw {
    
    // 设置视口
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    // 编译顶点着色程序 和 片元着色程序
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER from:@"shaderv.vsh"]) {
        return;
    }
    
    if (![self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER from:@"shaderf.fsh"]) {
        return;
    }
    
    // 附着  链接 并 使用 program
    if (![self attachLinkUseProgram:&program with:vertexShader another:fragmentShader]) {
        return;
    }
    
    glUseProgram(program);
    
    // 设置 顶点数据&颜色数据&纹理数据 并 copy到 顶点缓存区  VAO -> VBO
    [self setupVertexData];
    
    // 索引绘图  EBO
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    glGenBuffers(1, &elementsBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementsBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
   
    // 传递顶点数据 -> 着色程序
    int position = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (GLfloat *)NULL);
    
    
    // 传递颜色数据 -> 着色程序
    int color = glGetAttribLocation(program, "color");
    glEnableVertexAttribArray(color);
    glVertexAttribPointer(color, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (GLfloat *)NULL + offsetof(CCVertex, color));
    
    
    // 传递纹理坐标
    int textureCoord = glGetAttribLocation(program, "textureCoord");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (GLfloat *)NULL + offsetof(CCVertex, textureCoord));
    
    // 利用采样器 获取纹素
    glUniform1f(glGetUniformLocation(program, "sampler"), 0);
}

- (void)rotateMatrix {
    // 传递模型视图矩阵
    KSMatrix4 modelViewMatrix;
    ksMatrixLoadIdentity(&modelViewMatrix);
    ksTranslate(&modelViewMatrix, 0.0, 0.0, -10.0);
    
    KSMatrix4 rotationMatrix;
    ksMatrixLoadIdentity(&rotationMatrix);
    ksRotate(&rotationMatrix, xDegree, 1.0, 0.0, 0.0);
    ksRotate(&rotationMatrix, yDegree, 0.0, 1.0, 0.0);
    ksRotate(&rotationMatrix, zDegree, 0.0, 0.0, 1.0);
    
    ksMatrixMultiply(&modelViewMatrix, &rotationMatrix, &modelViewMatrix);
    
    glUniformMatrix4fv(glGetUniformLocation(program, "rotateMatrix"), 1, GL_FALSE, &modelViewMatrix.m[0][0]);
    
    
    // 传递投影视图矩阵
    
    GLfloat width = self.bounds.size.width;
    GLfloat height = self.bounds.size.height;
    
    KSMatrix4 projectionMatrix;
    ksMatrixLoadIdentity(&projectionMatrix);
    
    ksPerspective(&projectionMatrix, 30.0f, width / height, 1.0f, 50.f);
    
    glUniformMatrix4fv(glGetUniformLocation(program, "projectionMatrix"), 1, GL_FALSE, &projectionMatrix.m[0][0]);
}

- (void)render {
    
    glClearColor(0.3, 0.4, 0.5, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 开启正背面剔除
    glEnable(GL_CULL_FACE);
    
    glUseProgram(program);
    
    [self rotateMatrix];
    
    // 开始绘制
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, 0);
    
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)shaderType from:(NSString *)filep {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filep ofType:nil];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(shaderType);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    
    if (status == GL_FALSE) {
        GLchar message[512];
        glGetShaderInfoLog(*shader, sizeof(message), NULL, message);
        NSString *info = [NSString stringWithUTF8String:message];
        NSLog(@"编译出错了: %@", info);
        return false;
    }
    
    return true;
}


- (BOOL)attachLinkUseProgram:(GLuint *)program with:(GLuint)vertexShader another:(GLuint)fragmentShader {
    
    *program = glCreateProgram();
    
    glAttachShader(*program, vertexShader);
    glAttachShader(*program, fragmentShader);
    
    glLinkProgram(*program);
    
    GLint status;
    glGetProgramiv(*program, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(*program, sizeof(512), NULL, message);
        NSString *info = [NSString stringWithUTF8String:message];
        NSLog(@"链接出错了: %@", info);
        return false;
    }
    
    glDetachShader(*program, vertexShader);
    glDetachShader(*program, fragmentShader);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return true;
}

- (void)setupVertexData {
    
    CCVertex vertexs[] = {
        {{-0.5f, 0.5f, 0.0f}, {1.0f, 0.0f, 1.0f}, {0.0f, 1.0f}},    // 左上
        {{0.5f, 0.5f, 0.0f}, {1.0f, 0.0f, 1.0f}, {1.0f, 1.0f}},     // 右上
        {{-0.5f, -0.5f, 0.0f}, {1.0f, 1.0f, 1.0f}, {0.0f, 0.0f}},   // 左下
        {{0.5f, -0.5f, 0.0f}, {1.0f, 1.0f, 1.0f}, {1.0f, 0.0f}},    // 右下
        
        {{0.0f, 0.0f, 1.0f}, {0.8f, 0.0f, 1.0f}, {0.5f, 0.5f}},     // 顶点
    };
    
    GLuint arrayBuffer;
    glGenBuffers(1, &arrayBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, arrayBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    
}

- (IBAction)rotateX:(UIButton *)sender {
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self reDegree];
        }];
    }
    bx = !bx;
}

- (IBAction)rotateY:(UIButton *)sender {
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self reDegree];
        }];
    }
    by = !by;
}

- (IBAction)rotateZ:(UIButton *)sender {
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self reDegree];
        }];
    }
    bz = !bz;
}

- (void)reDegree {
    
    xDegree += bx * 5;
    yDegree += by * 5;
    zDegree += bz * 5;
    
    if (!bx && !by && !bz) {
        return;
    }
    
    [self render];
}

@end
