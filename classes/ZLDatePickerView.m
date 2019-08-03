//
//  CustomDatePickerView.m
//
//  Created by zl jiao on 2019/7/2.
//

#import "ZLDatePickerView.h"
#import "NSBundle+Addition.h"
#import "UIView+Frame.h"

static NSString *const kCalendarUnit = @"calendarunit";
static NSString *const kNumberOfRowsInCurrentComponent = @"kNumberOfRowsInCurrentComponent";
static NSString *const kWidthRatioOfComponent = @"kWidthRatioOfComponent";
static NSString *const kBlockGetTitleOfRowInComponent = @"kBlockGetTitleOfRowInComponent";
static NSString *const kBlockSelectRowInComponent = @"kBlockSelectRowInComponent";

@interface ZLDatePickerView() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) UIPickerView *pickerView; // 选择器
@property (strong, nonatomic) UIView *toolView; // 工具条
@property (strong, nonatomic) UILabel *titleLbl; // 标题
@property (strong, nonatomic) UIButton *foreverBtn; // 长期按钮

// 数显最小时间 最大时间
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (strong, nonatomic) NSMutableArray *dataArray; // 数据源
@property (strong, nonatomic) NSMutableDictionary *pickerConfig; // 标明各个comps的顺序


@property (assign, nonatomic) NSInteger multiples; // 数据源倍数

@property (copy, nonatomic) NSString *year; // 选中年
@property (copy, nonatomic) NSString *month; //选中月
@property (copy, nonatomic) NSString *day; //选中日
@property (copy, nonatomic) NSString *hour; //选中时
@property (copy, nonatomic) NSString *minute; //选中分

@property (strong, nonatomic) NSString *maxWidthStr;

@property (strong, nonatomic) UIView *bgView;


@end

@interface NSString (Addition)

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

@end

#define mPickerHeight (300.0)
#define COLOR_RGBA(r, g, b, a) [UIColor colorWithRed:(r) / 255.f green:(g) / 255.f blue:(b) / 255.f alpha:(a)]
#define COLOR_RGB(r, g, b) COLOR_RGBA(r, g, b, 1.0)

@implementation ZLDatePickerView

#pragma mark - init
/// 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[self screenBounds]];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self configData];
        [self configView];
    }
    return self;
}

- (void)layoutSubviews
{
    self.bgView.frame = CGRectMake(0, [self screenHeight] - mPickerHeight, self.width, mPickerHeight);
    
    [self configToolView];
    
    CGFloat pickerY = self.toolView.bottom;
    if (self.isNeedForeverBtn) {
        pickerY += 30;
    }
    self.foreverBtn.hidden = !self.isNeedForeverBtn;
    
    CGFloat x = 5.0;
    self.pickerView.frame = CGRectMake(x, pickerY, self.bgView.width - x * 2, mPickerHeight - self.toolView.bottom);
    
    self.foreverBtn.frame = CGRectMake(0, self.toolView.bottom + 12.5, 100, 30);
    self.foreverBtn.centerX = self.toolView.centerX;
}

#pragma mark - 配置初始化数据
- (void)configData
{    
    self.minuteInterval = 1;
    self.date = [NSDate date];
    self.multiples = 200;
    self.beginDate = [NSDate dateWithTimeIntervalSince1970:0];
    self.endDate = [self stringDate:@"10000-01-01" andFormat:@"yyyy-MM-dd"];
    self.minimumDate = self.beginDate;
    self.maximumDate = self.endDate;
    self.font = [UIFont fontWithName:@"PingFangSC-Regular" size:22];
    self.toolBgColor = COLOR_RGB(238, 238, 238);
    self.isNeedForeverBtn = NO;
}

