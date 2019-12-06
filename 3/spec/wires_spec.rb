require 'rspec'
require 'pry'
require_relative '../wires.rb'

include RSpec
include Advent

describe Wires do
    let(:wires) { Wires.new }

    it 'handles example 1' do
        wire1 = 'R8,U5,L5,D3'
        wire2 = 'U7,R6,D4,L4'
        intersection = wires.intersection(wire1, wire2)
        expect(intersection[:x].abs + intersection[:y].abs).to eq(6)
    end

    it 'handles example 2' do
        wire1 = 'R75,D30,R83,U83,L12,D49,R71,U7,L72'
        wire2 = 'U62,R66,U55,R34,D71,R55,D58,R83'
        intersection = wires.intersection(wire1, wire2)
        expect(intersection[:x].abs + intersection[:y].abs).to eq(159)
    end

    it 'handles example 3' do
        wire1 = 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51'
        wire2 = 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7'
        intersection = wires.intersection(wire1, wire2)
        expect(intersection[:x].abs + intersection[:y].abs).to eq(135)
    end

    it 'handles example 4' do
        wire1 = 'R75,D30,R83,U83,L12,D49,R71,U7,L72'
        wire2 = 'U62,R66,U55,R34,D71,R55,D58,R83'
        steps = wires.steps_to_intersect(wire1, wire2)
        expect(steps).to eq(610)
    end

    it 'handles example 5' do
        wire1 = 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51'
        wire2 = 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7'
        steps = wires.steps_to_intersect(wire1, wire2)
        expect(steps).to eq(410)
    end
end
