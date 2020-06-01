require "./eight_queens"

population = EightQueens::ConfigurationPopulation(EightQueens::QueenConfiguration).new(1000)
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
