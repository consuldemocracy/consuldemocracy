class AddFieldsToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :address, :string
    add_column :proposals, :commitment, :string
    add_column :proposals, :solve, :string
    add_column :proposals, :relevant, :string
    add_column :proposals, :additional_info, :string
    add_column :proposals, :activity, :string
  end
end
