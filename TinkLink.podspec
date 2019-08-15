Pod::Spec.new do |s|
  s.name     = 'TinkLink'
  s.version  = '0.0.1'
  s.license  = 'Tink AB'
  s.authors  = { 'Tink AB' => 'support@tink.se' }
  s.homepage = 'https://tink.com'
  s.summary = 'Tink Link.'
  s.source = { :git => 'https://github.com/tink-ab/tink-link-ios' }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'

  s.source_files = 'Sources/TinkLink/**/*.swift'
  s.dependency 'SwiftProtobuf'
  s.dependency 'SwiftGRPC'
end
