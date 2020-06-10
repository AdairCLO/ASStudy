//
//  ASSCIOutputImage.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/4.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIOutputImage.h"
#import "ASSCIFilter.h"
#import "ASSCIFilter+Internal.h"
#import "ASSCIImageOutputing.h"

@interface ASSCIOutputImage ()

@property (nonatomic, strong) ASSCIFilter *filter;

@end

@implementation ASSCIOutputImage

- (instancetype)initWithFilter:(ASSCIFilter *)filter
{
    self = [super init];
    if (self)
    {
        assert(filter != nil);
        
        _filter = filter;
    }
    return self;
}

- (CGRect)extent
{
    return self.filter.inputImage.extent;
}

- (BOOL)isFlip
{
    return self.filter.inputImage.isFlip;
}

#pragma mark - ASSCIImageOutputing

- (GLuint)outputTextureName
{
    return self.filter.outputTextureName;
}

- (void)prepareWithContext:(ASSCIContext *)context
{
    [self.filter prepareWithContext:context];
}

- (void)render
{
    [self.filter render];
}

@end
