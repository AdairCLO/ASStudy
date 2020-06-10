//
//  ASSCIFilter+Protected.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIFilter.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASSCIFilter (Protected)

- (GLuint)inputTextureName;

- (GLuint)frameBuffer;
- (GLuint)renderTextureName;
- (CGSize)renderTextureSize;
- (GLuint)outputTextureName;
- (void)setOutputTextureName:(GLuint)name; // need to set value

- (void)prepareRenderTextureWithSize:(CGSize)size; // init renderTextureName
- (void)prepareFrameBufferWithTextureName:(GLuint)name; // init frameBuffer
- (void)prepareCore; // need to implement
- (void)renderCore;  // need to implement

@end

NS_ASSUME_NONNULL_END
