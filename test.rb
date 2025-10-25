#!/usr/bin/env ruby
# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Pan (Portable Action Notation)
#
# Tests the PAN implementation for Ruby, covering validation,
# parsing, action creation, and type queries according to the
# PAN Specification v1.0.0.
#
# @see https://sashite.dev/specs/pan/1.0.0/ PAN Specification v1.0.0
#
# This test suite validates strict compliance with the official specification
# and includes all examples provided in the spec documentation.

require_relative "lib/sashite/pan"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Pan (Portable Action Notation)"
puts "Validating compliance with PAN Specification v1.0.0"
puts "Specification: https://sashite.dev/specs/pan/1.0.0/"
puts

# ============================================================================
# SPECIFICATION COMPLIANCE TESTS
# ============================================================================

run_test("All specification examples are valid") do
  # Examples directly from PAN Specification v1.0.0
  spec_examples = [
    "e2-e4",       # Move to empty square
    "d1+f3",       # Capture at destination
    "e1~g1",       # Castling (with side effects)
    "P*e5",        # Drop piece from reserve
    "e7-e8=Q",     # Move with promotion
    "...",         # Pass turn
    "e5~f6",       # En passant
    "*d4",         # Drop (piece inferred)
    "b7+a8=R",     # Capture with promotion
    "S*c3=+S",     # Drop with immediate promotion
    "L.b4",        # Drop with capture
    "+d4",         # Static capture
    "e4=+P"        # In-place transformation
  ]

  spec_examples.each do |pan|
    raise "Specification example '#{pan}' should be valid but was rejected" unless Sashite::Pan.valid?(pan)
  end
end

run_test("Operator semantics match specification") do
  operators = {
    "-" => "e2-e4",   # Move to empty square
    "+" => "d1+f3",   # Capture at destination
    "~" => "e1~g1",   # Special move with effects
    "*" => "P*e5",    # Drop to empty square
    "." => "L.b4",    # Drop with capture
    "=" => "e4=+P"    # Transform piece
  }

  operators.each do |operator, example|
    raise "Example with operator '#{operator}' should be valid: #{example}" unless Sashite::Pan.valid?(example)
  end

  # Pass is special (no traditional operator)
  raise "Pass notation '...' should be valid" unless Sashite::Pan.valid?("...")
end

# ============================================================================
# PASS ACTION TESTS
# ============================================================================

run_test("Pass action is valid and recognized") do
  raise "Pass notation '...' should be valid" unless Sashite::Pan.valid?("...")

  action = Sashite::Pan.parse("...")
  raise "Parsed action should be pass type" unless action.pass?
  raise "Pass action should return correct type symbol" unless action.type == :pass
  raise "Pass action should convert back to '...'" unless action.to_s == "..."
end

run_test("Pass action has no coordinates or pieces") do
  action = Sashite::Pan.parse("...")

  raise "Pass action should have no source" unless action.source.nil?
  raise "Pass action should have no destination" unless action.destination.nil?
  raise "Pass action should have no piece" unless action.piece.nil?
  raise "Pass action should have no transformation" unless action.transformation.nil?
end

run_test("Pass action factory method works") do
  action = Sashite::Pan::Action.pass

  raise "Factory should create pass action" unless action.pass?
  raise "Factory action should convert to '...'" unless action.to_s == "..."
end

run_test("Pass action type queries return correct values") do
  action = Sashite::Pan.parse("...")

  raise "pass? should return true" unless action.pass? == true
  raise "move? should return false" unless action.move? == false
  raise "capture? should return false" unless action.capture? == false
  raise "special? should return false" unless action.special? == false
  raise "static_capture? should return false" unless action.static_capture? == false
  raise "drop? should return false" unless action.drop? == false
  raise "drop_capture? should return false" unless action.drop_capture? == false
  raise "modify? should return false" unless action.modify? == false
  raise "movement? should return false" unless action.movement? == false
  raise "drop_action? should return false" unless action.drop_action? == false
end

run_test("Only valid pass notation is accepted") do
  invalid_pass = [".", "..", ".. .", " ...", "....", "pass", "PASS"]

  invalid_pass.each do |notation|
    raise "Invalid pass notation '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# MOVE ACTION TESTS
# ============================================================================

run_test("Move action notation is valid") do
  valid_moves = [
    "e2-e4",       # Simple move
    "a1-h8",       # Long diagonal
    "e7-e8=Q",     # Move with promotion
    "a7-a8=+R",    # Move with enhanced promotion
    "h2-h1=-P"     # Move with diminished state
  ]

  valid_moves.each do |move|
    raise "Valid move '#{move}' should be accepted" unless Sashite::Pan.valid?(move)
  end
