# frozen_string_literal: true

require "sashite/cell"
require "sashite/epin"

module Sashite
  module Pan
    module Action
      # Move action class
      #
      # Handles move actions to empty squares, with optional transformation.
      #
      # Format: <source>-<destination>[=<piece>]
      # Examples: "e2-e4", "e7-e8=Q", "a7-a8=+R"
      class Move
        # Action type
        TYPE = :move

        # Operator constant
        OPERATOR = "-"

        # Transformation separator
        TRANSFORMATION_SEPARATOR = "="

        # Error messages
        ERROR_INVALID_MOVE = "Invalid move notation: %s"
        ERROR_INVALID_SOURCE = "Invalid source coordinate: %s"
        ERROR_INVALID_DESTINATION = "Invalid destination coordinate: %s"
        ERROR_INVALID_TRANSFORMATION = "Invalid transformation piece: %s"

        # @return [String] source CELL coordinate
        attr_reader :source

        # @return [String] destination CELL coordinate
        attr_reader :destination

        # @return [String, nil] optional EPIN transformation
        attr_reader :transformation

        # Check if a string represents a valid move action
        #
        # @param pan_string [String] the string to validate
        # @return [Boolean] true if valid move notation
        #
        # @example
        #   Move.valid?("e2-e4")       # => true
        #   Move.valid?("e7-e8=Q")     # => true
        #   Move.valid?("e2+e4")       # => false
        def self.valid?(pan_string)
          return false unless pan_string.is_a?(::String)
          return false unless pan_string.include?(OPERATOR)

          parts = pan_string.split(OPERATOR, 2)
          return false if parts.size != 2

          source_part = parts[0]
          dest_and_transform = parts[1]

          return false unless ::Sashite::Cell.valid?(source_part)

          # Check if there's a transformation
          if dest_and_transform.include?(TRANSFORMATION_SEPARATOR)
            dest_parts = dest_and_transform.split(TRANSFORMATION_SEPARATOR, 2)
            return false if dest_parts.size != 2

            destination_part = dest_parts[0]
            transformation_part = dest_parts[1]

            return false unless ::Sashite::Cell.valid?(destination_part)
            return false unless ::Sashite::Epin.valid?(transformation_part)
          else
            return false unless ::Sashite::Cell.valid?(dest_and_transform)
          end

          true
        end

        # Parse a move notation string into a Move instance
        #
        # @param pan_string [String] move notation string
        # @return [Move] move action instance
        # @raise [ArgumentError] if the string is not valid move notation
        #
        # @example
        #   Move.parse("e2-e4")      # => #<Move source="e2" destination="e4">
        #   Move.parse("e7-e8=Q")    # => #<Move source="e7" destination="e8" transformation="Q">
        def self.parse(pan_string)
          raise ::ArgumentError, format(ERROR_INVALID_MOVE, pan_string) unless valid?(pan_string)

          parts = pan_string.split(OPERATOR, 2)
          source = parts[0]
          dest_and_transform = parts[1]

          if dest_and_transform.include?(TRANSFORMATION_SEPARATOR)
            dest_parts = dest_and_transform.split(TRANSFORMATION_SEPARATOR, 2)
            destination = dest_parts[0]
            transformation = dest_parts[1]
          else
            destination = dest_and_transform
            transformation = nil
          end

          new(source, destination, transformation: transformation)
        end

        # Create a new move action instance
        #
        # @param source [String] source CELL coordinate
        # @param destination [String] destination CELL coordinate
        # @param transformation [String, nil] optional EPIN transformation
        # @raise [ArgumentError] if coordinates or transformation are invalid
        #
        # @example
        #   Move.new("e2", "e4")                        # => #<Move ...>
        #   Move.new("e7", "e8", transformation: "Q")   # => #<Move ...>
        def initialize(source, destination, transformation: nil)
          raise ::ArgumentError, format(ERROR_INVALID_SOURCE, source) unless ::Sashite::Cell.valid?(source)
          unless ::Sashite::Cell.valid?(destination)
            raise ::ArgumentError, format(ERROR_INVALID_DESTINATION, destination)
          end

          if transformation && !::Sashite::Epin.valid?(transformation)
            raise ::ArgumentError, format(ERROR_INVALID_TRANSFORMATION, transformation)
          end

          @source = source
          @destination = destination
          @transformation = transformation

          freeze
        end

        # Get the action type
        #
        # @return [Symbol] :move
        def type
          TYPE
        end

        # Get the piece identifier
        #
        # @return [nil] move actions have no piece identifier
        def piece
          nil
        end

        # Convert the action to its PAN string representation
        #
        # @return [String] move notation
        #
        # @example
        #   action.to_s  # => "e2-e4" or "e7-e8=Q"
        def to_s
          result = "#{source}#{OPERATOR}#{destination}"
          result += "#{TRANSFORMATION_SEPARATOR}#{transformation}" if transformation
          result
        end

        # Check if this is a pass action
        #
        # @return [Boolean] false
        def pass?
          false
        end

        # Check if this is a move action
        #
        # @return [Boolean] true
        def move?
          true
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
        # @return [Boolean] false
        def modify?
          false
        end

        # Check if this is a movement action
        #
        # @return [Boolean] true
        def movement?
          true
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

          source == other.source &&
            destination == other.destination &&
            transformation == other.transformation
        end

        # Alias for == to ensure Set functionality works correctly
        alias eql? ==

        # Custom hash implementation for use in collections
        #
        # @return [Integer] hash value
        def hash
          [self.class, source, destination, transformation].hash
        end
      end
    end
  end
end
