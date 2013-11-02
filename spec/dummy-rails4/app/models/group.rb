class Group < ActiveRecord::Base
  has_neo4j_ancestry parent_class_names: %w(Group), child_class_names: %w(Group User)

  def assign_user(user)
    self.child_users << user
  end
  def unassign_user(user)
    # TODO
  end
end
