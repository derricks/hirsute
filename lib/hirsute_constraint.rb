module Hirsute
  # defines the interface for a Constraint object that can correct a field that would otherwise break a constraint
  class Constraint
    def correct(field_value)
    end
  end
  
  # this just adds 
  class UniqueConstraint < Constraint
    @counter = 1
    def correct(field_value)
      ret_val = field_value.to_s + @counter.to_s
      @counter = @counter + 1
      ret_val
    end
  end
end