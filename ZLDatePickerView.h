//
//  CustomDatePickerView.h
//
//  Created by zl jiao on 2019/7/2.
//

#import <UIKit/UIKit.h>
#import "UIColor+Addition.h"
#import "UIView+Frame.h"

NS_ASSUME_NONNULL_BEGIN

#define mKeyWindow  [[[UIApplication sharedApplication] delegate] window]
#define mScreenBounds         ([UIScreen mainScreen].bounds)
#define mScreenWidth          ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight         ([UIScreen mainScreen].bounds.size.height)

typedef NS_ENUM(NSInteger, CustomDatePickerMode) {
    CustomDatePickerModeDefault = 0,
    CustomDatePickerModeNianyuerishifen,
    CustomDatePickerModeNianyuerizhoushifen,
    CustomDatePickerModeYuerinianshifen
};

@interface ZLDatePickerView : UIView


/// 标题
@property (copy, nonatomic) NSString *title;
/** 工具栏背景色 */
@property (strong, nonatomic) UIColor *toolBgColor;
/** 选择器字体 */
@property (strong, nonatomic) UIFont *font;

@property (assign, nonatomic) CustomDatePickerMode mode;

/// 分钟间隔 默认5分钟
@property (assign, nonatomic) NSInteger minuteInterval;

/// 选中的时间, 默认为当前时间
@property (copy, nonatomic) NSDate *date;
/// 可选中的最大最小时间
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (copy, nonatomic)  void(^dismissBlock)(void);
@property (copy, nonatomic)  void(^doneBlock)(NSDate *date);

- (void)setTitle:(NSString *)title datePickerMode:(CustomDatePickerMode)mode defDate:(NSDate *)defDate doneBlock:(void (^)(NSDate *date))done dismissBlock:(void(^)(void))dismiss;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
