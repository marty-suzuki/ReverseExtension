#
# Be sure to run `pod lib lint ReverseExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  last_commit = `git rev-list --tags --max-count=1`.strip
  last_tag = `git describe --tags #{last_commit}`.strip

  s.name             = 'ReverseExtension'
  s.version          = last_tag
  s.summary          = 'UITableView extension that enabled to insert cell from bottom of tableView.'
  s.homepage         = 'https://github.com/marty-suzuki/ReverseExtension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'marty-suzuki' => 's1180183@gmail.com' }
  s.source           = { :git => 'https://github.com/marty-suzuki/ReverseExtension.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/marty_suzuki'
  s.ios.deployment_target = '10.0'
  s.source_files = 'ReverseExtension/*.{swift,h,m}'
  s.swift_version = '5.0'
end