#pragma mark - 配置界面
- (void)configView
{
    [self addSubview:self.bgView];
    [self.toolView addSubview:self.titleLbl];
    [self.bgView addSubview:self.toolView];
    [self.bgView addSubview:self.foreverBtn];
    [self.bgView addSubview:self.pickerView];
}
/// 配置工具条
- (void)configToolView
{
    self.toolView.frame = CGRectMake(0, 0, self.bgView.width, 44);
    self.toolView.backgroundColor = self.toolBgColor;
    
    UIButton *saveBtn = [[UIButton alloc] init];
    saveBtn.frame = CGRectMake(self.bgView.width - 50, 2, 40, 40);
    [saveBtn setImage:[NSBundle imageWithName:@"icon_select"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:saveBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(10, 2, 40, 40);
    [cancelBtn setImage:[NSBundle imageWithName:@"icon_revocation"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:cancelBtn];
    
    self.titleLbl.frame = CGRectMake(60, 2, self.bgView.width - 120, 40);
}

- (void)setTitle:(NSString *)title datePickerMode:(ZLDatePickerMode)mode defDate:(NSDate *)defDate doneBlock:(void (^)(NSDate *date))done dismissBlock:(void(^)(void))dismiss
{
    self.title = title;
    self.mode = mode;
    self.date = defDate ? : [NSDate date];
    self.doneBlock = done;
    self.dismissBlock = dismiss;
}

- (void)showInView:(UIView *)view
{
    [self prepareToShow];
    [view addSubview:self];
    self.bgView.top = self.height;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.backgroundColor = COLOR_RGBA(170, 170, 170, 0.46);
                         self.bgView.top = self.height - self.bgView.height;
                     }];

}
- (void)dismiss
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.bgView.top = self.height;
                         self.backgroundColor = [UIColor clearColor];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

- (void)prepareToShow
{
    [self.dataArray removeAllObjects];
    [self.pickerConfig removeAllObjects];
    
    if ([self.date timeIntervalSinceDate:self.minimumDate] < 0 || [self.endDate timeIntervalSinceDate:self.date] < 0) {
        self.date = [NSDate date];
    }
    
    if ([self.maximumDate timeIntervalSinceDate:self.minimumDate] < 0 ) {
        self.minimumDate = self.beginDate;
        self.maximumDate = self.endDate;
    }
    
    if ([self.minimumDate timeIntervalSinceDate:self.beginDate] < 0 ) {
        self.minimumDate = self.beginDate;
    }
    
    if ([self.endDate timeIntervalSinceDate:self.endDate] < 0) {
        self.maximumDate = self.endDate;
    }
    
    self.year = [NSString stringWithFormat:@"%ld年", [self convertDateToYear:self.date]];
    self.month = [NSString stringWithFormat:@"%02ld月", [self convertDateToMonth:self.date]];
    self.day = [NSString stringWithFormat:@"%02ld日", [self convertDateToDay:self.date]];
    self.hour = [NSString stringWithFormat:@"%02ld", [self convertDateToHour:self.date]];
    self.minute = [NSString stringWithFormat:@"%02ld", [self convertDateToMinute:self.date]];
    
    switch (self.mode) {
        case ZLDatePickerModeNianyuerishifen:
        {
            self.maxWidthStr = @"0000年00月00日0000";
            [self.dataArray addObject:[self yearConfig]];
            [self.dataArray addObject:[self monthConfig]];
            [self.dataArray addObject:[self dayConfig:(NSCalendarUnitDay)]];
            [self.dataArray addObject:[self hourConfig]];
            [self.dataArray addObject:[self minuteConfit]];
        }
            break;
        case ZLDatePickerModeNianyuerizhoushifen:
        {
            self.maxWidthStr = @"0000年00月00日 周五0000";
            [self.dataArray addObject:[self yearConfig]];
            [self.dataArray addObject:[self monthConfig]];
            [self.dataArray addObject:[self dayConfig:(NSCalendarUnitDay | NSCalendarUnitWeekday)]];
            [self.dataArray addObject:[self hourConfig]];
            [self.dataArray addObject:[self minuteConfit]];
        }
            break;
        case ZLDatePickerModeYuerinianshifen:
            self.maxWidthStr = @"0000年00月00日0000";
            [self.dataArray addObject:[self monthConfig]];
            [self.dataArray addObject:[self dayConfig:(NSCalendarUnitDay)]];
            [self.dataArray addObject:[self yearConfig]];
            [self.dataArray addObject:[self hourConfig]];
            [self.dataArray addObject:[self minuteConfit]];
            break;
        default:
            self.maxWidthStr = @"0000年00月00日";
            [self.dataArray addObject:[self yearConfig]];
            [self.dataArray addObject:[self monthConfig]];
            [self.dataArray addObject:[self dayConfig:(NSCalendarUnitDay)]];
            break;
    }
    
    [self setupConfig];
    
    [self.pickerView reloadAllComponents];
    
    [self selectDefaultDateTime];
}

- (void)selectDefaultDateTime
{
    if (self.pickerConfig[@(NSCalendarUnitYear)]) {
        [self.pickerView selectRow:[self rowForYear] inComponent:[self.pickerConfig[@(NSCalendarUnitYear)] integerValue]  animated:YES];
    }
    if (self.pickerConfig[@(NSCalendarUnitMonth)]) {
        [self.pickerView selectRow:[self rowForMonth] inComponent:[self.pickerConfig[@(NSCalendarUnitMonth)] integerValue] animated:YES];
    }
    if (self.pickerConfig[@(NSCalendarUnitDay)]) {
        [self.pickerView selectRow:([self rowForDay]) inComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue] animated:YES];
    }
    if (self.pickerConfig[@(NSCalendarUnitHour)]) {
        [self.pickerView selectRow:[self rowForHour] inComponent:[self.pickerConfig[@(NSCalendarUnitHour)] integerValue] animated:YES];
    }
    if (self.pickerConfig[@(NSCalendarUnitMinute)]) {
        [self.pickerView selectRow:[self rowForMinute] inComponent:[self.pickerConfig[@(NSCalendarUnitMinute)] integerValue] animated:YES];
    }
}

