# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-pan"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "Portable Action Notation (PAN) - operator-based notation for abstract strategy game actions"

  spec.description = <<~DESC
    Parse and generate Portable Action Notation (PAN) strings for representing atomic actions in abstract strategy board games including chess, shogi, xiangqi, and others. PAN provides an intuitive operator-based syntax with six core operators: "-" (move to empty square), "+" (capture), "~" (special moves with side effects), "*" (drop to board), "." (drop with capture), and "=" (in-place transformation), plus "..." (pass turn).
    Supports coordinates via CELL specification and piece identifiers via EPIN specification. Handles transformations ("e7-e8=Q"), enhanced/diminished states ("+R", "-P"), and style derivation markers ("K'"). Provides comprehensive validation, immutable action objects, and functional API design.
    Examples: "e2-e4" (move), "d1+f3" (capture), "e1~g1" (castling), "P*e5" (drop), "e7-e8=Q" (promotion), "..." (pass), "+d4" (static capture), "e4=+P" (modify).
  DESC

  spec.homepage               = "https://github.com/sashite/pan.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-cell", "~> 2.0"
  spec.add_dependency "sashite-epin", "~> 1.1"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pan.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pan.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pan.rb",
    "source_code_uri"       => "https://github.com/sashite/pan.rb",
    "specification_uri"     => "https://sashite.dev/specs/pan/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
