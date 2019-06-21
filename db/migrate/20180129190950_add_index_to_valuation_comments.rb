class AddIndexToValuationComments < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index :comments, :valuation, algorithm: :concurrently
  end
end
