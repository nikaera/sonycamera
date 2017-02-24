//
//  SampleStreamingDataDelegate.h
//  test
//
//  Created by 福本駿 on 2017/02/24.
//  Copyright © 2017年 Takuma Noguchi. All rights reserved.
//

#ifndef SampleStreamingDataDelegate_h
#define SampleStreamingDataDelegate_h

#import <Availability.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol SampleStreamingDataDelegate <NSObject>

- (void)didFetchImage:(UIImage *)image;

- (void)didStreamingStopped;

@end


#endif /* SampleStreamingDataDelegate_h */
