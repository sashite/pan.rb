# frozen_string_literal: true

require "sashite/cell"
require "sashite/epin"

module Sashite
  module Pan
    module Action
      # Drop action class
      #
      # Handles drop actions to empty squares, with optional piece identifier
      # and transformation.
      #
      # Format: [<piece>]*<destination>[=<piece>]
      # Examples: "P*e5", "*d4", "S*c3=+S"
      class Drop
        # Action type
        TYPE = :drop

        # Operator constant
        OPERATOR = "*"

        # Transformation separator
        TRANSFORMATION_SEPARATOR = "="

        # Error messages
        ERROR_INVALID_DROP = "Invalid drop notation: %s"
        ERROR_INVALID_DESTINATION = "Invalid destination coordinate: %s"
        ERROR_INVALID_PIECE = "Invalid piece identifier: %s"
        ERROR_INVALID_TRANSFORMATION = "Invalid transformation piece: %s"

        # @return [String] destination CELL coordinate
        attr_reader :destination

        # @return [String, nil] optional EPIN piece identifier
        attr_reader :piece

        # @return [String, nil] optional EPIN transformation
        attr_reader :transformation

        # Check if a string represents a valid drop action
        #
        # @param pan_string [String] the string to validate
        # @return [Boolean] true if valid drop notation
        #
        # @example
        #   Drop.valid?("P*e5")       # => true
        #   Drop.valid?("*d4")        # => true
        #   Drop.valid?("S*c3=+S")    # => true
        def self.valid?(pan_string)
          return false unless pan_string.is_a?(::String)
          return false unless pan_string.include?(OPERATOR)

          parts = pan_string.split(OPERATOR, 2)
          return false if parts.size != 2

          piece_part = parts[0]
          dest_and_transform = parts[1]

          # Piece part is optional, but if present must be valid EPIN
          return false if !piece_part.empty? && !::Sashite::Epin.valid?(piece_part)

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

        # Parse a drop notation string into a Drop instance
        #
        # @param pan_string [String] drop notation string
        # @return [Drop] drop action instance
        # @raise [ArgumentError] if the string is not valid drop notation
        #
        # @example
        #   Drop.parse("P*e5")      # => #<Drop piece="P" destination="e5">
        #   Drop.parse("*d4")       # => #<Drop destination="d4">
        #   Drop.parse("S*c3=+S")   # => #<Drop piece="S" destination="c3" transformation="+S">
        def self.parse(pan_string)
          raise ::ArgumentError, format(ERROR_INVALID_DROP, pan_string) unless valid?(pan_string)

          parts = pan_string.split(OPERATOR, 2)
          piece = parts[0].empty? ? nil : parts[0]
          dest_and_transform = parts[1]

          if dest_and_transform.include?(TRANSFORMATION_SEPARATOR)
            dest_parts = dest_and_transform.split(TRANSFORMATION_SEPARATOR, 2)
            destination = dest_parts[0]
            transformation = dest_parts[1]
          else
            destination = dest_and_transform
            transformation = nil
          end

          new(destination, piece: piece, transformation: transformation)
        end

        # Create a new drop action instance
        #
        # @param destination [String] destination CELL coordinate
        # @param piece [String, nil] optional EPIN piece identifier
        # @param transformation [String, nil] optional EPIN transformation
        # @raise [ArgumentError] if coordinates, piece, or transformation are invalid
        #
        # @example
        #   Drop.new("e5", piece: "P")                           # => #<Drop ...>
        #   Drop.new("d4")                                       # => #<Drop ...>
        #   Drop.new("c3", piece: "S", transformation: "+S")     # => #<Drop ...>
        def initialize(destination, piece: nil, transformation: nil)
          unless ::Sashite::Cell.valid?(destination)
            raise ::ArgumentError, format(ERROR_INVALID_DESTINATION, destination)
          end

          raise ::ArgumentError, format(ERROR_INVALID_PIECE, piece) if piece && !::Sashite::Epin.valid?(piece)

          if transformation && !::Sashite::Epin.valid?(transformation)
            raise ::ArgumentError, format(ERROR_INVALID_TRANSFORMATION, transformation)
          end

          @destination = destination
          @piece = piece
          @transformation = transformation

          freeze
        end

        # Get the action type
        #
        # @return [Symbol] :drop
        def type
          TYPE
        end

        # Get the source coordinate
        #
        # @return [nil] drop actions have no source
        def source
          nil
        end

        # Convert the action to its PAN string representation
        #
        # @return [String] drop notation
        #
        # @example
        #   action.to_s  # => "P*e5" or "*d4" or "S*c3=+S"
        def to_s
          result = +""
          result << piece if piece
          result << OPERATOR
          result << destination
          result << TRANSFORMATION_SEPARATOR << transformation if transformation
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
        # @return [Boolean] true
        def drop?
          true
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
        # @return [Boolean] true
        def drop_action?
          true
        end

        # Custom equality comparison
        #
        # @param other [Object] object to compare with
        # @return [Boolean] true if actions are equal
        def ==(other)
          return false unless other.is_a?(self.class)

          destination == other.destination &&
            piece == other.piece &&
            transformation == other.transformation
        end

        # Alias for == to ensure Set functionality works correctly
        alias eql? ==

        # Custom hash implementation for use in collections
        #
        # @return [Integer] hash value
        def hash
          [self.class, destination, piece, transformation].hash
        end
      end
    end
  end
end
