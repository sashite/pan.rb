# frozen_string_literal: true

require "minitest/autorun"
require_relative "lib/sashite/pan"

class TestSashitePan < Minitest::Test
  def test_parse_simple_move
    pan = "27,18,+P"
    expected = [
      {
        "src_square" => "27",
        "dst_square" => "18",
        "piece_name" => "+P"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan)
  end

  def test_parse_capture_with_hand_piece
    pan = "36,27,B,P"
    expected = [
      {
        "src_square" => "36",
        "dst_square" => "27",
        "piece_name" => "B",
        "piece_hand" => "P"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan)
  end

  def test_parse_drop_from_hand
    pan = "*,27,p"
    expected = [
      {
        "dst_square" => "27",
        "piece_name" => "p"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan)
  end

  def test_parse_castling
    pan = "e1,g1,K;h1,f1,R"
    expected = [
      {
        "src_square" => "e1",
        "dst_square" => "g1",
        "piece_name" => "K"
      },
      {
        "src_square" => "h1",
        "dst_square" => "f1",
        "piece_name" => "R"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan)
  end

  def test_parse_complex_multi_action
    pan = "e1,g1,K;h1,f1,R;a1,a1,R"
    expected = [
      {
        "src_square" => "e1",
        "dst_square" => "g1",
        "piece_name" => "K"
      },
      {
        "src_square" => "h1",
        "dst_square" => "f1",
        "piece_name" => "R"
      },
      {
        "src_square" => "a1",
        "dst_square" => "a1",
        "piece_name" => "R"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan)
  end

  def test_parse_piece_with_state_modifier
    pan = "e2,e4,P'"
    expected = [
      {
        "src_square" => "e2",
        "dst_square" => "e4",
        "piece_name" => "P'"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan)
  end

  def test_dump_simple_move
    pmn = [
      {
        "src_square" => "27",
        "dst_square" => "18",
        "piece_name" => "+P"
      }
    ]

    assert_equal "27,18,+P", Sashite::Pan.dump(pmn)
  end

  def test_dump_capture_with_hand_piece
    pmn = [
      {
        "src_square" => "36",
        "dst_square" => "27",
        "piece_name" => "B",
        "piece_hand" => "P"
      }
    ]

    assert_equal "36,27,B,P", Sashite::Pan.dump(pmn)
  end

  def test_dump_drop_from_hand
    pmn = [
      {
        "src_square" => nil,
        "dst_square" => "27",
        "piece_name" => "p"
      }
    ]

    assert_equal "*,27,p", Sashite::Pan.dump(pmn)
  end

  def test_dump_castling
    pmn = [
      {
        "src_square" => "e1",
        "dst_square" => "g1",
        "piece_name" => "K"
      },
      {
        "src_square" => "h1",
        "dst_square" => "f1",
        "piece_name" => "R"
      }
    ]

    assert_equal "e1,g1,K;h1,f1,R", Sashite::Pan.dump(pmn)
  end

  def test_roundtrip_conversion
    original_pan = "e1,g1,K;h1,f1,R;a1,a1,R"
    pmn = Sashite::Pan.parse(original_pan)
    reconstructed_pan = Sashite::Pan.dump(pmn)

    assert_equal original_pan, reconstructed_pan
  end

  def test_valid_pan_strings
    assert Sashite::Pan.valid?("27,18,+P")
    assert Sashite::Pan.valid?("36,27,B,P")
    assert Sashite::Pan.valid?("*,27,p")
    assert Sashite::Pan.valid?("e1,g1,K;h1,f1,R")
    assert Sashite::Pan.valid?("e2,e4,P'")
  end

  def test_invalid_pan_strings
    refute Sashite::Pan.valid?("")
    refute Sashite::Pan.valid?("27,18")  # Missing piece
    refute Sashite::Pan.valid?("27,18,+P,X,Y")  # Too many components
    refute Sashite::Pan.valid?("27,,+P")  # Empty destination
    refute Sashite::Pan.valid?("27,18,++P")  # Invalid piece identifier
    refute Sashite::Pan.valid?("27,18,P''")  # Invalid piece identifier
  end

  def test_safe_parse_valid
    pan = "27,18,+P"
    expected = [
      {
        "src_square" => "27",
        "dst_square" => "18",
        "piece_name" => "+P"
      }
    ]

    assert_equal expected, Sashite::Pan.safe_parse(pan)
  end

  def test_safe_parse_invalid
    assert_nil Sashite::Pan.safe_parse("")
    assert_nil Sashite::Pan.safe_parse("invalid")
    assert_nil Sashite::Pan.safe_parse("27,18")
  end

  def test_safe_dump_valid
    pmn = [
      {
        "src_square" => "27",
        "dst_square" => "18",
        "piece_name" => "+P"
      }
    ]

    assert_equal "27,18,+P", Sashite::Pan.safe_dump(pmn)
  end

  def test_safe_dump_invalid
    assert_nil Sashite::Pan.safe_dump(nil)
    assert_nil Sashite::Pan.safe_dump([])
    assert_nil Sashite::Pan.safe_dump([{ "invalid" => "action" }])
  end

  def test_parse_errors
    assert_raises(Sashite::Pan::Parser::Error) { Sashite::Pan.parse(nil) }
    assert_raises(Sashite::Pan::Parser::Error) { Sashite::Pan.parse("") }
    assert_raises(Sashite::Pan::Parser::Error) { Sashite::Pan.parse("27,18") }
    assert_raises(Sashite::Pan::Parser::Error) { Sashite::Pan.parse("27,,+P") }
    assert_raises(Sashite::Pan::Parser::Error) { Sashite::Pan.parse("27,18,++P") }
  end

  def test_dump_errors
    assert_raises(Sashite::Pan::Dumper::Error) { Sashite::Pan.dump(nil) }
    assert_raises(Sashite::Pan::Dumper::Error) { Sashite::Pan.dump([]) }
    assert_raises(Sashite::Pan::Dumper::Error) { Sashite::Pan.dump("not an array") }
    assert_raises(Sashite::Pan::Dumper::Error) { Sashite::Pan.dump([{ "invalid" => "action" }]) }
  end

  def test_piece_identifier_validation
    # Valid piece identifiers
    assert Sashite::Pan.valid?("a1,b2,K")
    assert Sashite::Pan.valid?("a1,b2,+K")
    assert Sashite::Pan.valid?("a1,b2,-K")
    assert Sashite::Pan.valid?("a1,b2,K'")
    assert Sashite::Pan.valid?("a1,b2,+K'")
    assert Sashite::Pan.valid?("a1,b2,-K'")
    assert Sashite::Pan.valid?("a1,b2,k")
    assert Sashite::Pan.valid?("a1,b2,+k")
    assert Sashite::Pan.valid?("a1,b2,-k")
    assert Sashite::Pan.valid?("a1,b2,k'")
    assert Sashite::Pan.valid?("a1,b2,+k'")
    assert Sashite::Pan.valid?("a1,b2,-k'")

    # Invalid piece identifiers
    refute Sashite::Pan.valid?("a1,b2,KK")
    refute Sashite::Pan.valid?("a1,b2,++K")
    refute Sashite::Pan.valid?("a1,b2,--K")
    refute Sashite::Pan.valid?("a1,b2,K''")
    refute Sashite::Pan.valid?("a1,b2,+-K")
    refute Sashite::Pan.valid?("a1,b2,K1")
    refute Sashite::Pan.valid?("a1,b2,1K")
  end

  def test_whitespace_handling
    # Parser should handle whitespace around components
    pan_with_spaces = " 27 , 18 , +P "
    expected = [
      {
        "src_square" => "27",
        "dst_square" => "18",
        "piece_name" => "+P"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan_with_spaces)

    # And around semicolons
    pan_with_spaces = "e1,g1,K ; h1,f1,R"
    expected = [
      {
        "src_square" => "e1",
        "dst_square" => "g1",
        "piece_name" => "K"
      },
      {
        "src_square" => "h1",
        "dst_square" => "f1",
        "piece_name" => "R"
      }
    ]

    assert_equal expected, Sashite::Pan.parse(pan_with_spaces)
  end
end
