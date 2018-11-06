class AddValuationFlagToComments < ActiveRecord::Migration
  def change
    add_column :comments, :valuation, :boolean, default: false
  end
end
