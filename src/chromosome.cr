require "bit_array"

# Each chromosome represents a solution for the algorithm.
# You should subclass this.
class Chromosome(T)
  getter dna
  
  # Create a random new chromosome.
  # Should be overridden.
  def self.random
    new(BitArray.new(1))
  end

  # Fitness function. Must be overridden.
  def fitness : Int32
    fitness_calculation.new.call(dna)
  end

  def fitness_calculation
    FitnessCalculation(T)
  end

  def crossover_strategy
    CrossoverStrategy(T)
  end

  def initialize(@dna : T)
  end

  # This should return whether or not the chromosome represents a complete solution.
  # Override if criterea for good enough solution can be determined.
  def solution? : Bool
    false
  end

  # Represent dna as string, mostly for development, testing and visualization.
  def inspect_dna : String
    @dna.map { |b| b ? "1" : "0" }.join
  end

  # Single-point crossover breeding at middle of bitarray.
  # Override for more sophisticated crossover.
  def breed(other_chromosome : Chromosome(T)) : Chromosome(T)
    new_dna = crossover_strategy.new.call(dna, other_chromosome.dna)
    self.class.new(new_dna)
  end

  # Picks a random bit and flips it.
  # Override for other dna datatypes.
  def mutate! : Nil
  end
end

class FitnessCalculation(T)
  def call(dna : T)
    1
  end
end

class CrossoverStrategy(T)
  def call(first_dna : T, second_dna : T)
    new_dna = T.new(first_dna.size)
    half_index = (first_dna.size // 2) - 1
    
    0.upto(first_dna.size - 1) do |i|
      new_dna[i] = i > half_index ? second_dna[i] : first_dna[i]
    end
    
    new_dna
  end
end
