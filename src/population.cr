# Keeps track of population, generations, selection.
abstract class Population
  getter generation
  
  abstract def chromosome_class

  def initialize(@n : Int32)
    @current_population = [] of Chromosome
    @generation = 0
  end

  # Seed the genesis generation.
  def seed(population : Array(Chromosome) = [] of Chromosome)
    if population.any?
      @current_population = population
      return
    end

    @n.times do
      @current_population << chromosome_class.random
    end
  end

  # Calls fitness function on ALL chromosomes, and returns highest.
  # Be mindful of the expense.
  def winner
    raise "Empty population" if @current_population.empty?
    @current_population.max_by(&.fitness)
  end

  # Selects chromosomes for breeding (using `#select_pair`), creates the next generation.
  # Adds random mutation depending on `#mutate?`
  def evolve!
    @generation += 1
    new_population = [] of Chromosome
    @n.times do
      pair = select_pair
      offspring = pair.first.breed(pair.last)
      offspring.mutate! if mutate?
      new_population << offspring
    end
    @current_population = new_population
  end

  # Select a pair of chromosomes using proportional selection.
  def select_pair
    # Utterly insane way to do this, not performant at all.
    # Probably a slightly better way would be to order by fitness and pick a
    # random number between 0 and the sum, then iterated and subtract.

    weighted_candidates = [] of Chromosome
    @current_population.each do |c|
      c.fitness.times do
        weighted_candidates << c
      end
    end
    # Avoid picking the same parent twice (we should use elitims to preserve genes instead)
    first = weighted_candidates.sample
    second = weighted_candidates.reject { |c| c == first }.sample
    [first, second]
  end

  # A bit naive perhaps, but easy to override.
  def mutate?
    Random.rand < 0.05
  end
end
