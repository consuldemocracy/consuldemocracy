class AddOficialToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :oficial, :boolean, default: false
  end
end
