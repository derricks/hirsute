# defines the basic functions used by the hirsute language, allowing a hirsute file to be loaded in
# usage:
#   ruby hirsute.rb <filename>
# if filename is not specified, you can use this in irb to define language items

load('./hirsute_template.rb')

@objToTemplates = Hash.new

# you can use an or a as your definition
def an(objName,&block)
  a(objName) {block.call}
end

# This method defines a Template with an identifier of objName. It is the basic method for defining
# dummy objects
def a(objName, &block)
  
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




load ARGV[0] if ARGV[0]