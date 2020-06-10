//
//  ASSCITestFilter.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/9.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIFilter.h"

NS_ASSUME_NONNULL_BEGIN

// filter demo: a normal filter, filter the input image pixel to a new texture with the same size
@interface ASSCITestFilter : ASSCIFilter

@property (nonatomic, assign) BOOL disableRed;
@property (nonatomic, assign) BOOL disableGreen;
@property (nonatomic, assign) BOOL disableBlue;

@end

NS_ASSUME_NONNULL_END
