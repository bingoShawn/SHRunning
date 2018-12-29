//
//  SHTimeLabel.h
//  iOS_2D_RecordPath
//
//  Created by Shawn on 2018/12/19.
//  Copyright © 2018年 FENGSHENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHTimeLabel : UIView
- (void)resetTimeLabelWithTotalSeconds:(NSUInteger)totalSeconds;
- (void)setLabelFontSize:(CGFloat)fontSize;

- (void)setTextColor:(UIColor *)textColor;

- (void)setBoldWithFontSize:(CGFloat)fontSize;

@end
