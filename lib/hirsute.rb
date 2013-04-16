# defines the basic functions used by the hirsute language, allowing a hirsute file to be loaded in
# usage:
#   ruby hirsute.rb <filename>
# if filename is not specified, you can use this in irb to define language items

require('lib/hirsute_utils.rb')
require('lib/hirsute_template.rb')
require('lib/hirsute_collection.rb')
require('lib/hirsute_fixed.rb')
require('lib/hirsute_output.rb')

# store the absolute path of the file (if present) to ensure we don't lose track during chdirs
ABS_HRS_FILE = File::expand_path(ARGV[0]) if ARGV[0]

Dir::chdir(File::dirname(__FILE__) + "/..")


include Hirsute::Support

@outputters = {:mysql => Hirsute::MySQLOutputter,
               :csv   => Hirsute::CSVOutputter}

@objToTemplates = Hash.new

def storage(storage_system)
   @storage = storage_system
end

def storage_options(options = Hash.new)
  @storage_options = options
end

# you can use an or a as your definition
def an(objName,&block)
  a(objName) {block.call}
end

# This method defines a Template with an identifier of objName. It is the basic method for defining
# dummy objects
def a(objName, &block)
  
  template = make_template(objName,&block)

  @objToTemplates[objName] = template
  
  # this allows the client to do something like user * 5
  # define_method objName -> template
  self.class.send(:define_method,objName.to_sym) {template}
  
  
  template
end

# iterates over every object of the specified type across any collection holding that type
# usage: foreach user {|cur_user|}
# if you only want to iterate over one collection, use that collection's each method
def foreach(objTemplate)
  #find every collection that has registered for this type of object (in the call you get the template)
  colls = Hirsute::Collection.collections_holding_object(objTemplate.templateName)
  colls.each {|coll| coll.each {|item| yield item if block_given?}}
end

# return any object in any collection that meets the criteria passed in a block
def any(objTemplate,&block)
  every(objTemplate,&block).choice
end

# return every object of a given type, combined from any collections that might include that type. If a block is passed, only elements returning true from the
# block will be returned
def every(objTemplate)
  results = Array.new
  foreach(objTemplate) do |item|
    results << item if !block_given?
    results << item if block_given? && (yield item)
  end
  results  
end

# tells Hirsute to output the given collection to the given storage system (or to generate the files necessary for that)
# if no storage symbol is passed in, this will use the default set with the storage command
def finish(collection,storageSymbol = nil)
  raise "No storage defined. Use 'storage <symbol>' to define a storage type" if @storage.nil? && storageSymbol.nil?
  
  if storageSymbol.nil?
    @outputters[@storage].new(collection,@storage_options).output
  else
    @outputters[storageSymbol].new(collection,@storage_options).output
  end
end

# returns an empty collection
def collection(objectName)
  Hirsute::Collection.new(objectName)
end

# returns an empty collection of the specified template type
def collection_of(template)
  collection template.templateName
end

# pick an item from an array based on an optional histogram
def pick_from(options,histogram = nil)
  random_item_with_histogram(options,histogram)
end
  

if ARGV[0]
  Dir::chdir(File::dirname(ABS_HRS_FILE))
  load ABS_HRS_FILE
end
