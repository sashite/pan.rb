# Sashite::PAN

Ruby implementation of [PAN](http://sashite.wiki/Portable_Action_Notation) parser and emitter.

## Status

* [![Gem Version](https://badge.fury.io/rb/sashite-pan.svg)](//badge.fury.io/rb/sashite-pan)
* [![Build Status](https://secure.travis-ci.org/sashite/pan.rb.svg?branch=master)](//travis-ci.org/sashite/pan.rb?branch=master)
* [![Dependency Status](https://gemnasium.com/sashite/pan.rb.svg)](//gemnasium.com/sashite/pan.rb)

## Installation

Add this line to your application's Gemfile:

    gem 'sashite-pan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sashite-pan

## Example

    require 'sashite-pan'

    action = Sashite::PAN.load :shift, 42, 43
    action.src_square # => 42

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
