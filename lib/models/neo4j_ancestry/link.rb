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
    
    after_save :neo_sync
    before_destroy :neo_delete
    def before_remove
      # This method is called from `active_record_associations_patches`.
      neo_delete
    end
    
    def neo_sync
      Neo4jDatabase.execute("
        match (parent {#{parent.neo_id}}), (child {#{child.neo_id}})
        merge (parent)-[relation:#{neo_relation_type}]->(child)
        return relation
      ")
    end
    def neo_delete
      Neo4jDatabase.execute("
        match 
          (parent {#{parent.neo_id}}), 
          (child {#{child.neo_id}}),
          (parent)-[relation:#{neo_relation_type}]->(child)
        delete relation
      ")
    end
    def neo_relation_type
      :is_parent_of
    end
    
  end
end