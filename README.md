# Portable Action Notation

A Ruby interface for data serialization in [PAN](https://developer.sashite.com/specs/portable-action-notation) format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sashite-pan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sashite-pan

## Usage

Working with PAN can be very simple, for example:

```ruby
require 'sashite/pan'

# Emit a PAN string

actions = [
  [52, 36, '♙', nil]
]

Sashite::PAN.dump(*actions) # => '52,36,♙'

# Parse a PAN string

Sashite::PAN.parse('52,36,♙') # => [[52, 36, '♙', nil]]
```

## Examples

```ruby
# Black castles on king-side

Sashite::PAN.dump([60, 62, '♔', nil], [63, 61, '♖', nil]) # => '60,62,♔;63,61,♖'
Sashite::PAN.parse('60,62,♔;63,61,♖') # => [[60, 62, '♔', nil], [63, 61, '♖', nil]]

# Promoting a chess pawn into a knight

Sashite::PAN.dump([12, 4, '♘', nil]) # => '12,4,♘'
Sashite::PAN.parse('12,4,♘') # => [[12, 4, '♘', nil]]

# Capturing a rook and promoting a shogi pawn

Sashite::PAN.dump([33, 24, '+P', 'R']) # => '33,24,+P,R'
Sashite::PAN.parse('33,24,+P,R') # => [[33, 24, '+P', 'R']]

# Dropping a shogi pawn

Sashite::PAN.dump([nil, 42, 'P', nil]) # => '*,42,P'
Sashite::PAN.parse('*,42,P') # => [[nil, 42, 'P', nil]]

# Capturing a white chess pawn en passant

Sashite::PAN.dump([33, 32, '♟', nil], [32, 40, '♟', nil]) # => '33,32,♟;32,40,♟'
Sashite::PAN.parse('33,32,♟;32,40,♟') # => [[33, 32, '♟', nil], [32, 40, '♟', nil]]
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

The `sashite-pan` gem is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
