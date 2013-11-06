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
      # match (self)<-[:is_parent_of]-(parents)
      self.neo_node.incoming(:is_parent_of).to_active_record
    end
    def children
      # match (self)-[:is_parent_of]->(children)
      self.neo_node.outgoing(:is_parent_of).to_active_record
    end
    def ancestors(options = {})
      # match (self)<-[:is_parent_of*1..100]->(ancestors)
      self.neo_node.incoming(:is_parent_of).depth(100).to_active_record
    end
    def descendants(options = {})
      # match (self)-[:is_parent_of*1..100]->(descendants)
      objs = self.neo_node.outgoing(:is_parent_of).depth(100).to_active_record
      objs.select! { |obj| obj.kind_of? options[:type].constantize } if options[:type].present?
      return objs
      
      # where_clause_for_type = "where descendants.ar_type = '#{options[:type]}'" if options[:type]
      # where_clause_for_type ||= ""
      # find_related_nodes_via_cypher("
      #   match (self)-[:is_parent_of*1..100]->(descendants)
      #   #{where_clause_for_type}
      #   return descendants
      # ").uniq
    end
    def siblings
      find_related_nodes_via_cypher("
        match (self)<-[:is_parent_of]-(parent)-[:is_parent_of]->(siblings)
        return siblings
      ").uniq
    end
    
    
    # Route Traversing Methods
    # ========================================================================================
    
    def find_routes_to(other_object)
      
      # find_related_nodes_via_cypher(",
      #   other_object = node(#{other_object.neo_id})
      #   match path = (self)-[:is_parent_of*1..100]-(other_object)
      #   return path
      # ")
  
      self.neo_node.all_paths_to(other_object.neo_node)
        .both(:is_parent_of).depth(100).nodes.collect do |path|
          neo_nodes_to_objects(path)
        end
      
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
      cypher_results_to_objects(
        Neoid.db.execute_query(query_string)
      )
    end
    
    # This method returns the ActiveRecord objects that match the
    # given cypher query result. 
    # 
    # For an example, have a look at the method
    #   find_related_nodes_via_cypher.
    #
    def cypher_results_to_objects(cypher_results)
      cypher_results["data"].collect do |result|
        #result.first["data"]["ar_type"].constantize.find(result.first["data"]["ar_id"])
        neo_node_to_object(result.first["data"])
      end
    end
    private :cypher_results_to_objects
    
    # Neography often returns an encapsulated array of neo_nodes, e.g.
    #    [[neo_node1, neo_node2 ...]]
    #
    # This method returns an array of the associated ActiveRecord objects.
    #
    def neo_nodes_to_objects(neo_nodes)
      neo_nodes_array = neo_nodes.first if neo_nodes.first.kind_of? Array
      neo_nodes_array ||= neo_nodes
      neo_nodes_array.collect do |neo_node|
        neo_node_to_object neo_node
      end
    end
    private :neo_nodes_to_objects
    
    # This method finds the ActiveRecord object that corresponds to 
    # a NeoNode. 
    #
    # TODO: I have not found a method on neo_node that simply returns the 
    # ActiveRecord object. If you know this method, please change this
    # method accordingly.
    #
    def neo_node_to_object(neo_node)
      neo_node["ar_type"].constantize.find neo_node["ar_id"]
    end
    private :neo_node_to_object
    
    # # This method returns an ActiveRecord::Relation that refers to the
    # # ActiveRecord object associated with the given neo_node.
    # #
    # # This might be useful if one would like to apply further where
    # # clauses, et cetera.
    # #
    # def neo_node_to_arel(neo_node)
    #   neo_node["ar_type"].where id: neo_node["ar_id"]
    # end
    # private :neo_node_to_arel
    # 
    # def neo_nodes_to_arel(neo_nodes)
    #   # TODO: How can multiple ActiveRecord::Relations contained in an Array
    #   # be combined to a single ActiveRecord::Relation, joined by the OR
    #   # operator?
    #   # 
    #   # There are a couple of possibilities:
    #   #   * http://stackoverflow.com/questions/9540801/combine-two-activerecordrelation-objects
    #   #   * http://stackoverflow.com/questions/7976358/activerecord-arel-or-condition
    #   #   * http://railscasts.com/episodes/355-hacking-with-arel
    #   # 
    #   # But, for the moment, I'm not sure if this is worth the efford.
    # end
    # private :neo_nodes_to_arel
    
  end
end