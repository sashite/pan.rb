# frozen_string_literal: true

require "sashite/cell"
require "sashite/epin"

module Sashite
  module Pan
    module Action
      # Modify action class
      #
      # Handles in-place transformation actions where a piece changes
      # its attributes without moving.
      #
      # Format: <square>=<piece>
      # Examples: "e4=+P", "c3=k'"
      class Modify
        # Action type
        TYPE = :modify

        # Operator constant
        OPERATOR = "="

        # Error messages
        ERROR_INVALID_MODIFY = "Invalid modify notation: %s"
        ERROR_INVALID_SQUARE = "Invalid square coordinate: %s"
        ERROR_INVALID_PIECE = "Invalid piece identifier: %s"

        # @return [String] destination CELL coordinate (square being modified)
        attr_reader :destination

        # @return [String] EPIN piece identifier (final state)
        attr_reader :piece

        # Check if a string represents a valid modify action
        #
        # @param pan_string [String] the string to validate
        # @return [Boolean] true if valid modify notation
        #
        # @example
        #   Modify.valid?("e4=+P")       # => true
        #   Modify.valid?("c3=k'")       # => true
        #   Modify.valid?("e4")          # => false
        def self.valid?(pan_string)
          return false unless pan_string.is_a?(::String)
          return false unless pan_string.include?(OPERATOR)

          parts = pan_string.split(OPERATOR, 2)
          return false if parts.size != 2

          square_part = parts[0]
          piece_part = parts[1]

          return false unless ::Sashite::Cell.valid?(square_part)
          return false unless ::Sashite::Epin.valid?(piece_part)

          true
        end

        # Parse a modify notation string into a Modify instance
        #
        # @param pan_string [String] modify notation string
        # @return [Modify] modify action instance
        # @raise [ArgumentError] if the string is not valid modify notation
        #
        # @example
        #   Modify.parse("e4=+P")      # => #<Modify destination="e4" piece="+P">
        #   Modify.parse("c3=k'")      # => #<Modify destination="c3" piece="k'">
        def self.parse(pan_string)
          raise ::ArgumentError, format(ERROR_INVALID_MODIFY, pan_string) unless valid?(pan_string)

          parts = pan_string.split(OPERATOR, 2)
          square = parts[0]
          piece = parts[1]

          new(square, piece)
        end

        # Create a new modify action instance
        #
        # @param square [String] CELL coordinate
        # @param piece [String] EPIN piece identifier (final state)
        # @raise [ArgumentError] if coordinate or piece is invalid
        #
        # @example
        #   Modify.new("e4", "+P")   # => #<Modify ...>
        #   Modify.new("c3", "k'")   # => #<Modify ...>
        def initialize(square, piece)
          raise ::ArgumentError, format(ERROR_INVALID_SQUARE, square) unless ::Sashite::Cell.valid?(square)
          raise ::ArgumentError, format(ERROR_INVALID_PIECE, piece) unless ::Sashite::Epin.valid?(piece)

          @destination = square
          @piece = piece

          freeze
        end

        # Get the action type
        #
        # @return [Symbol] :modify
        def type
          TYPE
        end

        # Get the source coordinate
        #
        # @return [nil] modify actions have no source
        def source
          nil
        end

        # Get the transformation piece
        #
        # @return [nil] modify actions have no separate transformation (piece represents final state)
        def transformation
          nil
        end

        # Convert the action to its PAN string representation
        #
        # @return [String] modify notation
        #
        # @example
        #   action.to_s  # => "e4=+P" or "c3=k'"
        def to_s
          "#{destination}#{OPERATOR}#{piece}"
        end

        # Check if this is a pass action
        #
        # @return [Boolean] false
        def pass?
          false
        end

        # Check if this is a move action
        #
        # @return [Boolean] false
        def move?
          false
        end

        # Check if this is a capture action
        #
        # @return [Boolean] false
        def capture?
          false
        end

        # Check if this is a special action
        #
        # @return [Boolean] false
        def special?
          false
        end

        # Check if this is a static capture action
        #
        # @return [Boolean] false
        def static_capture?
          false
        end

        # Check if this is a drop action
        #
        # @return [Boolean] false
        def drop?
          false
        end

        # Check if this is a drop capture action
        #
        # @return [Boolean] false
        def drop_capture?
          false
        end

        # Check if this is a modify action
        #
        # @return [Boolean] true
        def modify?
          true
        end

        # Check if this is a movement action
        #
        # @return [Boolean] false
        def movement?
          false
        end

        # Check if this is a drop action (drop or drop_capture)
        #
        # @return [Boolean] false
        def drop_action?
          false
        end

        # Custom equality comparison
        #
        # @param other [Object] object to compare with
        # @return [Boolean] true if actions are equal
        def ==(other)
          return false unless other.is_a?(self.class)

          destination == other.destination &&
            piece == other.piece
        end

        # Alias for == to ensure Set functionality works correctly
        alias eql? ==

        # Custom hash implementation for use in collections
        #
        # @return [Integer] hash value
        def hash
          [self.class, destination, piece].hash
        end
      end
    end
  end
end
