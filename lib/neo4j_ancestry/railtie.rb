module Neo4jAncestry
  class Railtie < Rails::Railtie

    rake_tasks do
      load File.expand_path("../../../lib/tasks/setup_stages.rake", __FILE__)
    end
    
    initializer 'setup neo4j database connection' do
      load File.expand_path("../../../config/initializers/001_neo4j.rb", __FILE__)
    end
    
    # initializer 'neo4j_ancestry.active_record_additions' do
    #   ActiveSupport.on_load(:active_record) do
    #     ActiveRecord::Base.send(:extend, Neo4jAncestry::ActiveRecordAdditions)
    #   end
    # end

  end
end