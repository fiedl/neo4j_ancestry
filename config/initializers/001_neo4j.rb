# This initializers estableshes the connection to the neo4j graph database.
# The settings for this connection are stored in 
# 
#    # TODO
#
# For further information how this connection works, have a look at:
# 
#    https://github.com/elado/neoid#usage
#

if Rails.env.development?
  neo4j_url = "http://localhost:7474"
elsif Rails.env.test?
  neo4j_url = "http://localhost:7574"
elsif Rails.env.production?
  raise 'TODO: read the neo4j server connection from config file.'
end

uri = URI.parse(neo4j_url)

$neo = Neography::Rest.new(uri.to_s)

Neography.configure do |c|
  c.server = uri.host
  c.port = uri.port

  if uri.user && uri.password
    c.authentication = 'basic'
    c.username = uri.user
    c.password = uri.password
  end
end

Neoid.db = $neo

Neoid.configure do |c|
  # should Neoid create sub-reference from the ref node (id#0) to every node-model? default: true
  c.enable_subrefs = false
end