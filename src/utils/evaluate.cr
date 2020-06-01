require "../population"
require "colorize"

class Evaluate
  @times : Int32
  @max_generations : Int32
  @runs : Array(Hash(String, Float64 | Int32))

  def initialize(@max_generations, @times)
    @runs = Array(Hash(String, Float64 | Int32)).new
  end

  def run!
    puts "Running algorithm #{@times} times, stay put"

    1.upto(@times) do |run|
      meta = {} of String => (Float64 | Int32)
      meta["best"] = 0
      meta["solved"] = 0

      population = yield
      population.seed

      0.upto(@max_generations) do |i|
        winner = population.winner
        if winner.fitness > meta["best"]
          meta["best"] = winner.fitness.to_f 
          meta["found_at"] = i
        end

        if winner.solution?
          meta["solved"] = 1
          break
        end
        population.evolve!
      end

      percent_done = (run / @times * 100).ceil.to_i
      progress_bar = ("*" * (percent_done)).colorize(:green).to_s + "." * (100 - percent_done)
      print "#{progress_bar} \r"
      @runs << meta
    end
    puts
    puts "Evaluation complete!"
    puts "Highest fitness: #{@runs.map {|r| r["best"]}.max }"
    puts "Average highest fitness: #{@runs.map {|r| r["best"] }.sum / @runs.size}"
    puts "Average generational convergence: #{@runs.map {|r| r["found_at"] }.sum / @runs.size}"
    puts "Solved #{@runs.map {|r| r["solved"] }.sum / @runs.size * 100} %"
  end
end
