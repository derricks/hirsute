# defines the basic functions used by the hirsute language, allowing a hirsute file to be loaded in
# usage:
#   ruby hirsute.rb <filename>
# if filename is not specified, you can use this in irb to define language items

load('lib/hirsute_template.rb')
load('lib/hirsute_collection.rb')
load('lib/hirsute_fixed.rb')

@objToTemplates = Hash.new

def storage(storage_system)
   @storage = storage_system
end

# you can use an or a as your definition
def an(objName,&block)
  a(objName) {block.call}
end

# This method defines a Template with an identifier of objName. It is the basic method for defining
# dummy objects
def a(objName, &block)
  
  # define a class with the given name. This is so that we can store class instance variables,
  # present more readable information to users, and so forth. Basically a('thing') should create 
  # a class named Thing that can be used elsewhere
  # do this here because template.instance_eval will add to this class if there's an is_stored_in method
  # used
  objClass = Class.new(Hirsute::Fixed)
  objClassName = Kernel.const_set(objName.capitalize.to_sym,objClass)
  
  # construct a new object, set self to that object
  # then yield to the block, which will call methods defined in Template
  template = Hirsute::Template.new(objName)
  if block_given?
    template.instance_eval &block  
  end
  
  @objToTemplates[objName] = template
  
  # this allows the client to do something like user * 5
  # define_method objName -> template
  self.class.send(:define_method,objName.to_sym) {template}
  
  
  template
end

# alias for each, really, but with a naming consistent with the rest of the language
def for_all(collection,&block) 
    collection.each(&block)
end

# returns a Collection of n elements that return true from the block. Note: this might return less.
def find(n,collection,&block)
end

def storage(storageSymbol)
  @storage = storageSymbol
end
  

# given an array of probabilities (as .1, .2, etc.), return the index of the item where the probability fell
# This is a finite discrete distribution http://en.wikipedia.org/wiki/Pseudo-random_number_sampling#Finite_discrete_distributions
def integer_from_histogram(probabilities)
    high_end = 1
    random_value = rand
    
    ret_val = probabilities.each_index do |idx|
      cur_prob = probabilities[idx]
      
      if random_value <= high_end && random_value > high_end - cur_prob
          break idx
      else
          high_end = high_end - cur_prob
          next
      end
    end
    
    ret_val   
end

load ARGV[0] if ARGV[0]