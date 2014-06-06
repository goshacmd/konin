# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'konin/version'

Gem::Specification.new do |spec|
  spec.name          = 'konin'
  spec.version       = Konin::VERSION
  spec.authors       = ['Gosha Arinich']
  spec.email         = ['me@goshakkk.name']
  spec.summary       = %q{RPC with RabbitMQ}
  spec.description   = %q{A RabbitMQ-powever library to enable RPC in SOA.}
  spec.homepage      = 'http://github.com/goshakkk/konin'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
