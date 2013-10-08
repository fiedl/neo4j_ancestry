require 'neo4j_ancestry'

ActiveRecord::Schema.define(version: 1) do
  
  create_table :users do |t|
    t.string :name
  end
  
  create_table :groups do |t|
    t.string :name
  end
  
  create_table :neo4j_ancestry_links do |t|
    t.integer :parent_id
    t.string :parent_type
    t.integer :child_id
    t.integer :child_type
  end
  
end


class User < ActiveRecord::Base
  has_neo4j_ancestry parent_class_names: %w(Group)
end

class Group < ActiveRecord::Base
  has_neo4j_ancestry parent_class_names: %w(Group), child_class_names: %w(Group User)

  def assign_user(user)
    self.child_users << user
  end
  def unassign_user(user)
    # TODO
  end
end

class ParentChildRelationship < Neo4jAncestry::Link
  def to_s
    "#{parent.name} is parent of #{child.name}."
  end
end
