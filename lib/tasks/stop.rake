
Rake::Task["neo4j:stop"].clear
namespace :neo4j do
  
  desc "Stop Neo4j Databases Deamons for Stages (development, test)"
  task :stop do
    
    `db/neo4j/development/bin/neo4j stop`
    `db/neo4j/test/bin/neo4j stop`

  end
end