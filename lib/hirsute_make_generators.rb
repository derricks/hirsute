# the various commands that make Hirsute generators. This mostly just keeps these methods isolated

load('lib/hirsute_generator.rb')
require('lib/hirsute_utils.rb')

module Hirsute
  module GeneratorMakers
    include Hirsute::Support
    
    public
      # A generator that increments values from a starting point. Good for IDs
      def counter(startingPoint=1,&block)
          gen_make_generator(block) {@current = startingPoint;def _generate(onObj); cur_current = @current; @current = @current + 1; cur_current; end;}
      end
          
      # A generator that combines all the generators passed in.
      def combination(*args,&block)
         CompoundGenerator.new(args.map {|item| generator_from_value(item)},block)
      end
      
      # given a list of generators,  pick between 1 and n of them and return a CompoundGenerator based off the subset
      def subset(*args,&block)
        gen_make_generator(block) {
          @generators = args.map {|item| generator_from_value(item)}
          @block = block
          def _generate(onObj)
            count = rand(@generators.length)
            subset = @generators[0..count]

            CompoundGenerator.new(subset,@block)
          end
        }
      end
    
      # pick one of the itmes in the list randomly
      def one_of (list,histogram = nil,&block)
        if !histogram
          gen_make_generator(block) {@options = list; def _generate(onObj); @options.choice; end;}
        else
          gen_make_generator(block) {
            @options = list
            @histogram = histogram
            def _generate(onObj)
              random_item_with_histogram(@options,@histogram)
            end
          }
        end
      end
      
      # reads from file, using each line as the result of the generation
      # algorithm defines the style of reading lines. The default is :markov
      # which picks a random number, reads n lines in, returns that, and then
      # picks another random number and reads n more lines in
      def read_from_file(file_name,algorithm=:markov,&block)
        ReadFromFileGenerator.new(file_name,algorithm,block)
      end
      
      # pull items in sequence from an array. once it reaches the end, reset
      def read_from_sequence(array,&block)
        raise "List must have at least one item" if array.length == 0
        gen_make_generator(block) {
          @items = array
          @index = 0
          
          def _generate(onObj)
            item = @items[@index]
            if item
              @index = @index + 1
              item
            else
              @index = 0
              generate(onObj)
            end
          end
        }
      end
      
    private
      # generic method for making a generator based off of a block. useful for simple cases.
      def gen_make_generator(finishProc=nil,&block)
         gen = Generator.new(finishProc)
         gen.instance_eval(&block)
         gen
      end
    
  end
end