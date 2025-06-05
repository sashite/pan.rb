# frozen_string_literal: true

require "simplecov"
SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Pan
#
# Tests the Portable Action Notation (PAN) parser and dumper.
# PAN is a compact notation for representing executed moves in abstract strategy games.
# Supports simple moves (e2-e4), captures (e4xd5), and drops (*e4).

require_relative "lib/sashite-pan"

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
puts "Tests for Sashite::Pan"
puts

# =============================================================================
# Parser Tests
# =============================================================================

puts "Parser Tests:"

run_test("Parse simple move") do
  result = Sashite::Pan.parse("e2-e4")
  expected = { type: :move, source: "e2", destination: "e4" }

  raise "Wrong type" unless result[:type] == expected[:type]
  raise "Wrong source" unless result[:source] == expected[:source]
  raise "Wrong destination" unless result[:destination] == expected[:destination]
end

run_test("Parse capture move") do
  result = Sashite::Pan.parse("e4xd5")
  expected = { type: :capture, source: "e4", destination: "d5" }

  raise "Wrong type" unless result[:type] == expected[:type]
  raise "Wrong source" unless result[:source] == expected[:source]
  raise "Wrong destination" unless result[:destination] == expected[:destination]
end

run_test("Parse drop move") do
  result = Sashite::Pan.parse("*e4")
  expected = { type: :drop, destination: "e4" }

  raise "Wrong type" unless result[:type] == expected[:type]
  raise "Should not have source" if result.key?(:source)
  raise "Wrong destination" unless result[:destination] == expected[:destination]
end

run_test("Parse with different coordinates") do
  # Test various valid coordinates
  coordinates = %w[a1 z9 h8 a0 z0]

  coordinates.each do |coord|
    result = Sashite::Pan.parse("#{coord}-a2")
    raise "Failed to parse #{coord}" unless result[:source] == coord

    result = Sashite::Pan.parse("e2x#{coord}")
    raise "Failed to parse capture to #{coord}" unless result[:destination] == coord

    result = Sashite::Pan.parse("*#{coord}")
    raise "Failed to parse drop to #{coord}" unless result[:destination] == coord
  end
end

run_test("Reject nil input") do
  exception_raised = false
  begin
    Sashite::Pan.parse(nil)
  rescue Sashite::Pan::Parser::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "PAN string cannot be nil"
  end

  raise "Expected exception for nil input" unless exception_raised
end

run_test("Reject empty string") do
  exception_raised = false
  begin
    Sashite::Pan.parse("")
  rescue Sashite::Pan::Parser::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "PAN string cannot be empty"
  end

  raise "Expected exception for empty string" unless exception_raised
end

run_test("Reject non-string input") do
  exception_raised = false
  begin
    Sashite::Pan.parse(123)
  rescue Sashite::Pan::Parser::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "PAN string must be a String"
  end

  raise "Expected exception for non-string input" unless exception_raised
end

run_test("Reject identical source and destination") do
  exception_raised = false
  begin
    Sashite::Pan.parse("e4-e4")
  rescue Sashite::Pan::Parser::Error => e
    exception_raised = true
    expected_message = "Source and destination cannot be identical: e4"
    raise "Wrong error message: #{e.message}" unless e.message == expected_message
  end

  raise "Expected exception for identical coordinates" unless exception_raised
end

run_test("Reject invalid coordinate format") do
  invalid_formats = ["E2-e4", "e2-E4", "e10-e4", "e2-e", "ee-e4", "e2- e4", "e2--e4"]

  invalid_formats.each do |format|
    exception_raised = false
    begin
      Sashite::Pan.parse(format)
    rescue Sashite::Pan::Parser::Error
      exception_raised = true
    end

    raise "Should reject invalid format: #{format}" unless exception_raised
  end
end

run_test("Reject spaces in PAN string") do
  invalid_with_spaces = ["e2 - e4", "e4 x d5", "* e4", " e2-e4", "e2-e4 "]

  invalid_with_spaces.each do |format|
    exception_raised = false
    begin
      Sashite::Pan.parse(format)
    rescue Sashite::Pan::Parser::Error
      exception_raised = true
    end

    raise "Should reject format with spaces: #{format}" unless exception_raised
  end
end

# =============================================================================
# Dumper Tests
# =============================================================================

puts "Dumper Tests:"

run_test("Dump simple move") do
  move_data = { type: :move, source: "e2", destination: "e4" }
  result = Sashite::Pan.dump(move_data)
  expected = "e2-e4"

  raise "Wrong PAN string: #{result}" unless result == expected
end

run_test("Dump capture move") do
  move_data = { type: :capture, source: "e4", destination: "d5" }
  result = Sashite::Pan.dump(move_data)
  expected = "e4xd5"

  raise "Wrong PAN string: #{result}" unless result == expected
