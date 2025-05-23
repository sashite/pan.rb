# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-pan"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "Portable Action Notation (PAN) parser and validator for Ruby"
  spec.description            = "A Ruby implementation of the Portable Action Notation (PAN) specification."
  spec.homepage               = "https://github.com/sashite/pan.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pan.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pan.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pan.rb",
    "source_code_uri"       => "https://github.com/sashite/pan.rb",
    "specification_uri"     => "https://sashite.dev/documents/pan/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
