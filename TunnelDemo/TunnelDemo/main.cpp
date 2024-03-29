//
//  main.cpp
//  TunnelDemo
//
//  Created by hys on 2019/6/15.
//  Copyright © 2019 hys. All rights reserved.
//

#include "GLTools.h"
#include "GLShaderManager.h"
#include "GLFrustum.h"
#include "GLBatch.h"
#include "GLFrame.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif

GLShaderManager        shaderManager;            //着色器管理器
GLMatrixStack        modelViewMatrix;        //模型视图矩阵
GLMatrixStack        projectionMatrix;        //投影矩阵
GLFrustum            viewFrustum;            //视景体
GLGeometryTransform    transformPipeline;        //几何变换管线

//4个批次容器类
GLBatch             floorBatch;//地面
GLBatch             ceilingBatch;//天花板
GLBatch             leftWallBatch;//左墙面
GLBatch             rightWallBatch;//右墙面

//深度初始值，-65。
GLfloat             viewZ = -65.0f;

// 纹理标识符号
#define TEXTURE_BRICK   0 //墙面
#define TEXTURE_FLOOR   1 //地板
#define TEXTURE_CEILING 2 //纹理天花板

#define TEXTURE_COUNT   3 //纹理个数

GLuint  textures[TEXTURE_COUNT];//纹理标记数组
//文件tag名字数组
const char *szTextureFiles[TEXTURE_COUNT] = { "brick.tga", "floor.tga", "ceiling.tga" };



//菜单栏选择
void ProcessMenu(int value)
{
    for (GLint iLoop = 0; iLoop < TEXTURE_COUNT; iLoop++) {
        
        glBindTexture(GL_TEXTURE_2D, textures[iLoop]);
        
        switch (value) {
            case 0:
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                break;
                
            case 1:
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                break;
                
            case 2:
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
                break;
                
            case 3:
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
                break;
                
            case 4:
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
                break;
                
            case 5:
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                break;
                
            case 6:
                GLfloat fLargest;
                glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &fLargest);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, fLargest);
                break;
                
            case 7:
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f);
                break;
                
            default:
                break;
        }
    }
    
    glutPostRedisplay();
}


//在这个函数里能够在渲染环境中进行任何需要的初始化，它这里的设置并初始化纹理对象
void SetupRC()
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    shaderManager.InitializeStockShaders();
    
    //分配纹理对象
    glGenTextures(TEXTURE_COUNT, textures);
    
    for (int i=0; i < TEXTURE_COUNT; i++) {
        //绑定纹理
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        
        //读取文件
        GLint iwidth, iheight,icomponents;
        GLenum  eformat;
        GLbyte  *byte;
        byte = gltReadTGABits(szTextureFiles[i], &iwidth, &iheight, &icomponents, &eformat);
        
        //设置纹理参数
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        //环绕方式
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //载入纹理
        glTexImage2D(GL_TEXTURE_2D, 0, icomponents, iwidth, iheight, 0, eformat, GL_UNSIGNED_BYTE, byte);
        
        glGenerateMipmap(GL_TEXTURE_2D);
        
        free(byte);
    }
    
    // 设置几何图形顶点/纹理坐标
    
    // 1.地板  其中1表示使用1组纹理
    floorBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    
    for (GLfloat z = 60.f; z >= 0.f; z -= 10.f) {
        
        floorBatch.MultiTexCoord2f(0, 0, 0);
        floorBatch.Vertex3f(-15.f, -15.f, z);
        
        floorBatch.MultiTexCoord2f(0, 1, 0);
        floorBatch.Vertex3f(15.f, -15.f, z);
        
        floorBatch.MultiTexCoord2f(0, 0, 1);
        floorBatch.Vertex3f(-15.f, -15.f, z - 10.f);
        
        floorBatch.MultiTexCoord2f(0, 1, 1);
        floorBatch.Vertex3f(15.f, -15.f, z - 10.f);
        
        
        
    }
    floorBatch.End();
    
    // 2.天花板
    ceilingBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    
    for (GLfloat z = 60.f; z >= 0.f; z -= 10.f) {
        
        ceilingBatch.MultiTexCoord2f(0, 0, 0);
        ceilingBatch.Vertex3f(-15.f, 15.f, z);
        
        ceilingBatch.MultiTexCoord2f(0, 1, 0);
        ceilingBatch.Vertex3f(15.f, 15.f, z);
        
        ceilingBatch.MultiTexCoord2f(0, 0, 1);
        ceilingBatch.Vertex3f(-15.f, 15.f, z - 10.f);
        
        ceilingBatch.MultiTexCoord2f(0, 1, 1);
        ceilingBatch.Vertex3f(15.f, 15.f, z - 10.f);
        
        
        
    }
    ceilingBatch.End();
    
    // 3.画左边墙
    leftWallBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    for (GLfloat z = 60.f; z >= 0.f; z -= 10.f) {
        
        leftWallBatch.MultiTexCoord2f(0, 0, 1);
        leftWallBatch.Vertex3f(-15.f, 15.f, z);
        
        leftWallBatch.MultiTexCoord2f(0, 0, 0);
        leftWallBatch.Vertex3f(-15.f, -15.f, z);
        
        leftWallBatch.MultiTexCoord2f(0, 1, 1);
        leftWallBatch.Vertex3f(-15.f, 15.f, z - 10.f);
        
        leftWallBatch.MultiTexCoord2f(0, 1, 0);
        leftWallBatch.Vertex3f(-15.f, -15.f, z - 10.f);
        
        
        
    }
    leftWallBatch.End();
    
    // 画右边墙
    rightWallBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    for (GLfloat z = 60.f; z >= 0.f; z -= 10.f) {
        
        rightWallBatch.MultiTexCoord2f(0, 0, 1);
        rightWallBatch.Vertex3f(15.f, 15.f, z);
        
        rightWallBatch.MultiTexCoord2f(0, 0, 0);
        rightWallBatch.Vertex3f(15.f, -15.f, z);
        
        rightWallBatch.MultiTexCoord2f(0, 1, 1);
        rightWallBatch.Vertex3f(15.f, 15.f,  z - 10.f);
        
        rightWallBatch.MultiTexCoord2f(0, 1, 0);
        rightWallBatch.Vertex3f(15.f, -15.f, z - 10.f);
        
        
        
    }
    rightWallBatch.End();
}


