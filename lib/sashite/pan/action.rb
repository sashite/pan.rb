# frozen_string_literal: true

require_relative "action/pass"
require_relative "action/move"
require_relative "action/capture"
require_relative "action/special"
require_relative "action/static_capture"
require_relative "action/drop"
require_relative "action/drop_capture"
require_relative "action/modify"

module Sashite
  module Pan
    # Action module
    #
    # Orchestrates all action types in PAN (Portable Action Notation) format.
    # Each action type is implemented as a separate, autonomous class.
    #
    # This module provides a unified interface for validation, parsing,
    # and factory methods that delegate to the appropriate action class.
    module Action
      # Error messages
      ERROR_INVALID_PAN = "Invalid PAN string: %s"

      # Check if a string represents a valid PAN action
      #
      # @param pan_string [String] the string to validate
      # @return [Boolean] true if the string is a valid PAN action
      #
      # @example
      #   Action.valid?("e2-e4")     # => true
      #   Action.valid?("P*e5")      # => true
      #   Action.valid?("...")       # => true
      #   Action.valid?("invalid")   # => false
      def self.valid?(pan_string)
        return false unless pan_string.is_a?(::String)
        return false if pan_string.empty?

        # Try each action type's validation
        Pass.valid?(pan_string) ||
          Move.valid?(pan_string) ||
          Capture.valid?(pan_string) ||
          Special.valid?(pan_string) ||
          StaticCapture.valid?(pan_string) ||
          Drop.valid?(pan_string) ||
          DropCapture.valid?(pan_string) ||
          Modify.valid?(pan_string)
      end

      # Parse a PAN string into an action object
      #
      # @param pan_string [String] PAN notation string
      # @return [Pass, Move, Capture, Special, StaticCapture, Drop, DropCapture, Modify] immutable action instance
      # @raise [ArgumentError] if the PAN string is invalid
      #
      # @example
      #   Action.parse("e2-e4")      # => #<Move ...>
      #   Action.parse("d1+f3")      # => #<Capture ...>
      #   Action.parse("...")        # => #<Pass ...>
      def self.parse(pan_string)
        string_value = String(pan_string)

        # Try each action type's parser in order of specificity
        return Pass.parse(string_value) if Pass.valid?(string_value)
        return Move.parse(string_value) if Move.valid?(string_value)
        return Capture.parse(string_value) if Capture.valid?(string_value)
        return Special.parse(string_value) if Special.valid?(string_value)
        return StaticCapture.parse(string_value) if StaticCapture.valid?(string_value)
        return Drop.parse(string_value) if Drop.valid?(string_value)
        return DropCapture.parse(string_value) if DropCapture.valid?(string_value)
        return Modify.parse(string_value) if Modify.valid?(string_value)

        raise ::ArgumentError, format(ERROR_INVALID_PAN, string_value)
      end

      # Create a pass action
      #
      # @return [Pass] pass action instance
      #
      # @example
      #   Action.pass  # => #<Pass>
      def self.pass
        Pass.instance
      end

      # Create a move action to an empty square
      #
      # @param source [String] source CELL coordinate
      # @param destination [String] destination CELL coordinate
      # @param transformation [String, nil] optional EPIN transformation
      # @return [Move] move action instance
      #
      # @example
      #   Action.move("e2", "e4")                        # => #<Move ...>
      #   Action.move("e7", "e8", transformation: "Q")   # => #<Move ...>
      def self.move(source, destination, transformation: nil)
        Move.new(source, destination, transformation: transformation)
      end

      # Create a capture action at destination
      #
      # @param source [String] source CELL coordinate
      # @param destination [String] destination CELL coordinate
      # @param transformation [String, nil] optional EPIN transformation
      # @return [Capture] capture action instance
      #
      # @example
      #   Action.capture("d1", "f3")                      # => #<Capture ...>
      #   Action.capture("b7", "a8", transformation: "R") # => #<Capture ...>
      def self.capture(source, destination, transformation: nil)
        Capture.new(source, destination, transformation: transformation)
      end

      # Create a special move action with implicit side effects
      #
      # @param source [String] source CELL coordinate
      # @param destination [String] destination CELL coordinate
      # @param transformation [String, nil] optional EPIN transformation
      # @return [Special] special action instance
      #
      # @example
      #   Action.special("e1", "g1")  # => #<Special ...>
      def self.special(source, destination, transformation: nil)
        Special.new(source, destination, transformation: transformation)
      end

      # Create a static capture action (remove piece without movement)
      #
      # @param square [String] CELL coordinate of piece to capture
      # @return [StaticCapture] static capture action instance
      #
      # @example
      #   Action.static_capture("d4")  # => #<StaticCapture ...>
      def self.static_capture(square)
        StaticCapture.new(square)
      end

      # Create a drop action to empty square
      #
      # @param destination [String] destination CELL coordinate
      # @param piece [String, nil] optional EPIN piece identifier
      # @param transformation [String, nil] optional EPIN transformation
      # @return [Drop] drop action instance
      #
      # @example
      #   Action.drop("e5", piece: "P")                           # => #<Drop ...>
      #   Action.drop("d4")                                       # => #<Drop ...>
      #   Action.drop("c3", piece: "S", transformation: "+S")     # => #<Drop ...>
      def self.drop(destination, piece: nil, transformation: nil)
        Drop.new(destination, piece: piece, transformation: transformation)
      end

      # Create a drop action with capture
      #
      # @param destination [String] destination CELL coordinate
      # @param piece [String, nil] optional EPIN piece identifier
      # @param transformation [String, nil] optional EPIN transformation
      # @return [DropCapture] drop capture action instance
      #
      # @example
      #   Action.drop_capture("b4", piece: "L")  # => #<DropCapture ...>
      def self.drop_capture(destination, piece: nil, transformation: nil)
        DropCapture.new(destination, piece: piece, transformation: transformation)
      end

      # Create an in-place transformation action
      #
      # @param square [String] CELL coordinate
      # @param piece [String] EPIN piece identifier (final state)
      # @return [Modify] modification action instance
      #
      # @example
      #   Action.modify("e4", "+P")   # => #<Modify ...>
      #   Action.modify("c3", "k'")   # => #<Modify ...>
      def self.modify(square, piece)
        Modify.new(square, piece)
      end
    end
  end
end
