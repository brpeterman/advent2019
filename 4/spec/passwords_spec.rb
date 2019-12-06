require 'rspec'
require 'pry'
require_relative '../passwords.rb'

include RSpec
include Advent

describe Passwords do
    let(:passwords) { Passwords.new }

    it 'rejects 111111' do
        expect(passwords.valid? 111111).to be false
    end

    it 'rejects 111123' do
        expect(passwords.valid? 111123).to be false
    end

    it 'accepts 122345' do
        expect(passwords.valid? 122345).to be true
    end

    it 'rejects 223450' do
        expect(passwords.valid? 223450).to be false
    end

    it 'rejects 123789' do
        expect(passwords.valid? 123789).to be false
    end

    it 'accepts 112233' do
        expect(passwords.valid? 112233).to be true
    end

    it 'accepts 111122' do
        expect(passwords.valid? 111122).to be true
    end
end
