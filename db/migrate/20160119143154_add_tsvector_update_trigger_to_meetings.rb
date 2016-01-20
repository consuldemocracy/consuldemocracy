class AddTsvectorUpdateTriggerToMeetings < ActiveRecord::Migration

  def up
    add_column :meetings, :tsv, :tsvector
    add_index :meetings, :tsv, using: "gin"
  end

  def down
    remove_index :meetings, :tsv
    remove_column :meetings, :tsv
  end

end
