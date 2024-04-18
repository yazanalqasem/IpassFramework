# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'IpassFrameWork1' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'DocumentReaderFullAuthRFID'
  pod 'DocumentReader'

 #pod 'amplify-swift', :path => 'https://github.com/aws-amplify/amplify-swift'

  # Pods for IpassFrameWork1

end

#post_install do |installer|
#    installer.generated_projects.each do |project|
#        project.targets.each do |target|
#            target.build_configurations.each do |config|
#                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
#                if target.name == 'IpassFrameWork1'
#                  target.swift_packages.append(package: 'https://github.com/aws-amplify/amplify-ui-swift-liveness.git', version: .up_to_next_major(from: "1.2.9"))
#                end
#            end
#        end
#    end
#end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'IpassFrameWork1'
      target.swift_packages.append('https://github.com/aws-amplify/amplify-ui-swift-liveness.git')
    end
  end
end
