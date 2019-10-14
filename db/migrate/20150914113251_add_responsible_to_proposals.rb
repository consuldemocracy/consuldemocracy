class AddResponsibleToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :responsible_name, :string, limit: 60
  end
end
