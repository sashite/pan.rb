# frozen_string_literal: true

require_relative 'action'

module Sashite
  module PAN
    # Parser class
    class Parser < Action
      def self.call(pan_string)
        pan_string.split(';').map do |serialized_action|
          new(serialized_action).call
        end
      end

      def initialize(serialized_action)
        action_args = serialized_action.split(',')
        src_square  = action_args.fetch(0)
        @src_square = src_square.eql?('*') ? nil : src_square.to_i
        @dst_square = action_args.fetch(1).to_i
        @piece_name = action_args.fetch(2)
        @piece_hand = action_args.fetch(3, nil)
      end

      def call
        [
          src_square,
          dst_square,
          piece_name,
          piece_hand
        ]
      end
    end
  end
end
