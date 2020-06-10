//
//  ASSCITest2Filter.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCITest2Filter.h"
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>
#import "ASSCIFilter+Protected.h"
#import "ASSCIImage.h"
#import "ASSCIShaderProgram.h"

static NSString * const kVertexShader = @"#version 300 es\n\
layout (location = 0) in vec4 position;\n\
//layout (location = 1) in vec2 textureCoord;\n\
layout (location = 1) in vec4 color;\n\
//out vec2 textureCoordinate;\n\
out vec4 textureColor;\n\
void main()\n\
{\n\
    //textureCoordinate = textureCoord;\n\
    textureColor = color;\n\
    gl_Position = position;\n\
}";

static NSString * const kFragmentShader = @"#version 300 es\n\
uniform sampler2D sampler;\n\
//in highp vec2 textureCoordinate;\n\
in highp vec4 textureColor;\n\
out highp vec4 fragColor;\n\
\n\
void main()\n\
{\n\
    //fragColor = texture(sampler, textureCoordinate);\n\
    fragColor = textureColor;\n\
}";

@interface ASSCITest2Filter ()
{
    float _vertexData[36];
}

@property (nonatomic, strong) ASSCIShaderProgram *shaderProgram;
@property (nonatomic, assign) GLuint vertexArrayBuf;

@end

@implementation ASSCITest2Filter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _shaderProgram = [[ASSCIShaderProgram alloc] initWithVertexShaderContent:kVertexShader fragmentShaderContent:kFragmentShader];
        [_shaderProgram linkProgram];
        
        _targetRect = CGRectZero;
    }
    return self;
}

- (void)dealloc
{
    if (_vertexArrayBuf != 0)
    {
        glDeleteBuffers(1, &_vertexArrayBuf);
        _vertexArrayBuf = 0;
    }
}

- (void)prepareCore
{
    [self prepareRenderTextureWithSize:self.targetRect.size];
    // render to the input texture!!!!!!
    [self prepareFrameBufferWithTextureName:self.inputTextureName];
}

- (void)renderCore
{
    if (_vertexArrayBuf == 0)
    {
        glGenBuffers(1, &_vertexArrayBuf);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexArrayBuf);
        
//        float vertexData[] = {
//             // position  // texture coordinate
//             -1, -1, 0,   0, 0, // left-bottom
//             -1,  1, 0,   0, 1, // left-top
//              1, -1, 0,   1, 0, // right-bottom
//              1, -1, 0,   1, 0, // right-bottom
//              1,  1, 0,   1, 1, // right-top
//             -1,  1, 0,   0, 1, // left-top
//        };
        
        float vertexData[] = {
             // position  // color
             -1, -1, 0,   1, 0, 0, // left-bottom
             -1,  1, 0,   1, 0, 0, // left-top
              1, -1, 0,   1, 0, 0, // right-bottom
              1, -1, 0,   1, 0, 0, // right-bottom
              1,  1, 0,   1, 0, 0, // right-top
             -1,  1, 0,   1, 0, 0, // left-top
        };
        assert(sizeof(vertexData) == sizeof(_vertexData));
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    }
    else
    {
        glBindBuffer(GL_ARRAY_BUFFER, _vertexArrayBuf);
    }

    // vertex data
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 6, NULL);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 6, NULL + sizeof(float) * 3);

    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.inputTextureName);

    [_shaderProgram useProgram];
    
    // can not clear!!!!!!
//    glClear(GL_COLOR_BUFFER_BIT);
    CGSize size = self.renderTextureSize;
    CGPoint viewportOrigin = self.targetRect.origin;
    if (!self.inputImage.isFlip)
    {
        CGSize imageSize = self.inputImage.extent.size;
        viewportOrigin.y = imageSize.height - size.height - viewportOrigin.y;
    }
    glViewport(viewportOrigin.x, viewportOrigin.y, size.width, size.height);
    
    // draw
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    self.outputTextureName = self.inputTextureName;
}

@end