end

run_test("Move action parses correctly") do
  action = Sashite::Pan.parse("e2-e4")

  raise "Parsed action should be move type" unless action.move?
  raise "Move should have correct source" unless action.source == "e2"
  raise "Move should have correct destination" unless action.destination == "e4"
  raise "Move should have no transformation" if action.transformation
  raise "Move should convert back correctly" unless action.to_s == "e2-e4"
end

run_test("Move with transformation parses correctly") do
  action = Sashite::Pan.parse("e7-e8=Q")

  raise "Should be move type" unless action.move?
  raise "Should have correct source" unless action.source == "e7"
  raise "Should have correct destination" unless action.destination == "e8"
  raise "Should have transformation" unless action.transformation == "Q"
  raise "Should convert back correctly" unless action.to_s == "e7-e8=Q"
end

run_test("Move factory method works") do
  action = Sashite::Pan::Action.move("e2", "e4")

  raise "Factory should create move action" unless action.move?
  raise "Factory move should have correct source" unless action.source == "e2"
  raise "Factory move should have correct destination" unless action.destination == "e4"
  raise "Factory move should convert correctly" unless action.to_s == "e2-e4"
end

run_test("Move factory with transformation works") do
  action = Sashite::Pan::Action.move("e7", "e8", transformation: "Q")

  raise "Should be move type" unless action.move?
  raise "Should have transformation" unless action.transformation == "Q"
  raise "Should convert correctly" unless action.to_s == "e7-e8=Q"
end

run_test("Move action type queries return correct values") do
  action = Sashite::Pan.parse("e2-e4")

  raise "pass? should return false" unless action.pass? == false
  raise "move? should return true" unless action.move? == true
  raise "capture? should return false" unless action.capture? == false
  raise "special? should return false" unless action.special? == false
  raise "movement? should return true" unless action.movement? == true
  raise "drop_action? should return false" unless action.drop_action? == false
end

run_test("Invalid move notation is rejected") do
  invalid_moves = [
    "e2e4",        # Missing operator
    "e2=e4",       # Wrong operator
    "e2+e4",       # Wrong operator (that's capture)
    "-e4",         # Missing source
    "e2-",         # Missing destination
    "e0-e4",       # Invalid CELL (zero)
    "e2-e8=",      # Missing transformation piece
    "e2-e8=QQ"     # Invalid EPIN
  ]

  invalid_moves.each do |notation|
    raise "Invalid move '#{notation}' should be rejected" if Sashite::Pan::Action::Move.valid?(notation)
  end
end

# ============================================================================
# CAPTURE ACTION TESTS
# ============================================================================

run_test("Capture action notation is valid") do
  valid_captures = [
    "d1+f3",       # Simple capture
    "a1+h8",       # Long diagonal capture
    "b7+a8=R",     # Capture with promotion
    "e5+d6=+P"     # Capture with enhanced promotion
  ]

  valid_captures.each do |capture|
    raise "Valid capture '#{capture}' should be accepted" unless Sashite::Pan.valid?(capture)
  end
end

run_test("Capture action parses correctly") do
  action = Sashite::Pan.parse("d1+f3")

  raise "Parsed action should be capture type" unless action.capture?
  raise "Capture should have correct source" unless action.source == "d1"
  raise "Capture should have correct destination" unless action.destination == "f3"
  raise "Capture should have no transformation" if action.transformation
  raise "Capture should convert back correctly" unless action.to_s == "d1+f3"
end

run_test("Capture with transformation parses correctly") do
  action = Sashite::Pan.parse("b7+a8=R")

  raise "Should be capture type" unless action.capture?
  raise "Should have correct source" unless action.source == "b7"
  raise "Should have correct destination" unless action.destination == "a8"
  raise "Should have transformation" unless action.transformation == "R"
  raise "Should convert back correctly" unless action.to_s == "b7+a8=R"
end

run_test("Capture factory method works") do
  action = Sashite::Pan::Action.capture("d1", "f3")

  raise "Factory should create capture action" unless action.capture?
  raise "Factory capture should have correct source" unless action.source == "d1"
  raise "Factory capture should have correct destination" unless action.destination == "f3"
  raise "Factory capture should convert correctly" unless action.to_s == "d1+f3"
end

run_test("Capture action type queries return correct values") do
  action = Sashite::Pan.parse("d1+f3")

  raise "pass? should return false" unless action.pass? == false
  raise "move? should return false" unless action.move? == false
  raise "capture? should return true" unless action.capture? == true
  raise "special? should return false" unless action.special? == false
  raise "movement? should return true" unless action.movement? == true
