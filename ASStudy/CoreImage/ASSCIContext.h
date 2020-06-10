//
//  ASSCIContext.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class ASSCIImage;

NS_ASSUME_NONNULL_BEGIN

@interface ASSCIContext : NSObject

@property (nonatomic, assign, readonly) CVOpenGLESTextureCacheRef textureCache;

- (instancetype)initWithEAGLContext:(EAGLContext *)context;

- (void)drawImage:(ASSCIImage *)image inRect:(CGRect)inRect fromRect:(CGRect)fromRect;

@end

NS_ASSUME_NONNULL_END
