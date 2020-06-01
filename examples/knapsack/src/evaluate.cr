require "./knapsack"
Evaluate.new(10, 10).run! do
  Knapsack::CombinationPopulation.new(200)
end
