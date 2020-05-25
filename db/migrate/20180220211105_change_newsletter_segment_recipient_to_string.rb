class ChangeNewsletterSegmentRecipientToString < ActiveRecord::Migration[4.2]
  def change
    change_column :newsletters, :segment_recipient, :string, null: false
  end
end
