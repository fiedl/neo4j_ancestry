module Neography
  class Node
    
    # This method returns the ActiveRecord that corresponds to this
    # Neography::Node. 
    #
    def to_active_record_object
      self["active_record_class"].constantize.find self["active_record_id"]
    end
    def to_active_record
      self.to_active_record_object
    end
    
  end
end