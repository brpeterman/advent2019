module Advent
    class IntCodeComputer
        def execute state
            position = 0
            while state[position] != 99 do
                if state[position] == 1 then add(state, position)
                elsif state[position] == 2 then multiply(state, position) end
                position += 4
            end
            state
        end

        def add(state, code_position)
            op1 = state[state[code_position + 1]]
            op2 = state[state[code_position + 2]]
            output_position = state[code_position + 3]
            state[output_position] = op1 + op2
        end

        def multiply(state, code_position)
            op1 = state[state[code_position + 1]]
            op2 = state[state[code_position + 2]]
            output_position = state[code_position + 3]
            state[output_position] = op1 * op2
        end
    end
end

if __FILE__ == $0
    computer = Advent::IntCodeComputer.new
    wanted = 19690720
    noun = 0
    verb = 0
    (0..99).each do |i|
        (0..99).each do |j|
            input = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,10,19,2,9,19,23,1,9,23,27,2,27,9,31,1,31,5,35,2,35,9,39,1,39,10,43,2,43,13,47,1,47,6,51,2,51,10,55,1,9,55,59,2,6,59,63,1,63,6,67,1,67,10,71,1,71,10,75,2,9,75,79,1,5,79,83,2,9,83,87,1,87,9,91,2,91,13,95,1,95,9,99,1,99,6,103,2,103,6,107,1,107,5,111,1,13,111,115,2,115,6,119,1,119,5,123,1,2,123,127,1,6,127,0,99,2,14,0,0]
            input[1] = i
            input[2] = j
            output = computer.execute(input).first
            if (output == wanted)
                noun = i
                verb = j
                break
            end
        end
    end

    puts "noun: #{noun}, verb: #{verb}, answer: #{100 * noun + verb}"
end
