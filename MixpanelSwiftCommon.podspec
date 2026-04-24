Pod::Spec.new do |s|
  s.name             = 'MixpanelSwiftCommon'
  s.version          = '1.0.1'
  s.summary          = 'Shared common functionality for Mixpanel iOS SDKs.'
  s.description      = <<-DESC
    Shared common functionality for Mixpanel iOS SDKs.
  DESC
  s.homepage         = 'https://github.com/mixpanel/mixpanel-swift-common'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Mixpanel' => 'support@mixpanel.com' }
  s.source           = { :git => 'https://github.com/mixpanel/mixpanel-swift-common.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.watchos.deployment_target = '4.0'

  s.swift_version = '5.3'
  s.source_files = 'Sources/MixpanelSwiftCommon/**/*.swift'
end
