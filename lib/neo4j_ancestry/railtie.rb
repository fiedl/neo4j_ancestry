module Neo4jAncestry
  class Railtie < Rails::Railtie

    rake_tasks do
      tasks = %w(setup start stop)
      for task in tasks
        load File.expand_path("../../../lib/tasks/#{task}.rake", __FILE__)
      end
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