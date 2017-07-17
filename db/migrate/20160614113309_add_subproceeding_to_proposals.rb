class AddSubproceedingToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :sub_proceeding, :string, index: true
    add_index :proposals, :sub_proceeding
  end
end
