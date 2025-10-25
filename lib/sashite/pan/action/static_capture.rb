# frozen_string_literal: true

require "sashite/cell"

module Sashite
  module Pan
    module Action
      # Static capture action class
      #
      # Handles capture actions without movement - removing a piece from the board
      # without the capturing piece moving.
      #
      # Format: +<square>
      # Examples: "+d4", "+e5"
      class StaticCapture
        # Action type
        TYPE = :static_capture

        # Operator constant
        OPERATOR = "+"

        # Error messages
        ERROR_INVALID_STATIC_CAPTURE = "Invalid static capture notation: %s"
        ERROR_INVALID_SQUARE = "Invalid square coordinate: %s"

        # @return [String] destination CELL coordinate (square where piece is captured)
        attr_reader :destination

        # Check if a string represents a valid static capture action
        #
        # @param pan_string [String] the string to validate
        # @return [Boolean] true if valid static capture notation
        #
        # @example
        #   StaticCapture.valid?("+d4")       # => true
        #   StaticCapture.valid?("+e5")       # => true
        #   StaticCapture.valid?("d4")        # => false
        def self.valid?(pan_string)
          return false unless pan_string.is_a?(::String)
          return false unless pan_string.start_with?(OPERATOR)
          return false if pan_string.length < 2

          square = pan_string[1..]
          ::Sashite::Cell.valid?(square)
        end

        # Parse a static capture notation string into a StaticCapture instance
        #
        # @param pan_string [String] static capture notation string
        # @return [StaticCapture] static capture action instance
        # @raise [ArgumentError] if the string is not valid static capture notation
        #
        # @example
        #   StaticCapture.parse("+d4")      # => #<StaticCapture destination="d4">
        def self.parse(pan_string)
          raise ::ArgumentError, format(ERROR_INVALID_STATIC_CAPTURE, pan_string) unless valid?(pan_string)

          square = pan_string[1..]
          new(square)
        end

        # Create a new static capture action instance
        #
        # @param square [String] CELL coordinate of piece to capture
        # @raise [ArgumentError] if coordinate is invalid
        #
        # @example
        #   StaticCapture.new("d4")  # => #<StaticCapture ...>
        def initialize(square)
          raise ::ArgumentError, format(ERROR_INVALID_SQUARE, square) unless ::Sashite::Cell.valid?(square)

          @destination = square

          freeze
        end

        # Get the action type
        #
        # @return [Symbol] :static_capture
        def type
          TYPE
        end

        # Get the source coordinate
        #
        # @return [nil] static capture actions have no source
        def source
          nil
        end

        # Get the piece identifier
        #
        # @return [nil] static capture actions have no piece identifier
        def piece
          nil
        end

        # Get the transformation piece
        #
        # @return [nil] static capture actions have no transformation
        def transformation
          nil
        end

        # Convert the action to its PAN string representation
        #
        # @return [String] static capture notation
        #
        # @example
        #   action.to_s  # => "+d4"
        def to_s
          "#{OPERATOR}#{destination}"
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
        # @return [Boolean] true
        def static_capture?
          true
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
        # @return [Boolean] false
        def modify?
          false
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

          destination == other.destination
        end

        # Alias for == to ensure Set functionality works correctly
        alias eql? ==

        # Custom hash implementation for use in collections
        #
        # @return [Integer] hash value
        def hash
          [self.class, destination].hash
        end
      end
    end
  end
end
