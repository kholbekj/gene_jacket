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
        queen_positions << index.to_i8 + 1 if locus
      end

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
      ((1 / 1 / moves_which_invalidate_solution) * 56).to_i32
    end

    # Let's make this easy to visually verify by printing like a chess board.
    def inspect_dna
      @dna
        .map { |b| b ? "1" : "0" }
        .each_slice(8)
        .map { |row| row.join }
        .join("\n")
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
  puts population.winner.inspect_dna
  puts population.winner.fitness
end
