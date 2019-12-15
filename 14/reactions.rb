module Advent
  module Reactions
    class Material
      attr_reader :amount, :dependencies

      def initialize(amount, dependencies)
        @dependencies = dependencies
        @amount = amount.to_i
      end

      def eql?(other)
        @dependencies = other.dependencies && @amount = other.amount
      end

      def hash
        { dependencies: @dependencies.hash, amount: @amount }
      end
    end

    class Synthesizer
      attr_reader :materials, :stockpile

      def initialize(recipes)
        @materials = parse_recipes(recipes)
        @stockpile = Hash.new { 0 }
      end

      def parse_recipes(recipes)
        materials = {}
        recipes.split("\n").each do |line|
          lhs, rhs = line.split('=>', 2)
          next unless lhs && rhs

          components = lhs.split(',')
          dependencies = components.each_with_object({}) do |definition, hash|
            material, amount = parse_component(definition)
            hash[material.to_sym] = amount.to_i
          end
          material, amount = parse_component(rhs)
          materials[material.to_sym] = Material.new(amount, dependencies)
        end
        materials
      end

      def parse_component(component_string)
        matches = component_string.match(/\A\s*(?<amount>\d+)\s+(?<type>[A-Z]+)\s*/)
        [matches[:type], matches[:amount]] if matches
      end

      def synthesize(material_type, amount: 1)
        consumed_ore = 0
        @materials[material_type].dependencies.each do |dep_type, dep_amount|
          amount_required = dep_amount * amount
          if dep_type == :ORE
            consumed_ore += amount_required
          elsif @stockpile[dep_type] >= amount_required
            @stockpile[dep_type] -= amount_required
          else
            needed_reactions = (amount_required + @materials[dep_type].amount - @stockpile[dep_type] - 1) / @materials[dep_type].amount
            consumed_ore += synthesize(dep_type, amount: needed_reactions)

            if @stockpile[dep_type] < amount_required
              puts "Not enough #{dep_type} stockpiled to produce #{material_type} (wanted #{amount_required}, found #{@stockpile[dep_type]})"
              return 0
            end

            @stockpile[dep_type] -= amount_required
          end
        end
        @stockpile[material_type] += @materials[material_type].amount * amount
        consumed_ore
      end
    end

    def self.find_upper_bound(recipes, target)
      required = 0
      amount = 2
      while required < target
        synthesizer = Synthesizer.new(recipes)
        required = synthesizer.synthesize(:FUEL, amount: amount)
        amount *= 1000
      end
      amount
    end
  
    def self.find_target(recipes, target, lower, upper)
      return lower if upper - lower == 1

      search_target = (upper + lower) / 2
      synthesizer = Synthesizer.new(recipes)
      required = synthesizer.synthesize(:FUEL, amount: search_target)
      if required > target
        upper = search_target
      elsif required < target
        lower = search_target
      end
      find_target(recipes, target, lower, upper)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry-byebug'
  recipes = File.open('input.txt').readlines.join("\n")
  synthesizer = Advent::Reactions::Synthesizer.new(recipes)
  puts "Ore for 1 fiel: #{synthesizer.synthesize(:FUEL)}"

  target = 1_000_000_000_000
  lower = 2
  upper = Advent::Reactions.find_upper_bound(recipes, target)
  puts "Fuel with 1000000000000 ore: #{Advent::Reactions.find_target(recipes, target, lower, upper)}"
end
