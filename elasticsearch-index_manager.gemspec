# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elasticsearch/index_manager/version'

Gem::Specification.new do |spec|
  spec.name          = "elasticsearch-index_manager"
  spec.version       = Elasticsearch::IndexManager::VERSION
  spec.authors       = ["Ægir Örn Símonarson"]
  spec.email         = ["agirorn@gmail.com"]
  spec.summary       = %q{ Tools to assist with managing elasticsearch index. }
  spec.description   = %q{ Tools to assist with managing elasticsearch index. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "elasticsearch"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
