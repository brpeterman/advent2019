module Advent
    module IntCodeComputer
        class Execution
            attr_accessor :position, :memory
            
            OPCODES = {
                add: 1,
                multiply: 2,
                input: 3,
                output: 4,
                jump_if_true: 5,
                jump_if_false: 6,
                less_than: 7,
                equals: 8
            }

            def initialize(memory, phase: nil)
                @position = 0
                @memory = memory
                if phase
                    @inputs = [phase]
                else
                    @inputs = []
                end
            end

            def execute(inputs)
                @inputs += inputs
                while @memory[@position] != 99 do
                    opstring = @memory[@position].to_s
                    op = get_operation(opstring)
                    case op
                    when OPCODES[:add]
                        add(opstring)
                        @position += 4
                    when OPCODES[:multiply]
                        multiply(opstring)
                        @position += 4
                    when OPCODES[:input]
                        input
                        @position += 2
                    when OPCODES[:output]
                        output = output(opstring)
                        @position += 2
                        return output
                    when OPCODES[:jump_if_true]
                        @position = jump_if_true(opstring)
                    when OPCODES[:jump_if_false]
                        @position = jump_if_false(opstring)
                    when OPCODES[:less_than]
                        less_than(opstring)
                        @position += 4
                    when OPCODES[:equals]
                        equals(opstring)
                        @position += 4
                    else
                        raise Exception.new("Unrecognized opcode: #{op}")
                    end
                end
                return nil
            end

            def get_operation(opstring)
                if (opstring.length == 1) then return opstring.to_i end
                opstring[-2..opstring.length-1].to_i
            end

            def resolve_operand(mode, value)
                if mode == '0'
                    @memory[value]
                elsif mode == '1'
                    value
                end
            end

            def add(opstring)
                padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
                op1 = resolve_operand(padded_op[2], @memory[@position + 1])
                op2 = resolve_operand(padded_op[1], @memory[@position + 2])
                output_position = @memory[@position + 3]
                @memory[output_position] = op1 + op2
            end

            def multiply(opstring)
                padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
                op1 = resolve_operand(padded_op[2], @memory[@position + 1])
                op2 = resolve_operand(padded_op[1], @memory[@position + 2])
                output_position = @memory[@position + 3]
                @memory[output_position] = op1 * op2
            end

            def input
                output_position = @memory[@position + 1]
                @memory[output_position] = @inputs.shift
            end

            def output(opstring)
                padded_op = "#{'0' * (3 - opstring.length)}#{opstring}"
                op1 = resolve_operand(padded_op[0], @memory[@position + 1])
                op1
            end

            def jump_if_true(opstring)
                padded_op = "#{'0' * (4 - opstring.length)}#{opstring}"
                condition = resolve_operand(padded_op[1], @memory[@position + 1])
                jump_to = resolve_operand(padded_op[0], @memory[@position + 2])
                condition == 0 ? @position + 3 : jump_to
            end

            def jump_if_false(opstringn)
                padded_op = "#{'0' * (4 - opstring.length)}#{opstring}"
                condition = resolve_operand(padded_op[1], @memory[@position + 1])
                jump_to = resolve_operand(padded_op[0], @memory[@position + 2])
                condition != 0 ? @position + 3 : jump_to
            end

            def less_than(opstring)
                padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
                op1 = resolve_operand(padded_op[2], @memory[@position + 1])
                op2 = resolve_operand(padded_op[1], @memory[@position + 2])
                output_position = @memory[@position + 3]
                @memory[output_position] = op1 < op2 ? 1 : 0
            end

            def equals(opstring)
                padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
                op1 = resolve_operand(padded_op[2], @memory[@position + 1])
                op2 = resolve_operand(padded_op[1], @memory[@position + 2])
                output_position = @memory[@position + 3]
                @memory[output_position] = op1 == op2 ? 1 : 0
            end
        end

        def self.maximize_amplifiers(phases, program)
            phases.permutation.to_a.reduce(0) do |maximum, configuration|
                input = 0
                next_input = 0
                index = 0
                amps = []
                configuration.length.times {|index| amps[index] = Execution.new(program.dup, phase: configuration[index])}
                while next_input != nil do
                    next_input = amps[index].execute([input])
                    if next_input != nil
                        input = next_input
                    end
                    index += 1
                    if index == configuration.length
                        index = 0
                    end
                end
                if input > maximum
                    maximum = input
                end
                maximum
            end
        end
    end
end

if __FILE__ == $0
    program = [3,8,1001,8,10,8,105,1,0,0,21,38,55,80,97,118,199,280,361,442,99999,3,9,101,2,9,9,1002,9,5,9,1001,9,4,9,4,9,99,3,9,101,5,9,9,102,2,9,9,1001,9,5,9,4,9,99,3,9,1001,9,4,9,102,5,9,9,101,4,9,9,102,4,9,9,1001,9,4,9,4,9,99,3,9,1001,9,3,9,1002,9,2,9,101,3,9,9,4,9,99,3,9,101,5,9,9,1002,9,2,9,101,3,9,9,1002,9,5,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,99]
    require 'pry-byebug'
    puts Advent::IntCodeComputer::maximize_amplifiers([5,6,7,8,9], program)
end
