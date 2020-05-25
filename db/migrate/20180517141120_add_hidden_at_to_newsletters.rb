class AddHiddenAtToNewsletters < ActiveRecord::Migration[4.2]
  def change
    add_column :newsletters, :hidden_at, :datetime
  end
end
