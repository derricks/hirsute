# Defines output modules that can translate Hirsute objects into load formats for various systems

module Hirsute
  
  # base class for working with objects
  class Outputter
    
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
    
    # external method telling 
    def output(collection)
      #derive file name from class of object
      
      begin
        @file = File.open(collection.object_name + '.load','w')
        start
      
        collection.each {|item| _outputItem(item)}
      
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
  
end