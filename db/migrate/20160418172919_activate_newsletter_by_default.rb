class ActivateNewsletterByDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :newsletter, :boolean, default: true
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
