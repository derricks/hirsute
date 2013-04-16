# the various commands that make Hirsute generators. This mostly just keeps these methods isolated

require('lib/hirsute_generator.rb')
require('lib/hirsute_utils.rb')
require('lib/histoparse.rb')

module Hirsute
  DEFAULT = :hirsute_default
  module GeneratorMakers
    include Hirsute::Support
    include Hirsute::HistoParse
    
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
          histogram_buckets = histogram
          histogram_buckets = parse_histogram(histogram).histogram_buckets if histogram.kind_of? String
          
          gen_make_generator(block) {
            @options = list
            @histogram = histogram_buckets
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
      
      # fork to different generators depending on the value of a particular field within the object
      # a value of DEFAULT can be used as a catch-all. If DEFAULT is not defined, a field value that isn't defined will cause
      # nil to be returned
      def depending_on(field,options,&block)
        gen = DependentGenerator.new(field,block)
        gen.instance_eval {
          @options = options
          @field = field
          
          # note that this generator won't be activated until the field we want is set
          def _generate(onObj)
            field_value = onObj.get(@field)
            if @options[field_value]
              @options[field_value]
            elsif @options[DEFAULT]
              @options[DEFAULT]
            else
              nil
            end
          end
          
        }
        gen
      end
      
      # Force a generator to not run until the given fields are set
      def requires_field(field,generator,&block)
        # this leverages existing depending_on behavior, just passing a set of options with one path
        options = {DEFAULT => generator}
        depending_on(field,options,&block)
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