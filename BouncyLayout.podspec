Pod::Spec.new do |s|
  s.name         = 'BouncyLayout'
  s.version      = '2.3.0'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.summary      = 'Make. It. Bounce.'
  s.description  = <<-DESC
    BouncyLayout is a collection view layout that makes your cells bounce.
  DESC
  s.homepage           = 'https://github.com/roberthein/BouncyLayout'
  s.license            = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { 'Robert-Hein Hooijmans' => 'rh.hooijmans@gmail.com' }
  s.social_media_url   = 'https://twitter.com/roberthein'
  s.source             = { :git => 'https://github.com/roberthein/BouncyLayout.git', :tag => s.version.to_s }
  s.source_files       = 'BouncyLayout/Classes/**/*.{swift}'
  s.swift_version      = '5.0'
end
