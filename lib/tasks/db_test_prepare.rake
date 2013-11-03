namespace :neo4j_ancestry do
  namespace :db do
    namespace :test do
      
      desc "Setup Neo4j Database for Testing"
      task :prepare do
        
        rails_version = `bundle exec rails --version`.gsub("Rails ", "")
        
        dummy_path = File.expand_path(
          "../../../spec/dummy-rails#{rails_version[0]}",
          __FILE__
        )
        
        unless File.exists?("#{dummy_path}/db/neo4j")
          `cd #{dummy_path} && bundle exec rake neo4j:install neo4j:setup`
        end
        
        `cd #{dummy_path} && bundle exec rake neo4j:start`
        
      end
      
    end
  end
end