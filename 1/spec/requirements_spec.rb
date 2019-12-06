require 'rspec'
require 'pry'
require_relative '../requirements.rb'

include RSpec
include Advent

describe Requirements do
    let(:requirements) { Requirements.new }

    it 'handles mass 12' do
        fuel = requirements.calculate_fuel([12])
        expect(fuel).to eq(2)
    end

    it 'handles mass 14' do
        fuel = requirements.calculate_fuel([14])
        expect(fuel).to eq(2)
    end

    it 'handles mass 1969' do
        fuel = requirements.calculate_fuel([1969])
        expect(fuel).to eq(966)
    end

    it 'handles mass 100756' do
        fuel = requirements.calculate_fuel([100756])
        expect(fuel).to eq(50346)
    end
end