end

run_test("Invalid capture notation is rejected") do
  invalid_captures = [
    "d1f3",        # Missing operator
    "d1-f3",       # Wrong operator
    "+f3",         # Missing source (that's static capture)
    "d1+",         # Missing destination
    "d0+f3"        # Invalid CELL
  ]

  invalid_captures.each do |notation|
    # Note: "+f3" is valid as static capture, so we check it parses as static_capture
    if notation == "+f3"
      action = Sashite::Pan.parse(notation)
      raise "'+f3' should be static capture, not regular capture" if action.capture?
    else
      raise "Invalid capture '#{notation}' should be rejected" if Sashite::Pan::Action::Capture.valid?(notation)
    end
  end
end

# ============================================================================
# SPECIAL ACTION TESTS
# ============================================================================

run_test("Special action notation is valid") do
  valid_specials = [
    "e1~g1",       # Castling
    "e5~f6",       # En passant
    "a1~h8",       # Any special long move
    "e7~e8=Q"      # Special with transformation
  ]

  valid_specials.each do |special|
    raise "Valid special '#{special}' should be accepted" unless Sashite::Pan.valid?(special)
  end
end

run_test("Special action parses correctly") do
  action = Sashite::Pan.parse("e1~g1")

  raise "Parsed action should be special type" unless action.special?
  raise "Special should have correct source" unless action.source == "e1"
  raise "Special should have correct destination" unless action.destination == "g1"
  raise "Special should have no transformation" if action.transformation
  raise "Special should convert back correctly" unless action.to_s == "e1~g1"
end

run_test("Special factory method works") do
  action = Sashite::Pan::Action.special("e1", "g1")

  raise "Factory should create special action" unless action.special?
  raise "Factory special should convert correctly" unless action.to_s == "e1~g1"
end

run_test("Special action type queries return correct values") do
  action = Sashite::Pan.parse("e1~g1")

  raise "special? should return true" unless action.special? == true
  raise "move? should return false" unless action.move? == false
  raise "capture? should return false" unless action.capture? == false
  raise "movement? should return true" unless action.movement? == true
end

run_test("Invalid special notation is rejected") do
  invalid_specials = [
    "e1g1",        # Missing operator
    "~g1",         # Missing source
    "e1~"          # Missing destination
  ]

  invalid_specials.each do |notation|
    raise "Invalid special '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# STATIC CAPTURE TESTS
# ============================================================================

run_test("Static capture notation is valid") do
  valid_static = [
    "+d4",         # Simple static capture
    "+e5",         # Another position
    "+a1",         # Corner
    "+h8"          # Opposite corner
  ]

  valid_static.each do |capture|
    raise "Valid static capture '#{capture}' should be accepted" unless Sashite::Pan.valid?(capture)
  end
end

run_test("Static capture parses correctly") do
  action = Sashite::Pan.parse("+d4")

  raise "Parsed action should be static_capture type" unless action.static_capture?
  raise "Static capture should have correct destination" unless action.destination == "d4"
  raise "Static capture should have no source" if action.source
  raise "Static capture should have no piece" if action.piece
  raise "Static capture should have no transformation" if action.transformation
  raise "Static capture should convert back correctly" unless action.to_s == "+d4"
end

run_test("Static capture factory method works") do
  action = Sashite::Pan::Action.static_capture("d4")

  raise "Factory should create static_capture action" unless action.static_capture?
  raise "Factory static capture should convert correctly" unless action.to_s == "+d4"
end

run_test("Static capture type queries return correct values") do
  action = Sashite::Pan.parse("+d4")

  raise "static_capture? should return true" unless action.static_capture? == true
  raise "capture? should return false" unless action.capture? == false
  raise "move? should return false" unless action.move? == false
  raise "movement? should return false" unless action.movement? == false
end

run_test("Invalid static capture notation is rejected") do
  invalid_static = [
    "+",           # No square
    "+d0",         # Invalid CELL (zero)
    "d4",          # Missing operator
    "++d4"         # Double operator
  ]

  invalid_static.each do |notation|
    raise "Invalid static capture '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# DROP ACTION TESTS
# ============================================================================

run_test("Drop action notation is valid") do
  valid_drops = [
    "P*e5",        # Drop pawn
    "*d4",         # Drop (piece inferred)
    "S*c3=+S",     # Drop with immediate promotion
    "R*h8",        # Drop rook
    "L*a1=-L"      # Drop with diminished state
  ]

  valid_drops.each do |drop|
    raise "Valid drop '#{drop}' should be accepted" unless Sashite::Pan.valid?(drop)
  end
