class ChangeNewsletterSegmentRecipientToString < ActiveRecord::Migration
  def change
    change_column :newsletters, :segment_recipient, :string, null: false
  end
end
