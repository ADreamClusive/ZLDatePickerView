# 自定义日期时间选择器

提供年月日时分秒、年月日周时分秒、年月日等常用样式

也可以方便地扩展更多的样式

# Cocoapods集成方式

```bash
pod 'ZLDatePickerView'
```
# 手动集成

将classes目录下得内容拖入工程即可

# 使用方法

```oc
ZLDatePickerView *customdateView = [[ZLDatePickerView alloc] init];

customdateView.minuteInterval = 10;
customdateView.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*1024];
customdateView.maximumDate = [NSDate dateWithTimeIntervalSinceNow:3600*24*1024];
NSDate *defDate = self.timeLabel.text.length ? [self stringDate:self.timeLabel.text andFormat:@"yyyy-MM-dd HH:mm:ss"] : [NSDate date];
customdateView.isNeedForeverBtn = YES;
// 通过ZLDatePickerMode指定显示的样式
[customdateView setTitle:@"请选择时间" datePickerMode:ZLDatePickerModeNianyuerishifen defDate:defDate doneBlock:^(NSDate * _Nonnull date) {
    self.timeLabel.text = [self dateStr:date andFormat:@"yyyy-MM-dd HH:mm:ss"];
} dismissBlock:^{
    
}];
[customdateView showInView:[[[UIApplication sharedApplication] delegate] window]];
```

>  stringDate:andFormat: 和  dateStr:andFormat: 分别提供NSString和NSDate之间的转换
