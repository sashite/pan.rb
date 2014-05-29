require_relative '_test_helper'

describe Sashite::PAN do
  describe 'remove' do
    describe 'errors' do
      it 'raises a same square error' do
        -> { Sashite::PAN::Remove.new 42, 42 }.must_raise Sashite::PAN::SameSquareError
      end

      it 'raises a type error from the source square' do
        -> { Sashite::PAN::Remove.new '42', 43 }.must_raise TypeError
      end

      it 'raises a type error from the destination square' do
        -> { Sashite::PAN::Remove.new 42, '43' }.must_raise TypeError
      end
    end

    describe 'instances' do
      before do
        @action = Sashite::PAN.load :remove, 42, 43
      end

      it 'returns the action' do
        @action.to_a.must_equal [ :remove, 42, 43 ]
      end

      it 'returns the action (once again)' do
        @action.to_a.must_equal Sashite::PAN::Remove.new(42, 43).to_a
      end

      it 'returns the src_square of the action' do
        @action.src_square.must_equal 42
      end

      it 'returns the dst_square of the action' do
        @action.dst_square.must_equal 43
      end
    end
  end
end
