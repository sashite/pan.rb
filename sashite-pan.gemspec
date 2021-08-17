# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = "sashite-pan"
  spec.version      = File.read("VERSION.semver")
  spec.author       = "Cyril Kato"
  spec.email        = "contact@cyril.email"
  spec.description  = "A Ruby interface for data serialization in PAN (Portable Action Notation) format."
  spec.summary      = "Data serialization in PAN format."
  spec.homepage     = "https://developer.sashite.com/specs/portable-action-notation"
  spec.license      = "MIT"
  spec.required_ruby_version = ::Gem::Requirement.new(">= 2.7.0")
  spec.files = Dir["LICENSE.md", "README.md", "lib/**/*"]

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/sashite/pan.rb/issues",
    "documentation_uri" => "https://rubydoc.info/gems/sashite-pan/index",
    "source_code_uri"   => "https://github.com/sashite/pan.rb"
  }

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop-md"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-thread_safety"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"
end
