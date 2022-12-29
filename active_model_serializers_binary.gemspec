$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_model_serializers_binary/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_model_serializers_binary"
  s.version     = ActiveModelSerializersBinary::VERSION
  s.authors     = ["ByS Sistemas de Control"]
  s.email       = ["info@bys-control.com.ar"]
  s.homepage    = "https://github.com/bys-control/active_model_serializers_binary"
  s.summary     = "Serialize models to/from binary format for raw data exchange"
  s.description = "active_model_serializers_binary is a declarative way to serialize/deserialize ActiveModel classes for raw data exchange."
  s.license     = "MIT"

  s.files = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rails"
  s.add_development_dependency "colorize"

  s.add_dependency "activemodel", ">= 5.0"
end
