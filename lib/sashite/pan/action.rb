# frozen_string_literal: true

module Sashite
  module PAN
    # Action class
    class Action
      attr_reader :src_square, :dst_square, :piece_name, :piece_hand

      private_class_method def self.separator
        ";"
      end

      private

      def separator
        ","
      end

      def drop_char
        "*"
      end
    end
  end
end
