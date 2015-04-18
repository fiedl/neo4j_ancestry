# This initializers estableshes the connection to the neo4j graph database.
# The settings for this connection are stored in 
# 
#    # TODO
#
# For further information how this connection works, have a look at:
# 
#    https://github.com/elado/neoid#usage
#

neo4j_url = ""
if Rails.env.development?
  neo4j_url = ENV['NEO4J_URL'] || "http://localhost:7474"
elsif Rails.env.test?
  neo4j_url = ENV['NEO4J_URL'] || "http://localhost:7574"
elsif Rails.env.production?
  raise 'TODO: read the neo4j server connection from config file.'
end

Neo4jDatabase.connect neo4j_url
