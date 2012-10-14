# the various commands that make Hirsute generators. This mostly just keeps these methods isolated

load('lib/hirsute_generator.rb')
require('lib/hirsute_utils.rb')

module Hirsute
  module GeneratorMakers
    include Hirsute::Support
    
    public
      def counter(startingPoint)
          gen_make_generator {@current = startingPoint;def generate; cur_current = @current; @current = @current + 1; cur_current; end;}
      end
          
      def combination(*args)
         CompoundGenerator.new(args.map {|item| generator_from_value(item)})
      end
    
      # pick one of the itmes in the list randomly
      def one_of (list,histogram = nil)
        if !histogram
          gen_make_generator {@options = list; def generate; @options.choice; end;}
        else
          gen_make_generator {
            @options = list
            @histogram = histogram
            def generate
              n = integer_from_histogram(@histogram)
              @options[n]
            end
          }
        end
      end
      
      # reads from file, using each line as the result of the generation
      # algorithm defines the style of reading lines. The default is :markov
      # which picks a random number, reads n lines in, returns that, and then
      # picks another random number and reads n more lines in
      def read_from_file(file_name,algorithm=:markov)
        ReadFromFileGenerator.new(file_name,algorithm)
      end
      
      # pull items in sequence from an array. once it reaches the end, reset
      def read_from_sequence(array)
        raise "List must have at least one item" if array.length == 0
        gen_make_generator {
          @items = array
          @index = 0
          
          def generate
            item = @items[@index]
            if item
              @index = @index + 1
              item
            else
              @index = 0
              generate
            end
          end
        }
      end
    
    private
      # generic method for making a generator based off of a block. useful for simple cases.
      def gen_make_generator(&block)
         gen = Generator.new
         gen.instance_eval(&block)
         gen
      end
    
  end
end