require 'io/console'

require_relative '../intcode/computer'

module Advent
  class Coords
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      @x == other.x && @y == other.y
    end

    def hash
      { x: @x, y: @y }.hash
    end

    def to_s
      "{x: #{@x}, y: #{@y}}"
    end
  end

  class RepairDroid
    attr_reader :map

    def initialize(program)
      @execution = IntCodeComputer::Execution.new(program)
      @map = {}
      @position = Coords.new(0, 0)
      @map[@position] = :open
      @frontiers = {
        Coords.new(1, 0) => true,
        Coords.new(0, 1) => true,
        Coords.new(-1, 0) => true,
        Coords.new(0, -1) => true
      }
      @route = []
    end

    def interactive_explore
      loop do
        map = render_map
        puts map
        key = read_char
        direction = {
          'w' => :up,
          's' => :down,
          'a' => :left,
          'd' => :right,
          'q' => :quit
        }[key]
        return if direction == :quit

        if direction
          output = @execution.execute(inputs: input_from_direction(direction))
          update_map(output, cell_from_direction(@position, direction))
        end
      end
    end

    def read_char
      state = `stty -g`
      `stty raw -echo -icanon isig`
      STDIN.getc.chr
    ensure
      `stty #{state}`
    end

    def auto_explore
      done = false
      until done
        direction = choose_direction
        return if direction == :quit

        output = @execution.execute(inputs: input_from_direction(direction))
        update_map(output, cell_from_direction(@position, direction))
      end
    end

    def choose_direction
      return @route.shift unless @route.empty?

      destination ||= next_unexplored_cell(@position)
      return :quit unless destination

      @route = route(@position, destination)
      @route.shift
    end

    def next_unexplored_cell(position)
      neighbors = [
        cell_from_direction(position, :up),
        cell_from_direction(position, :down),
        cell_from_direction(position, :left),
        cell_from_direction(position, :right)
      ].reject { |cell| @map[cell] == :wall }
      unexplored_neighbors = neighbors.select { |cell| @map[cell].nil? }
      unexplored_neighbors.each { |cell| @frontiers[cell] = true }
      return unexplored_neighbors.first unless unexplored_neighbors.empty?
      return nil if @frontiers.empty?

      nearest_unexplored_cell(position)
    end

    def nearest_unexplored_cell(position)
      # Use Manhattan distance in absence of a better heuristic
      @frontiers.reduce(@frontiers.first.first) do |nearest, (cell, _)|
        if manhattan_distance(position, cell) < manhattan_distance(position, nearest)
          cell
        else
          nearest
        end
      end
    end

    def manhattan_distance(cell1, cell2)
      (cell1.x - cell2.x).abs + (cell1.y - cell2.y).abs
    end

    def route(start_position, end_position)
      routed = false
      current_cell = start_position
      tree = {}
      path = []
      nodes = []
      visited = []
      until routed
        visited << current_cell
        if adjacent?(current_cell, end_position)
          path.unshift(direction_from_cell(current_cell, end_position))
          routed = true
          next
        end

        # binding.pry
        open_neighbors = open_neighbors(current_cell).reject { |neighbor| visited.include?(neighbor) }
        open_neighbors.each { |neighbor| tree[neighbor] = current_cell }
        nodes += open_neighbors
        nodes.uniq!
        current_cell = nodes.shift
      end

      until current_cell == start_position
        parent = tree[current_cell]
        path.unshift(direction_from_cell(parent, current_cell))
        current_cell = parent
      end
      path
    end

    def open_neighbors(cell)
      [
        Coords.new(cell.x, cell.y + 1),
        Coords.new(cell.x, cell.y - 1),
        Coords.new(cell.x + 1, cell.y),
        Coords.new(cell.x - 1, cell.y)
      ].select { |neighbor| @map[neighbor] == :open }
    end

    def adjacent?(cell1, cell2)
      (cell1.x == cell2.x && (cell1.y - cell2.y).abs == 1) ||
        (cell1.y == cell2.y && (cell1.x - cell2.x).abs == 1)
    end

    # Assumes cells are adjacent
    def direction_from_cell(cell1, cell2)
      if cell1.x < cell2.x
        :right
      elsif cell1.x > cell2.x
        :left
      elsif cell1.y < cell2.y
        :up
      else
        :down
      end
    end

    def fully_explored?
      @frontiers.empty?
    end

    def input_from_direction(direction)
      {
        up: [1],
        down: [2],
        left: [3],
        right: [4]
      }[direction]
    end

    def cell_from_direction(position, direction)
      case direction
      when :up
        Coords.new(position.x, position.y + 1)
      when :down
        Coords.new(position.x, position.y - 1)
      when :left
        Coords.new(position.x - 1, position.y)
      when :right
        Coords.new(position.x + 1, position.y)
      end
    end

    def update_map(output, cell)
      case output
      when 0
        @map[cell] = :wall
      when 1
        @map[cell] = :open
        @position = cell
      when 2
        @map[cell] = :goal
        @position = cell
      end
      @frontiers.delete(cell)
    end

    def fill_time
      tree = {}
      current_cell = @map.keys.select { |cell| @map[cell] == :goal }.first
      depths = {
        current_cell => 0
      }
      explore_next = [current_cell]
      visited = []
      max_depth = 0
      until current_cell.nil?
        visited << current_cell
        if tree[current_cell]
          depth = depths[tree[current_cell]] + 1 || 0
          depths[current_cell] = depth
          max_depth = depth if depth > max_depth
        end
        neighbors = open_neighbors(current_cell).reject { |n| visited.include?(n) }
        neighbors.each { |n| tree[n] = current_cell }
        explore_next += neighbors
        explore_next.uniq!
        current_cell = explore_next.shift
      end
      max_depth
    end

    def cell_to_s(cell)
      return '🤖 ' if cell == @position

      {
        open: '..',
        wall: '🔲 ',
        goal: '🎉 '
      }[@map[cell]] || '  '
    end

    def render_map
      min_x, max_x, min_y, max_y = map_bounds
      map_string = "===\n      "
      (min_x..max_x).each do |col|
        map_string += col.to_s.ljust(4) if col % 2 == 0
      end
      map_string += "\n"
      (min_y..max_y).reverse_each do |row|
        line = "#{row.to_s.rjust(3)} "
        (min_x..max_x).each do |col|
          line += cell_to_s(Coords.new(col, row))
        end
        map_string += line + "\n"
      end
      map_string + "===\n"
    end

    def map_bounds
      min_x = nil
      max_x = nil
      min_y = nil
      max_y = nil
      map.keys.each do |cell|
        min_x = cell.x if min_x.nil? || cell.x < min_x
        max_x = cell.x if max_x.nil? || cell.x > max_x
        min_y = cell.y if min_y.nil? || cell.y < min_y
        max_y = cell.y if max_y.nil? || cell.y > max_y
      end
      [min_x, max_x, min_y, max_y]
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry-byebug'
  program = File.open('input.txt').readlines.join.split(',').map(&:to_i)
  droid = Advent::RepairDroid.new(program)
  droid.auto_explore
  goal = droid.map.keys.select { |cell| droid.map[cell] == :goal }.first
  path_to_goal = droid.route(Advent::Coords.new(0, 0), goal)
  puts "Steps to goal: #{path_to_goal.size}"
  puts "Fill time: #{droid.fill_time}"
end
