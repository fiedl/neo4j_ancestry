require 'rubygems'
#require 'neography'
#require 'neoid'

module Neo4jAncestry
  class Engine < ::Rails::Engine
    
    engine_name "neo4j_ancestry"
    
    config.generators do |g|
      # use rspec, see: http://whilefalse.net/2012/01/25/testing-rails-engines-rspec/
      g.test_framework :rspec
      g.integration_tool :rspec
    end
    
  end
end