# frozen_string_literal: true

require 'rspec'
require 'pry-byebug'
require_relative '../computer.rb'

include RSpec
include Advent

describe IntCodeComputer do
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
