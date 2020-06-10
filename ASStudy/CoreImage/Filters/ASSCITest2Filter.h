//
//  ASSCITest2Filter.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/10.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIFilter.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

// filter demo2: render "something" into the input image texture
@interface ASSCITest2Filter : ASSCIFilter

// origin is at left-top
@property (nonatomic, assign) CGRect targetRect;
//@property (nonatomic, assign) CGColorRef targetColor;
//@property (nonatomic, assign) CGImageRef targetImage;

@end

NS_ASSUME_NONNULL_END
