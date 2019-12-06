module Advent
    class IntCodeComputer
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

        def execute(state, input_value)
            position = 0
            outputs = []
            while state[position] != 99 do
                opstring = state[position].to_s
                op = get_operation(opstring)
                case op
                when OPCODES[:add]
                    add(state, opstring, position)
                    position += 4
                when OPCODES[:multiply]
                    multiply(state, opstring, position)
                    position += 4
                when OPCODES[:input]
                    input(state, position, input_value)
                    position += 2
                when OPCODES[:output]
                    outputs << output(state, opstring, position)
                    position += 2
                when OPCODES[:jump_if_true]
                    position = jump_if_true(state, opstring, position)
                when OPCODES[:jump_if_false]
                    position = jump_if_false(state, opstring, position)
                when OPCODES[:less_than]
                    less_than(state, opstring, position)
                    position += 4
                when OPCODES[:equals]
                    equals(state, opstring, position)
                    position += 4
                else
                    raise Exception.new("Unrecognized opcode: #{op}")
                end
            end
            [state, outputs]
        end

        def get_operation(opstring)
            if (opstring.length == 1) then return opstring.to_i end
            opstring[-2..opstring.length-1].to_i
        end

        def resolve_operand(mode, value, state)
            if mode == '0'
                state[value]
            elsif mode == '1'
                value
            end
        end

        def add(state, opstring, code_position)
            padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
            op1 = resolve_operand(padded_op[2], state[code_position + 1], state)
            op2 = resolve_operand(padded_op[1], state[code_position + 2], state)
            output_position = state[code_position + 3]
            # binding.pry
            state[output_position] = op1 + op2
        end

        def multiply(state, opstring, code_position)
            padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
            op1 = resolve_operand(padded_op[2], state[code_position + 1], state)
            op2 = resolve_operand(padded_op[1], state[code_position + 2], state)
            output_position = state[code_position + 3]
            state[output_position] = op1 * op2
        end

        def input(state, code_position, input_value)
            output_position = state[code_position + 1]
            state[output_position] = input_value
        end

        def output(state, opstring, code_position)
            padded_op = "#{'0' * (3 - opstring.length)}#{opstring}"
            op1 = resolve_operand(padded_op[0], state[code_position + 1], state)
            op1
        end

        def jump_if_true(state, opstring, code_position)
            padded_op = "#{'0' * (4 - opstring.length)}#{opstring}"
            condition = resolve_operand(padded_op[1], state[code_position + 1], state)
            jump_to = resolve_operand(padded_op[0], state[code_position + 2], state)
            condition == 0 ? code_position + 3 : jump_to
        end

        def jump_if_false(state, opstring, code_position)
            padded_op = "#{'0' * (4 - opstring.length)}#{opstring}"
            condition = resolve_operand(padded_op[1], state[code_position + 1], state)
            jump_to = resolve_operand(padded_op[0], state[code_position + 2], state)
            condition != 0 ? code_position + 3 : jump_to
        end

        def less_than(state, opstring, code_position)
            padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
            op1 = resolve_operand(padded_op[2], state[code_position + 1], state)
            op2 = resolve_operand(padded_op[1], state[code_position + 2], state)
            output_position = state[code_position + 3]
            state[output_position] = op1 < op2 ? 1 : 0
        end

        def equals(state, opstring, code_position)
            padded_op = "#{'0' * (5 - opstring.length)}#{opstring}"
            op1 = resolve_operand(padded_op[2], state[code_position + 1], state)
            op2 = resolve_operand(padded_op[1], state[code_position + 2], state)
            output_position = state[code_position + 3]
            state[output_position] = op1 == op2 ? 1 : 0
        end
    end
end

if __FILE__ == $0
    require 'pry-byebug'
    computer = Advent::IntCodeComputer.new
    initial_state = [3,225,1,225,6,6,1100,1,238,225,104,0,1101,65,39,225,2,14,169,224,101,-2340,224,224,4,224,1002,223,8,223,101,7,224,224,1,224,223,223,1001,144,70,224,101,-96,224,224,4,224,1002,223,8,223,1001,224,2,224,1,223,224,223,1101,92,65,225,1102,42,8,225,1002,61,84,224,101,-7728,224,224,4,224,102,8,223,223,1001,224,5,224,1,223,224,223,1102,67,73,224,1001,224,-4891,224,4,224,102,8,223,223,101,4,224,224,1,224,223,223,1102,54,12,225,102,67,114,224,101,-804,224,224,4,224,102,8,223,223,1001,224,3,224,1,224,223,223,1101,19,79,225,1101,62,26,225,101,57,139,224,1001,224,-76,224,4,224,1002,223,8,223,1001,224,2,224,1,224,223,223,1102,60,47,225,1101,20,62,225,1101,47,44,224,1001,224,-91,224,4,224,1002,223,8,223,101,2,224,224,1,224,223,223,1,66,174,224,101,-70,224,224,4,224,102,8,223,223,1001,224,6,224,1,223,224,223,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,108,226,226,224,102,2,223,223,1005,224,329,101,1,223,223,1107,226,677,224,1002,223,2,223,1005,224,344,101,1,223,223,8,226,677,224,102,2,223,223,1006,224,359,101,1,223,223,108,677,677,224,1002,223,2,223,1005,224,374,1001,223,1,223,1108,226,677,224,1002,223,2,223,1005,224,389,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,404,1001,223,1,223,1108,677,677,224,102,2,223,223,1006,224,419,1001,223,1,223,1008,226,677,224,102,2,223,223,1005,224,434,101,1,223,223,107,677,677,224,102,2,223,223,1006,224,449,1001,223,1,223,1007,226,677,224,102,2,223,223,1005,224,464,101,1,223,223,7,677,226,224,102,2,223,223,1005,224,479,101,1,223,223,1007,226,226,224,102,2,223,223,1005,224,494,101,1,223,223,7,677,677,224,102,2,223,223,1006,224,509,101,1,223,223,1008,677,677,224,1002,223,2,223,1006,224,524,1001,223,1,223,108,226,677,224,1002,223,2,223,1006,224,539,101,1,223,223,8,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,8,677,226,224,102,2,223,223,1005,224,569,1001,223,1,223,1108,677,226,224,1002,223,2,223,1006,224,584,101,1,223,223,1107,677,226,224,1002,223,2,223,1005,224,599,101,1,223,223,107,226,226,224,102,2,223,223,1006,224,614,1001,223,1,223,7,226,677,224,102,2,223,223,1005,224,629,1001,223,1,223,107,677,226,224,1002,223,2,223,1005,224,644,1001,223,1,223,1107,677,677,224,102,2,223,223,1006,224,659,101,1,223,223,1008,226,226,224,1002,223,2,223,1006,224,674,1001,223,1,223,4,223,99,226]
    state, outputs = computer.execute(initial_state, 5)
    puts outputs.map(&:to_i).join(', ')
end
