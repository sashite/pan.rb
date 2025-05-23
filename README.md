# Pan.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pan.rb?label=Version&logo=github)](https://github.com/sashite/pan.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pan.rb/main)
![Ruby](https://github.com/sashite/pan.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pan.rb?label=License&logo=github)](https://github.com/sashite/pan.rb/raw/main/LICENSE.md)

> **PAN** (Portable Action Notation) support for the Ruby language.

## What is PAN?

PAN (Portable Action Notation) is a compact, string-based format for representing **executed moves** in abstract strategy board games. PAN serves as a human-readable and space-efficient alternative to PMN (Portable Move Notation), expressing the same semantic information in a condensed textual format.

While PMN uses JSON arrays to describe move sequences, PAN encodes the same information using a delimited string format that is easier to read, write, and transmit in contexts where JSON overhead is undesirable.

This gem implements the [PAN Specification v1.0.0](https://sashite.dev/documents/pan/1.0.0/), providing a Ruby interface for:

- Converting between PAN strings and PMN format
- Parsing PAN strings into structured move data
- Creating PAN strings from move components
- Validating PAN strings according to the specification

## Installation

```ruby
# In your Gemfile
gem "sashite-pan"
```

Or install manually:

```sh
gem install sashite-pan
```

## PAN Format

A PAN string represents one or more **actions** that constitute a complete move in a game. The format structure is:

### Single Action

```
<source>,<destination>,<piece>[,<hand_piece>]
```

### Multiple Actions

```
<action1>;<action2>[;<action3>...]
```

Where:

- **source**: Origin square label, or `*` for drops from hand
- **destination**: Target square label
- **piece**: Piece being moved (PNN format with optional modifiers)
- **hand_piece**: Optional piece added to mover's hand (captures, promotions)

## Basic Usage

### Parsing PAN Strings

Convert a PAN string into PMN format (array of action hashes):

```ruby
require "sashite-pan"

# Simple move
result = Sashite::Pan.parse("27,18,+P")
# => [{"src_square"=>"27", "dst_square"=>"18", "piece_name"=>"+P"}]

# Capture with hand piece
result = Sashite::Pan.parse("36,27,B,P")
# => [{"src_square"=>"36", "dst_square"=>"27", "piece_name"=>"B", "piece_hand"=>"P"}]

# Drop from hand
result = Sashite::Pan.parse("*,27,p")
# => [{"src_square"=>nil, "dst_square"=>"27", "piece_name"=>"p"}]

# Multiple actions (castling)
result = Sashite::Pan.parse("e1,g1,K;h1,f1,R")
# => [
#   {"src_square"=>"e1", "dst_square"=>"g1", "piece_name"=>"K"},
#   {"src_square"=>"h1", "dst_square"=>"f1", "piece_name"=>"R"}
# ]
```

### Safe Parsing

Parse a PAN string without raising exceptions:

```ruby
require "sashite-pan"

# Valid PAN string
result = Sashite::Pan.safe_parse("e2,e4,P'")
# => [{"src_square"=>"e2", "dst_square"=>"e4", "piece_name"=>"P'"}]

# Invalid PAN string
result = Sashite::Pan.safe_parse("invalid pan string")
# => nil
```

### Creating PAN Strings

Convert PMN actions (array of hashes) into a PAN string:

```ruby
require "sashite-pan"

# Simple move
pmn_actions = [{"src_square" => "27", "dst_square" => "18", "piece_name" => "+P"}]
pan_string = Sashite::Pan.dump(pmn_actions)
# => "27,18,+P"

# Capture with hand piece
pmn_actions = [{"src_square" => "36", "dst_square" => "27", "piece_name" => "B", "piece_hand" => "P"}]
pan_string = Sashite::Pan.dump(pmn_actions)
# => "36,27,B,P"

# Drop from hand
pmn_actions = [{"src_square" => nil, "dst_square" => "27", "piece_name" => "p"}]
pan_string = Sashite::Pan.dump(pmn_actions)
# => "*,27,p"

# Multiple actions (castling)
pmn_actions = [
  {"src_square" => "e1", "dst_square" => "g1", "piece_name" => "K"},
  {"src_square" => "h1", "dst_square" => "f1", "piece_name" => "R"}
]
pan_string = Sashite::Pan.dump(pmn_actions)
# => "e1,g1,K;h1,f1,R"
```

### Safe Dumping

Create PAN strings without raising exceptions:

```ruby
require "sashite-pan"

# Valid PMN data
pmn_actions = [{"src_square" => "e2", "dst_square" => "e4", "piece_name" => "P"}]
result = Sashite::Pan.safe_dump(pmn_actions)
# => "e2,e4,P"

# Invalid PMN data
invalid_data = [{"invalid" => "data"}]
result = Sashite::Pan.safe_dump(invalid_data)
# => nil
```

### Validation

Check if a string is valid PAN notation:

```ruby
require "sashite-pan"

Sashite::Pan.valid?("27,18,+P")           # => true
Sashite::Pan.valid?("*,27,p")             # => true
Sashite::Pan.valid?("e1,g1,K;h1,f1,R")   # => true

Sashite::Pan.valid?("")                   # => false
Sashite::Pan.valid?("invalid")            # => false
Sashite::Pan.valid?("27,18")              # => false (missing piece)
```

## Examples

### Shogi Examples

```ruby
require "sashite-pan"

# Pawn promotion
Sashite::Pan.parse("27,18,+P")
# => [{"src_square"=>"27", "dst_square"=>"18", "piece_name"=>"+P"}]

# Bishop captures promoted pawn
Sashite::Pan.parse("36,27,B,P")
# => [{"src_square"=>"36", "dst_square"=>"27", "piece_name"=>"B", "piece_hand"=>"P"}]

# Drop pawn from hand
Sashite::Pan.parse("*,27,p")
# => [{"src_square"=>nil, "dst_square"=>"27", "piece_name"=>"p"}]
```

### Chess Examples

```ruby
require "sashite-pan"

# Kingside castling
Sashite::Pan.parse("e1,g1,K;h1,f1,R")
# => [
#   {"src_square"=>"e1", "dst_square"=>"g1", "piece_name"=>"K"},
#   {"src_square"=>"h1", "dst_square"=>"f1", "piece_name"=>"R"}
# ]

# Pawn with state modifier (can be captured en passant)
Sashite::Pan.parse("e2,e4,P'")
# => [{"src_square"=>"e2", "dst_square"=>"e4", "piece_name"=>"P'"}]

# En passant capture (multi-step)
Sashite::Pan.parse("d4,e3,p;e3,e4,p")
# => [
#   {"src_square"=>"d4", "dst_square"=>"e3", "piece_name"=>"p"},
#   {"src_square"=>"e3", "dst_square"=>"e4", "piece_name"=>"p"}
# ]
```

## Integration with PMN

PAN is designed to work seamlessly with PMN (Portable Move Notation). You can easily convert between the two formats:

```ruby
require "sashite-pan"
require "portable_move_notation"

# Start with a PAN string
pan_string = "e2,e4,P';d7,d5,p"

# Convert to PMN format
pmn_actions = Sashite::Pan.parse(pan_string)
# => [
#   {"src_square"=>"e2", "dst_square"=>"e4", "piece_name"=>"P'"},
#   {"src_square"=>"d7", "dst_square"=>"d5", "piece_name"=>"p"}
# ]

# Use with PMN library
move = PortableMoveNotation::Move.new(*pmn_actions.map { |action|
  PortableMoveNotation::Action.new(**action.transform_keys(&:to_sym))
})

# Convert back to PAN
new_pan_string = Sashite::Pan.dump(pmn_actions)
# => "e2,e4,P';d7,d5,p"
```

## Use Cases

PAN is optimal for:

- **Move logging and game records**: Compact storage of game moves
- **Network transmission**: Efficient move data transmission
- **Command-line interfaces**: Human-readable move input/output
- **Quick manual entry**: Easy to type and edit move sequences
- **Storage optimization**: Space-efficient alternative to JSON

PMN is optimal for:

- **Programmatic analysis**: Complex move processing and validation
- **JSON-based systems**: Direct integration with JSON APIs
- **Structured data processing**: Schema validation and type checking

## Properties of PAN

- **Rule-agnostic**: PAN does not encode legality, validity, or game-specific conditions
- **Space-efficient**: Significantly more compact than equivalent JSON representation
- **Human-readable**: Easy to read, write, and understand
- **Lossless conversion**: Perfect bidirectional conversion with PMN format

## Error Handling

The library provides detailed error messages for invalid input:

```ruby
require "sashite-pan"

begin
  Sashite::Pan.parse("invalid,pan")  # Missing piece component
rescue Sashite::Pan::Parser::Error => e
  puts e.message  # => "Action must have at least 3 components (source, destination, piece)"
end

begin
  Sashite::Pan.dump([{"invalid" => "data"}])  # Missing required fields
rescue Sashite::Pan::Dumper::Error => e
  puts e.message  # => "Action must have dst_square"
end
```

## Documentation

- [Official PAN Specification](https://sashite.dev/documents/pan/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/pan.rb/main)
- [PMN Specification](https://sashite.dev/documents/pmn/1.0.0/)

## License

The [gem](https://rubygems.org/gems/sashite-pan) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
