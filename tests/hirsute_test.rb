# unit tests for the hirsute language

require 'test/unit'
require 'lib/hirsute.rb'
require 'lib/hirsute_make_generators.rb'
require 'lib/hirsute_collection.rb'
require 'lib/hirsute_utils.rb'

class TestHirsute < Test::Unit::TestCase
  include Hirsute::GeneratorMakers
  include Hirsute::Support
  
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
    coll = Hirsute::Collection.new('fixnum')
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
  
  # tests that is_template works
  def testIsTemplate
    testObj2 = Hirsute::Template.new('testObj2') 
    assert(is_template(testObj2))    
  end
  
  def testCollectionRejectsDifferentObject
    template1 = make_template('testCollectionRejectsDifferentObject1')
    template2 = make_template('testCollectionRejectsDifferentObject2')
    
    coll1 = template1 * 2
    
    begin
       coll1 << template2
       assert(false)
    rescue
       assert(true)
    end
  end
  
  # ensure that the << operator works properly when appending a template (i.e., it makes a new object rather than appending the template)
  def testAppendWithTemplate
    testObj3 = make_template('testObj3') {
       has :id => counter(1)
    }
     
    coll = testObj3 * 1
    coll << testObj3
    
    # either line would have raised an exception if the collection thought it was an invalid type (see test above)
    assert(true)
  end
  
  def testNestedGenerators
    template = make_template('testNestedGenerators') {
      has :id => one_of([one_of([1,2,3]),one_of([4,5,6])])
    }
    obj = template.make
    assert(obj.id == 1 || obj.id == 2 || obj.id == 3 || obj.id == 4 || obj.id == 5 || obj.id == 6)
  end  
  
  def testSubset
    template = make_template('testSubset') {
        has :item => subset(one_of([1,2,3]),
                            one_of(['a','b','c']),
                            one_of([4,5,6]))
    }
    obj = template.make
    assert(obj.item.length <= 3 && obj.item.length > 0)
  end
  
  def testAppendCollectionToCollection
    template = make_template('testAppendCollectionToCollection')
    coll1 = template * 3
    coll2 = template * 4
    coll1 << coll2
    assert(coll1.length == 7)
  end
  
  def testAnyObject
    template = make_template('testAnyObject') {
      has :id => counter(1)
    }
    coll1 = template * 3
    coll2 = template * 4
    greaterThan5 = any(template) do |item|
      item.id > 5
    end
    assert(greaterThan5.id > 5)
    
    equals2 = any(template) do |item|
      item.id == 2
    end
    assert(equals2.id == 2)
  end
end