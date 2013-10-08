ENV["RAILS_ENV"] ||= 'test'

require 'rails/all'
require 'rspec/rails'
require 'rspec/autorun'

require 'neo4j_ancestry'

# The initializers are not run in this minimal spec setup.
# Therefore, extend ActiveRecord::Base manually, here.
ActiveRecord::Base.send(:extend, Neo4jAncestry::ActiveRecordAdditions)

RSpec.configure do |config|
end

# The simulated database lives in the memory rather than in a file.
ActiveRecord::Base.establish_connection( :adapter => "sqlite3", :database => ":memory:" )

# This is the required database structure.
load File.dirname( __FILE__ ) + '/support/schema.rb'