end

run_test("Drop action parses correctly") do
  action = Sashite::Pan.parse("P*e5")

  raise "Parsed action should be drop type" unless action.drop?
  raise "Drop should have correct destination" unless action.destination == "e5"
  raise "Drop should have correct piece" unless action.piece == "P"
  raise "Drop should have no source" if action.source
  raise "Drop should have no transformation" if action.transformation
  raise "Drop should convert back correctly" unless action.to_s == "P*e5"
end

run_test("Drop without piece identifier parses correctly") do
  action = Sashite::Pan.parse("*d4")

  raise "Should be drop type" unless action.drop?
  raise "Should have correct destination" unless action.destination == "d4"
  raise "Should have no piece identifier" if action.piece
  raise "Should convert back correctly" unless action.to_s == "*d4"
end

run_test("Drop with transformation parses correctly") do
  action = Sashite::Pan.parse("S*c3=+S")

  raise "Should be drop type" unless action.drop?
  raise "Should have correct destination" unless action.destination == "c3"
  raise "Should have correct piece" unless action.piece == "S"
  raise "Should have transformation" unless action.transformation == "+S"
  raise "Should convert back correctly" unless action.to_s == "S*c3=+S"
end

run_test("Drop factory method works") do
  action = Sashite::Pan::Action.drop("e5", piece: "P")

  raise "Factory should create drop action" unless action.drop?
  raise "Factory drop should have correct destination" unless action.destination == "e5"
  raise "Factory drop should have correct piece" unless action.piece == "P"
  raise "Factory drop should convert correctly" unless action.to_s == "P*e5"
end

run_test("Drop factory without piece works") do
  action = Sashite::Pan::Action.drop("d4")

  raise "Factory should create drop action" unless action.drop?
  raise "Factory drop should have no piece" if action.piece
  raise "Factory drop should convert correctly" unless action.to_s == "*d4"
end

run_test("Drop action type queries return correct values") do
  action = Sashite::Pan.parse("P*e5")

  raise "drop? should return true" unless action.drop? == true
  raise "drop_capture? should return false" unless action.drop_capture? == false
  raise "drop_action? should return true" unless action.drop_action? == true
  raise "move? should return false" unless action.move? == false
  raise "movement? should return false" unless action.movement? == false
end

run_test("Invalid drop notation is rejected") do
  invalid_drops = [
    "*",           # No destination
    "*d0",         # Invalid CELL (zero)
    "P*",          # Missing destination
    "PP*e5",       # Invalid EPIN
    "P*e5=",       # Missing transformation piece
    "P*e5=QQ"      # Invalid transformation EPIN
  ]

  invalid_drops.each do |notation|
    raise "Invalid drop '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# DROP CAPTURE TESTS
# ============================================================================

run_test("Drop capture notation is valid") do
  valid_drop_captures = [
    "L.b4",        # Drop lance with capture
    ".c3",         # Drop with capture (piece inferred)
    "P.e5=+P",     # Drop capture with transformation
    "R.h8"         # Drop rook with capture
  ]

  valid_drop_captures.each do |drop|
    raise "Valid drop capture '#{drop}' should be accepted" unless Sashite::Pan.valid?(drop)
  end
end

run_test("Drop capture parses correctly") do
  action = Sashite::Pan.parse("L.b4")

  raise "Parsed action should be drop_capture type" unless action.drop_capture?
  raise "Drop capture should have correct destination" unless action.destination == "b4"
  raise "Drop capture should have correct piece" unless action.piece == "L"
  raise "Drop capture should have no source" if action.source
  raise "Drop capture should convert back correctly" unless action.to_s == "L.b4"
end

run_test("Drop capture without piece parses correctly") do
  action = Sashite::Pan.parse(".c3")

  raise "Should be drop_capture type" unless action.drop_capture?
  raise "Should have correct destination" unless action.destination == "c3"
  raise "Should have no piece identifier" if action.piece
  raise "Should convert back correctly" unless action.to_s == ".c3"
end

run_test("Drop capture factory method works") do
  action = Sashite::Pan::Action.drop_capture("b4", piece: "L")

  raise "Factory should create drop_capture action" unless action.drop_capture?
  raise "Factory drop_capture should convert correctly" unless action.to_s == "L.b4"
end

