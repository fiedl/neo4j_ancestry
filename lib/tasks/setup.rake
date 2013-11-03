namespace :neo4j do
  
  desc "Setup Neo4j Database Stages (development, test)"
  task :setup_stages do
    
    # neo4j folders for the development stage and for the test stage
    #
    `mkdir db/neo4j`
    `mv neo4j db/neo4j/development`
    `cp -r db/neo4j/development db/neo4j/test`
    
    # the port number for the development database is 7474 (default),
    # the port number for the test database is 7574.
    # For https, the ports are 7473 (development) and 7573 (test). 
    #
    `sed -i -e 's/7474/7574/g' db/neo4j/test/conf/neo4j-server.properties`
    `sed -i -e 's/7473/7573/g' db/neo4j/test/conf/neo4j-server.properties`    
    
    # the wrapper names are 'neo4j-development' and 'neo4j-test' respectively.
    #
    `sed -i -e 's/wrapper.name=neo4j/wrapper.name=neo4j-development/g' db/neo4j/development/conf/neo4j-wrapper.conf`
    `sed -i -e 's/wrapper.name=neo4j/wrapper.name=neo4j-test/g' db/neo4j/test/conf/neo4j-wrapper.conf`
  end
end