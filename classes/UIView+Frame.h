//
//  UIView+Frame.h
//
//  Created by oyahaok on 2018/10/17.
//  Copyright © 2018年 oyahaok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

/**
 *  返回UIView及其子类的位置和尺寸。分别为左、右边界在X轴方向上的距离，上、下边界在Y轴上的距离，View的宽和高。
 */

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic, assign) CGFloat centerX;
@property(nonatomic, assign) CGFloat centerY;
@property(nonatomic, assign) CGSize size;

- (void)setLayerShadow:(nullable UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;
- (UIView *)findFirstResponder;
@end
