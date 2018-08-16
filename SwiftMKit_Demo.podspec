Pod::Spec.new do |s|
  s.name         = "SwiftMKit_Demo"
  s.module_name  = "SwiftMKit"
  s.version      = "1.1.5.4"
  s.summary      = "This is SwiftMKit."
  s.description  = <<-DESC
                   This is description 
                   DESC
  s.homepage     = "https://github.com/Lves/SwiftMKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "lveslxl@gmail.com" => "lveslxl@gmail.com" }

  s.ios.deployment_target = "9.0"
  s.swift_version = "4.0"
  s.source       = { :git => "https://github.com/Lves/SwiftMKit.git", :tag => s.version.to_s }
  s.source_files  = "SwiftMKit/**/*.{h,m,swift,xcdatamodeld}"
  s.resources = ["SwiftMKit/Data/Log/*.{xcdatamodeld, xcdatamodel}","SwiftMKit/UI/**/**/*.{xib, png}","SwiftMKit/UI/**/*.{xib, png}","SwiftMKit/UI/**/**/**/*.png"]


  s.dependency "CocoaLumberjack/Swift", "~> 3.4.0"
  s.dependency "ReactiveCocoa", "~> 7.2.0"
  s.dependency "Alamofire", "~> 4.7.0"
  s.dependency "Kingfisher", "~> 4.8.0"
  s.dependency "MagicalRecord", "~> 2.3.0"
  s.dependency "MJExtension", "~> 3.0.0"
  s.dependency "MJRefresh", "~> 3.1.0"
  s.dependency "CryptoSwift", "~> 0.10.0"
  s.dependency "IQKeyboardManager", "~> 6.0.0"
  s.dependency "WebViewJavascriptBridge", "~> 6.0.0"
  s.dependency "PINCache", "~> 2.3.0"
  s.dependency "SnapKit", "~> 4.0.0"
  s.dependency "pop", "~> 1.0.0"
  s.dependency "Aspects", "~> 1.4.0"
  s.dependency "MBProgressHUD", "~> 1.1.0"

end
