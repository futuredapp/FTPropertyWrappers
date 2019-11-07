Pod::Spec.new do |s|
  s.name         = "FTPropertyWrappers"
  s.version      = "0.1.0"
  s.summary      = "Commonly used property wrappers"
  s.description  = <<-DESC
    Property wrappers for common usecases such as User defaults, Serialization,
    Keychain storage and Observing
  DESC
  s.homepage     = "https://github.com/thefuntasty/FTPropertyWrappers"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Matěj Kašpar Jirásek" => "matej.jirasek@thefuntasty.com" }
  s.social_media_url   = "https://twitter.com/thefuntasty"
  s.default_subspec = 'Core'
  s.swift_version = "5.1"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/thefuntasty/FTPropertyWrappers.git", :tag => s.version.to_s }

  s.source_files  = "Sources/FTPropertyWrappers/*"
  s.framework  = "Foundation"
end
