module Advent
  class Transformer
    PATTERN = [0, 1, 0, -1].freeze

    def decode_cheat(input_signal)
      real_input = input_signal * 10000
      offset = input_signal[0..6].to_i
      seq = real_input.split('').map(&:to_i)
      100.times do
        seq = fft_cheat(seq, offset)
      end
      seq[offset..(offset + 7)].map(&:to_s).join
    end

    def fft(input_sequence)
      output_sequence = []
      input_sequence.each_index do |index|
        output_sequence[index] = compute_position(input_sequence, index)
      end
      output_sequence
    end

    def fft_cheat(input_sequence, offset)
      output_sequence = []
      (offset..(input_sequence.size - 1)).reverse_each do |index|
        output_sequence[index] = ((output_sequence[index + 1] || 0) + input_sequence[index]) % 10
      end
      output_sequence
    end

    def compute_position(input_sequence, position)
      applied_pattern = []
      PATTERN.each do |i|
        (position + 1).times { applied_pattern << i }
      end
      total = 0
      pattern_index = position + 1
      (position..(input_sequence.size - 1)).each do |index|
        input_value = input_sequence[index]
        total += input_value * applied_pattern[pattern_index]
        pattern_index = (pattern_index + 1) % applied_pattern.size
      end
      total.abs % 10
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry-byebug'
  include Advent
  transformer = Transformer.new
  input = File.open('input.txt').readlines.join
  seq = input.split('').map(&:to_i)
  100.times do
    seq = transformer.fft(seq)
  end
  puts seq[0..7].join

  # Even though the tests pass, this outputs the wrong answer
  puts transformer.decode_cheat(input)
end
