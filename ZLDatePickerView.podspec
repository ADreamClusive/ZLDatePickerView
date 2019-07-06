Pod::Spec.new do |s|
s.name = 'ZLDatePickerView'
s.version = '1.0.0'
s.license = "MIT" //开源协议
s.summary = '自定义日期选择组件，支持2019年07月06日、2019年07月06日 周六 12:05、2019年07月06日 12:05等多种自定义格式，也可随机组合自己想要的时间显示格式' //简单的描述
s.homepage = 'https://github.com/jingyiqiujing/ZLDatePickerView' //主页
s.author = { 'ADreamClusive' => '2506513065@qq.com' } //作者
s.source = { :git => 'https://github.com/jingyiqiujing/ZLDatePickerView.git', :tag => "1.0.0" } //git路径、指定tag号
s.platform = :ios
s.source_files  = "classes", "classes/**/*.{h,m}" //库的源代码文件
s.framework = 'UIKit' //依赖的framework
s.requires_arc = true
end
