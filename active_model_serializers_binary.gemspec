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

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake", "~> 10.3"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "rails", "~> 4.1"

  s.add_development_dependency 'devise', '~> 3.2'
  s.add_development_dependency 'jquery-ui-rails', '~> 4.2'
  s.add_development_dependency 'sass-rails', '~> 4.0'
  s.add_development_dependency 'uglifier', '~> 1.3'
  s.add_development_dependency 'coffee-rails', '~> 4.0'
  s.add_development_dependency 'turbolinks', "~> 2.2"
  s.add_development_dependency 'jbuilder', '~> 1.2'
  s.add_development_dependency 'jquery-validation-rails', '~> 1.12'
  s.add_development_dependency 'therubyracer', '~> 0.12'
  s.add_development_dependency "colorize", '~> 0.7'

  s.add_dependency "activemodel", "~> 4.1"
end