- (CGFloat)ratioForComWidth:(NSString *)eStr
{
    CGFloat cwidth = [eStr sizeForFont:self.font size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].width;
    CGFloat width = [self.maxWidthStr sizeForFont:self.font size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].width;
    return cwidth/width;
}

- (NSDictionary *)yearConfig
{
    NSInteger minimum = [self convertDateToYear:self.beginDate];
    NSInteger maximum = [self convertDateToYear:self.endDate];
    NSInteger numNian = maximum - minimum + 1;
    
    NSDictionary *dict = @{kCalendarUnit:@(NSCalendarUnitYear),
                           kWidthRatioOfComponent:@([self ratioForComWidth:@"00年"]),
                           kNumberOfRowsInCurrentComponent:@(numNian),
                           kBlockGetTitleOfRowInComponent:(NSString *)^(NSInteger component, NSInteger row){
                               
                               return [NSString stringWithFormat:@"%ld年", [self convertDateToYear:self.beginDate]+row];
                           },
                           kBlockSelectRowInComponent:^(NSInteger component, NSInteger row){
                               self.year =  [(UILabel *)[self.pickerView viewForRow:row forComponent:component] text];
                               
                               [self checkRange];
                               
                               if (self.pickerConfig[@(NSCalendarUnitDay)]) {
                                   [self.pickerView reloadComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue]];
                                   [self scrollToCorrectDay];
                               }
                           }};
    return dict;
}
- (NSDictionary *)monthConfig
{
    NSDictionary *dict = @{kCalendarUnit:@(NSCalendarUnitMonth),
                           kWidthRatioOfComponent:@([self ratioForComWidth:@"00月"]),
                           kNumberOfRowsInCurrentComponent:@(12*self.multiples),
                           kBlockGetTitleOfRowInComponent:(NSString *)^(NSInteger component, NSInteger row){
                               
                               return [NSString stringWithFormat:@"%02ld月", row%12+1];
                           },
                           kBlockSelectRowInComponent:^(NSInteger component, NSInteger row){
                               
                               self.month = [(UILabel *)[self.pickerView viewForRow:row forComponent:component] text];

                               [self checkRange];
                               
                               if (self.pickerConfig[@(NSCalendarUnitDay)]) {
                                   [self.pickerView reloadComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue]];
                                   [self scrollToCorrectDay];
                               }
                           }};
    return dict;
}
- (NSDictionary *)dayConfig:(NSCalendarUnit)unit
{
    NSDictionary *dict = @{kCalendarUnit:@(unit),
                           kWidthRatioOfComponent:@([self ratioForComWidth:(unit == NSCalendarUnitDay) ? @"00日" : @"00日 周五"]),
                           kNumberOfRowsInCurrentComponent:@([self daysOfYear:self.year.integerValue month:self.month.integerValue]*self.multiples),
                           kBlockGetTitleOfRowInComponent:(NSString *)^(NSInteger component, NSInteger row){
        
                                if (unit == (NSCalendarUnitDay | NSCalendarUnitWeekday) ) {
                                    NSInteger day = row%([self daysOfYear:self.year.integerValue month:self.month.integerValue])+1;
                                    NSString *weekday = [self weekdayOfYear:self.year.integerValue month:self.month.integerValue day:day];
                                    
                                    return [NSString stringWithFormat:@"%02ld日 %@", day, weekday ];
                                } else {
                                    return [NSString stringWithFormat:@"%02ld日", row%([self daysOfYear:self.year.integerValue month:self.month.integerValue])+1];
                                }
                           },
                           kBlockSelectRowInComponent:^(NSInteger component, NSInteger row){
        
                               self.day = [(UILabel *)[self.pickerView viewForRow:row forComponent:component] text];
                               
                               [self checkRange];
                           }};
    return dict;
}

