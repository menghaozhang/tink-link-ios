Pod::Spec.new do |s|
  s.name     = 'TinkGRPC'
  s.version  = '0.0.1'
  s.license  = 'Tink AB'
  s.authors  = { 'Tink AB' => 'support@tink.se' }
  s.homepage = 'https://tink.com'
  s.summary = 'Tink gRPC library.'
  s.source = { :git => 'https://github.com/tink-ab/tink-link-ios' }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'

  s.subspec 'Messages' do |ms|
    ms.source_files = "Sources/*.pb.swift"
    ms.requires_arc = false
    ms.dependency 'SwiftProtobuf'
  end

  s.subspec 'Services' do |ss|
    ss.source_files = "Sources/*.grpc.swift"
    ss.requires_arc = true
    ss.dependency 'SwiftGRPC'
  end
end
