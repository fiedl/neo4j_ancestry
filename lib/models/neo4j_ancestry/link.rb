module Neo4jAncestry
  def self.table_name_prefix
    'neo4j_ancestry_'
  end
  
  class Link < ActiveRecord::Base
    
    # ActiveRecord database columns
    # 
    #     create_table :neo4j_ancestry_links do |t|
    #       t.integer :parent_id
    #       t.string :parent_type
    #       t.integer :child_id
    #       t.integer :child_type
    #     end
    #
    
    belongs_to :parent, polymorphic: true
    belongs_to :child, polymorphic: true
    
    include Neoid::Relationship
  
    neoidable do |c|
      c.relationship start_node: :parent, end_node: :child, type: :is_parent_of
    end
    
  end
end 