- (NSDictionary *)hourConfig
{
    NSDictionary *dict = @{kCalendarUnit:@(NSCalendarUnitHour),
                           kWidthRatioOfComponent:@([self ratioForComWidth:@"00"]),
                           kNumberOfRowsInCurrentComponent:@(24*self.multiples),
                           kBlockGetTitleOfRowInComponent:(NSString *)^(NSInteger component, NSInteger row){
                               
                               return [NSString stringWithFormat:@"%02ld", row%(24)];
                           },
                           kBlockSelectRowInComponent:^(NSInteger component, NSInteger row){
                               
                               self.hour = [(UILabel *)[self.pickerView viewForRow:row forComponent:component] text];
                               
                               [self checkRange];
                           }};
    return dict;
}
- (NSDictionary *)minuteConfit
{
    NSDictionary *dict = @{kCalendarUnit:@(NSCalendarUnitMinute),
                           kWidthRatioOfComponent:@([self ratioForComWidth:@"00"]),
                           kNumberOfRowsInCurrentComponent:@([self countOfOneHour]*self.multiples),
                           kBlockGetTitleOfRowInComponent:(NSString *)^(NSInteger component, NSInteger row){
                        
                               return [NSString stringWithFormat:@"%02ld", row % [self countOfOneHour] * self.minuteInterval];
                           },
                           kBlockSelectRowInComponent:^(NSInteger component, NSInteger row){
        
                               self.minute = [(UILabel *)[self.pickerView viewForRow:row forComponent:component] text];
                               
                               [self checkRange];
                           }};
    return dict;
}

