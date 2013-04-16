# represents a generator used to derive a field value. An empty object, save for a generate method that is here largely for
# documentation. Instances of this class are set up within the Template object

require ('lib/hirsute_utils.rb')

module Hirsute
  class Generator
    include Hirsute::Support
         
     def initialize(block)
       @finalizer = block
     end
     
     # do the actual work of generating a value. takes the fixed object being made as an argument
     def generate(onObj)
       result = _generate(onObj)

       # if a generator returns a generator, keep going down the chain
       while result.kind_of? Generator
         result = result.generate(onObj)
       end
       
       # if it's a range, grab the array from the range and choose one item randomly
       if result.kind_of? Range
         ary = Hirsute::Support.get_range_array(result)
         result = ary.choice
       end
       
       finish(result,onObj)
     end
     
     def _generate(onObj)
     end
     
     private
       def finish(value,onObj)
         # create a local copy for closure
         if @finalizer
           onObj.instance_exec value, &@finalizer
         else
           value
         end
       end
  end
  
  #in this case, the definition is fixed, so no need for dynamic construction
  class CompoundGenerator < Generator
      
      def initialize(generators,block)
         @generators = generators
         super(block)
      end
      
      # return the joined response of each embedded generator
      def _generate(onObj)
         ret_val = ""
         @generators.each {|gen| ret_val = ret_val + gen.generate(onObj).to_s}
         ret_val
      end
  end
  
  # convenience class for literal values (especially strings and nil) 
  class LiteralGenerator < Generator
      def initialize(value,block)
        @value = value
        super(block)
      end
      
      def _generate(onObj)
        @value
      end
   end
   
   class ReadFromFileGenerator < Generator
     
     public
       def initialize(file_name,algorithm,block)
         @file_name = file_name
         @file = File.open @file_name
         @algorithm = algorithm
         super(block)
       end
       
       def _generate(onObj)
         if @algorithm == :markov
           advance_count = rand(100)
           read_line_at(advance_count)
         elsif @algorithm == :linear
           read_line_at(1)
         else
           raise "Unknown read_from_file algorithm: " + @algorithm
         end
       
       end
      
     private
       def reset_file
         @file.close
         @file = File.open(@file_name)
       end
     
       # advances line_count lines from current location (resetting the file if necessary)
       # and returns the relevant line
       def read_line_at(line_count)
         line = ""
         (0...line_count).each do |idx|
           line = @file.gets
           
           while line && line.strip == ""
             line = @file.gets
           end
           
           if line.nil? # reached the end of the file
             reset_file
             line = read_line_at(1)
           end
         end
         line.chomp
      end
  end
  
  # generators of this type are dependant on some field in the final object already being set
  # this base class allows 
  class DependentGenerator < Generator
    def initialize(dependencyFields,block)
      @dependencyFields = dependencyFields
      super(block)
    end
    
    def dependency_fields
      if @dependencyFields.kind_of? Array
        @dependencyFields
      else
        @dependencyFields = [@dependencyFields]
        dependency_fields
      end
    end
      
  end
end