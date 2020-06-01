require "./knapsack"

# Rather than set up tests for the example (which is pretty cumbersome with randomness)
# Here I setup and execute my algorithm to see that things run somewhat meaningfully.
population = Population(Knapsack::ItemCombination).new(200)
population.seed
0.upto(9) do |i|
  winner = population.winner
  puts "Generation #{i}:"
  puts "Highest fitness: #{winner.fitness} (#{winner.inspect_dna})"
  puts
  population.evolve!
end

best = population.best_solution
puts "Best solution:"
puts "#{best.fitness} (#{best.inspect_dna})" if best
