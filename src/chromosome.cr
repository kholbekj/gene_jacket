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
    0
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
    new_dna = BitArray.new(@dna.size)
    half_index = (@dna.size // 2) - 1
    
    0.upto(@dna.size - 1) do |i|
      new_dna[i] = i > half_index ? other_chromosome.dna[i] : @dna[i]
    end
    
    self.class.new(new_dna)
  end

  # Picks a random bit and flips it.
  # Override for other dna datatypes.
  def mutate! : Nil
    index = (0..@dna.size - 1).to_a.sample
    @dna[index] = !@dna[index]
  end
end
