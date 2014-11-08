# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neo4j_ancestry/version'

Gem::Specification.new do |spec|
  spec.name          = "neo4j_ancestry"
  spec.version       = Neo4jAncestry::VERSION
  spec.authors       = ["Sebastian Fiedlschuster"]
  spec.email         = ["sebastian@fiedlschuster.de"]
  spec.description   = "This ruby on rails gem makes it easy to store polymorphic structure information --- parents, children, ancestors, descendants, ... --- in a neo4j graph database parallel to using ActiveRecord."
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/fiedl/neo4j_ancestry"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'activerecord'
  
  spec.add_dependency "rails", ">= 3.2"
  spec.add_dependency "neography", '>= 1.6.0'
  spec.add_dependency "neoid"
end
