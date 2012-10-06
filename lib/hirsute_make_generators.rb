# the various commands that make Hirsute generators. This mostly just keeps these methods isolated

load('lib/hirsute_generator.rb')

module Hirsute
  module GeneratorMakers
    def counter(startingPoint)
        gen_make_generator {@current = startingPoint;def generate; cur_current = @current; @current = @current + 1; cur_current; end;}
    end
          
    def combination(*args)
       CompoundGenerator.new(args.map {|item| generator_from_value(item)})
    end
    
  end
end