run_test("Drop capture type queries return correct values") do
  action = Sashite::Pan.parse("L.b4")

  raise "drop_capture? should return true" unless action.drop_capture? == true
  raise "drop? should return false" unless action.drop? == false
  raise "drop_action? should return true" unless action.drop_action? == true
  raise "movement? should return false" unless action.movement? == false
end

run_test("Invalid drop capture notation is rejected") do
  invalid_drop_captures = [
    ".",           # No destination
    ".d0",         # Invalid CELL
    "LL.b4"        # Invalid EPIN
  ]

  invalid_drop_captures.each do |notation|
    raise "Invalid drop capture '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# MODIFY ACTION TESTS
# ============================================================================

run_test("Modify action notation is valid") do
  valid_modifies = [
    "e4=+P",       # Enhance piece at e4
    "c3=k'",       # Change style at c3
    "a1=-R",       # Diminish piece at a1
    "h8=Q"         # Change piece type
  ]

  valid_modifies.each do |modify|
    raise "Valid modify '#{modify}' should be accepted" unless Sashite::Pan.valid?(modify)
  end
end

run_test("Modify action parses correctly") do
  action = Sashite::Pan.parse("e4=+P")

  raise "Parsed action should be modify type" unless action.modify?
  raise "Modify should have correct destination" unless action.destination == "e4"
  raise "Modify should have correct piece" unless action.piece == "+P"
  raise "Modify should have no source" if action.source
  raise "Modify should have no transformation" if action.transformation
  raise "Modify should convert back correctly" unless action.to_s == "e4=+P"
end

run_test("Modify factory method works") do
  action = Sashite::Pan::Action.modify("e4", "+P")

  raise "Factory should create modify action" unless action.modify?
  raise "Factory modify should have correct destination" unless action.destination == "e4"
  raise "Factory modify should have correct piece" unless action.piece == "+P"
  raise "Factory modify should convert correctly" unless action.to_s == "e4=+P"
end

run_test("Modify action type queries return correct values") do
  action = Sashite::Pan.parse("e4=+P")

  raise "modify? should return true" unless action.modify? == true
  raise "move? should return false" unless action.move? == false
  raise "drop? should return false" unless action.drop? == false
  raise "movement? should return false" unless action.movement? == false
end

run_test("Invalid modify notation is rejected") do
  invalid_modifies = [
    "e4=",         # Missing piece
    "=+P",         # Missing square
    "e0=+P",       # Invalid CELL
    "e4=PP"        # Invalid EPIN
  ]

  invalid_modifies.each do |notation|
    raise "Invalid modify '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# ACTION TYPE DETECTION TESTS
# ============================================================================

run_test("Action type is correctly detected from notation") do
  type_cases = {
    "..." => :pass,
    "e2-e4" => :move,
    "d1+f3" => :capture,
    "e1~g1" => :special,
    "+d4" => :static_capture,
    "P*e5" => :drop,
    "L.b4" => :drop_capture,
    "e4=+P" => :modify
  }

  type_cases.each do |notation, expected_type|
    action = Sashite::Pan.parse(notation)
    actual_type = action.type
    raise "Action '#{notation}' should have type #{expected_type}, got #{actual_type}" unless actual_type == expected_type
  end
end

run_test("Movement actions are correctly identified") do
  movement_actions = ["e2-e4", "d1+f3", "e1~g1"]
  non_movement_actions = ["...", "+d4", "P*e5", "L.b4", "e4=+P"]

  movement_actions.each do |notation|
    action = Sashite::Pan.parse(notation)
    raise "Action '#{notation}' should be a movement action" unless action.movement?
  end

  non_movement_actions.each do |notation|
    action = Sashite::Pan.parse(notation)
    raise "Action '#{notation}' should not be a movement action" if action.movement?
  end
end

run_test("Drop actions are correctly identified") do
  drop_actions = ["P*e5", "L.b4", "*d4", ".c3"]
  non_drop_actions = ["e2-e4", "d1+f3", "...", "+d4", "e4=+P"]

  drop_actions.each do |notation|
    action = Sashite::Pan.parse(notation)
    raise "Action '#{notation}' should be a drop action" unless action.drop_action?
  end

  non_drop_actions.each do |notation|
    action = Sashite::Pan.parse(notation)
    raise "Action '#{notation}' should not be a drop action" if action.drop_action?
  end
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

run_test("Identical actions are equal") do
  pairs = [
    ["e2-e4", "e2-e4"],
    ["d1+f3", "d1+f3"],
    ["P*e5", "P*e5"],
    ["...", "..."],
    ["+d4", "+d4"]
  ]

  pairs.each do |notation1, notation2|
    action1 = Sashite::Pan.parse(notation1)
    action2 = Sashite::Pan.parse(notation2)
    raise "Actions '#{notation1}' and '#{notation2}' should be equal" unless action1 == action2
    raise "Actions should have same hash" unless action1.hash == action2.hash
  end
