# frozen_string_literal: true

require_relative 'lib/sashite-pan'

# King's Pawn opening at chess

raise unless Sashite::PAN.dump([52, 36, '♙', nil]) == '52,36,♙'
raise unless Sashite::PAN.parse('52,36,♙') == [[52, 36, '♙', nil]]

# Black castles on king-side

raise unless Sashite::PAN.dump([60, 62, '♔', nil], [63, 61, '♖', nil]) == '60,62,♔;63,61,♖'
raise unless Sashite::PAN.parse('60,62,♔;63,61,♖') == [[60, 62, '♔', nil], [63, 61, '♖', nil]]

# Promoting a chess pawn into a knight

raise unless Sashite::PAN.dump([12, 4, '♘', nil]) == '12,4,♘'
raise unless Sashite::PAN.parse('12,4,♘') == [[12, 4, '♘', nil]]

# Capturing a rook and promoting a shogi pawn

raise unless Sashite::PAN.dump([33, 24, '+P', 'R']) == '33,24,+P,R'
raise unless Sashite::PAN.parse('33,24,+P,R') == [[33, 24, '+P', 'R']]

# Dropping a shogi pawn

raise unless Sashite::PAN.dump([nil, 42, 'P', nil]) == '*,42,P'
raise unless Sashite::PAN.parse('*,42,P') == [[nil, 42, 'P', nil]]

# Capturing a white chess pawn en passant

raise unless Sashite::PAN.dump([33, 32, '♟', nil], [32, 40, '♟', nil]) == '33,32,♟;32,40,♟'
raise unless Sashite::PAN.parse('33,32,♟;32,40,♟') == [[33, 32, '♟', nil], [32, 40, '♟', nil]]
