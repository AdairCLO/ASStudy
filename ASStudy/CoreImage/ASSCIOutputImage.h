//
//  ASSCIOutputImage.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASSCIImage.h"

@class ASSCIFilter;

NS_ASSUME_NONNULL_BEGIN

@interface ASSCIOutputImage : ASSCIImage

@property (nonatomic, strong, readonly) ASSCIFilter *filter;

- (instancetype)initWithFilter:(ASSCIFilter *)filter;

@end

NS_ASSUME_NONNULL_END
