class DestroyBenches < ActiveRecord::Migration
  def self.up
    drop_table :benches
  end

  def self.down
    create_table :benches do |t|
      t.string  :name
      t.string  :code
      t.integer :cached_votes_up, default: 0
    end

    add_index :benches, [:cached_votes_up]
  end
end
