//
//  ASSCIImage.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASSCIImage : NSObject

- (instancetype)initWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@property (nonatomic, assign, readonly) CVPixelBufferRef pixelBuffer;
@property (nonatomic, assign, readonly) CGRect extent;
@property (nonatomic, assign, readonly) BOOL isFlip;

@end

NS_ASSUME_NONNULL_END
