module Sashite
  module PAN
    class SetActor
      attr_reader :actor, :square

      def initialize square, actor
        raise TypeError unless actor.is_a? Symbol
        raise TypeError unless square.is_a? Fixnum

        @actor = actor
        @square = square
      end

      def to_a
        [
          verb,
          @square,
          @actor
        ]
      end

      def verb
        self.class.name.split('::').last.downcase.to_sym
      end
    end
  end
end
