require_relative 'computer'

module Advent
  class Coords
    attr_accessor :x, :y

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
  end

  class Painter
    def initialize(program)
      @position = Coords.new(0, 0)
      @direction = :up
      @grid = Hash.new { 0 }
      @grid[@position] = 1
      @program = Advent::IntCodeComputer::Execution.new(program)
    end

    def auto_paint
      tiles_painted = {}
      until @program.halted
        painted_tile = paint_and_move
        tiles_painted[painted_tile] = true unless painted_tile.nil?
      end
      tiles_painted.keys.length
    end

    def paint_and_move
      current_color = @grid[@position]
      new_color = @program.execute(inputs: [current_color])
      return nil if @program.halted

      turn = @program.execute
      @grid[@position] = new_color
      # puts "Assigned #{new_color} to #{@position.x},#{position.y}"
      @direction = turn(turn.zero? ? :left : :right)
      last_position = @position.dup
      @position = move_forward
      last_position
    end

    def turn(turn_direction)
      case @direction
      when :up
        turn_direction == :left ? :left : :right
      when :down
        turn_direction == :left ? :right : :left
      when :left
        turn_direction == :left ? :down : :up
      when :right
        turn_direction == :left ? :up : :down
      end
    end

    def move_forward
      case @direction
      when :up
        Coords.new(@position.x, @position.y + 1)
      when :down
        Coords.new(@position.x, @position.y - 1)
      when :left
        Coords.new(@position.x - 1, @position.y)
      when :right
        Coords.new(@position.x + 1, @position.y)
      end
    end

    def render_grid
      max_x = @grid.keys.max { |a, b| a.x <=> b.x }.x
      min_x = @grid.keys.min { |a, b| a.x <=> b.x }.x
      max_y = @grid.keys.max { |a, b| a.y <=> b.y }.y
      min_y = @grid.keys.min { |a, b| a.y <=> b.y }.y

      (min_y..max_y).reverse_each do |row|
        line = ''
        (min_x..max_x).each do |column|
          painted_tile_index = @grid.keys.find_index { |coords| coords.x == column && coords.y == row }
          color = painted_tile_index ? @grid[Coords.new(column, row)] : 0
          line += color.zero? ? '◼️' : '◻️'
        end
        puts line
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry-byebug'
  input = File.open('input.txt').readlines.join
  program = input.split(',').map(&:to_i)
  painter = Advent::Painter.new(program)
  painter.auto_paint
  painter.render_grid
end
