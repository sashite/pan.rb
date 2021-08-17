# frozen_string_literal: true

require_relative "action"

module Sashite
  module PAN
    # Dumper class
    class Dumper < Action
      def self.call(*actions)
        actions.map { |action_items| new(*action_items).call }
               .join(separator)
      end

      def initialize(src_square, dst_square, piece_name, piece_hand = nil)
        super()

        @src_square = src_square.nil? ? drop_char : Integer(src_square)
        @dst_square = Integer(dst_square)
        @piece_name = piece_name.to_s
        @piece_hand = piece_hand&.to_s
      end

      def call
        action_items.join(separator)
      end

      private

      def action_items
        return [src_square, dst_square, piece_name] if piece_hand.nil?

        [src_square, dst_square, piece_name, piece_hand]
      end
    end
  end
end
