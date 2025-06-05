# frozen_string_literal: true

module Sashite
  module Pan
    # Dumper for converting structured move data to PAN strings
    module Dumper
      class Error < ::StandardError
      end

      # Convert structured move data to PAN string
      #
      # @param move_data [Hash] Move data with type, source, destination
      # @return [String] PAN string representation
      # @raise [Dumper::Error] If the move data is invalid
      def self.call(move_data)
        raise Dumper::Error, "Move data cannot be nil" if move_data.nil?
        raise Dumper::Error, "Move data must be a Hash" unless move_data.is_a?(::Hash)

        validate_move_data(move_data)

        case move_data[:type]
        when :move
          dump_simple_move(move_data)
        when :capture
          dump_capture_move(move_data)
        when :drop
          dump_drop_move(move_data)
        else
          raise Dumper::Error, "Invalid move type: #{move_data[:type]}"
        end
      end

      private

      # Validate the structure of move data
      #
      # @param move_data [Hash] Move data to validate
      # @raise [Dumper::Error] If move data is invalid
      def self.validate_move_data(move_data)
        unless move_data.key?(:type)
          raise Dumper::Error, "Move data must have :type key"
        end

        unless move_data.key?(:destination)
          raise Dumper::Error, "Move data must have :destination key"
        end

        validate_coordinate(move_data[:destination], "destination")

        case move_data[:type]
        when :move, :capture
          unless move_data.key?(:source)
            raise Dumper::Error, "Move and capture types must have :source key"
          end
          validate_coordinate(move_data[:source], "source")
          validate_different_coordinates(move_data[:source], move_data[:destination])
        when :drop
          if move_data.key?(:source)
            raise Dumper::Error, "Drop type cannot have :source key"
          end
        else
          raise Dumper::Error, "Invalid move type: #{move_data[:type]}"
        end
      end

      # Validate a coordinate follows PAN format
      #
      # @param coordinate [String] Coordinate to validate
      # @param field_name [String] Name of the field for error messages
      # @raise [Dumper::Error] If coordinate is invalid
      def self.validate_coordinate(coordinate, field_name)
        if coordinate.nil? || coordinate.empty?
          raise Dumper::Error, "#{field_name.capitalize} coordinate cannot be nil or empty"
        end

        unless coordinate.is_a?(::String)
          raise Dumper::Error, "#{field_name.capitalize} coordinate must be a String"
        end

        unless coordinate.match?(/\A[a-z][0-9]\z/)
          raise Dumper::Error, "Invalid #{field_name} coordinate format: #{coordinate}. Must be lowercase letter followed by digit (e.g., 'e4')"
        end
      end

      # Validate that source and destination are different
      #
      # @param source [String] Source coordinate
      # @param destination [String] Destination coordinate
      # @raise [Dumper::Error] If coordinates are the same
      def self.validate_different_coordinates(source, destination)
        if source == destination
          raise Dumper::Error, "Source and destination coordinates cannot be identical: #{source}"
        end
      end

      # Generate PAN string for simple move
      #
      # @param move_data [Hash] Move data with :source and :destination
      # @return [String] PAN string in format "source-destination"
      def self.dump_simple_move(move_data)
        "#{move_data[:source]}-#{move_data[:destination]}"
      end

      # Generate PAN string for capture move
      #
      # @param move_data [Hash] Move data with :source and :destination
      # @return [String] PAN string in format "sourcexdestination"
      def self.dump_capture_move(move_data)
        "#{move_data[:source]}x#{move_data[:destination]}"
      end

      # Generate PAN string for drop move
      #
      # @param move_data [Hash] Move data with :destination
      # @return [String] PAN string in format "*destination"
      def self.dump_drop_move(move_data)
        "*#{move_data[:destination]}"
      end
    end
  end
end
