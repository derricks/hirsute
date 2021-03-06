# defines a Collection interface for Hirsute::Fixed objects
# why not just an array? because eventually this might need to deal with objects in a text file for memory purposes, but I want to provide a consistent interface
# in the short-term though, just wrap an array
require('lib/hirsute_utils.rb')
require('lib/hirsute_template.rb')

module Hirsute
  
   class Collection
       include Enumerable
       # hold a class variable that contains all the collections for specific users
       @object_names_to_collections = Hash.new
       
       #class methods
       # return a list of all collections holding objects of the specified type
       def self.collections_holding_object(object_name)
         @object_names_to_collections[object_name]
       end
       
       def self.registerCollectionForObject(collection,objectName)
         if @object_names_to_collections[objectName]
           @object_names_to_collections[objectName] << collection
         else
           @object_names_to_collections[objectName] = [collection]
         end
       end
        
       include Enumerable
       include Support
       
       attr_reader :object_name
       
       def initialize(objectName)
          @object_name = objectName # defines the object type kept in this collection
          Hirsute::Collection.registerCollectionForObject(self,objectName)
          @collection = Array.new
       end
       
       def each(&block)
          @collection.each(&block)
       end
       
       def <<(element)
          # allows for deferred definition of type
           if element.kind_of? Hirsute::Template
             self.<<(element.make(false))
             return
           end
           
           if element.kind_of? Hirsute::Collection
              element.each {|item| self << item}
              return
           end
                      
           raise "Only objects of type #{@object_name} can be stored in this collection" if element.class != class_for_name(@object_name)    
           
           @collection << element
      end
       
       def length; @collection.length; end;
       
       # so that collections can be used with the one_of generator
       def choice
         @collection.choice
       end
   end
end