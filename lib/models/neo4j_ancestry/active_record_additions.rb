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

      parent_class_names.each do |parent_class_name|
        has_many( "links_as_child_for_#{parent_class_name.underscore.pluralize}".to_sym, 
                  -> { where parent_type: parent_class_name },
                  #conditions: { parent_type: parent_class_name } )
                  as: :child, class_name: link_class_name )
        has_many( "parent_#{parent_class_name.underscore.pluralize}".to_sym, 
                  through: "links_as_child_for_#{parent_class_name.underscore.pluralize}".to_sym, 
                  as: :structureable, 
                  foreign_key: :parent_id, source: 'parent', 
                  source_type: parent_class_name )
        define_method "ancestor_#{parent_class_name.underscore.pluralize}".to_sym do
          send("parent_#{parent_class_name.underscore.pluralize}".to_sym)
        end
      end  

      child_class_names.each do |child_class_name|
        has_many( "links_as_parent_for_#{child_class_name.underscore.pluralize}".to_sym, 
                  -> { where child_type: child_class_name },
                  #conditions: { child_type: child_class_name } )
                  as: :parent, class_name: link_class_name )
        has_many( "child_#{child_class_name.underscore.pluralize}".to_sym, 
                  through: "links_as_parent_for_#{child_class_name.underscore.pluralize}".to_sym, 
                  as: :structureable, 
                  foreign_key: :child_id, source: 'child', 
                  source_type: child_class_name )
        define_method "descendant_#{child_class_name.underscore.pluralize}".to_sym do
          send("child_#{child_class_name.underscore.pluralize}".to_sym)
        end
      end

    end
    
  end
end