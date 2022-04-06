#
# Be sure to run `pod lib lint Lasso.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'LassoTestUtilities'
  s.version          = '1.3.0'
  s.summary          = 'Unit test support for the Lasso framework.'
  s.description      = 'Lasso is an iOS application architecture for building discrete, composable and testable compenents both big and small - from single one-off screens, through complex flows, to high-level application structures.'

  s.homepage         = 'https://github.com/ww-tech/lasso'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.authors          = { 'Steven Grosmark' => 'steven.grosmark@ww.com',
                         'Trevor Beasty' => 'trevor.beasty@ww.com' }

  s.source           = { :git => 'https://github.com/ww-tech/lasso.git', :tag => s.version.to_s }
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.swift_versions   = '4.2', '5', '5.1', '5.2', '5.3', '5.4', '5.5'

  s.ios.deployment_target = '10.0'
  s.framework = 'XCTest'

  s.dependency 'Lasso'

  s.source_files = 'Sources/LassoTestUtilities/**/*'  
end
