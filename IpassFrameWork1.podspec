#
#  Be sure to run `pod spec lint IpassFrameWork1.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "IpassFrameWork1"
  spec.version      = "1.0.10"
  spec.summary      = "Addition and substraction of numbers"
  spec.description  = "The mai feature of this skd Adding and Substrating of two numbers"

  spec.homepage     = "https://github.com/yazanalqasem/IpassFramework"

 # spec.license      = "MIT (example)"
   spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "yazanalqasem" => "yalqasem@ipass-mena.com" }
  # Or just: spec.author    = "yazanalqasem"
  # spec.authors            = { "yazanalqasem" => "yalqasem@ipass-mena.com" }
  

   spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  spec.ios.deployment_target = "14.0"


  spec.source       = { :git => "https://github.com/yazanalqasem/IpassFramework.git", :tag => "#{spec.version}" }

  spec.source_files  =  "IpassFrameWork1/**/*.{h,m,swift}","IpassFrameWork1/Extensions/**/*.{swift}","IpassFrameWork1/Extensions/OnlineProcessing/**/*.swift"
  #spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

    spec.swift_version = '5.0'
  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

 # spec.requires_arc = true

 # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "DocumentReaderFullAuthRFID"
   spec.dependency "DocumentReader"
  # spec.dependency "Alamofire"
   # spec.dependency "Toast-Swift"
    # spec.dependency "PKHUD"
     # spec.dependency "ReachabilitySwift"
          # spec.resources = "IpassFrameWork1/Resources/**/*.{license,bundle}"
        spec.resources = 'IpassFrameWork1/**/*.license'

end
