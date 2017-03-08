# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hinge/version'

Gem::Specification.new do |spec|
  spec.name          = "hinge"
  spec.version       = Hinge::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ["Thomas Stratmann"]
  spec.email         = ["thomas.stratmann@9elements.com"]

  spec.summary       = %q{Trivial dependency resolver using introspection}
  spec.description   = %q{Trivial dependency resolver using introspection}
  spec.homepage      = %q{https://github.com/schnittchen/hinge}

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