end

run_test("Dump drop move") do
  move_data = { type: :drop, destination: "e4" }
  result = Sashite::Pan.dump(move_data)
  expected = "*e4"

  raise "Wrong PAN string: #{result}" unless result == expected
end

run_test("Reject nil move data") do
  exception_raised = false
  begin
    Sashite::Pan.dump(nil)
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "Move data cannot be nil"
  end

  raise "Expected exception for nil move data" unless exception_raised
end

run_test("Reject non-hash move data") do
  exception_raised = false
  begin
    Sashite::Pan.dump("not a hash")
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "Move data must be a Hash"
  end

  raise "Expected exception for non-hash move data" unless exception_raised
end

run_test("Reject move data without type") do
  exception_raised = false
  begin
    Sashite::Pan.dump({ source: "e2", destination: "e4" })
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "Move data must have :type key"
  end

  raise "Expected exception for missing type" unless exception_raised
end

run_test("Reject move data without destination") do
  exception_raised = false
  begin
    Sashite::Pan.dump({ type: :move, source: "e2" })
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "Move data must have :destination key"
  end

  raise "Expected exception for missing destination" unless exception_raised
end

run_test("Reject move/capture without source") do
  exception_raised = false
  begin
    Sashite::Pan.dump({ type: :move, destination: "e4" })
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    expected = "Move and capture types must have :source key"
    raise "Wrong error message" unless e.message == expected
  end

  raise "Expected exception for missing source in move" unless exception_raised
end

run_test("Reject drop with source") do
  exception_raised = false
  begin
    Sashite::Pan.dump({ type: :drop, source: "e2", destination: "e4" })
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    raise "Wrong error message" unless e.message == "Drop type cannot have :source key"
  end

  raise "Expected exception for source in drop" unless exception_raised
end

run_test("Reject invalid coordinate format in dumper") do
  invalid_data = [
    { type: :move, source: "E2", destination: "e4" },
    { type: :move, source: "e2", destination: "E4" },
    { type: :move, source: "e10", destination: "e4" },
    { type: :drop, destination: "E4" }
  ]

  invalid_data.each do |data|
    exception_raised = false
    begin
      Sashite::Pan.dump(data)
    rescue Sashite::Pan::Dumper::Error
      exception_raised = true
    end

    raise "Should reject invalid coordinate in: #{data}" unless exception_raised
  end
end

run_test("Reject identical coordinates in dumper") do
  exception_raised = false
  begin
    Sashite::Pan.dump({ type: :move, source: "e4", destination: "e4" })
  rescue Sashite::Pan::Dumper::Error => e
    exception_raised = true
    expected = "Source and destination coordinates cannot be identical: e4"
    raise "Wrong error message" unless e.message == expected
  end

  raise "Expected exception for identical coordinates" unless exception_raised
end

# =============================================================================
# Round-trip Tests
# =============================================================================

puts "Round-trip Tests:"

run_test("Round-trip simple moves") do
  pan_strings = %w[e2-e4 a1-h8 d7-d8 h1-a8]

  pan_strings.each do |pan|
    move_data = Sashite::Pan.parse(pan)
    result = Sashite::Pan.dump(move_data)
    raise "Round-trip failed for #{pan}: got #{result}" unless result == pan
  end
end

run_test("Round-trip captures") do
  pan_strings = %w[e4xd5 a1xh8 d7xc8 h1xa8]

  pan_strings.each do |pan|
    move_data = Sashite::Pan.parse(pan)
    result = Sashite::Pan.dump(move_data)
    raise "Round-trip failed for #{pan}: got #{result}" unless result == pan
  end
end

run_test("Round-trip drops") do
  pan_strings = %w[*e4 *a1 *h8 *d5]

  pan_strings.each do |pan|
    move_data = Sashite::Pan.parse(pan)
    result = Sashite::Pan.dump(move_data)
    raise "Round-trip failed for #{pan}: got #{result}" unless result == pan
  end
end

# =============================================================================
# Validation Tests
# =============================================================================

puts "Validation Tests:"

run_test("Valid PAN strings") do
  valid_strings = %w[e2-e4 e4xd5 *e4 a1-h8 z9xz8 *a0]

  valid_strings.each do |pan|
    raise "Should be valid: #{pan}" unless Sashite::Pan.valid?(pan)
  end
end

run_test("Invalid PAN strings") do
  invalid_strings = ["", "e2-e2", "E2-e4", "e2 - e4", "invalid", "e2--e4", "*", "xe4"]

  invalid_strings.each do |pan|
    raise "Should be invalid: #{pan}" if Sashite::Pan.valid?(pan)
  end
end

