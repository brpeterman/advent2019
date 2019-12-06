require 'rspec'
require 'pry-byebug'
require_relative '../computer.rb'

include RSpec
include Advent

describe IntCodeComputer do
    let(:computer) { IntCodeComputer.new }

    describe 'day 2' do
        it 'handles example 1,0,0,0,99' do
            input = [1,0,0,0,99]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([2,0,0,0,99])
        end

        it 'handles example 2,3,0,3,99' do
            input = [2,3,0,3,99]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([2,3,0,6,99])
        end

        it 'handles example 2,4,4,5,99,0' do
            input = [2,4,4,5,99,0]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([2,4,4,5,99,9801])
        end

        it 'handles example 1,1,1,4,99,5,6,0,99' do
            input = [1,1,1,4,99,5,6,0,99]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([30,1,1,4,2,5,6,0,99])
        end
    end

    describe 'day 5' do
        it 'handles example 1002,4,3,4,33' do
            input = [1002,4,3,4,33]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([1002,4,3,4,99])
            expect(outputs).to be_empty
        end

        it 'handles example 1001,4,3,4,96' do
            input = [1001,4,3,4,96]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([1001,4,3,4,99])
            expect(outputs).to be_empty
        end

        it 'handles example 3,2,0' do
            input = [3,2,0]
            state, outputs = computer.execute(input, 99)
            expect(state).to eq([3,2,99])
            expect(outputs).to be_empty
        end

        it 'handles example 103,2,0' do
            input = [103,2,0]
            state, outputs = computer.execute(input, 99)
            expect(state).to eq([103,2,99])
            expect(outputs).to be_empty
        end

        it 'handles example 104,0,99' do
            input = [104,0,99]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([104,0,99])
            expect(outputs).to eq([0])
        end

        it 'handles example 4,0,99,0,11' do
            input = [4,0,99,0,11]
            state, outputs = computer.execute(input, nil)
            expect(state).to eq([4,0,99,0,11])
            expect(outputs).to eq([4])
        end

        it 'handles example 3,13,1,13,6,6,1100,1,14,13,104,0,99,0,1105' do
            input = [3,225,1,225,6,6,1100,1,238,225,104,0,99]
            input[238] = 1105
            state, outputs = computer.execute(input, 1)
            expect(outputs.first).to eq(0)
        end

        it 'handles example 3,9,8,9,10,9,4,9,99,-1,8 (equals, position mode)' do
            input = [3,9,8,9,10,9,4,9,99,-1,8]
            state, outputs = computer.execute(input, 8)
            expect(outputs.first).to eq(1)

            input = [3,9,8,9,10,9,4,9,99,-1,8]
            state, outputs = computer.execute(input, 7)
            expect(outputs.first).to eq(0)
        end

        it 'handles example 3,9,7,9,10,9,4,9,99,-1,8 (less than, position mode)' do
            input = [3,9,7,9,10,9,4,9,99,-1,8]
            state, outputs = computer.execute(input, 8)
            expect(outputs.first).to eq(0)

            input = [3,9,7,9,10,9,4,9,99,-1,8]
            state, outputs = computer.execute(input, 7)
            expect(outputs.first).to eq(1)
        end

        it 'handles example 3,3,1108,-1,8,3,4,3,99 (equals, immediate mode)' do
            input = [3,3,1108,-1,8,3,4,3,99]
            state, outputs = computer.execute(input, 8)
            expect(outputs.first).to eq(1)

            input = [3,3,1108,-1,8,3,4,3,99]
            state, outputs = computer.execute(input, 7)
            expect(outputs.first).to eq(0)
        end

        it 'handles example 3,3,1107,-1,8,3,4,3,99 (less than, immediate mode)' do
            input = [3,3,1107,-1,8,3,4,3,99]
            state, outputs = computer.execute(input, 8)
            expect(outputs.first).to eq(0)

            input = [3,3,1107,-1,8,3,4,3,99]
            state, outputs = computer.execute(input, 7)
            expect(outputs.first).to eq(1)
        end

        it 'handles example 3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9 (jump, position mode)' do
            input = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
            state, outputs = computer.execute(input, 0)
            expect(outputs.first).to eq(0)

            input = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
            state, outputs = computer.execute(input, 10)
            expect(outputs.first).to eq(1)
        end

        it 'handles example 3,3,1105,-1,9,1101,0,0,12,4,12,99,1 (jump, immediate mode)' do
            input = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
            state, outputs = computer.execute(input, 0)
            expect(outputs.first).to eq(0)

            input = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
            state, outputs = computer.execute(input, 10)
            expect(outputs.first).to eq(1)
        end

        it 'handles 8 comparison example' do
            input = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
            state, outputs = computer.execute(input, -10)
            expect(outputs.first).to eq(999)

            input = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
            state, outputs = computer.execute(input, 8)
            expect(outputs.first).to eq(1000)

            input = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
            state, outputs = computer.execute(input, 99)
            expect(outputs.first).to eq(1001)
        end
    end
end
