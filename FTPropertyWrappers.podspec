Pod::Spec.new do |s|
  s.name         = "FTPropertyWrappers"
  s.version      = "1.2.0"
  s.summary      = "Commonly used property wrappers"
  s.description  = <<-DESC
    Property wrappers for common use-cases such as Serialization and Keychain storage
  DESC
  s.homepage     = "https://github.com/futuredapp/FTPropertyWrappers"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Mikoláš Stuchlík" => "mikolas.stuchlik@futured.app" }
  s.social_media_url   = "https://twitter.com/FuturedApps"
  s.swift_version = "5.1"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/futuredapp/FTPropertyWrappers.git", :tag => s.version.to_s }

  s.source_files  = "Sources/**/*"
  s.framework  = "Foundation"
end
