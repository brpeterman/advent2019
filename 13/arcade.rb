require_relative '../intcode/computer'

module Advent
  module Arcade
    class Position
      attr_reader :x, :y

      def initialize(x:, y:)
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

    class Tile
      attr_reader :type

      def initialize(type_code)
        @type = {
          0 => :empty,
          1 => :wall,
          2 => :block,
          3 => :paddle,
          4 => :ball
        }[type_code]
      end

      def to_s
        {
          empty: '  ',
          wall: '🔳 ',
          block: '🔲 ',
          paddle: '🏓 ',
          ball: '🎾 '
        }[@type]
      end
    end

    class Game
      attr_reader :tiles, :score

      def initialize(program, quarters: 0)
        @score = 0
        @tiles = {}
        modded_program = program.dup
        modded_program[0] = quarters
        @execution = IntCodeComputer::Execution.new(modded_program)
      end

      def next_tile(inputs: [])
        x = @execution.execute(inputs: inputs)
        y, id = 2.times.to_a.map { @execution.execute }
        return nil if x.nil? || y.nil? || id.nil?

        return [:score, id] if x == -1 && y.zero?

        [Position.new(x: x, y: y), Tile.new(id)]
      end

      def auto_play(render_screen: false)
        @last_ball_position = nil
        until @execution.halted
          position, tile = next_tile(inputs: ai_input)
          if position == :score
            @score = tile
          elsif !position.nil?
            @tiles[position] = tile
          end

          @paddle_x = actor_position(:paddle)
          @last_ball_position = @ball_x unless @ball_x.nil?
          @ball_x = actor_position(:ball)
          puts render if render_screen
        end
      end

      def actor_position(tile_type)
        tiles = @tiles.select { |_, t| t.type == tile_type }
        if tiles.empty?
          nil
        else
          tiles.keys.first.x
        end
      end

      def ai_input
        return [] if @ball_x == @last_ball_position
        return [] if @ball_x.nil? || @paddle_x.nil?

        [@ball_x <=> @paddle_x]
      end

      def render
        max_x = (@tiles.keys.max { |a, b| a.x <=> b.x }).x
        max_y = (@tiles.keys.max { |a, b| a.y <=> b.y }).y
        screen = "Score: #{@score}\n"
        (0..max_y).each do |row|
          line = ''
          (0..max_x).each do |col|
            line += @tiles[Position.new(x: col, y: row)].to_s
          end
          screen += line + "\n"
        end
        screen
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry-byebug'
  program = File.open('input.txt').readlines.join.split(',').map(&:to_i)
  game = Advent::Arcade::Game.new(program, quarters: 2)
  game.auto_play
  puts game.score
end