- (void)checkRange
{
    if (self.pickerConfig[@(NSCalendarUnitYear)]) {
        if (self.year.integerValue < [self convertDateToYear:self.minimumDate]) {
            self.year = [NSString stringWithFormat:@"%ld年", [self convertDateToYear:self.minimumDate]];
            
        } else if (self.year.integerValue > [self convertDateToYear:self.maximumDate]) {
            self.year = [NSString stringWithFormat:@"%ld年", [self convertDateToYear:self.maximumDate]];
        }
        [self.pickerView selectRow:[self rowForYear] inComponent:[self.pickerConfig[@(NSCalendarUnitYear)] integerValue] animated:YES];
    }
    
    if (self.pickerConfig[@(NSCalendarUnitMonth)]) {
        if (self.month.integerValue < [self convertDateToMonth:self.minimumDate] &&
            self.year.integerValue == [self convertDateToYear:self.minimumDate]) {
            
            self.month = [NSString stringWithFormat:@"%02ld月", [self convertDateToMonth:self.minimumDate]];
            [self.pickerView selectRow:[self rowForMonth] inComponent:[self.pickerConfig[@(NSCalendarUnitMonth)] integerValue] animated:YES];
        } else if (self.month.integerValue > [self convertDateToMonth:self.maximumDate] &&
                   self.year.integerValue == [self convertDateToYear:self.maximumDate]) {
            
            self.month = [NSString stringWithFormat:@"%02ld月", [self convertDateToMonth:self.maximumDate]];
            [self.pickerView selectRow:[self rowForMonth] inComponent:[self.pickerConfig[@(NSCalendarUnitMonth)] integerValue] animated:YES];
        }
    }
    
    if (self.pickerConfig[@(NSCalendarUnitDay)]) {
        if (self.day.integerValue < [self convertDateToDay:self.minimumDate] &&
            self.month.integerValue == [self convertDateToMonth:self.minimumDate] &&
            self.year.integerValue == [self convertDateToYear:self.minimumDate]) {
            
            self.day = [NSString stringWithFormat:@"%02ld日", [self convertDateToDay:self.minimumDate]];
            [self.pickerView selectRow:[self rowForDay] inComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue] animated:YES];
        } else if (self.day.integerValue > [self convertDateToDay:self.maximumDate] &&
                   self.month.integerValue == [self convertDateToMonth:self.maximumDate] &&
                   self.year.integerValue == [self convertDateToYear:self.maximumDate]) {
            
            self.day = [NSString stringWithFormat:@"%02ld日", [self convertDateToDay:self.maximumDate]];
            [self.pickerView selectRow:[self rowForDay] inComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue] animated:YES];
        }
    }
    
    if (self.pickerConfig[@(NSCalendarUnitHour)]) {
        if (self.hour.integerValue < [self convertDateToHour:self.minimumDate] &&
            self.day.integerValue == [self convertDateToDay:self.minimumDate] &&
            self.month.integerValue == [self convertDateToMonth:self.minimumDate] &&
            self.year.integerValue == [self convertDateToYear:self.minimumDate]) {
            
            self.hour = [NSString stringWithFormat:@"%02ld", [self convertDateToHour:self.minimumDate]];
            [self.pickerView selectRow:[self rowForHour] inComponent:[self.pickerConfig[@(NSCalendarUnitHour)] integerValue] animated:YES];
        } else if (self.hour.integerValue > [self convertDateToHour:self.maximumDate] &&
                   self.day.integerValue == [self convertDateToDay:self.maximumDate] &&
                   self.month.integerValue == [self convertDateToMonth:self.maximumDate] &&
                   self.year.integerValue == [self convertDateToYear:self.maximumDate]) {
            
            self.hour = [NSString stringWithFormat:@"%02ld", [self convertDateToHour:self.maximumDate]];
            [self.pickerView selectRow:[self rowForHour] inComponent:[self.pickerConfig[@(NSCalendarUnitHour)] integerValue] animated:YES];
        }
    }

    if (self.pickerConfig[@(NSCalendarUnitMinute)]) {
        if (self.minute.integerValue < [self convertDateToMinute:self.minimumDate] &&
            self.hour.integerValue == [self convertDateToHour:self.minimumDate] &&
            self.day.integerValue == [self convertDateToDay:self.minimumDate] &&
            self.month.integerValue == [self convertDateToMonth:self.minimumDate] &&
            self.year.integerValue == [self convertDateToYear:self.minimumDate]) {
            
            self.minute = [NSString stringWithFormat:@"%02ld", [self convertDateToMinute:self.minimumDate]];
            [self.pickerView selectRow:[self rowForMinute] inComponent:[self.pickerConfig[@(NSCalendarUnitMinute)] integerValue] animated:YES];
        } else if (self.minute.integerValue > [self convertDateToMinute:self.maximumDate] &&
                   self.hour.integerValue == [self convertDateToHour:self.maximumDate] &&
                   self.day.integerValue == [self convertDateToDay:self.maximumDate] &&
                   self.month.integerValue == [self convertDateToMonth:self.maximumDate] &&
                   self.year.integerValue == [self convertDateToYear:self.maximumDate]) {
            
            self.minute = [NSString stringWithFormat:@"%02ld", [self convertDateToMinute:self.maximumDate]];
            [self.pickerView selectRow:[self rowForMinute] inComponent:[self.pickerConfig[@(NSCalendarUnitMinute)] integerValue] animated:YES];
        }
    }
}

- (void)setupConfig
{
    for (int i = 0; i < self.dataArray.count; i++) {
        NSNumber *key = (([[self.dataArray[i] valueForKey:kCalendarUnit] integerValue] & NSCalendarUnitDay) == NSCalendarUnitDay) ? @(NSCalendarUnitDay) : [self.dataArray[i] valueForKey:kCalendarUnit];
        [self.pickerConfig addEntriesFromDictionary:@{key:@(i)}];
    }
}

- (NSInteger)rowForYear
{
    return (self.year.integerValue - [self convertDateToYear:self.beginDate]);
}

- (NSInteger)rowForMonth
{
    return (self.multiples * 12 * 0.5 + self.month.integerValue - 1);
}

