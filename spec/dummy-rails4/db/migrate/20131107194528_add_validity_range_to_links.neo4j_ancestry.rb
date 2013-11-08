# This migration comes from neo4j_ancestry (originally 20131107194437)
class AddValidityRangeToLinks < ActiveRecord::Migration
  def change
    add_column :neo4j_ancestry_links, :valid_from, :datetime
    add_column :neo4j_ancestry_links, :valid_to, :datetime
    add_column :neo4j_ancestry_links, :created_at, :datetime
    add_column :neo4j_ancestry_links, :updates_at, :datetime
  end
end
