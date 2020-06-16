# frozen_string_literal: true

module Sashite
  module PAN
    # Dumper class
    class Dumper
      def self.call(*unserialized_actions)
        unserialized_actions.map { |params| new(*params).call }.join(';')
      end

      attr_reader :src_square, :dst_square, :piece_name, :piece_hand

      def initialize(src_square, dst_square, piece_name, piece_hand)
        unless src_square.nil?
          raise src_square.inspect unless src_square.is_a?(Integer)
        end

        raise dst_square.inspect unless dst_square.is_a?(Integer)
        raise piece_name.inspect unless piece_name.is_a?(String)

        unless piece_hand.nil?
          raise piece_hand.inspect unless piece_hand.is_a?(String)
        end

        @src_square = (src_square.nil? ? '*' : src_square)
        @dst_square = dst_square
        @piece_name = piece_name
        @piece_hand = piece_hand
      end

      def call
        action_items.join(',')
      end

      private

      def action_items
        return [src_square, dst_square, piece_name] if piece_hand.nil?

        [src_square, dst_square, piece_name, piece_hand]
      end
    end
  end
end
