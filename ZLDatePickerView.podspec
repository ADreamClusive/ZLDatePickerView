Pod::Spec.new do |s|
s.name = 'ZLDatePickerView'
s.version = '1.0.3'
s.license = "MIT"
s.summary = '自定义日期选择组件，支持2019年07月06日、2019年07月06日 周六 12:05、2019年07月06日 12:05等多种自定义格式，也可随机组合自己想要的时间显示格式'
s.homepage = 'https://github.com/jingyiqiujing/ZLDatePickerView'
s.author = { 'ADreamClusive' => '2506513065@qq.com' }
s.source = { :git => 'https://github.com/jingyiqiujing/ZLDatePickerView.git', :tag => s.version }
s.platform = :ios
s.source_files  = "classes", "classes/**/*.{h,m}"
s.resources = "classes/images/ZLDatePicker.bundle"
s.framework = 'UIKit'
s.requires_arc = true
end
