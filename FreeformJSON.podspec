Pod::Spec.new do |s|
  s.name         = "FreeformJSON"
  s.version      = "0.1.2"
  s.summary      = "Type-safe freeform JSON data structure with Codable support for Swift"
  s.description  = <<-DESC
  FreeformJSON is a tiny data structure that allows you to create and/or access freeform JSON data in a type safe manner, while still enjoying the benefits of the Codable protocol
  DESC
  s.homepage     = "https://github.com/fabiorodella/FreeformJSON"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Fabio Rodella" => "fabiorodella@gmail.com" }
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/fabiorodella/FreeformJSON.git", :tag => s.version }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.swift_version = '4.0'
end
