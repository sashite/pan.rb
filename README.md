# Portable Action Notation

[![Version](https://img.shields.io/github/v/tag/sashite/pan.rb?label=Version&logo=github)](https://github.com/sashite/pan.rb/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pan.rb/main)
[![CI](https://github.com/sashite/pan.rb/workflows/CI/badge.svg?branch=main)](https://github.com/sashite/pan.rb/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/sashite/pan.rb/workflows/RuboCop/badge.svg?branch=main)](https://github.com/sashite/pan.rb/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/sashite/pan.rb?label=License&logo=github)](https://github.com/sashite/pan.rb/raw/main/LICENSE.md)

A Ruby interface for data serialization in [PAN](https://developer.sashite.com/specs/portable-action-notation) format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "sashite-pan"
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install sashite-pan
```

## Usage

Working with PAN can be very simple, for example:

```ruby
require "sashite/pan"

# Emit a PAN string

actions = [
  [52, 36, "♙"]
]

Sashite::PAN.dump(*actions) # => "52,36,♙"

# Parse a PAN string

Sashite::PAN.parse("52,36,♙") # => [[52, 36, "♙", nil]]
```

## Example

### Promoting a chess pawn into a knight

```ruby
Sashite::PAN.dump([12, 4, "♘"]) # => "12,4,♘"
Sashite::PAN.parse("12,4,♘") # => [[12, 4, "♘", nil]]
```

### Capturing a rook and promoting a shogi pawn

```ruby
Sashite::PAN.dump([33, 24, "+P", "R"]) # => "33,24,+P,R"
Sashite::PAN.parse("33,24,+P,R") # => [[33, 24, "+P", "R"]]
```

### Dropping a shogi pawn

```ruby
Sashite::PAN.dump([nil, 42, "P"]) # => "*,42,P"
Sashite::PAN.parse("*,42,P") # => [[nil, 42, "P", nil]]
```

***

In the context of a game with several possible actions per turn, like in
Western chess, more than one action could be consider like a move, and joined
thanks to the [`portable_move_notation`](https://rubygems.org/gems/portable_move_notation) gem.

### Black castles on king-side

```ruby
Sashite::PAN.dump([60, 62, "♔"], [63, 61, "♖"]) # => "60,62,♔;63,61,♖"
Sashite::PAN.parse("60,62,♔;63,61,♖") # => [[60, 62, "♔", nil], [63, 61, "♖", nil]]
```

### Capturing a white chess pawn en passant

```ruby
Sashite::PAN.dump([33, 32, "♟"], [32, 40, "♟"]) # => "33,32,♟;32,40,♟"
Sashite::PAN.parse("33,32,♟;32,40,♟") # => [[33, 32, "♟", nil], [32, 40, "♟", nil]]
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

This [gem](https://rubygems.org/gems/sashite-pan) is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
