require 'rspec'
require 'pry'
require_relative '../computer.rb'

include RSpec
include Advent

describe IntCodeComputer do
    let(:computer) { IntCodeComputer.new }

    it 'handles example 1,0,0,0,99' do
        input = [1,0,0,0,99]
        expect(computer.execute(input)).to eq([2,0,0,0,99])
    end

    it 'handles example 2,3,0,3,99' do
        input = [2,3,0,3,99]
        expect(computer.execute(input)).to eq([2,3,0,6,99])
    end

    it 'handles example 2,4,4,5,99,0' do
        input = [2,4,4,5,99,0]
        expect(computer.execute(input)).to eq([2,4,4,5,99,9801])
    end

    it 'handles example 1,1,1,4,99,5,6,0,99' do
        input = [1,1,1,4,99,5,6,0,99]
        expect(computer.execute(input)).to eq([30,1,1,4,2,5,6,0,99])
    end
end
