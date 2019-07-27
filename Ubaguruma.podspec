#
#  Be sure to run `pod spec lint Ubaguruma.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name             = "Ubaguruma"
  s.version          = "0.0.1"
  s.summary          = "Ubaguruma can a photo select picker like LINE."
  s.homepage         = "https://github.com/nakajijapan/Ubaguruma"
  s.license          = 'MIT'
  s.author           = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.source           = { :git => "https://github.com/nakajijapan/Ubaguruma.git", :tag => s.version.to_s }
  #s.social_media_url = 'https://twitter.com/nakajijapan'

  s.platform     = :ios, '11.0'
  s.requires_arc = true
  s.swift_versions = ['5.0']

  s.source_files = 'Sources/Classes/**/*'
  s.resource_bundles = {
    'Ubaguruma' => ['Sources/Assets/*']
  }

end
