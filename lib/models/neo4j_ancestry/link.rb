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
    #       t.datetime :valid_from
    #       t.datetime :valid_to
    #     end
    #
    
    belongs_to :parent, polymorphic: true
    belongs_to :child, polymorphic: true
    
    include Neoid::Relationship
  
    neoidable do |c|
      c.relationship start_node: :parent, end_node: :child, type: :is_parent_of
      c.field :valid_from do
        valid_from.try(:to_time).try(:to_s, :db)
      end
      c.field :valid_to do
        valid_to.try(:to_time).try(:to_s, :db)
      end
    end
    
    before_create :set_valid_from_to_current_time
    
    def set_valid_from_to_current_time
      self.valid_from = Time.zone.now
    end
    private :set_valid_from_to_current_time
    
    # This method marks a link as expired, i.e. sets the 
    # `valid_to` attribute to the current datetime.
    #
    # The record is updated without the need for calling `save`. 
    #
    def expire
      self.expire_at Time.zone.now
    end
    
    # This method tells a link to expire at a certain datetime,
    # i.e. updates the `valid_to` attribute.
    #
    def expire_at(datetime)
      self.update_attribute(:valid_to, datetime)
    end
    
  end
end 