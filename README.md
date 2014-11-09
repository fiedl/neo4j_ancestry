# Neo4jAncestry

[![Build Status](https://travis-ci.org/fiedl/neo4j_ancestry.png?branch=master)](https://travis-ci.org/fiedl/neo4j_ancestry)

This ruby on rails gem makes it easy to store polymorphic structure information—`parents`, `children`, `ancestors`, `descendants`, …—in a [neo4j graph database](http://www.neo4j.org) parallel to using ActiveRecord.

All relevant information is stored in your default ActiveRecord database, including the parent-child relationships. But, in addition, the structure information is also stored in a neo4j graph database in order to use its power of fast graph traversing queries.

## Usage

TODO: Write usage instructions here

* use `has_neo4j_ancestry` in nodes
* use methods like `ancestors` or `ancestor_groups`
* special methods like `find_shortest_path_to(other_node)`.

## Graph Data Browser

You can use Neo4j's excellent web interface when the daemon is running:
* development environment: http://localhost:7474
* test environment: http://localhost:7574.

![Bildschirmfoto 2014 11 09 Um 02.47.29](images/Bildschirmfoto%202014-11-09%20um%2002.47.29.png)

From there, you can use [Cypher](http://neo4j.com/developer/cypher-query-language/) queries like this producing the above:

```cypher
match
  (group1:Group {active_record_id: 2978}),
  (group2:Group {active_record_id: 2983}),
  paths = (group1)-[:is_parent_of*1..100]->(group2)
return paths
order by length(paths)
```

This is an excellen cheat sheet for cypher:
http://neo4j.com/docs/2.0/cypher-refcard/

## Installation

### Installing Java 7 JDK

First, make sure, **Java 7 JDK** is installed. You can check using `java -version`. If you need to install it:

* Mac OS
  * Install the JDK, not the JRE: [Download](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
  * Set your `JAVA_HOME` environment variable in the `.zshenv` or `.bashrc` like this:
    
    ```bash
    # .zshenv
    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
    ```
    
* Ubuntu/Debian GNU Linux
  * `aptitude install openjdk-7-jre-headless`

### Including the gem

Add the gem to your application's `Gemfile`:

    # Gemfile
    # ...
    gem 'neo4j_ancestry'

And then execute:

    # bash
    bundle install

### Installing Neo4j

This will install two instances of the neo4j database inside the `db` directory of your app—one instance for `development`, one for `test`. The data of the database instances are stored in `data` subdirectories.

    # bash
    bundle exec rake neo4j:install neo4j:get_spatial neo4j:setup neo4j:start

### ActiveRecord Migration

Next, migrate the ActiveRecord database in order to add a table for direct links between objects. This way, all relevant information is stored within the ActiveRecord database. This way, the whole graph database could be reconstructed from the ActiveRecord database.

    # bash
    bundle exec rake neo4j_ancestry:install:migrations
    bundle exec rake db:migrate


## Underlying Technology

* The [neo4j graph database](http://www.neo4j.org)
* The [neography gem](https://github.com/maxdemarzi/neography) is used as datbase interface.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Running the Gem's Specs Locally

Symlink the `Gemfile` according to the Rails version you would like to use:

```bash
# bash
rm Gemfile Gemfile.lock
ln -s rails3.2.Gemfile Gemfile   # for Rails 3
ln -s rails4.Gemfile Gemfile     # for Rails 4  (default)
```

Next, install the dependencies and run the specs.

```bash
# bash
bundle install
bundle exec rake neo4j_ancestry:db:test:prepare
bundle exec rake
```

## Author, License

&copy; 2013-2014, Sebastian Fiedlschuster

Released under the [MIT License](./MIT-LICENSE).
