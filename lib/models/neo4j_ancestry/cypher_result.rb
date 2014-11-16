module Neo4jAncestry
  class CypherResult < Hash
    
    # This method returns a representation of the CypherResult as ActiveRecord objects,
    # e.g. a single ActiveRecord object, an Array of such objects or even an Array of 
    # Array of such objects (which would be an Array of paths).
    #
    # The Cypher result is formatted as REST API output,
    # see http://docs.neo4j.org/chunked/stable/rest-api-cypher.html.
    #
    # Options:
    #   - type: Assume that the result objects are of the given type, which makes the
    #       conversion to ActiveRecord faster. Example: "Group".
    #
    def to_active_record(options = {})
      ( 
        object_data_to_active_record         ||  # single ActiveRecord object
        array_data_to_active_record(options) ||  # Array of ActiveRecord objects
        path_data_to_active_record               # Array of Arrays of ActiveRecord objects
      )
    end

    # Assuming the CypherResult represents a single node, this method
    # returns the corresponding ActiveRecord object.
    # 
    # The CypherResult looks like this:
    #     {"extensions"=>{},
    #      "paged_traverse"=>
    #       "http://localhost:7574/db/data/node/217/paged/traverse/{returnType}{?pageSize,leaseTime}",
    #      "outgoing_relationships"=>
    #       "http://localhost:7574/db/data/node/217/relationships/out",
    #      "traverse"=>"http://localhost:7574/db/data/node/217/traverse/{returnType}",
    #      "all_typed_relationships"=>
    #       "http://localhost:7574/db/data/node/217/relationships/all/{-list|&|types}",
    #      "property"=>"http://localhost:7574/db/data/node/217/properties/{key}",
    #      "all_relationships"=>
    #       "http://localhost:7574/db/data/node/217/relationships/all",
    #      "self"=>"http://localhost:7574/db/data/node/217",
    #      "properties"=>"http://localhost:7574/db/data/node/217/properties",
    #      "outgoing_typed_relationships"=>
    #       "http://localhost:7574/db/data/node/217/relationships/out/{-list|&|types}",
    #      "incoming_relationships"=>
    #       "http://localhost:7574/db/data/node/217/relationships/in",
    #      "incoming_typed_relationships"=>
    #       "http://localhost:7574/db/data/node/217/relationships/in/{-list|&|types}",
    #      "create_relationship"=>"http://localhost:7574/db/data/node/217/relationships",
    #      "data"=>
    #       {"ar_id"=>32,
    #        "neoid_unique_id"=>"Group:32",
    #        "name"=>"F",
    #        "ar_type"=>"Group"}}
    #
    def object_data_to_active_record
      if self["data"] && self["data"].kind_of?(Hash) && self["data"]["active_record_class"] && self["data"]["active_record_id"]
        self["data"]["active_record_class"].constantize.find(self["data"]["active_record_id"]) 
      end
    end
    
    # This method returns an Array of ActiveRecord objects.
    # 
    # The CypherResult looks like this:
    # 
    #    {"columns"=>["siblings"],
    #     "data"=>
    #      [[{"extensions"=>{},
    #         "paged_traverse"=>
    #          "http://localhost:7574/db/data/node/664/paged/traverse/{returnType}{?pageSize,leaseTime}",
    #         "outgoing_relationships"=>
    #          "http://localhost:7574/db/data/node/664/relationships/out",
    #         "traverse"=>
    #          "http://localhost:7574/db/data/node/664/traverse/{returnType}",
    #         "all_typed_relationships"=>
    #          "http://localhost:7574/db/data/node/664/relationships/all/{-list|&|types}",
    #         "property"=>"http://localhost:7574/db/data/node/664/properties/{key}",
    #         "all_relationships"=>
    #          "http://localhost:7574/db/data/node/664/relationships/all",
    #         "self"=>"http://localhost:7574/db/data/node/664",
    #         "properties"=>"http://localhost:7574/db/data/node/664/properties",
    #         "outgoing_typed_relationships"=>
    #          "http://localhost:7574/db/data/node/664/relationships/out/{-list|&|types}",
    #         "incoming_relationships"=>
    #          "http://localhost:7574/db/data/node/664/relationships/in",
    #         "incoming_typed_relationships"=>
    #          "http://localhost:7574/db/data/node/664/relationships/in/{-list|&|types}",
    #         "create_relationship"=>
    #          "http://localhost:7574/db/data/node/664/relationships",
    #         "data"=>
    #          {"neoid_unique_id"=>"Group:439",
    #           "ar_id"=>439,
    #           "ar_type"=>"Group",
    #           "name"=>"Sibling Group"}}],
    #
    # Options:
    #   - type: Assume that the result objects are of the given type, which makes the
    #       conversion to ActiveRecord faster. Example: "Group".
    #
    # This method is able to convert object results as well as id results.
    #   Example:
    #     - match (n) ... return n
    #     - match (n) ... return n.active_record_id
    #
    def array_data_to_active_record(options = {})
      if options[:type]
        if self["data"].first.first.kind_of? Integer
          # self["data"] == [[1], [2], [3], ...]
          ids = self["data"].collect { |node_data| node_data.first }
          options[:type].constantize.find(ids)
        elsif self["data"] && self["data"].first && self["data"].first.first && self["data"].first.first["data"] && self["data"].first.first["data"]["active_record_class"]
          ids = self["data"].collect { |node_data| node_data.first["data"]["active_record_id"] }
          options[:type].constantize.find(ids)
        end
      else        
        if self["data"] && self["data"].first && self["data"].first.first && self["data"].first.first["data"] && self["data"].first.first["data"]["active_record_class"]
          self["data"].collect do |node_data| 
            CypherResult.new(node_data.first).to_active_record
          end
        end
      end
    end
    
    # This method returns an Array of paths, where each path
    # is represented by an Array of nodes, each node being
    # represented by an ActiveRecord object.
    #
    # For example,
    #
    #     [
    #      [<Group...>,<Group...>,<User...>],
    #      [<Group...>,<Group...>,<User...>]
    #     ]
    #
    # A result of a cypher path query looks like this:
    #
    #     {"columns"=>["paths"],
    #      "data"=>
    #       [[{"start"=>"http://localhost:7574/db/data/node/147",
    #          "nodes"=>
    #           ["http://localhost:7574/db/data/node/147",
    #            "http://localhost:7574/db/data/node/146",
    #            "http://localhost:7574/db/data/node/147",
    #            "http://localhost:7574/db/data/node/149",
    #            "http://localhost:7574/db/data/node/148",
    #            "http://localhost:7574/db/data/node/144"],
    #          "length"=>5,
    #          "relationships"=>
    #           ["http://localhost:7574/db/data/relationship/130",
    #            "http://localhost:7574/db/data/relationship/130",
    #            "http://localhost:7574/db/data/relationship/133",
    #            "http://localhost:7574/db/data/relationship/135",
    #            "http://localhost:7574/db/data/relationship/134"],
    #          "end"=>"http://localhost:7574/db/data/node/144"}],    
    #      ...
    #
    def path_data_to_active_record
      if self["data"] && self["data"].first && self["data"].first.first && self["data"].first.first["nodes"]
        paths_data = self["data"]
        paths_of_node_references = paths_data.collect { |path| path.first["nodes"] }
        
        paths_of_nodes = paths_of_node_references.collect do |path|
          path.collect do |node_reference|
            CypherResult.new(Neo4jDatabase.get_node(node_reference)).to_active_record
          end
        end
      end
    end
    
    # # Same as #to_active_record, but as ActiveRecord::Relation.
    # #
    # def to_arel
    #   self["data"]["ar_type"].constantize.where(id: self["data"]["ar_id"].limit(1))
    # end
    
    def initialize(hash)
      # copy over values from hash
      self.merge!(hash)
    end
    
  end
end