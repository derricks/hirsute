# this represents a fixed object created from a template
module Hirsute
  class Fixed
      def initialize
         @fields = Hash.new
      end
      
      def set(field,value)
         @fields[field] = value
      end
      
      def get(field); @fields[field];end
      
      def fields; @fields.keys; end
      
  end
end