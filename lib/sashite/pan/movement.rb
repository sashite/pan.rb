module Sashite
  module PAN
    class Movement
      attr_reader :src_square, :dst_square

      def initialize src_square, dst_square
        raise TypeError unless src_square.is_a? Fixnum
        raise TypeError unless dst_square.is_a? Fixnum
        raise SameSquareError if src_square == dst_square

        @src_square = src_square
        @dst_square = dst_square
      end

      def to_a
        [
          self.class.name.split('::').last.downcase.to_sym,
          @src_square,
          @dst_square
        ]
      end
    end
  end
end
