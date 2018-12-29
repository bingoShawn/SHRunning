//
//  SHTimeManager.h
//  iOS_2D_RecordPath
//
//  Created by Shawn on 2018/12/19.
//  Copyright © 2018年 FENGSHENG. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SHTimeManagerDelegate <NSObject>

- (void)tickWithAccumulatedTime:(NSUInteger)time;

@end
@interface SHTimeManager : NSObject
@property (nonatomic, weak) id<SHTimeManagerDelegate> delegate;

- (void)start;
- (void)pause;
- (void)stop;
- (NSUInteger)getTotalTime;
- (NSUInteger)currentAccumulatedTime;
@end
