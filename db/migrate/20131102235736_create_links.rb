class CreateLinks < ActiveRecord::Migration
  def change
    create_table :neo4j_ancestry_links do |t|
      t.integer :parent_id
      t.string :parent_type
      t.integer :child_id
      t.string :child_type
    end
  end
end
