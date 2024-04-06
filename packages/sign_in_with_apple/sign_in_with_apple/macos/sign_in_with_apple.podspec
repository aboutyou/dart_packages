#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sign_in_with_apple.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sign_in_with_apple'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for handling Sign in with Apple'
  s.description      = <<-DESC
Flutter bridge to Sign in with Apple. Includes support for keychain entries as well as sign in with an Apple ID.
                       DESC
  s.homepage         = 'https://github.com/aboutyou/dart_packages/tree/master/packages/sign_in_with_apple'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Timm Preetz' => 'timm.preetz@aboutyou.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
