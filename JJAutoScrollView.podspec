Pod::Spec.new do |s|
s.name = 'JJAutoScrollView'
s.version = '0.0.5'
s.platform = :ios, '7.0'
s.summary = '一个很好用banner滚动控件'
s.homepage = 'https://github.com/andyfangjunjie/JJAutoScrollView'
s.license = 'MIT'
s.author = { 'andyfangjunjie' => 'andyfangjunjie@163.com' }
s.source = {:git => 'https://github.com/andyfangjunjie/JJAutoScrollView.git', :tag => s.version}
s.source_files = 'JJAutoScrollView/**/*.{h,m}'
s.requires_arc = true
s.framework  = 'UIKit'
end
