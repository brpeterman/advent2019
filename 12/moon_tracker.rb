module Advent
  class Vector3D
    attr_reader :x, :y, :z

    def initialize(x_pos, y_pos, z_pos)
      @x = x_pos.to_i
      @y = y_pos.to_i
      @z = z_pos.to_i
    end

    def +(other)
      new_x = @x + other.x
      new_y = @y + other.y
      new_z = @z + other.z
      Vector3D.new(new_x, new_y, new_z)
    end

    def to_s
      { x: @x, y: @y, z: @z }.to_s
    end

    def eql?(other)
      @x == other.x && @y == other.y && @z == other.z
    end

    def hash
      { x: @x, y: @y, z: @z }.hash
    end
  end

  class MoonTracker
    class MoonState
      attr_reader :position, :velocity

      def initialize(pos:, vel: Vector3D.new(0, 0, 0))
        @position = pos
        @velocity = vel
      end

      def potential_energy
        @position.x.abs + @position.y.abs + @position.z.abs
      end

      def kinetic_energy
        @velocity.x.abs + @velocity.y.abs + @velocity.z.abs
      end

      def total_energy
        potential_energy * kinetic_energy
      end

      def to_s
        { position: @position.to_s, velocity: @velocity.to_s }.to_s
      end

      def eql?(other)
        @position.eql?(other.position) && @velocity.eql?(other.velocity)
      end

      def hash
        { position: @position, velocity: @velocity }.hash
      end
    end

    attr_reader :system, :positions

    def initialize(system_definition: nil, system: [])
      @system = system
      @system = parse_system_definition(system_definition) if system_definition
      @positions = {}
    end

    def simulate(steps)
      (0..steps - 1).each do
        step
      end
    end

    def steps_to_repeat
      steps = 0
      until @positions[@system]
        @positions[@system] = true
        step
        steps += 1
      end
      steps
    end

    def parse_system_definition(system_definition)
      system = []
      system_definition.split("\n").each do |line|
        matches = line.match(/\A\s*<x=(?<x_pos>-?\d+),\s*y=(?<y_pos>-?\d+),\s*z=(?<z_pos>-?\d+)>\s*\Z/)
        if matches
          position = Vector3D.new(matches[:x_pos], matches[:y_pos], matches[:z_pos])
          system << MoonState.new(pos: position)
        end
      end
      system
    end

    def step
      apply_velocities(compute_velocities)
    end

    def apply_velocities(velocities)
      @system.each_index do |index|
        moon = @system[index]
        @system[index] = MoonState.new(pos: moon.position + velocities[index], vel: velocities[index])
      end
    end

    def compute_velocities
      velocities = []
      @system.each_index do |index|
        moon = @system[index]
        new_velocity = moon.velocity.dup
        @system.each_index do |other_index|
          new_velocity += influence(moon, @system[other_index]) if other_index != index
        end
        velocities[index] = new_velocity
      end
      velocities
    end

    def influence(moon, other)
      x_influence = clamp_velocity(other.position.x - moon.position.x)
      y_influence = clamp_velocity(other.position.y - moon.position.y)
      z_influence = clamp_velocity(other.position.z - moon.position.z)
      Vector3D.new(x_influence, y_influence, z_influence)
    end

    def clamp_velocity(amount)
      if amount <= -1
        -1
      elsif amount >= 1
        1
      else
        0
      end
    end
  end

  def self.simulate_until_repeat(input)
    full_system = MoonTracker.new(system_definition: input).system
    trackers = Advent.build_subsystems(full_system).map { |system| MoonTracker.new(system: system) }
    steps_to_repeat = trackers.map(&:steps_to_repeat)
    steps_to_repeat
  end

  def self.build_subsystems(full_system)
    x_system = full_system.map do |moon|
      MoonTracker::MoonState.new(pos: Vector3D.new(moon.position.x, 0, 0), vel: moon.velocity)
    end
    y_system = full_system.map do |moon|
      MoonTracker::MoonState.new(pos: Vector3D.new(0, moon.position.y, 0), vel: moon.velocity)
    end
    z_system = full_system.map do |moon|
      MoonTracker::MoonState.new(pos: Vector3D.new(0, 0, moon.position.z), vel: moon.velocity)
    end
    [x_system, y_system, z_system]
  end
end

if $PROGRAM_NAME == __FILE__
  input = File.open('input.txt').readlines.join("\n")
  tracker = Advent::MoonTracker.new(system_definition: input)
  tracker.simulate(1000)
  system_energy = tracker.system.reduce(0) do |energy, moon|
    energy + moon.total_energy
  end
  puts "Total energy after 1000 steps: #{system_energy}"

  puts Advent.simulate_until_repeat(input).reduce(1, :lcm)
end
