require "genetic"

# The knapsack problem is this:
# We have knapsack that can hold 15kg of stuff, and a range of items with
# varying weight and value.
# We want to figure out what items to pick to maximize value without 
# going over weight.
#
module Knapsack
  # We have to encode solutions to our problem in a way that fits the GA
  # setup, for knapsack that is simple, as we can just create an array of bits.
  # Each bit position signifies an item, and a 1 in it's position indicates
  # that we take said item.

  ITEMS = [
    { weight: 3, value: 5 },
    { weight: 1, value: 2 },
    { weight: 5, value: 4 },
    { weight: 2, value: 2 },
    { weight: 7, value: 8 },
    { weight: 4, value: 6 },
    { weight: 2, value: 3 },
    { weight: 8, value: 7 },
  ]

  class ItemCombinationFitness < FitnessCalculation(BitArray)
    def call(dna)
      weight, value = 0,0

      dna.each_with_index do |locus, index|
        if locus
          weight += ITEMS[index][:weight]
          value += ITEMS[index][:value]
        end
      end

      # If it weighs too much the chromosome is not fit at all
      return 0 if weight > 15

      # Otherwise, all we're interested in is the value, so it makes a good
      # fitness function
      return value
    end
  end

  class SinglePointCrossover < CrossoverStrategy(BitArray)
    def call(first_dna, second_dna)
      new_dna = T.new(first_dna.size)
      half_index = (first_dna.size // 2) - 1

      0.upto(first_dna.size - 1) do |i|
        new_dna[i] = i > half_index ? second_dna[i] : first_dna[i]
      end

      [new_dna]
    end
  end

  class UniformCrossover < CrossoverStrategy(BitArray)
    def call(first_dna, second_dna)
      new_dna = T.new(first_dna.size)

      0.upto(first_dna.size - 1) do |i|
        new_dna[i] = i.even? ? second_dna[i] : first_dna[i]
      end

      [new_dna]
    end
  end

  class ItemCombination < Chromosome(BitArray)
    def self.random
      bits = BitArray.new(8)

      0.upto(7) do |i|
        # Turn a bit on with 30% chance, should mostly generate valid solutions
        if Random.rand < 0.3
          bits[i] = true
        end
      end

      new(bits)
    end

    def fitness_calculation
      ItemCombinationFitness
    end

    def crossover_strategy
      SinglePointCrossover
    end

    def mutate! : Nil
      index = (0..@dna.size - 1).to_a.sample
      @dna[index] = !@dna[index]
    end
  end
end