run_test("Valid coordinate check") do
  valid_coords = %w[e4 a1 h8 z9 a0 z0]

  valid_coords.each do |coord|
    raise "Should be valid coordinate: #{coord}" unless Sashite::Pan.valid_coordinate?(coord)
  end
end

run_test("Invalid coordinate check") do
  invalid_coords = ["E4", "e10", "ee", "4e", "", "e", "4", "e4e", "E4"]

  invalid_coords.each do |coord|
    raise "Should be invalid coordinate: #{coord}" if Sashite::Pan.valid_coordinate?(coord)
  end
end

# =============================================================================
# Safe Methods Tests
# =============================================================================

puts "Safe Methods Tests:"

run_test("Safe parse valid input") do
  result = Sashite::Pan.safe_parse("e2-e4")
  expected = { type: :move, source: "e2", destination: "e4" }

  raise "Wrong result" unless result == expected
end

run_test("Safe parse invalid input") do
  result = Sashite::Pan.safe_parse("invalid")
  raise "Should return nil for invalid input" unless result.nil?
end

run_test("Safe dump valid input") do
  move_data = { type: :move, source: "e2", destination: "e4" }
  result = Sashite::Pan.safe_dump(move_data)

  raise "Wrong result" unless result == "e2-e4"
end

run_test("Safe dump invalid input") do
  result = Sashite::Pan.safe_dump({ invalid: :data })
  raise "Should return nil for invalid input" unless result.nil?
end

# =============================================================================
# Description Tests
# =============================================================================

puts "Description Tests:"

run_test("Describe simple move") do
  result = Sashite::Pan.describe("e2-e4")
  expected = "Move from e2 to e4"

  raise "Wrong description: #{result}" unless result == expected
end

run_test("Describe capture") do
  result = Sashite::Pan.describe("e4xd5")
  expected = "Capture from e4 to d5"

  raise "Wrong description: #{result}" unless result == expected
end

run_test("Describe drop") do
  result = Sashite::Pan.describe("*e4")
  expected = "Drop to e4"

  raise "Wrong description: #{result}" unless result == expected
end

run_test("Safe describe valid input") do
  result = Sashite::Pan.safe_describe("e2-e4")
  expected = "Move from e2 to e4"

  raise "Wrong description" unless result == expected
end

run_test("Safe describe invalid input") do
  result = Sashite::Pan.safe_describe("invalid")
  raise "Should return nil for invalid input" unless result.nil?
end

# =============================================================================
# Pattern Tests
# =============================================================================

puts "Pattern Tests:"

run_test("Pattern matches valid PAN strings") do
  pattern = Sashite::Pan.pattern
  valid_strings = %w[e2-e4 e4xd5 *e4]

  valid_strings.each do |pan|
    raise "Pattern should match: #{pan}" unless pattern.match?(pan)
  end
end

run_test("Pattern rejects invalid PAN strings") do
  pattern = Sashite::Pan.pattern
  invalid_strings = ["E2-e4", "e2 - e4", "invalid"]

  invalid_strings.each do |pan|
    raise "Pattern should not match: #{pan}" if pattern.match?(pan)
  end
end

# =============================================================================
# Edge Cases
# =============================================================================

puts "Edge Cases:"

run_test("Boundary coordinates") do
  # Test boundary cases for coordinate system
  boundary_cases = %w[a0-z9 z9xa0 *a0 *z9]

  boundary_cases.each do |pan|
    result = Sashite::Pan.parse(pan)
    back = Sashite::Pan.dump(result)
    raise "Boundary case failed: #{pan}" unless back == pan
  end
end

run_test("Chess-style examples") do
  chess_moves = %w[e2-e4 d2-d4 exd5 Nf3-g5 O-O]

  # Only the first three should be valid PAN
  raise "e2-e4 should be valid" unless Sashite::Pan.valid?("e2-e4")
  raise "d2-d4 should be valid" unless Sashite::Pan.valid?("d2-d4")
  # Note: "exd5" is invalid because it doesn't specify source coordinate
  raise "exd5 should be invalid" if Sashite::Pan.valid?("exd5")
  raise "Nf3-g5 should be invalid" if Sashite::Pan.valid?("Nf3-g5")
  raise "O-O should be invalid" if Sashite::Pan.valid?("O-O")
end

run_test("Shogi-style examples") do
  # Test drops and moves that might appear in Shogi
  shogi_moves = %w[*g4 g7-f7 h2xg2]

  shogi_moves.each do |pan|
    raise "#{pan} should be valid" unless Sashite::Pan.valid?(pan)
    result = Sashite::Pan.parse(pan)
    back = Sashite::Pan.dump(result)
    raise "Round-trip failed for #{pan}" unless back == pan
  end
end

puts
puts "All PAN tests passed!"
puts
