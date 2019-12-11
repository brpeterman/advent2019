module Advent
  class CartesianCoord
    attr_accessor :x, :y

    def initialize(x:, y:)
      @x = x
      @y = y
    end

    def to_polar(origin)
      x_diff = @x - origin.x
      y_diff = @y - origin.y
      distance = Math.sqrt(x_diff ** 2 + y_diff ** 2)
      angle = Math.atan2(y_diff, x_diff)
      PolarCoord.new(angle: angle, distance: distance)
    end

    def eql?(other)
      @x == other.x && @y == other.y
    end

    def hash
      { x: x, y: y }.hash
    end
  end

  class PolarCoord
    attr_accessor :angle, :distance

    def initialize(angle:, distance:)
      @angle = angle
      @distance = distance
    end

    def to_cartesian(base)
      x = @distance * Math.cos(@angle) + base.x
      y = @distance * Math.sin(@angle) + base.y
      CartesianCoord.new(x: x, y: y)
    end

    def eql?(other)
      @angle == other.angle && @distance == other.distance
    end

    def hash
      { angle: angle, distance: distance }.hash
    end
  end

  class AsteroidScanner
    def initialize(map_definition)
      @asteroids = parse_map(map_definition)
      @laser_position = -(Math::PI / 2) - 0.000000000001
    end

    def parse_map(map_definition)
      asteroids = []
      lines = map_definition.split("\n")
      lines.each_index do |y_coord|
        points = lines[y_coord].split("")
        points.each_index do |x_coord|
          if points[x_coord] == "#"
            asteroids << CartesianCoord.new(x: x_coord, y: y_coord)
          end
        end
      end
      asteroids
    end

    def polar_asteroids(origin)
      polar_asteroids = Hash.new { [] }
      @asteroids.each do |asteroid|
        polar = asteroid.to_polar(origin)
        list = polar_asteroids[polar.angle]
        list << polar
        polar_asteroids[polar.angle] = list
      end
      polar_asteroids.keys.each do |key|
        polar_asteroids[key].sort! { |a, b| a.distance <=> b.distance }
      end
      polar_asteroids
    end

    def most_asteroids
      most_asteroids = 0
      best_asteroid = nil
      @asteroids.each do |candidate|
        visible_asteroids = polar_asteroids(candidate).keys.length
        if visible_asteroids > most_asteroids
          most_asteroids = visible_asteroids
          best_asteroid = candidate
        end
      end
      [most_asteroids, best_asteroid]
    end

    def position_and_fire_laser(asteroid_positions)
      sorted_angles = asteroid_positions.keys.sort
      angle_index = sorted_angles.find_index { |angle| angle > @laser_position }
      if angle_index == nil
        angle_index = 0
      end
      next_angle = sorted_angles[angle_index]
      @laser_position = next_angle
      destroyed = asteroid_positions[next_angle].first
      asteroid_positions[next_angle].delete(destroyed)
      if asteroid_positions[next_angle].empty?
        asteroid_positions.delete(next_angle)
      end
      destroyed
    end
  end
end

if __FILE__ == $0
  require "pry-byebug"
  map = %q(.#......##.#..#.......#####...#..
...#.....##......###....#.##.....
..#...#....#....#............###.
.....#......#.##......#.#..###.#.
#.#..........##.#.#...#.##.#.#.#.
..#.##.#...#.......#..##.......##
..#....#.....#..##.#..####.#.....
#.............#..#.........#.#...
........#.##..#..#..#.#.....#.#..
.........#...#..##......###.....#
##.#.###..#..#.#.....#.........#.
.#.###.##..##......#####..#..##..
.........#.......#.#......#......
..#...#...#...#.#....###.#.......
#..#.#....#...#.......#..#.#.##..
#.....##...#.###..#..#......#..##
...........#...#......#..#....#..
#.#.#......#....#..#.....##....##
..###...#.#.##..#...#.....#...#.#
.......#..##.#..#.............##.
..###........##.#................
###.#..#...#......###.#........#.
.......#....#.#.#..#..#....#..#..
.#...#..#...#......#....#.#..#...
#.#.........#.....#....#.#.#.....
.#....#......##.##....#........#.
....#..#..#...#..##.#.#......#.#.
..###.##.#.....#....#.#......#...
#.##...#............#..#.....#..#
.#....##....##...#......#........
...#...##...#.......#....##.#....
.#....#.#...#.#...##....#..##.#.#
.#.#....##.......#.....##.##.#.##)
  scanner = Advent::AsteroidScanner.new(map)
  visible, base = scanner.most_asteroids
  puts "Visible asteroids: #{visible}"
  puts "Base: #{base.x},#{base.y}"
  positions = scanner.polar_asteroids(base)
  target = 200
  destroyed_count = 0
  while positions.length > 0
    destroyed = scanner.position_and_fire_laser(positions)
    destroyed_count += 1
    if destroyed_count == target
      original = destroyed.to_cartesian(base)
      puts "#{original.x},#{original.y}"
    end
  end
end