- (NSInteger)rowForDay
{
    return self.multiples * [self daysOfYear:self.year.integerValue month:self.month.integerValue] * 0.5 + self.day.integerValue - 1;
}

- (NSInteger)rowForHour
{
    return (self.multiples * 24 * 0.5 + self.hour.integerValue);
}

- (NSInteger)rowForMinute
{
    return (self.multiples * (60 / self.minuteInterval) * 0.5 + (self.minute.integerValue / self.minuteInterval));
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.dataArray.count;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self.dataArray[component] valueForKey:kNumberOfRowsInCurrentComponent] integerValue];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self.dataArray[component][kWidthRatioOfComponent] floatValue] * self.pickerView.bounds.size.width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLbl = (UILabel *)view;
    if (!titleLbl) {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 44)];
        titleLbl.font = self.font;
        titleLbl.textAlignment = NSTextAlignmentCenter;
    } else {
        titleLbl = (UILabel *)view;
    }

    NSString *(^blockGetTitle)(NSInteger component, NSInteger row) = [self.dataArray[component] valueForKey:kBlockGetTitleOfRowInComponent];
    if (blockGetTitle) {
        titleLbl.text = blockGetTitle(component, row);
    } else {
        titleLbl.text = [NSString stringWithFormat:@"Error %ld:%ld", component, row];
    }

    return titleLbl;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    void(^didSelectBlock)(NSInteger component, NSInteger row) = self.dataArray[component][kBlockSelectRowInComponent];
    if (didSelectBlock) {
        didSelectBlock(component, row);
    }
    NSLog(@"%@-%@-%@ %@:%@", self.year, self.month, self.day, self.hour, self.minute);
}

#pragma mark - 点击方法
/// 保存按钮点击方法
- (void)saveBtnClick
{
    NSLog(@"点击了保存");
    if (self.doneBlock) {
        self.doneBlock([self selectedDate]);
    }
    [self dismiss];
}
/// 取消按钮点击方法
- (void)cancelBtnClick
{
    NSLog(@"点击了取消");
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    [self dismiss];
}

- (void)foreverBtnClick
{
    self.date = self.endDate;
    
    self.year = [NSString stringWithFormat:@"%ld年", [self convertDateToYear:self.date]];
    self.month = [NSString stringWithFormat:@"%02ld月", [self convertDateToMonth:self.date]];
    self.day = [NSString stringWithFormat:@"%02ld日", [self convertDateToDay:self.date]];
    self.hour = [NSString stringWithFormat:@"%02ld", [self convertDateToHour:self.date]];
    self.minute = [NSString stringWithFormat:@"%02ld", [self convertDateToMinute:self.date]];
    
    [self saveBtnClick];
}

#pragma mark - private
// 一个小时显示多少个刻度
- (NSInteger)countOfOneHour
{
    return (59 / self.minuteInterval + 1);
}
- (void)scrollToCorrectDay
{
    NSInteger monthDays = [self daysOfYear:self.year.integerValue month:self.month.integerValue];
    if (self.day.integerValue > monthDays) {
        self.day = [NSString stringWithFormat:@"%02ld日", monthDays];
        [self.pickerView selectRow:[self rowForDay] inComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue] animated:YES];
    } else {
        [self.pickerView selectRow:[self rowForDay] inComponent:[self.pickerConfig[@(NSCalendarUnitDay)] integerValue] animated:NO];
    }
}

// comps -> date
- (NSDate *)selectedDate
{
    NSDate *date = [self dateFromYear:self.year.integerValue month:self.month.integerValue day:self.day.integerValue hour:self.hour.integerValue minute:self.minute.integerValue];
    return date;
}

// 周
- (NSString *)weekdayOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDate *date = [self dateFromYear:self.year.integerValue month:self.month.integerValue day:day hour:1 minute:1];
    NSInteger weekDay = [self convertDateToWeekDay:date];
    NSString *weekdayStr;
    switch (weekDay) {
        case 0:
            weekdayStr = @"周日";
            break;
        case 1:
            weekdayStr = @"周一";
            break;
        case 2:
            weekdayStr = @"周二";
            break;
        case 3:
            weekdayStr = @"周三";
            break;
        case 4:
            weekdayStr = @"周四";
            break;
        case 5:
            weekdayStr = @"周五";
            break;
        case 6:
            weekdayStr = @"周六";
            break;
        default:
            break;
    }
    return weekdayStr;
}

