module Neo4jAncestry
  module NodeInstanceMethods
    
    # Neo4j Association Methods
    # ========================================================================================

    # The neoid gem provides a neo_node method, which returns an object
    # representing the node in the neo4j database that corresponds to this
    # object.
    # 
    # Overriding the neo_node method ensures that for STI the same neo_node
    # is returned for the same object regardless of the subclass.
    # 
    # That means: group.neo_node == group.becomes(SpecialGroup).neo_node
    #
    def neo_node
      super || self.becomes(self.class.base_class).neo_node
    end
    
    # The unique id of the neo4j node that corresponds to this object.
    #
    def neo_id
      neo_node.try(:neo_id)
    end
    
    
    # Basic Traversing Methods
    # ========================================================================================
    
    # Methods to query the neo4j database for parents, children,
    # ancestors, descendants and siblings.
    #
    def parents
      find_related_nodes_via_cypher("
        match (parents)-[:is_parent_of]->(self)
        return parents
      ")
    end
    def children
      find_related_nodes_via_cypher("
        match (self)-[:is_parent_of]->(children)
        return children
      ")
    end
    def ancestors(options = {})
      find_related_nodes_via_cypher("
        match (self)<-[rels:is_parent_of*1..100]-(ancestors)
        #{where('ancestors.ar_type' => options[:type])} 
        AND #{validity_range_conditions(options, 'rels')}
        return distinct ancestors
      ")
    end
    def descendants(options = {})
      find_related_nodes_via_cypher("
        match (self)-[:is_parent_of*1..100]->(descendants)
        #{where('descendants.ar_type' => options[:type])}
        return distinct descendants
      ")
    end
    def siblings
      find_related_nodes_via_cypher("
        match (self)<-[:is_parent_of]-(parent)-[:is_parent_of]->(siblings)
        return distinct siblings
      ")
    end
    
    
    # Route Traversing Methods
    # ========================================================================================
    
    def find_routes_to(destination_object, options = {})
      
      if options[:via]
        unless options[:via].kind_of? Array
          options[:via] = [ options[:via] ]
        end
      end
      options[:via] ||= []
      
      counter = 0
      via_object_names = []
      via_object_declarations = options[:via].collect do |active_record_object|
        counter += 1
        via_object_names << "obj#{counter}"
        "obj#{counter} = node(#{active_record_object.neo_id})"
      end
      
      via_object_declarations_str = via_object_declarations.join(', ')
      via_object_declarations_str += ", " if via_object_declarations_str.present?
      nodes_to_connect = ["self"] + via_object_names + ["destination_object"]
      
      # Note: Providing the :direction option if the direction is known,
      # may reduce the query time considerably.
      #
      if options[:direction] == :outgoing
        relation_str = "-[:is_parent_of*1..100]->"
      elsif options[:direction] == :incoming
        relation_str = "<-[:is_parent_of*1..100]-"
      else
        relation_str = "-[:is_parent_of*1..100]-"
      end
      
      find_related_nodes_via_cypher(",
        #{via_object_declarations_str}
        destination_object = node(#{destination_object.neo_id})
        match paths = (#{nodes_to_connect.join(')' + relation_str + '(')})
        return paths
        order by length(paths)
      ") || []
    end
    
    
    # Query Methods 
    # ========================================================================================
    
    # This method returns all ActiveRecord objects found by a cypher
    # neo4j query defined through the given query_string.
    # 
    # Within the query_string, no START expression is needed, 
    # because the start node is given by the neo_node of this
    # structureable object. It is referred to just by 'self'. 
    #
    # Example:
    #   group.find_related_nodes_via_cypher("
    #     match (self)-[:is_parent_of]->(children)
    #     return children
    #   ")  # =>  [child_group1, child_group2, ...]
    #
    def find_related_nodes_via_cypher(query_string)
      query_string = "
        start self=node(#{neo_id})
        #{query_string}
      "
      
      p "QUERY", query_string if query_string.include? "valid_from"
      
      #t1 = Time.now
      result = CypherResult.new(Neoid.db.execute_query(query_string))
      #t2 = Time.now
      result.to_active_record || []
      #t3 = Time.now
      
      #p "===", (t2-t1)*1000.0, (t3-t2)*1000.0
      #result.to_active_record || []
    end
    
    # This is a helper for Cypher where clauses.
    # Example:
    #
    #     where( 'user.name' => 'Bob', 'user.age' => 16 )
    #
    # results in
    #
    #     "WHERE user.name = 'Bob' AND 'user.age' = '16'"
    #
    def where(conditions_hash = {})
      conditions_array = []
      conditions_hash.each do |key, value|
        conditions_array << "#{key} = '#{value}'" if value.present?
      end
      if conditions_array.count > 0
        conditions_str = "WHERE " + conditions_array.join(" AND ")
      else
        conditions_str = "WHERE 1=1"
      end
      return conditions_str
    end
    
    # This helper transforms the given options_hash that includes validity
    # options like 'at', 'before', 'after' into a condition string that can
    # be used in a Cypher WHERE statement.
    #
    #      valid_from           valid_to
    #         |--------------------->|
    #        
    #
    def validity_range_conditions(options_hash, relationships_identifyer = "rels")
      options_hash[:at] ||= Time.zone.now
      at_time = options_hash[:at].to_time.to_s(:db)  #.to_datetime.to_s(:db)
      valid_from_condition = "(not has(rel.valid_from)) OR rel.valid_from is null OR rel.valid_from <= '#{at_time}'"
      valid_to_condition = "(not has(rel.valid_to)) OR rel.valid_to is null OR rel.valid_to >= '#{at_time}'"
      "ALL ( rel in #{relationships_identifyer} 
             where (#{valid_from_condition}) AND (#{valid_to_condition}) 
           )"
    end
      
  end
end