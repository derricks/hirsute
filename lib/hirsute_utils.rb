# various utility methods

module Hirsute
  module Support
    # return the class object for the given string. Recipes for object types (e.g., a('thing'))
    # create a class definition for that object (Thing) for a variety of reasons. This provides an easy mechanism
    # for returning the class constant given a String, which is often what we have available when working
    # with the template instead of a fixed product of applying that template
    def class_for_name(className);Kernel.const_get(className.capitalize);end;
  end
    
end