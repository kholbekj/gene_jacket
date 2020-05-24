require "./spec_helper"
require "../src/chromosome"

class Cat < Chromosome(BitArray)
  getter dna
  getter current_population

  def initialize(@dna : BitArray = BitArray.new(8))
  end

  def self.random
    new(BitArray.new(8))
  end

  def self.from_string(dna_string)
    dna = BitArray.new(8)
    dna_string.chars.each_with_index do |value, index|
      dna[index] = !value.to_i.zero?
    end
    self.new(dna)
  end

  def fitness : Int32
    inspect_dna.to_i(2)
  end

  def solution? : Bool
    false
  end
  
  def mutate!
    dna[0] = true
  end
end

describe Chromosome do
  it "subclass can instatiate" do
    Cat.new.should be_a(Cat)
  end

  describe "#inspect_dna" do
    it "renders as binary string" do
      Cat.new.inspect_dna.should eq("00000000")
    end
  end

  describe "#breed" do
    it "does single point crossover by default" do
      mom = Cat.new
      dad = Cat.from_string("11111111")
      kitten = mom.breed(dad)

      kitten.inspect_dna[0..3].should eq(mom.inspect_dna[0..3])
      kitten.inspect_dna[4..7].should eq(dad.inspect_dna[4..7])
    end
  end

  describe "#mutate!" do
    it "flips a random bit" do
      cat = Cat.new
      cat.mutate!
      cat.inspect_dna.count("1").should eq(1)
    end
  end
end
