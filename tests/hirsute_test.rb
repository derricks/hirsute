# unit tests for the hirsute language

require 'test/unit'
require 'lib/hirsute.rb'
require 'lib/hirsute_make_generators.rb'
require 'lib/hirsute_collection.rb'

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
  
  def testOneOfWithHistogram
    results = []
    list = ["a","b","c"]
    histogram = [0.9,0.05,0.05]
    gen = one_of(list,histogram)
    (1..1000).each do |i|
      results << gen.generate
    end
    
    a_count = (results.select {|item| item == 'a'}).length
    assert(a_count > 855 && a_count < 945)
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
  
  def testCollectionCreationWithObject
    coll = Hirsute::Collection.new("String")
    begin
      coll << 3
      flunk "Collection should not allow an inconsistent type"
    rescue Exception => e
      assert(coll.length == 0)
    end
  end
  
  def testCollectionCreationWithoutObject
    coll = Hirsute::Collection.new
    coll << 3
    begin
      coll << "test"
      flunk "Strings should not be allowed in a collection created as an integer"
    rescue
      assert(coll.length == 1)
    end
  end
  
  def testCollectionChoice
    coll = Hirsute::Collection.new("String")
    coll << "a"
    coll << "b"
    coll << "c"
    
    str = one_of(coll).generate
    assert(str=='a' || str == 'b' || str == 'c')
  end
  
  def testPostGenerateBlockExecution
    list = ['abc','apple','asparagus']
    gen = one_of(list) {|value| value[0,1]}
    result = gen.generate
    assert(result == 'a')
  end
  
  # ensure that when you create a collection for an object, that it registers itself as a holder of that object type
  def testCollectionsRegisterForObject
    objName = 'testObj'
    
    #setup, copied from hirsute.rb
    objClass = Class.new(Hirsute::Fixed)
    objClassName = Kernel.const_set(objName.capitalize.to_sym,objClass)
    
    template = Hirsute::Template.new(objName)
    
    coll1 = template * 2
    coll2 = template * 3
    all_colls = Hirsute::Collection.collections_holding_object(objName)
    assert(all_colls.length == 2)
  end
end