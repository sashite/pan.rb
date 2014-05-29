require_relative 'pan/capture'
require_relative 'pan/drop'
require_relative 'pan/error/not_implemented_verb_error'
require_relative 'pan/error/same_square_error'
require_relative 'pan/promote'
require_relative 'pan/remove'
require_relative 'pan/shift'

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

      when :remove
        Remove.new arg1, arg2

      when :shift
        Shift.new arg1, arg2

      else
        raise NotImplementedVerbError
      end
    end
  end
end
