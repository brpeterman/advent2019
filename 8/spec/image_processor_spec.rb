require 'rspec'
require 'pry-byebug'
require_relative '../image_processor.rb'

include RSpec
include Advent

describe ImageProcessor do
    it 'handles example 1' do
        image = ImageProcessor::Image.new(3, 2, '123456789012'.split('').map(&:to_i))
        layer = ImageProcessor::characteristic_layer(image)
        expect(layer.checksum).to eq(1)
    end
end
