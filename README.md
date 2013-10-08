# Neo4jAncestry

This ruby on rails gem makes it easy to store polymorphic structure information --- `parents`, `children`, `ancestors`, `descendants`, ... --- in a [neo4j graph database](http://www.neo4j.org) parallel to using ActiveRecord.

All relevant information is stored in your default ActiveRecord database, including the parent-child relationships. But, in addition, the structure information is also stored in a neo4j graph database in order to use its power of fast graph traversing queries.

## Usage

TODO: Write usage instructions here


## Installation

Add this line to your application's Gemfile:

    gem 'neo4j_ancestry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neo4j_ancestry


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
