require_relative '_test_helper'

describe Sashite::PAN do
  describe 'promotion' do
    describe 'errors' do
      it 'raises a type error from the source square' do
        -> { Sashite::PAN.load :promote, '42', :foobar }.must_raise TypeError
      end

      it 'raises a type error from the actor' do
        -> { Sashite::PAN.load :promote, 42, 'foobar' }.must_raise TypeError
      end
    end

    describe 'instances' do
      before do
        @action = Sashite::PAN.load :promote, 42, :foobar
      end

      it 'returns the action' do
        @action.to_a.must_equal [ :promote, 42, :foobar ]
      end

      it 'returns the action (once again)' do
        @action.to_a.must_equal Sashite::PAN::Promote.new(42, :foobar).to_a
      end

      it 'returns the square of the action' do
        @action.square.must_equal 42
      end

      it 'returns the actor of the action' do
        @action.actor.must_equal :foobar
      end
    end
  end
end
