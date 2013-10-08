require 'spec_helper'

describe Neo4jAncestry::ActiveRecordAdditions do
  
  specify "additions should be available in ActiveRecord::Base" do
    ActiveRecord::Base.should respond_to :has_neo4j_ancestry
    ActiveRecord::Base.should respond_to :attributes_to_copy_to_neo4j
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
  
  describe "(simple traversal methods)" do
    before do
      @group = Group.create(name: "Group")
      @parent1 = @group.parent_groups.create(name: "Parent Group 1")
      @parent2 = @group.parent_groups.create(name: "Parent Group 2")
      @parents = [@parent1, @parent2]
      @ancestor1 = @parent1.parent_groups.create(name: "Ancestor Group 1")
      @ancestors = [@parent1, @parent2, @ancestor1]
      @child1 = @group.child_groups.create(name: "Child Group")
      @child2 = @group.child_users.create(name: "Child User")
      @children = [@child1, @child2]
      @descendant1 = @child1.child_users.create(name: "Descendant User 1")
      @descendants = [@child1, @child2, @descendant1]
      @sibling1 = @parent1.child_groups.create(name: "Sibling Group")
      @sibling2 = @parent2.child_users.create(name: "Child User 1")
      @siblings = [@sibling1, @sibling2]
    end
    describe "#parents" do
      subject { @group.parents }
      it { should == @parents }
    end
    describe "#children" do
      subject { @group.children }
      it { should == @children }
    end
    describe "#ancestors" do
      subject { @group.ancestors }
      it { should == @ancestors }
    end
    describe "#descendants" do
      subject { @group.descendants }
      it { should == @descendants }
    end
    describe "#siblings" do
      subject { @group.siblings }
      it { should == @siblings }
    end
  end

end