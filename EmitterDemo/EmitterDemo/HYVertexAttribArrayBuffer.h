//
//  HYVertexAttribArrayBuffer.h
//  EmitterDemo
//
//  Created by hys on 2019/6/28.
//  Copyright © 2019 hys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    HYVertexAttribPosition = GLKVertexAttribPosition,
    HYVertexAttribNormal = GLKVertexAttribNormal,
    HYVertexAttribColor = GLKVertexAttribColor,
    HYVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    HYVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
} HYVertexAttrib;

@interface HYVertexAttribArrayBuffer : NSObject

@end

NS_ASSUME_NONNULL_END
