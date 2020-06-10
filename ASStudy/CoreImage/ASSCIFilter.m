//
//  ASSCIFilter.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIFilter.h"
#import <OpenGLES/gltypes.h>
#import <OpenGLES/es3/gl.h>
#import "ASSCIOutputImage.h"
#import "ASSCIImage+Internal.h"
#import "ASSCIImageOutputing.h"

@interface ASSCIFilter () <ASSCIImageOutputing>

@property (nonatomic, assign) GLuint outputTextureName;

@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderTextureName;
@property (nonatomic, assign) CGSize renderTextureSize;

@end

@implementation ASSCIFilter

- (void)dealloc
{
    if (_renderTextureName != 0)
    {
        glDeleteTextures(1, &_renderTextureName);
        _renderTextureName = 0;
    }
    
    if (_frameBuffer != 0)
    {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (ASSCIImage *)createOutputImage
{
    ASSCIImage *outputImage = [[ASSCIOutputImage alloc] initWithFilter:self];
    return outputImage;
}

#pragma mark - ASSCIImageOutputing

- (void)prepareWithContext:(ASSCIContext *)context
{
    assert(_inputImage != nil);
    if (_inputImage == nil)
    {
        return;
    }
    
    [self.inputImage prepareWithContext:context];
}

- (void)render
{
    assert(_inputImage != nil);
    if (_inputImage == nil)
    {
        return;
    }
    
    [self.inputImage render];
    
    // the "outputImageName" of the previous element(image or filter) will be valid after render, so put "prepareCore" here
    [self prepareCore];
    
    [self renderCore];
}

#pragma mark - Protected

- (void)prepareRenderTextureWithSize:(CGSize)size
{
    if (_renderTextureName != 0 && !CGSizeEqualToSize(_renderTextureSize, size))
    {
        glDeleteTextures(1, &_renderTextureName);
    }
    
    glGenTextures(1, &_renderTextureName);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _renderTextureName);
    
    // some texture parameters of texture created by gen texture
    // - GL_TEXTURE_MIN_FILTER: GL_NEAREST_MIPMAP_LINEAR!!!!!!!!!!!!
    // - GL_TEXTURE_MIN_FILTER: GL_LINEAR
    // - GL_TEXTURE_WRAP_S: GL_REPEAT
    // - GL_TEXTURE_WRAP_T: GL_REPEAT
    // == in OpenGLES2.0, for image width/height is not the power of 2, GL_TEXTURE_WRAP_S/GL_TEXTURE_WRAP_T should set to GL_CLAMP_TO_EDGE, or the sampler in the fragment shader will not work
    // == in OpenGLES3.0, no need to set
    
    // !!!!!!important!!!!!!
    // if not set the GL_TEXTURE_MIN_FILTER to GL_LINEAR, the sampler in the fragament shader will not work
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    _renderTextureSize = size;
}

- (void)prepareFrameBufferWithTextureName:(GLuint)name
{
    assert(name != 0);
    
    if (_frameBuffer == 0)
    {
        glGenFramebuffers(1, &_frameBuffer);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, name, 0);
    
#ifdef DEBUG
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    assert(status == GL_FRAMEBUFFER_COMPLETE);
#endif
}

- (GLuint)inputTextureName
{
    return self.inputImage.outputTextureName;
}

- (void)prepareCore
{
    // to implement by subclass
}

- (void)renderCore
{
    // to implement by subclas
}

@end
