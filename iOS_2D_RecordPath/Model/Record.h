//
//  Record.h
//  iOS_2D_RecordPath
//
//  Created by PC on 15/8/3.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Record : NSObject

@property(nonatomic,copy)NSString *kmNumText;
@property(nonatomic,copy)NSString *ratNumText;
@property(nonatomic,assign)NSInteger accumulatedTime;
@property(nonatomic,copy)NSString *killNumText;

- (NSString *)title;

- (NSString *)subTitle;

- (void)addLocation:(CLLocation *)location;

- (NSInteger)numOfLocations;

- (CLLocation *)startLocation;

- (CLLocation *)endLocation;

- (CLLocationCoordinate2D *)coordinates;

- (CLLocationDistance)totalDistance;

- (NSTimeInterval)totalDuration;



@end
