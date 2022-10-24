class ChangeNewsletterSegmentRecipientToString < ActiveRecord::Migration[4.2]
  def up
    change_column :newsletters, :segment_recipient, :string, null: false
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
