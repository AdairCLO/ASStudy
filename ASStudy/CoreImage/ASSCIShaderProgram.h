//
//  ASSCIShaderProgram.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/8.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/gltypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASSCIShaderProgram : NSObject

- (instancetype)initWithVertexShaderContent:(NSString *)vertexShaderContent fragmentShaderContent:(NSString *)fragmentShaderContent;
- (instancetype)initWithShaderFileName:(NSString *)shaderFileName; // <shaderFileName>.vsh and <shaderFileName>.fsh

@property (nonatomic, assign, readonly) GLuint shaderProgram;

- (void)bindVertexAttributeWithName:(NSString *)name toLocation:(uint32_t)location;
- (void)setUniformWithName:(NSString *)name toIntValue:(int32_t)intValue;
- (void)setUniformWithName:(NSString *)name toFloatValue:(float)floatValue;
- (void)linkProgram;
- (void)useProgram;

@end

NS_ASSUME_NONNULL_END
