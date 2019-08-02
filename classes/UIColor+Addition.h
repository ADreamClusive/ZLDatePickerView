//
//  UIColor+WSK.h
//
//  Created by oyahaok on 2018/10/17.
//  Copyright © 2018年 oyahaok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Addition)

// 随机颜色
+ (UIColor *)randomColor;


+ (UIColor *)red:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha;


+ (NSArray *)convertColorToRBG:(UIColor *)color;

+ (UIColor *)convertHexColorToUIColor:(NSInteger)hexColor;


+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

+ (NSArray *)getRGBDictionaryByColor:(UIColor *)originColor;

+ (NSArray *)transColorBeginColor:(UIColor *)beginColor andEndColor:(UIColor *)endColor;

+ (UIColor *)getColorWithColor:(UIColor *)beginColor andCoe:(double)coe andMarginArray:(NSArray<NSNumber *> *)marginArray;
@end
