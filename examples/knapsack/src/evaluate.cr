require "./knapsack"

class First < Knapsack::ItemCombination
  def fitness_calculation
    Knapsack::ItemCombinationFitness
  end

  def crossover_strategy
    Knapsack::SinglePointCrossover
  end
end

class Second < Knapsack::ItemCombination
  def fitness_calculation
    Knapsack::ItemCombinationFitness
  end

  def crossover_strategy
    Knapsack::UniformCrossover
  end
end

FULL_RUNS = 100
MAX_GENERATIONS = 10

Evaluate.new(MAX_GENERATIONS, FULL_RUNS).run! do
  Population(First).new(200)
end

Evaluate.new(MAX_GENERATIONS, FULL_RUNS).run! do
  Population(Second).new(200)
end
