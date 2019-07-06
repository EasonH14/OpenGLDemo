//
//  ViewController.m
//  OpenGLESTest2
//
//  Created by iMac on 2019/6/5.
//  Copyright © 2019 iMac. All rights reserved.
//

#import "CubeViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;
    GLKVector3 textureCoord;
    GLKVector3 normal;
} HYVertex;

static GLint const kCoordCount = 24;
static GLint const kFaceCount = 6;
static GLint const kFaceVertexCount = 4;

@interface CubeViewController ()<GLKViewDelegate>
{
    HYVertex *vertices;
    GLuint vertexBuffer;
    GLint angle;
}

@property (nonatomic, strong) GLKView *glkView;

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation CubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self commonInit];
    
    [self addCADisplayLink];
}

- (void)dealloc {
    
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    if (vertices) {
        free(vertices);
        vertices = nil;
    }
    
    if (vertexBuffer) {
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
    
    [self.displayLink invalidate];
}

- (void)addCADisplayLink {
    
    angle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)commonInit {
    
    // 设置context
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    // 添加glkview
    self.glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width) context:context];
    self.glkView.delegate = self;
    self.glkView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.glkView];
    
    // 设置glkview深度缓存区和颜色缓存区格式
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self loadTexture];
  
    // 设置顶点数据
    [self vertexDataSetup];
}

- (void)loadTexture {
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"2.jpg"];
    
    GLKTextureInfo *tetureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:@{GLKTextureLoaderOriginBottomLeft : @(GL_TRUE)} error:nil];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = tetureInfo.name;
    self.baseEffect.texture2d0.target = tetureInfo.target;
}

- (void)vertexDataSetup {
    
    // 开辟顶点数据空间
    vertices = malloc(sizeof(HYVertex) * kCoordCount);
    
    // 前面
    vertices[0] = (HYVertex){{0.5, -0.5, 0.5}, {1, 0}, {0, 0, 1}};
    vertices[1] = (HYVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    vertices[2] = (HYVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    vertices[3] = (HYVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 0, 1}};
    
    // 后面
    vertices[4] = (HYVertex){{-0.5, 0.5, -0.5}, {0, 1}, {0, 0, -1}};
    vertices[5] = (HYVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    vertices[6] = (HYVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    vertices[7] = (HYVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, 0, -1}};
    
    // 上面
    vertices[8] = (HYVertex){{0.5, 0.5, 0.5}, {1, 0}, {0, 1, 0}};
    vertices[9] = (HYVertex){{-0.5, 0.5, 0.5}, {0, 0}, {0, 1, 0}};
    vertices[10] = (HYVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 1, 0}};
    vertices[11] = (HYVertex){{-0.5, 0.5, -0.5}, {0, 1}, {0, 1, 0}};
    
    // 下面
    vertices[12] = (HYVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, -1, 0}};
    vertices[13] = (HYVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    vertices[14] = (HYVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    vertices[15] = (HYVertex){{0.5, -0.5, 0.5}, {1, 1}, {0, -1, 0}};
    
    // 左面
    vertices[16] = (HYVertex){{-0.5, -0.5, -0.5}, {0, 0}, {-1, 0, 0}};
    vertices[17] = (HYVertex){{-0.5, -0.5, 0.5}, {1, 0}, {-1, 0, 0}};
    vertices[18] = (HYVertex){{-0.5, 0.5, -0.5}, {0, 1}, {-1, 0, 0}};
    vertices[19] = (HYVertex){{-0.5, 0.5, 0.5}, {1, 1}, {-1, 0, 0}};
    
    // 右面
    vertices[20] = (HYVertex){{0.5, 0.5, -0.5}, {1, 1}, {1, 0, 0}};
    vertices[21] = (HYVertex){{0.5, 0.5, 0.5}, {0, 1}, {1, 0, 0}};
    vertices[22] = (HYVertex){{0.5, -0.5, -0.5}, {1, 0}, {1, 0, 0}};
    vertices[23] = (HYVertex){{0.5, -0.5, 0.5}, {0, 0}, {1, 0, 0}};
    
    // 开辟顶点缓存区 VBO
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(HYVertex) * kCoordCount, vertices, GL_STATIC_DRAW);
    
    // 开启通道
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(HYVertex), NULL + offsetof(HYVertex, positionCoord));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(HYVertex), NULL + offsetof(HYVertex, textureCoord));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(HYVertex), NULL + offsetof(HYVertex, normal));
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glEnable(GL_DEPTH_TEST);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    for (GLint i = 0; i < kFaceCount; i++) {
        glDrawArrays(GL_TRIANGLE_STRIP, i * kFaceVertexCount, kFaceVertexCount);
    }
}


#pragma mark - update
- (void)update {
    
    angle = (angle + 5) % 360;
    
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(angle), 0.3, 0.7, 0.2);
    
    [self.glkView display];
}

@end
