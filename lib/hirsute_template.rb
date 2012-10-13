# Defines the Template class that forms the foundation of Hirsute object definitions

load('lib/hirsute_generator.rb')
load('lib/hirsute_make_generators.rb')
load('lib/hirsute_fixed.rb')
load('lib/hirsute_collection.rb')
load('lib/hirsute_utils.rb')

module Hirsute
  class Template
     include GeneratorMakers
     include Support
     
      public
        def initialize(templateName)
           @templateName = templateName
        end
            
        # has takes a hash of field name -> field generator definitions and stores them
        # for later use
        # remembering that the syntax is 
        # has 
        #   "id" => counter(1)
        # this means that counter must be a method in this class
        def has(fieldDefs)
           @fieldDefs = Hash.new
         
           # do this in a loop to have special handling for different types
           fieldDefs.each_pair {|key,value|  @fieldDefs[key] = generator_from_value(value)}
           
           # define accessors for each of the fields defined in the template 
           hashToFields(fieldDefs)
           
           # add a fields field to the class _instance_ (note that in has, no instances of the object itself yet exist)
           class_for_name(@templateName).instance_eval {
             @fields = fieldDefs.keys
             def fields; @fields; end;
           }
        end
        
        # Allows a template to have transient objects that are not going to be persisted to the data store
        # In that case, they get added as fields within the template, but get stored separately so that they're
        # not included in make
        def transients(transients)
          @transients = transients
          hashToFields(transients)
          
          class_for_name(@templateName).instance_eval {
            @transients = transients.keys
            def transients;@transients;end;
          }
        end
        
        # is_stored_in defines some meaningful name for where a generated object should be stored
        # in the final output (e.g., the name of a database table)
        def is_stored_in(storageName)
          class_for_name(@templateName).class_eval {@storage_name = storageName;attr_reader :storage_name;}
        end
      
        # makes an object based on this template definition. the 
        def make
            obj = class_for_name(@templateName).new
            @fieldDefs.each_pair {|fieldName,generator| obj.set(fieldName,generator.generate)}
            
            @transients.each_pair{|transientName,generator| obj.set(transientName,generator.generate)}
            obj
        end
      
        # makes n objects based on template and returns them as an array
        def *(count)
          ret_val = Collection.new(@templateName)
          (1..count).each {|idx| ret_val << make}
          ret_val
        end
        
     private      
      
        # refactored logic for deriving generator from a value
        def generator_from_value(value)
           if value.is_a? Generator
              value
           else
              LiteralGenerator.new(value)
           end
        end
        
        # given a hash of values, add attr_accessors for each key
        # define accessors for each of the fields defined in the template 
        def hashToFields(hash)
          class_for_name(@templateName).class_eval {
            hash.keys.each {|item| attr_accessor item.to_sym}
          }
        end
        
            
  end
end