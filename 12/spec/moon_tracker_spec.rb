# frozen_string_literal: true

require 'rspec'
require 'pry-byebug'
require_relative '../moon_tracker.rb'

include RSpec
include Advent

describe Vector3D do
  it 'implements eql? correctly' do
    vec1 = Vector3D.new(-4, 6, 8)
    vec2 = Vector3D.new(-4, 6, 8)
    expect(vec1).to eql(vec2)
  end
end

describe MoonTracker do
  describe MoonTracker::MoonState do
    it 'implements eql? correctly' do
      state1 = MoonTracker::MoonState.new(pos: Vector3D.new(-4, 6, 8), vel: Vector3D.new(5, -11, 7))
      state2 = MoonTracker::MoonState.new(pos: Vector3D.new(-4, 6, 8), vel: Vector3D.new(5, -11, 7))
      expect(state1).to eql(state2)
    end
  end

  describe 'system 1' do
    it 'handles 0 steps' do
      input = "<x=-1, y=0, z=2>\n
               <x=2, y=-10, z=-7>\n
               <x=4, y=-8, z=8>\n
               <x=3, y=5, z=-1>"
      tracker = MoonTracker.new(system_definition: input)

      expected_system = [
        MoonTracker::MoonState.new(pos: Vector3D.new(-1, 0, 2), vel: Vector3D.new(0, 0, 0)),
        MoonTracker::MoonState.new(pos: Vector3D.new(2, -10, -7), vel: Vector3D.new(0, 0, 0)),
        MoonTracker::MoonState.new(pos: Vector3D.new(4, -8, 8), vel: Vector3D.new(0, 0, 0)),
        MoonTracker::MoonState.new(pos: Vector3D.new(3, 5, -1), vel: Vector3D.new(0, 0, 0))
      ]
      expect(tracker.system).to eql(expected_system)
    end

    it 'handles 1 step' do
      input = "<x=-1, y=0, z=2>\n
               <x=2, y=-10, z=-7>\n
               <x=4, y=-8, z=8>\n
               <x=3, y=5, z=-1>"
      tracker = MoonTracker.new(system_definition: input)

      expected_system = [
        MoonTracker::MoonState.new(pos: Vector3D.new(2, -1, 1), vel: Vector3D.new(3, -1, -1)),
        MoonTracker::MoonState.new(pos: Vector3D.new(3, -7, -4), vel: Vector3D.new(1, 3, 3)),
        MoonTracker::MoonState.new(pos: Vector3D.new(1, -7, 5), vel: Vector3D.new(-3, 1, -3)),
        MoonTracker::MoonState.new(pos: Vector3D.new(2, 2, 0), vel: Vector3D.new(-1, -3, 1))
      ]
      tracker.simulate(1)
      expect(tracker.system).to eql(expected_system)
    end

    it 'handles 2 steps' do
      input = "<x=-1, y=0, z=2>\n
               <x=2, y=-10, z=-7>\n
               <x=4, y=-8, z=8>\n
               <x=3, y=5, z=-1>"
      tracker = MoonTracker.new(system_definition: input)

      expected_system = [
        MoonTracker::MoonState.new(pos: Vector3D.new(5, -3, -1), vel: Vector3D.new(3, -2, -2)),
        MoonTracker::MoonState.new(pos: Vector3D.new(1, -2, 2), vel: Vector3D.new(-2, 5, 6)),
        MoonTracker::MoonState.new(pos: Vector3D.new(1, -4, -1), vel: Vector3D.new(0, 3, -6)),
        MoonTracker::MoonState.new(pos: Vector3D.new(1, -4, 2), vel: Vector3D.new(-1, -6, 2))
      ]
      tracker.simulate(2)
      expect(tracker.system).to eql(expected_system)
    end

    it 'repeats after 2772 steps' do
      input = "<x=-1, y=0, z=2>\n
               <x=2, y=-10, z=-7>\n
               <x=4, y=-8, z=8>\n
               <x=3, y=5, z=-1>"

      repeat_depth = Advent.simulate_until_repeat(input).reduce(1, :lcm)
      expect(repeat_depth).to eq(2772)
    end
  end
end
