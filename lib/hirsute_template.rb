# Defines the Template class that forms the foundation of Hirsute object definitions

load('lib/hirsute_generator.rb')
load('lib/hirsute_fixed.rb')
load('lib/hirsute_collection.rb')

module Hirsute
  class Template
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
        end
      
        # makes an object based on this template definition. the 
        def make
            obj = Fixed.new
            @fieldDefs.each_pair {|fieldName,generator| obj.set(fieldName,generator.generate)}
            obj
        end
      
        # makes n objects based on template and returns them as an array
        def *(count)
          ret_val = Collection.new
          (1..count).each {|idx| ret_val << make}
          ret_val
        end
      
        # generator methods. see note above has for why they're defined here
        def counter(startingPoint)
            gen_make_generator {@current = startingPoint;def generate; cur_current = @current; @current = @current + 1; cur_current; end;}
        end
              
        def combination(*args)
           CompoundGenerator.new(args.map {|item| generator_from_value(item)})
        end
        
     private      
      
        # generic method for making a generator based off of a block. useful for simple cases.
        def gen_make_generator(&block)
           gen = Generator.new
           gen.instance_eval(&block)
           gen
        end
        
        # refactored logic for deriving generator from a value
        def generator_from_value(value)
           if value.is_a? Generator
              value
           else
              LiteralGenerator.new(value)
           end
        end
            
  end
end