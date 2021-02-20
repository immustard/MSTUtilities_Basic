#
# Be sure to run `pod lib lint MSTUtilities_Basic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MSTUtilities_Basic'
  s.version          = '1.0.0'
  s.summary          = 'Mustard\'s Common Basic Util'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/immustard/MSTUtilities_Basic'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'immustard' => 'mustard.gxg@gmail.com' }
  s.source           = { :git => 'https://github.com/immustard/MSTUtilities_Basic.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = ['4.0', '5.0']
  s.pod_target_xcconfig = {
    'VALID_ARCHS' => 'x86_64 armv7 arm64'
  }

  s.source_files = 'MSTUtilities_Basic/Classes/**/*'
  
  s.resource_bundles = {
    'MSTUtilities_Basic' => ['MSTUtilities_Basic/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

    # 约束
  s.dependency 'SnapKit', '~> 5.0.0'
  # 下拉刷新
  s.dependency 'MJRefresh'
  # 模型转换
  s.dependency 'HandyJSON', '~> 5.0.2'
  # toastView
  s.dependency 'PKHUD'
  # alertView
  s.dependency 'SCLAlertView'
  # 网络图片
  s.dependency 'SDWebImage'
  # 独立 navigationController
  s.dependency 'RTRootNavigationController'
  # 键盘监听
  s.dependency 'IQKeyboardManagerSwift'
  # 读取图片
  s.dependency 'TZImagePickerController'
  # 展示图片
  s.dependency 'SKPhotoBrowser'
  # 全屏手势
  s.dependency 'FDFullscreenPopGesture'
  # cell滑动手势
  s.dependency 'SwipeCellKit'
  # 网络请求
  s.dependency 'Alamofire', '~> 5.2'
  # Then
  s.dependency 'Then'
  # UI DEBUG
  s.dependency 'LookinServer', :configurations => ['Debug']

end
