require "gene_jacket"

# The eight queens problems is this:
# Assuming a regular chessboard (8x8), place 8 queens so that no one queen can
# take any other.
module EightQueens
  # Since we know 8 queens will have 2 be on 8 different rows, we can represent
  # the board with the position of a queen in each row.
  #

  class QueenConfiguration < Chromosome(Array(Int32))
    def self.random
      list = 8.times.map { Random.rand(8).ceil.to_i }.to_a
      new(list)
    end

    def initialize(@dna : Array(Int32))
    end

    # This is where our bit-array gets a bit hairy.
    # Probably a decent fitness function is inverse of the moves where queens
    # can take another, but for that we have to decide how often two queens can.
    # I'll not spend a lot of time on an elegant / efficient algorithm here,
    # maybe I'll revisit that after I check out other solutions to the problem.
    def fitness : Int32
      queen_positions = indices_from_dna(dna).map { |i| i + 1 }

      moves_which_invalidate_solution = 0
      queen_positions.each do |i|
        verticals = queen_positions.select do |p|
          # If the remainder of dividing by 8 is the same, they're in same column
          p % 8 == i % 8 &&
          # But she can't attack herself
          p != i
        end

        horizontals = queen_positions.select do |p|
          # If integer dividing by 8 is the same, they're in same row
          p // 8 == i // 8 &&
          # But still can't attack herself
          p != i
        end

        diagonals = queen_positions.select do |p|
          # I guess diagonals are kinda like columns, but with 7 and 9 as modulo?
          (p % 9 == i % 9 ||
           p % 7 == i % 7) &&
          p != i
        end

        moves_which_invalidate_solution += [verticals, horizontals, diagonals].flatten.size
      end

      # This is where I realize that probably my fitness function should work with floats.
      # 0 means we have a solution, and since we're not properly checking for blocked 
      # lines, we can expect out upper bound to be around 8x7 = 56.
      # It's for sure not really linear, though, so with proportial selection we'll need to
      # emphasize lower scores more.
      ((3 / moves_which_invalidate_solution) * 56).to_i32
    end

    # Let's make this easy to visually verify by printing like a chess board.
    def inspect_dna
      @dna
        .map { |b| b ? "1" : "0" }
        .each_slice(8)
        .map { |row| row.join }
        .join("\n")
    end

    # For breeding, with permutations we can't just randomly combine the dna,
    # as we'd be likely to end up with more or less than 8 queens.
    # I'm not well versed in the gallery of crossover operators yet,
    # so I'm going a bit on intuition here. Finger's *crossed*!
    def breed(other_chromosome)
      p1_positions = indices_from_dna(dna).to_set
      p2_positions = indices_from_dna(other_chromosome.dna).to_set

      # Copy the bits that the parents have in common
      final_positions = [] of Int8
      common_positions = (p1_positions & p2_positions)
      final_positions += common_positions.to_a

      # Now we need (8 - common_bits) positions selected from a mix of both parents.
      # I think it's important that I do this randomly, or we'd skew the result.
      amount_of_positions_still_needed = 8 - common_positions.size
      1.upto(amount_of_positions_still_needed) do |i|
        relevant_parent = i % 2 == 0 ? p1_positions : p2_positions
        remaining_candidate_positions = relevant_parent - final_positions
        final_positions << remaining_candidate_positions.to_a.sample
      end

      new_dna = BitArray.new(64)
      final_positions.each do |p|
        new_dna[p] = true
      end
      self.class.new(new_dna)
    end

    # Since we want to keep amount of queens, rather than flip bits we swap.
    def mutate!
      bits_to_swap = 0.upto(63).to_a.sample(2)
      dna[bits_to_swap.first], dna[bits_to_swap.last] = dna[bits_to_swap.last], dna[bits_to_swap.first]
    end

    private def indices_from_dna(dna : BitArray)
      indices = [] of Int8
      dna.each_with_index do |locus, index|
        indices << index.to_i8 if locus
      end
      indices
    end
  end

  # Yes, I chose this name because it sounds funny, sue me.
  class ConfigurationPopulation < Population
    def chromosome_class
      QueenConfiguration
    end

    def mutate?
      Random.rand < 0.02
    end

    def max_fitness
      168
    end
  end

  population = ConfigurationPopulation.new(1000)
  population.seed

  0.upto(900) do |i|
    winner = population.winner
    puts "Generation #{i}:"
    puts "Highest fitness:"
    puts winner.inspect_dna
    puts winner.fitness
    puts
    if winner.solution?
      puts "Solved!"
      exit
    end
    population.evolve!
  end
end
