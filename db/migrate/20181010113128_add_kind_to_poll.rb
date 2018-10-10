class AddKindToPoll < ActiveRecord::Migration
  def up
    add_column :polls, :kind, :string
  end

  def down
    remove_column :polls, :kind
  end
end
