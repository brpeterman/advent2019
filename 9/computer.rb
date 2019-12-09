module Advent
    module IntCodeComputer
        class Execution
            OPCODES = {
                add: 1,
                multiply: 2,
                input: 3,
                output: 4,
                jump_if_true: 5,
                jump_if_false: 6,
                less_than: 7,
                equals: 8,
                relative_base_offset: 9
            }

            MODES = {
                positional: 0,
                immediate: 1,
                relative: 2
            }

            def initialize(initial_memory, phase: nil)
                @position = 0
                @relative_base = 0
                @memory = initial_memory.dup
                if phase
                    @inputs = [phase]
                else
                    @inputs = []
                end
            end

            def execute(inputs: [])
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
                        input(opstring)
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
                    when OPCODES[:relative_base_offset]
                        relative_base_offset(opstring)
                        @position += 2
                    else
                        raise Exception.new("Unrecognized opcode: #{op}")
                    end
                end
                return nil
            end

            def execute_until_halt(inputs: [])
                outputs = []
                current_output = 0
                while current_output != nil
                    current_output = execute(inputs: inputs)
                    if current_output != nil
                        outputs << current_output
                    end
                end
                outputs
            end

            def get_operation(opstring)
                if (opstring.length == 1) then return opstring.to_i end
                opstring[-2..opstring.length-1].to_i
            end

            def resolve_operand(mode, value)
                case mode.to_i
                when MODES[:positional]
                    read_addr(value)
                when MODES[:immediate]
                    value
                when MODES[:relative]
                    read_addr(@relative_base + value)
                end
            end

            def resolve_output_position(mode, position)
                case mode.to_i
                when MODES[:positional]
                    read_addr(position)
                when MODES[:relative]
                    @relative_base + read_addr(position)
                else
                    raise Exception.new("Got a nonsense mode for output: #{mode}")
                end
            end

            def read_addr(addr)
                @memory[addr] || 0
            end

            def pad_op(length, opstring)
                "#{'0' * (length - opstring.length)}#{opstring}"
            end

            def add(opstring)
                padded_op = pad_op(5, opstring)
                op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
                op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
                output_position = resolve_output_position(padded_op[0], @position + 3)
                @memory[output_position] = op1 + op2
            end

            def multiply(opstring)
                padded_op = pad_op(5, opstring)
                op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
                op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
                output_position = resolve_output_position(padded_op[0], @position + 3)
                @memory[output_position] = op1 * op2
            end

            def input(opstring)
                padded_op = pad_op(3, opstring)
                output_position = resolve_output_position(padded_op[0], @position + 1)
                @memory[output_position] = @inputs.shift
            end

            def output(opstring)
                padded_op = pad_op(3, opstring)
                op1 = resolve_operand(padded_op[0], read_addr(@position + 1))
                op1
            end

            def jump_if_true(opstring)
                padded_op = pad_op(4, opstring)
                condition = resolve_operand(padded_op[1], read_addr(@position + 1))
                jump_to = resolve_operand(padded_op[0], read_addr(@position + 2))
                condition == 0 ? @position + 3 : jump_to
            end

            def jump_if_false(opstring)
                padded_op = pad_op(4, opstring)
                condition = resolve_operand(padded_op[1], read_addr(@position + 1))
                jump_to = resolve_operand(padded_op[0], read_addr(@position + 2))
                condition != 0 ? @position + 3 : jump_to
            end

            def less_than(opstring)
                padded_op = pad_op(5, opstring)
                op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
                op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
                output_position = resolve_output_position(padded_op[0], @position + 3)
                @memory[output_position] = op1 < op2 ? 1 : 0
            end

            def equals(opstring)
                padded_op = pad_op(5, opstring)
                op1 = resolve_operand(padded_op[2],read_addr(@position + 1))
                op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
                output_position = resolve_output_position(padded_op[0], @position + 3)
                @memory[output_position] = op1 == op2 ? 1 : 0
            end

            def relative_base_offset(opstring)
                padded_op = pad_op(3, opstring)
                offset = resolve_operand(padded_op[0], read_addr(@position + 1))
                @relative_base += offset
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
    program = [1102,34463338,34463338,63,1007,63,34463338,63,1005,63,53,1102,1,3,1000,109,988,209,12,9,1000,209,6,209,3,203,0,1008,1000,1,63,1005,63,65,1008,1000,2,63,1005,63,904,1008,1000,0,63,1005,63,58,4,25,104,0,99,4,0,104,0,99,4,17,104,0,99,0,0,1101,36,0,1004,1102,28,1,1003,1101,0,0,1020,1102,22,1,1016,1101,21,0,1015,1102,897,1,1028,1101,0,815,1022,1101,554,0,1027,1101,0,38,1005,1102,33,1,1008,1101,0,23,1018,1101,826,0,1025,1101,0,30,1013,1102,31,1,1017,1102,35,1,1010,1102,1,34,1007,1102,1,892,1029,1101,0,808,1023,1102,29,1,1014,1102,1,1,1021,1101,0,39,1002,1101,0,561,1026,1102,1,27,1009,1102,20,1,1019,1102,37,1,1011,1101,32,0,1000,1102,1,26,1001,1101,0,25,1012,1102,24,1,1006,1101,0,835,1024,109,10,21108,40,41,4,1005,1014,201,1001,64,1,64,1105,1,203,4,187,1002,64,2,64,109,-12,2101,0,9,63,1008,63,34,63,1005,63,229,4,209,1001,64,1,64,1105,1,229,1002,64,2,64,109,-4,1202,8,1,63,1008,63,39,63,1005,63,255,4,235,1001,64,1,64,1106,0,255,1002,64,2,64,109,12,1201,2,0,63,1008,63,34,63,1005,63,279,1001,64,1,64,1105,1,281,4,261,1002,64,2,64,109,12,1206,2,299,4,287,1001,64,1,64,1106,0,299,1002,64,2,64,109,-21,1202,7,1,63,1008,63,34,63,1005,63,319,1106,0,325,4,305,1001,64,1,64,1002,64,2,64,109,5,1201,-2,0,63,1008,63,32,63,1005,63,347,4,331,1105,1,351,1001,64,1,64,1002,64,2,64,109,-2,1208,3,28,63,1005,63,373,4,357,1001,64,1,64,1106,0,373,1002,64,2,64,109,5,2107,28,4,63,1005,63,389,1106,0,395,4,379,1001,64,1,64,1002,64,2,64,109,3,1208,1,26,63,1005,63,415,1001,64,1,64,1106,0,417,4,401,1002,64,2,64,109,-5,2101,0,0,63,1008,63,25,63,1005,63,441,1001,64,1,64,1105,1,443,4,423,1002,64,2,64,109,14,1206,4,459,1001,64,1,64,1105,1,461,4,449,1002,64,2,64,109,-11,21107,41,40,4,1005,1010,477,1105,1,483,4,467,1001,64,1,64,1002,64,2,64,109,1,2107,23,-1,63,1005,63,501,4,489,1106,0,505,1001,64,1,64,1002,64,2,64,109,1,1207,-4,37,63,1005,63,523,4,511,1106,0,527,1001,64,1,64,1002,64,2,64,109,8,1205,5,545,4,533,1001,64,1,64,1105,1,545,1002,64,2,64,109,14,2106,0,-3,1001,64,1,64,1106,0,563,4,551,1002,64,2,64,109,-29,2108,32,-1,63,1005,63,585,4,569,1001,64,1,64,1105,1,585,1002,64,2,64,109,19,21108,42,42,-6,1005,1014,603,4,591,1106,0,607,1001,64,1,64,1002,64,2,64,109,-12,1207,-7,25,63,1005,63,627,1001,64,1,64,1106,0,629,4,613,1002,64,2,64,109,12,21102,43,1,-7,1008,1013,43,63,1005,63,655,4,635,1001,64,1,64,1105,1,655,1002,64,2,64,109,-11,21101,44,0,6,1008,1015,46,63,1005,63,675,1106,0,681,4,661,1001,64,1,64,1002,64,2,64,109,-1,21102,45,1,7,1008,1015,42,63,1005,63,701,1106,0,707,4,687,1001,64,1,64,1002,64,2,64,109,-1,2102,1,2,63,1008,63,26,63,1005,63,731,1001,64,1,64,1106,0,733,4,713,1002,64,2,64,109,6,21107,46,47,-2,1005,1011,755,4,739,1001,64,1,64,1105,1,755,1002,64,2,64,109,2,21101,47,0,-2,1008,1013,47,63,1005,63,777,4,761,1106,0,781,1001,64,1,64,1002,64,2,64,109,10,1205,-5,793,1106,0,799,4,787,1001,64,1,64,1002,64,2,64,109,-1,2105,1,-1,1001,64,1,64,1105,1,817,4,805,1002,64,2,64,109,9,2105,1,-9,4,823,1001,64,1,64,1105,1,835,1002,64,2,64,109,-36,2108,38,7,63,1005,63,855,1001,64,1,64,1106,0,857,4,841,1002,64,2,64,109,13,2102,1,-6,63,1008,63,36,63,1005,63,879,4,863,1106,0,883,1001,64,1,64,1002,64,2,64,109,10,2106,0,8,4,889,1105,1,901,1001,64,1,64,4,64,99,21101,0,27,1,21101,915,0,0,1106,0,922,21201,1,49329,1,204,1,99,109,3,1207,-2,3,63,1005,63,964,21201,-2,-1,1,21102,1,942,0,1105,1,922,21201,1,0,-1,21201,-2,-3,1,21102,957,1,0,1106,0,922,22201,1,-1,-2,1105,1,968,22102,1,-2,-2,109,-3,2105,1,0]
    require 'pry-byebug'
    execution = Advent::IntCodeComputer::Execution.new(program)
    puts execution.execute_until_halt(inputs: [2]).join(',')
end
