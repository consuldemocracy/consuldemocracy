class ChangeDebatesTitleLength < ActiveRecord::Migration[4.2]
  def up
    change_column :debates, :title, :string, limit: 80
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
