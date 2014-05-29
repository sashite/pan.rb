require_relative '_test_helper'

describe Sashite::PAN do
  describe 'errors' do
    it 'raises a not implemented method error' do
      -> { Sashite::PAN.load :foobar, 42, 43 }.must_raise Sashite::PAN::NotImplementedVerbError
    end
  end
end
