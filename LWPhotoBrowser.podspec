#
#  Be sure to run `pod spec lint LWPhotoBrowser.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.version      = "0.1"
  s.summary      = "An iOS photo Browser."
  s.homepage     = "https://github.com/imhui/LWPhotoBrowser"
  s.license      = "Apache License"
  s.author             = { "imhui" => "seasonlyh@gmail.com" }
  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/imhui/LWPhotoBrowser.git", :tag => "0.1" }
  s.source_files  = "LWPhotoBrowser/LWPhotoBrowser/*.{h,m}"
  s.requires_arc = true

end
