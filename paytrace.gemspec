# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paytrace/version'

Gem::Specification.new do |spec|
  spec.name          = "paytrace"
  spec.version       = PayTrace::VERSION
  spec.authors       = ["Trevor Redfern"]
  spec.email         = ["trevor@paytrace.com"]
  spec.description   = %q{Integration with PayTrace Payment Gateway}
  spec.summary       = %q{Integration providing access to the transaction processing API for PayTrace}
  spec.homepage      = "http://github.com/PayTrace/paytrace_ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.9"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "mocha", "~> 1.0"
  spec.add_development_dependency "guard", '~> 0'
  spec.add_development_dependency "guard-minitest", '~> 0'
  spec.add_development_dependency "ruby_gntp"
end
