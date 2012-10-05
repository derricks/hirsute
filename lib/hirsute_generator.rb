# represents a generator used to derive a field value. An empty object, save for a generate method that is here largely for
# documentation. Instances of this class are set up within the Template object

module Hirsute
  class Generator
           
     def generate
       ""
     end
  end
  
  #in this case, the definition is fixed, so no need for dynamic construction
  class CompoundGenerator < Generator
      
      def initialize(generators)
         @generators = generators
      end
      
      def generate
         ret_val = ""
         @generators.each {|gen| ret_val = ret_val + gen.generate.to_s}
         ret_val
      end
  end
end