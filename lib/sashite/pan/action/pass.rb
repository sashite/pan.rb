# frozen_string_literal: true

require "singleton"

module Sashite
  module Pan
    module Action
      # Pass action class
      #
      # Represents a pass action where the active player voluntarily ends their turn
      # without performing any movement or transformation.
      #
      # This class is implemented as a singleton since all pass actions are identical.
      #
      # Format: "..."
      class Pass
        include ::Singleton

        # Action type
        TYPE = :pass

        # Pass notation constant
        NOTATION = "..."

        # Error messages
        ERROR_INVALID_PASS = "Invalid pass notation: %s"

        # Check if a string represents a valid pass action
        #
        # @param pan_string [String] the string to validate
        # @return [Boolean] true if valid pass notation
        #
        # @example
        #   Pass.valid?("...")       # => true
        #   Pass.valid?("e2-e4")     # => false
        def self.valid?(pan_string)
          pan_string == NOTATION
        end

        # Parse a pass notation string into a Pass instance
        #
        # @param pan_string [String] pass notation string
        # @return [Pass] the singleton pass action instance
        # @raise [ArgumentError] if the string is not a valid pass notation
        #
        # @example
        #   Pass.parse("...")  # => #<Pass>
        def self.parse(pan_string)
          raise ::ArgumentError, format(ERROR_INVALID_PASS, pan_string) unless valid?(pan_string)

          instance
        end

        # Get the action type
        #
        # @return [Symbol] :pass
        def type
          TYPE
        end

        # Get the source coordinate
        #
        # @return [nil] pass actions have no source
        def source
          nil
        end

        # Get the destination coordinate
        #
        # @return [nil] pass actions have no destination
        def destination
          nil
        end

        # Get the piece identifier
        #
        # @return [nil] pass actions have no piece
        def piece
          nil
        end

        # Get the transformation piece
        #
        # @return [nil] pass actions have no transformation
        def transformation
          nil
        end

        # Convert the action to its PAN string representation
        #
        # @return [String] pass notation "..."
        #
        # @example
        #   action.to_s  # => "..."
        def to_s
          NOTATION
        end

        # Check if this is a pass action
        #
        # @return [Boolean] true
        def pass?
          true
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
        # @return [Boolean] true if other is also the Pass singleton
        def ==(other)
          other.equal?(self)
        end

        # Alias for == to ensure Set functionality works correctly
        alias eql? ==

        # Custom hash implementation for use in collections
        #
        # @return [Integer] hash value
        def hash
          [self.class, TYPE].hash
        end
      end
    end
  end
end
