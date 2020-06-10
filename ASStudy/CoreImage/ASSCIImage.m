//
//  ASSCIImage.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIImage.h"
#import <OpenGLES/gltypes.h>
#import <OpenGLES/es3/glext.h>
#import "ASSCIImageOutputing.h"
#import "ASSCIContext.h"

@interface ASSCIImage () <ASSCIImageOutputing>

@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;
@property (nonatomic, assign) CGRect extent;
@property (nonatomic, assign) BOOL isFlip;

@property (nonatomic, assign) GLuint outputTextureName;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;

@end

@implementation ASSCIImage

- (instancetype)initWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    self = [super init];
    if (self)
    {
        _pixelBuffer = pixelBuffer;
        if (_pixelBuffer != NULL)
        {
            CVPixelBufferRetain(_pixelBuffer);
            
            size_t width = CVPixelBufferGetWidth(pixelBuffer);
            size_t height = CVPixelBufferGetHeight(pixelBuffer);
            _extent = CGRectMake(0, 0, width, height);
            
            _isFlip = CVImageBufferIsFlipped(pixelBuffer);
        }
    }
    return self;
}

- (void)dealloc
{
    if (_pixelBuffer != NULL)
    {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = NULL;
    }
    
    if (_textureCache != NULL)
    {
        CFRelease(_textureCache);
        _textureCache = NULL;
    }
}

- (void)setTextureCache:(CVOpenGLESTextureCacheRef)textureCache
{
    if (_textureCache != textureCache)
    {
        if (_textureCache != NULL)
        {
            CFRelease(_textureCache);
        }
        
        if (textureCache != NULL)
        {
            CFRetain(textureCache);
        }
        _textureCache = textureCache;
    }
}

#pragma mark - ASSCIImageOutputing

- (void)prepareWithContext:(ASSCIContext *)context
{
    self.textureCache = context.textureCache;
}

- (void)render
{
    CVOpenGLESTextureRef texture = NULL;
    
    GLint pixcelFormatType = [self pixelFormatType];
    CVReturn r = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                              _textureCache,
                                                              _pixelBuffer,
                                                              NULL, // texture attributes
                                                              GL_TEXTURE_2D,
                                                              GL_RGBA,
                                                              (GLsizei)_extent.size.width,
                                                              (GLsizei)_extent.size.height,
                                                              pixcelFormatType,
                                                              GL_UNSIGNED_BYTE, // type
                                                              0, // planeIndex
                                                              &texture);
    assert(r == kCVReturnSuccess);
    if (r == kCVReturnSuccess)
    {
        _outputTextureName = CVOpenGLESTextureGetName(texture);
        
        // some texture parameters of texture created by texture cache
        // - GL_TEXTURE_MIN_FILTER: GL_LINEAR
        // - GL_TEXTURE_MIN_FILTER: GL_LINEAR
        // - GL_TEXTURE_WRAP_S: GL_REPEAT
        // - GL_TEXTURE_WRAP_T: GL_REPEAT
        // == in OpenGLES2.0, for image width/height is not the power of 2, GL_TEXTURE_WRAP_S/GL_TEXTURE_WRAP_T should set to GL_CLAMP_TO_EDGE, or the sampler in the fragment shader will not work
        // == in OpenGLES3.0, no need to set
    }
    
    // I think, the texture has been managed by texture cahce, so release the texture here
    if (texture != NULL)
    {
        CFRelease(texture);
    }
    
    // no need to call CVOpenGLESTextureCacheFlush, because CVOpenGLESTextureCacheCreateTextureFromImage will try to flush too
}

- (GLint)pixelFormatType
{
    GLint type = GL_RGBA;
    
    OSType pixelFormatType = CVPixelBufferGetPixelFormatType(_pixelBuffer);
    switch (pixelFormatType)
    {
        case kCVPixelFormatType_24RGB:
        {
            type = GL_RGB;
            break;
        }
        case kCVPixelFormatType_32BGRA:
        {
            type = GL_BGRA;
            break;
        }
        case kCVPixelFormatType_32RGBA:
        {
            type = GL_RGBA;
        }
        default:
        {
            // to suport
            assert(NO);
            break;
        }
    }
    
    return type;
}

@end
