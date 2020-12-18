#
# Be sure to run `pod lib lint ObjMapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ObjMapper'
  s.version          = '1.0.2'
  s.summary          = 'A simple json object mapper for swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  ObjtMapper是基于Swift的Codable协议进行扩展的框架，可让您轻松地将模型对象（类和结构）与JSON相互转换，无副作用的转换。
                       DESC

  s.homepage         = 'https://github.com/ninefivefly/ObjMapper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JIANG PENG CHENG' => 'ninefivefly@foxmail.com' }
  s.source           = { :git => 'https://github.com/ninefivefly/ObjMapper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'ObjMapper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ObjMapper' => ['ObjMapper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
