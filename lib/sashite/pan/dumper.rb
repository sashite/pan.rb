# frozen_string_literal: true

require_relative "dumper/error"

module Sashite
  module Pan
    # Dumper for converting PMN format to PAN strings
    module Dumper
      # Convert PMN actions to PAN string
      #
      # @param pmn_actions [Array<Hash>] Array of PMN action objects
      # @return [String] PAN string representation
      # @raise [Dumper::Error] If the PMN data is invalid
      def self.call(pmn_actions)
        raise Dumper::Error, "PMN actions cannot be nil" if pmn_actions.nil?
        raise Dumper::Error, "PMN actions cannot be empty" if pmn_actions.empty?
        raise Dumper::Error, "PMN actions must be an array" unless pmn_actions.is_a?(::Array)

        pmn_actions.map { |action| dump_action(action) }.join(";")
      end

      private

      # Convert a single PMN action to PAN format
      #
      # @param action [Hash] PMN action object
      # @return [String] PAN action string
      # @raise [Dumper::Error] If the action is invalid
      def self.dump_action(action)
        validate_pmn_action(action)

        components = [
          dump_source_square(action["src_square"]),
          action["dst_square"],
          action["piece_name"]
        ]

        components << action["piece_hand"] if action["piece_hand"]

        components.join(",")
      end

      # Validate PMN action structure
      #
      # @param action [Hash] PMN action to validate
      # @raise [Dumper::Error] If action is invalid
      def self.validate_pmn_action(action)
        raise Dumper::Error, "Action must be a Hash" unless action.is_a?(::Hash)
        raise Dumper::Error, "Action must have dst_square" unless action.key?("dst_square")
        raise Dumper::Error, "Action must have piece_name" unless action.key?("piece_name")

        raise Dumper::Error, "dst_square cannot be nil or empty" if action["dst_square"].nil? || action["dst_square"].empty?
        raise Dumper::Error, "piece_name cannot be nil or empty" if action["piece_name"].nil? || action["piece_name"].empty?

        validate_piece_identifier(action["piece_name"])
        validate_piece_identifier(action["piece_hand"]) if action["piece_hand"]
      end

      # Convert source square, handling drops
      #
      # @param src_square [String, nil] Source square or nil for drop
      # @return [String] "*" for drops, otherwise the square identifier
      def self.dump_source_square(src_square)
        src_square.nil? ? "*" : src_square
      end

      # Validate piece identifier follows PNN specification
      #
      # @param piece [String] Piece identifier to validate
      # @raise [Dumper::Error] If piece identifier is invalid
      def self.validate_piece_identifier(piece)
        return if piece.nil?

        # PNN pattern: optional prefix (+/-), letter (a-z/A-Z), optional suffix (')
        unless piece.match?(/\A[-+]?[a-zA-Z][']?\z/)
          raise Dumper::Error, "Invalid piece identifier: #{piece}"
        end
      end
    end
  end
end
