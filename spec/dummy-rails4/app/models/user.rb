class User < ActiveRecord::Base
  has_neo4j_ancestry parent_class_names: %w(Group)
end
