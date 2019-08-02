//
//  NSBundle+Addition.m
//  ZLDatePickerDemo
//
//  Created by zl jiao on 2019/8/3.
//  Copyright © 2019 zl jiao. All rights reserved.
//

#import "NSBundle+Addition.h"
#import "ZLDatePickerView.h"

@implementation NSBundle (Addition)

+ (instancetype)ZLDatePickerBundle
{
    static NSBundle *mBundle = nil;
    if (mBundle == nil) {
        mBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZLDatePickerView class]] pathForResource:@"ZLDatePicker" ofType:@"bundle"]];
    }
    return mBundle;
}

+ (UIImage *)imageWithName:(NSString *)imageName
{
    UIImage *image = [[UIImage imageWithContentsOfFile:[[self ZLDatePickerBundle] pathForResource:[NSString stringWithFormat:@"imageName@%zdx", (NSInteger)UIScreen.mainScreen.scale] ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

@end
