# unit tests for the hirsute language

require 'test/unit'
require 'lib/hirsute.rb'
require 'lib/hirsute_make_generators.rb'

class TestHirsute < Test::Unit::TestCase
  include Hirsute::GeneratorMakers
  
  # test functionality of the histogram distribution
  def testIntegerFromHistogram1
    
    # define a very skewed histogram
    histogram_a = [0.9,0.05,0.05]
    values_a = Array.new(histogram_a.length,0)
    
    (1..1000).each do |i|
      index = integer_from_histogram(histogram_a)
      values_a[index] = values_a[index] + 1
    end
    
    # check for 5% tolerance
    assert(values_a[0] > 855 && values_a[0] < 945)
    
  end
  
  def testOneOfGenerator
    
    domains = ["gmail.com","yahoo.com","ea.com"]
    domain = one_of(domains).generate
    assert(domain == 'gmail.com' || domain == 'yahoo.com' || domain = 'ea.com')
  end
  
  def testFileRead
    gen = read_from_file('tests/first_names.txt',:linear)
    line = gen.generate
    assert(line == 'Derrick')
    
    # toss the rest
    (1..7).each do |i|
      line = gen.generate
    end
    
    line = gen.generate() # should have wrapped around
    assert(line == 'Derrick')
  end
end