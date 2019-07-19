#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_background_audio'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin can play audio in background.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
                       s.homepage         = 'https://blog.haihui.site'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'haihuiling2014@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

