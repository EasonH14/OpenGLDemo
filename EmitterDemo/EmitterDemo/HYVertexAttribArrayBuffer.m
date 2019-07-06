//
//  HYVertexAttribArrayBuffer.m
//  EmitterDemo
//
//  Created by hys on 2019/6/28.
//  Copyright © 2019 hys. All rights reserved.
//

#import "HYVertexAttribArrayBuffer.h"

@interface HYVertexAttribArrayBuffer ()

@property (nonatomic, assign) GLuint name;  // 缓存区名字

@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;  // 缓存区大小字节数

@property (nonatomic, assign) GLsizeiptr stride;  // 步长

@end

@implementation HYVertexAttribArrayBuffer

- (instancetype)initWithAttribStride:(GLsizeiptr)aStride
                    numberOfVertices:(GLsizei)count
                               bytes:(const GLvoid *)dataPtr
                               usage:(GLenum)usage
{
    self = [super init];
    if (self) {
        
        _stride = aStride;
        _bufferSizeBytes = _stride * count;
        
        glGenBuffers(1, &_name);
    }
    return self;
}

@end
