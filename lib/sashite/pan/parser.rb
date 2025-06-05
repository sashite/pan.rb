# frozen_string_literal: true

module Sashite
  module Pan
    # Parser for Portable Action Notation (PAN) strings
    module Parser
      class Error < ::StandardError
      end

      # Regular expression pattern for validating PAN strings
      PAN_PATTERN = /\A(\*|[a-z][0-9][-x])([a-z][0-9])\z/

      # Parse a PAN string into structured move data
      #
      # @param pan_string [String] The PAN string to parse
      # @return [Hash] Structured move data with type, source, and destination
      # @raise [Parser::Error] If the PAN string is invalid
      def self.call(pan_string)
        raise Parser::Error, "PAN string cannot be nil" if pan_string.nil?
        raise Parser::Error, "PAN string must be a String" unless pan_string.is_a?(::String)
        raise Parser::Error, "PAN string cannot be empty" if pan_string.empty?

        validate_format(pan_string)
        parse_move(pan_string)
      end

      private

      # Validate the basic format of a PAN string
      #
      # @param pan_string [String] The PAN string to validate
      # @raise [Parser::Error] If format is invalid
      def self.validate_format(pan_string)
        unless pan_string.match?(PAN_PATTERN)
          raise Parser::Error, "Invalid PAN format: #{pan_string}"
        end

        # Additional validation for source != destination in moves and captures
        if pan_string.include?('-') || pan_string.include?('x')
          source = pan_string[0..1]
          destination = pan_string[-2..-1]
          if source == destination
            raise Parser::Error, "Source and destination cannot be identical: #{source}"
          end
        end
      end

      # Parse the move based on its type
      #
      # @param pan_string [String] The validated PAN string
      # @return [Hash] Structured move data
      def self.parse_move(pan_string)
        case pan_string
        when /\A([a-z][0-9])-([a-z][0-9])\z/
          parse_simple_move($1, $2)
        when /\A([a-z][0-9])x([a-z][0-9])\z/
          parse_capture_move($1, $2)
        when /\A\*([a-z][0-9])\z/
          parse_drop_move($1)
        else
          # This should never happen due to earlier validation
          raise Parser::Error, "Unexpected PAN format: #{pan_string}"
        end
      end

      # Parse a simple move (non-capture)
      #
      # @param source [String] Source coordinate
      # @param destination [String] Destination coordinate
      # @return [Hash] Move data for simple move
      def self.parse_simple_move(source, destination)
        {
          type: :move,
          source: source,
          destination: destination
        }
      end

      # Parse a capture move
      #
      # @param source [String] Source coordinate
      # @param destination [String] Destination coordinate
      # @return [Hash] Move data for capture move
      def self.parse_capture_move(source, destination)
        {
          type: :capture,
          source: source,
          destination: destination
        }
      end

      # Parse a drop/placement move
      #
      # @param destination [String] Destination coordinate
      # @return [Hash] Move data for drop move
      def self.parse_drop_move(destination)
        {
          type: :drop,
          destination: destination
        }
      end
    end
  end
end
