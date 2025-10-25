# frozen_string_literal: true

require_relative "pan/action"

module Sashite
  # PAN (Portable Action Notation) implementation for Ruby
  #
  # Provides functionality for working with atomic actions in abstract strategy board games
  # using a human-readable string format with intuitive operator-based syntax.
  #
  # This implementation is strictly compliant with PAN Specification v1.0.0
  # @see https://sashite.dev/specs/pan/1.0.0/ PAN Specification v1.0.0
  module Pan
    # Check if a string represents a valid PAN action
    #
    # @param pan_string [String] the string to validate
    # @return [Boolean] true if the string is a valid PAN action
    #
    # @example
    #   Sashite::Pan.valid?("e2-e4")     # => true
    #   Sashite::Pan.valid?("d1+f3")     # => true
    #   Sashite::Pan.valid?("...")       # => true
    #   Sashite::Pan.valid?("P*e5")      # => true
    #   Sashite::Pan.valid?("invalid")   # => false
    def self.valid?(pan_string)
      Action.valid?(pan_string)
    end

    # Parse a PAN string into an Action object
    #
    # @param pan_string [String] PAN notation string
    # @return [Pan::Action] immutable action instance
    # @raise [ArgumentError] if the PAN string is invalid
    #
    # @example
    #   Sashite::Pan.parse("e2-e4")      # => #<Pan::Action type=:move ...>
    #   Sashite::Pan.parse("d1+f3")      # => #<Pan::Action type=:capture ...>
    #   Sashite::Pan.parse("...")        # => #<Pan::Action type=:pass>
    #   Sashite::Pan.parse("P*e5")       # => #<Pan::Action type=:drop ...>
    def self.parse(pan_string)
      Action.parse(pan_string)
    end
  end
end
