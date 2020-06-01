require "./eight_queens.cr"

Evaluate.new(100, 20).run! do
  EightQueens::ConfigurationPopulation(EightQueens::QueenConfiguration).new(1000)
end

Evaluate.new(100, 20).run! do
  EightQueens::ConfigurationPopulation(EightQueens::QueenConfiguration).new(200)
end