end

run_test("Different actions are not equal") do
  pairs = [
    ["e2-e4", "e2-e5"],
    ["d1+f3", "d1-f3"],
    ["P*e5", "R*e5"],
    ["...", "e2-e4"],
    ["+d4", "+e5"]
  ]

  pairs.each do |notation1, notation2|
    action1 = Sashite::Pan.parse(notation1)
    action2 = Sashite::Pan.parse(notation2)
    raise "Actions '#{notation1}' and '#{notation2}' should not be equal" if action1 == action2
  end
end

run_test("Factory-created and parsed actions are equal") do
  test_cases = [
    [Sashite::Pan::Action.move("e2", "e4"), "e2-e4"],
    [Sashite::Pan::Action.capture("d1", "f3"), "d1+f3"],
    [Sashite::Pan::Action.drop("e5", piece: "P"), "P*e5"],
    [Sashite::Pan::Action.pass, "..."]
  ]

  test_cases.each do |factory_action, notation|
    parsed_action = Sashite::Pan.parse(notation)
    raise "Factory action and parsed '#{notation}' should be equal" unless factory_action == parsed_action
  end
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

run_test("Parse and to_s round-trip correctly") do
  notations = [
    "e2-e4", "d1+f3", "e1~g1", "P*e5", "+d4",
    "L.b4", "e4=+P", "...", "e7-e8=Q", "b7+a8=R",
    "S*c3=+S", ".c3", "*d4"
  ]

  notations.each do |notation|
    action = Sashite::Pan.parse(notation)
    result = action.to_s
    raise "Round-trip failed for '#{notation}': got '#{result}'" unless result == notation
  end
end

run_test("Factory methods produce correct string output") do
  factory_cases = [
    [Sashite::Pan::Action.move("e2", "e4"), "e2-e4"],
    [Sashite::Pan::Action.move("e7", "e8", transformation: "Q"), "e7-e8=Q"],
    [Sashite::Pan::Action.capture("d1", "f3"), "d1+f3"],
    [Sashite::Pan::Action.capture("b7", "a8", transformation: "R"), "b7+a8=R"],
    [Sashite::Pan::Action.special("e1", "g1"), "e1~g1"],
    [Sashite::Pan::Action.static_capture("d4"), "+d4"],
    [Sashite::Pan::Action.drop("e5", piece: "P"), "P*e5"],
    [Sashite::Pan::Action.drop("d4"), "*d4"],
    [Sashite::Pan::Action.drop_capture("b4", piece: "L"), "L.b4"],
    [Sashite::Pan::Action.modify("e4", "+P"), "e4=+P"],
    [Sashite::Pan::Action.pass, "..."]
  ]

  factory_cases.each do |action, expected|
    result = action.to_s
    raise "Factory action should produce '#{expected}', got '#{result}'" unless result == expected
  end
end

# ============================================================================
# TRANSFORMATION TESTS
# ============================================================================

run_test("Actions with transformations parse correctly") do
  transformation_cases = [
    ["e7-e8=Q", :move, "Q"],
    ["b7+a8=R", :capture, "R"],
    ["a7-a8=+P", :move, "+P"],
    ["S*c3=+S", :drop, "+S"],
    ["P.e5=+P", :drop_capture, "+P"]
  ]

  transformation_cases.each do |notation, expected_type, expected_transform|
    action = Sashite::Pan.parse(notation)
    raise "Action '#{notation}' should have type #{expected_type}" unless action.type == expected_type
    raise "Action '#{notation}' should have transformation '#{expected_transform}'" unless action.transformation == expected_transform
  end
end

run_test("Actions without transformations have nil transformation") do
  no_transform_cases = ["e2-e4", "d1+f3", "P*e5", "+d4", "e4=+P"]

  # Note: modify actions have piece but no separate transformation
  no_transform_cases.each do |notation|
    action = Sashite::Pan.parse(notation)
    if action.modify?
      # Modify actions have piece but no transformation field
      raise "Modify action '#{notation}' should have no transformation" unless action.transformation.nil?
    else
      # Other actions should have nil transformation when not specified
      raise "Action '#{notation}' should have nil transformation unless it's a modify action" unless action.transformation.nil?
    end
  end
end

# ============================================================================
# INTEGRATION WITH CELL AND EPIN
# ============================================================================

