module Neography
  class NodeTraverser
    
    # This method returns an Array of ActiveRecord objects that 
    # correspond to these Neography::Nodes.
    #
    def to_active_record_objects
      self.collect do |neo_node|
        neo_node.to_active_record_object
      end
    end
    def to_active_record
      self.to_active_record_objects
    end
    
  end
end