
Rake::Task["neo4j:start"].clear
namespace :neo4j do
  
  desc "Start Neo4j Databases Deamons for Stages (development, test)"
  task :start do
    
    `db/neo4j/development/bin/neo4j start`
    `db/neo4j/test/bin/neo4j start`

  end
end