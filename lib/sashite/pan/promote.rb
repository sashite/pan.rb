module Sashite
  module PAN
    class Promote
      attr_reader :src_square, :actor

      def initialize src_square, actor
        raise TypeError unless src_square.is_a? Fixnum
        raise TypeError unless actor.is_a? Symbol

        @src_square = src_square
        @actor = actor
      end

      def to_a
        [
          self.class.name.split('::').last.downcase.to_sym,
          @src_square,
          @actor
        ]
      end
    end
  end
end
