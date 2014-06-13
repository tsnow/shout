# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shout/version'

Gem::Specification.new do |spec|
  spec.name          = "shout"
  spec.version       = Shout::VERSION
  spec.authors       = ["Tim Snowhite"]
  spec.email         = ["tim@snowhitesolutions.com"]
  spec.description   = %q{A class-level observer pattern for ActiveRecord.}
  spec.summary       = %q{Publish and subscribe to events on your models.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
