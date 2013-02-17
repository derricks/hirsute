# Defines output modules that can translate Hirsute objects into load formats for various systems
require 'lib/hirsute_utils.rb'

module Hirsute
  
  include Support
  
  # base class for working with objects
  class Outputter
    
    attr_accessor :fields
    
    def initialize(collection,options=Hash.new)
      @collection = collection
      @obj_class = Hirsute::Support.class_for_name(@collection.object_name)
      @fields = @obj_class.fields
      @options = options
    end
    
    def get_storage_option(option,default=nil)
      return default if !@options
      
      retVal = @options[option]
      if retVal != nil
        retVal
      else
        default
      end
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
    
    MySQLOutputter::DEFAULT_MAX_PACKET = 1048576
    
    def _start
      @cur_statement = insertStringBase
    end
    
     def _outputItem(item)
         # add VALUES(...) to existing string only if the existing string plus the values line is smaller than mox_allowed_packet
         
         value_string = " VALUES (" + @fields.map{|column| object_value_to_sql_literal(item.get(column))}.join(",") + "),"
         
         if @cur_statement.length + value_string.length > get_storage_option(:max_allowed_packet,MySQLOutputter::DEFAULT_MAX_PACKET)
           # the current statement plus the addition would be too large. so output current statement, reset, start again
           output_current
           @cur_statement = insertStringBase
         end
           
         @cur_statement << value_string
     end
     
     def _finish
       output_current # flush the last entry
     end

     private
     
       def output_current
         @file.puts(@cur_statement[0...-1] << ";\n") # trim the tailing comma that comes from the last value_string
       end
       
       def insertStringBase
         "INSERT INTO #{@obj_class.storage_name} (" +
             @fields.map{|column| column.to_s}.join(",") +
             ") "
       end
       
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
       
  end
  
  class CSVOutputter < Outputter
    def get_file(name)
      name + ".csv"
    end
    
    def _start
      #output header
      header = fields.map{|field| "\"#{field}\""}.join(separator)
      @file.puts header
    end
    
    def _outputItem(item)
      line = fields.map {|field| "\"#{item.send(field)}\""}.join(separator)
      @file.puts line
    end
  end
  
  private
    def separator
      get_storage_option(:separator,",")
    end
  
end