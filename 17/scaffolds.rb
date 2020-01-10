require_relative '../intcode/computer'

module Advent
  class Coords
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def eql?(other)
      @x == other.x && @y == other.y
    end

    def hash
      { x: @x, y: @y }.hash
    end

    def to_s
      { x: @x, y: @y }.to_s
    end
  end

  class Cell
    attr_reader :type

    def initialize(type)
      @type = type
    end

    def self.from_ascii(code)
      {
        '^' => Cell.new(:up),
        '<' => Cell.new(:left),
        '>' => Cell.new(:right),
        'v' => Cell.new(:down),
        '.' => Cell.new(:open),
        '#' => Cell.new(:path)
      }[code]
    end

    def to_s
      {
        up: '⬆ ',
        down: '⬇ ',
        left: '⬅ ',
        right: '➡ ',
        open: '. ',
        path: '⬜ ',
        intersection: '❎ '
      }[@type]
    end
  end

  class Mapper
    def initialize(program)
      @execution = Advent::IntCodeComputer::Execution.new(program)
    end

    def alignments
      @map.keys.reduce(0) do |sum, coord|
        if intersection?(coord)
          puts "Intersection: #{coord}"
          @map[coord] = Cell.new(:intersection)
          sum + (coord.x * coord.y)
        else
          sum
        end
      end
    end

    def intersection?(coord)
      solid?(coord) &&
        solid?(Coords.new(coord.x, coord.y + 1)) &&
        solid?(Coords.new(coord.x, coord.y - 1)) &&
        solid?(Coords.new(coord.x + 1, coord.y)) &&
        solid?(Coords.new(coord.x - 1, coord.y))
    end

    def solid?(coord)
      !@map[coord].nil? && @map[coord].type != :open
    end

    def build_map
      outputs = @execution.execute_until_halt
      ascii_to_map(outputs)
    end

    def ascii_to_map(ascii)
      col = 0
      row = 0
      @map = {}
      @max_x = 0
      @max_y = 0
      ascii.each do |code|
        if code == 10
          row += 1
          col = 0
        else
          @map[Coords.new(col, row)] = Cell.from_ascii(code.chr)
          col += 1
        end
        @max_x = col unless col < @max_x
        @max_y = row unless row < @max_y
      end
    end

    def render_map
      output = "\n"
      (0..@max_y).each do |col|
        line = ''
        (0..@max_x).each do |row|
          line += @map[Coords.new(row, col)].to_s
        end
        output += line + "\n"
      end
      output
    end
  end

  class Guidance
    def initialize(program)
      @execution = Advent::IntCodeComputer::Execution.new(program)
    end

    def override_program(func_main, func_a, func_b, func_c)
      @execution.execute(inputs: to_ascii_input(func_main))
      @execution.execute(inputs: to_ascii_input(func_a))
      @execution.execute(inputs: to_ascii_input(func_b))
      @execution.execute(inputs: to_ascii_input(func_c))
    end

    def execute(view: false)
      video_feed = view ? 'y'.ord : 'n'.ord
      @execution.execute_until_halt(inputs: [video_feed, "\n".ord])
    end

    def to_ascii_input(sequence)
      converted = []
      sequence.each_index do |index|
        char = sequence[index]
        converted << char.ord
        if index < (sequence.length - 1)
          converted << ','.ord
        else
          converted << "\n".ord
        end
      end
      converted
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry-byebug'
  input = File.open('input.txt').readlines.join
  program = input.split(',').map(&:to_i)
  mapper = Advent::Mapper.new(program)
  mapper.build_map
  puts mapper.alignments
  puts mapper.render_map

  func_a = %w[L 6 6 L 6 L 8 R 6]
  func_b = %w[L 8 L 8 R 4 R 6 R 6]
  func_c = %w[L 6 6 R 6 L 8]
  func_main = %w[A B A B C C B A B C]
  movement_program = program.clone
  movement_program[0] = 2
  guidance = Advent::Guidance.new(movement_program)
  guidance.override_program(func_main, func_a, func_b, func_c)
  output = guidance.execute(view: false)
  puts output.last
end
