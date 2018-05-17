class AddHiddenAtToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :hidden_at, :datetime
  end
end
