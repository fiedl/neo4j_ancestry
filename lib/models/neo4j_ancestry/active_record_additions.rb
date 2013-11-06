module Neo4jAncestry
  module ActiveRecordAdditions
    require 'neo4j_ancestry/railtie' if defined?(Rails)
    
    # Example options:
    #   parent_class_names: %w(Group), 
    #   child_class_names: %w(Group User)
    #
    def has_neo4j_ancestry(options)
      
      link_class_name = 'Neo4jAncestry::Link'
      
      # Links (direct relationships between objects) are stored
      # via ActiveRecord in the mysql database. (The neo4j database contains only 
      # redundant information and is used for fast queries.)
      #
      has_many :links_as_parent, foreign_key: :parent_id, class_name: link_class_name
      has_many :links_as_child, foreign_key: :child_id, class_name: link_class_name
      
      parent_class_names = options[:parent_class_names] || []
      child_class_names = options[:child_class_names] || []
      
      # links_as_child for specific parent object classes and
      # links_as_parent for specific child object classes, e.g.
      #   group.links_as_child_for_groups
      #   group.links_as_parent_for_groups
      #   group.links_as_parent_for_users
      #
      parent_class_names.each do |parent_class_name|
        has_many_for_rails_3_and_4(
          "links_as_child_for_#{parent_class_name.underscore.pluralize}".to_sym,
          { parent_type: parent_class_name },
          { as: :child, class_name: link_class_name } )
      end
      child_class_names.each do |child_class_name|
        has_many_for_rails_3_and_4( 
          "links_as_parent_for_#{child_class_name.underscore.pluralize}".to_sym, 
          { child_type: child_class_name },
          { as: :parent, class_name: link_class_name } )
      end
      
      # parent and child associations for specific object classes, e.g.
      #   group.parent_groups
      #   group.child_groups
      #   group.child_users
      #
      parent_class_names.each do |parent_class_name|
        has_many( 
          "parent_#{parent_class_name.underscore.pluralize}".to_sym, 
          through: "links_as_child_for_#{parent_class_name.underscore.pluralize}".to_sym, 
          as: :structureable, 
          foreign_key: :parent_id, source: 'parent', 
          source_type: parent_class_name )
      end
      child_class_names.each do |child_class_name|
        has_many( 
          "child_#{child_class_name.underscore.pluralize}".to_sym, 
          through: "links_as_parent_for_#{child_class_name.underscore.pluralize}".to_sym, 
          as: :structureable, 
          foreign_key: :child_id, source: 'child', 
          source_type: child_class_name )
      end
      
      # ancestors and descendants for certain types of objects, e.g.
      #   group.ancestor_groups
      #   group.descendant_users
      #
      parent_class_names.each do |parent_class_name|
        define_method("ancestor_#{parent_class_name.underscore.pluralize}") do |options = {}|
          ancestors(options.merge({ type: parent_class_name }))
        end
      end
      child_class_names.each do |child_class_name|
        define_method("descendant_#{child_class_name.underscore.pluralize}") do |options = {}|
          descendants(options.merge({ type: child_class_name }))
        end
      end
      
      # Use the neoid gem to have this object represented as node
      # in the neo4j graph database.
      # 
      include Neoid::Node
      
      # Copy the name attribute to the neo4j nodes.
      # Other attributes can be copied as well by using the 'attributes_to_copy_to_neo4j'.
      # 
      attributes_to_copy_to_neo4j do |c|
        c.field :name
      end
      
      # Include the instance methods for interaction with the neo4j graph.
      #
      include Neo4jAncestry::NodeInstanceMethods
      
    end
    
    # Attributes to copy over to the neo4j database.
    # This is just a wrapper for the 'neoidable' method of the neoid gem.
    #   https://github.com/elado/neoid
    # 
    # Example:
    #   attributes_to_copy_to_neo4j do |c|
    #     c.field :name
    #     c.field :name_length do 
    #       self.name.length
    #     end
    #   end
    # 
    def attributes_to_copy_to_neo4j(&block)
      neoidable(&block)
    end
    
    # The has_many method changes from Rails 3 to Rails 4.
    # Since this gem supports both rails versions, this method
    # is a wrapper.
    #
    def has_many_for_rails_3_and_4(association_name, conditions_hash, options)
      if Rails.version.start_with? "4"
        has_many(association_name, -> { where conditions_hash }, options)
      elsif Rails.version.start_with? "3"
        has_many(association_name, options.merge({conditions: conditions_hash}))
      end
    end
    
  end
end