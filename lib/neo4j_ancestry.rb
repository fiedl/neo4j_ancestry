require 'rubygems'
require 'neography'

require "models/active_record_associations_patches"

require "models/neo4j_ancestry/neo4j_database"
require "models/neo4j_ancestry/active_record_additions"
require "models/neo4j_ancestry/node_instance_methods"
require "models/neo4j_ancestry/link"
require "models/neo4j_ancestry/cypher_result"

require "models/neography/node"
require "models/neography/node_traverser"

require "neo4j_ancestry/engine"
require "neo4j_ancestry/railtie"
require "neo4j_ancestry/version"