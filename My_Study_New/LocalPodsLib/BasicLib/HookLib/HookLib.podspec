#
# Be sure to run `pod lib lint HookLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HookLib'
  s.version          = '0.1.2'
  s.summary          = 'A short description of HookLib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://gitf-stock.paic.com.cn/mobile/LocalPodsLib/BasicLib/HookLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dongligang239' => 'dongligang239@pingan.com.cn' }
  s.source           = { :git => './LocalPodsLib/BasicLib/HookLib/Classes', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
 	s.requires_arc = true
  
  s.subspec "Aspects" do |sp|
    sp.source_files = "Classes/Aspects/*.{h,m}"
  end
  
#  s.subspec "BlockHook" do |sp|
#    sp.source_files = "Classes/BlockHook/*.{h,m}"
#  end
#
#  s.subspec "libffi" do |sp|
#    sp.source_files = "Classes/libffi/**/*.{h,m}"
#    #sp.resources = "Classes/openssl/*.{png,xib,bundle}"
#    sp.vendored_libraries = "Classes/libffi/*.a"
#  end

  s.subspec "WBHookBlock" do |sp|
    sp.source_files = "Classes/WBHookBlock/*.{h,m}"
  end
  
  s.subspec "DynamicRun" do |sp|
    sp.source_files = "Classes/DynamicRun/*.{h,m}"
  end
  
#  s.xcconfig = {
#    'LIBRARY_SEARCH_PATHS' => '${PODS_ROOT}/../LocalPodsLib/BasicLib/HookLib/Classes/libffi',
#    'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/../LocalPodsLib/BasicLib/HookLib/Classes/libffi',
#    'ENABLE_BITCODE' => false,
#    'OTHER_LDFLAGS' => ['-ObjC'],
#    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
#  }
 	
  # s.resource_bundles = {
  #   'HookLib' => ['HookLib/HookLib/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
