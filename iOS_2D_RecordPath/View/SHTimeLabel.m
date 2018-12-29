//
//  SHTimeLabel.m
//  iOS_2D_RecordPath
//
//  Created by Shawn on 2018/12/19.
//  Copyright © 2018年 FENGSHENG. All rights reserved.
//
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
#import "SHTimeLabel.h"
@interface SHTimeLabel()
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger second;
@property(nonatomic,strong)UILabel *timeLabel;
@end
@implementation SHTimeLabel

- (instancetype)init{
    if (self = [super init]) {
        [self initCount];
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, (WIDTH/7)*3-10, 30)];
        self.timeLabel.text = @"00 : 00 : 00";
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.textColor = [UIColor blackColor];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)initCount
{
    self.hour = 0;
    self.minute = 0;
    self.second = 0;
}

- (void)resetTimeLabelWithTotalSeconds:(NSUInteger)totalSeconds
{
    self.hour = totalSeconds / 3600;
    self.minute = (totalSeconds - self.hour * 3600) / 60;
    self.second = totalSeconds - self.hour * 3600 - self.minute * 60;
    
    [self setupTimeLabelText];
}

- (void)setLabelFontSize:(CGFloat)fontSize
{
    self.timeLabel.font = [UIFont systemFontOfSize:fontSize];
}

- (void)setupTimeLabelText
{
    NSString *hourText = @"";
    if (self.hour < 10)
    {
        hourText = [hourText stringByAppendingString:@"0"];
    }
    hourText = [hourText stringByAppendingString:[NSString stringWithFormat:@"%@", @(self.hour)]];
    
    NSString *minuteText = @"";
    if (self.minute < 10)
    {
        minuteText = [minuteText stringByAppendingString:@"0"];
    }
    minuteText = [minuteText stringByAppendingString:[NSString stringWithFormat:@"%@", @(self.minute)]];
    
    NSString *secondText = @"";
    if (self.second < 10)
    {
        secondText = [secondText stringByAppendingString:@"0"];
    }
    secondText = [secondText stringByAppendingString:[NSString stringWithFormat:@"%@", @(self.second)]];
    
    NSString *labelText = [NSString stringWithFormat:@"%@ : %@ : %@", hourText, minuteText, secondText];
    self.timeLabel.text = labelText;
}

- (void)setBoldWithFontSize:(CGFloat)fontSize
{
    // 设置粗体
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:fontSize];
}

- (void)setTextColor:(UIColor *)textColor{
    self.timeLabel.textColor = textColor;
}

@end
