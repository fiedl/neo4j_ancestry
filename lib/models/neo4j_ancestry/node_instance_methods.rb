module Neo4jAncestry
  module NodeInstanceMethods
    
    # Neo4j Association Methods
    # ========================================================================================

    # # The neoid gem provides a neo_node method, which returns an object
    # # representing the node in the neo4j database that corresponds to this
    # # object.
    # # 
    # # Overriding the neo_node method ensures that for STI the same neo_node
    # # is returned for the same object regardless of the subclass.
    # # 
    # # That means: group.neo_node == group.becomes(SpecialGroup).neo_node
    # #
    # def neo_node
    #   super || self.becomes(self.class.base_class).neo_node
    # end
    # 
    # # The unique id of the neo4j node that corresponds to this object.
    # #
    # def neo_id
    #   neo_node.try(:neo_id)
    # end
    
    
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
        match (self)<-[:is_parent_of*1..100]-(ancestors)
        #{where('ancestors.active_record_class' => options[:type])}
        return distinct ancestors
      ")
    end
    def descendants(options = {})
      find_related_nodes_via_cypher("
        match (self)-[:is_parent_of*1..100]->(descendants)
        #{where('descendants.active_record_class' => options[:type])}
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
        "(obj#{counter} {#{active_record_object.neo_id}})"
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
       
      find_related_nodes_via_cypher("
        match 
          #{via_object_declarations_str}
          (destination_object {#{destination_object.neo_id}}),
          paths = (#{nodes_to_connect.join(')' + relation_str + '(')})
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
        #{neo_self_match_clause}
        #{query_string}
      "
      # t1 = Time.now
      result = CypherResult.new(Neo4jDatabase.execute(query_string))
      # t2 = Time.now
      result.to_active_record || []
      # t3 = Time.now

      
      # p "===", (t2-t1)*1000.0, (t3-t2)*1000.0
      # result.to_active_record || []
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
      conditions_str = ""
      if conditions_array.count > 0
        conditions_str = "WHERE " + conditions_array.join(" AND ")
      end
      return conditions_str
    end

    # This returns a MATCH clause which finds the neo node that represents
    # this ActiveRecord object.
    #
    def neo_self_match_clause
      "MATCH (self {#{neo_self_condition}})"
    end
    def neo_self_condition
      "active_record_class: '#{self.class.base_class}', active_record_id: #{self.id}"
    end
    # as a shortcut:
    def neo_id 
      neo_self_condition
    end
    
    # This creates a MERGE clause which finds or creates the node repsesenting
    # this ActiveRecord object.
    #
    def neo_self_merge_clause
      "MERGE (self:#{self.class.base_class} {#{neo_self_condition}})"
    end
    
    def create_or_update_neo_node
      Neo4jDatabase.execute("
        #{neo_self_merge_clause} 
        #{neo_attribute_set_clauses}
        return self
      ")
    end

    # For example: [:name, :email]
    def attribute_keys_to_copy_to_neo4j
      self.class.instance_variable_get :@attribute_keys_to_copy_to_neo4j
    end
    
    # For example: {name: "John Doe", email: "doe@example.com"}
    def attributes_to_copy_to_neo4j
      Hash[ attribute_keys_to_copy_to_neo4j.map { |key| [key, self.send(key)] } ]
    end
    
    # For example:
    #   set self.name = "John Doe"
    #   set self.email = "doe@example.com"
    #
    def neo_attribute_set_clauses
      attribute_keys_to_copy_to_neo4j.collect do |key|
        "set self.#{key} = '#{self.send(key)}'"
      end.join("\n")
    end
    
    def destroy_neo_node
      Neo4jDatabase.execute("
        #{neo_self_match_clause} 
        delete self
      ")
    end
    def destroy_neo_node_and_relations
      Neo4jDatabase.execute("
        #{neo_self_match_clause} 
        optional match (self)-[relation]
        delete self, relation
      ")
    end
    
  end
end