# various utility methods

module Hirsute
  module Support
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
    
      ret_val = probabilities.each_index do |idx|
        cur_prob = probabilities[idx]
      
        if random_value <= high_end && random_value > high_end - cur_prob
            break idx
        else
            high_end = high_end - cur_prob
            next
        end
      end
    
      ret_val   
   end
    
  end
    
end