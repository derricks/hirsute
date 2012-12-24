# represents a generator used to derive a field value. An empty object, save for a generate method that is here largely for
# documentation. Instances of this class are set up within the Template object

require ('lib/hirsute_utils.rb')

module Hirsute
  class Generator
    include Hirsute::Support
         
     def initialize(block)
       @finalizer = block
     end
     
     def finish(value)
       if @finalizer
         @finalizer.call(value)
       else
         value
       end
     end
     
     def generate
       result = _generate

       # if a generator returns a generator, keep going down the chain
       while result.kind_of? Generator
         result = result.generate
       end
       finish(result)
     end
     
     def _generate
     end
  end
  
  #in this case, the definition is fixed, so no need for dynamic construction
  class CompoundGenerator < Generator
      
      def initialize(generators,block)
         @generators = generators
         super(block)
      end
      
      # return the joined response of each embedded generator
      def _generate
         ret_val = ""
         @generators.each {|gen| ret_val = ret_val + gen.generate.to_s}
         ret_val
      end
  end
  
  # convenience class for literal values (especially strings and nil) 
  class LiteralGenerator < Generator
      def initialize(value,block)
        @value = value
        super(block)
      end
      
      def _generate
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
       
       def _generate
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
       # and returns the relevant lie
       def read_line_at(line_count)
         line = ""
         (0...line_count).each do |idx|
           line = @file.gets
           
           while line && line.strip != ""
             line = @file.gets
           end
           
           if line.nil? # reached the end of the file
             reset_file
             line = @file.gets
           end
         end
         line.chomp
      end
  end
end