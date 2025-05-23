# frozen_string_literal: true

require_relative "pan/dumper"
require_relative "pan/parser"

module Sashite
  # The PAN (Portable Action Notation) module
  module Pan
    # Main interface for PAN operations
    module_function

    # Parse a PAN string into PMN format
    #
    # @param pan_string [String] The PAN string to parse
    # @return [Array<Hash>] Array of PMN action objects
    # @raise [Parser::Error] If the PAN string is invalid
    def parse(pan_string)
      Parser.call(pan_string)
    end

    # Convert PMN actions to PAN string
    #
    # @param pmn_actions [Array<Hash>] Array of PMN action objects
    # @return [String] PAN string representation
    # @raise [Dumper::Error] If the PMN data is invalid
    def dump(pmn_actions)
      Dumper.call(pmn_actions)
    end

    # Validate a PAN string without raising exceptions
    #
    # @param pan_string [String] The PAN string to validate
    # @return [Boolean] True if valid, false otherwise
    def valid?(pan_string)
      parse(pan_string)
      true
    rescue Parser::Error
      false
    end

    # Parse a PAN string without raising exceptions
    #
    # @param pan_string [String] The PAN string to parse
    # @return [Array<Hash>, nil] Array of PMN actions or nil if invalid
    def safe_parse(pan_string)
      parse(pan_string)
    rescue Parser::Error
      nil
    end

    # Convert PMN actions to PAN string without raising exceptions
    #
    # @param pmn_actions [Array<Hash>] Array of PMN action objects
    # @return [String, nil] PAN string or nil if invalid
    def safe_dump(pmn_actions)
      dump(pmn_actions)
    rescue Dumper::Error
      nil
    end
  end
end
