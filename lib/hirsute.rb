# defines the basic functions used by the hirsute language, allowing a hirsute file to be loaded in
# usage:
#   ruby hirsute.rb <filename>
# if filename is not specified, you can use this in irb to define language items

# store the absolute path of the file (if present) to ensure we don't lose track during chdirs
ABS_HRS_FILE = File::expand_path(ARGV[0]) if ARGV[0]

Dir::chdir(File::dirname(__FILE__) + "/..")

load('lib/hirsute_template.rb')
load('lib/hirsute_collection.rb')
load('lib/hirsute_fixed.rb')
load('lib/hirsute_output.rb')

@outputters = {:mysql => Hirsute::MySQLOutputter.new}

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

# tells Hirsute to output the given collection to the given storage system (or to generate the files necessary for that)
# if no storage symbol is passed in, this will use 
def finish(collection,storageSymbol = nil)
  raise "No storage defined. Use 'storage <symbol>' to define a storage type" if @storage.nil? && storageSymbol.nil?
  
  if storageSymbol.nil?
    @outputters[@storage].output(collection)
  else
    @outputters[storageSymbol].output(collection)
  end
end
  

# given an array of probabilities (as .1, .2, etc.), return the index of the item where the probability fell
# This is a finite discrete distribution http://en.wikipedia.org/wiki/Pseudo-random_number_sampling#Finite_discrete_distributions
def integer_from_histogram(probabilities)
  Hirsute::Support.integer_from_histogram(probabilities)
end

if ARGV[0]
  Dir::chdir(File::dirname(ABS_HRS_FILE))
  load ABS_HRS_FILE
end
