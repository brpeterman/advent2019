module Advent
  module IntCodeComputer
    class Operation
      OPCODES = {
        1 => :add,
        2 => :multiply,
        3 => :input,
        4 => :output,
        5 => :jump_if_true,
        6 => :jump_if_false,
        7 => :less_than,
        8 => :equals,
        9 => :relative_base_offset
      }.freeze

      attr_accessor :opcode, :length, :implementation

      def initialize(opcode, length, implementation)
        @opcode = opcode
        @length = length
        @implementation = implementation
      end
    end

    OPERATIONS = {
      add: Operation.new(1, 4, :add),
      multiply: Operation.new(2, 4, :multiply),
      input: Operation.new(3, 2, :input),
      output: Operation.new(4, 2, :output),
      jump_if_true: Operation.new(5, 3, :jump_if_true),
      jump_if_false: Operation.new(6, 3, :jump_if_false),
      less_than: Operation.new(7, 4, :less_than),
      equals: Operation.new(8, 4, :equals),
      relative_base_offset: Operation.new(9, 2, :relative_base_offset)
    }.freeze

    class Execution
      attr_reader :halted

      MODES = {
        positional: 0,
        immediate: 1,
        relative: 2
      }.freeze

      def initialize(initial_memory, phase: nil)
        @halted = false
        @position = 0
        @relative_base = 0
        @memory = initial_memory.dup
        @inputs = if phase
                    [phase]
                  else
                    []
                  end
      end

      def execute(inputs: [])
        @inputs += inputs
        while @memory[@position] != 99
          opstring = @memory[@position].to_s
          opcode = get_operation(opstring)
          operation = OPERATIONS[Operation::OPCODES[opcode]]
          output = send(operation.implementation, operation, opstring)
          return output if opcode == 4
        end
        @halted = true
        nil
      end

      def execute_until_halt(inputs: [])
        outputs = []
        current_output = 0
        until current_output.nil?
          current_output = execute(inputs: inputs)
          outputs << current_output unless current_output.nil?
        end
        outputs
      end

      def get_operation(opstring)
        return opstring.to_i if opstring.length == 1

        opstring[-2..opstring.length - 1].to_i
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
          raise Exception, "Got a nonsense mode for output: #{mode}"
        end
      end

      def read_addr(addr)
        @memory[addr] || 0
      end

      def pad_op(length, opstring)
        "#{'0' * (length - opstring.length)}#{opstring}"
      end

      def add(operation, opstring)
        padded_op = pad_op(5, opstring)
        op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
        op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
        output_position = resolve_output_position(padded_op[0], @position + 3)
        @memory[output_position] = op1 + op2
        @position += operation.length
      end

      def multiply(operation, opstring)
        padded_op = pad_op(5, opstring)
        op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
        op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
        output_position = resolve_output_position(padded_op[0], @position + 3)
        @memory[output_position] = op1 * op2
        @position += operation.length
      end

      def input(operation, opstring)
        padded_op = pad_op(3, opstring)
        output_position = resolve_output_position(padded_op[0], @position + 1)
        @memory[output_position] = @inputs.shift
        @position += operation.length
      end

      def output(operation, opstring)
        padded_op = pad_op(3, opstring)
        op1 = resolve_operand(padded_op[0], read_addr(@position + 1))
        @position += operation.length
        op1
      end

      def jump_if_true(operation, opstring)
        padded_op = pad_op(4, opstring)
        condition = resolve_operand(padded_op[1], read_addr(@position + 1))
        jump_to = resolve_operand(padded_op[0], read_addr(@position + 2))
        @position = condition.zero? ? @position + operation.length : jump_to
      end

      def jump_if_false(operation, opstring)
        padded_op = pad_op(4, opstring)
        condition = resolve_operand(padded_op[1], read_addr(@position + 1))
        jump_to = resolve_operand(padded_op[0], read_addr(@position + 2))
        @position = !condition.zero? ? @position + operation.length : jump_to
      end

      def less_than(operation, opstring)
        padded_op = pad_op(5, opstring)
        op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
        op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
        output_position = resolve_output_position(padded_op[0], @position + 3)
        @memory[output_position] = op1 < op2 ? 1 : 0
        @position += operation.length
      end

      def equals(operation, opstring)
        padded_op = pad_op(5, opstring)
        op1 = resolve_operand(padded_op[2], read_addr(@position + 1))
        op2 = resolve_operand(padded_op[1], read_addr(@position + 2))
        output_position = resolve_output_position(padded_op[0], @position + 3)
        @memory[output_position] = op1 == op2 ? 1 : 0
        @position += operation.length
      end

      def relative_base_offset(operation, opstring)
        padded_op = pad_op(3, opstring)
        offset = resolve_operand(padded_op[0], read_addr(@position + 1))
        @relative_base += offset
        @position += operation.length
      end
    end
  end
end
