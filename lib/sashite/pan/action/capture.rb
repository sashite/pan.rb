# frozen_string_literal: true

require "sashite/cell"
require "sashite/epin"

module Sashite
  module Pan
    module Action
      # Capture action class
      #
      # Handles capture actions at destination, with optional transformation.
      #
      # Format: <source>+<destination>[=<piece>]
      # Examples: "d1+f3", "b7+a8=R"
      class Capture
        # Action type
        TYPE = :capture

        # Operator constant
        OPERATOR = "+"

        # Transformation separator
        TRANSFORMATION_SEPARATOR = "="

        # Error messages
        ERROR_INVALID_CAPTURE = "Invalid capture notation: %s"
        ERROR_INVALID_SOURCE = "Invalid source coordinate: %s"
        ERROR_INVALID_DESTINATION = "Invalid destination coordinate: %s"
        ERROR_INVALID_TRANSFORMATION = "Invalid transformation piece: %s"

        # @return [String] source CELL coordinate
        attr_reader :source

        # @return [String] destination CELL coordinate
        attr_reader :destination

        # @return [String, nil] optional EPIN transformation
        attr_reader :transformation

        # Check if a string represents a valid capture action
        #
        # @param pan_string [String] the string to validate
        # @return [Boolean] true if valid capture notation
        #
        # @example
        #   Capture.valid?("d1+f3")       # => true
        #   Capture.valid?("b7+a8=R")     # => true
        #   Capture.valid?("d1-f3")       # => false
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

        # Parse a capture notation string into a Capture instance
        #
        # @param pan_string [String] capture notation string
        # @return [Capture] capture action instance
        # @raise [ArgumentError] if the string is not valid capture notation
        #
        # @example
        #   Capture.parse("d1+f3")      # => #<Capture source="d1" destination="f3">
        #   Capture.parse("b7+a8=R")    # => #<Capture source="b7" destination="a8" transformation="R">
        def self.parse(pan_string)
          raise ::ArgumentError, format(ERROR_INVALID_CAPTURE, pan_string) unless valid?(pan_string)

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

        # Create a new capture action instance
        #
        # @param source [String] source CELL coordinate
        # @param destination [String] destination CELL coordinate
        # @param transformation [String, nil] optional EPIN transformation
        # @raise [ArgumentError] if coordinates or transformation are invalid
        #
        # @example
        #   Capture.new("d1", "f3")                      # => #<Capture ...>
        #   Capture.new("b7", "a8", transformation: "R") # => #<Capture ...>
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
        # @return [Symbol] :capture
        def type
          TYPE
        end

        # Get the piece identifier
        #
        # @return [nil] capture actions have no piece identifier
        def piece
          nil
        end

        # Convert the action to its PAN string representation
        #
        # @return [String] capture notation
        #
        # @example
        #   action.to_s  # => "d1+f3" or "b7+a8=R"
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
        # @return [Boolean] false
        def move?
          false
        end

        # Check if this is a capture action
        #
        # @return [Boolean] true
        def capture?
          true
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
