# frozen_string_literal: true

require 'rspec'
require 'pry-byebug'
require_relative '../computer.rb'

include RSpec
include Advent

describe IntCodeComputer do
  describe 'day 1' do
    it 'handles example 1,0,0,0,99' do
      program = [1, 0, 0, 0, 99]
      execution = IntCodeComputer::Execution.new(program)
      execution.execute_until_halt
      expect(execution.memory).to eq([2, 0, 0, 0, 99])
    end

    it 'handles example 2,3,0,3,99' do
      program = [2, 3, 0, 3, 99]
      execution = IntCodeComputer::Execution.new(program)
      execution.execute_until_halt
      expect(execution.memory).to eq([2, 3, 0, 6, 99])
    end

    it 'handles example 2,4,4,5,99,0' do
      program = [2, 4, 4, 5, 99, 0]
      execution = IntCodeComputer::Execution.new(program)
      execution.execute_until_halt
      expect(execution.memory).to eq([2, 4, 4, 5, 99, 9801])
    end

    it 'handles example 1,1,1,4,99,5,6,0,99' do
      program = [1, 1, 1, 4, 99, 5, 6, 0, 99]
      execution = IntCodeComputer::Execution.new(program)
      execution.execute_until_halt
      expect(execution.memory).to eq([30, 1, 1, 4, 2, 5, 6, 0, 99])
    end
  end

  describe 'day 5' do
    it 'handles example 1002,4,3,4,33' do
      program = [1002, 4, 3, 4, 33]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(execution.memory).to eq([1002, 4, 3, 4, 99])
      expect(outputs).to be_empty
    end

    it 'handles example 1001,4,3,4,96' do
      program = [1001, 4, 3, 4, 96]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(execution.memory).to eq([1001, 4, 3, 4, 99])
      expect(outputs).to be_empty
    end

    it 'handles example 3,2,0' do
      program = [3, 2, 0]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [99])
      expect(execution.memory).to eq([3, 2, 99])
      expect(outputs).to be_empty
    end

    it 'handles example 104,0,99' do
      program = [104, 0, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(execution.memory).to eq([104, 0, 99])
      expect(outputs).to eq([0])
    end

    it 'handles example 4,0,99,0,11' do
      program = [4, 0, 99, 0, 11]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(execution.memory).to eq([4, 0, 99, 0, 11])
      expect(outputs).to eq([4])
    end

    it 'handles example 3,13,1,13,6,6,1100,1,14,13,104,0,99,0,1105' do
      program = [3, 225, 1, 225, 6, 6, 1100, 1, 238, 225, 104, 0, 99]
      program[238] = 1105
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [1])
      expect(outputs.first).to eq(0)
    end

    it 'handles example 3,9,8,9,10,9,4,9,99,-1,8 (equals, position mode)' do
      program = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [8])
      expect(outputs.first).to eq(1)

      program = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [7])
      expect(outputs.first).to eq(0)
    end

    it 'handles example 3,9,7,9,10,9,4,9,99,-1,8 (less than, position mode)' do
      program = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [8])
      expect(outputs.first).to eq(0)

      program = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [7])
      expect(outputs.first).to eq(1)
    end

    it 'handles example 3,3,1108,-1,8,3,4,3,99 (equals, immediate mode)' do
      program = [3, 3, 1108, -1, 8, 3, 4, 3, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [8])
      expect(outputs.first).to eq(1)

      program = [3, 3, 1108, -1, 8, 3, 4, 3, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [7])
      expect(outputs.first).to eq(0)
    end

    it 'handles example 3,3,1107,-1,8,3,4,3,99 (less than, immediate mode)' do
      program = [3, 3, 1107, -1, 8, 3, 4, 3, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [8])
      expect(outputs.first).to eq(0)

      program = [3, 3, 1107, -1, 8, 3, 4, 3, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [7])
      expect(outputs.first).to eq(1)
    end

    it 'handles example 3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 (jump, position mode)' do
      program = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [0])
      expect(outputs.first).to eq(0)

      program = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [10])
      expect(outputs.first).to eq(1)
    end

    it 'handles example 3,3,1105,-1,9,1101,0,0,12,4,12,99,1 (jump, immediate mode)' do
      program = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [0])
      expect(outputs.first).to eq(0)

      program = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [10])
      expect(outputs.first).to eq(1)
    end

    it 'handles 8 comparison example' do
      program = [3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [-10])
      expect(outputs.first).to eq(999)

      program = [3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [8])
      expect(outputs.first).to eq(1000)

      program = [3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt(inputs: [99])
      expect(outputs.first).to eq(1001)
    end
  end

  describe 'day 9' do
    it 'handles example 1' do
      program = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(outputs).to eq(program)
    end

    it 'handles example 2' do
      program = [1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(outputs.first.to_s.length).to eq(16)
    end

    it 'handles example 3' do
      program = [104, 1_125_899_906_842_624, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(outputs.first).to eq(1_125_899_906_842_624)
    end
  end

  describe 'day 11' do
    it 'handles example 1' do
      program = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(outputs).to eq(program)
    end

    it 'handles example 2' do
      program = [1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(outputs.first.to_s.length).to eq(16)
    end

    it 'handles example 3' do
      program = [104, 1_125_899_906_842_624, 99]
      execution = IntCodeComputer::Execution.new(program)
      outputs = execution.execute_until_halt
      expect(outputs.first).to eq(1_125_899_906_842_624)
    end
  end
end
