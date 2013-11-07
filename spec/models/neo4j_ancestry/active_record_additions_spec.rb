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
      #   spec/dummy-rails4/app/models/group.rb
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
  
  describe "(association methods)" do
    before do
      @user = User.create(name: "John Doe")
      @group = Group.create(name: "Group")
      @parent_group = @group.parent_groups.create(name: "Parent Group")
    end
    describe "#child_objects << [assignment]" do
      subject { @group.child_users << @user }
      it "should add the object to the list of associated objects" do
        @group.child_users.should_not include @user
        subject
        @group.child_users.should include @user
      end
      it "should also create the indirect association via the graph" do
        @user.ancestors.should_not include @parent_group
        subject
        @user.ancestors.should include @parent_group
      end
    end
    describe "#child_objects.destroy(...) [unassignment]" do
      before { @group.child_users << @user }
      subject { @group.child_users.destroy(@user) }
      it "should destroy the association" do
        @group.child_users.should include @user
        subject
        @group.child_users.should_not include @user
      end
      it "should not destroy the object itself" do
        subject
        User.all.should include @user
      end
      it "should destroy the indirect associations in the graph" do
        @user.ancestors.should include @parent_group
        subject
        @user.ancestors.should_not include @parent_group
      end
    end
  end
  
  describe "(simple traversal methods)" do
    before do
      @group = Group.create(name: "Group")
      @parent1 = @group.parent_groups.create(name: "Parent Group 1")
      @parent2 = @group.parent_groups.create(name: "Parent Group 2")
      @parents = [@parent1, @parent2]
      @ancestor1 = @parent1.parent_groups.create(name: "Ancestor Group 1")
      @ancestors = [@parent1, @ancestor1, @parent2]
      @child1 = @group.child_groups.create(name: "Child Group")
      @child2 = @group.child_users.create(name: "Child User")
      @children = [@child1, @child2]
      @descendant1 = @child1.child_users.create(name: "Descendant User 1")
      @descendants = [@child1, @descendant1, @child2]
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
    
    describe "#ancestor_groups" do
      subject { @group.ancestor_groups }
      it { should == @ancestors.select { |ancestor| ancestor.kind_of? Group } }
    end
    describe "#descendant_groups" do
      subject { @group.descendant_groups }
      it { should == @descendants.select { |descendant| descendant.kind_of? Group } }
    end
    describe "#descendant_users" do
      subject { @group.descendant_users }
      it { should == @descendants.select { |descendant| descendant.kind_of? User } }
    end
  end
  
  describe "(route traversing methods)" do
    # 
    # For visualization, consider the following graph.
    #    
    #     A
    #     |-- B ----- C -.
    #     D              |
    #     |-- E -------- F
    #     G
    #
    # In this graph, there are two routes between A and F:
    #   A -- B -- C -- F   and
    #   A -- D -- E -- F
    #
    before do
      @A = Group.create(name: "A")
      @B = @A.child_groups.create(name: "B")
      @C = @B.child_groups.create(name: "C")
      @F = @C.child_groups.create(name: "F")
      @D = @A.child_groups.create(name: "D")
      @E = @D.child_groups.create(name: "E")
      @E.child_groups << @F
      @G = @D.child_groups.create(name: "G")
    end
    describe "#find_routes_to" do
      subject { @F.find_routes_to(@A) }
      it "should return an Array of Arrays of objects (Groups in this case)" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of Array
        subject.first.first.should be_kind_of Group
      end
      it "should return the correct routes" do
        subject.should include [@A, @B, @C, @F].reverse
        subject.should include [@A, @D, @E, @F].reverse
      end
      describe "with via option" do
        describe "with one argument" do
          subject { @F.find_routes_to(@A, via: @C) }
          it "should return an Array of the correct path(s)" do
            subject.should be_kind_of Array
            subject.first.should == [@A, @B, @C, @F].reverse
          end
        end
        describe "with two arguments" do
          subject { @F.find_routes_to(@A, via: [@C, @B]) }
          it "should return an Array of the correct path(s)" do
            subject.should be_kind_of Array
            subject.first.should == [@A, @B, @C, @F].reverse
          end
        end
      end
    end

  end
end