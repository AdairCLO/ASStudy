//
//  ASSCIImageOutputing.h
//  ASStudy
//
//  Created by Adair Wang on 2020/6/9.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASSCIContext;

NS_ASSUME_NONNULL_BEGIN

@protocol ASSCIImageOutputing <NSObject>

- (GLuint)outputTextureName;

- (void)prepareWithContext:(ASSCIContext *)context;
- (void)render;

@end

NS_ASSUME_NONNULL_END
