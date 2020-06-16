# frozen_string_literal: true

module Sashite
  # The PAN (Portable Action Notation) module
  module PAN
    def self.dump(*actions)
      Dumper.call(*actions)
    end

    def self.parse(pan_string)
      Parser.call(pan_string)
    end
  end
end

require_relative 'pan/dumper'
require_relative 'pan/parser'
