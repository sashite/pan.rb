# Pan.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pan.rb?label=Version&logo=github)](https://github.com/sashite/pan.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pan.rb/main)
![Ruby](https://github.com/sashite/pan.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pan.rb?label=License&logo=github)](https://github.com/sashite/pan.rb/raw/main/LICENSE.md)

> **PAN** (Portable Action Notation) implementation for the Ruby language.

## What is PAN?

PAN (Portable Action Notation) is a human-readable string format for representing atomic actions in abstract strategy board games. PAN provides an intuitive operator-based syntax to describe how pieces move, capture, transform, and interact on game boards.

This gem implements the [PAN Specification v1.0.0](https://sashite.dev/specs/pan/1.0.0/), providing a pure functional Ruby interface with immutable action objects.

## Installation

```ruby
# In your Gemfile
gem "sashite-pan"
```

Or install manually:

```sh
gem install sashite-pan
```

## Quick Start

```ruby
require "sashite/pan"

# Validate PAN strings
Sashite::Pan.valid?("e2-e4")      # => true
Sashite::Pan.valid?("d1+f3")      # => true
Sashite::Pan.valid?("...")        # => true
Sashite::Pan.valid?("invalid")    # => false

# Parse PAN strings into action objects
action = Sashite::Pan.parse("e2-e4")
action.type          # => :move
action.source        # => "e2"
action.destination   # => "e4"
action.to_s          # => "e2-e4"

# Create actions programmatically
action = Sashite::Pan::Action.move("e2", "e4")
action.to_s          # => "e2-e4"

promotion = Sashite::Pan::Action.move("e7", "e8", transformation: "Q")
promotion.to_s       # => "e7-e8=Q"

capture = Sashite::Pan::Action.capture("d1", "f3")
capture.to_s         # => "d1+f3"

# Drop actions (shogi-style)
drop = Sashite::Pan::Action.drop("e5", piece: "P")
drop.to_s            # => "P*e5"

# Pass action
pass = Sashite::Pan::Action.pass
pass.to_s            # => "..."

# Query action properties
action.move?         # => true
action.pass?         # => false
capture.capture?     # => true
```

## Format Overview

PAN uses six intuitive operators:

| Operator | Meaning | Example |
|----------|---------|---------|
| `-` | Move to empty square | `e2-e4` |
| `+` | Capture at destination | `d1+f3` |
| `~` | Special move with side effects | `e1~g1` (castling) |
| `*` | Drop to empty square | `P*e5` |
| `.` | Drop with capture | `L.b4` |
| `=` | Transform piece | `e4=+P` |
| `...` | Pass turn | `...` |

For complete format details, see the [PAN Specification](https://sashite.dev/specs/pan/1.0.0/).

## API Reference

### Module Methods

#### Validation

```ruby
Sashite::Pan.valid?(pan_string)
```

Check if a string represents a valid PAN action.

**Parameters:**
- `pan_string` [String] - The string to validate

**Returns:** [Boolean] - true if valid PAN, false otherwise

**Examples:**
```ruby
Sashite::Pan.valid?("e2-e4")       # => true
Sashite::Pan.valid?("P*d4")        # => true
Sashite::Pan.valid?("...")         # => true
Sashite::Pan.valid?("invalid")     # => false
```

#### Parsing

```ruby
Sashite::Pan.parse(pan_string)
```

Parse a PAN string into an Action object.

**Parameters:**
- `pan_string` [String] - PAN notation string

**Returns:** [Pan::Action] - Immutable action object

**Raises:** [ArgumentError] - If the PAN string is invalid

**Examples:**
```ruby
Sashite::Pan.parse("e2-e4")        # => #<Pan::Action type=:move ...>
Sashite::Pan.parse("d1+f3")        # => #<Pan::Action type=:capture ...>
Sashite::Pan.parse("...")          # => #<Pan::Action type=:pass>
```

### Action Class

#### Creation Methods

All creation methods return immutable Action objects.

##### Pass Action

```ruby
Sashite::Pan::Action.pass
```

Create a pass action (no move, turn ends).

**Returns:** [Action] - Pass action

**Example:**
```ruby
action = Sashite::Pan::Action.pass
action.to_s  # => "..."
```

##### Movement Actions

```ruby
Sashite::Pan::Action.move(source, destination, transformation: nil)
```

Create a move action to an empty square.

**Parameters:**
- `source` [String] - Source CELL coordinate
- `destination` [String] - Destination CELL coordinate
- `transformation` [String, nil] - Optional EPIN transformation

**Returns:** [Action] - Move action

**Examples:**
```ruby
Sashite::Pan::Action.move("e2", "e4")
# => "e2-e4"

Sashite::Pan::Action.move("e7", "e8", transformation: "Q")
# => "e7-e8=Q"

Sashite::Pan::Action.move("a7", "a8", transformation: "+R")
# => "a7-a8=+R"
```

---

```ruby
Sashite::Pan::Action.capture(source, destination, transformation: nil)
```

Create a capture action at destination.

**Parameters:**
- `source` [String] - Source CELL coordinate
- `destination` [String] - Destination CELL coordinate (occupied square)
- `transformation` [String, nil] - Optional EPIN transformation

**Returns:** [Action] - Capture action

**Examples:**
```ruby
Sashite::Pan::Action.capture("d1", "f3")
# => "d1+f3"

Sashite::Pan::Action.capture("b7", "a8", transformation: "R")
# => "b7+a8=R"
```

---

```ruby
Sashite::Pan::Action.special(source, destination, transformation: nil)
```

Create a special move action with implicit side effects.

**Parameters:**
- `source` [String] - Source CELL coordinate
- `destination` [String] - Destination CELL coordinate
- `transformation` [String, nil] - Optional EPIN transformation

**Returns:** [Action] - Special action

**Examples:**
```ruby
Sashite::Pan::Action.special("e1", "g1")
# => "e1~g1" (castling)

Sashite::Pan::Action.special("e5", "f6")
# => "e5~f6" (en passant)
```

##### Static Capture

```ruby
Sashite::Pan::Action.static_capture(square)
```

Create a static capture action (remove piece without movement).

**Parameters:**
- `square` [String] - CELL coordinate of piece to capture

**Returns:** [Action] - Static capture action

**Example:**
```ruby
Sashite::Pan::Action.static_capture("d4")
# => "+d4"
```

##### Drop Actions

```ruby
Sashite::Pan::Action.drop(destination, piece: nil, transformation: nil)
```

Create a drop action to empty square.

**Parameters:**
- `destination` [String] - Destination CELL coordinate (empty square)
- `piece` [String, nil] - Optional EPIN piece identifier
- `transformation` [String, nil] - Optional EPIN transformation

**Returns:** [Action] - Drop action

**Examples:**
```ruby
Sashite::Pan::Action.drop("e5", piece: "P")
# => "P*e5"

Sashite::Pan::Action.drop("d4")
# => "*d4" (piece type inferred from context)

Sashite::Pan::Action.drop("c3", piece: "S", transformation: "+S")
# => "S*c3=+S"
```

---

```ruby
Sashite::Pan::Action.drop_capture(destination, piece: nil, transformation: nil)
```

Create a drop action with capture.

**Parameters:**
- `destination` [String] - Destination CELL coordinate (occupied square)
- `piece` [String, nil] - Optional EPIN piece identifier
- `transformation` [String, nil] - Optional EPIN transformation

**Returns:** [Action] - Drop capture action

**Example:**
```ruby
Sashite::Pan::Action.drop_capture("b4", piece: "L")
# => "L.b4"
```

##### Modification Action

```ruby
Sashite::Pan::Action.modify(square, piece)
```

Create an in-place transformation action.

**Parameters:**
- `square` [String] - CELL coordinate
- `piece` [String] - EPIN piece identifier (final state)

**Returns:** [Action] - Modification action

**Examples:**
```ruby
Sashite::Pan::Action.modify("e4", "+P")
# => "e4=+P"

Sashite::Pan::Action.modify("c3", "k'")
# => "c3=k'"
```

#### Instance Methods

##### Attribute Access

```ruby
action.type
```

Get the action type.

**Returns:** [Symbol] - One of: `:pass`, `:move`, `:capture`, `:special`, `:static_capture`, `:drop`, `:drop_capture`, `:modify`

---

```ruby
action.source
```

Get the source coordinate (for movement actions).

**Returns:** [String, nil] - CELL coordinate or nil

---

```ruby
action.destination
```

Get the destination coordinate.

**Returns:** [String, nil] - CELL coordinate or nil

---

```ruby
action.piece
```

Get the piece identifier (for drop/modify actions).

**Returns:** [String, nil] - EPIN identifier or nil

---

```ruby
action.transformation
```

Get the transformation piece (for actions with `=<piece>`).

**Returns:** [String, nil] - EPIN identifier or nil

---

```ruby
action.to_s
```

Convert action to PAN string representation.

**Returns:** [String] - PAN notation

**Examples:**
```ruby
Sashite::Pan::Action.move("e2", "e4").to_s
# => "e2-e4"

Sashite::Pan::Action.drop("e5", piece: "P").to_s
# => "P*e5"
```

##### Type Queries

```ruby
action.pass?
action.move?
action.capture?
action.special?
action.static_capture?
action.drop?
action.drop_capture?
action.modify?
action.movement?        # true for move, capture, or special
action.drop_action?     # true for drop or drop_capture
```

Check action type.

**Returns:** [Boolean]

**Examples:**
```ruby
action = Sashite::Pan.parse("e2-e4")
action.move?       # => true
action.movement?   # => true
action.pass?       # => false

pass = Sashite::Pan::Action.pass
pass.pass?         # => true

drop = Sashite::Pan.parse("P*e5")
drop.drop?         # => true
drop.drop_action?  # => true
```

##### Comparison

```ruby
action == other
```

Check equality between actions.

**Parameters:**
- `other` [Action] - Action to compare with

**Returns:** [Boolean] - true if actions are identical

**Example:**
```ruby
action1 = Sashite::Pan.parse("e2-e4")
action2 = Sashite::Pan::Action.move("e2", "e4")
action1 == action2  # => true
```

## Advanced Usage

### Parsing Game Sequences

```ruby
# Parse a sequence of moves
moves = %w[e2-e4 e7-e5 g1-f3 b8-c6]
actions = moves.map { |move| Sashite::Pan.parse(move) }

# Analyze action types
actions.count(&:move?)     # => 4
actions.all?(&:movement?)  # => true

# Extract coordinates
sources = actions.map(&:source)
destinations = actions.map(&:destination)
```

### Action Type Detection

```ruby
def describe_action(pan_string)
  action = Sashite::Pan.parse(pan_string)

  case action.type
  when :pass
    "Player passes"
  when :move
    "Move from #{action.source} to #{action.destination}"
  when :capture
    "Capture at #{action.destination}"
  when :special
    "Special move: #{action.source} to #{action.destination}"
  when :drop
    piece_str = action.piece ? "#{action.piece} " : ""
    "Drop #{piece_str}at #{action.destination}"
  when :modify
    "Transform piece at #{action.square} to #{action.piece}"
  end
end

describe_action("e2-e4")   # => "Move from e2 to e4"
describe_action("d1+f3")   # => "Capture at f3"
describe_action("P*e5")    # => "Drop P at e5"
describe_action("...")     # => "Player passes"
```

### Transformation Detection

```ruby
def has_promotion?(pan_string)
  action = Sashite::Pan.parse(pan_string)
  !action.transformation.nil?
end

has_promotion?("e2-e4")      # => false
has_promotion?("e7-e8=Q")    # => true
has_promotion?("P*e5")       # => false
has_promotion?("S*c3=+S")    # => true
```

### Building Move Generators

```ruby
class MoveBuilder
  def initialize(source)
    @source = source
  end

  def to(destination)
    Sashite::Pan::Action.move(@source, destination)
  end

  def captures(destination)
    Sashite::Pan::Action.capture(@source, destination)
  end

  def to_promoting(destination, piece)
    Sashite::Pan::Action.move(@source, destination, transformation: piece)
  end
end

# Usage
builder = MoveBuilder.new("e7")
builder.to("e8").to_s                    # => "e7-e8"
builder.to_promoting("e8", "Q").to_s     # => "e7-e8=Q"
builder.captures("d8").to_s              # => "e7+d8"
```

### Validation Before Parsing

```ruby
def safe_parse(pan_string)
  return nil unless Sashite::Pan.valid?(pan_string)

  Sashite::Pan.parse(pan_string)
rescue ArgumentError
  nil
end

safe_parse("e2-e4")      # => #<Pan::Action ...>
safe_parse("invalid")    # => nil
```

### Pattern Matching (Ruby 3.0+)

```ruby
def analyze(action)
  case action
  in { type: :move, source:, destination:, transformation: nil }
    "Simple move: #{source} → #{destination}"
  in { type: :move, transformation: piece }
    "Promotion to #{piece}"
  in { type: :capture, source:, destination: }
    "Capture: #{source} takes #{destination}"
  in { type: :drop, piece:, destination: }
    "Drop #{piece} at #{destination}"
  in { type: :pass }
    "Pass"
  else
    "Other action"
  end
end

action = Sashite::Pan.parse("e7-e8=Q")
analyze(action)  # => "Promotion to Q"
```

## Properties

* **Operator-based**: Intuitive symbols for different action types
* **Compact notation**: Minimal character usage while maintaining readability
* **Game-agnostic**: Works across chess, shōgi, xiangqi, and other abstract strategy games
* **CELL integration**: Uses CELL coordinates for board positions
* **EPIN integration**: Uses EPIN identifiers for piece representation
* **Immutable**: All action objects are frozen
* **Functional**: Pure functions with no side effects
* **Type-safe**: Strong validation and error handling

## Related Specifications

- [PAN Specification v1.0.0](https://sashite.dev/specs/pan/1.0.0/) - Complete format specification
- [PAN Examples](https://sashite.dev/specs/pan/1.0.0/examples/) - Usage examples across different games
- [CELL](https://sashite.dev/specs/cell/) - Coordinate encoding for board positions
- [EPIN](https://sashite.dev/specs/epin/) - Extended piece identifiers
- [Game Protocol](https://sashite.dev/protocol/) - Conceptual foundation

## Documentation

- [Official PAN Specification v1.0.0](https://sashite.dev/specs/pan/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/pan.rb/main)
- [PAN Examples](https://sashite.dev/specs/pan/1.0.0/examples/)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/pan.rb.git
cd pan.rb

# Install dependencies
bundle install

# Run tests
ruby test.rb

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`ruby test.rb`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) – promoting chess variants and sharing the beauty of board game cultures.
