# Defines output modules that can translate Hirsute objects into load formats for various systems
require 'lib/hirsute_utils.rb'

module Hirsute
  
  include Support
  
  # base class for working with objects
  class Outputter
    
    attr_accessor :fields
    
    def initialize(collection)
      @collection = collection
      obj_class = Hirsute::Support.class_for_name(@collection.object_name)
      @fields = obj_class.fields
    end
    
    # allows the outputter to do any preliminary work
    def start
       _start
    end
    
    def _start;end;
    
    # cleanup work
    def finish
      _finish
    end
    
    def _finish;end;
    
    def get_file(object_name) 
      object_name + ".load"
    end
    
    # external method telling 
    def output
      #derive file name from class of object
      
      begin        
        @file = File.open(get_file(@collection.object_name),'w')
        start
      
        @collection.each {|item| _outputItem(item)}
      
        finish
      rescue Exception => e
        puts "Error #{e}"
      ensure 
        @file.close if !@file.nil?
      end
      
    end
  end
  
  
  class MySQLOutputter < Outputter
     # convenience method for getting a SQL representation of a ruby object
     def object_value_to_sql_literal(value)
       if value.nil?
          "NULL"
       elsif value.kind_of? Numeric
         value.to_s
       else
         "'#{value}'"
       end
     end
       
     def _outputItem(item)
         insert_string = "INSERT INTO #{item.class.storage_name} ("
         sql_columns = item.class.fields.map{|col_name| "'" + col_name.to_s + "'"}
         insert_string = insert_string + sql_columns.join(",") + ") VALUES ("
         
         sql_values = item.class.fields.map{|fieldName| object_value_to_sql_literal(item.get(fieldName))}
         insert_string = insert_string + sql_values.join(",") + ");\n"
         
         @file.puts(insert_string)
     end
  end
  
  class CSVOutputter < Outputter
    def get_file(name)
      name + ".csv"
    end
    
    def _start
      #output header
      header = fields.map{|field| "\"#{field}\""}.join(",")
      @file.puts header
    end
    
    def _outputItem(item)
      line = fields.map {|field| "\"#{item.send(field)}\""}.join(",")
      @file.puts line
    end
  end
  
end