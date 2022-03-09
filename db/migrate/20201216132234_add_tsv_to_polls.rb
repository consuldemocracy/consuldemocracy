class AddTsvToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :tsv, :tsvector
  end
end
