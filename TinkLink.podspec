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

  s.subspec 'GRPCMessages' do |ms|
    ms.source_files = "Sources/TinkGRPC/*.pb.swift"
    ms.requires_arc = false
    ms.dependency 'SwiftProtobuf'
  end

  s.subspec 'GRPCServices' do |ss|
    ss.source_files = "Sources/TinkGRPC/*.grpc.swift"
    ss.requires_arc = true
    ss.dependency 'SwiftGRPC'
  end
end
