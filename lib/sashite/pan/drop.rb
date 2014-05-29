module Sashite
  module PAN
    class Drop
      attr_reader :actor, :dst_square

      def initialize actor, dst_square
        raise TypeError unless actor.is_a? Symbol
        raise TypeError unless dst_square.is_a? Fixnum

        @actor = actor
        @dst_square = dst_square
      end

      def to_a
        [
          self.class.name.split('::').last.downcase.to_sym,
          @actor,
          @dst_square
        ]
      end
    end
  end
end
