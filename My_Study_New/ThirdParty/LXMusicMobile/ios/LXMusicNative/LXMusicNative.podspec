Pod::Spec.new do |spec|
  spec.name = 'LXMusicNative'
  spec.version = '1.0.0'
  spec.summary = 'LX Music 的 iOS 原生能力桥接'
  spec.homepage = 'https://github.com/lyswhut/lx-music-mobile'
  spec.license = { :type => 'Apache-2.0', :file => '../../LICENSE' }
  spec.author = { 'LX Music iOS Port' => 'local' }
  spec.source = { :path => '.' }
  spec.platform = :ios, '13.4'
  spec.source_files = '*.{h,m,mm}'
  spec.resource_bundles = { 'LXMusicNative' => ['Resources/user-api-preload.js'] }
  spec.dependency 'React-Core'
  spec.frameworks = 'UIKit', 'UserNotifications', 'JavaScriptCore', 'Security', 'AVFoundation'
end
