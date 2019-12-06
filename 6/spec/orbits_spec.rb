require 'rspec'
require 'pry-byebug'
require_relative '../orbits.rb'

include RSpec
include Advent

describe Orbits do
    let(:orbits) { Orbits.new }

    it 'calculates total orbits' do
        orbit_defs = %w{
            COM)B
            B)C
            C)D
            D)E
            E)F
            B)G
            G)H
            D)I
            E)J
            J)K
            K)L
        }
        nodes = orbits.orbital_tree(orbit_defs)
        expect(orbits.total_orbits(nodes['COM'])).to eq(42)
    end

    it 'calculates shortest path' do
        orbit_defs = %w{
            COM)B
            B)C
            C)D
            D)E
            E)F
            B)G
            G)H
            D)I
            E)J
            J)K
            K)L
            K)YOU
            I)SAN
        }
        nodes = orbits.orbital_tree(orbit_defs)
        expect(orbits.shortest_path(nodes['YOU'], nodes['SAN'])).to eq(4)
    end
end