void ShutdownRC(void)
{
    //删除纹理
    glDeleteTextures(TEXTURE_COUNT, textures);
}


//前后移动视口来对方向键作出响应
void SpecialKeys(int key, int x, int y)
{
    if (key == GLUT_KEY_UP) {
        viewZ -= 1.f;
    }
    
    if (key == GLUT_KEY_DOWN) {
        viewZ += 1.f;
    }
    
    glutPostRedisplay();
}


//调用，绘制场景
void RenderScene(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    modelViewMatrix.PushMatrix();
    modelViewMatrix.Translate(0, 0, viewZ);
    
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_REPLACE, transformPipeline.GetModelViewProjectionMatrix(), 0);
    
    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_FLOOR]);
    floorBatch.Draw();
    
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_CEILING]);
    ceilingBatch.Draw();
    
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_BRICK]);
    leftWallBatch.Draw();
    rightWallBatch.Draw();
    
    modelViewMatrix.PopMatrix();
    
    glutSwapBuffers();
}


//改变视景体和视口，在改变窗口大小或初始化窗口调用
void ChangeSize(int w, int h)
{
    //1.防止对0进行除法操作
    if(h == 0)
        h = 1;
    
    //2.将视口设置大小
    glViewport(0, 0, w, h);
    
    GLfloat fAspect = (GLfloat)w/(GLfloat)h;
    
    //3.生成透视投影
    viewFrustum.SetPerspective(80.0f,fAspect,1.0,120.0);
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
    
}

int main(int argc, char *argv[])
{
    gltSetWorkingDirectory(argv[0]);
    
    // 标准初始化
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize(800, 600);
    glutCreateWindow("Tunnel");
    glutReshapeFunc(ChangeSize);
    glutSpecialFunc(SpecialKeys);
    glutDisplayFunc(RenderScene);
    
    // 添加菜单入口，改变过滤器
    glutCreateMenu(ProcessMenu);
    glutAddMenuEntry("GL_NEAREST",0);
    glutAddMenuEntry("GL_LINEAR",1);
    glutAddMenuEntry("GL_NEAREST_MIPMAP_NEAREST",2);
    glutAddMenuEntry("GL_NEAREST_MIPMAP_LINEAR", 3);
    glutAddMenuEntry("GL_LINEAR_MIPMAP_NEAREST", 4);
    glutAddMenuEntry("GL_LINEAR_MIPMAP_LINEAR", 5);
    glutAddMenuEntry("Anisotropic Filter", 6);
    glutAddMenuEntry("Anisotropic Off", 7);
    
    
    glutAttachMenu(GLUT_RIGHT_BUTTON);
    
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    
    
    // 启动循环，关闭纹理
    SetupRC();
    glutMainLoop();
    ShutdownRC();
    
    return 0;
}



