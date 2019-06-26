#Setting Info
use_frameworks!
install! 'cocoapods', :warn_for_multiple_pod_sources => false
platform :ios, '8.0'
inhibit_all_warnings!

workspace 'FMDBDemo.xcworkspace'

pre_install do |installer|
    Pod::PodTarget.send(:define_method, :static_framework?) { return true }
end

#Third Party

source 'https://github.com/CocoaPods/Specs'

target "SDWebImageDemo" do
    project 'SDWebImageDemo.project'
    pod 'SDWebImage', :source => 'https://github.com/SDWebImage/SDWebImage.git'
end

#https://github.com/CocoaPods/Specs.git
#https://github.com/SDWebImage/SDWebImage.git