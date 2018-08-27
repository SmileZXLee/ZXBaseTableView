Pod::Spec.new do |s|
s.name         = 'ZXBaseTableView'
s.version      = '1.0.1'
s.summary      = '对tableView的封装，简化代码风格'
s.homepage     = 'https://github.com/SmileZXLee/ZXBaseTableView'
s.license      = 'MIT'
s.authors      = {'ZXLee' => '393727164@qq.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/SmileZXLee/ZXBaseTableView.git', :tag => s.version}
s.source_files = 'ZXBaseTableView/ZXBaseTableViewDemo/ZXBaseTableView/'
s.requires_arc = true
end
