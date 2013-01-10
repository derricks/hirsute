# Defines the Template class that forms the foundation of Hirsute object definitions

require('lib/hirsute_generator.rb')
require('lib/hirsute_make_generators.rb')
require('lib/hirsute_fixed.rb')
require('lib/hirsute_collection.rb')
require('lib/hirsute_utils.rb')

module Hirsute
  class Template
     include GeneratorMakers
     include Support
     
      public
        def initialize(templateName)
           @templateName = templateName
        end
        
        attr_reader :templateName
        
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
        
        # Define a set of Constraint objects that act as data integrity enforcers. For instance, if a field needs to be unique.
        # Hash is defined as field_name, requirement type
        # While these are defined as part of this class, they're actually copied over to the collection class, since that's who needs
        # to enforce the constraint
        def requires(requirements)
          class_for_name(@templateName).instance_eval {
            @requirements = requirements
            def requirements; @requirements; end;
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
          class_for_name(@templateName).instance_eval {
            @storage_name = storageName
            class << self
              attr_reader :storage_name
            end
          }
        end
      
        # makes an object based on this template definition. the 
        def make(addToSingleCollection=true)
            fieldsAlreadySet = Hash.new(false)
            dependentGenerators = Hash.new
            
            allFields = Array.new
            obj = class_for_name(@templateName).new
            
            # populate all the fields; traverse both collections of fields at once
            [@fieldDefs,@transients].each do |field_map|
              next if field_map.nil?
            
              field_map.each_pair do |fieldName,generator| 
                # if it's a dependent generator, check to see if the fields it's dependent on have been set
                if generator.kind_of? Hirsute::DependentGenerator
                  if !dependent_fields_are_set?(fieldsAlreadySet,generator)
                    dependentGenerators[fieldName] = generator
                    next
                  end
                end
                obj.set(fieldName,generator.generate(obj))
                fieldsAlreadySet[fieldName] = true;
              end
            end
            
            # now handle any dependent generators left hanging and try to spot endless loops
            cur_dependent_gens_length = dependentGenerators.size
            while(cur_dependent_gens_length > 0)
              dependentGenerators.keys.each do |field|
                generator = dependentGenerators[field]
                next if generator.nil?
                if dependent_fields_are_set?(fieldsAlreadySet,generator)
                  
                   # all dependencies are in place
                   obj.set(field,generator.generate(obj))
                   fieldsAlreadySet[field] = true
                   dependentGenerators.delete(field)
                end
              end
              
              # if the size of the hash hasn't changed, we have a problem: another pass through the loop won't change things, so it'll go forever
              raise "Dependency loop spotted in #{@templateName}. Check generators to make sure there are no circular dependencies." if dependentGenerators.size == cur_dependent_gens_length
              cur_dependent_gens_length = dependentGenerators.size
            end
            
            # if there is exactly one collection declared for this type, add this object to it
            colls = Hirsute::Collection.collections_holding_object(@templateName)
            colls[0] << obj if addToSingleCollection && colls && colls.length == 1 
            obj
        end
      
        # makes n objects based on template and returns them as an array
        def *(count)
          ret_val = Collection.new(@templateName)
          (1..count).each {|idx| ret_val << make(false)}
          ret_val
        end
        
     private      
      
        # given a hash of values, add attr_accessors for each key
        # define accessors for each of the fields defined in the template 
        def hashToFields(hash)
          class_for_name(@templateName).class_eval {
            hash.keys.each {|item| attr_accessor item.to_sym}
          }
        end
        
        def dependent_fields_are_set?(fields_set,dependent_generator)
          unset_fields = dependent_generator.dependency_fields.select {|fieldName| !fields_set[fieldName]}
          unset_fields.length == 0
        end
  end
end