class AddValuationFlagToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :valuation, :boolean, default: false
  end
end
