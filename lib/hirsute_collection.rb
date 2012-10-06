# defines a Collection interface for Hirsute::Fixed objects
# why not just an array? because eventually this might need to deal with objects in a text file for memory purposes, but I want to provide a consistent interface
# in the short-term though, just wrap an array
require('lib/hirsute_utils.rb')

module Hirsute
   class Collection
       include Enumerable
       include Support
       
       attr_reader :object_name
       
       def initialize(objectName)
          @object_name = objectName # defines the object type kept in this collection
          @collection = Array.new
       end
       
       def each(&block)
          @collection.each(&block)
       end
       
       def <<(element)
           raise "Only objects of type #{@object_name} can be stored in this collection" if element.class != class_for_name(@object_name)    
           
           @collection << element
      end
       
       def length; @collection.length; end;
          
   end
end