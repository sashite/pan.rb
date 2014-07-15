require_relative '_test_helper'

describe Sashite::PAN do
  describe 'drops' do
    describe 'errors' do
      it 'raises a type error from the actor' do
        -> { Sashite::PAN.load :drop, 42, 'foobar' }.must_raise TypeError
      end

      it 'raises a type error from the destination square' do
        -> { Sashite::PAN.load :drop, '42', :foobar }.must_raise TypeError
      end
    end

    describe 'instances' do
      before do
        @action = Sashite::PAN.load :drop, 42, :foobar
      end

      it 'returns the action' do
        @action.to_a.must_equal [ :drop, 42, :foobar ]
      end

      it 'returns the action (once again)' do
        @action.to_a.must_equal Sashite::PAN::Drop.new(42, :foobar).to_a
      end

      it 'returns the actor of the action' do
        @action.actor.must_equal :foobar
      end

      it 'returns the dst_square of the action' do
        @action.dst_square.must_equal 42
      end
    end
  end
end
