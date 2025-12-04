require_relative 'lib/rbnput/version'

Gem::Specification.new do |spec|
  spec.name          = "rbnput"
  spec.version       = Rbnput::VERSION
  spec.authors       = ["Your Name"]
  spec.email         = ["you@example.com"]
  spec.summary       = "Ruby Input library (rbnput)"
  spec.description   = "A Ruby library for mouse and keyboard control and monitoring, inspired by pynput."
  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
  spec.add_dependency "ffi", "~> 1.15"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
