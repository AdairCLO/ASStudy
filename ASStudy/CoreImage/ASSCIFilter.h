//
//  ASSCIFilter.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASSCIImage;

NS_ASSUME_NONNULL_BEGIN

@interface ASSCIFilter : NSObject

@property (nonatomic, strong) ASSCIImage *inputImage;
- (ASSCIImage *)createOutputImage;

@end

NS_ASSUME_NONNULL_END
