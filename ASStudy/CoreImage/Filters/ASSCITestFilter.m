//
//  ASSCITestFilter.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/9.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCITestFilter.h"
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>
#import "ASSCIFilter+Protected.h"
#import "ASSCIImage.h"
#import "ASSCIShaderProgram.h"

static NSString * const kVertexShader = @"#version 300 es\n\
layout (location = 0) in vec4 position;\n\
layout (location = 1) in vec2 textureCoord;\n\
out vec2 textureCoordinate;\n\
void main()\n\
{\n\
    textureCoordinate = textureCoord;\n\
    gl_Position = position;\n\
}";

static NSString * const kFragmentShader = @"#version 300 es\n\
uniform sampler2D sampler;\n\
uniform bool disableR;\n\
uniform bool disableG;\n\
uniform bool disableB;\n\
in highp vec2 textureCoordinate;\n\
out highp vec4 fragColor;\n\
\n\
void main()\n\
{\n\
    fragColor = texture(sampler, textureCoordinate);\n\
    if (disableR) fragColor.r = 0.0;\n\
    if (disableG) fragColor.g = 0.0;\n\
    if (disableB) fragColor.b = 0.0;\n\
}";

@interface ASSCITestFilter ()
{
    float _vertexData[30];
}

@property (nonatomic, strong) ASSCIShaderProgram *shaderProgram;
@property (nonatomic, assign) GLuint vertexArrayBuf;

@end

@implementation ASSCITestFilter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _shaderProgram = [[ASSCIShaderProgram alloc] initWithVertexShaderContent:kVertexShader fragmentShaderContent:kFragmentShader];
        [_shaderProgram linkProgram];
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
    [self prepareRenderTextureWithSize:self.inputImage.extent.size];
    [self prepareFrameBufferWithTextureName:self.renderTextureName];
}

- (void)renderCore
{
    if (_vertexArrayBuf == 0)
    {
        glGenBuffers(1, &_vertexArrayBuf);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexArrayBuf);
        
        float vertexData[] = {
             // position  // texture coordinate
             -1, -1, 0,   0, 0, // left-bottom
             -1,  1, 0,   0, 1, // left-top
              1, -1, 0,   1, 0, // right-bottom
              1, -1, 0,   1, 0, // right-bottom
              1,  1, 0,   1, 1, // right-top
             -1,  1, 0,   0, 1, // left-top
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
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, NULL);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, NULL + sizeof(float) * 3);

    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.inputTextureName);

    [_shaderProgram useProgram];
    [_shaderProgram setUniformWithName:@"disableR" toIntValue:_disableRed];
    [_shaderProgram setUniformWithName:@"disableG" toIntValue:_disableGreen];
    [_shaderProgram setUniformWithName:@"disableB" toIntValue:_disableBlue];
    
    glClear(GL_COLOR_BUFFER_BIT);
    CGSize size = self.renderTextureSize;
    glViewport(0, 0, size.width, size.height);
    
    // draw
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    self.outputTextureName = self.renderTextureName;
}

@end
