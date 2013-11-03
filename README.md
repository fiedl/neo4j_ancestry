# Neo4jAncestry 

[![Build Status](https://travis-ci.org/fiedl/neo4j_ancestry.png?branch=master)](https://travis-ci.org/fiedl/neo4j_ancestry)

This ruby on rails gem makes it easy to store polymorphic structure information --- `parents`, `children`, `ancestors`, `descendants`, ... --- in a [neo4j graph database](http://www.neo4j.org) parallel to using ActiveRecord.

All relevant information is stored in your default ActiveRecord database, including the parent-child relationships. But, in addition, the structure information is also stored in a neo4j graph database in order to use its power of fast graph traversing queries.

## Usage

TODO: Write usage instructions here


## Installation

Add the gem to your application's `Gemfile`:

    # Gemfile
    # ...
    gem 'neo4j_ancestry'

And then execute:

    # bash
    bundle install

Install the neo4j database `db` directory:

    # bash
    bundle exec rake neo4j:install
    bundle exec rake neo4j:setup_stages
    
Activate the neo4j database deamon. Otherwise, connecting to the neo4j database 
will fail in the further setup process.

    # bash
    bundle exec foreman start neo4j
    
Next, migrate the database in order to add the neccessary tables.

    # bash
    bundle exec rake neo4j_ancestry:install:migrations
    bundle exec rake db:migrate
    

## Underlying Technology

* The [neo4j graph database](http://www.neo4j.org)
* The [neography gem](https://github.com/maxdemarzi/neography) is used as datbase interface.
* The [neoid gem](https://github.com/elado/neoid) is used for database abstraction in parallel to ActiveRecord.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author, License

(c) 2013, Sebastian Fiedlschuster

Released under the [MIT License](./MIT-LICENSE).
