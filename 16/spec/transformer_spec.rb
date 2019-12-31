require 'rspec'
require 'pry-byebug'
require_relative '../transformer.rb'

include RSpec
include Advent

describe Transformer do
  let(:transformer) { Transformer.new }

  it 'handles example 1' do
    input = '12345678'
    seq = input.split('').map(&:to_i)
    seq = transformer.fft(seq)
    expect(seq).to eq([4, 8, 2, 2, 6, 1, 5, 8])
  end

  it 'handles example 2' do
    input = '80871224585914546619083218645595'
    seq = input.split('').map(&:to_i)
    100.times do
      seq = transformer.fft(seq)
    end
    first8 = seq[0..7].map(&:to_s).join
    expect(first8).to eq('24176176')
  end

  it 'handles example 3' do
    input = '19617804207202209144916044189917'
    seq = input.split('').map(&:to_i)
    100.times do
      seq = transformer.fft(seq)
    end
    first8 = seq[0..7].map(&:to_s).join
    expect(first8).to eq('73745418')
  end

  it 'handles example 4' do
    input = '69317163492948606335995924319873'
    seq = input.split('').map(&:to_i)
    100.times do
      seq = transformer.fft(seq)
    end
    first8 = seq[0..7].map(&:to_s).join
    expect(first8).to eq('52432133')
  end

  it 'cheats correctly' do
    input = '12345678'
    seq = input.split('').map(&:to_i)
    seq = transformer.fft_cheat(seq, 4)
    expect(seq[4..7]).to eq([6, 1, 5, 8])

    seq = transformer.fft_cheat(seq, 4)
    expect(seq[4..7]).to eq([0, 4, 3, 8])

    seq = transformer.fft_cheat(seq, 4)
    expect(seq[4..7]).to eq([5, 5, 1, 8])

    seq = transformer.fft_cheat(seq, 4)
    expect(seq[4..7]).to eq([9, 4, 9, 8])
  end

  it 'handles cheat example 1' do
    input = '03036732577212944063491565474664'
    message = transformer.decode_cheat(input)
    expect(message).to eq('84462026')
  end

  it 'handles cheat example 2' do
    input = '02935109699940807407585447034323'
    message = transformer.decode_cheat(input)
    expect(message).to eq('78725270')
  end

  it 'handles cheat example 3' do
    input = '03081770884921959731165446850517'
    message = transformer.decode_cheat(input)
    expect(message).to eq('53553731')
  end
end
