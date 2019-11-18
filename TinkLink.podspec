Pod::Spec.new do |s|
  s.name     = 'TinkLink'
  s.version  = '0.1.0'
  s.license  = 'Tink AB'
  s.authors  = { 'Tink AB' => 'support@tink.se' }
  s.homepage = 'https://tink.com'
  s.summary = 'Tink Link SDK.'
  s.source = { :git => 'https://github.com/tink-ab/tink-link-ios' }
  s.swift_version = '5.0'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'
  s.platform = :ios, '10.0'

  s.source_files = 'Sources/TinkLink/**/*.swift'
  s.dependency 'SwiftGRPC', '~> 0.9.1'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'
  end
end
