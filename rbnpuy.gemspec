require_relative 'lib/rbnpuy/version'

Gem::Specification.new do |spec|
  spec.name          = "rbnpuy"
  spec.version       = Rbnpuy::VERSION
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "Monitor and control user input devices"
  spec.description   = "A Ruby library for controlling and monitoring mouse and keyboard input devices. Inspired by Python's pynput."
  spec.homepage      = "https://github.com/yourusername/rbnpuy"
  spec.license       = "LGPL-3.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{lib,ext}/**/*") + %w[README.md LICENSE CHANGELOG.md]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Platform-specific dependencies
  if RUBY_PLATFORM =~ /darwin/
    # macOS dependencies - using ffi to interface with Cocoa/Quartz
    spec.add_dependency "ffi", "~> 1.15"
  elsif RUBY_PLATFORM =~ /linux/
    # Linux dependencies
    spec.add_dependency "ffi", "~> 1.15"
  elsif RUBY_PLATFORM =~ /mingw|mswin/
    # Windows dependencies
    spec.add_dependency "ffi", "~> 1.15"
  end

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
