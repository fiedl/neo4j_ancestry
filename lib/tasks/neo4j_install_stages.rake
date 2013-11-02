namespace :neo4j do
  task install_stages: :environment do
    
    `mkdir db/neo4j`
    `mv neo4j`
    
  end
end