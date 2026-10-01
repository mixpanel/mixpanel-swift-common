Pod::Spec.new do |s|
  s.name             = 'MixpanelSwiftCommon'
  s.version          = '2.0.0'
  s.summary          = 'Shared common functionality for Mixpanel iOS SDKs.'
  s.description      = <<-DESC
    Shared common functionality for Mixpanel iOS SDKs.
  DESC
  s.homepage         = 'https://github.com/mixpanel/mixpanel-swift-common'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Mixpanel' => 'support@mixpanel.com' }
  s.source           = { :git => 'https://github.com/mixpanel/mixpanel-swift-common.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.tvos.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.watchos.deployment_target = '9.0'

  s.swift_version = '5.7'
  s.source_files = 'Sources/MixpanelSwiftCommon/**/*.swift'
  s.preserve_paths = 'THIRD_PARTY_LICENSES.md'
end
