# Pan.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pan.rb?label=Version&logo=github)](https://github.com/sashite/pan.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pan.rb/main)
![Ruby](https://github.com/sashite/pan.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pan.rb?label=License&logo=github)](https://github.com/sashite/pan.rb/raw/main/LICENSE.md)

> **PAN** (Portable Action Notation) support for the Ruby language.

## What is PAN?

PAN (Portable Action Notation) is a compact, string-based format for representing **executed moves** in abstract strategy board games played on coordinate-based boards. PAN provides a human-readable and space-efficient notation for expressing move actions in a rule-agnostic manner.

PAN focuses on representing the spatial aspects of moves: where pieces move from and to, and whether the move involves capture or placement. The notation is designed to be intuitive and compatible with standard algebraic coordinate systems.

This gem implements the [PAN Specification v1.0.0](https://sashite.dev/documents/pan/1.0.0/), providing a Ruby interface for:

- Parsing PAN strings into structured move data
- Validating PAN strings according to the specification
- Converting between PAN and other move representations

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

PAN uses three fundamental move types with intuitive operators:

### Simple Move (Non-capture)
```
<source>-<destination>
```
**Example**: `e2-e4` - Moves a piece from e2 to e4

### Capture Move
```
<source>x<destination>
```
**Example**: `e4xd5` - Moves a piece from e4 to d5, capturing the piece at d5

### Drop/Placement
```
*<destination>
```
**Example**: `*e4` - Places a piece at e4 from off-board (hand, reserve, etc.)

### Coordinate System

PAN uses algebraic coordinates consisting of:
- **File**: A single lowercase letter (`a-z`)
- **Rank**: A single digit (`0-9`)

Examples: `e4`, `a1`, `h8`, `d5`

## Basic Usage

### Parsing PAN Strings

Convert a PAN string into structured move data:

```ruby
require "sashite-pan"

# Simple move
result = Sashite::Pan.parse("e2-e4")
# => {type: :move, source: "e2", destination: "e4"}

# Capture
result = Sashite::Pan.parse("e4xd5")
# => {type: :capture, source: "e4", destination: "d5"}

# Drop from hand
result = Sashite::Pan.parse("*e4")
# => {type: :drop, destination: "e4"}
```

### Safe Parsing

Parse a PAN string without raising exceptions:

```ruby
require "sashite-pan"

# Valid PAN string
result = Sashite::Pan.safe_parse("e2-e4")
# => {type: :move, source: "e2", destination: "e4"}

# Invalid PAN string
result = Sashite::Pan.safe_parse("invalid")
# => nil
```

### Validation

Check if a string is valid PAN notation:

```ruby
require "sashite-pan"

Sashite::Pan.valid?("e2-e4")    # => true
Sashite::Pan.valid?("*e4")      # => true
Sashite::Pan.valid?("e4xd5")    # => true

Sashite::Pan.valid?("")         # => false
Sashite::Pan.valid?("e2-e2")    # => false (source equals destination)
Sashite::Pan.valid?("E2-e4")    # => false (uppercase file)
Sashite::Pan.valid?("e2 - e4")  # => false (spaces not allowed)
```

## Examples

### Chess Examples

```ruby
require "sashite-pan"

# Pawn advance
Sashite::Pan.parse("e2-e4")
# => {type: :move, source: "e2", destination: "e4"}

# Capture
Sashite::Pan.parse("exd5")
# => {type: :capture, source: "e4", destination: "d5"}

# Note: PAN cannot distinguish piece types or promotion choices
# These moves require game context for complete interpretation:
Sashite::Pan.parse("e7-e8")  # Could be pawn promotion to any piece
Sashite::Pan.parse("a1-a8")  # Could be rook, queen, or promoted piece
```

### Shogi Examples

```ruby
require "sashite-pan"

# Piece movement
Sashite::Pan.parse("g7-f7")
# => {type: :move, source: "g7", destination: "f7"}

# Drop from hand
Sashite::Pan.parse("*e5")
# => {type: :drop, destination: "e5"}

# Capture (captured piece goes to hand in Shogi)
Sashite::Pan.parse("h2xg2")
# => {type: :capture, source: "h2", destination: "g2"}

# Note: PAN cannot specify which piece type is being dropped
# or whether a piece is promoted
```

## Limitations and Context Dependency

**Important**: PAN is intentionally minimal and rule-agnostic. It has several important limitations:

### What PAN Cannot Represent

- **Piece types**: Cannot distinguish between different pieces making the same move
- **Promotion choices**: Cannot specify what piece a pawn promotes to
- **Game state**: No encoding of check, checkmate, or game conditions
- **Complex moves**: Castling requires external representation
- **Piece identity**: Multiple pieces of the same type making similar moves

### Examples of Ambiguity

```ruby
# These PAN strings are syntactically valid but may be ambiguous:

"e7-e8"    # Pawn promotion - but to what piece?
"*g4"      # Drop - but which piece from hand?
"a1-a8"    # Movement - but which piece type?
"e1-g1"    # Could be castling, but rook movement not shown
```

### When PAN is Insufficient

- Games where multiple pieces can make the same spatial move
- Games requiring promotion choice specification
- Analysis requiring piece type identification
- Self-contained game records without context

## Error Handling

The library provides detailed error messages for invalid input:

```ruby
require "sashite-pan"

begin
  Sashite::Pan.parse("e2-e2")  # Source equals destination
rescue Sashite::Pan::Parser::Error => e
  puts e.message  # => "Source and destination cannot be identical"
end

begin
  Sashite::Pan.parse("E2-e4")  # Invalid uppercase file
rescue Sashite::Pan::Parser::Error => e
  puts e.message  # => "Invalid PAN format: E2-e4"
end

begin
  Sashite::Pan.parse("")  # Empty string
rescue Sashite::Pan::Parser::Error => e
  puts e.message  # => "PAN string cannot be empty"
end
```

## Regular Expression Pattern

PAN strings can be validated using this pattern:

```ruby
PAN_PATTERN = /\A(\*|[a-z][0-9][-x])([a-z][0-9])\z/

def valid_pan?(string)
  return false unless string.match?(PAN_PATTERN)

  # Additional validation for source != destination
  if string.include?('-') || string.include?('x')
    source = string[0..1]
    destination = string[-2..-1]
    return source != destination
  end

  true
end
```

## Use Cases

### Optimal for PAN

- **Move logs**: Simple game records where context is available
- **User interfaces**: Command input for move entry
- **Network protocols**: Compact move transmission
- **Quick notation**: Manual notation for simple games

### Consider Alternatives When

- **Ambiguous games**: Multiple pieces can make the same spatial move
- **Complex promotions**: Games with multiple promotion choices
- **Analysis tools**: When piece identity is crucial
- **Self-contained records**: When context is not available

## Integration Considerations

When using PAN in your applications:

1. **Always pair with context**: Store board state alongside PAN moves
2. **Document assumptions**: Clearly specify how ambiguities are resolved
3. **Validate rigorously**: Check both syntax and semantic validity
4. **Handle edge cases**: Plan for promotion and drop ambiguities

## Properties of PAN

- **Rule-agnostic**: Does not encode piece types, legality, or game-specific conditions
- **Compact**: Minimal character overhead (3-5 characters per move)
- **Human-readable**: Intuitive algebraic notation
- **Space-efficient**: Excellent for large game databases
- **Context-dependent**: Requires external game state for complete interpretation

## Documentation

- [Official PAN Specification](https://sashite.dev/documents/pan/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/pan.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-pan) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
