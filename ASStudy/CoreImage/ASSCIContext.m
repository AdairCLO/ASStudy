//
//  ASSCIContext.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIContext.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/gltypes.h>
#import <OpenGLES/es3/gl.h>
#import "ASSCIShaderProgram.h"
#import "ASSCIImage.h"
#import "ASSCIImage+Internal.h"
#import "ASSCIImageOutputing.h"

#define kVertexDataArrayLength 30

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
in highp vec2 textureCoordinate;\n\
out highp vec4 fragColor;\n\
\n\
void main()\n\
{\n\
    fragColor = texture(sampler, textureCoordinate);\n\
}";

@interface ASSCIContext ()
{
    float _vertexData[kVertexDataArrayLength];
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) ASSCIShaderProgram *shaderProgram;
@property (nonatomic, assign) GLuint vertexArrayBuf;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;

@end

@implementation ASSCIContext

- (instancetype)initWithEAGLContext:(EAGLContext *)context;
{
    self = [super init];
    if (self)
    {
        assert(context.API > kEAGLRenderingAPIOpenGLES2);
        if (context.API <= kEAGLRenderingAPIOpenGLES2)
        {
            @throw [[NSException alloc] initWithName:@"EAGLContextAPIVersion" reason:@"should use OpenGLES3 context" userInfo:nil];
        }
        
        [EAGLContext setCurrentContext:context];
        
        _context = context;
        
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
    
    if (_textureCache != NULL)
    {
        CFRelease(_textureCache);
        _textureCache = NULL;
    }
}

- (CVOpenGLESTextureCacheRef)textureCache
{
    if (_textureCache == NULL)
    {
#ifdef DEBUG
        CVReturn r =
#endif
        CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                     NULL, // cache attributes
                                     _context,
                                     NULL, // texture attribute
                                     &_textureCache);
#ifdef DEBUG
        assert(r == kCVReturnSuccess);
#endif
    }
    
    return _textureCache;
}

- (void)drawImage:(ASSCIImage *)image inRect:(CGRect)inRect fromRect:(CGRect)fromRect
{
    [EAGLContext setCurrentContext:_context];
    
    // save the current binding framebuffer, because the image/filter render would change the framebuffer
    GLint targetFramebuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &targetFramebuffer);
    
    // render
    id<ASSCIImageOutputing> imageOuput = image;
    [imageOuput prepareWithContext:self];
    [imageOuput render];
    
    // restore the current framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, targetFramebuffer);
    
    // vertex data
    if (_vertexArrayBuf == 0)
    {
        glGenBuffers(1, &_vertexArrayBuf);
    }
    glBindBuffer(GL_ARRAY_BUFFER, _vertexArrayBuf);
    
    CGRect viewportRect;
    float vertexData[kVertexDataArrayLength];
    size_t vertexDataSize = sizeof(vertexData);
    assert(vertexDataSize == sizeof(_vertexData));
    [[self class] vertexDataAndViewportRectWithImage:image inRect:inRect fromRect:fromRect vertexData:vertexData vertextDataSize:vertexDataSize viewportRect:&viewportRect];
    BOOL updateData = NO;
    for (NSUInteger i = 0; i < kVertexDataArrayLength; i++)
    {
        if (_vertexData[i] != vertexData[i])
        {
            updateData = YES;
            break;
        }
    }
    if (updateData)
    {
        glBufferData(GL_ARRAY_BUFFER, vertexDataSize, vertexData, GL_STATIC_DRAW);
    }
    
    // config vertex data
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, NULL);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, NULL + sizeof(float) * 3);
    
    // texture for sampler
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, imageOuput.outputTextureName);
 
    [_shaderProgram useProgram];
    
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(viewportRect.origin.x, viewportRect.origin.y, viewportRect.size.width, viewportRect.size.height);
    
    // draw
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

+ (void)vertexDataAndViewportRectWithImage:(ASSCIImage *)image inRect:(CGRect)inRect fromRect:(CGRect)fromRect vertexData:(float *)vertexData vertextDataSize:(NSUInteger)vertextDataSize viewportRect:(CGRect *)viewportRect
{
    *viewportRect = inRect;
    
    // when inRect is empty, no need to do anything special here, because the "viewport" will be set empty too later
    
    CGFloat s_min = 0;
    CGFloat s_max = 0;
    CGFloat t_min = 0;
    CGFloat t_max = 0;
    
    CGRect imgRect = image.extent;
    CGRect imgIntersectionRect = CGRectIntersection(imgRect, fromRect);
    if (!CGRectIsEmpty(imgIntersectionRect))
    {
        if (CGRectGetMaxX(fromRect) > CGRectGetWidth(imgRect) || CGRectGetMaxY(fromRect) > CGRectGetHeight(imgRect))
        {
            // partly
            CGFloat x_scale = CGRectGetWidth(inRect) / CGRectGetWidth(fromRect);
            CGFloat y_scale = CGRectGetHeight(inRect) / CGRectGetHeight(fromRect);
            
            viewportRect->size.width = x_scale * CGRectGetWidth(imgIntersectionRect);
            viewportRect->size.height = y_scale * CGRectGetHeight(imgIntersectionRect);
        }
        
        s_min = CGRectGetMinX(imgIntersectionRect) / CGRectGetWidth(imgRect);
        s_max = CGRectGetMaxX(imgIntersectionRect) / CGRectGetWidth(imgRect);
        t_min = CGRectGetMinY(imgIntersectionRect) / CGRectGetHeight(imgRect);
        t_max = CGRectGetMaxY(imgIntersectionRect) / CGRectGetHeight(imgRect);
        
        if (image.isFlip)
        {
            t_min = 1 - t_min;
            t_max = 1 - t_max;
        }
    }
    else
    {
        // nothing in the image will be displayed, just to viewport to empty
        *viewportRect = CGRectZero;
    }
    
    float data[] = {
         // position  // texture coordinate
         -1, -1, 0,   s_min, t_min, // left-bottom
         -1,  1, 0,   s_min, t_max, // left-top
          1, -1, 0,   s_max, t_min, // right-bottom
          1, -1, 0,   s_max, t_min, // right-bottom
          1,  1, 0,   s_max, t_max, // right-top
         -1,  1, 0,   s_min, t_max, // left-top
    };
    
    assert(sizeof(data) == vertextDataSize);
    memcpy(vertexData, data, vertextDataSize);
}

@end
