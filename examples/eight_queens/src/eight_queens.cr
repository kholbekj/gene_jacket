require "gene_jacket"

# The eight queens problems is this:
# Assuming a regular chessboard (8x8), place 8 queens so that no one queen can
# take any other.
module EightQueens
  # Technically the encoding here should be trivial, but I wonder if I can
  # make life easier for the fitness function. Let's start by just doing the
  # simple thing: a 64 length bit-array with 8 1's.
  #
  # In this example we are dealing with permutations (there's always 8 1's and
  # 56 0's, only the order changes), which switches up how we do crossover and
  # mutation.


  class QueenConfiguration < Chromosome
    def self.random
      bits = BitArray.new(64)

      0.upto(63).to_a.sample(8).each do |i|
        bits[i] = true
      end

      new(bits)
    end

    # This is where our bit-array gets a bit hairy.
    # Probably a decent fitness function is inverse of the amount of queens
    # which can take another, but for that we have to decide if two queens can.
    # I'll not spend a lot of time on an elegant / efficient algorithm here,
    # maybe I'll revisit that after I check out other solutions to this.
    def fitness : Int32
      queen_positions = [] of Int8
      dna.each_with_index do |locus, index|
        queen_positions << index.to_i8 if locus
      end
      queen_positions.map(&.to_i32).sum
    end
  end

  # Yes, I chose this name because it sounds funny, sue me.
  class ConfigurationPopulation < Population
    def chromosome_class
      QueenConfiguration
    end
  end

  population = ConfigurationPopulation.new(1)
  population.seed
  puts population.winner.fitness
end
