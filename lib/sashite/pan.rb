require_relative 'pan/error/not_implemented_verb_error'
require_relative 'pan/error/same_square_error'
require_relative 'pan/movement/capture'
require_relative 'pan/movement/shift'
require_relative 'pan/set_actor/drop'
require_relative 'pan/set_actor/promote'

module Sashite
  module PAN
    def self.load verb, arg1, arg2
      case verb

      when :capture
        Capture.new arg1, arg2

      when :drop
        Drop.new arg1, arg2

      when :promote
        Promote.new arg1, arg2

      when :shift
        Shift.new arg1, arg2

      else
        raise NotImplementedVerbError
      end
    end
  end
end
