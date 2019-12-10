require "rspec"
require "pry-byebug"
require_relative "../asteroid_scanner.rb"

include RSpec
include Advent

describe AsteroidScanner do
  let(:scanner) { AsteroidScanner.new }

  it "handles example 1" do
    map = %q(.#..#
.....
#####
....#
...##)
    scanner = AsteroidScanner.new(map)
    expect(scanner.most_asteroids.first).to eq(8)
  end

  it "handles example 2" do
    map = %q(......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####)
    scanner = AsteroidScanner.new(map)
    expect(scanner.most_asteroids.first).to eq(33)
  end

  it "handles example 3" do
    map = %q(#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.)
    scanner = AsteroidScanner.new(map)
    expect(scanner.most_asteroids.first).to eq(35)
  end

  it "handles example 4" do
    map = %q(.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..)
    scanner = AsteroidScanner.new(map)
    expect(scanner.most_asteroids.first).to eq(41)
  end

  it "handles example 4" do
    map = %q(.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##)
    scanner = AsteroidScanner.new(map)
    expect(scanner.most_asteroids.first).to eq(210)
  end
end
