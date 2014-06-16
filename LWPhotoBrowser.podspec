Pod::Spec.new do |s|

  s.name	 = "LWPhotoBrowser"
  s.version      = "0.2"
  s.summary      = "An iOS photo Browser."
  s.homepage     = "https://github.com/imhui/LWPhotoBrowser"
  s.license      = "Apache License"
  s.author       = { "imhui" => "seasonlyh@gmail.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/imhui/LWPhotoBrowser.git", :tag => "0.2" }
  s.source_files  = "LWPhotoBrowser/LWPhotoBrowser/*.{h,m}"
  s.requires_arc = true

end
