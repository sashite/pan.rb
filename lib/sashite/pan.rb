# frozen_string_literal: true

require_relative "pan/dumper"
require_relative "pan/parser"

module Sashite
  # The PAN (Portable Action Notation) module
  module Pan
    # Main interface for PAN operations
    module_function

    # Parse a PAN string into structured move data
    #
    # @param pan_string [String] The PAN string to parse
    # @return [Hash] Structured move data with type, source, and destination
    # @raise [Parser::Error] If the PAN string is invalid
    # @example
    #   Sashite::Pan.parse("e2-e4")
    #   # => {type: :move, source: "e2", destination: "e4"}
    #
    #   Sashite::Pan.parse("e4xd5")
    #   # => {type: :capture, source: "e4", destination: "d5"}
    #
    #   Sashite::Pan.parse("*e4")
    #   # => {type: :drop, destination: "e4"}
    def parse(pan_string)
      Parser.call(pan_string)
    end

    # Convert structured move data to PAN string
    #
    # @param move_data [Hash] Structured move data with type, source, and destination
    # @return [String] PAN string representation
    # @raise [Dumper::Error] If the move data is invalid
    # @example
    #   Sashite::Pan.dump({type: :move, source: "e2", destination: "e4"})
    #   # => "e2-e4"
    #
    #   Sashite::Pan.dump({type: :capture, source: "e4", destination: "d5"})
    #   # => "e4xd5"
    #
    #   Sashite::Pan.dump({type: :drop, destination: "e4"})
    #   # => "*e4"
    def dump(move_data)
      Dumper.call(move_data)
    end

    # Validate a PAN string without raising exceptions
    #
    # @param pan_string [String] The PAN string to validate
    # @return [Boolean] True if valid, false otherwise
    # @example
    #   Sashite::Pan.valid?("e2-e4")    # => true
    #   Sashite::Pan.valid?("*e4")      # => true
    #   Sashite::Pan.valid?("e4xd5")    # => true
    #   Sashite::Pan.valid?("")         # => false
    #   Sashite::Pan.valid?("e2-e2")    # => false
    #   Sashite::Pan.valid?("E2-e4")    # => false
    def valid?(pan_string)
      parse(pan_string)
      true
    rescue Parser::Error
      false
    end

    # Parse a PAN string without raising exceptions
    #
    # @param pan_string [String] The PAN string to parse
    # @return [Hash, nil] Structured move data or nil if invalid
    # @example
    #   Sashite::Pan.safe_parse("e2-e4")
    #   # => {type: :move, source: "e2", destination: "e4"}
    #
    #   Sashite::Pan.safe_parse("invalid")
    #   # => nil
    def safe_parse(pan_string)
      parse(pan_string)
    rescue Parser::Error
      nil
    end

    # Convert structured move data to PAN string without raising exceptions
    #
    # @param move_data [Hash] Structured move data with type, source, and destination
    # @return [String, nil] PAN string or nil if invalid
    # @example
    #   Sashite::Pan.safe_dump({type: :move, source: "e2", destination: "e4"})
    #   # => "e2-e4"
    #
    #   Sashite::Pan.safe_dump({invalid: :data})
    #   # => nil
    def safe_dump(move_data)
      dump(move_data)
    rescue Dumper::Error
      nil
    end

    # Check if a coordinate is valid according to PAN specification
    #
    # @param coordinate [String] The coordinate to validate
    # @return [Boolean] True if valid, false otherwise
    # @example
    #   Sashite::Pan.valid_coordinate?("e4")   # => true
    #   Sashite::Pan.valid_coordinate?("a1")   # => true
    #   Sashite::Pan.valid_coordinate?("E4")   # => false (uppercase)
    #   Sashite::Pan.valid_coordinate?("e10")  # => false (multi-digit rank)
    def valid_coordinate?(coordinate)
      return false unless coordinate.is_a?(::String)
      coordinate.match?(/\A[a-z][0-9]\z/)
    end

    # Get the regular expression pattern used for PAN validation
    #
    # @return [Regexp] The regex pattern for PAN strings
    # @example
    #   pattern = Sashite::Pan.pattern
    #   pattern.match?("e2-e4")  # => true
    def pattern
      Parser::PAN_PATTERN
    end

    # Convert a PAN string to a human-readable description
    #
    # @param pan_string [String] The PAN string to describe
    # @return [String] Human-readable description
    # @raise [Parser::Error] If the PAN string is invalid
    # @example
    #   Sashite::Pan.describe("e2-e4")
    #   # => "Move from e2 to e4"
    #
    #   Sashite::Pan.describe("e4xd5")
    #   # => "Capture from e4 to d5"
    #
    #   Sashite::Pan.describe("*e4")
    #   # => "Drop to e4"
    def describe(pan_string)
      move_data = parse(pan_string)

      case move_data[:type]
      when :move
        "Move from #{move_data[:source]} to #{move_data[:destination]}"
      when :capture
        "Capture from #{move_data[:source]} to #{move_data[:destination]}"
      when :drop
        "Drop to #{move_data[:destination]}"
      end
    end

    # Convert a PAN string to a human-readable description without raising exceptions
    #
    # @param pan_string [String] The PAN string to describe
    # @return [String, nil] Human-readable description or nil if invalid
    # @example
    #   Sashite::Pan.safe_describe("e2-e4")
    #   # => "Move from e2 to e4"
    #
    #   Sashite::Pan.safe_describe("invalid")
    #   # => nil
    def safe_describe(pan_string)
      describe(pan_string)
    rescue Parser::Error
      nil
    end
  end
end
