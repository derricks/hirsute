# unit tests for the histoparse subsystem of Hirsute
require 'test/unit'
require 'lib/histoparse.rb'

class TestHistoParse < Test::Unit::TestCase
  
  include Hirsute::HistoParse
  
  def testBasicParsing
    histogram = <<-HIST
       **
       
       ****
       
     | **
     | *
     | *
    HIST
    
    parsed_histogram = parse_histogram(histogram)
    buckets = parsed_histogram.histogram_buckets
    assert(!buckets.nil?)
    
    assert(buckets[0] > 0.19 && buckets[0] < 0.21)
    assert(buckets[1] > 0.39 && buckets[1] < 0.41)
    assert(buckets[2] > 0.19 && buckets[2] < 0.21)
    assert(buckets[3] > 0.09 && buckets[3] < 0.11)
    assert(buckets[4] > 0.09 && buckets[4] < 0.11)
    
  end
    
end