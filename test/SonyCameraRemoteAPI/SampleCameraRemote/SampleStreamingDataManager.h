/**
 * @file  SampleStreamingDataManager.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import <Availability.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SampleStreamingDataDelegate.h"

@interface SampleStreamingDataManager : NSObject <NSStreamDelegate>

- (void)start:(NSString *)url
 viewDelegate:(id<SampleStreamingDataDelegate>)viewDelegate;

- (void)stop;

- (BOOL)isStarted;

@end
