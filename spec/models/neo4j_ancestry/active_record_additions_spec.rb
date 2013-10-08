require 'spec_helper'

describe Neo4jAncestry::ActiveRecordAdditions do
  
  specify "additions should be available in ActiveRecord::Base" do
    ActiveRecord::Base.should respond_to :has_neo4j_ancestry
  end
  
  describe "model that has_neo4j_ancestry (here: Group)" do
    before do
      # Here the Group model is used as an example. 
      #
      # This model 
      #   has_neo4j_ancestry parent_class_names: %w(Group), child_class_names: %w(Group User)
      #
      # as can be seen in
      #   spec/support/schema.rb
      #
      @group ||= Group.new
    end
    subject { @group }
    
    # direct links stored as ActiveRecord associations
    it { should respond_to :links_as_parent }
    it { should respond_to :links_as_child }
    
    # parent class names: ["Group"]
    it { should respond_to :parent_groups }
    it { should respond_to :links_as_child_for_groups }
    
    # child class names: ["Group", "User"]
    it { should respond_to :child_groups }
    it { should respond_to :child_users }
    it { should respond_to :links_as_parent_for_groups }
    it { should respond_to :links_as_parent_for_users }
  end

end