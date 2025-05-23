# frozen_string_literal: true

require_relative "parser/error"

module Sashite
  module Pan
    # Parser for Portable Action Notation (PAN) strings
    module Parser
      # Parse a PAN string into PMN format
      #
      # @param pan_string [String] The PAN string to parse
      # @return [Array<Hash>] Array of PMN action objects
      # @raise [Parser::Error] If the PAN string is invalid
      def self.call(pan_string)
        raise Parser::Error, "PAN string cannot be nil" if pan_string.nil?
        raise Parser::Error, "PAN string cannot be empty" if pan_string.empty?

        actions = pan_string.split(";").map(&:strip)
        raise Parser::Error, "No actions found" if actions.empty?

        actions.map { |action| parse_action(action) }
      end

      private

      # Parse a single action string into a PMN action hash
      #
      # @param action_string [String] Single action in PAN format
      # @return [Hash] PMN action object
      # @raise [Parser::Error] If the action is invalid
      def self.parse_action(action_string)
        components = action_string.split(",").map(&:strip)

        validate_action_components(components)

        {
          "src_square" => parse_source_square(components[0]),
          "dst_square" => components[1],
          "piece_name" => components[2],
          "piece_hand" => components[3] || nil
        }.compact
      end

      # Validate action components structure
      #
      # @param components [Array<String>] Components of the action
      # @raise [Parser::Error] If components are invalid
      def self.validate_action_components(components)
        case components.length
        when 0, 1, 2
          raise Parser::Error, "Action must have at least 3 components (source, destination, piece)"
        when 3, 4
          # Valid number of components
        else
          raise Parser::Error, "Action cannot have more than 4 components"
        end

        components.each_with_index do |component, index|
          if component.nil? || component.empty?
            raise Parser::Error, "Component #{index} cannot be empty"
          end
        end

        validate_piece_identifier(components[2])
        validate_piece_identifier(components[3]) if components[3]
      end

      # Parse source square, handling drop notation
      #
      # @param source [String] Source square or "*" for drop
      # @return [String, nil] Square identifier or nil for drops
      def self.parse_source_square(source)
        source == "*" ? nil : source
      end

      # Validate piece identifier follows PNN specification
      #
      # @param piece [String] Piece identifier to validate
      # @raise [Parser::Error] If piece identifier is invalid
      def self.validate_piece_identifier(piece)
        return if piece.nil?

        # PNN pattern: optional prefix (+/-), letter (a-z/A-Z), optional suffix (')
        unless piece.match?(/\A[-+]?[a-zA-Z][']?\z/)
          raise Parser::Error, "Invalid piece identifier: #{piece}"
        end
      end
    end
  end
end
