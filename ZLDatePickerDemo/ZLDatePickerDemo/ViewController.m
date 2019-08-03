//
//  ViewController.m
//  ZLDatePickerDemo
//
//  Created by zl jiao on 2019/8/3.
//  Copyright © 2019 zl jiao. All rights reserved.
//

#import "ViewController.h"
#import "ZLDatePickerView.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)action:(id)sender
{
    ZLDatePickerView *customdateView = [[ZLDatePickerView alloc] init];
    
    customdateView.minuteInterval = 10;
    customdateView.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*1024];
    customdateView.maximumDate = [NSDate dateWithTimeIntervalSinceNow:3600*24*1024];
    NSDate *defDate = self.timeLabel.text.length ? [self stringDate:self.timeLabel.text andFormat:@"yyyy-MM-dd HH:mm:ss"] : [NSDate date];
    customdateView.isNeedForeverBtn = YES;
    [customdateView setTitle:@"请选择时间" datePickerMode:ZLDatePickerModeNianyuerishifen defDate:defDate doneBlock:^(NSDate * _Nonnull date) {
        self.timeLabel.text = [self dateStr:date andFormat:@"yyyy-MM-dd HH:mm:ss"];
    } dismissBlock:^{
        
    }];
    [customdateView showInView:[[[UIApplication sharedApplication] delegate] window]];
}

- (NSDate *)stringDate:(NSString *)dateStr andFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format ? format : @"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}

- (NSString *)dateStr:(NSDate *)senddate andFormat:(NSString *)format
{
    NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:format ? format : @"yyyy-MM-dd"];
    NSString *  locationString = [dateformatter stringFromDate:senddate];
    return locationString;
}


@end
