module Neo4jAncestry
  module NodeInstanceMethods

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
    
    # Methods to query the neo4j database for parents, children,
    # ancestors, descendants and siblings.
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
    def ancestors
      find_related_nodes_via_cypher("
        match (ancestors)-[:is_parent_of*1..100]->(self)
        return ancestors
      ").uniq
    end
    def descendants
      find_related_nodes_via_cypher("
        match (self)-[:is_parent_of*1..100]->(descendants)
        return descendants
      ").uniq
    end
    def siblings
      find_related_nodes_via_cypher("
        match (self)<-[:is_parent_of]-(parent)-[:is_parent_of]->(siblings)
        return siblings
      ").uniq
    end
    
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
        result.first["data"]["ar_type"].constantize.find(result.first["data"]["ar_id"])
      end
    end
    private :cypher_results_to_objects
    
  end
end