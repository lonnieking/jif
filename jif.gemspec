lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'jif/version'

Gem::Specification.new do |spec|
  spec.name          = 'jif'
  spec.version       = Jif::VERSION

  spec.authors       = 'Lonnie King'
  spec.email         = 'lonnie.king@me.com'
  spec.homepage      = 'http://github.com/lonnieking/jif'

  spec.license       = 'MIT'
  spec.summary       = 'A CLI for retrieving animated gifs.'
  spec.description   = 'Jif provides a command line utility for '\
                       'retrieving animated gifs from Giphy.com!'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.bindir        = 'bin'
  spec.executables   = %w[jif]
  spec.require_paths = %w[lib]

  spec.add_dependency 'thor'
  spec.add_dependency 'faraday'

  spec.add_development_dependency "bundler",   "~> 1.11"
  spec.add_development_dependency "rake",      "~> 10.0"
  spec.add_development_dependency "rspec",     "~> 3.0"
  spec.add_development_dependency "webmock",   "~> 2.1"
  spec.add_development_dependency "simplecov", "~> 0.11.2"
end
