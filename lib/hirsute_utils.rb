# various utility methods

module Hirsute
  module Support
    
    # store a map of range objects to its constituent array. But we want to store it within the Module's eigenclass so it's shared
    # across the code base
    Hirsute::Support.instance_eval {@rangeToArray = Hash.new}
    
    # return the class object for the given string. Recipes for object types (e.g., a('thing'))
    # create a class definition for that object (Thing) for a variety of reasons. This provides an easy mechanism
    # for returning the class constant given a String, which is often what we have available when working
    # with the template instead of a fixed product of applying that template
    def class_for_name(className);Kernel.const_get(className.capitalize);end;
    
    
    # given an array of probabilities, return an integer (between 0 and length of probabilities) based on the probabilities passed in
    # in other words, [.9,.05,.05] would return 0 approximately 90% of the time.
    def integer_from_histogram(probabilities)
      
      high_end = 1
      random_value = rand
    
      final_idx = 0
      ret_val = probabilities.each_index do |idx|
        cur_prob = probabilities[idx]
      
        if random_value <= high_end && random_value > high_end - cur_prob
           final_idx = idx
           break
        else
            high_end = high_end - cur_prob
            next
        end
      end
      final_idx   
   end
   
   def random_item_with_histogram(list,probabilities)
     probabilities.nil? || !probabilities.length ? list.choice : list[integer_from_histogram(probabilities)]
   end
  
   def is_template(obj)
     obj.kind_of? Hirsute::Template
   end
   
   # refactored code for making/registering a template and class type
   def make_template(objName,&block)
     # define a class with the given name. This is so that we can store class instance variables,
     # present more readable information to users, and so forth. Basically a('thing') should create 
     # a class named Thing that can be used elsewhere
     # do this here because template.instance_eval will add to this class if there's an is_stored_in method
     # used
     objClass = Class.new(Hirsute::Fixed)
     Kernel.const_set(objName.capitalize.to_sym,objClass)

     # construct a new object, set self to that object
     # then yield to the block, which will call methods defined in Template
     template = Hirsute::Template.new(objName)
     if block_given?
       template.instance_eval &block  
     end
     return template

   end

   # refactored logic for deriving generator from a value
   def generator_from_value(value,&block)
      if value.is_a? Generator
         value
      else
         LiteralGenerator.new(value,block)
      end
   end
   
   # Given a range object, select an item randomly from it. This method hashes range -> range.to_a for speed
   def random_from_range(range)    
     ary = get_range_array(range)
   end
   
   # Gets the array associated with a range from the cache, or adds an entry if it's not there
   # refactored for unit testing
   # todo: make private and call
   def Support.get_range_array(range)
     ary = @rangeToArray[range]
     if !ary
        ary = range.to_a
        @rangeToArray[range] = ary
     end
     ary        
   end
  end
  
  
    
end