# defines a Collection interface for Hirsute::Fixed objects
# why not just an array? because eventually this might need to deal with objects in a text file for memory purposes, but I want to provide a consistent interface
# in the short-term though, just wrap an array

module Hirsute
   class Collection
       include Enumerable
       
       def initialize
          @collection = Array.new
       end
       
       def each(&block)
          @collection.each(&block)
       end
       
       def <<(other);  @collection << other;  end;
       
       def length; @collection.length; end;
          
   end
end