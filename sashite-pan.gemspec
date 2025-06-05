# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-pan"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "Compact notation for board game moves - parse chess, shogi, and strategy game actions"

  spec.description = <<~DESC
    Parse and generate Portable Action Notation (PAN) strings for representing moves
    in chess, shogi, and other strategy board games. PAN provides a compact,
    human-readable format for move logging, game transmission, and database storage.
    Supports simple moves (e2-e4), captures (exd5), and piece drops (*e4) with
    comprehensive validation and error handling.
  DESC

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