run_test("PAN validates CELL coordinates in actions") do
  invalid_cell_actions = [
    "e0-e4",       # Zero in numeric dimension
    "1a-e4",       # Starts with numeric
    "A1-e4",       # Starts with uppercase
    "e2-e0",       # Invalid destination
    "P*e0",        # Invalid drop destination
    "+e0"          # Invalid static capture
  ]

  invalid_cell_actions.each do |notation|
    raise "Action with invalid CELL '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

run_test("PAN validates EPIN piece identifiers in actions") do
  invalid_epin_actions = [
    "P**e5",       # Invalid EPIN (double state modifier)
    "e7-e8=++Q",   # Invalid EPIN transformation
    "e4=PPP",      # Invalid EPIN in modify
    "QQ*e5"        # Invalid EPIN in drop
  ]

  invalid_epin_actions.each do |notation|
    raise "Action with invalid EPIN '#{notation}' should be rejected" if Sashite::Pan.valid?(notation)
  end
end

run_test("PAN accepts valid EPIN with state modifiers") do
  valid_epin_actions = [
    "e7-e8=+Q",    # Enhanced transformation
    "e7-e8=-Q",    # Diminished transformation
    "+P*e5",       # Enhanced drop
    "-R*h8",       # Diminished drop
    "e4=+P",       # Enhanced modify
    "c3=-N"        # Diminished modify
  ]

  valid_epin_actions.each do |notation|
    raise "Action with valid EPIN '#{notation}' should be accepted" unless Sashite::Pan.valid?(notation)
  end
end

run_test("PAN accepts valid EPIN with derivation markers") do
  valid_derivation_actions = [
    "e7-e8=K'",    # Foreign style transformation
    "P'*e5",       # Foreign style drop
    "e4=k'"        # Foreign style modify
  ]

  valid_derivation_actions.each do |notation|
    raise "Action with EPIN derivation '#{notation}' should be accepted" unless Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# EDGE CASES AND BOUNDARY CONDITIONS
# ============================================================================

run_test("Multi-dimensional CELL coordinates work in actions") do
  multi_dim_actions = [
    "a1A-b2B",     # 3D move
    "c3C+d4D",     # 3D capture
    "P*e5E",       # 3D drop
    "+f6F"         # 3D static capture
  ]

  multi_dim_actions.each do |notation|
    raise "Multi-dimensional action '#{notation}' should be valid" unless Sashite::Pan.valid?(notation)
    action = Sashite::Pan.parse(notation)
    raise "Multi-dimensional action should round-trip correctly" unless action.to_s == notation
  end
end

run_test("Extended alphabet CELL coordinates work in actions") do
  extended_actions = [
    "aa1-bb2",     # Extended alphabet move
    "zz26+aa1",    # Extended alphabet capture
    "P*abc123"     # Extended alphabet drop
  ]

  extended_actions.each do |notation|
    raise "Extended alphabet action '#{notation}' should be valid" unless Sashite::Pan.valid?(notation)
  end
end

run_test("Non-string input is handled gracefully") do
  non_strings = [nil, 123, :e2e4, [], {}]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Pan.valid?(input)

    begin
      Sashite::Pan.parse(input)
      raise "#{input.inspect} should raise ArgumentError when parsed"
    rescue ArgumentError
      # Expected
    end
  end
end

run_test("Empty and whitespace strings are rejected") do
  invalid_strings = ["", " ", "  ", "\t", "\n", "  e2-e4", "e2-e4  "]

  invalid_strings.each do |str|
    raise "String '#{str.inspect}' should be invalid" if Sashite::Pan.valid?(str)
  end
end

run_test("Actions are immutable") do
  action = Sashite::Pan.parse("e2-e4")

  raise "Action should be frozen" unless action.frozen?

  begin
    action.instance_variable_set(:@source, "e3")
    raise "Should not be able to modify frozen action"
  rescue RuntimeError, FrozenError
    # Expected - action is immutable
  end
end

# ============================================================================
# GAME SEQUENCE TESTS
# ============================================================================

run_test("Chess opening sequence parses correctly") do
  italian_game = [
    "e2-e4",   # White: King's pawn
    "e7-e5",   # Black: Mirror
    "g1-f3",   # White: Knight develops
    "b8-c6",   # Black: Knight defends
    "f1-c4",   # White: Bishop attacks f7
    "f8-c5"    # Black: Bishop creates symmetry
  ]

  italian_game.each do |move|
    raise "Italian Game move '#{move}' should be valid" unless Sashite::Pan.valid?(move)
    action = Sashite::Pan.parse(move)
    raise "Italian Game move should be move type" unless action.move?
  end
