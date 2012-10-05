# unit tests for the hirsute language

require 'test/unit'
require 'lib/hirsute.rb'

class TestHiruste < Test::Unit::TestCase
  
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
end