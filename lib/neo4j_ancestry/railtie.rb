module Neo4jAncestry
  class Railtie < Rails::Railtie
    initializer 'neo4j_ancestry.active_record_additions' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send(:extend, Neo4jAncestry::ActiveRecordAdditions)
      end
    end
  end
end