module Neography
  class Node
    
    # This method returns the ActiveRecord that corresponds to this
    # Neography::Node. 
    #
    def to_active_record_object
      self["ar_type"].constantize.find self["ar_id"]
    end
    def to_active_record
      self.to_active_record_object
    end
    
  end
end