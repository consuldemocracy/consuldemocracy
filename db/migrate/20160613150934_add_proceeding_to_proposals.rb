class AddProceedingToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :proceeding, :string
    add_index :proposals, :proceeding
  end
end
