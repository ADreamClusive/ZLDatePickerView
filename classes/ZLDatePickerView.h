//
//  CustomDatePickerView.h
//
//  Created by zl jiao on 2019/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZLDatePickerMode) {
    ZLDatePickerModeDefault = 0,
    ZLDatePickerModeNianyuerishifen,
    ZLDatePickerModeNianyuerizhoushifen,
    ZLDatePickerModeYuerinianshifen
};

@interface ZLDatePickerView : UIView

/// 标题
@property (copy, nonatomic) NSString *title;
/** 工具栏背景色 */
@property (strong, nonatomic) UIColor *toolBgColor;
/** 选择器字体 */
@property (strong, nonatomic) UIFont *font;

@property (assign, nonatomic) ZLDatePickerMode mode;

/// 分钟间隔 默认5分钟
@property (assign, nonatomic) NSInteger minuteInterval;

/// 选中的时间, 默认为当前时间
@property (copy, nonatomic) NSDate *date;
/// 可选中的最大最小时间
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (copy, nonatomic)  void(^dismissBlock)(void);
@property (copy, nonatomic)  void(^doneBlock)(NSDate *date);

/// 是否显示长期按钮(针对长期有效期的情况)
@property (assign, nonatomic) BOOL isNeedForeverBtn;

- (void)setTitle:(NSString *)title datePickerMode:(ZLDatePickerMode)mode defDate:(NSDate *)defDate doneBlock:(void (^)(NSDate *date))done dismissBlock:(void(^)(void))dismiss;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