end

run_test("Mixed action sequence parses correctly") do
  mixed_sequence = [
    "e2-e4",       # Move
    "d7-d5",       # Move
    "e4+d5",       # Capture
    "d8+d5",       # Capture
    "b8-c6",       # Move
    "g1-f3",       # Move
    "c8-g4",       # Move
    "f1-e2"        # Move
  ]

  mixed_sequence.each do |notation|
    raise "Sequence action '#{notation}' should be valid" unless Sashite::Pan.valid?(notation)
    action = Sashite::Pan.parse(notation)
    raise "Sequence action should be movement type" unless action.movement?
  end
end

run_test("Shogi sequence with drops parses correctly") do
  shogi_sequence = [
    "i9-i8",       # Move
    "P*e5",        # Drop
    "e7-e6",       # Move
    "R*h8",        # Drop
    "g7-g6",       # Move
    "S*c3=+S"      # Drop with promotion
  ]

  shogi_sequence.each do |notation|
    raise "Shogi sequence action '#{notation}' should be valid" unless Sashite::Pan.valid?(notation)
  end
end

# ============================================================================
# API CONSISTENCY TESTS
# ============================================================================

run_test("API methods are stateless and consistent") do
  test_notation = "e2-e4"

  # Test that repeated calls give consistent results
  5.times do
    raise "valid? should be consistent" unless Sashite::Pan.valid?(test_notation) == true

    action = Sashite::Pan.parse(test_notation)
    raise "type should be consistent" unless action.type == :move
    raise "source should be consistent" unless action.source == "e2"
    raise "destination should be consistent" unless action.destination == "e4"
    raise "to_s should be consistent" unless action.to_s == "e2-e4"
  end
end

run_test("Factory methods are consistent with parsing") do
  test_cases = [
    ["e2-e4", -> { Sashite::Pan::Action.move("e2", "e4") }],
    ["d1+f3", -> { Sashite::Pan::Action.capture("d1", "f3") }],
    ["P*e5", -> { Sashite::Pan::Action.drop("e5", piece: "P") }]
  ]

  test_cases.each do |notation, factory|
    parsed = Sashite::Pan.parse(notation)
    created = factory.call

    raise "Factory and parsing should produce equal actions for '#{notation}'" unless parsed == created
    raise "Factory and parsing should produce same string for '#{notation}'" unless parsed.to_s == created.to_s
  end
end

# ============================================================================
# SPECIFICATION COMPLIANCE VERIFICATION
# ============================================================================

run_test("All specification constraints are enforced") do
  puts "\n    Verifying specification constraints..."

  # Operator-based syntax
  raise "Move operator - should be valid" unless Sashite::Pan.valid?("e2-e4")
  raise "Capture operator + should be valid" unless Sashite::Pan.valid?("d1+f3")
  raise "Special operator ~ should be valid" unless Sashite::Pan.valid?("e1~g1")
  raise "Drop operator * should be valid" unless Sashite::Pan.valid?("P*e5")
  raise "Drop capture operator . should be valid" unless Sashite::Pan.valid?("L.b4")
  raise "Modify operator = should be valid" unless Sashite::Pan.valid?("e4=+P")
  raise "Pass notation ... should be valid" unless Sashite::Pan.valid?("...")

  # Effect awareness
  move_action = Sashite::Pan.parse("e2-e4")
  special_action = Sashite::Pan.parse("e1~g1")
  raise "Move and special should have different types" unless move_action.type != special_action.type
  raise "Special action type should be :special" unless special_action.special?

  # Compact notation
  all_actions = ["e2-e4", "d1+f3", "P*e5", "...", "+d4", "L.b4", "e4=+P"]
  all_actions.each do |notation|
    raise "Action '#{notation}' should be compact" if notation.length > 20
  end

  # Game-agnostic
  chess_action = Sashite::Pan.parse("e2-e4")
  shogi_action = Sashite::Pan.parse("P*e5")
  raise "Both chess and shogi actions should be valid" unless chess_action && shogi_action

  # CELL integration
  cell_action = Sashite::Pan.parse("a1A-b2B")
  raise "Multi-dimensional CELL coordinates should work" unless cell_action.move?

  # EPIN integration
  epin_action = Sashite::Pan.parse("e7-e8=+Q")
  raise "EPIN with state modifier should work" unless epin_action.transformation == "+Q"

  puts "    ✓ All specification constraints verified"
end

puts
puts "All PAN tests passed!"
puts
