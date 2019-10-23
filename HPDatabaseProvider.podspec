#
# Be sure to run `pod lib lint HPDatabaseProvider.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HPDatabaseProvider'
  s.version          = '1.1.1'
  s.summary          = 'A short description of HPDatabaseProvider.'



  s.description      = <<-DESC
- 1.1.0
Added migration callback;
                       DESC

  s.homepage         = 'https://github.com/DimasSup/HPDatabaseProvider'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'GPL-3.0', :file => 'LICENSE' }
  s.author           = { 'DimasSup' => 'dima.teleban@gmail.com' }
  s.source           = { :git => 'https://github.com/DimasSup/HPDatabaseProvider.git', :tag => "v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HPDatabaseProvider/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HPDatabaseProvider' => ['HPDatabaseProvider/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'FMDB'
end
