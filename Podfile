# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

workspace 'ios_wallet_core.xcworkspace'

def pods
    inhibit_all_warnings!
    pod 'YYModel', '1.0.4'
    pod 'Protobuf','3.6.1'
end

target 'NebWalletCore' do
    project 'NebWalletCore.xcodeproj'
    pods
end

target 'wallet_core_test' do
    project 'wallet_core_test.xcodeproj'
    pods
end

