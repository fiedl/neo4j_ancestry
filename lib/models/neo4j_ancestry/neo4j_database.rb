class Neo4jDatabase
  
  def self.connect(neo4j_url = "http://localhost:7474")
    @@singleton = self.new
    @@singleton.connect
  end
  def self.method_missing(m, *args, &block)
    @@singleton.send m, *args, &block
  end
  
  def connect(neo4j_url = "http://localhost:7474")
    uri = URI.parse(neo4j_url)
    connect_rest_interface uri

    Neography.configure do |c|
      c.server = uri.host
      c.port = uri.port

      if uri.user && uri.password
        c.authentication = 'basic'
        c.username = uri.user
        c.password = uri.password
      end
    end
  end
  def rest_interface
    @rest_interface
  end
  def connect_rest_interface(uri)
    @rest_interface = Neography::Rest.new(uri.to_s)
  end
  
  def execute(query)
    # print "#{query}\n".blue
    rest_interface.execute_query query
  end
  def get_node(reference)
    rest_interface.get_node(reference)
  end
  
  def clear(confirmation)
    if confirmation == :yes_i_am_sure
      execute "
        MATCH (n)
        OPTIONAL MATCH (n)-[r]-()
        DELETE n,r
      "
    end
  end
end