- (NSDate *)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = year;
    comps.month = month;
    comps.day = day;
    comps.hour = hour;
    comps.minute = minute;
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return date;
}

// 根据date获取分
- (NSInteger)convertDateToMinute:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMinute) fromDate:date];
    return [components minute];
}

// 根据date获取时
- (NSInteger)convertDateToHour:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour) fromDate:date];
    return [components hour];
}

// 根据date获取日
- (NSInteger)convertDateToDay:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay) fromDate:date];
    return [components day];
}

// 根据date获取月
- (NSInteger)convertDateToMonth:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth) fromDate:date];
    return [components month];
}

// 根据date获取年
- (NSInteger)convertDateToYear:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear) fromDate:date];
    return [components year];
}

// 根据date获取当月周几 (美国时间周日-周六为 1-7,改为0-6方便计算)
- (NSInteger)convertDateToWeekDay:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday fromDate:date];
    NSInteger weekDay = [components weekday] - 1;
    weekDay = MAX(weekDay, 0);
    return weekDay;
}

// 根据date获取当月周几
- (NSInteger)convertDateToFirstWeekDay:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;  //美国时间周日为星期的第一天，所以周日-周六为1-7，改为0-6方便计算
}

// 根据date获取当月总天数
- (NSInteger)convertDateToTotalDays:(NSDate *)date
{
    NSRange daysInOfMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInOfMonth.length;
}

- (NSInteger)daysOfYear:(NSInteger)year month:(NSInteger)month
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = year;
    comps.month = month;
    comps.day = 1;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    return [self convertDateToTotalDays:date];
}

- (NSDate *)stringDate:(NSString *)dateStr andFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format ? format : @"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}

#pragma mark - setters
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLbl.text = title;
}

- (void)setDate:(NSDate *)date
{
    if (date == nil ) {
        return;
    }
    _date = date;
}
- (void)setMinimumDate:(NSDate *)minimumDate
{
    if (minimumDate == nil ) {
        return;
    }
    _minimumDate = minimumDate;
}
- (void)setMaximumDate:(NSDate *)maximumDate
{
    if (maximumDate == nil ) {
        return;
    }
    _maximumDate = maximumDate;
}

- (void)setMinuteInterval:(NSInteger)minuteInterval
{
    if (minuteInterval < 1 ) {
        return;
    }
    _minuteInterval = minuteInterval;
}

#pragma mark - getters
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
- (NSMutableDictionary *)pickerConfig
{
    if (!_pickerConfig) {
        _pickerConfig = [NSMutableDictionary new];
    }
    return _pickerConfig;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColor.whiteColor;
    }
    return _bgView;
}

- (UIView *)toolView
{
    if (!_toolView) {
        _toolView = [[UIView alloc] init];
    }
    return _toolView;
}

- (UIButton *)foreverBtn
{
    if (!_foreverBtn) {
        _foreverBtn = [[UIButton alloc] init];
        [_foreverBtn addTarget:self action:@selector(foreverBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_foreverBtn setTitle:@"长期" forState:UIControlStateNormal];
        [_foreverBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    }
    return _foreverBtn;
}

- (UILabel *)titleLbl
{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = COLOR_RGB(34, 34, 34);
    }
    return _titleLbl;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.showsSelectionIndicator = YES;
    }
    return _pickerView;
}

#pragma mark - frame

- (CGRect)screenBounds
{
    return UIScreen.mainScreen.bounds;
}

- (CGFloat)screenWidth
{
    return UIScreen.mainScreen.bounds.size.width;
}

- (CGFloat)screenHeight
{
    return UIScreen.mainScreen.bounds.size.height;
}

@end


@implementation NSString (Addition)

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode
{
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
        if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
            NSMutableDictionary *attr = [NSMutableDictionary new];
            attr[NSFontAttributeName] = font;
            if (lineBreakMode != NSLineBreakByWordWrapping) {
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                paragraphStyle.lineBreakMode = lineBreakMode;
                attr[NSParagraphStyleAttributeName] = paragraphStyle;
            }
            CGRect rect = [self boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attr context:nil];
            result = rect.size;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
        }
    return result;
}

@end


