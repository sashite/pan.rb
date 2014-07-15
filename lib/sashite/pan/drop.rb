module Sashite
  module PAN
    class Drop
      attr_reader :actor, :dst_square

      def initialize dst_square, actor
        raise TypeError unless actor.is_a? Symbol
        raise TypeError unless dst_square.is_a? Fixnum

        @actor = actor
        @dst_square = dst_square
      end

      def to_a
        [
          self.class.name.split('::').last.downcase.to_sym,
          @dst_square,
          @actor
        ]
      end
    end
  end
end
